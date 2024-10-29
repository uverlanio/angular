({
	    init: function (cmp, event, helper) {
	        var queryTerm = '';
	        helper.pesquisaGarantias(cmp,event, helper, queryTerm);
	        helper.buscaNomePagamentoGarantia(cmp, event, helper);
	    },

	    handleOnChange: function(component, event, helper){
	    	var queryTerm = component.get('v.search');
	    	helper.pesquisaGarantias(component,event,helper,queryTerm);
	    },

	    voltarBox: function (component) {
       		$A.get("e.force:closeQuickAction").fire();
    	},

    	updatePagamento: function(component, event, helper){
    		var element = event.currentTarget;
    		var index = element.dataset.index;
    		var data = component.get('v.data');
    		var record = data[index];
    		console.log(record);

    		helper.updatePag(component,event,helper,record);



    	}

})