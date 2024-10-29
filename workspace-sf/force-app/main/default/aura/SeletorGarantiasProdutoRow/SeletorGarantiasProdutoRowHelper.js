({
    LimiteGarantiaPicklist : function (component){
        var action = component.get("c.getPickListValuesIntoList");
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('status: ', state);
            if (state === "SUCCESS"){
                component.set("v.LMoeda", a.getReturnValue());
                console.log(a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})