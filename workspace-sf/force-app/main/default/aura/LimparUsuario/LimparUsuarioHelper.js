({
	Init: function (component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.Inicializar");

        action.setCallback(this, function (a) {
			let retorno = a.getReturnValue();
            component.set("v.retorno", retorno);
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
	apagar: function (component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.apagarItens");
        action.setParams({
            retorno:JSON.stringify(component.get('v.retorno'))
        });
        action.setCallback(this, function (a) {
			let retorno = a.getReturnValue();

            component.set("v.retorno", retorno);
            component.set("v.resultadoMensagem", retorno.resultadoMensagem);
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
})