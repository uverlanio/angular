/**
 * Created by Alessndro Ponte on 11/07/2018.
 */
({
  doInitHelper : function(component,event){
    Promise.all([
      this.buscarRemuneracaoOrcamento(component,event),
      this.buscarRemuneracaoProposta(component,event)
    ]).then((values) => this.mergeRemuneracoes(component,event,...values));
  },

  showToast : function(component, event,type,mensagem){
    component.set('v.type',type);
    component.set('v.bodyToast',mensagem);
    let toast = component.find('ToastParaModal');
    if(toast != undefined) toast.showToast();
  },

  buscarRemuneracaoProposta : function (component, event) {
    return new Promise((resolve,reject)=> {
      let recordId = component.get('v.recordId');

      var action = component.get("c.buscarRemuneracaoProposta");
      action.setParams({quoteId: recordId});
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log(state);
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        }
        else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " +
                  errors[0].message);
            }
            reject();
          } else {
            console.log("Unknown error");
            reject();
          }
        }
      });
      $A.enqueueAction(action);
    });
  },

  buscarRemuneracaoOrcamento : function(component, event){
    return new Promise((resolve,reject)=>{

      let recordId = component.get('v.recordId');

      var action = component.get("c.buscarRemuneracaoOrcamentoNoOrcamento");
      action.setParams({ quoteId : recordId});
      action.setCallback(this, function(response) {
        var state = response.getState();
        console.log(state);
        if (state === "SUCCESS") {
          resolve(response.getReturnValue());
        }
        else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " +
                  errors[0].message);
            }
            reject();
          } else {
            console.log("Unknown error");
            reject();
          }
        }
      });
      $A.enqueueAction(action);
    });
  },

  mergeRemuneracoes : function(component,event,listOrcamento,listRemuneracaoProposta){

    // Declara variaveis
    let mapListRemuneracoesPropostaPorTipoRemuneracao = new Map();
    let mapRemuneracaoOrcamentoPorTipoRemuneracao = new Map();
    let listWrapper = [];

    if (listOrcamento.length == 0) return;

    // Itera sobre a lista de orcamento para recuperar os tipos de remuneracao
    listOrcamento.forEach((orcamento) =>{
      let listRemuneracoesOrcamento = orcamento.RemuneracoesOrcamento__r;
      if(listRemuneracoesOrcamento == undefined) return;

      listRemuneracoesOrcamento.forEach((remuneracaoOrcamento) => {
        mapRemuneracaoOrcamentoPorTipoRemuneracao.set(remuneracaoOrcamento.TipoRemuneracao__r.Name, remuneracaoOrcamento);
      });
    });

    // Itera sobre a lista de Remuneracao da Proposta
    if(listRemuneracaoProposta.length > 0){
      listRemuneracaoProposta.forEach((remuneracaoProposta) => {
        let listRemuneracaoProposta2 = mapListRemuneracoesPropostaPorTipoRemuneracao.get(remuneracaoProposta.TipoRemuneracao__r.Name);
        if(listRemuneracaoProposta2 == undefined) listRemuneracaoProposta2 = [];
        listRemuneracaoProposta2.push(remuneracaoProposta);
        mapListRemuneracoesPropostaPorTipoRemuneracao.set(remuneracaoProposta.TipoRemuneracao__r.Name,listRemuneracaoProposta2);
      });
    }

    // Merge da Remuneracao do Orcamento na Remuneracao da Proposta
    mapRemuneracaoOrcamentoPorTipoRemuneracao.forEach((remuneracaoOrcamento,tipoRemuneracao,map) =>{

      let listRemuneracaoProposta3 = mapListRemuneracoesPropostaPorTipoRemuneracao.get(tipoRemuneracao);

      // Verifica se existe uma Remuneracao da proposta para esse tipo de remuneracao
      if(listRemuneracaoProposta3 == undefined) {
        listRemuneracaoProposta3 = [];
        listRemuneracaoProposta3.push(this.criarRemuneracaoProposta(component, event, remuneracaoOrcamento));
      }

      // Insere objeto de controle
      listRemuneracaoProposta3.forEach((remuneracaoProposta) => {
        if(remuneracaoProposta.controle == undefined) remuneracaoProposta.controle = this.criarControle();
        this.criarOpcoesPapel(component,event,remuneracaoProposta);
      });

      // Cria um Wrapper para juntar a lista de Remuneracao da proposta, o Percentual e o tipo da remuneracao
      listWrapper.push(this.criarWrapper(tipoRemuneracao, remuneracaoOrcamento, listRemuneracaoProposta3));

      component.set('v.listWrapper',listWrapper);
    });

    let spinner = component.find('spinner');
    $A.util.addClass(spinner, 'slds-hide');
  },

  criarWrapper : function(tipoRemuneracao, remuneracaoOrcamento, listRemuneracaoProposta){
    return {
      'tipoRemuneracao' : tipoRemuneracao,
      'percentual' : remuneracaoOrcamento.Percentual__c,
      'percentualTotal' : listRemuneracaoProposta.reduce((acumulador,valorAtual)=>{
        if(Number.isNaN(valorAtual.Participacao__c) || valorAtual.Participacao__c == undefined) return acumulador;
        return acumulador + parseFloat(valorAtual.Participacao__c);
      },0.0),
      'listRemuneracaoProposta' : listRemuneracaoProposta,
      'TipoRemuneracao__c' : remuneracaoOrcamento.TipoRemuneracao__c,
      'TipoRemuneracao__r' : {
        'Name' : remuneracaoOrcamento.TipoRemuneracao__r.Name
      },
      'temErro' : false
    };
  },

  criarRemuneracaoProposta : function (component, event, remuneracao){
    return {
      'sobjectType':'RemuneracaoProposta__c',
      'Lider__c': false,
      'Proposta__c': component.get('v.recordId'),
      'TipoRemuneracao__c': remuneracao.TipoRemuneracao__c,
      'Percentual__c' : remuneracao.Percentual__c,
      'TipoRemuneracao__r' : {
        'Id' : remuneracao.TipoRemuneracao__c,
        'Name' : remuneracao.TipoRemuneracao__r.Name
      },
      'controle' : this.criarControle()
    };
  },

  criarControle : function(){
    return {'temErro': false};
  },

  criarOpcoesPapel : function (component,event,remuneracaoProposta) {

    if(remuneracaoProposta.Conta__r == undefined){ return; }

    remuneracaoProposta.Conta__c = remuneracaoProposta.Conta__r.Id;
    let papeis = remuneracaoProposta.Conta__r.Papel__c;
    if(papeis == undefined) return;

    let listPapel = papeis.split(';');

    remuneracaoProposta.controle.opcoesPapel = listPapel.map((element) => {
      return {
        'label': element,
        'value': element
      };
    });
  },

  salvarRemuneracoes : function (component, event) {
    let listRemuneracaoProposta = [];

    let listWrapper = component.get('v.listWrapper');
    let listaRemuneracaoPropostaParaApagar = component.get('v.listRemuneracoesParaApagar');

    listWrapper = this.calcularTotal(listWrapper);

    let remuneracoesSaoValidas = this.remuneracoesSaoValidas(component,event,listWrapper);
    if(!remuneracoesSaoValidas){
      // TODO: Scroll no modal para o topo
      return;
    }

    // Pega somente as remuneracoes preenchidas e deleta os dados de controle
    listWrapper.forEach((wrapper) => {
      let lstRP = wrapper.listRemuneracaoProposta;
      if(lstRP == undefined) return;
      lstRP.forEach((remuneracaoTemp) => {
        if(this.estaPreenchido(remuneracaoTemp)){
          let remuneracao = Object.assign({},remuneracaoTemp);
          // converte o valor da porcentagem
          remuneracao.Participacao__c = parseFloat(remuneracao.Participacao__c);
          delete remuneracao.controle;
          listRemuneracaoProposta.push(remuneracao);
        }
      });
    });

    // Verifica se tem remuneracao para atualizar/criar/deletar
    if(listRemuneracaoProposta.length == 0 && listaRemuneracaoPropostaParaApagar.length == 0) return;

    let spinner = component.find('spinner');
    $A.util.removeClass(spinner, 'slds-hide');


    var action = component.get("c.salvarRemuneracaoProposta");
    action.setParams({
      listRemuneracaoProposta : listRemuneracaoProposta,
      listaRemuneracaoPropostaParaApagar : listaRemuneracaoPropostaParaApagar
    });
    action.setCallback(this, function(response) {
      $A.util.addClass(spinner, 'slds-hide');
      var state = response.getState();
      console.log(state);
      if (state === "SUCCESS") {
        let mensagem = response.getReturnValue();
        if(mensagem != ''){
          console.log(mensagem);
        }else {
          this.doInitHelper(component, event);
          this.showToast(component, event, 'success', 'Salvo com sucesso!');
        }
      }
      else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " +
                errors[0].message);
          }
          this.showToast(component, event,'error','Erro! Por favor tente novamente.');
        } else {
          console.log("Unknown error");
          this.showToast(component, event,'error','Erro! Por favor tente novamente.');
        }
      }
    });
    $A.enqueueAction(action);

  },

  calcularTotal : function(listWrapper){

    if(listWrapper == undefined) return listWrapper;

    listWrapper.forEach((wrapper) => {

      wrapper.percentualTotal = wrapper.listRemuneracaoProposta.reduce((acumulador,valorAtual)=>{
      if(Number.isNaN(valorAtual.Participacao__c) || valorAtual.Participacao__c == undefined) return acumulador;
      return acumulador + parseFloat(valorAtual.Participacao__c);
    },0.0);

    });

    return listWrapper;

  },

  remuneracoesSaoValidas : function(component,event,listWrapper){
    component.set('v.mensagemErro', '');

    let temErroNaValidacao = false;

    // Pega as remuneracoes do Wrapper
    listWrapper.some((wrapper) => {

      wrapper.temErro = false;

      let lstRP = wrapper.listRemuneracaoProposta;
      if(lstRP == undefined) return;

      let jaExisteLider = false;
      let haTipoRemuneracaoCorretagem = false;
      let haRemuneracaoPropostaParaValidar = false;

      lstRP.some((remuneracaoProposta) => {

        if(remuneracaoProposta.TipoRemuneracao__c == undefined) return false;

        remuneracaoProposta.controle.temErro = false;

        // Verifica se eh uma remuneracao da proposta preenchida
        if(!this.estaPreenchido(remuneracaoProposta))
          return false;

        haRemuneracaoPropostaParaValidar = true;

        let tipoRemuneracao = remuneracaoProposta.TipoRemuneracao__r.Name.toLowerCase();
        let papel;
        if(remuneracaoProposta.Papel__c != undefined)
        papel = remuneracaoProposta.Papel__c.toLowerCase();

        // Verifica se eh uma remunercao preenchida com o tipo de remuneracao corretagem
        if(tipoRemuneracao == 'corretagem')
          haTipoRemuneracaoCorretagem = true;

        // Verifica se o líder é um corretor
        if(remuneracaoProposta.Lider__c == true && remuneracaoProposta.papel != 'corretor' && remuneracaoProposta.papel != undefined) {
          remuneracaoProposta.controle.temErro = true;
          temErroNaValidacao = true;
          component.set('v.mensagemErro', 'Somente um corretor pode ser líder');
          return true;
        }

        // Valida se existe um corretor lider para o Tipo de remuneração CORRETAGEM
        if(tipoRemuneracao == 'corretagem' && remuneracaoProposta.Lider__c == true && jaExisteLider) {
          remuneracaoProposta.controle.temErro = true;
          temErroNaValidacao = true;
          component.set('v.mensagemErro', 'Já existe um líder para essa remuneração');
          return true;
        }

        // informa se eh lider
        if(remuneracaoProposta.Lider__c == true) jaExisteLider = true;
      });

      // Verifica se tem alguma Remuneracao da proposta com o tipo de remuneracao Corretagem, sem um lider
      if(!jaExisteLider && haTipoRemuneracaoCorretagem){
        component.set('v.mensagemErro', 'Corretor líder não informado');
        temErroNaValidacao = true;
        wrapper.temErro = true;
        return true;
      }

      // Verifica se a participacao eh de 100% por tipo de remuneração
      if(wrapper.percentualTotal != 100 && haRemuneracaoPropostaParaValidar){
        component.set('v.mensagemErro', 'Percentual de participação dos favorecidos deve ser 100%.');
        temErroNaValidacao = true;
        wrapper.temErro = true;
        return true;
      }

    });

    if(temErroNaValidacao) return false;
    return true;

  },

  estaPreenchido : function(remuneracaoTemp){

    if(remuneracaoTemp.Conta__c != undefined && remuneracaoTemp.Conta__c != null && remuneracaoTemp.Conta__c != ''
        && remuneracaoTemp.Papel__c != undefined && remuneracaoTemp.Papel__c != null && remuneracaoTemp.Papel__c != ''
        && remuneracaoTemp.Participacao__c != undefined && remuneracaoTemp.Participacao__c != null && remuneracaoTemp.Participacao__c != '')
      return true;

    return false;

  }
})