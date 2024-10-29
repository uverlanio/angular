({
    validacheque : function(component, event, helper){
        var recId = component.get('v.recordId');
        var action = component.get('c.validarcheque');
        action.setParams({recordId: recId});
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();
                console.log('ret cheque');
                console.log(ret);

               	if (ret == true)
                {
                    component.set("v.cheque", 'true');
                    helper.validaserasa(component, event, helper);
                }else
                {
                    console.log('false chequeeee');
                    
                    component.set("v.cheque", 'false');
                    helper.validacomposicao(component, event, helper);
                    
                }
				
            } else {
                console.log('Error, response state: ' + state);
            }
        });

        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },
    
    validacomposicao : function(component, event, helper){
    	//$A.get("e.force:refreshView").fire();
    	var recId = component.get('v.recordId');
        console.log('entrou valida ');
        
        var action = component.get('c.validarComposicaoBancaria');
        action.setParams({recordId: recId});
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
			console.log('state valida ');
            console.log(state);
            
            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();
				console.log('ret valida ');
                console.log(ret);
                
                $A.get('e.force:refreshView').fire();
               if (ret === 'Validada')
                {
                    component.set("v.sucesso", ' Dados bancários válidos');
                    var icone = component.find("icone-sucesso");
                    $A.util.toggleClass(icone, "slds-hide"); 
                    helper.validabloqueio(component,event,helper,ret);
                }else{
                    component.set("v.sucesso", ' Dados bancários inválidos');
                    var icone = component.find("icone-error");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Dados bancários são inválidos. Bloqueio não verificado.');
                    var iconebloq = component.find("icone-errorconta");
                    $A.util.toggleClass(iconebloq, "slds-hide");
                    	
                    helper.validaserasa(component,event,helper,ret);
                }

            } else {
                
                component.set("v.sucesso", ' Erro na integração. Favor verifique com um administrador.');
                var icone = component.find("icone-error");
                $A.util.toggleClass(icone, "slds-hide");
                console.log('Error, response state: ' + state);
            }
        });

        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
   
    },

    validabloqueio : function(component, event, helper, ret){
       // $A.get("e.force:refreshView").fire();
        var recId = component.get('v.recordId');
        console.log('entrou bloqueio '); 
        
        var action = component.get('c.verificarbloqueiobancario');
        action.setParams({recordId: recId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
               	if (ret === 'Não Validada')
                {
                    component.set("v.bloqueio", ' Inconsistência nos dados bancários do beneficiário.');
                    var icone = component.find("icone-errorconta");
                    $A.util.toggleClass(icone, "slds-hide"); 
                    
                    helper.validaserasa(component,event,helper);
                }
                else if(ret === 'Não existe parceiro')
                {
                    component.set("v.bloqueio", ' Não existe parceiro de negócios para o CPF ou CNPJ informado.');
                    var icone = component.find("icone-errorconta");
                    $A.util.toggleClass(icone, "slds-hide");
                    
                    helper.validaserasa(component,event,helper);
                }
                else
                {
                    component.set("v.bloqueio", ' Dados bancários do beneficiário validados');
                    var icone = component.find("icone-sucessoconta");
                    $A.util.toggleClass(icone, "slds-hide");
                    helper.validaserasa(component,event,helper);
                }

            } else {
                component.set("v.bloqueio", ' Erro na integração, favor verifique com um administrador.');
                var icone = component.find("icone-errorconta");
                $A.util.toggleClass(icone, "slds-hide");
               
                console.log('Error, response state: ' + state);
            }
        });

        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },
    
    
    validaserasa : function(component, event, helper, ret){
        var recId = component.get('v.recordId');
        console.log('entrou serasa '); 
        
        var action = component.get('c.validarnomeserasa');
        action.setParams({recordId: recId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var error = response.getError();
            console.log('state');
            console.log(state);
            
            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();
				console.log('ret');
                console.log(ret);
                if (ret === 'Nome já atualizado')
                {
                    component.set("v.serasa", 'Nome da Conta já atualizado.');
                    var serasa = component.find("icone-sucessoserasa");
                    var serasa2 = component.find("icone-sucessoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide"); 
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire();
                }
                else if(ret === 'Nome foi atualizado')
                {
                    component.set("v.serasa", 'Nome da Conta Atualizado pelo Serasa.');
                    var serasa = component.find("icone-sucessoserasa");
                    var serasa2 = component.find("icone-sucessoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire(); 
                }else if (ret === 'Não encontrado registro no Serasa')
                {
                    component.set("v.serasa", 'Não foi possível realizar a validação do Beneficiário no Serasa.');
                    var serasa = component.find("icone-avisoserasa");
                    var serasa2 = component.find("icone-avisoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire(); 
                }else if (ret == 'Erro no update')
                {
                    component.set("v.serasa", 'Erro no Update. Por favor consulte o administrador do sistema');
                    var serasa = component.find("icone-errorserasa");
                    var serasa2 = component.find("icone-erroserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire(); 
                }else if (ret === 'Erro no serviço')
                {
                    component.set("v.serasa", 'Não foi possível realizar a validação do Beneficiário no Serasa.');
                    var serasa = component.find("icone-avisoserasa");
                    var serasa2 = component.find("icone-avisoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire(); 
                }else
                {
                    component.set("v.serasa", 'Erro na integração, verifique com um administrador.');
                    var serasa = component.find("icone-errorserasa");
                    var serasa2 = component.find("icone-erroserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire();
                }
				
                	helper.toggleSpinner(component);
                    var loads = component.find("loads");
                    var footer = component.find("footer");
                    var header = component.find("header");
                    $A.util.removeClass(loads, "slds-hide");
                    $A.util.addClass(loads, "slds-show");
                    $A.util.removeClass(footer, "slds-hide");
                    $A.util.addClass(footer, "slds-show");
                	$A.util.removeClass(header, "slds-hide");
                    $A.util.addClass(header, "slds-show"); 

            } else {
                console.log('ret');
                console.log(ret);
                
                console.log('Error, response state: ' + state);
                        
                 	component.set("v.serasa", 'Erro na integração, verifique com um administrador.');
                    var serasa4 = component.find("icone-errorserasa");
                    var serasa5 = component.find("icone-erroserasacheque");
                    $A.util.toggleClass(serasa4, "slds-hide");
                    $A.util.toggleClass(serasa5, "slds-hide");
                    $A.get('e.force:refreshView').fire();
                
                	helper.toggleSpinner(component);
                    var loads = component.find("loads");
                    var footer = component.find("footer");
                    var header = component.find("header");
                    $A.util.removeClass(loads, "slds-hide");
                    $A.util.addClass(loads, "slds-show");
                    $A.util.removeClass(footer, "slds-hide");
                    $A.util.addClass(footer, "slds-show");
                	$A.util.removeClass(header, "slds-hide");
                    $A.util.addClass(header, "slds-show");
                }
        });

        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },
    
    chamarCIVLiquidacao : function(component, event, helper, ret){
        var recId = component.get('v.recordId');
        console.log('entrou serasa '); 
        
        var action = component.get('c.acionaCIVLiquidacao');
        action.setParams({recordId: recId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var error = response.getError();
            console.log('state');
            console.log(state);
            
            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();
				console.log('ret');
                console.log(ret);
                console.log('ret.Status');
				console.log(ret.Status);
				console.log('ret.sucesso');
				console.log(ret.sucesso);
				if (ret.Serasa === 'Nome já atualizado no Salesforce')
                {
                    component.set("v.sucesso", ' Dados bancários válidos');
                    var icone = component.find("icone-sucesso");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Dados bancários do beneficiário validados');
                    var icone = component.find("icone-sucessoconta");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.serasa", 'Nome da Conta já atualizado.');
                    var serasa = component.find("icone-sucessoserasa");
                    var serasa2 = component.find("icone-sucessoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide"); 
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire();

					//Ajuste
					var iconePEP = component.find("icone-sucessoPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", ret.PEP);
					//Ajuste
                }
                else if(ret.Serasa === 'Nome foi atualizado')
                {
                    component.set("v.sucesso", ' Dados bancários válidos');
                    var icone = component.find("icone-sucesso");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Dados bancários do beneficiário validados');
                    var icone = component.find("icone-sucessoconta");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.serasa", 'Nome da Conta Atualizado pelo Serasa.');
                    var serasa = component.find("icone-sucessoserasa");
                    var serasa2 = component.find("icone-sucessoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire();
					
					//Ajuste
					var iconePEP = component.find("icone-sucessoPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", ret.PEP);
					//Ajuste 
                }else if (ret.Serasa === 'Não encontrado registro no Serasa')
                {
                    component.set("v.sucesso", ' Dados bancários válidos');
                    var icone = component.find("icone-sucesso");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Dados bancários do beneficiário validados');
                    var icone = component.find("icone-sucessoconta");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.serasa", 'Não foi possível realizar a validação do Beneficiário no Serasa.');
                    var serasa = component.find("icone-avisoserasa");
                    var serasa2 = component.find("icone-avisoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire();
					
					//Ajuste
					var iconePEP = component.find("icone-sucessoPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", ret.PEP);
					//Ajuste 
                }else if (ret.Serasa === 'Erro no serviço do Serasa')
                {
                    component.set("v.sucesso", ' Dados bancários válidos');
                    var icone = component.find("icone-sucesso");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Dados bancários do beneficiário validados');
                    var icone = component.find("icone-sucessoconta");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.serasa", 'Não foi possível realizar a validação do Beneficiário no Serasa.');
                    var serasa = component.find("icone-avisoserasa");
                    var serasa2 = component.find("icone-avisoserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    $A.get('e.force:refreshView').fire();
					
					//Ajuste
					var iconePEP = component.find("icone-sucessoPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", ret.PEP);
					//Ajuste 
                }else if(ret.DadosBancarios === 'Erro na validação dos dados bancários'){
                    component.set("v.sucesso", ' Dados bancários inválidos');
                    var icone = component.find("icone-error");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Erro na integração dos dados bancários.');
                    var icone = component.find("icone-errorconta");
                    $A.util.toggleClass(icone, "slds-hide");

					//Ajuste
					var iconePEP = component.find("icone-sucessoPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", ret.PEP);
					//Ajuste
                }
                else if(ret.Status === 'Não é possível validar o beneficiário com o status do pagamento diferente de Pendente.'){
                    component.set("v.sucesso", ' Não é possível validar o beneficiário com o status do pagamento diferente de Pendente.');
                    var icone = component.find("icone-error");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Não é possível validar o beneficiário com o status do pagamento diferente de Pendente.');
                    var icone = component.find("icone-errorconta");
                    $A.util.toggleClass(icone, "slds-hide");
					component.set("v.serasa", 'Não é possível validar o beneficiário com o status do pagamento diferente de Pendente.');
                    var serasa = component.find("icone-errorserasa");
                    var serasa2 = component.find("icone-erroserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
					
					//Ajuste
					var iconePEP = component.find("icone-errorPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", 'Não é possível validar o beneficiário com o status do pagamento diferente de Pendente.');
					//Ajuste

                    $A.get('e.force:refreshView').fire();
                }//Ajuste  Inicio
				else if(ret.PEP === 'Pessoa não é PEP.'){
                    component.set("v.sucesso", 'Pessoa não é PEP.');
                    var icone = component.find("icone-error");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", 'Pessoa não é PEP.');
                    var icone = component.find("icone-errorconta");
                    $A.util.toggleClass(icone, "slds-hide");
					component.set("v.serasa", 'Pessoa não é PEP.');
                    var serasa = component.find("icone-errorserasa");
                    var serasa2 = component.find("icone-erroserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
					
					//Ajuste
					var iconePEP = component.find("icone-sucessoPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", ret.PEP);
					//Ajuste

                    $A.get('e.force:refreshView').fire();
                }//Ajuste  Fim
				 else
                {	
					console.log('Entrou Else ');
                    component.set("v.sucesso", ' Dados bancários válidos');
                    var icone = component.find("icone-sucesso");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.bloqueio", ' Dados bancários do beneficiário validados');
                    var icone = component.find("icone-sucessoconta");
                    $A.util.toggleClass(icone, "slds-hide");
                    component.set("v.serasa", 'Erro na integração, verifique com um administrador.');
                    var serasa = component.find("icone-errorserasa");
                    var serasa2 = component.find("icone-erroserasacheque");
                    $A.util.toggleClass(serasa, "slds-hide");
                    $A.util.toggleClass(serasa2, "slds-hide");
                    
					//Ajuste
					var iconePEP = component.find("icone-sucessoPEP");
                    $A.util.toggleClass(iconePEP, "slds-hide");
					component.set("v.pep", ret.PEP);
					//Ajuste

					$A.get('e.force:refreshView').fire();
                }
				
                	helper.toggleSpinner(component);
                    var loads = component.find("loads");
                    var footer = component.find("footer");
                    var header = component.find("header");
                    $A.util.removeClass(loads, "slds-hide");
                    $A.util.addClass(loads, "slds-show");
                    $A.util.removeClass(footer, "slds-hide");
                    $A.util.addClass(footer, "slds-show");
                	$A.util.removeClass(header, "slds-hide");
                    $A.util.addClass(header, "slds-show"); 

            } else {
                console.log('ret');
                console.log(ret);
                
                console.log('Error, response state: ' + state);
                        
                 	component.set("v.serasa", 'Erro na integração, verifique com um administrador.');
                    var serasa4 = component.find("icone-errorserasa");
                    var serasa5 = component.find("icone-erroserasacheque");
                    $A.util.toggleClass(serasa4, "slds-hide");
                    $A.util.toggleClass(serasa5, "slds-hide");
                    $A.get('e.force:refreshView').fire();
                
                	helper.toggleSpinner(component);
                    var loads = component.find("loads");
                    var footer = component.find("footer");
                    var header = component.find("header");
                    $A.util.removeClass(loads, "slds-hide");
                    $A.util.addClass(loads, "slds-show");
                    $A.util.removeClass(footer, "slds-hide");
                    $A.util.addClass(footer, "slds-show");
                	$A.util.removeClass(header, "slds-hide");
                    $A.util.addClass(header, "slds-show");
                }
            
        });

        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },
    
    verifica : function(component, event, helper, recId) {
        var action = component.get('c.verificastatus');
        		action.setParams({recordId: recId});
            
        // Configure response handler
        action.setCallback(verifica, function(response) 
        {
            var state = response.getState();
            if (state === 'SUCCESS') {
				var ret = response.getReturnValue();
            }else
            {
                var ret = response.getReturnValue();
            }
        }
        

            )        
      
	},

    RemoveCSS: function(component, event, helper) {
        var cmpTarget = component.find('MainDiv');
        $A.util.removeClass(cmpTarget, 'slds-modal__container');
    }, 
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Mode is pester ,duration is 5sec and this is normal Message',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    verifica : function(component, event, helper, recId) {
        var action = component.get('c.verificastatus');
        		action.setParams({recordId: recId});
            
        // Configure response handler
        action.setCallback(verifica, function(response) 
        {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var ret = response.getReturnValue();
            }else
            {
                var ret = response.getReturnValue();
            }
        }
                          )        
	},
    
    toggleSpinner : function(component){
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})