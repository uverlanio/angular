({
	inicializar: function(component, event, helper) {
		helper.inicializar(component, event);
	},
	excluirOpcao: function(component, event, helper) {
		helper.excluirOpcao(component, event);
	},
	salvarOpcoes: function(component, event, helper) {
		helper.salvarOpcoes(component, event);
	},
	buscarOpcoesResposta: function(component, event, helper) {
		helper.buscarOpcoesResposta(component, event);
	},
	buscarPerguntasQuestionario: function(component, event, helper) {
		helper.buscarPerguntasQuestionario(component, event);
	},
	atualizarPerguntaEscolhida: function (component, event) {
		console.log('selectedOptionValue: ' + event.getParam("value"));
	}
})