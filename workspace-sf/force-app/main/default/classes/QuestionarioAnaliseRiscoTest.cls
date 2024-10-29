/**
 * Created by Alessandro Ponte on 28/06/2018.
 */

@IsTest
private class QuestionarioAnaliseRiscoTest {

  // @TestSetup
  // static void testSetup(){
  //   TestDataFactory.gerarDadosSetup();
  //   TestDataFactory.gerarProposta();
  // }

  // @IsTest
  // static void testBuscarListVidaProposta() {

  //   Quote proposta = [SELECT Id FROM Quote];

  //   Test.startTest();    
  //   List<SeguradoProposta__c> listVidaProposta = QuestionarioAnaliseRiscoController.buscarListVidaProposta(proposta.Id); 
  //   System.assert(listVidaProposta.size() > 0);    
  //   Test.stopTest();
  // }

  // @IsTest
  // static void testBuscarPerguntas(){
  //   Quote proposta = [SELECT Id FROM Quote];

  //   Test.startTest();
  //   String listPerguntasQuestionarioString = QuestionarioAnaliseRiscoController.buscarPerguntas(proposta.Id);
  //   List<QuestionarioAnaliseRiscoController.WrapperQuestionario> listWrapperQuestionario = (List<QuestionarioAnaliseRiscoController.WrapperQuestionario>) JSON.deserialize(listPerguntasQuestionarioString, List<QuestionarioAnaliseRiscoController.WrapperQuestionario>.class);

  //   System.assert(listWrapperQuestionario.size() > 0);

  //   Test.stopTest();
  // }

  // @IsTest
  // static void testSalvarRespostaQuestionario(){
  //   PerguntaQuestionario__c perguntaQuestionario = [SELECT Id FROM PerguntaQuestionario__c WHERE Pergunta__r.TipoResposta__c = 'Data'];    
  //   SeguradoProposta__c vidaProposta = [SELECT Id FROM SeguradoProposta__c];
  //   RespostaQuestionario__c respostaQuestionario = new RespostaQuestionario__c(
  //       PerguntaQuestionario__c = perguntaQuestionario.Id,
  //       SeguradoProposta__c = vidaProposta.Id,
  //       Resposta__c = String.valueOf(System.today()),
  //       Status__c = 'Aberto'
  //   );

  //   Test.startTest();
  //   List<RespostaQuestionario__c> listRespostaQuestionarios = QuestionarioAnaliseRiscoController.salvarRespostaQuestionario(new List<RespostaQuestionario__c>{respostaQuestionario});
  //   System.assert(listRespostaQuestionarios.size() > 0);
  //   System.assert(listRespostaQuestionarios[0].Id != null);

  //   Test.stopTest();
  // }
}