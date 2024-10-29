@isTest
public class QueueableCreateContractTest {
    public static final QuoteBO bo = QuoteBO.getInstance();
    @isTest
    static void testExecute() {
        // Criar dados de teste para o objeto Quote
                Account contaTeste = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '518.179.180-87',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert contaTeste;

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c= 'Versão atual'
        );
        insert produtoTec;
        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = new Product2(
            ProdutoTecnico__c = produtoTec.Id,
            Name = 'Nome Produto Comercial',
            Status__c = 'Em criação',
            ProductCode = '201700001',            	
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            LimiteTotalCarregamento__c = 200,
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual'
        );
        insert produtoCom; 

        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        
        String origem = '18';
        String numeroProposta = '00006767';

        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = contaTeste.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC', 
                OpportunityId = orcamentoContratado.Id,
                Origem__c = origem,
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = numeroProposta,
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO' 

        );
        insert proposta;
        List<Quote> quotes = new List<Quote>();
        
        for (Integer i = 0; i < 5; i++) {
            Quote quote = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta) + i,
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta) + i,
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = contaTeste.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC', 
                OpportunityId = orcamentoContratado.Id,
                Origem__c = origem,
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = numeroProposta,
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO' 

        );
         quotes.add(quote);
        }

        insert quotes;

        // Iniciar a execução do teste de Queueable
        Test.startTest();
        QueueableCreateContract queueable = new QueueableCreateContract(quotes);
        System.enqueueJob(queueable);
        Test.stopTest();

        List<Quote> propostas = [SELECT Id FROM Quote LIMIT 5];
        System.debug('Contracts ' + propostas);
        System.assertEquals(5, propostas.size(), 'Número de propostas criadas deve ser igual a 5');

    }


}