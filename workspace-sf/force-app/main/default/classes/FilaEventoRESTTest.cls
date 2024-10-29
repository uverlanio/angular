@isTest
private class FilaEventoRESTTest {

    @isTest
    static void testProcessarPost() {
        RestRequest request = new RestRequest();
        request.requestURI = '/fila-evento/processar-massificados';
        request.requestBody = Blob.valueOf('{"key": "value"}');

        RestContext.request = request;

        Test.startTest();
        FilaEventoREST.processarPost();
        Test.stopTest();
    }
    
    @isTest
    static void testProcessarServico() {
        FilaEventoREST instance = new FilaEventoREST();
        instance.setServicoRestBase('InclusaoEvento');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutMock());
        instance.processarServico('POST');
        Test.stopTest();
    }

    @IsTest
    static void testAbortaProcessarMassificados(){
        
        RestRequest request = new RestRequest();
        request.requestURI = '/fila-evento/abortar-processar-massificados';
        request.requestBody = Blob.valueOf('{"key": "value"}');

        RestContext.request = request;

        Test.startTest();
        FilaEventoREST.processarPost();
        Test.stopTest();
        
    }
    
    private class MockHttpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"key": "value"}');
            return response;
        }
    }
}