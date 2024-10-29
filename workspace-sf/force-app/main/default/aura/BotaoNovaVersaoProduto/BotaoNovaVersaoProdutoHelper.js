({
	gerarNovaVersao : function(component) {		
		let action = component.get('c.gerarNovaVersao');
		action.setParams({
			idProduto : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			component.find("cmpModalAcaoBotao").callback(response);
		});

		$A.enqueueAction(action);
	}
})