({
	abrirPDF : function(component, event) {
		var action = component.get("c.getPropostaName");
		var propostaName = "";
		action.setParams({
			recordId: component.get('v.recordId')
		});

		action.setCallback(this, (response) => {
			var state = response.getState();
			
			if(state == "SUCCESS"){
				let pageReference = {
					type: 'standard__webPage',
					attributes: {
						url: '/apex/PropostaIndividual?numProposta=' + response.getReturnValue()  
					},
		
				};
		
				var navService = component.find("navService");
				navService.generateUrl(pageReference)
					.then($A.getCallback(function(url) {
						console.log(url);
						navService.navigate(pageReference);
		
		
					}), $A.getCallback(function(error) {
						console.log(error); 
					}));
			}else if(state == "ERROR"){
				console.log(response.getError());
			}
		});
				
		$A.enqueueAction(action);
	}
})