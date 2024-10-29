({
	doInit : function(component, event, helper) {
        helper.consultainfos(component,event,helper);
        helper.verificafases(component,event,helper);
	},
    
    clickbutton : function(component, event, helper) {
		helper.solicitapagamentos(component,event,helper);
        component.set("v.Likedisable",true);
 	},

 	confirmardata : function(component, event, helper){
 		helper.confirmardataa(component,event,helper);
 	},

    voltarBox: function (component) {
       $A.get("e.force:closeQuickAction").fire();
    } 

})