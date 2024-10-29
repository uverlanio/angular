({
    doInit : function(component, event, helper) {          
        helper.loadContracts(component);
    },
    
    handleSelect : function(component, event, helper) {
        var contracts = component.get("v.contracts");
        var contractList = component.get("v.contractList");        
        var selected = event.getSource().get("v.value");    
        var filter = [];
        var k = 0;
        for (var i=0; i<contractList.length; i++){
            var c = contractList[i];
            if (selected != "All"){
                if(c.LeadSource == selected) {
                    filter[k] = c;
                    k++; 
                }
            }
            else {
                   filter = contractList;
            }       
        }        
        component.set("v.contracts", filter);
        helper.updateTotal(component);
    },

    navigateToMyComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ContractRenRelList",
            componentAttributes: {
                recordId : component.get("v.recordId")                
            }
        });
        evt.fire();
    }
})