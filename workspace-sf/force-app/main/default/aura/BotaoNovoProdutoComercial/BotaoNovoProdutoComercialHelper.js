({
	gerarNovoProdutoComercial : function(component) {		
		let action = component.get('c.gerarNovoProdutoComercial');
		action.setParams({
			idProduto : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			component.find("cmpModalAcaoBotao").callback(response);
		});

		$A.enqueueAction(action);
	}
})