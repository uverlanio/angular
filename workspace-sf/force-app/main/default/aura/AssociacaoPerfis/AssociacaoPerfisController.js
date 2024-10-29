({
	//Inicializa componente
	inicializar : function(component, event, helper) {
		helper.inicializar(component, event);
		// helper.recuperarBancosInformacaoBancaria(component, event);
	},

	//Adiciona novo item para ser inserido
	adicionarNovo : function(component, event, helper) {
		helper.adicionarNovo(component, event);	
	},

	//Salva os registros criados/editados
	salvar : function(component, event, helper) {
		helper.salvar(component, event);
	},

	//Fecha popup
	cancelar: function(component, event, helper) {
		helper.cancelar(component, event);
	}
})