/**
 * Testes PerguntaQuestionario__c
 * @author Fernando Barcellos @ 23/01/2018
 *
 **/
@isTest
private class PerguntaQuestionarioTest {
	
	@isTest
	static void test_method() {
		Test.startTest();
		Questionario__c q = new Questionario__c();
		q.Name = 'Q1';
		//PLV-2771 - Codigo removido devido a exclusão do campo
		insert q;

		Pergunta__c p = new Pergunta__c();
    	// PLV-2542 INICIO
		p.Pergunta__c = 'P1';
		// PLV-2542 FIM
		insert p;

		PerguntaQuestionario__c pq = new PerguntaQuestionario__c();
		pq.Questionario__c = q.Id;
		pq.Numero__c = 1;
		pq.Pergunta__c = p.Id;
		insert pq;

		PerguntaQuestionarioDAO.getInstance().buscarPerguntaQuestionario(pq.Id);
		PerguntaQuestionarioDAO.getInstance().buscarTodasPerguntasQuestionario(q.Id);

		Test.stopTest();
	}
}