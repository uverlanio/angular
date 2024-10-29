({
	gerarBaseProdutosOpin : function(component) {		
		let action = component.get('c.gerarBaseProdutosOpin');
		action.setParams({});
		/*action.setParams({
			idProduto : component.get('v.recordId')
		});
*/
		action.setCallback(this, function(response){
			console.log('response: ' + response);
			component.find("cmpModalAcaoBotao").callback(response);
		});

		$A.enqueueAction(action);
	}
})