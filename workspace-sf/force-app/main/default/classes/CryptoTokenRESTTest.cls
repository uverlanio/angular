/*******************************************************************************************************************************
 * 
 * @author Pedro Augusto Braz - SYS4B
 * @date 10/12/2020
 * @modifiedAt 
 * Classe de teste criada por conta da história PLV-4572
 * Serviço para Criptografar valores
 ******************************************************************************************************************************/
@isTest
public class CryptoTokenRESTTest {
	//PLV-4921 - INICIO
	// PLV-5188 INICIO
	@isTest
	public static void CryptoTokenRESTTest(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":null,"itens":[{"id":"","input":""}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTest_err1(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"encrypt","itens":[{"id":"abcdaef","input":null}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTest_err2(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"decrypt","itens":[{"id":"abcdaef","input":null}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTest_SUCESSO(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"encrypt","itens":[{"id":"abcdaef","input":"001235152"}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTest_SUCESSO_DECRYPT(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"decrypt","itens":[{"id":"abcdaef","input":"FyiIabsw5aDYhAm9/h865VSaqFlg54lgHiX+ULB8YmA="}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	//PLV-4921 - FIM
	@isTest
	public static void CryptoTokenRESTTestUrl_SUCESSO(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"encryptUrl","itens":[{"id":"abcdaef","input":"001235152"}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTest_SUCESSO_DECRYPTUrl(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"decryptUrl","itens":[{"id":"abcdaef","input":"FyiIabsw5aDYhAm9/h865VSaqFlg54lgHiX+ULB8YmA="}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTestUrl(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"encryptUrl","itens"=[{"id"="abcdaef","input"=null}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTestUrl_err1(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"encryptUrl","itens":[{"id":"abcdaef","input":null}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	@isTest
	public static void CryptoTokenRESTTestUrl_err2(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/crypto';
		request.requestBody = Blob.valueOf('{"acao":"decryptUrl","itens":[{"id":"abcdaef","input":null}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		Test.startTest();
		CryptoTokenREST.processarPost();
		Test.stopTest();
	}
	// PLV-5188 FIM

}