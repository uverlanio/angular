({
	gerarProdutosAcordoComercial : function(component) {		
		let action = component.get('c.gerarProdutosAcordoComercial');
		action.setParams({
			idAcordoComercial : component.get('v.recordId')
		});

		action.setCallback(this, function(response){
			component.find("cmpModalAcaoBotao").callback(response);
		});

		$A.enqueueAction(action);
	}
})