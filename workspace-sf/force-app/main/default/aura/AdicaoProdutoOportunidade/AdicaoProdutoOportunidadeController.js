({
	inicializar: function(component, event, helper) {
		helper.buscarProdutosOferta(component, event);
	},
	avancar: function(component, event, helper) {
		helper.avancar(component, event);
	},
	cancelar: function(component, event, helper) {
		helper.cancelar(component, event);	
	},	
	voltar: function(component, event, helper) {
		helper.voltar(component, event);	
	},
	salvar: function(component, event, helper) {
		helper.salvar(component, event);	
	}
})