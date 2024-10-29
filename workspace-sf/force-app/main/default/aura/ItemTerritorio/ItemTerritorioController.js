({
	//Inicializa componente
	inicializar : function(component, event, helper) {
		helper.gerarEventoBuscaPais(component, event);
		helper.gerarEventoBuscaMunicipio(component, event);
		helper.habilitarCombosDependentes(component, true);
	},

	//Exibe combos de acordo com o tipo escolhido
	habilitarCombos : function(component, event, helper) {
		helper.habilitarCombos(component, event);
	},

	//Exclui um territorio
	excluirItemTerritorio : function(component, event, helper) {
		helper.excluirItemTerritorio(component, event);
	}
})