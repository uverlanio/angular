({
	verificafases : function(component,event,helper) {
		var recId = component.get('v.recordId');
        console.log('recId');
        console.log(recId);
        
        var action = component.get('c.verificafase');
        action.setParams({recordId: recId});
        
    	action.setCallback( null, function(callbackResult) {
        	console.log(callbackResult.getState());
            
        if(callbackResult.getState()=='SUCCESS') {
            console.log(callbackResult.getReturnValue());
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
            console.log(callbackResult.getReturnValue());
           alert('erro');
        }
    });

    $A.enqueueAction( action );
	},

    
	consultainfos : function(component,event,helper) { 
        var recId = component.get('v.recordId');
        console.log('recId');
        console.log(recId);
        
        var action = component.get('c.consultainfo');
    	action.setParams({recordId: recId});
        
		action.setCallback( null, function(callbackResult) {
        	console.log(callbackResult.getState());
            
        if(callbackResult.getState()=='SUCCESS') {
            var retorno = callbackResult.getReturnValue();
            var valorLiberado = retorno[0].ValorIndenizado__c * (retorno[0].PercentualLiberados__c / 100);
            component.set("v.percValorIndenizado", valorLiberado);
			component.set("v.casos", retorno);
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
    
    solicitapagamentos : function(component,event,helper) { 
        
        //var dataprogramada = component.find("dataprog").get("v.value");
        //var valorcomplemento = parseFloat(component.find("valorcompl").get("v.value"));
        //console.log(valorcomplemento);
        //var valorcapital = parseFloat(component.find("valorpagam").get("v.value"));
        //console.log(valorcapital);
        var valorpagamento = component.find("valorpagam").get("v.value");
        console.log(valorpagamento);
 		var recId = component.get('v.recordId');
        
        //console.log(dataprogramada + ' '+valorpagamento + ' '+recId);
        
        var action = component.get('c.gravapagamento');
        action.setParams({recordId: recId, /*dataprogramada : dataprogramada,*/ valorpagamento : valorpagamento});
        
		action.setCallback( null, function(callbackResult) {

        if(callbackResult.getState()=='SUCCESS') {
            
            if(callbackResult.getReturnValue() != 'OK'){
                var lessdate = callbackResult.getReturnValue();
                if(lessdate == 'ERRO'){
                    var lstlessdate = 0;
                }else{
                    var lstlessdate = JSON.parse(lessdate);
                }
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
                
                //helper.atualizaregistros(component,event,helper,recId,valorpagamento);
                $A.get('e.force:refreshView').fire();
            }else if(lstlessdate.length > 0){
                function addDays(atual, daysToAdd) {
                    var date = new Date(atual.valueOf());
                    date.setDate(date.getDate() + daysToAdd);
                    return date;
                }
                var todayplustwo = new Date();
                    todayplustwo = addDays(todayplustwo,2);
                var dd = String(todayplustwo.getDate()).padStart(2, '0');
                var mm = String(todayplustwo.getMonth() + 1).padStart(2, '0');
                var yyyy = todayplustwo.getFullYear();
                todayplustwo = dd + '/' + mm + '/' + yyyy;

                var nameBenef = "";
                var idBenef = "";
                var i;
                for(i=0;i<lstlessdate.length;i++){
                    nameBenef += '"'+lstlessdate[i].Name+'", ';
                    idBenef += lstlessdate[i].Id+' ';
                    i = i;
                }
                var nameBenef = nameBenef.substring(0, nameBenef.length-2);

                if(i==1){
                    component.set("v.msg", 'O Beneficiário '+ nameBenef +' possue sua data Programada de Pagamento inferior a (D+2). Deseja alterar a data programada de pagamento para '+ todayplustwo +' ?');
                }else{
                    component.set("v.msg", 'Os Beneficiários '+ nameBenef +' possuem sua data Programada de Pagamento inferior a (D+2). Deseja alterar a data programada de pagamento para '+ todayplustwo +' ?');
                }
                component.set("v.idBenef", idBenef);
                var lessdays = component.find("lessdays");
                var sucesso = component.find("sucesso");
                $A.util.removeClass(lessdays, "slds-hide");
                $A.util.addClass(lessdays, "slds-show");
                $A.util.removeClass(sucesso, "slds-show");
                $A.util.addClass(sucesso, "slds-hide");

            }else{
                component.set("v.msg", 'Houve um erro na solicitação do pagamento. Por favor procure o administrador do sistema.');
                var erro = component.find("erro");
                var sucesso = component.find("sucesso");
                $A.util.removeClass(erro, "slds-hide");
                $A.util.addClass(erro, "slds-show");
                $A.util.removeClass(sucesso, "slds-show");
                $A.util.addClass(sucesso, "slds-hide");
            }
        }else{
            console.log('ERRO');
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
    
    confirmardataa : function(component,event,helper){
        var recId = component.get('v.recordId');
        var idBenef = component.get('v.idBenef');

        var action = component.get('c.salvadataBenef');
        action.setParams({recordId: recId, cidBenef : idBenef});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                
                this.solicitapagamentos(component,event,helper);
                
            }else {
                console.log('Error, response state: ' + state);
                component.set("v.msg", 'Houve um erro na solicitação do pagamento. Por favor procure o administrador do sistema.');
                var erro = component.find("erro");
                var lessdays = component.find("lessdays");
                $A.util.removeClass(erro, "slds-hide");
                $A.util.addClass(erro, "slds-show");
                $A.util.removeClass(lessdays, "slds-show");
                $A.util.addClass(lessdays, "slds-hide");
            }
        });
        $A.enqueueAction(action);
    },

    atualizaregistros : function(component,event,helper,recId,valorpagamento) { 
        
        //console.log('dataprogramada');
        //console.log(dataprogramada);
        
        console.log('valorpagamento');
        console.log(valorpagamento);
            
        var action = component.get('c.atualizaregistro');
            action.setParams({recordId: recId, 
                              /*dataprogramada : dataprogramada,*/ 
                              valorpagamento : valorpagamento});
            
            action.setCallback( this, function(callbackResult) {
                console.log('callbackResult.getState()');
                console.log(callbackResult.getState());
                
            if(callbackResult.getState()=='SUCCESS') {
                console.log('callbackResult.getReturnValue()2');
                console.log(callbackResult.getReturnValue());
                $A.get('e.force:refreshView').fire();
            }else{
               alert('Erro');
            }
        });
    
       $A.enqueueAction( action );
	},

    toggleSpinner : function(component){
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})