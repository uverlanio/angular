({
	doInit : function(component, event, helper) {
        helper.consultaHistorico(component,event,helper);
	},

	AdicionarSpinner : function(component, event, helper){
		helper.AddSpinner(component,event,helper);
	},

	RemoverSpinner : function(component, event, helper){
		helper.RemoveSpinner(component,event,helper);
	}
})