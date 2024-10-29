({
	handleRecordUpdated : function(component, event, helper) {
		
		var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
        	var serasa = component.get('v.beneficiario.ConsultaManualSerasa__c');
        	component.set('v.flag', serasa);
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
	},

	salvar : function(component, event, helper) {

		component.set('v.beneficiario.ConsultaManualSerasa__c', true);
		//var registro = component.get('v.beneficiario.ConsultaManualSerasa__c');
		var recordData = component.find('recordLoader');
		recordData.saveRecord($A.getCallback(function(saveResult) {

            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {

           		//toast
           		var resultsToast = $A.get("e.force:showToast");
                    
                resultsToast.setParams({
					"title": "Sucesso",
                    "message": "Beneficiário atualizado com sucesso."
                });

                resultsToast.fire();

                component.set('v.flag', true);

            }else if (saveResult.state === "INCOMPLETE" || saveResult.state === "ERROR") {

                //toast
                var resultsToast = $A.get("e.force:showToast");
                    
                resultsToast.setParams({
                    "title": "ERRO",
                    "message": "Não foi possível atualizar o Beneficiário. Procure um administrador do sistema."
                });

                resultsToast.fire();

            }

        }));
	},

	desmarcar : function(component, event, helper) {

		component.set('v.beneficiario.ConsultaManualSerasa__c', false);
		//var registro = component.get('v.beneficiario.ConsultaManualSerasa__c');
		var recordData = component.find('recordLoader');
		recordData.saveRecord($A.getCallback(function(saveResult) {

            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {

           		//toast
           		var resultsToast = $A.get("e.force:showToast");
                    
                resultsToast.setParams({
					"title": "SUCESSO",
                    "message": "Beneficiário atualizado com sucesso."
                });

                resultsToast.fire();

                component.set('v.flag', false);

            }else if (saveResult.state === "INCOMPLETE" || saveResult.state === "ERROR") {

                //toast
                var resultsToast = $A.get("e.force:showToast");
                    
                resultsToast.setParams({
                    "title": "ERRO",
                    "message": "Não foi possível atualizar o Beneficiário. Procure um administrador do sistema."
                });

                resultsToast.fire();

            }

        }));
	},

})