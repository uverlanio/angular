// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
({
	buscarPagamentosSinistros : function(cmp) {
        var inputDtInicio = cmp.find("dtInicio");
        var valueDtInicio = inputDtInicio.get("v.value");
        
        var inputDtFim = cmp.find("dtFim");
        var valueDtFim = inputDtFim.get("v.value");
        
        var selectParceiro = cmp.find("Contas_de_Parceiro__c");        
		var valueParceiro = selectParceiro.get("v.value");
        
        var inputValorCotacao = cmp.find("Valor_da_Cotacao_de_Moeda_Estrangeira__c");
        var valueValorCotacao = inputValorCotacao.get("v.value");
        
       
        if(valueValorCotacao == 0){
           var type = 'error';
           var title = 'valor Catação';
           var message = 'Valor da cotação tem que ser maior que zero (0).';
           this.validacaoFields(type, title, message);
        }
        
            	
        if(!valueDtFim || !valueDtInicio || !valueValorCotacao || !valueParceiro){
           var type = 'error';
           var title = 'Campos obrigatórios';
           var message = 'Favor verificar se os campos Data Inicio, Data Fim, Contas de parceiro e valor de Cotação moeda estrangeira estão preenchidos.';
           this.validacaoFields(type, title, message);
        }else if(valueDtFim && valueDtInicio && valueValorCotacao > 0){
        	//PLV-3918 - FIX2 - INICIO
            console.log('buscarPagamentosSinistros');
            //PLV-3918 - FIX2 - FIM
            //PLV-4148-FIX5 - INICIO
            var columns = [
                        {
                            type: 'text',
                            fieldName: 'NumeroSinistro__c',
                            label: 'Nº Sinistro'
                            //initialWidth: 300
                        },
                        {
                            type: 'date',
                            fieldName: 'Dataocorrencia__c',
                            label: 'Data da Ocorrencia'
                            
                        },
                        {
                            type: 'date',
                            fieldName: 'Data_sinistro_avisado__c',
                            label: 'Data do aviso'
                            
                        },
                		{
                            type: 'string',
                            fieldName: 'CurrencyIsoCode',
                            label: 'Cotação'
                            
                        },
                        {
                            type: 'number',
                            fieldName: 'Valor_total_a_ser_indenizado__c',
                            label: 'Valor da Prestação'
                            
                        }
                		 
                 
                    ];
            //PLV-4148-FIX5 - INICIO
            cmp.set('v.gridColumns', columns);
                    
            var action = cmp.get("c.buscarPagamentosSinistros");
            action.setParams({
                dtinicio: valueDtInicio,
                dtfim: valueDtFim,
                parceiro: valueParceiro
            });      
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    //var obj = JSON.stringify(data);
                    if(data.length > 0){
                        document.getElementById("gridPagamentos").style.display="block";
                        cmp.set('v.tipoMoeda',data[0]['CurrencyIsoCode']);
                        console.log('tipo moeda'+data[0]['CurrencyIsoCode']);
                        for(var i=0; i<data.length; i++) {
                            data[i]['Dataocorrencia__c'] = data[i]['Caso_de_Sinistro__r']['Dataocorrencia__c'];
                            data[i]['Data_sinistro_avisado__c'] = data[i]['Caso_de_Sinistro__r']['Data_sinistro_avisado__c'];
                            data[i]['NumeroSinistro__c'] = data[i]['Caso_de_Sinistro__r']['NumeroSinistro__c'];
                        }
                                               
                    }else{
                       document.getElementById("gridPagamentos").style.display="none";
                       var type = 'alert';
                       var title = 'Pagamentos de Sinistros'
                       var message = 'Nenhum Pagamento de Sisnitro encontrado!';
                       this.validacaoFields(type, title, message);
                    }
                    console.log('santana'+data.length);
                   
                    cmp.set('v.gridData', data);
                }
                
            });
            $A.enqueueAction(action);
    	}
	},

	//PLV-4148 Inicio
	buscarPagamentosSinistrosIndenizacao : function(cmp) {
        var inputDtInicio = cmp.find("dtInicio");
        var valueDtInicio = inputDtInicio.get("v.value");
        
        var inputDtFim = cmp.find("dtFim");
        var valueDtFim = inputDtFim.get("v.value");
        
        var selectParceiro = cmp.find("Contas_de_Parceiro__c");
		console.log('selectParceiro = ' + selectParceiro);
        var valueParceiro = selectParceiro.get("v.value");
		console.log('valueParceiro = ' + valueParceiro);   
        
        var selectMoeda = cmp.find("moedas");
        var valueMoeda = selectMoeda.get("v.value");
         
        console.log('valueMoeda'+valueMoeda);
            	
        if(!valueDtFim || !valueDtInicio || !valueParceiro || !valueMoeda){
           var type = 'error';
           var title = 'Campos obrigatórios';
           var message = 'Favor verificar se os campos Data Inicio, Data Fim, Contas de parceiro e se existe um valor na na opção de Moeda estão preenchidos.';
           this.validacaoFields(type, title, message);
        }else if(valueDtFim && valueDtInicio){
        	//PLV-3918 - FIX2 - INICIO
            console.log('buscarPagamentosSinistrosIndenizacao');
            //PLV-3918 - FIX2 - FIM
            var columns = [
                        {
                            type: 'text',
                            fieldName: 'NumeroSinistro__c',
                            label: 'Nº Sinistro'
                            //initialWidth: 300
                        },
                        {
                            type: 'text',
                            fieldName: 'Name',
                            label: 'Nome da garantia'
                            
                        },
                        {
                            type: 'text',
                            fieldName: 'Account',
                            label: 'Nome do segurado'
                            
                        },
                        {
                            type: 'text',
                            fieldName: 'Contrato__c',
                            label: 'Contrato'
                            
                        },
                		{
                            type: 'string',
                            fieldName: 'CurrencyIsoCode',
                            label: 'Moeda'
                            
                        },
                		 {
                            type: 'string',
                            fieldName: 'SomaValorBeneficiarios__c',
                            label: 'Valor Indenizado'
                            
                        }
                 
                    ];
            
            cmp.set('v.gridColumns', columns);
                    
            var action = cmp.get("c.buscarGarantias");
            action.setParams({
                dtinicio: valueDtInicio,
                dtfim: valueDtFim,
                parceiro: valueParceiro,
                moeda: valueMoeda
            });      
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    //var obj = JSON.stringify(data);
                    if(data.length > 0){
                        document.getElementById("gridPagamentos").style.display="block";
                         //PLV-4356 - INICIO
                        cmp.set('v.tipoMoeda',data[0]['Pagamento_de_garantia__r']['CurrencyIsoCode']);
                       
						for(var i=0; i<data.length; i++) {
                            /*data[i]['Contrato__c'] = data[i]['Caso__r']['Contrato__c'];
                            data[i]['Account'] = data[i]['Caso__r']['Account']['Name'];
                            data[i]['NumeroSinistro__c'] = data[i]['Caso__r']['NumeroSinistro__c'];
                            var somaBen = parseFloat(data[i]['SomaValorBeneficiarios__c']).toFixed(2);
                            data[i]['SomaValorBeneficiarios__c'] = somaBen;
                            */
                            data[i]['Id'] = data[i]['Pagamento_de_garantia__c'];
                            data[i]['Name'] = data[i]['Pagamento_de_garantia__r']['Name'];
                            data[i]['Contrato__c'] = data[i]['Pagamento_de_garantia__r']['Caso__r']['Contrato__c'];
                            data[i]['Account'] = data[i]['Conta__r']['Name'];
                            data[i]['NumeroSinistro__c'] = data[i]['Pagamento_de_garantia__r']['Caso__r']['NumeroSinistro__c'];
                            data[i]['CurrencyIsoCode'] = data[i]['Pagamento_de_garantia__r']['CurrencyIsoCode'];
                            var somaBen = parseFloat(data[i]['Pagamento_de_garantia__r']['SomaValorBeneficiarios__c']).toFixed(2);
                            data[i]['SomaValorBeneficiarios__c'] = somaBen;
                          
          
                        }  
                        //PLV4356 - FIM
                        
                    }else{
                       document.getElementById("gridPagamentos").style.display="none";
                       var type = 'alert';
                       var title = 'Pagamentos de Sinistros'
                       var message = 'Nenhum Pagamento de Sinistro encontrado!';
                       this.validacaoFields(type, title, message);
                    }
                    
                    console.log('garantias pagamentos/'+JSON.stringify(data));
                    
                    cmp.set('v.gridData', data);
                }
                
            });
            $A.enqueueAction(action);
    	}
	},
	//PLV-4148 Fim
    
    validacaoFields: function(type, title, message){
         let toastParams = {
             title: title,
             message: message,
             type: type
         };
         // Fire error toast
         let toastEvent = $A.get("e.force:showToast");
         toastEvent.setParams(toastParams);
         toastEvent.fire();
    },
    
	getSelectedRowsHelper: function(cmp, event, helper) {
       //PLV-4148 - INICIO
	   var recordTypeName = cmp.get('v.recordTypeName');
	   console.log('recordTypeName = '+ recordTypeName);
	   if(recordTypeName == 'Indenização de sinistros'){
			console.log('Entrou If  recordTypeName = '+ recordTypeName);
			this.getSelectedRowsIndenizacao(cmp, event, helper);
	   }else{
	   var curRows = event.getParam('selectedRows');
       var listaIds = [];
       var valorTotal = 0;
       
       var imputQtPagamento = cmp.find("Quantidade_total_de_sinistros_realizados__c");
       imputQtPagamento.set("v.value",curRows.length);
       
        
       if(curRows.length > 0){
           for(var x=0; x<curRows.length; x++){
                listaIds.push(curRows[x].Id);
              	valorTotal = valorTotal + curRows[x].Valor_total_a_ser_indenizado__c;
           }
          
       }
       var inputValorCotacao = cmp.find("Valor_da_Cotacao_de_Moeda_Estrangeira__c");
       var valueValorCotacao = inputValorCotacao.get("v.value");
       cmp.set('v.IdsPagamentosSinistros',listaIds);
       var totalValorItens = valorTotal*valueValorCotacao;
       cmp.set('v.valorTotal',parseFloat(totalValorItens.toFixed(2)));
       cmp.set('v.valorTotalItens',valorTotal);
       var listaGrid = cmp.get('v.gridData');
       console.log('santana2'+ JSON.stringify(curRows));
	   }
	   //PLV-4148 - FIM
	   
    },
	//PLV-4148 - INICIO
	getSelectedRowsIndenizacao: function(cmp, event, helper) {
       var curRows = event.getParam('selectedRows');
       var listaIds = [];
       var valorTotal = 0;
       
       var imputQtPagamento = cmp.find("Quantidade_total_de_sinistros_realizados__c");
       imputQtPagamento.set("v.value",curRows.length);
       
        
       if(curRows.length > 0){
           for(var x=0; x<curRows.length; x++){
                listaIds.push(curRows[x].Id);
              	valorTotal = valorTotal + parseFloat(curRows[x].SomaValorBeneficiarios__c);
           }
          
       }
       //var inputValorCotacao = cmp.find("Valor_da_Cotacao_de_Moeda_Estrangeira__c");
       //var valueValorCotacao = inputValorCotacao.get("v.value");
       cmp.set('v.idsPagamentosGarantias',listaIds);
       //var totalValorItens = valorTotal*valueValorCotacao;
       cmp.set('v.valorTotal',parseFloat(valorTotal.toFixed(2)));
       cmp.set('v.valorTotalItens',valorTotal);
       var listaGrid = cmp.get('v.gridData');
       console.log('santana2'+ JSON.stringify(curRows));
    },
    buscaMoeda: function(cmp){
         var action = cmp.get("c.buscaMoedas");   
             action.setCallback(this, function(resp) {
             	if(resp.getState() === 'SUCCESS'){
                    var data = resp.getReturnValue();
                	cmp.set('v.moedasSelect',data);
                	
                }
             });
       	$A.enqueueAction(action);
    },   
	//PLV-4148 - FIM
	
	//PLV-4501 - INICIO
	criarPagamentoPrestadoraHelper: function(cmp){
						
		var recordTypeId =  cmp.get("v.recordTypeId");		

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

		
		var action = cmp.get("c.criarPagamentoPrestador");
            action.setParams({
                recordTypeId: recordTypeId,
				dtinicio: valueDtInicio,
                dtfim: valueDtFim,
                codigoPrestador: valueParceiro,
				valorPagamento: valuePagamento
            }); 
				     
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
					if(data == 'ok'){
						var type = 'success';
						var title = 'Requisição Pagamento Salva';
						var message = 'Registro salvo com sucesso.';
						this.validacaoFields(type, title, message);
                        //PLV-4501 - FIX1 - INICIO
                        var homeEvt = $A.get("e.force:navigateToObjectHome");
                        homeEvt.setParams({
                            "scope": "Requisicao_de_Pagamento__c"
                        });
                        $A.get('e.force:refreshView').fire();
                        homeEvt.fire(); 
                       
                    }else{
                        var type = 'error';
						var title = 'Requisição Pagamento';
						var message = 'Houve um erro ao criar a requisição de pagamento.';
						this.validacaoFields(type, title, message);
                    }
                     //PLV-4501 - FIX1 - FIM
				}
			});
            $A.enqueueAction(action);
        	
	},
	//PLV-4501 - FIM

    //PLV-4604 - INICIO
	criarPagamentoDespesasHelper: function(cmp, event,helper){
						
		var requisicao = cmp.get("v.requisicao");
        console.log(JSON.stringify(requisicao));
        var action = cmp.get("c.criarPagamentoDespesa");
        requisicao.Valor_Total_Prestadora__c = requisicao.Valor_Total_Prestadora__c.replace('.',',');
        action.setParams({
            requisicao: requisicao
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data.Id != null){
                    var type = 'success';
                    var title = 'Requisição de Pagamento de Despesa';
                    var message = 'Registro salvo com sucesso.';
                    this.validacaoFields(type, title, message);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": data.Id
                    });
                    navEvt.fire();
                }else{
                    var type = 'error';
                    var title = 'Requisição de Pagamento de Despesa';
                    var message = 'Houve um erro ao criar a requisição de pagamento de despesa.';
                    this.validacaoFields(type, title, message);
                }
                  
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var type = 'error';
                        var title = 'Requisição de Pagamento de Despesa';
                        var message = errors[0].message;
                        this.validacaoFields(type, title, message);                        
                    }
                }
            }
        });
        $A.enqueueAction(action);
        	
	}
	//PLV-4604 - FIM

})