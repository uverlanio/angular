({
   loadContracts : function(cmp) {        
        var recordId = cmp.get('v.recordId');
        var action = cmp.get("c.getContracts");
        action.setParams({idCTR:recordId});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.contracts", response.getReturnValue());
                cmp.set("v.contractList", response.getReturnValue());
                this.updateTotal(cmp);
            }            
        });
         $A.enqueueAction(action);
    },
     
    updateTotal: function(cmp) {
      var contracts = cmp.get("v.contracts");
      cmp.set("v.totalContracts", contracts.length);
    }
})