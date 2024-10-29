/*******************************************************************************************************************************
* 
* @author Pedro Augusto Braz - SYS4B
* @date 08/04/2021
* @modifiedAt 
* Classe de teste criada por conta da história PLV-4891
* Serviço para Criar Arquivos
******************************************************************************************************************************/
@isTest
private class CreateFileRESTTest {
	static testMethod void CreateFileRESTTest(){
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();//PLV-4921
		request.requestUri = '/services/apexrest/createfile';
		request.requestBody = Blob.valueOf('{"itens":[{"fileName":"_localStorage","fileBody":"001235152","extensao":".min.json","recordId":"0Q0L0000000QBnqKAG"}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;//PLV-4921
		CreateFileREST.processarPost();//PLV-4921
	}
	//PLV-4921 -INICIO
	static testMethod void CreateFileRESTTest_SUCESSO(){
		Account conta = TestDataFactory.gerarConta();
		RestRequest request = new RestRequest();
		RestResponse res = new RestResponse();
		request.requestUri = '/services/apexrest/createfile';
		request.requestBody = Blob.valueOf('{"itens":[{"fileName":"_localStorage","fileBody":"001235152","extensao":".min.json","recordId":"'+conta.id+'"}]}');
		request.httpMethod = 'POST';
		RestContext.request = request;
		RestContext.response = res;
		CreateFileREST.processarPost();
	}
	//PLV-4921 -FIM
}