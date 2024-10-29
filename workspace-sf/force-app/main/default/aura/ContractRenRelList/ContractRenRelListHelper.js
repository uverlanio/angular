({
	loadRelContracts : function(cmp) {        
		 var recordId = cmp.get('v.recordId');		 
		 var action = cmp.get("c.getContracts");
		 action.setParams({idCTR:recordId});
		 var actionName = cmp.get("c.getContractName");
		 actionName.setParams({idCTR:recordId});
		 
		 action.setCallback(this, function(response) {
			 var state = response.getState();
			 if (state === "SUCCESS") {				
				var rows = response.getReturnValue();               
                for ( var i = 0; i < rows.length; i++ ) {                   
                    var row = rows[i];                   
                    if (row.Account) {
                        row.AccountName = row.Account.Name;
                    }
					if (row.FormaPagamento__r) {
                        row.FormaPagamento = row.FormaPagamento__r.Codigo__c + '-' + row.FormaPagamento__r.Name;
                    }
					row.LinkContract = '/' + row.Id;
					row.LinkAccount = '/' + row.Account.Id;
					row.CurrencyCode = row.CurrencyIsoCode;
                }               
                cmp.set("v.contractList", rows);
				cmp.set("v.contracts", rows);				
				this.updateTotal(cmp);
			}            
		 });
		  $A.enqueueAction(action);

		  actionName.setCallback(this, function(responseName) {
			var stateName = responseName.getState();
			if (stateName === "SUCCESS") {			
				var rowsName = responseName.getReturnValue();               
                for ( var i = 0; i < rowsName.length; i++ ) {    					               
                    var rowName = rowsName[i];                   					
                    cmp.set("v.contractName", rowName.Name);
                }				 				   			   
		    }            
		});
		 $A.enqueueAction(actionName);
	 },
	  
	 updateTotal: function(cmp) {
	   var contracts = cmp.get("v.contracts");
	   cmp.set("v.totalContracts", contracts.length);
	 },

	 sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.contracts");        
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
         
        data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            });
        component.set("v.contracts",data);
    }
 })