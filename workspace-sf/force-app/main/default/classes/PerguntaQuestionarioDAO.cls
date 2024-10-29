/**
 * PerguntaQuestionarioDAO
 * @author Fernando Barcellos @ 20/12/2017
 *
 **/
 public class PerguntaQuestionarioDAO {
 	
 	private static final PerguntaQuestionarioDAO instance = new PerguntaQuestionarioDAO();
 	
 	public static PerguntaQuestionarioDAO getInstance() {
 		return instance;
 	}

 	private PerguntaQuestionarioDAO() { }

 	public PerguntaQuestionario__c buscarPerguntaQuestionario(String idPerguntaQuestionario) {
 		return [
 			SELECT
				Id,
				Name,
				Questionario__c,
				Questionario__r.Name,
				Pergunta__c,
				Pergunta__r.Name,
				Pergunta__r.TipoResposta__c,
				Pergunta__r.OpcoesResposta__c,
				Obrigatorio__c, // PLV-4797 INICIO/FIM SYS4B ODEMIR
				Numero__c,
				ProximaPergunta__c,
				PerguntasOpcao__c
			FROM
				PerguntaQuestionario__c
			WHERE
				Id =: idPerguntaQuestionario
				AND (ProximaPergunta__c = NULL OR ProximaPergunta__c = '')
			LIMIT 1
		];
 	}

 	//public List<PerguntaQuestionario__c> buscarTodasPerguntasQuestionario(String idQuestionario) {
	public List<PerguntaQuestionario__c> buscarTodasPerguntasQuestionario(String idquestionario) { //RVI-138 INICIO-FIM FIX01
 		return [
 			SELECT
 				Id,
 				Name,
 				Questionario__c,
 				Pergunta__c,
 				Pergunta__r.Name,
 				Numero__c,
 				ProximaPergunta__c,
 				PerguntasOpcao__c
 			FROM
 				PerguntaQuestionario__c
 			WHERE
 				//Questionario__c =: idQuestionario 
				Questionario__c =: idquestionario //RVI-138 INICIO-FIM FIX01
 			ORDER BY 
 				Numero__c ASC
 		];
 	}
}