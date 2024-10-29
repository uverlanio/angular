({
	inicializar : function(component, event, helper) {
		$A.util.addClass(component.find("contentModal"), "slds-hide");
	},
	callbackAcaoBotao: function(component, event, helper){
		helper.callbackAcaoBotao(component, event.getParam('arguments').response);
	},
	fechar :function(component, event, helper) {
		helper.fecharModal();
	}
})