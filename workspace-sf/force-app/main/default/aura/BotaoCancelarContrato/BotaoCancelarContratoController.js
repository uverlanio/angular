({
	inicializar : function(component, event, helper) {
		helper.inicializar(component, event, helper); //PLV-4270 - INÍCIO/FIM
	},

	calcular: function (component, event, helper) {
		helper.calcular(component, event, helper);
	},
	//PLV-4678 - Inicio
	/*
	setOferta: function (component, event, helper) {
		helper.setOferta(component, event, helper);
	},*/
	//PLV-4678 - Fim
	
	limparValues: function (component, event, helper) {
		helper.limparValues(component, event, helper);
	},

	salvar : function(component, event, helper) {
		helper.salvar(component, event, helper);
	},

	//Fecha popup
	cancelar: function(component, event, helper) {
		helper.cancelar(component, event);
	}

})