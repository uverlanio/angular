/**
 * @author Guilherme Azevedo
 * @date 2020-12-14
 * @description Criada para a história PLV-4644
 */
@IsTest
public class BatchErroSampleMed_schTest {
    @TestSetup
    static void makeData() {
        RamoAtividade__c  ramo = new RamoAtividade__c();
        ramo.Name='teste';
        insert ramo;

        Account acct = TestDataFactory.gerarConta();
        acct.Sexo__c = 'Masculino';
        acct.RamoAtividade__c = ramo.id;
        update acct;

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(acct).createRecord();
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Em criação';
        opp.CloseDate = date.today();
        opp.Name = 'teste';
        opp.AccountId = acct.id;
        opp.RecordTypeId = oppVidaEmGrupo;
        insert opp;

        //TKCL-246 FIX05 INICIO
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.ProductCode = '49';
        produtoTecnico.Segmento__c = 'Individual';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        //TKCL-246 FIX05 FIM

        Quote proposta = new Quote(
            OpportunityId = opp.id, 
            Name = 'Teste Quote56', 
            NumeroProposta__c = '356',
            Origem__c = '9',
            status = 'Pendente',
            Produto__c = produtoComercial.Id, //TKCL-246 FIX05 INICIO/FIM
            CodigoCorretor__c = dadosCorretor.Id
        );
        insert proposta; 

        CriticaProposta__c Ctt2 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Subscrição',
            Status__c = 'Falha na Integração',
            Integracao__c = 'SAMPLE',
            Acao__c = 'auto'
        ); 

        insert ctt2;
    }

    @isTest
    static void executeTest() {
        Test.startTest();
        Database.executeBatch(new BatchErroSampleMed_sch(), 10);
        Test.stopTest();
    }

    @isTest
    static void runAndScheduleTest() {
        Test.startTest();
        BatchErroSampleMed_sch.runAndSchedule();
        Test.stopTest();
    }

    @isTest
    static void singleRunByDateTest() {
        Test.startTest();
        BatchErroSampleMed_sch.singleRunByDate(Date.today().format(), Date.today().addDays(1).format());
        Test.stopTest();
    }
}