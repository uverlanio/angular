//FNPVVEP-187 INICIO
@isTest
public class BatchRepiqueRenovacaoJobTest {

    @testSetup
    static void setupData() {
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c = 'Individual';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        produtoCom.Segmento__c = 'Individual';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        orcamentoContratado.Type = 'Novo';        
        update orcamentoContratado;

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

      	Quote propostaTeste= TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        propostaTeste.Status = 'Em análise';
        propostaTeste.Tipo__c = 'Novo';
        propostaTeste.VigenciaInicial__c = System.today().addDays(10);
        propostaTeste.PaisesDestino__c = 'Brasil';
        propostaTeste.FaseStatus__c = 'Palavra final';
        update propostaTeste;

        FormaPagamento__c pagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c contratantePropLiberada = TestDataFactory.gerarContratanteProposta(contaTeste, propostaTeste, pagamento);

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = propostaTeste.Id,        
            Status__c = 'Liberado',
            Tipo__c = 'Analise',
            MomentoAnalise__c = 'Palavra Final'    
        );
        insert criticaProposta;
    }

    @isTest
    static void testExecute() {
        List<CriticaProposta__c> critica = [SELECT Id, Codigo__c, Status__c FROM CriticaProposta__c LIMIT 1];
        System.debug('criticas >< ' + critica);
        BatchRepiqueRenovacaoJob job = new BatchRepiqueRenovacaoJob();
        job.scope = critica;
        
        Test.startTest();
        
        String cronExpression = '0 0 0 1 1 ? 2050';
        String jobId = System.schedule('Test BatchRepiqueRenovacao', cronExpression, job);
        
        Test.stopTest();
    }
}
//FNPVVEP-187 FIM