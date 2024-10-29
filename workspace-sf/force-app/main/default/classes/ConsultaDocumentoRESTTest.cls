/*******************************************************************************************************************************
* Consulta documento
* @author Yuri - Sys4b
* @date 06/04/2021
* Classe criada por conta da história PLV-4891
******************************************************************************************************************************/
@isTest
public class ConsultaDocumentoRESTTest {
	@TestSetup
    static void setupUnit(){
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        		
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf('{"jsonResponseCalculo": {"ofertas": [{"resultadoTeste":"ok"}, {"resultadoTeste":"ok"}]}}');
        v.title = 'teste_localStorage';
        v.pathOnClient = 'teste_localStorage';
        insert v;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: v.Id].ContentDocumentId;
        cdl.LinkedEntityId = orcamento.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    
    @IsTest
    static void valida_parametros(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"orcamento\":\"\"}');
        RestContext.request = req;
        
        Test.startTest();
        ConsultaDocumentoREST.Response result = ConsultaDocumentoREST.consultar();
        System.debug(JSON.serialize(result));
        Test.stopTest();
    } 
    
    @IsTest
    static void busca_documento(){
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueof('{\"orcamento\":\"00005555\"}');
        RestContext.request = req;

        Test.startTest();
        ConsultaDocumentoREST.Response result = ConsultaDocumentoREST.consultar();
        System.debug('resposta: ' + JSON.serialize(result));
        Test.stopTest();
    }
    
    
}