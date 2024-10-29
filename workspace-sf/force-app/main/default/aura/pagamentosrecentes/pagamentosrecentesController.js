({
	doInit : function(component, event, helper) {
        helper.consultapagamento(component,event,helper);
        
},
    botaoclick : function(component, event, helper) {
      $A.get('e.force:refreshView').fire();
      helper.cancelarpagamento(component,event,helper);
	  helper.consultapagamento(component,event,helper);
},

})