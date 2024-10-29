//II-166 - INICIO
@isTest
private class AltFormPgtoDAOTest {

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
                Parceiro__c = '67708896000139'        
        );
        insert proposta;

        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c cp = TestDataFactory.gerarContratanteProposta(conta, proposta, formaPagamento);
        cp.VencimentoDemaisParcelas__c = 'A cada 30 dias';
        update cp;

        CondicaoCobranca__c cc = new CondicaoCobranca__c();
		cc.Produto__c = produtoTec.Id;
		cc.FormaPagamento__c = formaPagamento.Id;
		cc.QuantidadeParcelas__c = '1';
		insert cc;

        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
            Name = 'AGENCIAMENTO',
            Codigo__c = 'COR',
            LimiteMinimo__c = 0,
            LimiteMaximo__c = 200,
            ModeloRecuperacao__c = 'Pro-rata'
        );

        insert tipoRemuneracao;

        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
              TipoRemuneracao__c = tipoRemuneracao.Id,
              Proposta__c = proposta.Id,
              Percentual__c = 30
        );

        insert remuneracaoProposta;
    }

    @isTest
    static void consultarContrPropTest() {
       
        AltFormPgtoDAO dao = new AltFormPgtoDAO();

        Quote prop = getProposta();
        ContratanteProposta__c cp = getContrProp();
        
        Test.startTest();

        List<ContratanteProposta__c> cpRetorno = dao.consultarContrProp(prop.Id);

        Test.stopTest();

        Assert.areEqual(true, !cpRetorno.isEmpty(), 'Success');
    }

    @isTest
    static void consultarQtdeParcelasTest(){

        AltFormPgtoDAO dao = new AltFormPgtoDAO();

        Test.startTest();

        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        CondicaoCobranca__c cc = getCondicaoCobranca();

        List<CondicaoCobranca__c> ccRetorno = dao.consultarQtdeParcelas(produto.Id);

        Test.stopTest();

        Assert.areEqual(true, !ccRetorno.isEmpty(), 'Success');

    }

    @isTest 
    static void agencPercMaiorQZeroTest(){

        AltFormPgtoDAO dao = new AltFormPgtoDAO();

        Test.startTest();

        RemuneracaoProposta__c rp = [SELECT Id, Percentual__c FROM RemuneracaoProposta__c LIMIT 1];
        Quote proposta = getProposta();

        List<RemuneracaoProposta__c> rpRetorno = dao.agencPercMaiorQZero(proposta.Name, 'AGENCIAMENTO');

        Test.stopTest();

        Assert.areEqual(true, !rpRetorno.isEmpty(), 'Success');

    }

    @isTest
    static void verCodProdEmpTest(){

        AltFormPgtoDAO dao = new AltFormPgtoDAO();

        Test.startTest();

        Account conta = [SELECT Id, CodigoEmpresa__c FROM Account LIMIT 1];
        conta.CodigoEmpresa__c = '14';
        update conta;
        
        Product2 prodTec = [SELECT Id from Product2 WHERE Name = 'Nome Produto Tecnico'];
       
        Product2 prodCom = new Product2(
            ProdutoTecnico__c = prodTec.Id,
            Name = 'Nome Produto Comercial',
            Status__c = 'Em criação',
            TipoResponsavelPagamento__c = 'PAR',
            ProductCode = '201700001',
            Empresa__c = conta.Id
        );

        insert prodCom;

        Quote proposta = getProposta();
        proposta.Produto__r = prodCom;
        update proposta;

        proposta.Empresa__r = conta;
        update proposta;

        Quote prop = dao.verificarCodProdEmp(proposta.Name);

        Test.stopTest();

        Assert.areEqual('14', prop.Account.CodigoEmpresa__c, 'Success');

    }

    //II-176 INICIO
    @isTest
    static void verificarAntecipacaoProdTest() {
        AltFormPgtoDAO dao = new AltFormPgtoDAO();
        
        Test.startTest();
        
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        
        List<AntecipacaoComissao__c> antecipacaoRetorno = dao.verificaAntecipacaoProd(produto.Id);
        
        Test.stopTest();
    }
    
    @isTest
    static void verificarFavRemuneracaoProdTest() {
        AltFormPgtoDAO dao = new AltFormPgtoDAO();
        
        Test.startTest();
        
        Set<Id> remuneracaoPropIds = new Set<Id>();
        // adicione IDs válidos de RemuneracaoProposta__c à variável remuneracaoPropIds
        
        List<FavorecidoRemuneracaoProposta__c> favorecidoRetorno = dao.verificaFavRemuneracaoProd(remuneracaoPropIds);
        
        Test.stopTest();
    }
    
    @isTest
    static void getRemPropTest() {
        AltFormPgtoDAO dao = new AltFormPgtoDAO();
        
        Test.startTest();
        
        Quote proposta = [SELECT Id, Name FROM Quote LIMIT 1];
        
        List<RemuneracaoProposta__c> remPropRetorno = dao.getRemProp(proposta.Name);
        
        Test.stopTest();
    }
    
    @isTest
    static void getQuoteTest() {
        AltFormPgtoDAO dao = new AltFormPgtoDAO();
        
        Test.startTest();
        
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        
        Quote quoteRetorno = dao.getQuote(proposta.Id);
        
        Test.stopTest();
    }

    //II-176 FIM

    private static ContratanteProposta__c getContrProp(){
        return [
                SELECT 
                    Id, 
                    FormaPagamento__r.Name, 
                    FormaPagamento__r.Codigo__c, 
                    Proposta__r.Produto__c, 
                    PremioTotal__c, 
                    QuantidadeParcelas__c, 
                    VencimentoDemaisParcelas__c, 
                    Proposta__r.Name 
                FROM 
                    ContratanteProposta__c
                LIMIT 1
            ];
    }

    private static Quote getProposta(){
        return [
                SELECT 
                    Id,
                    Name,
                    Produto__r.Empresa__r.CodigoEmpresa__c
                FROM
                    Quote
                LIMIT 1
            ];
    }

    private static CondicaoCobranca__c getCondicaoCobranca(){
        return [
            SELECT
                Id,
                FormaPagamento__r.Codigo__c,
                NomeFormaPagamento__c,
                QuantidadeParcelas__c,
                AntecipacaoComissao__c
            FROM
                CondicaoCobranca__c
        ];
    }
}
//II-166 - FIM