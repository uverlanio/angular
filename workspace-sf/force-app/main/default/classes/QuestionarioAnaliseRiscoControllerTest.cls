@isTest
private class QuestionarioAnaliseRiscoControllerTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
		// PLV-2312-28 INICIO
		TestDataFactory.gerarProposta(true);
		// PLV-2312-28 FIM
	}

	@isTest
	static void testarServicoSugestao() {
		Quote proposta = [SELECT Id FROM Quote LIMIT 1];

		//Atualiza questionario
		QuestionarioProduto__c questionario = [Select Id From QuestionarioProduto__c Limit 1];
		update questionario;

		//Teste busca segurados proposta
		List<sObject> seguradosProposta = QuestionarioAnaliseRiscoController.buscarListVidaProposta(proposta.Id);
		System.assert(!seguradosProposta.isEmpty());

		//Teste busca perguntas questionario
		String perguntas = QuestionarioAnaliseRiscoController.buscarPerguntas(proposta.Id);	
		System.assert(String.isNotBlank(perguntas));

		//Teste salvar questionario
		RespostaQuestionario__c respostaQuestionario = new RespostaQuestionario__c();
		insert respostaQuestionario;

		List<RespostaQuestionario__c> respostas = QuestionarioAnaliseRiscoController.salvarRespostaQuestionario([SELECT Id FROM RespostaQuestionario__c]);	
		System.assert(!respostas.isEmpty());

	}
}