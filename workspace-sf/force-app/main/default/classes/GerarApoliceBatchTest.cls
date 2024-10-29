@isTest
public class GerarApoliceBatchTest{
    
    @TestSetup
    static void setup(){
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        update produtoCom;
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        cot.NumeroProposta__c = '00001910';
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.NumeroPropostaUnico__c = '18-00001910';
        update contrato;
    }
    
    @isTest
    static void TestOne(){
        Test.startTest();
        
        Contract c =[ SELECT Id,Produto__r.segmento__c,Status, Name FROM Contract limit 1];
        
        c.Status='Emitido';
        c.ApolicePdfDownloadUrl__c=null;
        c.Tipo__c = 'Novo';
        update c;
        c.produto__r.segmento__c = 'Viagem';
        update c.produto__r;
        list<ContentDocumentLink> docs = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :c.Id];
        delete docs;
        
        List<Contract> contracts=[SELECT Id, Name FROM Contract WHERE Segmento__c = 'Viagem' AND ApolicePdfDownloadUrl__c = NULL AND Status='Emitido'AND Tipo__c != 'Endosso' AND Tipo__c != 'Cancelamento'];
        
        Database.executeBatch(new GerarApoliceBatch());
        Test.stopTest();
    }
}