({
	doInit : function(component, event, helper) {
        helper.tipoPagamento(component,event,helper);
        helper.sucursales(component,event,helper);
        helper.verificafases(component,event,helper);
        helper.consultainfos(component,event,helper);
	},
    
    clickbutton : function(component, event, helper) {
		helper.solicitapagamentos(component,event,helper);
        helper.atualizarPagamentos(component, event, helper);
        
 	},


    voltarBox: function (component) {
       $A.get("e.force:closeQuickAction").fire();
    }
    
    

})