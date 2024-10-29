/**
 * @description       : Classe criada para garantir comportamento da classe BatchReviewQuoteToRenovate (II-185)
 * @author            : Kevin Vogado (GLOBANT)
 * @last modified on  : 09-04-2024
 * @last modified by  : Kevin Vogado
**/
@isTest
private class BatchReviewQuoteToRenovateTest {

    @testSetup
    static void setupTestData() {
        Date vigenciaFinal = Date.today().addDays(15);
        Date vigenciaInicial = Date.today();
        String origem = '18';
        String numeroProposta = '00006767';
        String data = '2023-03-21';

        String origemPropostaRenovada = '19';
        String numeroPropostaRenovada = '00006069';

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c)new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c)new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Account conta = (Account)new AccountFactory.PessoaFisica().createRecord();

        RamoSeguro__c ramoSegurado = new RamoSeguro__c(
            Name = 'Segurado',
            CodigoEmpresa__c = '1',
            Codigo__c = '2',
            IdExterno__c = '1' + '_3',
            Empresa__c = conta.Id,
            Status__c = 'Ativo',
            CodigoOrigemDoMovimentoBCP__c = '32'
        );
        insert ramoSegurado;

        Modalidade__c modalidade = new Modalidade__c(
            RamoSeguro__c = ramoSegurado.Id,
            Name = 'Mod teste',
            Codigo__c = '0'
        );
        insert modalidade;

        DadosCorretor__c dadosCorretor = new DadosCorretor__c(
            Name = 'REN01J',
            NomeCorretor__c = conta.Id
        );
        insert dadosCorretor;

        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c(
            Name = 'Canal Distribuição Teste 001',
            Status__c = 'Em criação',
            Sigla__c = 'EXE'
        );
        insert canalDistribuicao;

        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '46',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Individual',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual'
        );
        insert produtoTec;

        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = new Product2(
            ProdutoTecnico__c = produtoTec.Id,
            Name = 'Seguro de Pessoas Individual.',
            Status__c = 'Em criação',
            ProductCode = 'VI-PESSOAS',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Individual',
            TipoResponsavelPagamento__c = 'SEG',
            LimiteTotalCarregamento__c = 200,
            NumeroSusep__c = '15414.900476/2015-42',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual'
        );
        insert produtoCom;

        produtoCom.Status__c = 'Ativo';
        update produtoCom;

        Opportunity orcamentoOriginal = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-00006769',
            CloseDate = System.today().addDays(20),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            Produto__c = produtoCom.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
            AccountId = conta.Id,
            Numero__c = '00006769',
            CanalDistribuicao__c = canalDistribuicao.Id,
            CodigoCorretor__c = dadosCorretor.Id
        );
        insert orcamentoOriginal;

        Quote quote = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem, numeroProposta),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem, numeroProposta),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em análise',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = conta.Id,
            CodigoCorretor__c = dadosCorretor.Id,
            DataCalculo__c = System.today(),
            DataProtocolo__c = Date.valueOf(data),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC',
            OpportunityId = orcamentoOriginal.Id,
            Origem__c = origem,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta,
            Parceiro__c = '67708896000139',
            CupomDesconto__c = 'VALE50DESCONTO',
            Tipo__c = 'Novo'
        );
        insert quote;

        Contract contratoOriginal = new Contract(
            AlteraFormaPagto__c = false,
            AccountId = conta.Id,
            Oportunidade__c = orcamentoOriginal.Id,
            Origem__c = '18',
            NumeroProposta__c = '00006767',
            NumeroApolice__c = '000014419',
            Tipo__c = 'Novo',
            Status = 'Cancelado',
            Endosso__c = '0',
            Sucursal__c =  '1', //FNPVVEP-93 INICIO/FIM
            Empresa__c =  '1', //FNPVVEP-93 INICIO/FIM
            Proposta__c = quote.Id,
            PremioTotal__c = 1300.00,
            VigenciaFinal__c = System.today().addDays(30),
            StatusRenovacao__c = 'Não Renovado',
            CodigoRamo__c = '1391',
            Produto__c = produtoCom.id,
            ApolicePdfDownloadUrl__c = 'https://MestreChico.com'
        );
        insert contratoOriginal;

        //FNPVVEP-93 INICIO
        Contract contratoTeste = new Contract(
            AlteraFormaPagto__c = false,
            AccountId = conta.Id,
            Oportunidade__c = orcamentoOriginal.Id,
            Origem__c = '18',
            NumeroProposta__c = '00006767',
            NumeroApolice__c = '000014419',
            Tipo__c = 'Cancelamento',
            Status = 'Emitido',
            Endosso__c = '1',
            Sucursal__c =  '1',
            Empresa__c =  '1',
            Proposta__c = quote.Id,
            PremioTotal__c = 1300.00,
            VigenciaFinal__c = System.today().addDays(30),
            StartDate = System.today().addYears(2),
            StatusRenovacao__c = 'Não Renovado',
            CodigoRamo__c = '1391',
            Produto__c = produtoCom.id,
            ApolicePdfDownloadUrl__c = 'https://MestreChico.com'
        );
        insert contratoTeste;
        //FNPVVEP-93 FIM
        Quote quoteRenovada = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origemPropostaRenovada, origemPropostaRenovada),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origemPropostaRenovada, origemPropostaRenovada),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em análise',
            VigenciaInicial__c = vigenciaInicial,
            VigenciaFinal__c = vigenciaFinal,
            Empresa__c = conta.Id,
            CodigoCorretor__c = dadosCorretor.Id,
            DataCalculo__c = System.today(),
            DataProtocolo__c = Date.valueOf(data),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC',
            OpportunityId = orcamentoOriginal.Id,
            Origem__c = origem,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta,
            Parceiro__c = '67708896000139',
            CupomDesconto__c = 'VALE50DESCONTO',
            Tipo__c = 'Renovacao',
            ContratoRenovado__c = contratoOriginal.id
        );
        insert quoteRenovada;
    }

    //FNPVVEP-93 INICIO
    @isTest //ANNVI-55 - INICIO
    static void testBatchExecution() {
        Test.startTest();
        BatchReviewQuoteToRenovate batchJob = new BatchReviewQuoteToRenovate();
        String jobId = Database.executeBatch(batchJob);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Batch job not executed');
    }
    
    @isTest
    static void testBatchExecutionBehavior() {
        
        Test.startTest();
        BatchReviewQuoteToRenovate batchInstance = new BatchReviewQuoteToRenovate();
        Database.executeBatch(batchInstance);
        Test.stopTest();
    }

    @isTest
    static void testBatchExecutionContract() {
        Contract contratoOriginal = [SELECT Id FROM Contract WHERE NumeroApolice__c = '000014419' AND Tipo__c = 'Cancelamento'];
        contratoOriginal.Tipo__c = 'Endosso';
        update contratoOriginal;
        Test.startTest();
        BatchReviewQuoteToRenovate batchInstance = new BatchReviewQuoteToRenovate();
        Database.executeBatch(batchInstance);
        Test.stopTest();
    }

    @isTest
    static void testScheduleBatch() {
        Test.startTest();
        BatchReviewQuoteToRenovate batch = new BatchReviewQuoteToRenovate();
        batch.scheduleBatch();
        Test.stopTest();

        List<CronTrigger> cronTriggers = [SELECT Id, CronExpression, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'BatchReviewQuoteToRenovate'];
        
        System.assertEquals(1, cronTriggers.size(), 'Deve haver um job agendado');

        CronTrigger cronTrigger = cronTriggers[0];
        System.assertNotEquals(null, cronTrigger.NextFireTime, 'O próximo horário de execução não deve ser nulo');
    }
    
    //FNPVVEP-18 - INICIO
    @isTest
    static void testBehaviorWhenHasDuplicatedQuotes(){

        Product2 productCom = [SELECT Id FROM Product2 WHERE Name = 'Seguro de Pessoas Individual.'];

        RamoSeguro__c ramoSegurado = [SELECT Id FROM RamoSeguro__c LIMIT 1];

        Account conta = [SELECT Id FROM Account LIMIT 1];
        
        DadosCorretor__c dadosCorretor = [SELECT Id FROM DadosCorretor__c LIMIT 1];

        Opportunity orcamentoOriginal = [SELECT Id FROM Opportunity LIMIT 1];

        Modalidade__c modalidade = [SELECT Id FROM Modalidade__c LIMIT 1];

        Contract contratoOriginal = [SELECT Id FROM Contract WHERE NumeroApolice__c = '000014419' AND Status = 'Cancelado'];

        Quote quoteRenovada = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta('18', '19'),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18', '19'),
            Produto__c = productCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em análise',
            VigenciaInicial__c = Date.today(),
            VigenciaFinal__c = Date.today().addDays(15),
            Empresa__c = conta.Id,
            CodigoCorretor__c = dadosCorretor.Id,
            DataCalculo__c = System.today(),
            DataProtocolo__c = Date.valueOf('2023-03-21'),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC',
            OpportunityId = orcamentoOriginal.Id,
            Origem__c = '18',
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = '00006969',
            Parceiro__c = '67708896000138',
            CupomDesconto__c = 'VALE50DESCONTO',
            Tipo__c = 'Renovacao',
            Observacoes__c = 'Em branco',
            ContratoRenovado__c = contratoOriginal.id
        );
        insert quoteRenovada;

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = quoteRenovada.Id,        
            Status__c = 'Pendente',
            Tipo__c = 'Analise'     
        );
        insert criticaProposta;
        
        CriticaProposta__c criticaProposta2 = new CriticaProposta__c(
            Proposta__c = quoteRenovada.Id,   
            Status__c = 'Pendente',
            Tipo__c = 'Analise'    
        );
        insert criticaProposta2;

        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c cp = TestDataFactory.gerarContratanteProposta(conta, quoteRenovada, formaPagamento);

        Test.startTest();
        BatchReviewQuoteToRenovate batchInstance = new BatchReviewQuoteToRenovate();
        Database.executeBatch(batchInstance);
        Test.stopTest();

        Quote canceledQuote = [SELECT Id, Status, CodigoMotivoDevolucao__c, Observacoes__c FROM Quote WHERE Status = 'Cancelada' AND Observacoes__c != null LIMIT 1];
        System.assertEquals('Proposta cancelada por duplicidade', canceledQuote.Observacoes__c);
    } //ANNVI-55 - FIM
    //FNPVVEP-18 - FIM
    //FNPVVEP-93 FIM

}