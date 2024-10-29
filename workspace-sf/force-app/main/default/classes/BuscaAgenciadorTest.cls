// PLV-4164 criação das classe
@isTest
public with sharing class BuscaAgenciadorTest {
    @isTest
    public static void testBusca(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 200, 'OK'));

        BuscaAgenciador.AgenciadorTO reqBody = new BuscaAgenciador.AgenciadorTO();
        reqBody.nome = 'testeAgenciador';
        reqBody.susep = '';
        reqBody.papel = 'agenciador'; // PLV-4164 - FIX
        reqBody.codigoAgenciador = '';
        reqBody.cpf = '';
        reqBody.cnpj = '';

        RestRequest req = new RestRequest(); 
        
        req.requestURI = '/services/apexrest/buscaAgenciador'; 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSON.serialize(reqBody));
        RestContext.request = req;

        test.startTest();

        // valida agenciador vazio
            BuscaAgenciador.Response res = BuscaAgenciador.BuscaAgenciador();

        // valida sucesso
            Account acc = (account) new AccountFactory.PessoaFisica().createRecord();
            acc.LastName = 'testeAgenciador';
            acc.papel__c = 'Agenciador';
            update acc;
            
            BuscaAgenciador.Response res2 = BuscaAgenciador.BuscaAgenciador();

        // valida parametros nulos
            reqBody.nome = '';
            req.requestBody = Blob.valueof(JSON.serialize(reqBody));
            RestContext.request = req;
            BuscaAgenciador.Response res3 = BuscaAgenciador.BuscaAgenciador();

        test.stopTest();
    }
}