({
	//Gera a combo de ramos de seguros
	gerarComboRamos : function(component, event) {
		let action = component.get("c.buscarRamosSeguro");

		action.setParams({
			garantiaId: component.get("v.garantiaProduto.Garantia__c")
		});

        action.setCallback(this, (response) => {
            let state = response.getState();
            
            if(state == "SUCCESS"){            	
            	component.set("v.ramos", JSON.parse(response.getReturnValue()));
            } else if(state == "ERROR"){
            	console.log(response.getError());
                alert('Error in calling server side action: ' + response.getError());
            }
        });
       
        $A.enqueueAction(action);
	},

	//Salva os dados
	salvar : function(component, event) {
		//Valida ramo escolhido
		if( component.find("cboRamo").get('v.value') != null){
			component.find('registroGarantiaProduto').saveRecord($A.getCallback(function(saveResult) {
				if (saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT') {
					$A.get('e.force:refreshView').fire();
					$A.get("e.force:closeQuickAction").fire();
				}
				else if (saveResult.state === 'INCOMPLETE') {
					console.log('Usuário offline.');
				}
				else if (saveResult.state === 'ERROR') {
					console.log('Erro: ' + JSON.stringify(saveResult.error));
					alert(saveResult.error[0].message + '\r\nPor favor informe o administrador.');
				}
				else {
					console.log('Problema desconhecido: ' + saveResult.state + ', erro: ' + JSON.stringify(saveResult.error));
				}
			}));
		}else{
			alert('Por favor, escolha um ramo de seguro');
		}
	},

	cancelar : function(component, event) {
		$A.get("e.force:closeQuickAction").fire();
	}
})