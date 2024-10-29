// PLV-4997 - INÍCIO
//ZSVEP-76-INICIO
@istest
public class BatchExpurgoOrcamentosTest 
{
    @testSetup
    static void setup() 
    {
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
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaTeste);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        Attachment anexo = new Attachment();   	
    	anexo.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	anexo.body=bodyBlob;
        anexo.parentId=orcamentoContratado.id;
        insert anexo;
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        update contrato;
        
        GarantiaOrcamento__c garantiaOrcamentoNC = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamentoNC = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamentoNC = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaTeste);
        GrupoOrcamento__c grupoOrcamentoNC = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamentoNC);
        SeguradoOrcamento__c seguradoOrcamentoNC = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamentoNC);
        Attachment anexoNC = new Attachment();   	
    	anexoNC.Name ='Unit Test Attachment';
    	Blob bodyBlobNC = Blob.valueOf('Unit Test Attachment Body');
    	anexoNC.body = bodyBlobNC;
        anexoNC.parentId = orcamentoContratado.id;
        insert anexoNC;
    }

    @IsTest
    static void expurgoContratadosTest()
    {
        List<Contract> contratadosAntesExclusao = [SELECT Id, CreatedDate, Oportunidade__c FROM Contract WHERE Oportunidade__c != NULL AND Oportunidade__r.QuantidadeGarantias__c > 0];
        
        for(Contract contrato : contratadosAntesExclusao)
        {
            Test.setCreatedDate(contrato.Id, Datetime.newInstance(2015,1,1));
        }
        
        Test.startTest();
        BatchExpurgoOrcamentos batchOrcamentos = new BatchExpurgoOrcamentos(1);
        Database.executeBatch(batchOrcamentos, 100);     
        Test.stopTest();
        
        List<Contract> contratadosAposExclusao = [SELECT Oportunidade__c FROM Contract WHERE CreatedDate < LAST_N_MONTHS:12 AND Oportunidade__c != NULL AND Oportunidade__r.QuantidadeGarantias__c > 0];
        
        System.assertEquals(0, contratadosAposExclusao.size(), 'Falha no expurgo de Orçamentos Contratados!');
    }
    
    @IsTest
    static void expurgoNaoContratadosTest()
    {
        List<Opportunity> naoContratadosAntesExclusao = [SELECT Id, CreatedDate FROM Opportunity WHERE StageName != 'Contratado' AND QuantidadeGarantias__c > 0];
        
        for(Opportunity naoContratado : naoContratadosAntesExclusao)
        {
            Test.setCreatedDate(naoContratado.Id, Datetime.newInstance(2015,1,1));
        }

        Test.startTest();
        BatchExpurgoOrcamentos batchOrcamentos = new BatchExpurgoOrcamentos(2);
        Database.executeBatch(batchOrcamentos, 100);
        Test.stopTest();
        
        List<Opportunity> naoContratadosAposExclusao = [SELECT Id FROM Opportunity WHERE CreatedDate < LAST_N_DAYS:45 AND StageName != 'Contratado' AND QuantidadeGarantias__c > 0];

        System.assertEquals(0, naoContratadosAposExclusao.size(), 'Falha no expurgo de Orçamentos Não Contratados!');
    }

    @IsTest
    static void agendarExpurgoTest()
    {
        Test.startTest();
        System.schedule('BatchExpurgoOrcamentos: Expurgo de Orçamentos Contratados > 9 horas', '0 0 9 * * ?', new BatchExpurgoOrcamentos(1));
        System.schedule('BatchExpurgoOrcamentos: Expurgo de Orçamentos Não Contratados > 9 horas','0 0 9 * * ?', new BatchExpurgoOrcamentos(2));
        Test.stopTest();
    }
}
//ZSVEP-76-FIM
// PLV-4997 - FIM