({
	inicializar : function(component, event, helper) {
		helper.carregarListaFiltrada(component, event);
	},	

	escolherProduto : function(component, event, helper) {
		helper.escolherProduto(component, event);
	},

	filtrar: function(component, event, helper) {
		helper.filtrar(component, event);
	}
})