({
	doInit : function(component, event, helper) {
		//helper.validaserasa(component, event, helper);
		//helper.validacheque(component,event,helper);
        helper.chamarCIVLiquidacao(component,event,helper);
        
	},  

    voltarBox: function (component) {
       $A.get("e.force:closeQuickAction").fire();
    } 
})