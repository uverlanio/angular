/**
 * Created by Isabela Fin on 30/10/2020.
 */
({
	popularTabelaCriticas : function(component) {
        //console.log('populaCriticas')
		component.set('v.colunasCriticas', [
            {label: 'Nº crítica', fieldName: 'Name', type: 'text', initialWidth: 150},
            {label: 'Área', fieldName: 'Area__c', type: 'text', initialWidth: 150},
            {label: 'Momento de análise', fieldName: 'MomentoAnalise__c', type: 'text', initialWidth: 150},
            {label: 'Parecer', fieldName: 'MensagemCliente__c', type: 'text'},
		]);
		
		var action = component.get("c.popularTabelaCriticas");
		action.setParams({ propostaId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status <> 0' + state);
            console.log('Status <> 0 ' + component.get("v.recordId"));
            console.log('response.getReturnValue() <> popularTabelaCriticas ' + response.getReturnValue());
            if (state === "SUCCESS") {
				var criticas = response.getReturnValue();
				//console.log(JSON.stringify(criticas));
                component.set("v.dadosCriticas", criticas);
            }
        });
        $A.enqueueAction(action);
    },
    
    carregaDadosProposta : function(component) {
        var action = component.get("c.carregarDadosProposta");
        action.setParams({ propostaId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var teste = response.getReturnValue();
            console.log('carregaDadosProposta stacktrace <>' + teste.stacktrace);
            console.log('Status carregaDadosProposta <>' + state);
            console.log('carregaDadosProposta stacktrace <>' + teste.stacktrace);
            console.log('carregaDadosProposta mensagem <>' + teste.mensagem);
            console.log('carregaDadosProposta sucesso <>' + teste.sucesso);
            console.log('carregaDadosProposta propostaId <>' + teste.propostaId);
            console.log('carregaDadosProposta cotacao <>' + teste.cotacao);
            console.log('carregaDadosProposta original <>' + teste.original);
            console.log('carregaDadosProposta modificada <>' + teste.modificada);
            console.log('carregaDadosProposta ctr <>' + teste.ctr);
            
            if(state === "SUCCESS") {
                var proposta = response.getReturnValue();
                //console.log(JSON.stringify(proposta.original));
                component.set("v.propostaOriginal", proposta.original);
                component.set("v.propostaModificada", proposta.modificada); //Teste
                component.set("v.propostaTipo", {}); //Teste
                if (proposta.canEdit==true) {
                    let garantiaDesconto = {}
                    let garantiasPrincipais = []
                    for (let i in proposta.original.garantias) {
                        let item = proposta.original.garantias[i]
                        garantiaDesconto[item.cobertura] = item.tipoDescontoAgravo
                        if (item.caracteristica == 'Principal')
                            garantiasPrincipais.push(item.cobertura)
                    }
                    component.set("v.garantiaDesconto", garantiaDesconto);
                    component.set("v.garantiasPrincipais", garantiasPrincipais);
                    component.set("v.isDadosCriticasValida", false);//II-166 - INICIO
                 
                    var elemento = document.querySelector('.cardAlterarFormaPagto');
                    elemento.style.marginTop = '';
                    //II-166 - FIM
                } else {
                    component.set("v.errorInit", proposta.mensagem);
                    component.set("v.isDadosCriticasValida", true);//II-166 - INICIO/FIM
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    //Debugs Rogerio e Henrique FIX01 - INICIO
    recalcular : function(component) {
        console.log("entrou na função recalcular <> ");
        //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        let keysToStrip = ['premioTotal', 'descontoAgravo', 'capital', 'premioAtual', 'descontoAgravo', 'limiteCapitalMinimo', 'limiteCapitalMaximo', 'percentualCapitalMinimo', 'percentualCapitalMaximo', 'percentualAgravoMaximo', 'percentualAgravoMinimo', 'percentualDescontoMinimo', 'percentualDescontoMaximo','percentual']//PLV-4851 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        let request = {}
        request.originalO = Object.assign(component.get("v.propostaOriginal"), {})
        request.modificadaO = Object.assign(component.get("v.propostaModificada"),{})
        request.original = this.replaceObject(component.get("v.propostaOriginal"), keysToStrip)
        request.modificada = this.replaceObject(component.get("v.propostaModificada"), keysToStrip)
        request.original.remuneracoes = request.originalO.remuneracoes;
        
        let item = {}
        for(let x in request.original.remuneracoes){
            if(request.original.remuneracoes[x].opcoes){
                item[request.original.remuneracoes[x].tipoRemuneracao] = request.original.remuneracoes[x];
            }
        }
        for(let x in request.modificada.remuneracoes){
            if(item[request.modificada.remuneracoes[x].tipoRemuneracao]){
                request.modificada.remuneracoes[x].opcoes = item[request.modificada.remuneracoes[x].tipoRemuneracao].opcoes;
            }
        }
        //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
        console.log('está chegando até aqui? <> ');
        //II-175 INICO
        let descontoAgravo;
        let alteracaoFormPag = component.get("v.alteracaoFormPag");
        if(alteracaoFormPag){
            descontoAgravo = component.get("v.descontoAgravo");
        }
        console.log('alteracaoFormPag <> ' + alteracaoFormPag);
        console.log('descontoAgravo <> ' + descontoAgravo);

        console.log('JSON.stringify(request) <> ' + JSON.stringify(request));
        //Debugs Rogerio e Henrique FIX01 - FIM
        var action = component.get('c.calcular')
        action.setParams({
            'requisicao': JSON.stringify(request),
            alteracaoFormPag : alteracaoFormPag,
            descontoAgravo : descontoAgravo
        });        
        //II-175 FIM
        action.setBackground(true)
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state <<<' + state);
            if (component.isValid() && state === "SUCCESS") {
                var retorno = response.getReturnValue()
                //console.log("retorno ", retorno)
                if (retorno.sucesso == true) {
                    let propostaModificada = component.get("v.propostaModificada");
                    let contratadas = []
                    for (let i in propostaModificada.garantias) {
                        if (propostaModificada.garantias[i].contratado == true)
                            contratadas.push(propostaModificada.garantias[i].cobertura)
                    }
                    
                    retorno.recalculada.garantias = retorno.recalculada.garantias.filter(e => { return contratadas.includes(e.cobertura)})
                    component.set('v.propostaRecalculada',retorno.recalculada)
                    component.set('v.jsonResponseRecalculo',retorno.jsonResponseRecalculo)
                    //II-206 FIX02 - INICIO
                    if(alteracaoFormPag){
                        component.set('v.etapaTela2', 2);
                        component.set('v.etapa', 1);
                    }else{
                        component.set('v.etapa', 2);
                        component.set('v.etapaTela2', 1);
                    }
                    //II-206 FIX02 - FIM
                    component.set('v.jsonModificada',retorno.jsonModificada) // II-54 INICIO/FIM
                }
                else {
                    this.showToastMessage(retorno.mensagem, "error", "pester")
                }
            } else {
                this.showToastMessage("Erro ao executar recálculo.", "error", "pester")
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action)
    },

    salvar : function(component){
        //PLV-4851 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        let keysToStrip = ['premioTotal', 'descontoAgravo', 'capital', 'premioAtual', 'descontoAgravo', 'limiteCapitalMinimo', 'limiteCapitalMaximo', 'percentualCapitalMinimo', 'percentualCapitalMaximo', 'percentualAgravoMaximo', 'percentualAgravoMinimo', 'percentualDescontoMinimo', 'percentualDescontoMaximo','percentual']
        let request = {}
        request.originalO = Object.assign(component.get("v.propostaOriginal"), {})
        request.modificadaO = Object.assign(component.get("v.propostaModificada"),{})
        request.original = this.replaceObject(component.get("v.propostaOriginal"), keysToStrip)
        request.modificada = this.replaceObject(component.get("v.propostaModificada"), keysToStrip)
        request.original.remuneracoes = request.originalO.remuneracoes // II-54 INICIO/FIM
        request.jsonResponseRecalculo = JSON.parse(component.get("v.jsonResponseRecalculo")) // II-54 INICIO/FIM
        request.jsonModificada =JSON.parse(component.get("v.jsonModificada")) // II-54 INICIO/FIM
        //IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! 
        
        
        //LEMBRAR DE DEIXAR ESSA FUNÇÃO COMO FUTURA PARA A GRAVAÇÃO DOS OBJETOS RETORNANDO SUCESSO QUANDO ELA FOR INICIADA.
        //MOTIVO: VISIBILIDADE DE CAMPOS E PERMISSÃO DOS USUÁRIOS NA EDIÇÃO DOS CAMPOS NECESSÁRIOS.
        
        
        //IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! IMPORTANTE!!!!! 

        let item = {}
        for(let x in request.original.remuneracoes){
            if(request.original.remuneracoes[x].opcoes){
                item[request.original.remuneracoes[x].tipoRemuneracao] = request.original.remuneracoes[x];
            }
        }
        for(let x in request.modificada.remuneracoes){
            if(item[request.modificada.remuneracoes[x].tipoRemuneracao]){
                request.modificada.remuneracoes[x].opcoes = item[request.modificada.remuneracoes[x].tipoRemuneracao].opcoes;
            }
        }
        //PLV-4851 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //II-175 INICO
        let altFormPag = component.get("v.alteracaoFormPag");
        console.log("alteracaoFormPag salvar " + altFormPag)
        var action = component.get('c.gravarCalculo')
        action.setParams({
            'requisicao': JSON.stringify(request),
            altFormPag : altFormPag
        });
        //II-175 FIM
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var retorno = response.getReturnValue()
                //console.log("retorno ", retorno)
                //FNPVVEP-126 INICIO
                let isRecalculoOut = component.get("v.isRecalculoOut");
                if (retorno.sucesso == true) {
                    component.set("v.showSpinner", false);
                    //FNPVVEP-147 INICIO
                    component.set("v.showConfirmRecalculo", true);
                    // if (isRecalculoOut) {
                    //     alert("Olá, (nome do cliente)!\n\nA alteração da forma de pagamento do seu Seguro de Vida da Porto foi realizada com sucesso!\n\nTodo cuidado é Porto.");
                    // }else{
                    //     this.showToastMessage("Olá, (nome do cliente)!\n\nA alteração da forma de pagamento do seu Seguro de Vida da Porto foi realizada com sucesso!\n\nTodo cuidado é Porto.", "success", "sticky") //II-206 - INICIO/FIM
                    // }
                    //FNPVVEP-147 FIM
                    /*component.set("v.saveMessage", '<h2 class="slds-text-title_bold">O processo de atualização foi iniciado! Ao final do processo:<h2><br/>• A Crítica de Recalculo da Proposta deverá ser Liberada;<br/>• Será criado um novo PDF da proposta;<br/>• Será criada Critica da proposta DOCUSIGN;<br/>• Itens vinculados ao registro poderão ser apagados;<br/>• O Contratante receberá o e-mail em algumas horas para aceitar a Proposta.<br/>');
                    setTimeout(function(){
                        $A.get("e.force:closeQuickAction").fire(); //not working
                        $A.get('e.force:refreshView').fire();
                    },2000);*/
                }
                else {
                    if (isRecalculoOut) {
                        alert(retorno.mensagem);
                    }else{
                        this.showToastMessage(retorno.mensagem, "error", "pester")
                    }
                }
                //FNPVVEP-126 FIM
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message)
                this.showToastMessage("Erro ao executar recálculo: "+ errors[0].message, "error", "pester")
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action)
    },

    /*FUNÇÕES AUXILIARES*/

    showToastMessage: function (message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": type,
            "mode": mode,
            "duration": $A.get('$Label.c.ToastDefaultDuration')
        });

        toastEvent.fire();
    },


    stripNum: function (valor) {
        console.log('valor entrada',valor)
        valor = valor!=null && valor!==undefined ? valor.toString().replace('%','').replace('$','').replace(',', '.').replace(/[^\d.,-]/g, '').replace(/(.*)\./, x => x.replace(/\./g, '') + '.').trim(): null;
        console.log('valor saida',valor)
        return valor
    },
    replaceObject: function (obj, keysToStrip) {
        let ObjToReturn = {}
        Object.entries(obj).forEach(([key, value]) => {
            //console.log(key + ' ' + value,typeof obj[key],Array.isArray(value));
            if (typeof obj[key] === 'object' && value != null) {
                if (!Array.isArray(value)) {
                    ObjToReturn[key] = this.replaceObject(obj[key], keysToStrip)
                } else {
                    ObjToReturn[key] = []
                    for (let ent in obj[key]) {
                        let parsed = obj[key][ent]
                        if (!Array.isArray(parsed) && typeof parsed !== 'string')
                            ObjToReturn[key].push(this.replaceObject(parsed, keysToStrip))
                        else
                            ObjToReturn[key].push(keysToStrip.includes(key) ? stripNum(parsed) : parsed)
                    }
                }

            } else {
                if (keysToStrip.includes(key) && value != null) ObjToReturn[key] = this.stripNum(value)
                else ObjToReturn[key] = value
            }
        });
        return ObjToReturn;
    },
    //II-166 - INICIO
    dadosFormaPagamento : function(component) {
        var action = component.get("c.dadosFormaPagamento");

        action.setParams({ propostaId : component.get("v.recordId") });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status' + state);
            console.log('response.getReturnValue() >< ' + response.getReturnValue());
            if(state === "SUCCESS") {
                var formaPagamento = response.getReturnValue();
                component.set("v.proposta", formaPagamento.proposta);
                component.set("v.cliente", formaPagamento.cliente); //FNPVVEP-147 INICIO/FIM
                component.set("v.produto", formaPagamento.produto); //FNPVVEP-147 INICIO/FIM
                component.set("v.formaPagamentoAtual", formaPagamento.formaPagamentoAtual);
                component.set("v.codFormPag", formaPagamento.codFormPag); //II-174 - INICIO/FIM
                console.log('formaPagamentoAtual' + formaPagamento.formaPagamentoAtual);
                console.log('formaPagamento.codFormPag' + formaPagamento.codFormPag);

                var valPremAt = parseFloat(formaPagamento.valorPremioAtual);                
                valPremAt = valPremAt.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }).replace('R$','');
                
                component.set("v.valorPremioAtual", valPremAt.trim());
                component.set("v.produtoId", formaPagamento.produtoId);
                
                var opcoesMelDtPgto = [];

                //II-174 - INICIO
                console.log('component.get("v.codFormPag") <> ' + component.get("v.codFormPag"));
                console.log('formaPagamento.vencimentoDemaisParcelas <> ' + formaPagamento.vencimentoDemaisParcelas);
                
                if (formaPagamento.vencimentoDemaisParcelas !== "A cada 30 dias" && (component.get("v.codFormPag") == '41' || component.get("v.codFormPag") == '52')) {
                    console.log('entrou no if rog <> <> ');
                    opcoesMelDtPgto.push({ label: formaPagamento.vencimentoDemaisParcelas, value: formaPagamento.vencimentoDemaisParcelas }); //II-206 - INICIO/FIM
                }
                opcoesMelDtPgto.push({ label: "A cada 30 dias", value: "A cada 30 dias" }); //II-206 - INICIO/FIM

                for (var i = 1; i <= 30; i++) {
                    if (i.toString() !== formaPagamento.vencimentoDemaisParcelas && i !== 0) {
                        opcoesMelDtPgto.push({ label: i.toString(), value: i.toString() });
                    }
                }
                component.set("v.opcoesMelDtPgto", opcoesMelDtPgto);
                //II-174 - FIM
            }
            //II-206 FIX01 - INICIO
            setTimeout(function() {
                var selectElement = document.getElementById("selectOpcoesParcelas");
                var option = document.createElement("option");
                option.value = formaPagamento.quantidadeParcelas;
                option.text = formaPagamento.quantidadeParcelas;
                selectElement.appendChild(option);
                component.set("v.quantidadeParcelasContratante", formaPagamento.quantidadeParcelas);
            }, 100);
            //II-206 FIX01 - FIM
            console.log('quantidadeParcelasContratante' +  component.get("v.quantidadeParcelasContratante"));

        });
        $A.enqueueAction(action);
    },
    removerOpEmp14: function(component){

        var action = component.get('c.verificarCodEmpresa');
        let isRecorrente = ''; //FNPVVEP-147 INICIO/FIM
        let codEmp = '';
        
        action.setParams({
            proposta : component.get("v.proposta"),
           });
           action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
               var retorno = response.getReturnValue();
                codEmp = retorno.codigoEmpresa;
                isRecorrente = retorno.produtoRecorrente; //FNPVVEP-147 INICIO/FIM

                component.set("v.codigoEmpresa", codEmp);//FNPVVEP-146 INICIO/FIM

                var selectElement = document.getElementById("novaFormaPagamento");
                    if(isRecorrente == 'true'){ //FNPVVEP-147 INICIO/FIM
                        var optionsToRemove = selectElement.querySelectorAll('option[value="62"], option[value="97"]');

                        optionsToRemove.forEach(function(option) {
                            option.remove();
                        });
                    }else{
                        var optionsToRemove = selectElement.querySelectorAll('option[value="70"], option[value="98"]');

                        optionsToRemove.forEach(function(option) {
                            option.remove();
                        });
                    }               
            }
        });
        $A.enqueueAction(action);        
    },
    qtdeParcelas: function(component) {

        //II-206 FIX01 - INICIO
        var ajusteParcelas = component.get('v.ajusteParcelas');
        if(ajusteParcelas){
            var opcaoParcela = component.get('v.quantidadeParcelasContratante');
            var selectElement = document.getElementById("selectOpcoesParcelas");
            var optionToRemove = selectElement.querySelector("option[value='" + opcaoParcela + "']");
            if (optionToRemove) {
                selectElement.removeChild(optionToRemove);
            }
        }
        //II-206 FIX01 - FIM
        var action = component.get("c.qtdeParcelas");
        action.setParams({
             proposta : component.get("v.proposta"),
             produtoId : component.get("v.produtoId") 
            });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                try{
                    component.set('v.ajusteParcelas', false); //II-206 FIX01 - INICIO/FIM
                    console.log('component.get("v.produtoId") ' + component.get("v.produtoId"));
                    var mapaRetorno = response.getReturnValue();
                    var mapParcelas = new Map(Object.entries(mapaRetorno));

                    var selectElement = document.getElementById("novaFormaPagamento");
                    var codigo = selectElement.value.toString();
                    //II-174 - INICIO
                    if(codigo != null && codigo != ''){
                        component.set("v.alteracaoFormPag", true); //II-175 INICO/FIM
                        component.set("v.codigoPagamento", codigo); //II-206 - INICIO/FIM
                        if(component.get("v.codFormPag") == '41' || component.get("v.codFormPag") == '52'){
                            component.set("v.showFormPgtoBoleto", (codigo == '41') ? true : false);
                            component.set("v.showFormPgtoADC", (codigo == '52') ? true : false);
                            component.set("v.showFormPgtoCartao", (codigo == '62' || codigo == '97' || codigo == '70' || codigo == '98') ? true : false);
                            // component.set("v.showFormPgtoCartao", false); //II-176 INICIO/FIM
                            if(codigo == '41' || codigo == '52'){
                                component.set("v.showMelhorDtPgto", true);
                                component.set("v.selectDisable", false);
                            }else if(codigo != '41' && codigo != '52'){
                                component.set("v.showMelhorDtPgto", true);
                                component.set("v.selectDisable", true);
                            }
                        }else if(component.get("v.codFormPag") == '62' || component.get("v.codFormPag") == '97' || component.get("v.codFormPag") == '70' || component.get("v.codFormPag") == '98'){
                            component.set("v.showFormPgtoBoleto", (codigo == '41') ? true : false);
                            component.set("v.showFormPgtoADC", (codigo == '52') ? true : false);
                            component.set("v.showFormPgtoCartao", (codigo == '62' || codigo == '97' || codigo == '70' || codigo == '98') ? true : false);
                            if(codigo == '41' || codigo == '52'){
                                console.log('entrou if cartão <> ');
                                component.set("v.showMelhorDtPgto", true);
                                component.set("v.selectDisable", false);
                            }else if(codigo != '41' && codigo != '52'){
                                console.log('entrou else cartão <> ');
                                component.set("v.showMelhorDtPgto", true);
                                component.set("v.selectDisable", true);
                            }
                        }
                        //II-174 FIM
                        var numeroParcelas = [];

                        numeroParcelas = mapParcelas.get(codigo);
                        console.log('codigo <>^^ ' + codigo);
                        console.log('numeroParcelas <> ' + numeroParcelas);
                        console.log('mapParcelas <> ' + mapParcelas);
                        console.log('RemuneracaoProposta__c >< ' + mapParcelas.get('RemuneracaoProposta__c >< '));
                        console.log('CondicaoCobranca__c >< ' + mapParcelas.get('CondicaoCobranca__c >< '));
                        console.log('stacktrace <>^^ ' + mapParcelas.get('stacktrace'));
                        //mapCodParc.put('RemuneracaoProposta__c >< ', rp[0].Id);
                        //mapCodParc.put('CondicaoCobranca__c >< ', condCobList[0].Id);

                        if(numeroParcelas != null){
                            var parcelasString = '[\'' + numeroParcelas.replaceAll(';','\',\'') + '\']';
                            var prepararSplit = parcelasString.replace(/\[|\]/g, '').replaceAll('\'','');
                            var parcelas = prepararSplit.split(",");
                            var opcoesParcelas = parcelas;
                            console.log('opcoesParcelas <> ' + opcoesParcelas);
                            component.set("v.opcoesParcelas", opcoesParcelas);  
                                            
                        }
                    }else{
                        component.set("v.selectDisable", false);
                    }
                    //II-174 - FIM
                    //II-175 INICO
                    var self = this; 
                    setTimeout(function() {
                    self.ocultarFrase(component);
                    }, 1);
                    //II-175 FIM
            }catch(e){
                throw new Error(e.message);
            }
        }
        });
        $A.enqueueAction(action);
    },
    verificarValCartCred: function() {
        var dataValidade = document.getElementById("dataVencimento").value;
        var mensagemErro = document.getElementById("mensagemErroValCartCred");
        
        if (!dataValidade || dataValidade.trim() === '') {
            mensagemErro.textContent = "Data de validade não foi informada";
        }else{
            mensagemErro.textContent = "";
        }
        
        // Verifique o formato MM/AA usando uma expressão regular
        var regex = /^(0[1-9]|1[0-2])\/(\d{2})$/;
        if (!regex.test(dataValidade)) {
            mensagemErro.textContent = "Formato inválido";
        }else{
            mensagemErro.textContent = "";
        }
        
        // Divida a data em mês e ano
        var partes = dataValidade.split('/');
        var mes = parseInt(partes[0]);
        var ano = parseInt(partes[1]);
        
        // Verifique se o mês está entre 1 e 12
        if (mes < 1 || mes > 12) {
            mensagemErro.textContent = "Data inválida";
        }else{
            mensagemErro.textContent = "";
        }
        
        // Obtenha o ano atual
        var anoAtual = new Date().getFullYear() % 100;
        
        // Obtenha o mês atual
        var mesAtual = new Date().getMonth() + 1;
        
        // Verifique se o ano é maior ou igual ao ano atual
        if (ano < anoAtual || (ano === anoAtual && mes < mesAtual)) {
            mensagemErro.textContent = "Data inválida";            
        }else{
            mensagemErro.textContent = "";
        }
    },
    verificarCartaoCredito: function(component, event, helper) {

        var numeroCartao = document.getElementById("numeroCardCred").value;
        var mensagemErro = document.getElementById("mensagemErroNumeroCardCred");
        var numeroCartaoSemEspacos = "";

        var label = component.find("nome");

        var labelClassList = label.getElement().classList;        

        for (var i = 0; i < numeroCartao.length; i++) {
            if (numeroCartao.charAt(i) !== " ") {
                numeroCartaoSemEspacos += numeroCartao.charAt(i);
            }
        }
        
        if (!numeroCartaoSemEspacos || numeroCartaoSemEspacos.trim() === '') {
            mensagemErro.textContent = "Número do cartão não informado";
            labelClassList.remove("slds-m-top_medium");
        }else{
            mensagemErro.textContent = "";
            labelClassList.add("slds-m-top_medium");
        }
        
        if (!/^\d+$/.test(numeroCartaoSemEspacos)) {
            mensagemErro.textContent = "Número do cartão inválido";
            labelClassList.remove("slds-m-top_medium");
        }else{
            mensagemErro.textContent = "";
            labelClassList.add("slds-m-top_medium");
        }
        
        if (numeroCartaoSemEspacos.length < 13 || numeroCartaoSemEspacos.length > 19) {
            mensagemErro.textContent = "Número do cartão inválido";
            labelClassList.remove("slds-m-top_medium");
        }else{
            mensagemErro.textContent = "";
            labelClassList.add("slds-m-top_medium");
        }
        
        var digits = [];
        for (var i = 0; i < numeroCartaoSemEspacos.length; i++) {
            digits.push(parseInt(numeroCartaoSemEspacos.charAt(i)));
        }
        
        var sum = 0;
        var shouldDouble = false;
        
        for (var i = digits.length - 1; i >= 0; i--) {
            var digit = digits[i];
            
            if (shouldDouble) {
                digit *= 2;
                if (digit > 9) {
                    digit -= 9;
                }
            }
            
            sum += digit;
            shouldDouble = !shouldDouble;
        }
        
        if (sum % 10 !== 0) {
            mensagemErro.textContent = "Número do cartão inválido";
            labelClassList.remove("slds-m-top_medium");
        }else{
            mensagemErro.textContent = "";
            labelClassList.add("slds-m-top_medium");
        }
    },
    //II-166 - FIM
    //II-172 - INICIO
    formatarNumCartCred: function(component){
        var numeroCardCred  = document.getElementById("numeroCardCred").value;

        if (numeroCardCred != '' && numeroCardCred.length == 16) {
            numeroCardCred = numeroCardCred.substring(0, 4) + " " + numeroCardCred.substring(4, 8) + " " + numeroCardCred.substring(8, 12) + " " + numeroCardCred.substring(12);
            component.set("v.numeroCartaoCredito", numeroCardCred);
        }
    },
    formatarValCartCred: function(component) {
        var dtVenc = document.getElementById("dataVencimento").value;
        
        if(dtVenc != '' && dtVenc.length > 3){

            dtVenc = dtVenc.replace(/\D/g, "");

            var dataVencimento = dtVenc.slice(0, 2);
            var mesVencimento = dtVenc.slice(2);
            var dataFormatada = dataVencimento + '/' + mesVencimento;
        
        component.set("v.dataVencimento", dataFormatada);
        }
    },    
    formatarCPF: function(component){
        var cpf = '';
        var cpfId = '';
       
        if(document.getElementById("cpf1") != null){
            cpf = document.getElementById("cpf1").value;
            cpfId = 'cpf1';
        }
        else if(document.getElementById("cpf2") != null){
            cpf = document.getElementById("cpf2").value;
            cpfId = 'cpf2';
        }

        if (cpf != '' && cpf.length == 11) {
            cpf = cpf.substring(0, 3) + "." + cpf.substring(3, 6) + "." + cpf.substring(6, 9) + "-" + cpf.substring(9);
            component.set("v." + cpfId, cpf);
        }
    },
    verificarCPF: function(){

        var cpfId = '';
        var mensagemErroCPFId = "";
        var cpf1 = document.getElementById("cpf1") != null ? document.getElementById("cpf1").value : '';
        var cpf2 = document.getElementById("cpf2") != null ? document.getElementById("cpf2").value : '';
        
        var mensagem = document.getElementById("cpf1") != null ? document.getElementById("cpf1") : document.getElementById("cpf2");

        mensagem.addEventListener('input', function(){

            if(cpf1 != '' ){
                mensagemErroCPFId = "mensagemErroCPF1";
            }

            if(cpf2 != ''){
                mensagemErroCPFId = "mensagemErroCPF2";
            }

            cpfId = cpf1 != '' ? 'cpf1' : 'cpf2';

            var cpfForm = document.getElementById(cpfId);
            var mensagemErroCPF = document.getElementById(mensagemErroCPFId);
            var cpf = cpfForm.value;

            cpf = cpf.trim();
    
            if (cpf != '') {
                cpf = cpf.replace('.', '').replace('.', '').replace('.', '').replace('-', '');
                cpf = cpf.replace('*', '').replace('@', '').replace('#', '');
               
                if (cpf === '00000000000' || cpf === '11111111111' || cpf === '22222222222' ||
                    cpf === '33333333333' || cpf === '44444444444' || cpf === '55555555555' ||
                    cpf === '66666666666' || cpf === '77777777777' || cpf === '88888888888' ||
                    cpf === '99999999999' || cpf.length !== 11) {
                   mensagemErroCPF.textContent = "CPF inválido.";
                }
                
                let dig10, dig11, sm, i, r, num, peso;
    
                sm = 0;
                peso = 10;
                let cpfString = cpf.split('');
                for (i = 0; i < 9; i++) {
                    num = parseInt(cpfString[i]);
                    sm = sm + (num * peso);
                    peso = peso - 1;
                }
    
                r = 11 - (sm % 11);
                if (r == 10 || r == 11) {
                    dig10 = 0;
                } else {
                    dig10 = r;
                }
    
                sm = 0;
                peso = 11;
                for (i = 0; i < 10; i++) {
                    num = parseInt(cpfString[i]);
                    sm = sm + (num * peso);
                    peso = peso - 1;
                }
    
                r = 11 - (sm % 11);
                if (r == 10 || r == 11) {
                    dig11 = 0;
                } else {
                    dig11 = r;
                }
    
                if (dig10 === parseInt(cpfString[9]) && dig11 === parseInt(cpfString[10])) {
                    mensagemErroCPF.textContent = "";
                } else {
                    mensagemErroCPF.textContent = "CPF inválido.";
                }
            }else{
                mensagemErroCPF.textContent = "";
            }
        });
    },
    verificarVinculo: function(){
        const vinculo = document.getElementById('vinculo');
        const mensagemErroVinculo = document.getElementById('mensagemErroVinculo');

        vinculo.addEventListener('input', function() {
            const vinculoValue = vinculo.value;
            const regex = /^[a-zA-Z\s]+$/;

            if(vinculoValue != ''){
                if(!regex.test(vinculoValue)){
                    mensagemErroVinculo.textContent = "Preencher apenas com texto.";
                }else{
                    mensagemErroVinculo.textContent = "";
                }
            }
        });
    },
    verificarNascimento: function() {
        const input = document.getElementById('nascimento');
        const mensagemErro = document.getElementById('mensagemErroNascimento');

            input.addEventListener('input', function() {
            const inputValue = input.value;
            const regex = /^\d{2}\/\d{2}\/\d{4}$/;

            if(!regex.test(inputValue)) {
                mensagemErro.textContent = "Data inválida.";
            }else{
                mensagemErro.textContent = "";
            }
        });
    },
    formatarNascimento: function(component) {
        var nascimento = document.getElementById("nascimento").value;
        
        if (nascimento != '' && nascimento.length > 7) {
            nascimento = nascimento.replace(/\D/g, "");
            
            if (nascimento.length > 2) {
                nascimento = nascimento.substring(0, 2) + "/" + nascimento.substring(2);
            }
            
            if (nascimento.length > 5) {
                nascimento = nascimento.substring(0, 5) + "/" + nascimento.substring(5, 9);
            }
        }        
        component.set("v.nascimento", nascimento);
    },
    verificarEmails: function(){
        const emailInput = document.getElementById('email');
        const confirmarEmailInput = document.getElementById('confirmarEmail');
        const mensagemErro = document.getElementById('mensagemErroEmail');

        confirmarEmailInput.addEventListener('input', function(){
        const email = emailInput.value;
        const confirmarEmail = confirmarEmailInput.value;

        var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

            if(email != '' && confirmarEmail != ''){
                if(!email.match(emailRegex)){
                    mensagemErro.textContent = "E-mail inválido.";
                }
                
                if(!confirmarEmail.match(emailRegex)){
                    mensagemErro.textContent = "E-mail inválido.";
                }               
                
                if(email !== confirmarEmail){
                    mensagemErro.textContent = "Emails diferentes.";
                }else{
                    mensagemErro.textContent = "";
                }
            }else{
                mensagemErro.textContent = "";
            }
        });
    },
    verificarTelefone1: function(){
        const telefone1 = document.getElementById('telefone1');
        const mensagemErroTel1 = document.getElementById('mensagemErroTel1');

        telefone1.addEventListener('input', function(){
        const tel1 = telefone1.value;

        var telefone1Regex = /^\(\d{2}\) \d{5}-\d{4}$/; 

            if(tel1 != ''){
                if(!tel1.match(telefone1Regex)){
                    mensagemErroTel1.textContent = "Formato correto: (xx) 9xxxx-xxxx"; 
                }else{
                    mensagemErroTel1.textContent = "";
                }
            }else{
                mensagemErroTel1.textContent = "";
            }
        });
    },
    formatarTelefone1: function(component){
        
        var telefone = '';

        if(document.getElementById("telefone1") != null){
            telefone = document.getElementById("telefone1").value;
        }
        
        if (telefone != '' && telefone.length == 11) {
            telefone = "(" + telefone.substring(0, 2) + ") " + telefone.substring(2, 7) + "-" + telefone.substring(7);
            component.set("v.telefone1", telefone);
        }        
    },
    formatarTelefone2: function(component){
        
        var telefone = '';

        if(document.getElementById("telefone2") != null){
            telefone = document.getElementById("telefone2").value;
        }        
 
        if (telefone != '' && telefone.length == 10) {
            telefone = "(" + telefone.substring(0, 2) + ") " + telefone.substring(2, 6) + "-" + telefone.substring(6);
            component.set("v.telefone2", telefone);
          }
    },
    verificarTelefone2: function(){
        const telefone2 = document.getElementById('telefone2');
        const mensagemErroTel2 = document.getElementById('mensagemErroTel2');

        telefone2.addEventListener('input', function(){
        const tel2 = telefone2.value;
            
        var telefone2Regex = /^\(\d{2}\) \d{4}-\d{4}$/;

            if(tel2 != ''){
                if(!tel2.match(telefone2Regex)){
                    mensagemErroTel2.textContent = "Telefone inválido."; 
                }else{
                    mensagemErroTel2.textContent = "";
                }
            }else{
                mensagemErroTel2.textContent = "";
            }
        });
    },
    verificarCEP: function(cep){
        
        const mensagemErroCEP = document.getElementById('mensagemErroCEP');
        
        if(cep != ''){//II-172 - INICIO

            cep = cep.replace(/\D/g, "");
            var cepInvalidos = [ "00000000", "11111111", "22222222", "33333333", "44444444", "55555555", "66666666", "77777777", "88888888", "99999999", "12345678", "98765432", "54321987"];
           
            if(cepInvalidos.includes(cep)){
                mensagemErroCEP.textContent = "CEP inválido.";
                return false;
                    
                }else{
                    mensagemErroCEP.textContent = "";
                    return true;
                }
        }else{
            mensagemErroCEP.textContent = "";
            return false;
        }//II-172 - FIM
        
    },
    consultarCEP: function(component){
        var action = component.get("c.getEnderecos");
        var cep = document.getElementById("cep").value;
        var cepValido = this.verificarCEP(cep);
    
        if (cep.length < 9) {
            this.limparComplementos(component);
        }
    
        if (cepValido) {
            action.setParams({ cep: cep });
            action.setCallback(this, function (response) {
                var state = response.getState();
    
                if (state === "SUCCESS") {
                    var retorno = response.getReturnValue();
                    var opcoesEndereco = [];
                    var texto = '';
    
                    if (retorno.enderecos != undefined) {
                        if (retorno.enderecos.length == 1) {
                            var logradouro = retorno.enderecos[0].logradouro;
                            var bairro = retorno.enderecos[0].bairro;
                            var estado = retorno.enderecos[0].estado;
                            var uf = retorno.enderecos[0].uf;
    
                            texto = logradouro + ', ' + bairro + ', ' + estado + ', ' + uf;
    
                            var opcoesEndereco = [{ label: texto, value: retorno.enderecos[0] }];
    
                            component.set("v.opcoesEndereco", opcoesEndereco);
    
                            if (logradouro != '') {
                                component.set("v.logradouro", logradouro);
                            }
                            if (bairro != '') {
                                component.set("v.bairro", bairro);
                            }
                            if (estado != '') {
                                component.set("v.cidade", estado);
                            }
                            if (uf != '') {
                                var opcoesEstado = [{ label: uf, value: uf }];
                                component.set("v.opcoesEstado", opcoesEstado);
                            }
                        } else {
                            opcoesEndereco = [{ label: "Selecione um endereço", value: "default" }];
                            for (var i = 0; i < retorno.enderecos.length; i++) {
                                var endereco = retorno.enderecos[i];
                                texto = endereco.logradouro + ', ' + endereco.bairro + ', ' + endereco.estado + ', ' + endereco.uf;
                                opcoesEndereco.push({ label: texto, value: texto });
                            }
    
                            component.set("v.opcoesEndereco", opcoesEndereco);
                        }
                    } else {
                        const mensagemErroCEP = document.getElementById('mensagemErroCEP');
                        mensagemErroCEP.textContent = "CEP inválido.";
                    }
                }
            });
        }
        $A.enqueueAction(action);
    },
    formatarCEP: function(component){
        
        var cep = document.getElementById("cep").value;

        cep = cep.replace(/\D/g, "");
    
        if (cep != '' && cep.length == 8) {
            cep = cep.substring(0, 5) + "-" + cep.substring(5);
            component.set("v.cep", cep);
        }
    },
    carregarComplementos: function(component, event) {

        var complementos = event.target.value;
    
        complementos = complementos.split(',');
    
        if (complementos[0] != '') {
            component.set("v.logradouro", complementos[0]);
        }
        if (complementos[1] != '') {
            component.set("v.bairro", complementos[1]);
        }
        if (complementos[2] != '') {
            component.set("v.cidade", complementos[2]);
        }
    
        if (complementos[3] != '') {
            var opcoesEstado = [{ label: complementos[3], value: complementos[3] }];
            component.set("v.opcoesEstado", opcoesEstado);
        }else{
            var opcoesEstado = [
                { label: "Selecione", value: "default" },
                { label: "AC", value: "AC" },
                { label: "AL", value: "AL" },
                { label: "AP", value: "AP" },
                { label: "AM", value: "AM" },
                { label: "BA", value: "BA" },
                { label: "CE", value: "CE" },
                { label: "DF", value: "DF" },
                { label: "ES", value: "ES" },
                { label: "GO", value: "GO" },
                { label: "MA", value: "MA" },
                { label: "MT", value: "MT" },
                { label: "MS", value: "MS" },
                { label: "MG", value: "MG" },
                { label: "PA", value: "PA" },
                { label: "PB", value: "PB" },
                { label: "PR", value: "PR" },
                { label: "PE", value: "PE" },
                { label: "PI", value: "PI" },
                { label: "RJ", value: "RJ" },
                { label: "RN", value: "RN" },
                { label: "RS", value: "RS" },
                { label: "RO", value: "RO" },
                { label: "RR", value: "RR" },
                { label: "SC", value: "SC" },
                { label: "SP", value: "SP" },
                { label: "SE", value: "SE" },
                { label: "TO", value: "TO" }
            ];
    
            component.set("v.opcoesEstado", opcoesEstado);
        }
    },
    limparComplementos: function(component){

        var logradouro = component.get("v.logradouro");
        var bairro = component.get("v.bairro");
        var estado = component.get("v.cidade");
        var uf = component.get("v.opcoesEstado");
        var opcoesEndereco = component.get("v.opcoesEndereco");


        if (logradouro != '') {
            component.set("v.logradouro", "");
        }
        if (bairro != '') {
            component.set("v.bairro", "");
        }
        if (estado != '') {
            component.set("v.cidade", "");
        }
    
        if (uf != '') {
            component.set("v.opcoesEstado", "");
        }

        if (opcoesEndereco != null){
            component.set("v.opcoesEndereco", null)
        }
    },       
    //II-172 - FIM
    //II-176 - INICIO
    verificaAgenciamento: function(component){
        var action = component.get("c.verificaAntecipacao");
        action.setParams({ propostaId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('Status <> 1' + state);
                if(state === "SUCCESS") {
                    var mostrarFrase = response.getReturnValue();
                    if(mostrarFrase){
                        component.set("v.ShowAntecipacao", mostrarFrase);
                        component.set("v.limite", mostrarFrase);
                    }else{
                        console.log('entrou else  antecipacaoIndisponivel <> ' + state);
                        component.set("v.antecipacaoIndisponivel", true);
                        component.set("v.ShowAntecipacao", mostrarFrase);
                        component.set("v.limite", mostrarFrase);
                    }
                }
            });
            $A.enqueueAction(action);
    },

    ocultarFrase: function(component){
        let qtdParcelas = document.getElementById("selectOpcoesParcelas").value;
        let newFormPag = document.getElementById("novaFormaPagamento").value;
        var action = component.get("c.verificaCondicaoCobranca");
        let limite = component.get("v.limite");
        action.setParams({ propostaId : component.get("v.recordId"),
                            qtdParcelas : qtdParcelas,
                            newFormPag : newFormPag});
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('Status <> 2' + state);
                if(state === "SUCCESS"){
                    var resultado = response.getReturnValue();
                    console.log('resultado <> ', resultado);
                    var antecipaComissao = resultado.antecipaComissao;
                    var antecipaFavorecido = resultado.antecipaFavorecido;
                    //II-175 INICO
                    component.set("v.descontoAgravo", resultado.descontoAgravo); 
                    if(limite){
                        console.log('antecipaComissao <> ' + antecipaComissao);
                        console.log('antecipaFavorecido <> ' + antecipaFavorecido);
                        if(antecipaComissao == 'true'){
                            console.log('entrou if antecipaComi <> ');
                            component.set("v.ShowAntecipacao", false);
                            component.set("v.anteciparCondCobranca", true);
                            component.set("v.antecipacaoSelecionada", true);
                        }else{
                            console.log('entrou else antecipaComi <> ');
                            component.set("v.anteciparCondCobranca", false);
                            component.set("v.ShowAntecipacao", true);
                            if(antecipaFavorecido == 'true'){
                                console.log('entrou antecipaFavorecido  <> ');
                                setTimeout(function() {
                                    let simRadio = document.querySelector('input.sim-radio');
                                    if (simRadio) {
                                        simRadio.checked = true;
                                        console.log('entrou if radio antecipaComi <> ');
                                        component.set("v.antecipacaoSelecionada", true);
                                    }
                                }, 100);
                            }else{
                                setTimeout(function() {
                                    let naoRadio = document.querySelector('input.nao-radio');
                                    if (naoRadio) {
                                        naoRadio.checked = true;
                                        console.log('entrou else radio antecipaComi <> ');
                                        component.set("v.antecipacaoSelecionada", true);
                                    }
                                }, 100);
                            }
                        }
                    }
                }
                //this.qtdeParcelas(component);
                //II-175 FIM
            });
            $A.enqueueAction(action);
    },
    //II-206 - INICIO
    atualizarFavorecido: function(component){

        let simAntecipar = component.get("v.antecipar");
        let notAntecipar = component.get("v.naoAntecipar");
        let condicaoAntecipar = component.get("v.anteciparCondCobranca");
        let limite = component.get("v.limite");
        let ataulizaFav = false;
        let antecipacaoSelecionada = component.get("v.antecipacaoSelecionada");
        let antecipacaoIndisponivel = component.get("v.antecipacaoIndisponivel");

        if(antecipacaoIndisponivel){
            limite = true;
            antecipacaoSelecionada = true;
            ataulizaFav = false;
        }

        if(notAntecipar){
            ataulizaFav = false;
        }
        if(simAntecipar){
            ataulizaFav = true;
        }
        if(condicaoAntecipar){
            ataulizaFav = true;
        }

        if(limite && antecipacaoSelecionada){
            var action = component.get("c.atualizaFavorecidoProposta");
            action.setParams({  propostaId : component.get("v.recordId"),
                                antecipar : ataulizaFav });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //II-175 INICIO
                    if(state === "SUCCESS") {
                    }else if(state == "ERROR"){
                        console.log(response.getError());
                        this.handleErrors(response.getError());
                    }
                    //II-175 FIM
                });
                $A.enqueueAction(action);
        }
    },
    //II-176 - FIM

    recalculoFormaPagamento: function(component){
        //component.set("v.errorInit", ''); //II-206 FIX02 - INICIO/FIM
        //Debugs Rogerio e Henrique FIX01 - INICIO
        console.log("entrou na recalculoFormaPagamento <> ");
        component.set("v.alteracaoFormPag", true);
        this.recalcular(component);
        component.set("v.showSpinner", true);
        //Debugs Rogerio e Henrique FIX01 - FIM
    },

    //FNPVVEP-146 INICIO
    newRecalculoFormaPagamento: function(component){
        component.set("v.showSpinner", true);
        const numero = document.getElementById("numeroCardCred").value;
        const dataVencimento = document.getElementById("dataVencimento").value;
        const recordId = component.get("v.recordId");
        const [mes, anoAbreviado] = dataVencimento.split('/');
        const ano = `20${anoAbreviado}`;
        const codigoEmpresa = component.get("v.codigoEmpresa");

        const cardObject = {
            numero: numero,
            dataVencimento: {
                mes: mes,
                ano: ano
            }
        };

        const action = component.get("c.callTokenizacao");
        action.setParams({
            cardJson: JSON.stringify(cardObject),
            recordId: recordId,
            codigoEmpresa: codigoEmpresa
        });

        console.log('cardObject->',cardObject);

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                console.log("Cartão enviado com sucesso:", response.getReturnValue());
                let jsonObj;
                try {
                    jsonObj = JSON.parse(response.getReturnValue());
                    if (jsonObj.idCartao) {
                        component.set("v.idCartao", jsonObj.idCartao);
                        this.recalculoFormaPagamento(component);
                    } else {
                        component.set("v.showSpinner", false);
                        this.showToastMessage('O idCartao é nulo ou vazio.', "error", "pester")
                    }
                } catch (e) {
                    component.set("v.showSpinner", false);
                    this.showToastMessage('Erro ao fazer o parse do JSON: ' + e.message, "error", "pester")
                }
            } else {
                component.set("v.showSpinner", false);
                this.showToastMessage('Erro ao enviar o cartão: ' + response.getError(), "error", "pester")
            }
        });

        $A.enqueueAction(action);
    },
    //FNPVVEP-146 FIM

    getRespFinanceiro: function(component){

        var nascimento = document.getElementById("nascimento").value;
        var partesData = nascimento.split("/");
        var dia = partesData[0];
        var mes = partesData[1];
        var ano = partesData[2];
        var nascimentoFormatado = ano + "-" + mes + "-" + dia;


        var responsavelFin = {
            responsavel: document.getElementById("responsavel").value,
            cpfResponsavel: document.getElementById("cpf2").value,
            vinculoSegurado: document.getElementById("vinculo").value,
            sexo: document.getElementById("sexo").value,
            nascimento: nascimentoFormatado,
            estadoCivil: document.getElementById("estadoCivil").value,
            email: document.getElementById("email").value,
            confirmarEmail: document.getElementById("confirmarEmail").value,
            cep: document.getElementById("cep").value,
            tipoEndereco: document.getElementById("tipoEndereco").value,
            logradouro: document.getElementById("logradouro").value,
            bairro: document.getElementById("bairro").value,
            cidade: document.getElementById("cidade").value,
            estado: document.getElementById("estados").value,
            //Mock testes
            // cep: '06332-147',
            // tipoEndereco: document.getElementById("tipoEndereco").value,
            // logradouro: 'Graviolas',
            // bairro: 'Vila Quintino',
            // cidade: 'São Paulo',
            // estado: 'SP',
            complemento: document.getElementById("complemento").value,
            semNumero: document.getElementById("semNumero").value,
            numero: document.getElementById("numero").value,
            telefone1: document.getElementById("telefone1").value,
            telefone2: document.getElementById("telefone2").value
          };
          component.set("v.responsavelFinanceiro", responsavelFin);
          var nascimento = component.get("v.responsavelFinanceiro.nascimento");
    },

    atualizaRespFinanceiro: function(component){
        
        var respFin = component.get("v.responsavelFinanceiro");
        var responsavelFinJSON = JSON.stringify(respFin);
        if(responsavelFinJSON == '"{}"'){
            responsavelFinJSON = '';
        }
        var action = component.get("c.atualizaResponsavelFinanceiro");
        action.setParams({
            propostaId : component.get("v.recordId"),
            'responsavelFinJSON' : responsavelFinJSON
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status <> 3' + state);
        });
        $A.enqueueAction(action);
    },

    verificarFormulario: function(component) {
        var form = document.getElementById("formId");
        var inputs = form.querySelectorAll("input");
        var selects = form.querySelectorAll("select");
        var isValid = true;

        inputs.forEach(function(input) {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        selects.forEach(function(select) {
            if (!select.checkValidity()) {
                select.reportValidity();
                isValid = false;
            }
        });

        component.set("v.liberarCalculo", isValid);
    },

    validarCamposCartao: function(component) {
        component.set("v.showFormPgtoADC", false);
        component.set("v.showFormPgtoBoleto", false);
        component.set("v.showFormPgtoCartao", true);
        var isValid = true;
        var numeroCartao = document.getElementById("numeroCardCred").value;
        var nome = document.getElementById("nome").value;
        var dataVencimento = document.getElementById("dataVencimento").value;
        var melDtPgto = document.getElementById("melDtPgtoDisable").value;
        var qtdParcelas = document.getElementById("selectOpcoesParcelas").value;
        var responsavelFinanceiro = document.querySelector('input[name="responsavelFinanceiro"]:checked');

        component.set("v.infoNumero", numeroCartao);
        component.set("v.infoNome", nome);
        component.set("v.infoVencimento", dataVencimento);
        component.set("v.infoMelDtPgto", melDtPgto);
        component.set("v.infoQtdParcelas", qtdParcelas);
    
        if (numeroCartao === "") {
            document.getElementById("mensagemErroNumeroCardCred").textContent = "Por favor, preencha o número do cartão.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroNumeroCardCred").textContent = "";
        }
    
        if (nome === "") {
            document.getElementById("mensagemErroNome").textContent = "Por favor, preencha o nome.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroNome").textContent = "";
        }
    
        if (dataVencimento === "") {
            document.getElementById("mensagemErroValCartCred").textContent = "Por favor, preencha a data de vencimento.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroValCartCred").textContent = "";
        }

        if(responsavelFinanceiro === null){
            document.getElementById("mensagemErroResponsavelFinanceiro").textContent = "Por favor, selecione uma opção.";
            isValid = false;
        }else{
            document.getElementById("mensagemErroResponsavelFinanceiro").textContent = "";
        }
    
        component.set("v.liberarCartao", isValid);
    },

    atualizaCartoes: function(component){
        
        var numero = component.get("v.infoNumero");
        var nome = component.get("v.infoNome");
        var vencimento = component.get("v.infoVencimento");
        var melDtPgto = component.get("v.infoMelDtPgto");
        var qtdParcelas = component.get("v.infoQtdParcelas");
        var codigo = component.get("v.codigoPagamento")
        var action = component.get("c.atualizaCartao");
        var premioTotalNovo = component.get("v.propostaRecalculada.premioTotal"); //ANNVI-91 INICIO/FIM
        var idCartao = component.get("v.idCartao"); //FNPVVEP-146 INICIO/FIM

        console.log('numero->',numero,'nome->',nome,'vencimento->',vencimento,'melDtPgto->',melDtPgto,'qtdParcelas->',qtdParcelas,'codigo->',codigo,'premioTotalNovo->',premioTotalNovo, 'produto->',component.get("v.produtoId"), 'idCartao->',idCartao);

        action.setParams({
            numero : numero,
            nome : nome,
            vencimento : vencimento,
            codigo : codigo,
            propostaId : component.get("v.recordId"),
            produtoId : component.get("v.produtoId"),
            melDtPgto : melDtPgto,
            qtdParcelas : qtdParcelas,
            premioTotalNovo : premioTotalNovo, //ANNVI-91 INICIO/FIM
            idCartao : idCartao //FNPVVEP-146 INICIO/FIM
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status <> 4' + state);
        });
        $A.enqueueAction(action);
        
    },

    validarCamposADC: function(component) {
        component.set("v.showFormPgtoADC", true);
        component.set("v.showFormPgtoBoleto", false);
        component.set("v.showFormPgtoCartao", false);
        var isValid = true;
        var banco = document.getElementById("banco").value;
        var agencia = document.getElementById("agencia").value;
        var contaCorrente = document.getElementById("contaCorrente").value;
        var digito = document.getElementById("digito").value;
        var cpf1 = document.getElementById("cpf1").value;
        var melDtPgto = document.getElementById("melDtPgto").value;
        var qtdParcelas = document.getElementById("selectOpcoesParcelas").value;
        var responsavelFinanceiro = document.querySelector('input[name="responsavelFinanceiro"]:checked');

        component.set("v.infoBanco", banco);
        component.set("v.infoAgencia", agencia);
        component.set("v.infoContaCorrente", contaCorrente);
        component.set("v.infoDigito", digito);
        component.set("v.infocpf1", cpf1);
        component.set("v.infoMelDtPgto", melDtPgto);
        component.set("v.infoQtdParcelas", qtdParcelas);
         
        if (banco === "") {
            document.getElementById("mensagemErroBanco").textContent = "Por favor, preencha o banco.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroBanco").textContent = "";
        }
    
        if (agencia === "") {
            document.getElementById("mensagemErroAgencia").textContent = "Por favor, preencha a agência.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroAgencia").textContent = "";
        }
    
        if (contaCorrente === "") {
            document.getElementById("mensagemErroContaCorrente").textContent = "Por favor, preencha a conta corrente.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroContaCorrente").textContent = "";
        }
    
        if (digito === "") {
            document.getElementById("mensagemErroDigito").textContent = "Por favor, preencha o dígito.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroDigito").textContent = "";
        }

        if (cpf1 === "") {
            document.getElementById("mensagemErroCPF1").textContent = "Por favor, preencha o dígito.";
            isValid = false;
        } else {
            document.getElementById("mensagemErroCPF1").textContent = "";
        }

        if(responsavelFinanceiro === null){
            document.getElementById("mensagemErroResponsavelFinanceiro").textContent = "Por favor, selecione uma opção.";
            isValid = false;
        }else{
            document.getElementById("mensagemErroResponsavelFinanceiro").textContent = "";
        }
        
        component.set("v.liberarADC", isValid);
    },

    atualizaADC: function(component){
        
        var banco = component.get("v.infoBanco");
        var agencia = component.get("v.infoAgencia");
        var contaCorrente = component.get("v.infoContaCorrente");
        var digito = component.get("v.infoDigito");
        var cpf1 = component.get("v.cpf1");
        var melDtPgto = component.get("v.infoMelDtPgto");
        var qtdParcelas = component.get("v.infoQtdParcelas");
        var codigo = component.get("v.codigoPagamento")
        var action = component.get("c.atualizaADC");
        var premioTotalNovo = component.get("v.propostaRecalculada.premioTotal"); //ANNVI-91 INICIO/FIM
        
        action.setParams({
            banco : banco,
            agencia : agencia,
            contaCorrente : contaCorrente,
            digito : digito,
            codigo : codigo,
            cpf1 : cpf1,
            propostaId : component.get("v.recordId"),
            produtoId : component.get("v.produtoId"),
            melDtPgto : melDtPgto,
            qtdParcelas : qtdParcelas,
            premioTotalNovo : premioTotalNovo  //ANNVI-91 INICIO/FIM
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status <> 5' + state);
        });
        $A.enqueueAction(action);
        
    },

    //Debugs Rogerio e Henrique FIX01 - INICIO
    validarCamposBoleto: function(component) {
        console.log('entrou na validarCamposBoleto >');
        component.set("v.showFormPgtoADC", false);
        component.set("v.showFormPgtoBoleto", true);
        component.set("v.showFormPgtoCartao", false);
        var isValid = true;
        var melDtPgto = document.getElementById("melDtPgto").value;
        var qtdParcelas = document.getElementById("selectOpcoesParcelas").value;
        var responsavelFinanceiro = document.querySelector('input[name="responsavelFinanceiro"]:checked');

        console.log('melDtPgto >>>' + melDtPgto);
        console.log('qtdParcelas >>>' + qtdParcelas);
        console.log('responsavelFinanceiro >>>' + responsavelFinanceiro);

        component.set("v.infoMelDtPgto", melDtPgto);
        component.set("v.infoQtdParcelas", qtdParcelas);
        
        if(responsavelFinanceiro === null){
            document.getElementById("mensagemErroResponsavelFinanceiro").textContent = "Por favor, selecione uma opção.";
            isValid = false;
        }else{
            document.getElementById("mensagemErroResponsavelFinanceiro").textContent = "";
        }
        
        component.set("v.liberarBoleto", isValid);
        console.log('liberarBoleto >>>' + component.get("v.liberarBoleto"));
    },
    //Debugs Rogerio e Henrique - FIM

    atualizaBoleto: function(component){
        
        var codigo = component.get("v.codigoPagamento")
        var action = component.get("c.atualizaBoleto");
        //FNPVVEP-147 INICIO
        var melDtPgto = component.get("v.infoMelDtPgto");
        var qtdParcelas = component.get("v.infoQtdParcelas");
        // var melDtPgto = document.getElementById("melDtPgto").value;
        // var qtdParcelas = document.getElementById("selectOpcoesParcelas").value;
        //FNPVVEP-147 FIM
        var premioTotalNovo = component.get("v.propostaRecalculada.premioTotal"); //ANNVI-91 INICIO/FIM

        action.setParams({
            codigo : codigo,
            propostaId : component.get("v.recordId"),
            produtoId : component.get("v.produtoId"),
            melDtPgto : melDtPgto,
            qtdParcelas : qtdParcelas,
            premioTotalNovo : premioTotalNovo //ANNVI-91 INICIO/FIM
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status <> 6' + state);
        });
        $A.enqueueAction(action);
        
    },

    consultaBancos: function(component){
        var opcoesBancos = [];
        var action = component.get("c.consultaBancos");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status consultaBancos <>' + state);
            var bancosString = response.getReturnValue();
            var bancos = JSON.parse(bancosString);
            console.log('bancos <>' + bancos);

            for (var i = 0; i < bancos.length; i++) {
                opcoesBancos.push({label: bancos[i].nomeBanco, value: bancos[i].nomeBanco})
            }
            component.set("v.opcoesBancos", opcoesBancos);
        });
        $A.enqueueAction(action);
    },
    //II-206 - FIM
    //II-206 FIX01 - INICIO
    verificaResponsavelFinanceiro : function(component) {
        var action = component.get("c.dadosResponsavelFinanceiro");

        action.setParams({ propostaId : component.get("v.recordId") });      
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Status Rogerio' + state);
            if(state === "SUCCESS") {
                var responsavelFin = response.getReturnValue();
                console.log('responsavelFin Rogerio >< ' + responsavelFin);
                console.log('responsavelFin.nascimento Rogerio >< ' + responsavelFin.nascimento);
                console.log('responsavelFin.estado >< ' + responsavelFin.estado);
                var date = new Date(responsavelFin.nascimento);
                var year = date.getFullYear();
                var month = ("0" + (date.getMonth() + 1)).slice(-2);
                var day = ("0" + date.getDate()).slice(-2);
                var formattedDate = day + "/" + month + "/" + year;
                console.log(formattedDate);
                if(responsavelFin.isResponsavel == 'true'){
                    console.log('responsavelFin Rogerio True>< ');
                    component.set("v.showOutroRespFin", false);
                    setTimeout(function() {
                        let simRadio = document.querySelector('input.sim-resp');
                        if (simRadio) {
                            simRadio.checked = true;
                        }
                    }, 100);
                }else if(responsavelFin.isResponsavel == 'false'){
                    console.log('responsavelFin Rogerio False>< ');
                    component.set("v.showOutroRespFin", true);
                    setTimeout(function() {
                        let naoRadio = document.querySelector('input.nao-resp');
                        if (naoRadio) {
                            naoRadio.checked = true;
                        }
                        document.getElementById("responsavel").value = responsavelFin.nomeResponsavel;
                        document.getElementById("cpf2").value = responsavelFin.cpfResponsavel;
                        document.getElementById("vinculo").value = responsavelFin.vinculoResponsavel;
                        document.getElementById("sexo").value = responsavelFin.sexo;
                        document.getElementById("nascimento").value = formattedDate;
                        document.getElementById("estadoCivil").value = responsavelFin.estadoCivil;
                        document.getElementById("email").value = responsavelFin.email;
                        document.getElementById("confirmarEmail").value = responsavelFin.email;
                        document.getElementById("cep").value = responsavelFin.cep;
                        document.getElementById("tipoEndereco").value = responsavelFin.tipoEndereco;
                        document.getElementById("logradouro").value = responsavelFin.logradouro;
                        document.getElementById("bairro").value = responsavelFin.bairro;
                        document.getElementById("cidade").value = responsavelFin.cidade;
                        document.getElementById("complemento").value = responsavelFin.complemento;
                        document.getElementById("semNumero").value = responsavelFin.semNumero;
                        document.getElementById("numero").value = responsavelFin.numero;
                        document.getElementById("telefone1").value = responsavelFin.telefone;
                        document.getElementById("telefone2").value = responsavelFin.telefone2;
                        var estadosSelect = document.getElementById("estados");
                        var estadoOption = document.createElement("option");
                        estadoOption.value = responsavelFin.estado;
                        estadoOption.text = responsavelFin.estado;
                        estadosSelect.appendChild(estadoOption);
                        estadosSelect.value = responsavelFin.estado;
                    }, 100);
                }
            }
        });
        $A.enqueueAction(action);
    },

    validarCampoPagamento: function(component) {
        var isValid = true;
        var novaFormaPagamento = document.getElementById("novaFormaPagamento").value;
        
        if(novaFormaPagamento == 'Escolher' || novaFormaPagamento == ''){
            document.getElementById("mensagemErronovaFormaPagamento").textContent = "Por favor, selecione uma opção.";
            isValid = false;
        }else{
            document.getElementById("mensagemErronovaFormaPagamento").textContent = "";
        }
    },
    //II-206 FIX01 - FIM
    //FNPVVEP-126 INICIO
    decryptIdProposta : function(component) {
        
		var action = component.get("c.decryptId");
        
		action.setParams({ propostaId : component.get("v.recordId") }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.recordId", response.getReturnValue());
                this.popularTabelaCriticas(component);
                this.carregaDadosProposta(component);
                this.dadosFormaPagamento(component);
                this.verificaAgenciamento(component);
                this.consultaBancos(component);
                this.verificaResponsavelFinanceiro(component);
            }
        });
        $A.enqueueAction(action);
    }
    //FNPVVEP-126 FIM
})