/**
 * Created by Alessandro Ponte on 09/12/2018.
 */

@IsTest
private class TitulosRecompraBatchTest {

  @TestSetup
  static void testSetup(){

    TestDataFactory.gerarDadosSetup();
    // PLV-2312-28 INICIO
    Map<String,List<SObject>> mapListObject = TestDataFactory.gerarContrato(true);
    // PLV-2312-28 FIM

    List<GarantiaContrato__c> listGarantiaContrato = [SELECT Id, VersaoTitulo__c, DataSorteio__c FROM GarantiaContrato__c WHERE Garantia__r.Sigla__c = 'CAP'];

    for(GarantiaContrato__c garantiaContrato : listGarantiaContrato){
      garantiaContrato.DataSorteio__c = System.today();
      garantiaContrato.LoteCapitalizacao__c = '20';
    }
    update listGarantiaContrato;

    System.debug('listGarantiaContrato ------------------ ' + listGarantiaContrato);

  }

  @IsTest
  static void testRecompraTitulos(){
    Test.startTest();

    // Mock de retorno da PortoCap
    String responseJsonString = '[{"Cessionario": [{}],"id_lote": 23232,"nm_retorno": "Código 0: Processamento efetuado com sucesso","cd_retorno": 0, "cd_versao": 2}]';
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse(responseJsonString, 200, 'OK'));

    Database.executeBatch(new TitulosRecompraBatch(), 100);

    Test.stopTest();

    List<GarantiaContrato__c> ListGarantiaContrato = [SELECT Id, VersaoTitulo__c, StatusCapitalizacao__c FROM GarantiaContrato__c WHERE Garantia__r.Sigla__c = 'CAP'];

      //PLV- 2932 Fix2 - Inicio - Código comentado
    //System.assertEquals('2', ListGarantiaContrato[0].VersaoTitulo__c);
    //System.assertEquals('AguardandoRecompra', ListGarantiaContrato[0].StatusCapitalizacao__c);
    //PLV- 2932 Fix2 - Fim - Código comentado
  }

}