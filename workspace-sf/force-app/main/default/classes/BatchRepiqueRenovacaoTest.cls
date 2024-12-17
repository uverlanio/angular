//FNPVVEP-187 INICIO
@IsTest
public class BatchRepiqueRenovacaoTest {    

    //FNPVVEP-187 FIX01 INICIO
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

      	Quote propostaTeste = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        propostaTeste.Status = 'Em análise';
        propostaTeste.Tipo__c = 'Renovacao';
        propostaTeste.VigenciaInicial__c = System.today().addDays(10);
        propostaTeste.PaisesDestino__c = 'Brasil';
        propostaTeste.FaseStatus__c = 'Palavra final';
        update propostaTeste;

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = propostaTeste.Id,        
            Status__c = 'Falha na Integração',
            MomentoAnalise__c = 'Palavra final',
            DataRepique__c = NULL, 
            codigo__c = '0',
            MensagemInterna__c = 'REJEITADO'
        );
        insert criticaProposta;
    }
    //FNPVVEP-187 FIX01 FIM
    
    @IsTest
    public static void testBatchRepiqueRenovacao() {

        Test.startTest();
        BatchRepiqueRenovacao batch = new BatchRepiqueRenovacao();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @IsTest
    public static void testExecuteMethod() {
        Test.startTest();
        BatchRepiqueRenovacao batch = new BatchRepiqueRenovacao();
        String jobId = System.schedule('Test Job', '0 0 15 * * ?', batch);
        Test.stopTest();
    }

    //FNPVVEP-191 INICIO
    @IsTest
    public static void testscheduleBatch() {

        Test.startTest();
        BatchRepiqueRenovacao batch = new BatchRepiqueRenovacao();
        batch.scheduleBatch();

        Test.stopTest();
    }
    //FNPVVEP-191 FIM
}
//FNPVVEP-187 FIM