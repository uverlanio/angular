({
	inicializar : function(component, event, helper) {
		console.log('inicializar aba garantias');
		helper.buscarGarantias(component, event);
	},

	selecionarGrupo : function(component, event, helper) {
    	helper.limparVidaLookup(component,event,'lookupVida');
		helper.selecionarGrupo(component, event);
	},	

	escolherGarantia : function(component, event, helper) {
		helper.escolherGarantia(component, event);	
	},

	alterarTipoEdicao: function(component, event, helper) {
    	helper.limparVidaLookup(component,event,'lookupVida');
		helper.alterarTipoEdicao(component, event);
	},

	gerarGarantiasSegurado: function(component, event, helper) {
	    let seguradoEscolhido = event.getParam("recordFound");
	    if(seguradoEscolhido != null) {
	      helper.gerarGarantiasSegurado(component, event, seguradoEscolhido);
    	}
    	else{
    		//helper.limparGrupoVidaSelecionado(event);
    	}
	},

	salvarGarantias : function(component, event, helper) {
		return helper.salvarGarantias(component, event);
	},
})