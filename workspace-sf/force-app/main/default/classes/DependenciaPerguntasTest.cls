@isTest
private class DependenciaPerguntasTest {
	
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        dadosBuscarPerguntasQuestionario2();
	}

    @isTest
    public static void dadosBuscarPerguntasQuestionario2(){
    	
		// PLV-2542 INICIO
    	Pergunta__c pergunta = new Pergunta__c(
                Pergunta__c = 'Qual a data de hoje',
                TipoResposta__c = 'Opção',
                OpcoesResposta__c = 'Sim;Não'
        );
		// PLV-2542 FIM

        insert pergunta;
    	Questionario__c questionario = TestDataFactory.gerarQuestionario();
    	PerguntaQuestionario__c perguntaQuestionario = new PerguntaQuestionario__c(
                Pergunta__c = pergunta.Id,
                Questionario__c = questionario.Id,
                Numero__c = 1,
                PerguntasOpcao__c = 'Sim;Não'
        );

        insert perguntaQuestionario;

    	String retorno = DependenciaPerguntasController.buscarPerguntasQuestionario2(perguntaQuestionario.Id);

    	DependenciaPerguntasController.OpcaoTO opcao = new DependenciaPerguntasController.OpcaoTO();
    	opcao.etiquetaOpcao = '1';
    	opcao.valorOpcao = 'Sim';
    	opcao.perguntaSelecionada = '1';
    	opcao.idx = 1;

    	String jsonEnvio = '[' + JSON.serialize(opcao) + ']';
    	System.debug(jsonEnvio);
    	String idPerguntaQuestionario = String.valueOf(perguntaQuestionario.Id);

    	DependenciaPerguntasController.atualizarDados(jsonEnvio, idPerguntaQuestionario);

    	System.assertEquals(true, (retorno.length() > 0));
    }
	
}