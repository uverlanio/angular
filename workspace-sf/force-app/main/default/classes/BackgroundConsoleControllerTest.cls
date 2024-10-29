/**
 * Created by Alessndro Ponte on 08/12/2018.
 */

@IsTest
private class BackgroundConsoleControllerTest {

  @TestSetup
  static void testSetup(){

    TestDataFactory.gerarDadosSetup();
    // PLV-2312-28 INICIO
    TestDataFactory.gerarOrcamento(false);
    // PLV-2312-28 FIM

  }

  @IsTest
  static void testBurcarOportunidadePorRoteamentoId() {
    Roteamento__c roteamento = [SELECT Id, Orcamento__c FROM Roteamento__c LIMIT 1];

    Test.startTest();

    Opportunity orcamento = BackgroundConsoleController.burcarOportunidadePorRoteamentoId(roteamento.Id);

    Test.stopTest();

    System.assert(orcamento != null);
  }

  @IsTest
  static void testAtualizarOportunidade() {
    Opportunity orcamento = [SELECT Id, Name FROM Opportunity LIMIT 1];
    orcamento.Name = 'Novo nome';

    Test.startTest();

    BackgroundConsoleController.atualizarOportunidade(orcamento);

    Test.stopTest();

    Opportunity orcamentoAtualizado = [SELECT Id, Name FROM Opportunity LIMIT 1];

    System.assert(orcamentoAtualizado.Name == 'Novo nome');
  }
}