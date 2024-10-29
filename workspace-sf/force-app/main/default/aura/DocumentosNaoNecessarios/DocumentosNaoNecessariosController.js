({
	inicializar : function(component, event, helper) {
		helper.carregarProdutoCanal(component, event);
	},

	salvar : function(component, event, helper) {
		helper.salvar(component, event);
	},

	cancelar : function(component, event, helper) {
		helper.cancelar();
	}
})