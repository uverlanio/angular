@isTest
private class ExtratoPropostaServiceTest {

    @TestSetup
    static void makeData(){
        Account conta = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(conta);
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        update produtoCom;

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity orcamento = TestDataFactory.gerarOrcamentoObjeto(conta, produtoCom, canalDistribuicao);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18','00324366'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00324366'),
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = conta.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamento.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00324366',
                Parceiro__c = '67708896000139',
                PremioTotal__c = 1000,
                DataProtocolo__c = System.today().addDays(3),
                CreatedDate = DateTime.now().addDays(-2),
                LastModifiedDate = DateTime.now().addDays(-1) //INICIO/FIM - LECVPV-218
        );
        insert proposta;
    }

    @isTest
    static void testGetPropostas() {

        ExtratoPropostaRest.Request request = new ExtratoPropostaRest.Request();
        request.inicio = System.today().addDays(1);
        request.fim = System.today().addYears(1);
        request.coberturas = new List<String>{'Cobertura 1', 'Cobertura 2'};
        request.ramos = new List<String>{'Ramo 1', 'Ramo 2'};
        request.produto = new List<String>{'Produto 1', 'Produto 2'};
        
        Test.startTest();

        Product2 produto = new Product2();
        produto.Name = 'Nome produto001';
		produto.Status__c = 'Em criação';
		produto.ProductCode = '201700001';
		produto.Status__c = 'Em criação';
		produto.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produto.TipoResponsavelPagamento__c = 'SEG';

        insert produto;

        List<Quote> quotes = new List<Quote>();
        Quote quote = [SELECT Id, Name, Origem__c, Status, PremioTotal__c, DataProtocolo__c, LastModifiedDate FROM Quote];
        quotes.add(quote);

        quotes[0].produto__r = produto;
        update quotes;

        GarantiaProposta__c garantia1 = new GarantiaProposta__c(Garantia__r = new Garantia__c(Sigla__c = 'Sigla 1'));        

        List<Quote> lstPropostas = ExtratoPropostaService.getPropostas(request);

        Test.stopTest();
    }

    @isTest
    static void testGetSegurados() {

        ExtratoPropostaRest.Request request = new ExtratoPropostaRest.Request();

        Test.startTest();
        
        List<Quote> quotes = new List<Quote>();
        Quote quote = [SELECT Id, Name, Origem__c, Status, PremioTotal__c, DataProtocolo__c, LastModifiedDate FROM Quote];
        quotes.add(quote);

        Account conta = [SELECT Id FROM Account];

        ContratanteProposta__c contratanteProposta = new ContratanteProposta__c(
            conta__c = conta.Id,
            Proposta__c = quote.Id,
            Tipo__c = 'Principal'
        );

        insert contratanteProposta;
        
        GrupoProposta__c grupoProposta = new GrupoProposta__c(
            Name = 'Teste',
            QuantidadeVidas__c = 1,
            ContratanteProposta__c = contratanteProposta.Id
        );

        insert grupoProposta;
        
        SeguradoProposta__c seguradoProposta = new SeguradoProposta__c(
            Conta__c = conta.Id,
            GrupoProposta__c = grupoProposta.Id
        );

        insert seguradoProposta;

        List<SeguradoProposta__c> lstSegurado = new List<SeguradoProposta__c>{seguradoProposta};

        Map<ID, SeguradoProposta__c> response = ExtratoPropostaService.getSegurados(quotes);
        
        Test.stopTest();
    }

    @isTest
    static void testGetCorretores() {

        List<Quote> quotes = new List<Quote>();

        Test.startTest();

        Quote quote = [SELECT Id, Name, Origem__c, Status, PremioTotal__c, DataProtocolo__c, LastModifiedDate FROM Quote];
        quotes.add(quote);

        Account conta = [SELECT Id FROM Account];

        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
                Name = 'CORRETAGEM',
                Codigo__c = 'COR',
                LimiteMinimo__c = 10000,
                LimiteMaximo__c = 100000,
                ModeloRecuperacao__c = 'Integral'
        );
        
        insert tipoRemuneracao;
        
        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
                TipoRemuneracao__c = tipoRemuneracao.Id,
                Proposta__c = quote.Id,
                Percentual__c = 100
        );
        
        insert remuneracaoProposta;
        
        FavorecidoRemuneracaoProposta__c favorecido = new FavorecidoRemuneracaoProposta__c(
        		Conta__c = conta.Id,
                Papel__c = 'Parceiro',
                Participacao__c = 100,
                RemuneracaoProposta__c = remuneracaoProposta.Id,
                Susep__c = '123',
                SusepEmissao__c = '123',
                SusepOficialCorretor__c = '123',
                SusepOrcamento__c = '123',
            	CorretorResponde__c = false
        );
        
        insert favorecido;

        List<FavorecidoRemuneracaoProposta__c> lstFavorecidos = new List<FavorecidoRemuneracaoProposta__c>{favorecido};
        ExtratoPropostaService.getCorretores(quotes);

        Test.stopTest();

    }
}