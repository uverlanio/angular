/**
 * @author Isabela (Globant) & Jeferson (Sys4B)
 * @date 2020-03-28
 * @description DocumentoEcmControllerTest (Test class for DocumentoEcmController)
 * Classe criada por conta da história PLV-3413
 */
@isTest
public class DocumentoEcmControllerTest {
    @testSetup
    static void testUnitSetup(){		
		Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaFisica, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiro).createRecord();
    }
    
	@isTest
    static void testUnitQueryExternalObj(){
        Contract contract = [SELECT Id from Contract LIMIT 1];
        Test.startTest();
        public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
            nomearquivo__c='TestFile',
            idecm__c='123',
            status__c='CRIADO',
            idsf__c=contract.Id
        );
        DocumentoEcmController.mockedRequests.add(mockedRequest);
        List<public_arquivoecm__x> arquivo = DocumentoEcmController.consultarArquivoEcm(mockedRequest.idsf__c);
        Test.stopTest();
        System.assertEquals('TestFile', arquivo[0].nomearquivo__c);
        System.assertEquals('CRIADO', arquivo[0].status__c);
    }
    
    @isTest
    static void testRequestECMFile(){
        DocumentoEcmController.BlobWrapper blobwrapper = new DocumentoEcmController.BlobWrapper();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new RestECMTestMock());
            blobwrapper = DocumentoEcmController.getBase64Info('123');
            System.debug('blobwrapper Test: ' + blobwrapper);
    	Test.stopTest();
        System.assertEquals(null, blobwrapper.Error);
    }
    
    @isTest
    static void testRequestECMFileError(){
        DocumentoEcmController.BlobWrapper blobwrapper = new DocumentoEcmController.BlobWrapper();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new RestECMTestMock.RestECMFileError());
            blobwrapper = DocumentoEcmController.getBase64Info('222');
            System.debug('blobwrapper Test: ' + blobwrapper);
    	Test.stopTest();
        System.assertEquals('Arquivo não encontrado no ECM.', blobwrapper.Error);
    }
    
    @isTest
    static void testRequestECMConnectionError(){
        DocumentoEcmController.BlobWrapper blobwrapper = new DocumentoEcmController.BlobWrapper();
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new RestECMTestMock.RestECMConnectionError());
            blobwrapper = DocumentoEcmController.getBase64Info('123');
            System.debug('blobwrapper Test: ' + blobwrapper);
    	Test.stopTest();
        System.assertEquals('Não foi possível realizar a conexão para a busca do arquivo. Entre em contato com o administrador.', blobwrapper.Error);
    }
}