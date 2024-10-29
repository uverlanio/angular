({
	inicializar : function(component, event, helper) {
		helper.gerarComboRamos(component, event);
	},

	salvar : function(component, event, helper) {
		helper.salvar(component, event);
	},

	cancelar : function(component, event, helper) {
		helper.cancelar(component, event);
	}
})