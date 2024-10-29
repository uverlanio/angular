/**
 * Consulta Oferta REST - Test
 * @author IF - Globant @ 25/12/2019
 * @modified IF - Globant @ 27/12/2019
 *
 **/
//PLV-3223 - INÍCIO
@isTest
public class ConsultaOfertaRESTTest {
	@testSetup
    static void setupUnit() {
        TestDataFactory.gerarDadosSetup();
		TestDataFactory.gerarOrcamento(false);
        Opportunity orcamento2Update = [SELECT StageName FROM Opportunity LIMIT 1];
        orcamento2Update.StageName = 'Disponível para contratação';
        update orcamento2Update;
    }
    
    @isTest
    public static void testUnitSuccess() {
        Opportunity orcamento = [SELECT Numero__c, Account.Name, Account.Cpf__c FROM Opportunity LIMIT 1];
        String cpf = orcamento.Account.Cpf__c;
        cpf = cpf.remove('-').remove('.');
        
        //bloco de montagem de json para body do serviço
        Map<String,String> mapBody = new Map<String,String>();
        mapBody.put('codigoCorretor', 'P5005J');
        mapBody.put('numero', orcamento.Numero__c);
        mapBody.put('nomeSegurado', orcamento.Account.Name);
        mapBody.put('numeroCpf', cpf);
        mapBody.put('periodoBusca', '2');
        //bloco de montagem de json para body do serviço
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/consulta/orcamento';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(mapBody));
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        
        Test.startTest();
        	ConsultaOfertaREST consulta = new ConsultaOfertaREST();
            consulta.processarServico('POST');
        Test.stopTest();
        
        Map<String, Object> mapReturnedObjects = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        Map<String, Object> mapData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(mapReturnedObjects.get('data')));
        System.assertEquals(null,mapData.get('mensagem'));
    }
    
    @isTest
    public static void testUnitNoResults() {
        //bloco de montagem de json para body do serviço
        Map<String,String> mapBody = new Map<String,String>();
        mapBody.put('numero', '1234');
        //bloco de montagem de json para body do serviço
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/consulta/orcamento';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(mapBody));
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        
        Test.startTest();
        	ConsultaOfertaREST consulta = new ConsultaOfertaREST();
            consulta.processarServico('POST');
        Test.stopTest();
        
        Map<String, Object> mapReturnedObjects = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        Map<String, Object> mapData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(mapReturnedObjects.get('data')));
        System.assertEquals('Não foram encontrados resultados.',mapData.get('mensagem'));
    }
    
    @isTest
    public static void testUnitError() {
        //bloco de montagem de json para body do serviço
        Map<String,String> mapBody = new Map<String,String>();
        mapBody.put('numero', '');
        //bloco de montagem de json para body do serviço
        
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/consulta/orcamento';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(mapBody));
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        
        Test.startTest();
        	ConsultaOfertaREST consulta = new ConsultaOfertaREST();
            consulta.processarServico('POST');
        Test.stopTest();
        
        Map<String, Object> mapReturnedObjects = (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        Map<String, Object> mapData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(mapReturnedObjects.get('data')));
        System.assertEquals('Parâmetros insuficientes.',mapData.get('mensagem'));
    }
}
//PLV-3223 - FIM