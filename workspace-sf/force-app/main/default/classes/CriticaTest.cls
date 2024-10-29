@isTest
private class CriticaTest
{
  @testSetup
  static void setup()
  {
    TestDataFactory.gerarDadosSetup();
    // PLV-2312-28 INICIO
    Map<String,List<SObject>> mapListObject = TestDataFactory.gerarOrcamento(false);
    // PLV-2312-28 FIM
  }

  @isTest
  static void atualizarOportunidade()
  {
    //Valida oportunidade com uma critica recusada
    CriticaOrcamento__c critica         = [SELECT Id, Status__c, Orcamento__c FROM CriticaOrcamento__c LIMIT 1];
    Opportunity         oportunidade    = [SELECT Id, StageName FROM Opportunity WHERE Id =: critica.Orcamento__c LIMIT 1];

    //Valida oportunidade com 2 criticas liberadas

    oportunidade.StageName = 'Disponível para contratação';

    Test.startTest();

    update oportunidade;
    System.assertEquals('Disponível para contratação', oportunidade.StageName);

    Test.stopTest();

    critica.Status__c           = 'Recusado';
    critica.Justificativa__c    = 'foi recusada';

    update critica;

    oportunidade = [SELECT Id, StageName FROM Opportunity WHERE Id =: critica.Orcamento__c LIMIT 1];

    System.assertEquals('Recusado', oportunidade.StageName);
  }
}