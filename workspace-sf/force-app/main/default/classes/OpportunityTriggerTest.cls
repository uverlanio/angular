//PLV-2286 - INICIO - ACIONAMENTO MÉTODO VALIDAR TRIGGERS
@isTest
public class OpportunityTriggerTest {

  @isTest
  private static void testEmissaoOrcamentoMassificados()
  {
      TestDataFactory.gerarDadosSetup();
      Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);
      Opportunity opportunity = (Opportunity) TestDataFactory.pegarRegistro(mapListObject, 'Opportunity');
      
      //insert opportunity;
      opportunity.CloseDate = System.today().addDays(30);
      update opportunity;
      System.assertEquals(true, (opportunity != null));
  }
}
//PLV-2286 - FIM - ACIONAMENTO MÉTODO VALIDAR TRIGGERS