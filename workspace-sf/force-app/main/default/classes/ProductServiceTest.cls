/**
 * Product Service Test 
 * @author Fernando Barcellos @ 26/06/2018
 *
 **/
@isTest(SeeAllData=true)
private class ProductServiceTest {
	
	@isTest
	static void testarServicoApenasSegmento() {
		RestRequest getRequest = new RestRequest();
		getRequest.httpMethod = 'GET';
		getRequest.requestURI = '/services/apexrest/produtos';
		//getRequest.addParameter('segmentoProduto', 'VI');// VI
		getRequest.addParameter('segmentoProduto', 'VG');// VG
		getRequest.addHeader('Accept', 'application/json');
		RestContext.request = getRequest;
		RestContext.response =  new RestResponse();

		Test.startTest();
		ProductREST.consultarProdutos();
		Util.printLimits('ProductService - testarServicoApenasSegmento');
		Test.stopTest();
	}	

	@isTest
	static void testarServicoApenasDocumentos() {
		RestRequest getRequest = new RestRequest();
		getRequest.httpMethod = 'GET';
		getRequest.requestURI = '/services/apexrest/produtos/documentos';
		//getRequest.addParameter('segmentoProduto', 'VI');// VI
		getRequest.addParameter('segmentoProduto', 'VG');// VG
		getRequest.addHeader('Accept', 'application/json');
		RestContext.request = getRequest;
		RestContext.response =  new RestResponse();

		Test.startTest();
		ProductREST.consultarProdutos();
		Util.printLimits('ProductService - testarServicoApenasDocumentos');
		Test.stopTest();
	}	

	@isTest
	static void testarServicoApenasPlanos() {
		RestRequest getRequest = new RestRequest();
		getRequest.httpMethod = 'GET';
		getRequest.requestURI = '/services/apexrest/produtos/planos';
		//getRequest.addParameter('segmentoProduto', 'VI');// VI
		getRequest.addParameter('segmentoProduto', 'VG');// VG
		getRequest.addHeader('Accept', 'application/json');
		RestContext.request = getRequest;
		RestContext.response =  new RestResponse();

		Test.startTest();
		ProductREST.consultarProdutos();
		Util.printLimits('ProductService - testarServicoApenasPlanos');
		Test.stopTest();
	}	
}