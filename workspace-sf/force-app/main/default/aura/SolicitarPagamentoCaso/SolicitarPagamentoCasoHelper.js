({
    tipoPagamento : function(component, event, helper){
        var name = 'Tipo_de_Pagamento__c';
        var action = component.get('c.picklistValue');
        action.setParams({fieldName: name, type: true});
        action.setCallback(null, function(callbackResult){
            if(callbackResult.getState() == 'SUCCESS'){
                component.set("v.pagamentos", callbackResult.getReturnValue());
            }else{
                console.log('linea 12 else ReturnValue: ' + callbackResult.getReturnValue());
            }
        });
        $A.enqueueAction( action );
    },
    
    sucursales : function(component, event, helper){
        var name = 'Sucursal_Destino_de_Cheque__c';
        var action = component.get('c.picklistValue');
        action.setParams({fieldName: name, type: false});
        action.setCallback(null, function(callbackResult){
            if(callbackResult.getState() == 'SUCCESS'){
                component.set("v.sucursales", callbackResult.getReturnValue());
            }else{
                console.log('linea 30 else ReturnValue: ' + callbackResult.getReturnValue());
            }
        });
        $A.enqueueAction( action );
    },
    
    verificafases : function(component, event, helper) {
        
        var recId = component.get('v.recordId');
        console.log('linea 39 recId: ' + recId);
        var action = component.get('c.verificafase');
        action.setParams({recordId: recId});
        action.setCallback( null, function(callbackResult) {
            if(callbackResult.getState() == 'SUCCESS') {
                console.log('linea 47 ReturnValue: ' + callbackResult.getReturnValue());
                component.set("v.msg", callbackResult.getReturnValue());
                //$A.get('e.force:refreshView').fire();
                if(callbackResult.getReturnValue() == 'Ok'){                   
                    var sucesso = component.find("sucesso");
                    $A.util.removeClass(sucesso, "slds-hide");
                    $A.util.addClass(sucesso, "slds-show");
                    helper.toggleSpinner(component);
                }else{
                    var erro = component.find("erro");
                    $A.util.removeClass(erro, "slds-hide");
                    $A.util.addClass(erro, "slds-show");
                    helper.toggleSpinner(component);
                }
            }else{
                console.log('linea 62 else ReturnValue: ' + callbackResult.getReturnValue());
                alert('erro');
            }
        });
        
        $A.enqueueAction( action );
    },
    
    consultainfos : function(component,event,helper) { 
        var recId = component.get('v.recordId');
        console.log('linea 72 recId: ' + recId);
        
        var action = component.get('c.consultainfo');
        action.setParams({recordId: recId});
        action.setCallback( null, function(callbackResult) {
            console.log('linea 78 result: ' + callbackResult.getState());
            if(callbackResult.getState() == 'SUCCESS') {
                var retorno = callbackResult.getReturnValue();
                console.log('linea 82 retorno bene: ' , retorno);                
                component.set("v.bene", retorno);
            }else{
                component.set("v.msg", 'Houve um erro na solicitação do pagamento. Por favor procure o administrador do sistema.');
                var erro = component.find("erro");
                var sucesso = component.find("sucesso");
                $A.util.removeClass(erro, "slds-hide");
                $A.util.addClass(erro, "slds-show");
                $A.util.removeClass(sucesso, "slds-show");
                $A.util.addClass(sucesso, "slds-hide");
            }
        });
        
        $A.enqueueAction( action );
    },
    
    atualizarPagamentos: function(component, event, helper){
        var listaBeneficiario = component.get("v.bene");
        var dadosBancarios = component.find("tipoPagamento");
        var sucursal = component.find("sucursal");
        console.log('************************** ' + dadosBancarios);
        console.log('*********listaBeneficiario*************** ' + JSON.stringify(listaBeneficiario));
        if(dadosBancarios !== undefined){
            for(var i = 0; i<listaBeneficiario.length; i++){
               
                var tipoPagamento = '';
                try{
                    tipoPagamento = dadosBancarios[i].get("v.value");
                } catch(e){
                    tipoPagamento = dadosBancarios.get("v.value");
                }
                
                var suc = '';
                if(tipoPagamento == 'Cheque'){
                 	try{
                        suc = sucursal[i].get("v.value");
                    } catch(e){
                        suc = sucursal.get("v.value");
                    }   
                }
                var action = component.get('c.updateTipoPagamento');
                action.setParams({tipoPagamento: tipoPagamento, bene: listaBeneficiario[i], suc: suc});
                action.setCallback( null, function(callbackResult){
                    if(callbackResult.getState() == 'SUCCESS'){
                        console.log('atualizar1: ',callbackResult.getReturnValue());
                    }else{
                        console.error('atualizar2: ',callbackResult.getReturnValue());
                    }
                });
                $A.enqueueAction( action );
            }
        }
    },
    
    solicitapagamentos : function(component,event,helper) { 
        var listaBeneficiario = component.get("v.bene");
        var tipoPagamento = component.find("tipoPagamento");
        var sucursal = component.find("sucursal");
        var banco = [];
        var mapPagamento = new Object();
        var mapSucursal = new Object();
        for(var i = 0; i<listaBeneficiario.length; i++){
            if(listaBeneficiario[i].Informacao_bancaria__c === undefined){
                listaBeneficiario[i].Informacao_bancaria__c = [" "];
            }
            var key = listaBeneficiario[i].Conta__c;
            var pagamento = '';
            try{
                pagamento = tipoPagamento[i].get("v.value");
            }catch(e){
                pagamento = tipoPagamento.get("v.value");
            }
            var suc = '';
            if(pagamento == 'Cheque'){
                try{
                   console.log('sucursal 159');
                    suc = sucursal[i].get("v.value");
                }catch(e){
                    suc = sucursal.get("v.value");
                }               
            }
           
            mapPagamento[key] = pagamento;
            mapSucursal[key] = suc;
            
        }
        
        listaBeneficiario.forEach(function x(item){
            banco.push(item.Informacao_bancaria__c);
        });
        
        var recId = component.get('v.recordId');
        var action = component.get('c.gravapagamento');	
        
        action.setParams({tipoPagamento: mapPagamento, recordId: recId, idBancos: banco.join(';'), sucursal: mapSucursal});
        
        action.setCallback( null, function(callbackResult) {
            var erro;
            if(callbackResult.getState() == 'SUCCESS') {
                if(callbackResult.getReturnValue() != 'OK'){
                    erro = callbackResult.getReturnValue();
                }
                if(callbackResult.getReturnValue() === 'OK'){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Sucesso',
                        message: 'Pagamento Solicitado com sucesso.',
                        messageTemplate: '',
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    
                    toastEvent.fire();
                   $A.get('e.force:refreshView').fire();
                }else{
                    component.set("v.msg", erro);
                    var erro = component.find("erro");
                    var sucesso = component.find("sucesso");
                    $A.util.removeClass(erro, "slds-hide");
                    $A.util.addClass(erro, "slds-show");
                    $A.util.removeClass(sucesso, "slds-show");
                    $A.util.addClass(sucesso, "slds-hide");
                }
            }else{
                
                component.set("v.msg", 'Houve um erro na solicitação do pagamento. Por favor procure o administrador do sistema.');
                var erro = component.find("erro");
                var sucesso = component.find("sucesso");
                $A.util.removeClass(erro, "slds-hide");
                $A.util.addClass(erro, "slds-show");
                $A.util.removeClass(sucesso, "slds-show");
                $A.util.addClass(sucesso, "slds-hide");
            }
            $A.get('e.force:refreshView').fire();   
        });
        
        $A.enqueueAction( action );
    },
    toggleSpinner : function(component){
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})