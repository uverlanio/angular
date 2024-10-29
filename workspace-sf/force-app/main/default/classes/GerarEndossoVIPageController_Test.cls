/**
* EnderecoTrigger
* @author Gabriel Roetger Loch - gabriel.roetger@globant.com @ 19/10/2020
* PLV-4392-VI
**/
@isTest public class GerarEndossoVIPageController_Test {

    public static final String MOCK_RECUSAS = '{"recusas":[{"codigo":1, "mensagens":{"cliente":"Prezado cliente, favor selecionar todas as garantias obrigátorias"}}]}'; //FNPVVEP-91 - INICIO/FIM

    @TestSetup
    public static void setupData(){  
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        garantiaCobertura.Sigla__c = 'PP';
        update garantiaCobertura;
        
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Morte Acidental';
        garantiaCobertura2.Sigla__c = 'MA';
        update garantiaCobertura2;
        
        Garantia__c garantiaCobertura3 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Invalidez Permanente';
        garantiaCobertura2.Sigla__c = 'IP';
        update garantiaCobertura3;   
        
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantiaCobertura, ramoSeguro).createRecord();
        RamoGarantia__c ramoGarantia2 = new RamoGarantia__c(
            Garantia__c = garantiaCobertura2.Id,
            RamoSeguro__c = ramoSeguro.Id
        );
        insert ramoGarantia2;
        
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        GarantiaProduto__c gproduto = new GarantiaProduto__c(
            Garantia__c = garantiaCobertura2.Id,
            Produto__c = produtoTecnico.Id,
            RamoSeguro__c = ramoSeguro.Id,
            OrdemPrioridade__c = 2,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1');
        insert gproduto;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoProduto__c rem = (RemuneracaoProduto__c) new RemuneracaoProdutoFactory(tipoRemuneracao, produtoComercial).createRecord();
        
        GarantiaProduto__c garanProdCom2 =  new GarantiaProduto__c(
            Garantia__c = garantiaCobertura2.Id,
            GarantiaProduto__c = gproduto.Id,
            Produto__c = produtoComercial.Id,
            OrdemPrioridade__c = 2,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            RamoSeguro__c = ramoSeguro.Id,
            TipoCaracteristicaEspecial__c = 'Cestas',
            LimiteMaximoCaracteristicaEspecial__c = 1000000001,
            LimiteMinimoCaracteristicaEspecial__c = 10,
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1',
            Obrigatoria__c = true,
            PrazoMaximoLiquidacao__c = 10,
            TipoPrazoMaximoLiquidacao__c = 'Dia',
            PrazoAvisoSinistro__c = 20,
            TipoPrazoAvisoSinistro__c = 'Ano',
            OrigemSinistroBeneficio__c = 'Acidente',
            LimiteCapitalMinimo__c = 200,
            LimiteCapitalMaximo__c = 900000001,
            currencyIsoCode = 'BRL'
        );
        
        insert garanProdCom2;
        
        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantiaCobertura, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura, garanProdTec, ramoSeguro).createRecord();
        
        garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
        update garanProdCom;
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();

        //II-167 INICIO
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.Conta__c = conta.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c ='Corretor';
        favorecidoRemuneracaoContrato.Participacao__c =100;
        insert favorecidoRemuneracaoContrato;
        //II-167 FIM
        
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        contratante.Numero__c = 123;
        contratante.IOF__c = 10;
        contratante.Contrato__c = contrato.Id;
        update contratante;
        
        GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        grupo.Numero__c = 123;
        update grupo;
        
        SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
        segurado.Numero__c = 123;
        update segurado;
        
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();

        // INICIO - PLV-4614-VI-Guilherme Brito
        //Construtores
        EndossoTO.OrcamentoTO orc = new EndossoTO.OrcamentoTO();
        orc.closeDate = System.today().addDays(20);
        orc.consultivo = true;
        
        EndossoTO endosso = new EndossoTO();
        endosso.request = new EndossoTO.Request();

        EndossoTO.PremioTO PremioTO = new EndossoTO.PremioTO();
        PremioTO.comercial = 0.0;
        PremioTO.total = 0.0;
        PremioTO.puro = 0.0;
       // PremioTO.minimo = 1.1;

        EndossoTO.TaxaTO TaxaTO = new EndossoTO.TaxaTO();
        TaxaTO.comercial = 1.1;
        TaxaTO.total = 1.1;
        TaxaTO.pura = 1.1;

        EndossoTO.CoberturaTO CoberturaTO = new EndossoTO.CoberturaTO();
        CoberturaTO.moeda = '';
        CoberturaTO.cotacaoMoeda = 1.1;
        CoberturaTO.cobrado = '';

        EndossoTO.PessoaTO PessoaTO = new EndossoTO.PessoaTO();
        PessoaTO.rendaMensal = '';

        /*
         * PLV - 4655 INICIO
         * EndossoTO.DadosPessoaJuridicaTO DadosPessoaJuridicaTO = new EndossoTO.DadosPessoaJuridicaTO();
        DadosPessoaJuridicaTO.numeroCnpj = '';
        DadosPessoaJuridicaTO.digitoCnpj = '';
        DadosPessoaJuridicaTO.ordemCnpj = '';
		PLV - 4655 FIM
		*/

        EndossoTO.GrupoTO GrupoTO = new EndossoTO.GrupoTO();
        GrupoTO.tarifa = 1;
        GrupoTO.tipoCalculo = '';

        EndossoTO.RemuneracaoTO RemuneracaoTO = new EndossoTO.RemuneracaoTO();
        RemuneracaoTO.percentual = 1.1;
        RemuneracaoTO.tipoRemuneracao = '';
        remuneracaoTO.bonusCampanha = 5; //II-167 INICIO-FIM

        EndossoTO.Response Response = new EndossoTO.Response();
        Response.numeroOrcamento = '';
        Response.tipoSeguro = '';
        Response.status = '';

        // --------------------
        // FIM - PLV-4614-VI-Guilherme Brito

        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
        
        contrato.Empresa__c = '1';
        contrato.Sucursal__c = '1';
        contrato.NumeroApolice__c = '12345';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = contrato.StartDate.addMonths(3);  
        contrato.MeioComercializacao__c = 'ARQ';
        contrato.Proposta__c = proposta.Id;
        contrato.RamoSeguro__c = ramoSeguro.Id;
        contrato.PremioComercial__c = 2.2;
        contrato.PremioPuro__c = 2.2;
        contrato.PremioTotal__c = 2.2;
        update contrato;
        
        insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantiaCobertura.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme');
        insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantiaCobertura3.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme');
        
        
        TestDataFactory.gerarRemuneracaoContrato(contrato, TestDataFactory.gerarTipoRemuneracao('AGENCIAMENTO', 100, 200, null));
        TestDataFactory.gerarRemuneracaoContrato(contrato, TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 100, 200, null));
        
        
        List<Profissao__c> profissoes = new List<Profissao__c>();
        List<String> lstatus = new List<String>{'Em análise','Ativo','Inativo'};
            Integer x = 0;
        for(integer i=0; i<100; i++){
            Profissao__c profissao = new Profissao__c(
                NomeOcupacao__c = null,
                Name = null,
                NomeFantasia__c = null,
                NomeFamilia__c = null,
                NomeSubGrupo__c = null,
                NomeSubGrupoPrincipal__c = null,
                NomeGrandeGrupo__c = 'teste',
                CodigoProfissao__c = null,
                Codigo__c = null,
                CodigoFamilia__c = null,
                CodigoSubGrupo__c = null,
                CodigoSubGrupoPrincipal__c = null,
                CodigoGrandeGrupo__c = '8'
            );
            profissao.name =' teste '+i;
            profissao.Status__c = lstatus[x];
            if(x<2) x=x+1; else x=0;
            profissao.Codigo__c = i+''+x+''+profissao.Status__c;
            profissoes.add(profissao);
        }
        insert profissoes;

        //II-149 - INICIO
        Franquia__c franquia = new Franquia__c(
            CodigoFranquia__c = 'FR_REDUZIDA'
        );

        insert franquia;

        FranquiaGarantia__c franquiaGarantia = new FranquiaGarantia__c(
            GarantiaProduto__c = gproduto.Id,
            Franquia__c = franquia.Id,
            Franquia__r = franquia
        );

        insert franquiaGarantia;

        GarantiaContrato__c gc = new GarantiaContrato__c(
            Contrato__c = contrato.Id,
            FranquiaGarantia__r = franquiaGarantia,
            FranquiaGarantia__c = franquiaGarantia.Id
        );

        insert gc;        
        //II-149 - FIM 
        // FNPVVEP-91 - INICIO
        Pergunta__c pergunta = new Pergunta__c(
            TipoResposta__c = 'Texto',
            Status__c = 'Ativo',
            Pergunta__c = 'qual o teste'
        );
        insert pergunta;

        Questionario__c questAR = TestDataFactory.gerarQuestionario();

        PerguntaQuestionario__c perguntaQuestionario = new PerguntaQuestionario__c(
            Pergunta__c = pergunta.Id,
            Questionario__c = questAR.Id,
            Numero__c = 1
        );
        insert perguntaQuestionario;

        //RespostaDeclaracaoSaude__c respostaDeclaracao = new RespostaDeclaracaoSaude__c(
        //  DeclaracaoSaude__c = healtStatement
        //);
        //insert respostaDeclaracao;
        //tentar cobrir 

        DeclaracaoSaude__c healthStatement = new DeclaracaoSaude__c(
            Contrato__c = contrato.Id,
			Conta__c = conta.Id,
        	Proposta__c = contrato.Proposta__c
        );
        insert healthStatement;
        // FNPVVEP-91 - FIM       
    }
    @isTest static void testeInvalidContract(){    
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract tempCtr = new Contract();
        
        testPage.getParameters().put('Id', '123');
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(tempCtr);      
        
        Test.startTest();
        String calloutMessage = null;
        try{
            GerarEndossoVIPageController pageController = new GerarEndossoVIPageController(sc);
        } catch (CalloutException expt){
            calloutMessage = expt.getMessage();
        }
        
        system.assertEquals(calloutMessage, 'Contrato não informado');
        Test.stopTest();
    } 
    
    @isTest static void testeContratoNaoEmitido(){    
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [SELECT  id from Contract limit 1];
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();
        String calloutMessage = null;
        try{
            GerarEndossoVIPageController pageController = new GerarEndossoVIPageController(sc);
        } catch (CalloutException expt){
            calloutMessage = expt.getMessage();
        }
        
        system.assertEquals(calloutMessage, 'Contrato não Emitido');
        Test.stopTest();
        //Segmento de produto não permite endosso de contrato
    } 
    
    @isTest static void testeContratoValido(){    
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();
        String calloutMessage = null;
        try{
            GerarEndossoVIPageController pageController = new GerarEndossoVIPageController(sc);
        } catch (CalloutException expt){
            calloutMessage = expt.getMessage();
        }
        
        system.assertEquals(calloutMessage, 'Segmento de produto não permite endosso de contrato');
        Test.stopTest();
    }
    
    @isTest static void testeSegmentoInvalido(){    
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id, Produto__c from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();
        GerarEndossoVIPageController pageController = new GerarEndossoVIPageController(sc);
        
        Test.stopTest();
    } 
    @isTest static void testGetProfessions(){
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id, Produto__c from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        GerarEndossoVIPageController pageController = new GerarEndossoVIPageController(sc);
        
        Test.startTest();
        pageController.getProfessions();
        Test.stopTest();
    }
    @isTest
    public static void GerarPayloadTest(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_RECUSAS, 200, 'OK')); //FNPVVEP-91 - INICIO/FIM

        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id, Produto__c from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);
        
        
        GerarEndossoVIPageController.EntradaPessoa entradaPessoa = new GerarEndossoVIPageController.EntradaPessoa();
        GerarEndossoVIPageController.EntradaCobertura cobertura = new GerarEndossoVIPageController.EntradaCobertura();
        List<GerarEndossoVIPageController.EntradaCobertura> coberturas = new List<GerarEndossoVIPageController.EntradaCobertura>();
        
        cobertura.sigla = 'MA'; //PLV-4481 DIT - VINICIUS - INICIO/FIM
        cobertura.valor = 232;
        cobertura.moeda = 'Teste'; 
        cobertura.cotacaoMoeda = '1.1';
        cobertura.quantidade = '';
        cobertura.cobrado = 'Teste';
        coberturas.add(cobertura);
        
        entradaPessoa.nome = 'test';
        entradaPessoa.dataNascimento = String.valueOf(system.today()); 
        entradaPessoa.sexo = '';
        entradaPessoa.profissao = '2111-05';
        //entradaPessoa.profissao = '9154-05';
        entradaPessoa.regimeTrabalho = '';
        entradaPessoa.percentual = 100;
        entradaPessoa.coberturas = coberturas;
        entradaPessoa.regimeTrabalho = '';
        
        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();
        
		//PLV 4518 Fix2 Inicio
        profissao.IdExterno__c = '2111-05';
        //profissao.CodigoProfissao__c = '9154-05';
		//PLV 4518 Fix2 Fim
        profissao.Name = 'Atuário';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;
        
        Test.startTest();
        GerarEndossoVIPageController pageController = new GerarEndossoVIPageController(sc);
        pageController.entradaCalculo = JSON.serialize(entradaPessoa);
        pageController.gerarPayload();
        Test.stopTest();
    }

    //II-149 - INICIO
    @isTest static void testFranquiaReduzida(){

        List<GarantiaContrato__c> lctrs = [SELECT Id, Contrato__c FROM GarantiaContrato__c];

        String codFranq = GerarEndossoVIPageController.getCodigoFranq(lctrs[2].Contrato__c);

        Assert.areEqual('FR_REDUZIDA', codFranq, 'Success');
    }
    //II-149 - FIM

    //FNPVVEP-29 - INICIO
    @isTest
    static void testRedirecionarEndosso() {
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [SELECT id, Produto__c FROM Contract LIMIT 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);
        Test.startTest();
        GerarEndossoVIPageController pageController = new GerarEndossoVIPageController(sc);
        //FNPVVEP-91 - INICIO
        PageReference result = pageController.redirecionarEndosso();
        String expectedUrl = '/' + ctr.Id;
        System.assertEquals(expectedUrl, result.getUrl(), 'A URL retornada não está correta');
        //FNPVVEP-91 - FIM
        Test.stopTest();
    }

    @isTest
    static void testGetTitleEndosso() {
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [SELECT id, Produto__c, Produto__r.CodigoPrecificaProduto__c FROM Contract LIMIT 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);
        Test.startTest();
        GerarEndossoVIPageController controller = new GerarEndossoVIPageController(sc);
        controller.contract = ctr;
        String tituloObtido = controller.getTitleEndosso();
        Test.stopTest();
    }

    @isTest
    static void testIsAPTLMKT() {
        PageReference testPage = Page.GerarEndossoVidaIndividual; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [SELECT id, Produto__c, Produto__r.CodigoPrecificaProduto__c FROM Contract LIMIT 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        prod.CodigoPrecificaProduto__c = 'APTLMKT';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);
        Test.startTest();
        GerarEndossoVIPageController controller = new GerarEndossoVIPageController(sc);
        controller.contract = ctr;
        Boolean resultadoObtido = controller.isAPTLMKT();
        Test.stopTest();
    }
    //FNPVVEP-29 - FIM
    // FNPVVEP-91 - INICIO
    @IsTest static void testCalculoEndosso() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_RECUSAS, 200, 'OK'));

        PageReference testPage = Page.GerarEndossoVidaIndividual;
        Test.setCurrentPage(testPage);

        Contract ctr = [SELECT id, Oportunidade__r.Numero__c,Oportunidade__r.NumeroOferta__c,Produto__c, StartDate, Produto__r.CodigoPrecificaProduto__c, Oportunidade__r.CanalDistribuicao__r.Sigla__c, Oportunidade__r.NumeroPortal__c, Oportunidade__r.TipoVigencia__c, VigenciaFinal__c, Produto__r.Segmento__c, Sucursal__c, Empresa__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, TipoContrato__c FROM Contract LIMIT 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        update prod;
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);
        //String payload = GerarPayloadTest()/

        GerarEndossoVIPageController.EntradaPessoa entradaPessoa = new GerarEndossoVIPageController.EntradaPessoa();
        GerarEndossoVIPageController.EntradaCobertura cobertura = new GerarEndossoVIPageController.EntradaCobertura();
        List<GerarEndossoVIPageController.EntradaCobertura> coberturas = new List<GerarEndossoVIPageController.EntradaCobertura>();
        
        cobertura.sigla = 'MA'; 
        cobertura.valor = 232;
        cobertura.moeda = 'Teste'; 
        cobertura.cotacaoMoeda = '1.1';
        cobertura.quantidade = '';
        cobertura.cobrado = 'Teste';
        coberturas.add(cobertura);
        
        entradaPessoa.nome = 'test';
        entradaPessoa.dataNascimento = String.valueOf(system.today()); 
        entradaPessoa.sexo = '';
        entradaPessoa.profissao = '2111-05';
        //entradaPessoa.profissao = '9154-05';
        entradaPessoa.regimeTrabalho = '';
        entradaPessoa.percentual = 100;
        entradaPessoa.coberturas = coberturas;
        entradaPessoa.regimeTrabalho = '';
        
        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();
        
		//PLV 4518 Fix2 Inicio
        profissao.IdExterno__c = '2111-05';
        //profissao.CodigoProfissao__c = '9154-05';
		//PLV 4518 Fix2 Fim
        profissao.Name = 'Atuário';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;

        Test.startTest();
        GerarEndossoVIPageController controller = new GerarEndossoVIPageController(sc);
        controller.contract = ctr;
        //controller.payload = payload;
        controller.entradaCalculo = JSON.serialize(entradaPessoa);
        controller.calculoEndosso();
        Test.stopTest();
    }
    // FNPVVEP-91 - FIM

    //FNPVVEP-91 - INICIO
    @IsTest static void testeMockCalculo() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(MOCK_RECUSAS,
                                                                 200,
                                                                 'OK'));

        PageReference testPage = Page.GerarEndossoVidaIndividual;
        Test.setCurrentPage(testPage);

        Contract ctr = [SELECT id, Oportunidade__r.Numero__c,Oportunidade__r.NumeroOferta__c,Produto__c, StartDate, Produto__r.CodigoPrecificaProduto__c, Oportunidade__r.CanalDistribuicao__r.Sigla__c, Oportunidade__r.NumeroPortal__c, Oportunidade__r.TipoVigencia__c, VigenciaFinal__c, Produto__r.Segmento__c, Sucursal__c, Empresa__c, CodigoRamo__c, NumeroApolice__c, Endosso__c, TipoContrato__c FROM Contract LIMIT 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Individual';
        update prod;
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);
        //String payload = GerarPayloadTest()/

        GerarEndossoVIPageController.EntradaPessoa entradaPessoa = new GerarEndossoVIPageController.EntradaPessoa();
        GerarEndossoVIPageController.EntradaCobertura cobertura = new GerarEndossoVIPageController.EntradaCobertura();
        List<GerarEndossoVIPageController.EntradaCobertura> coberturas = new List<GerarEndossoVIPageController.EntradaCobertura>();
        
        cobertura.sigla = 'MA'; 
        cobertura.valor = 232;
        cobertura.moeda = 'Teste'; 
        cobertura.cotacaoMoeda = '1.1';
        cobertura.quantidade = '';
        cobertura.cobrado = 'Teste';
        coberturas.add(cobertura);
        
        entradaPessoa.nome = 'test';
        entradaPessoa.dataNascimento = String.valueOf(system.today()); 
        entradaPessoa.sexo = '';
        entradaPessoa.profissao = '2111-05';
        //entradaPessoa.profissao = '9154-05';
        entradaPessoa.regimeTrabalho = '';
        entradaPessoa.percentual = 100;
        entradaPessoa.coberturas = coberturas;
        entradaPessoa.regimeTrabalho = '';
        
        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();
        
        //PLV 4518 Fix2 Inicio
        profissao.IdExterno__c = '2111-05';
        //profissao.CodigoProfissao__c = '9154-05';
        //PLV 4518 Fix2 Fim
        profissao.Name = 'Atuário';
        insert profissao;
        grupoRisco.Name = 'DIT';
        Insert grupoRisco;
        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;

        Test.startTest();
        GerarEndossoVIPageController controller = new GerarEndossoVIPageController(sc);
        controller.contract = ctr;
        //controller.payload = payload;
        controller.entradaCalculo = JSON.serialize(entradaPessoa);
        controller.calculoEndosso();
        Test.stopTest();
    }
    //FNPVVEP-91 - FIM

}