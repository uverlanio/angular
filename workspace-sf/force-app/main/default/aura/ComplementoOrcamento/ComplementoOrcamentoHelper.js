({
  inicializar : function(component, event) {
    this.buscarDadosOrcamento(component, event);
  },

  //Busca a oportunidade e os produtos para serem ofertados
  buscarDadosOrcamento : function(component, event) {
    let action = component.get("c.buscarOportunidade");

    action.setParams({
      oportunidadeId : component.get("v.recordId")
    });

    action.setCallback(this, (response) => {
      let state = response.getState();

      if(state == "SUCCESS"){
        let oportunidade = response.getReturnValue();

        if(oportunidade){
          //TODO: BUSCAR GARANTIAS
          //this.buscarProdutosVigentes(component, oportunidade.RecordType.DeveloperName);
          //this.buscarProdutosSugestao
          component.set("v.oportunidade", oportunidade);
          this.buscarCamposProduto(component, event);

        }else{
          alert("Não é mais possível editar este orçamento");
          this.cancelar(component, event);
        }

      } else if(state == "ERROR"){
        console.log( JSON.stringify(response.getError()) );
        alert('Error in calling server side action: ' + response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  //Busca os field sets de acordo com o produto relacionado a oportunidade
  buscarCamposProduto : function(component, event) {
    //let spinner = component.find('spinner');
    //$A.util.toggleClass(spinner, 'slds-hide');

    let action = component.get("c.buscarFieldSetProduto");
    let oportunidade = component.get("v.oportunidade");

    if(oportunidade.Produto__r){
      action.setParams({
        codigoProduto : oportunidade.Produto__r.ProductCode,
        objeto: 'Opportunity'
      });

      action.setCallback(this, (response) => {
        let state = response.getState();

        if(state == "SUCCESS"){
          let camposComplemento = JSON.parse(response.getReturnValue());
          console.log( 'BUSCA CAMPOS' );
          console.log( camposComplemento );

          component.set("v.camposComplemento", camposComplemento);
          this.habilitarAbaGarantias(!camposComplemento.length > 0);
          
        } else if(state == "ERROR"){
          console.log(response.getError());
          component.set("v.camposComplemento", []);
          this.habilitarAbaGarantias(true);
        }
      });

      $A.enqueueAction(action);
    }
    else{
      alert('Produto não encontrado');
      $A.get("e.force:closeQuickAction").fire();
    }
  },

  habilitarAbaGarantias : function(habilitar){
    //https://portoseguro--dev.lightning.force.com/lightning/r/Opportunity/0061F000002qkVBQAY/view

      if(habilitar){
        let elem = document.getElementById("tabItemComplemento");
        elem.parentElement.removeChild(elem);

        document.getElementById("tabAdicionais").classList.remove("slds-show");
        document.getElementById("tabAdicionais").classList.add("high-hide");
        document.getElementById("tabItemGarantia").classList.add("slds-is-active");
        document.getElementById("tabGarantias").classList.remove("slds-hide");
        document.getElementById("tabGarantias").classList.add("slds-show");
      }

  },

  calcular : function(component, event, apenasCalcular) {
    let action = component.get('c.validarCalcularOrcamento');
    action.setParams({
      orcamentoId : component.get('v.recordId')
    });

    action.setCallback(this, (response) => {
      let state = response.getState();
      console.log(state);

      if(state == "SUCCESS"){
        let resposta = response.getReturnValue();

        // Verifica se deu erro
        if(resposta != undefined){
          this.showToast(component,event,'error',resposta);
          return;
        }
        this.calcularPasso1(component, event, apenasCalcular);
      } else if(state == "ERROR"){
        console.log('Entrou no ERROR');
      }

    });

    $A.enqueueAction(action);
  },

  calcularPasso1 : function(component, event, apenasCalcular){
    console.log(' CALCULAR PASSO 1');
    component.set('v.alternaFuncao', apenasCalcular);

    // Verifica os campos obrigatórios na conta por produto
    let contaEhValida = this.contaEhValida(component,event);
    if(!contaEhValida)return;

    // Salva dados da primeira aba
    let cmpDadosAdicionais = component.find('cmpDadosAdicionais');
    if(cmpDadosAdicionais != undefined) cmpDadosAdicionais.salvarFormComplemento();
  },
  calcularPasso2 : function(component,event){
    console.log(' CALCULAR PASSO 2');
    let apenasCalcular = component.get('v.alternaFuncao');
    let cmpGarantias = component.find("cmpGarantias");
    let cmpInformacoesComplementares = component.find('orcamentoResumo');
    $A.util.toggleClass(component.find('spinner'), 'slds-hide');

    cmpGarantias.salvarAbaGarantias().then(
        $A.getCallback((result) => {
          return cmpInformacoesComplementares.salvarAbaComplementos();
        })
    )
        .then(
            $A.getCallback((result) => {
              return this.realizarCalculo(component);
            })
        ).then(
        $A.getCallback((result) => {
          return this.atualizarComponente(cmpGarantias, cmpInformacoesComplementares);
        })
    ).then(
        $A.getCallback((result) => {
          return this.fechar(!apenasCalcular);
        })
    );
  },

  salvar : function(component, event) {
    this.calcular(component, event, false);
  },

  fechar: function(fechar) {
    if(fechar){
      $A.get('e.force:refreshView').fire();
      $A.get("e.force:closeQuickAction").fire();
    }
  },

  //Realiza DML dos dados
  realizarCalculo: function(component) {
    return new Promise(function(resolve, reject) {
      console.log('realizarCalculo');
      let apenasCalcular = component.get('v.alternaFuncao');
      let action = component.get("c.calcularOrcamento");
      let mensagem = '';

      action.setParams({
        oportunidadeId : component.get("v.recordId")
      });

      action.setCallback(this, (response) => {
        let state = response.getState();
        var mensagemErro = response.getReturnValue();

        if(state == "SUCCESS"){
          console.log('Recalculo efetuado');

          if(!mensagemErro){
            mensagem = 'Cálculo efetuado com sucesso!';
            resolve();
          }else{
            let arrMensagem = mensagemErro.split("|");
            mensagem = arrMensagem[0];
            console.log("Erro cálculo: " + arrMensagem[1]);

            if(apenasCalcular)
              reject();
            else
              resolve();
          }

        } else if(state == "ERROR"){
          mensagem = 'Erro ao efetuar cálculo.';
          reject();
        }

        if(apenasCalcular){
          alert(mensagem);
        }
        $A.util.toggleClass(component.find('spinner'), 'slds-hide');

      });

      $A.enqueueAction(action);

    });
  },

  cancelar : function(component, event) {
    $A.get("e.force:closeQuickAction").fire();
  },

  atualizarComponente : function(cmpGarantias, cmpInformacoesComplementares) {
    return new Promise(function(resolve, reject) {
      cmpGarantias.inicializarAbaGarantias();
      cmpInformacoesComplementares.inicializarAbaComplementos();
      resolve();
    });
  },

  contaEhValida: function(component,event){
    // get oportunidade
    let oportunidade = component.get('v.oportunidade');

    /*
    * declaracao de variaveis
    */

    // produto
    let codePME = '37'; // Pequenas e medias empresas
    let codeAPC = '2'; // Acidentes pessoais coloetivo
    let codeCG 	= '3'; // Capital global
    let codeVC 	= '71'; // Vida coletiva
    let codeVI 	= '7'; // Vida individual
    let codeVMS = '10' // Vida mais simples
    let codeVMM = '11' // Vida mais mulher
    let codeAPIP = '12' // Acidentes pessoais individual plus


    let mensagens = '';
    let jahTemErro = false;

    // Produtos do segmentoVI
    if(oportunidade.Produto__r.ProductCode == codePME){
      mensagens = this.verificaCamposObrigatoriosParaPME(oportunidade);
      if(mensagens != '') { mensagens += '\n'; jahTemErro = true;}
      // TODO: Na PLV-952 foi solicitado que removesse o campo de endereço da oportunidade, então removi a validação
      //mensagens += this.verificaCamposObrigatoriosParaPmeNaOportunidade(oportunidade,jahTemErro);
      console.log('Mensagem para exibir');
      console.log(mensagens);

    }else if (oportunidade.Produto__r.ProductCode == codeVI
        || oportunidade.Produto__r.ProductCode == codeVMS
        || oportunidade.Produto__r.ProductCode == codeVMM
        || oportunidade.Produto__r.ProductCode == codeAPIP ) {
      mensagens = this.verificaCamposObrigatoriosDoSegmentoVINaConta(oportunidade);
      if(mensagens != '') { mensagens += '\n'; jahTemErro = true;}
      // TODO: Na PLV-952 foi solicitado que removesse o campo de endereço da oportunidade, então removi a validação
      //mensagens += this.verificaCamposObrigatoriosDoSegmentoVINaOportunidade(oportunidade,jahTemErro);
    }

    // se Acidentes pessoais coloetivo
    // }else if(oportunidade.Produto__r.ProductCode == codeAPC){
    //   listMensagens = this.verificaCamposObrigatoriosParaAPC(oportunidade,listMensagens);
    //
    //   // se Capital global
    // }else if(oportunidade.Produto__r.ProductCode == codeCG){
    //   listMensagens = this.verificaCamposObrigatoriosParaCG(oportunidade,listMensagens);
    //
    //   // se Vida coletiva
    // }else if(oportunidade.Produto__r.ProductCode == codeVC){
    //   listMensagens = this.verificaCamposObrigatoriosParaVC(oportunidade,listMensagens);
    // }

    if(mensagens != '')    {
      // Exibe o toast
      this.showToast(component,event, 'error' , mensagens);
      return false;
    }

    return true;
  },

  verificaCamposObrigatoriosDoSegmentoVINaConta: function(oportunidade){

    let listMensagens = [];
    let conta = oportunidade.Account;
    if(conta == undefined) return;

    if(conta.Name == undefined || conta.Name == '')
      listMensagens.push('Nome');

    if(conta.PersonBirthdate == undefined || conta.PersonBirthdate == '')
      listMensagens.push('Data de Nascimento');

    if(conta.Idade__c == undefined || conta.Idade__c == '')
      listMensagens.push('Idade');

    if(conta.Sexo__c == undefined || conta.Sexo__c == '')
      listMensagens.push('Sexo');

    if(conta.Fumante__c == undefined || conta.Fumante__c == '')
      listMensagens.push('Fumante');

    if(conta.Profissao__c == undefined || conta.Profissao__c == '')
      listMensagens.push('Profissão');

    if(conta.Renda__c == undefined || conta.Renda__c == '')
      listMensagens.push('Renda');

    let mensagem = '';

    if(listMensagens.length > 0)    {
      // concatena a lista de campos em uma String
      listMensagens[0] = 'Por favor preencher o(s) campo(s) obrigatório(s) na Conta: ' + listMensagens[0];
      mensagem = listMensagens.join(', ');
    }

    return mensagem;
  },

  verificaCamposObrigatoriosParaPME: function(oportunidade){

    let listMensagens = [];
    let conta = oportunidade.Account;
    if(conta == undefined) return;
    if(conta.RecordType.DeveloperName == undefined) return;

    if(conta.RecordType.DeveloperName == 'PessoaJuridica'){

      if(conta.Cnpj__c == undefined || conta.Cnpj__c == '')
        listMensagens.push('CNPJ');

      if(conta.RamoAtividade__c == undefined || conta.RamoAtividade__c == '')
        listMensagens.push('Ramo da atividade');


    }else if(conta.RecordType.DeveloperName == 'PessoaFisica') {

      if (conta.Cpf__c == undefined
          || conta.Cpf__c == '') {

        listMensagens.push('CPF');
      }

      if(conta.Name == undefined || conta.Name == '')
        listMensagens.push('Nome');


      if(conta.PersonBirthdate == undefined || conta.PersonBirthdate == '')
        listMensagens.push('Data de Nascimento');

      if(conta.Idade__c == undefined || conta.Idade__c == '')
        listMensagens.push('Idade');

      if(conta.Sexo__c == undefined || conta.Sexo__c == '')
        listMensagens.push('Sexo');

      if(conta.Fumante__c == undefined || conta.Fumante__c == '')
        listMensagens.push('Fumante');

      if(conta.Renda__c == undefined || conta.Renda__c == '')
        listMensagens.push('Renda');
    }



    let mensagem = '';

    if(listMensagens.length > 0)    {
      // concatena a lista de campos em uma String
      listMensagens[0] = 'Por favor preencher o(s) campo(s) obrigatório(s) na Conta: ' + listMensagens[0];
      mensagem = listMensagens.join(', ');
    }

    return mensagem;
  },

  verificaCamposObrigatoriosDoSegmentoVINaOportunidade :function(oportunidade, jahTemErro){

    let listMensagens = [];

    let endereco = oportunidade.Endereco__r;

    if(endereco == undefined) listMensagens.push('Cadastre um endereço residencial');

    else {

      if(endereco.TipoEndereco__c == undefined
          || endereco.TipoEndereco__c == ''
          || endereco.TipoEndereco__c != 'Residencial') listMensagens.push('Cadastre um endereço residencial');

      if(endereco.CEP__c == undefined || endereco.CEP__c == '') listMensagens.push('CEP');

    }

    let mensagem = '';

    if(listMensagens.length > 0)    {
      // concatena a lista de campos em uma String
      if(jahTemErro){
        listMensagens[0] = 'e no Orcamento: ' + listMensagens[0];
      }else {
        listMensagens[0] = 'Por favor preencher o(s) campo(s) obrigatório(s) no Orcamento: ' + listMensagens[0];
      }
      mensagem = listMensagens.join(', ');
    }

    return mensagem;
  },

  verificaCamposObrigatoriosParaPmeNaOportunidade :function(oportunidade, jahTemErro){

    let listMensagens = [];

    let endereco = oportunidade.Endereco__r;

    if(endereco == undefined) {
      listMensagens.push('Cadastre um endereço residencial');
    }else {

      if(endereco.TipoEndereco__c == undefined
          || endereco.TipoEndereco__c == ''
          || endereco.TipoEndereco__c != 'Residencial') listMensagens.push('Cadastre um endereço residencial');

      if(endereco.CEP__c == undefined || endereco.CEP__c == '') listMensagens.push('CEP');

    }

    console.log('Tipo de calculo');
    console.log(oportunidade.TipoCalculo__c);

    console.log('Multiplo Salarial');
    console.log(oportunidade.MultiploSalarial__c);

    if(oportunidade.TipoCalculo__c == 'Múltiplo' && oportunidade.MultiploSalarial__c == ''){
      listMensagens.push('Múltiplo Salarial');
    }

    let mensagem = '';

    if(listMensagens.length > 0)    {
      // concatena a lista de campos em uma String
      if(jahTemErro){
        listMensagens[0] = 'e no Orcamento: ' + listMensagens[0];
      }else {
        listMensagens[0] = 'Por favor preencher o(s) campo(s) obrigatório(s) no Orcamento: ' + listMensagens[0];
      }
      mensagem = listMensagens.join(', ');
    }

    return mensagem;
  },

  verificaCamposObrigatoriosParaAPC : function(oportunidade, listMensagens){
    return listMensagens;
  },

  verificaCamposObrigatoriosParaCG : function(oportunidade, listMensagens){
    return listMensagens;
  },

  verificaCamposObrigatoriosParaVC : function(oportunidade, listMensagens){
    return listMensagens;
  },

  showToast : function(component, event, type, mensagens){
    component.set('v.type',type);
    component.set('v.bodyToast',mensagens);
    let toast = component.find('ToastParaModal');
    if(toast != undefined) toast.showToast();
  },

  hiddenToast : function(component, event,  type, mensagens){
    component.set('v.type',type);
    component.set('v.bodyToast',mensagens);
    let toast = component.find('ToastParaModal');
    if(toast != undefined) toast.hiddenToast();
  }

})