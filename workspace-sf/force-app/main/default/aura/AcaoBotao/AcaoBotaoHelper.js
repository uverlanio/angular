({
	callbackAcaoBotao: function(component, response){
		// Busca os dados do retorno
		let state = response.getState();

		console.log('state: ' + state);
		
		if(component.isValid() && state === 'SUCCESS') 
		{
			component.get('v.responseString')

			let retornoController = JSON.parse(response.getReturnValue());
			let titulo = '';
			let mensagem = '';

			retornoController.mensagens.forEach(element => { 
				mensagem += '\r > ' + element ; 
			});

			if(retornoController.tipo != 'error')
			{
				if(retornoController.tipo == 'success')
				{
					titulo = 'Sucesso!';
					$A.get('e.force:refreshView').fire();
				}
				else
					titulo = 'Erro!';

				// Preenche a mensagem de exibição
				this.exibirToast(retornoController.tipo, titulo, mensagem);

				if(!retornoController.linkRedirecionar)
				{
					this.fecharModal();
				}
				else
				{
					let navEvt = $A.get("e.force:navigateToSObject");
				    navEvt.setParams({
				      "recordId": retornoController.linkRedirecionar,
				      "slideDevName": "related"
				    });
				    navEvt.fire();
				}		
			}
			else 
			{
				$A.util.removeClass(component.find("contentModal"), "slds-hide"); 
				let verSpinner = component.get("v.spinnerAberto");
				if(verSpinner){
					this.toggleSpinner(component);
				}
				component.set('v.detalhesErro', mensagem);
			}
		}
		else 
		{
			this.exibirToast('error', 'Erro!', response.error[1]);
		}

	},
	exibirToast: function(tipo, titulo, mensagem)
	{
		let toast = $A.get('e.force:showToast');
		toast.setParams({
			'title': titulo,
			'mode' :'sticky',
			'message': mensagem,
			'type': tipo
		});
		toast.fire();
	},
	fecharModal: function()
	{
		$A.get("e.force:closeQuickAction").fire();
	},
	toggleSpinner : function (component)
	{
		let spinner = component.find("mySpinner");
		$A.util.toggleClass(spinner, "slds-hide");
	}
})