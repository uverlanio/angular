// RVI-223 inicio  
({
    myAction : function(component, event, helper) {
        var recordId = component.get("v.recordId");
    }
})
({
    handleCloseAction : function(c, e, h) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
// RVI-223 fim