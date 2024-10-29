@isTest
private class PdfEcmTest {
	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}

	@isTest
	static void testarChamadasComponenteLightining() {
		// PLV-2312-28 INICIO
		Map<String, List<SObject>> mapListObject = TestDataFactory.gerarProposta(true);
		// PLV-2312-28 FIM
		
		Quote proposta = (Quote)mapListObject.get('Quote').get(0);
		Opportunity oportunidade = (Opportunity)mapListObject.get('Opportunity').get(0);
		Account conta = (Account)mapListObject.get('Account').get(0);

		Contract contrato = new Contract(
			Name = '111',
			Oportunidade__c = oportunidade.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Novo',
			AccountId = conta.Id,
			IdContrato__c = '666'
		);
		insert contrato;

		//Busca dominio de serviço a ser utilziado
		String dominio = PdfEcmController.buscarDominioSf();
		System.assert(String.isNotBlank(dominio));

		String codigoEcm = PdfEcmController.buscarCodigoEcmDocumento(contrato.Id);
		System.assertEquals('666', codigoEcm);
	}

	@isTest
	static void testarChamadasServico() {
		//Gera configuração de token ECM
		Token__c authECM = new Token__c(Name='ECM', Token__c=null);
		insert authECM;

		//Gera mock de erro de autenticação, para forçar o serviço a reautenticar
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('{"codigo" : "401"}', 200, 'OK'));

		RestRequest getRequest = new RestRequest();
		getRequest.requestURI = '/services/apexrest/buscaecmpdf?codigo=88888';
		getRequest.httpMethod = 'GET';
		getRequest.addHeader('Content-Type', 'application/json');
		RestContext.request	= getRequest;
		RestContext.response = new RestResponse();

		Test.startTest();

		PdfEcmREST.processarGet();
		Blob documento = RestContext.response.responseBody;
		
		//NAO CONTEM ASSERTS, DEVIDO NÃO SER POSSIVEL COLOCAR MAIS DE UM MOCK DE SERVIÇO, E A CHAMADA TESTADA EXECUTA 2 CHAMADAS HTTP UMA SEGUIDA DA OUTRA

		Test.stopTest();
	}
}