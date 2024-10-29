({
    inicializar : function(component, helper) {
        let mapObject= component.get('v.mapObject');
        let mapKey = component.get('v.mapKey');
        let outputText = component.find("outputTextId");

        outputText.set("v.value", mapObject[mapKey]);
    }
})