({
	inicializar : function(component, event, helper) {
		helper.buscarCamposProduto(component, event);
		//helper.buscarCamposProdutoConta(component, event);
	},

	salvar : function(component, event, helper) {
        document.getElementById('btnSubmit').click();
	},	

	// teste : function(component, event, helper) {
	// 	console.log('TESTE');
	// 	document.getElementById('btnSubmit').click();
	// },	

    onSubmit  : function(component, event, helper) {
     	helper.validarCamposObrigatorios(component, event);
    },

	fireRefreshView : function(component, event, helper) {
		$A.get('e.force:refreshView').fire();
    }
})