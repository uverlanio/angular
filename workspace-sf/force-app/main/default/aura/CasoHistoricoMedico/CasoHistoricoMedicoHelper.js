({
	consultaHistorico : function(component, event, helper) {
        var recId = component.get('v.recordId');
        var action = component.get('c.consultaHistorico');
        action.setParams({recordId: recId});
    
    	action.setCallback(this , function(response) {
    	var state = response.getState();
    	console.log('TF: '+state);
        if(state === 'SUCCESS') {
			var ret = response.getReturnValue();

			console.log('TF: ');
			console.log(ret);

			component.set("v.listadados", ret);

        }else{
           alert('erro de conexão');
        }
    });

    $A.enqueueAction(action);
	},

	AddSpinner : function(component){
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },

	RemoveSpinner : function(component){
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
    }
})