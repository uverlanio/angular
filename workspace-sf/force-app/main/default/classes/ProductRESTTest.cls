@isTest
private class ProductRESTTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
		Map<String,List<SObject>> mapListObject = TestDataFactory.gerarProdutoComercialAtivo(false);

	}

	@isTest
	private static void testarBuscaPorSegmento(){
		Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE Status__c = 'Ativo'AND RecordType.DeveloperName = 'ProdutoComercial'];

		RestRequest postRequest = new RestRequest();
		postRequest.requestURI = '/services/apexrest/produtos/';
		//postRequest.requestBody = Blob.valueOf(payloadEntrada);
		postRequest.httpMethod = 'POST';
		postRequest.addHeader('Content-Type', 'application/json');
		postRequest.params.put('segmentoProduto', 'VG');
		RestContext.request = postRequest;
		RestContext.response =  new RestResponse();

		Test.startTest();

		ProductREST.consultarProdutos();
		String jsonResposta = RestContext.response.responseBody.toString();
		//RetornoTeste resposta = (RetornoTeste)JSON.deserialize(jsonResposta, RetornoTeste.class);

		//System.assertEquals(resposta.meta.statusHttp, 200);
		//System.assertEquals(resposta.data.produtos.size(), 1);
		//System.assertEquals(resposta.data.produtos.get(0).nome, produtoGerado.Name);	
		Test.stopTest();
	}

	@isTest
	private static void testarBuscaPorCodigo(){
		Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE Status__c = 'Ativo'AND RecordType.DeveloperName = 'ProdutoComercial'];

		RestRequest postRequest = new RestRequest();
		postRequest.requestURI = '/services/apexrest/produtos/' + produto.ProductCode + '/';
		postRequest.httpMethod = 'POST';
		postRequest.addHeader('Content-Type', 'application/json');
		RestContext.request = postRequest;
		RestContext.response =  new RestResponse();

		Test.startTest();

		ProductREST.consultarProdutos();
		String jsonResposta = RestContext.response.responseBody.toString();
		//RetornoTeste resposta = (RetornoTeste)JSON.deserialize(jsonResposta, RetornoTeste.class);

		//System.assertEquals(resposta.meta.statusHttp, 200);
		//System.assertEquals(resposta.data.produtos.size(), 1);
		//System.assertEquals(resposta.data.produtos.get(0).nome, produtoGerado.Name);	

		Test.stopTest();
	}

	@isTest
	private static void testarBuscaPorPlanos(){
		Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE Status__c = 'Ativo'AND RecordType.DeveloperName = 'ProdutoComercial'];

		RestRequest postRequest = new RestRequest();
		postRequest.requestURI = '/services/apexrest/produtos/' + produto.ProductCode + '/planos';
		postRequest.httpMethod = 'POST';
		postRequest.addHeader('Content-Type', 'application/json');
		RestContext.request = postRequest;
		RestContext.response =  new RestResponse();

		Test.startTest();

		ProductREST.consultarProdutos();
		String jsonResposta = RestContext.response.responseBody.toString();
		//RetornoTeste resposta = (RetornoTeste)JSON.deserialize(jsonResposta, RetornoTeste.class);

		//System.assertEquals(resposta.meta.statusHttp, 200);
		//System.assertEquals(resposta.data.produtos.size(), 1);
		//System.assertEquals(resposta.data.produtos.get(0).nome, produtoGerado.Name);	

		Test.stopTest();
	}

	@isTest
	private static void testarBuscaPorDocumentos(){
		Product2 produto = [SELECT Id, ProductCode FROM Product2 WHERE Status__c = 'Ativo'AND RecordType.DeveloperName = 'ProdutoComercial'];

		RestRequest postRequest = new RestRequest();
		postRequest.requestURI = '/services/apexrest/produtos/' + produto.ProductCode + '/documentos';
		postRequest.httpMethod = 'POST';
		postRequest.addHeader('Content-Type', 'application/json');
		RestContext.request = postRequest;
		RestContext.response =  new RestResponse();

		Test.startTest();

		ProductREST.consultarProdutos();
		String jsonResposta = RestContext.response.responseBody.toString();
		//RetornoTeste resposta = (RetornoTeste)JSON.deserialize(jsonResposta, RetornoTeste.class);

		//System.assertEquals(resposta.meta.statusHttp, 200);
		//System.assertEquals(resposta.data.produtos.size(), 1);
		//System.assertEquals(resposta.data.produtos.get(0).nome, produtoGerado.Name);	

		Test.stopTest();
	}
}