@isTest
public class BatchExecucaoBCPTest {
    @TestSetup
    static void makeData(){
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
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
        contrato.NumeroApolice__c = '000014419';
        update contrato;
    }
    
    @isTest
    static void batchExecucaoBCPTest() {
        Test.startTest();
        String retorno = '{"servico":"/reprocessamentobcp/consultar-bcp","status":"PROCESSADO","codigoprocessamento":0,"dataexecucao":"2021-12-08T17:27:06.993Z","descricao":"A consulta localizou 2 registro(s).","dados":[{"registros":[{"numeroProposta":"18-00001910"},{"numeroProposta":"18-00001910"}],"totalRegistros":2}]}';
        BatchExecucaoBCPTO.consultarBCPRetorno teste = (BatchExecucaoBCPTO.consultarBCPRetorno) JSON.deserialize(retorno, BatchExecucaoBCPTO.consultarBCPRetorno.class);
        BatchExecucaoBCP testBatchexecucaoBCP = new BatchExecucaoBCP();
        testBatchexecucaoBCP.responseHerokuTratado = teste;
        Database.executeBatch(testBatchexecucaoBCP, 100);
        Test.stopTest();
    }

    @isTest
    static void schedulableBatchExecucaoBCPTest() {
        Test.startTest();
        BatchExecucaoBCP testBatchexecucaoBCP = new BatchExecucaoBCP();
        System.schedule('BatchExecucaoBCP: execução de batch > 9 horas', '0 0 9 * * ?', testBatchexecucaoBCP);
        Test.stopTest();
    }
}