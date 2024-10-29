({
    doInit : function(component, event, helper) {  		
		component.set('v.columns', [
			{label: 'Contrato', fieldName: 'LinkContract', type: 'url', sortable :true, typeAttributes: {label: { fieldName: 'Name' }, targe: '_self'}},
			{label: 'Nome', fieldName: 'LinkAccount', type: 'url', sortable :true, typeAttributes: {label: { fieldName: 'AccountName' }, targe: '_self'}},
			{label: 'Início de vigência', fieldName: 'StartDate', sortable :true, type: 'date'},
			{label: 'Final de vigência', fieldName: 'VigenciaFinal__c', sortable :true, type: 'date'},
			{label: 'Prêmio Total', fieldName: 'PremioTotal__c', sortable :true, type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: 'code' },  cellAttributes: { alignment: 'left' }},
			{label: 'Forma Pagamento', fieldName: 'FormaPagamento', sortable :true, type: 'text'}
		]);        
        helper.loadRelContracts(component);		
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

	handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");   
        var sortDirection = event.getParam("sortDirection");   
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);         
        helper.sortData(component,sortBy,sortDirection);
    }
})