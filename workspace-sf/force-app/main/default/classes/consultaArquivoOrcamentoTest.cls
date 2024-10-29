@isTest
public with sharing class consultaArquivoOrcamentoTest {

    @testSetup
	static void testSetup() {
		TestDataFactory.gerarDadosSetup();
		// PLV-2312-28 INICIO
		TestDataFactory.gerarOrcamento(false);
		// PLV-2312-28 FIM
	}

    @isTest
    static void testconsultaArquivoOrcamentoTestSuccess() 
    {
        RestRequest CodigoPropostaRequest = new RestRequest();
        CodigoPropostaRequest.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/consultaArquivoOrcamento/';
        CodigoPropostaRequest.httpMethod = 'GET';

        consultaArquivoOrcamento.CodigoPropostaRequest newCodigoProposta = generateCodigoPropostaSuccess(); 

        test.startTest();
        RestContext.request = CodigoPropostaRequest;
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(newCodigoProposta));
        consultaArquivoOrcamento.CodigoPropostaResponse responseCodigoProposta = consultaArquivoOrcamento.doGET();
        system.debug('responseconsultaArquivoOrcamento Sucesso: ' + responseCodigoProposta);
        system.debug(responseCodigoProposta.isSuccess);
        test.stopTest();
    }
    @isTest
    static void testconsultaArquivoOrcamentoTestError() 
    {
        RestRequest CodigoPropostaRequest = new RestRequest();
        CodigoPropostaRequest.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/consultaArquivoOrcamento/';
        CodigoPropostaRequest.httpMethod = 'GET';

        consultaArquivoOrcamento.CodigoPropostaRequest newCodigoProposta = generateCodigoPropostaError(); 

        test.startTest();
        RestContext.request = CodigoPropostaRequest;
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(newCodigoProposta));
        consultaArquivoOrcamento.CodigoPropostaResponse responseCodigoProposta = consultaArquivoOrcamento.doGET();
        system.debug('responseconsultaArquivoOrcamento: ' + responseCodigoProposta + RestContext.request.requestBody);
        system.debug(responseCodigoProposta.isSuccess);
        test.stopTest();
    }

    @isTest
    static void testconsultaArquivoOrcamentoTestBlank() 
    {
        RestRequest CodigoPropostaRequest = new RestRequest();
        CodigoPropostaRequest.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/consultaArquivoOrcamento/';
        CodigoPropostaRequest.httpMethod = 'GET';

        consultaArquivoOrcamento.CodigoPropostaRequest newCodigoProposta = generateCodigoPropostaBlank(); 

        test.startTest();
        RestContext.request = CodigoPropostaRequest;
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(newCodigoProposta));
        consultaArquivoOrcamento.CodigoPropostaResponse responseCodigoProposta = consultaArquivoOrcamento.doGET();
        system.debug('responseconsultaArquivoOrcamento: ' + responseCodigoProposta);
        system.debug(responseCodigoProposta.isSuccess);
        test.stopTest();
    }


    private static consultaArquivoOrcamento.CodigoPropostaRequest generateCodigoPropostaError()
    {
        consultaArquivoOrcamento.CodigoPropostaRequest request = new consultaArquivoOrcamento.CodigoPropostaRequest();
       
        request.numeroOrcamento = '9987';
                   
        return request;
    }

    private static consultaArquivoOrcamento.CodigoPropostaRequest generateCodigoPropostaBlank()
    {
        consultaArquivoOrcamento.CodigoPropostaRequest request = new consultaArquivoOrcamento.CodigoPropostaRequest();
       
        request.numeroOrcamento = '';
                   
        return request;
    }

    private static consultaArquivoOrcamento.CodigoPropostaRequest generateCodigoPropostaSuccess()
    {
        consultaArquivoOrcamento.CodigoPropostaRequest request = new consultaArquivoOrcamento.CodigoPropostaRequest();
       	
        Opportunity orcamento = [SELECT Id, Numero__c FROM Opportunity];
		orcamento.Name = 'Novo Orcamento';
       
        request.numeroOrcamento = orcamento.Numero__c;
                   
        return request;
    }
    

}