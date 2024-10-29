({
	inicializar : function(component, event, helper) {
		let iniciarFechado = component.get("v.iniciarFechado");

		if(iniciarFechado){
			helper.toggleSecao(component, event);
		}
	},

    toggle : function(component, event, helper) {
        helper.toggleSecao(component, event);
    }
})