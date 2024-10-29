/**
 * Created by Alessndro Ponte on 08/12/2018.
 */

@IsTest
private class AtualizarDadosArquivosEcmTest {

  @TestSetup
  static void setup(){

    TestDataFactory.gerarDadosSetup();
    // PLV-2312-28 INICIO
    // PLV-2372 INICIO
    TestDataFactory.gerarContrato(true);
    // PLV-2372 FIM
    // PLV-2312-28 FIM
    Fatura__c fatura = TestDataFactory.gerarFatura();



  }

  @IsTest
  static void testAtualizarArquivosEcm(){
    // Recupera a Fatura gerada

    Fatura__c fatura = [SELECT Id,Name FROM Fatura__c limit 1];

    // Recupera o JSON que está no recurso estático;
    String payloadName = 'PayloadArquivosECM';
    StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: payloadName LIMIT 1];
    String payload = sr.Body.toString();

    ServiceTO.PayloadDadosEcmTO objPayload = (ServiceTO.PayloadDadosEcmTO) JSON.deserialize(payload, ServiceTO.PayloadDadosEcmTO.class);

    System.debug('Fatura -------------- ' + fatura);
    System.debug('objPayload ----------------------' + objPayload);

    for(ServiceTO.DetalheDadosEcmTO detalhe : objPayload.dados){
      if(detalhe.tipoarquivo == 'Anexo Fatura'){
        detalhe.codfatura = fatura.Name;
      }
    }

    System.debug('objPayload ----------------------' + objPayload);
    payload = JSON.serialize(objPayload);


    RestRequest request = new RestRequest();
    request.requestUri ='/services/apexrest/api/arquivos-ecm';
    request.httpMethod = 'POST';
    request.requestBody = Blob.valueOf(payload);

    RestResponse res = new RestResponse();

    RestContext.response = res;
    RestContext.request = request;

    Test.startTest();

    AtualizarDadosArquivosEcmREST.processarPost();

    Test.stopTest();

  }



}