({
    retornaArquivoECM : function(component){
        var recordId = component.get("v.recordId");
        var action = component.get("c.consultarArquivoEcm");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS")
                component.set("v.listaArquivosECM", a.getReturnValue());
            else if (state === "ERROR"){
                var errors = a.getError();
				if (errors){
                    if (errors[0] && errors[0].message){
						 console.error("Error message: " + errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})