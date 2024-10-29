// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
({
     doInit: function(cmp, event, helper) {
        //PLV-4931 - INICIO
        var myPageRef = cmp.get("v.pageReference");
        console.log('myPageRef:' +myPageRef);
        console.log('state:' +myPageRef.state);
        var recordTypeValue = myPageRef.state.recordTypeId;
        console.log('recordTypeValue:' +recordTypeValue);
        var action = cmp.get("c.validaTipoRegistro");
        /*
        //PLV-4148-FIX5 - INICIO
         var urlAtual =  location.search.substr(1);
         if(urlAtual.indexOf("recordTypeId") < 0){
            var recordTypeValue = null;
            console.log('recordTypeValue'+recordTypeValue);
         }else{
             var arrayRetorno = urlAtual.split("recordTypeId=");
             var idRecordType = arrayRetorno[1].split("&");
             
            
             var recordTypeValue = idRecordType[0];
             //PLV-3918 - FIX2 - INICIO
             console.log('idrecordType'+idRecordType[0]);
             //PLV-3918 - FIX2 - FIM
         }*/
         //PLV-4931 - FIM
         
         action.setParams({
             recordType: recordTypeValue
         });  
        //PLV-4148-FIX5 - FIM
     	action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
               //PLV-4148 - INICIO
               //PLV-4148-FIX5 - INICIO
               var recordTypeName = response.getReturnValue();
               console.log('recordTypeName'+ JSON.stringify(response.getReturnValue()));
               cmp.set("v.recordTypeName",recordTypeName.nomeRecordType);
               cmp.set("v.recordTypeId",recordTypeName.idRecordType);
               //PLV-3918 - FIX2 - INICIO
                 console.log('recordTypeName entrou '+ recordTypeName.nomeRecordType+ ' = '+recordTypeName.nomeRecordType);
               //PLV-3918 - FIX2 - FIM
                if(recordTypeName.nomeRecordType == "Indenização de sinistros"){
                   helper.buscaMoeda(cmp);
                }
                //PLV-4604 - INICIO
                else if(recordTypeName.nomeRecordType == "Despesas com Sinistros Não Tributáveis" || recordTypeName.nomeRecordType == "Despesas com Sinistros Tributáveis"){
                    var requisicao = new Object();
                    requisicao.RecordTypeId = recordTypeName.idRecordType;
                    requisicao.Status__c = 'Pendente';
                    cmp.set('v.requisicao',requisicao);
                }
                //PLV-4604 - FIM
                //PLV-4148-FIX5 - FIM
				//PLV-4148 - FIM  
				            
            }
        });
        $A.enqueueAction(action);
     
    },
    
    handleCancel: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleSubmit: function(cmp, event, helper) {
        event.preventDefault();
        var fields = event.getParam('fields');
        //PLV-4148 - INICIO
        console.log('4148'+JSON.stringify(fields));
        //PLV-4148 - FIM
        cmp.find('myform').submit(fields);
        
        //alert('salvou'+cmp.get('v.IdsPagamentosSinistros'));
    },
    
    handleSuccess: function(cmp, event, helper) {
        var params = event.getParams();
    	cmp.set('v.recordId', params.response.id);
        //PLV-4148 - INICIO
        if(cmp.get("v.recordTypeName") == "Operacional de sinistros"){
             console.log('entrou em Operacional'+cmp.get('v.IdsPagamentosSinistros'));
             var action = cmp.get("c.atualizaPagamentoSinistro");
             action.setParams({
                    recordId: params.response.id,
                    IdsPagSinistro: cmp.get('v.IdsPagamentosSinistros')
             });  
        }else{
             console.log('entrou em Indenização'+cmp.get('v.idsPagamentosGarantias'));
             var action = cmp.get("c.createPagamentoSinistro");
             action.setParams({
                    recordId: params.response.id,
                    idsPagamentoGarantias: cmp.get('v.idsPagamentosGarantias')
             });  
        }
        //PLV-4604 - INICIO
        if(cmp.get("v.recordTypeName") == "Despesas com Sinistros Não Tributáveis" || cmp.get("v.recordTypeName") == "Despesas com Sinistros Tributáveis"){             
            helper.criarPagamentoDespesasHelper(cmp, event, helper);
        }
        else{
            //PLV-4148 - FIM
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //var data = response.getReturnValue();
                        //var obj = JSON.stringify(data);
                        console.log('sucesso.');
                        
                    }
                    
            });
            $A.enqueueAction(action);
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Requisicao_de_Pagamento__c"
            });
            $A.get('e.force:refreshView').fire();
            homeEvt.fire(); 
        }
        //PLV-4604 - FIM
    },
    pagamentosSinistros: function(cmp, event, helper){
        //PLV-3918 - FIX2 - INICIO
        console.log('pagamentosSinistros'+cmp);
        //PLV-3918 - FIX2 - FIM

         helper.buscarPagamentosSinistros(cmp);
    },
    
	//PLV-4148 - INICIO
	pagamentosSinistrosIndenizacao: function(cmp, event, helper){
        console.log('pagamentosSinistrosIndenizacao'+cmp);
     
        helper.buscarPagamentosSinistrosIndenizacao(cmp);
    },
	//PLV-4148 - FIM

	//PLV-4501 - INICIO
	criarPagamentoPrestadora: function(cmp, event, helper){
        console.log('criarPagamentoPrestadora'+cmp);

		var inputDtInicio = cmp.find("dtInicio");
        var valueDtInicio = inputDtInicio.get("v.value");
        
        var inputDtFim = cmp.find("dtFim");
        var valueDtFim = inputDtFim.get("v.value");
        
        
		var selectParceiro = cmp.find("Contas_de_Parceiro__c");
		console.log('selectParceiro = ' + selectParceiro);
        var valueParceiro = selectParceiro.get("v.value");
		console.log('valueParceiro = ' + valueParceiro);   
        
        var valorPagamento = cmp.find("Valor_do_pagamento__c");
        var valuePagamento = valorPagamento.get("v.value");
		
		if(!valueDtFim || !valueDtInicio || !valuePagamento || !valueParceiro){
           var type = 'error';
           var title = 'Campos obrigatórios';
           var message = 'Favor verificar se os campos Data Inicio, Data Fim, Contas de parceiro e valor Pagamento estão preenchidos.';
           helper.validacaoFields(type, title, message);
        }else{
			helper.criarPagamentoPrestadoraHelper(cmp); //PLV-4501 - FIX1 - INICIO/FIM
		}
    },
	//PLV-4501 - FIM

    //PLV-4148 - INICIO
	getSelectedRows: function(cmp, event, helper) {
		helper.getSelectedRowsHelper(cmp, event, helper);
	},
	//PLV-4148 - FIM
    closeDialog: function(cmp, helper) {
		var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Requisicao_de_Pagamento__c"
        });
        homeEvt.fire();
    },
    atualizaValores: function(cmp, event, helper){
        var inputValorCotacao = cmp.find("Valor_da_Cotacao_de_Moeda_Estrangeira__c");
        var valueValorCotacao = inputValorCotacao.get("v.value");
       
        if(valueValorCotacao > 0){
            var valorItens = cmp.get('v.valorTotalItens');
            var totalValorItens = valorItens*valueValorCotacao;
       	
        	cmp.set('v.valorTotal',parseFloat(totalValorItens.toFixed(2)));
        }
       
        
        
    }
})