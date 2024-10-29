//ZSVEP-76-INICIO
@isTest 
private class ConsultaPropostaRESTTest 
{
	@isTest
	public static void testeConsultaProposta() 
	{
		StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadProposta' LIMIT 1];
		String payload = staticResource.Body.toString();

		RestRequest requestPost = new RestRequest();
		requestPost.requestUri ='/services/apexrest/api/proposta';
		requestPost.httpMethod = 'POST';
		requestPost.requestBody = Blob.valueOf(payload);
		RestResponse resPost = new RestResponse();
		RestContext.response = resPost;
		RestContext.request = requestPost;
        
		PropostaREST.processarPost();
        
		RestRequest request = new RestRequest();
		request.requestUri ='/services/apexrest/api/ConsultaPropostas?proposta=Teste&origem=18';
		request.httpMethod = 'GET';
		RestResponse res = new RestResponse();
		RestContext.response = res;
		RestContext.request = request;

		Test.startTest();
		ConsultaPropostaREST.processarPost();
		Test.stopTest();
	}
    
    @isTest
    static void testProcessarServicoGET() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ConsultaPropostas';
        req.httpMethod = 'GET';
        req.addParameter('empresa', 'EmpresaTeste');
        req.addParameter('ramo', 'RamoTeste');
        req.addParameter('origem', 'OrigemTeste');
        req.addParameter('proposta', '123');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ConsultaPropostaREST.processarPost();
        Test.stopTest();

        String responseBody = res.responseBody.toString();
        System.assertNotEquals(null, responseBody, 'O corpo da resposta não deve ser nulo');
    }

    @isTest
    static void testCompleteToLeft() {
        ConsultaPropostaREST instance = new ConsultaPropostaREST();
        String result = instance.completeToLeft('123', '0', 8);
    }
    
    @isTest
    static void testProcessarServicoGET_Exception() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ConsultaPropostas';
        req.httpMethod = 'GET';
        req.addParameter('empresa', 'EmpresaTeste');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ConsultaPropostaREST.processarPost();
        Test.stopTest();

        String responseBody = res.responseBody.toString();
        System.assertNotEquals(null, responseBody, 'O corpo da resposta não deve ser nulo');
    }
}
//ZSVEP-76-FIM