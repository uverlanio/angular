/********************************************************************************************************************
* Gerar Endosso Viagem Page Controller Test
* @author Squad_Globant
* @date 30/06/2021
* Classe criada por conta da história PLV-5063
*********************************************************************************************************************/
@isTest 
public class GerarEndossoViagemPageControllerTest {
    @TestSetup
    public static void setupData(){  

        Account conta = new Account(
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
			LastName = 'Teste',
			Nacionalidade__c = 'Brasileira',
			CPF__c = '00478394659',
			Rg__c = '232323231',
			DataExpedicao__c = Date.today(),
			OrgaoExpedidor__c = '123132',
			PersonBirthDate = (Date.today()-7300),
			EstadoCivil__c = 'Solteiro (a)'
		);
		insert conta;
        

        ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

		Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        garantiaCobertura.Sigla__c = 'PP';
        garantiaCobertura.Tipo__c = 'Cobertura';
        update garantiaCobertura;
        
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Morte Acidental';
        garantiaCobertura2.Sigla__c = 'MA';
        garantiaCobertura2.Tipo__c = 'Cobertura';
        update garantiaCobertura2;
        
        Garantia__c garantiaCobertura3 = TestDataFactory.gerarGarantia();
        garantiaCobertura3.name = 'Invalidez Permanente';
        garantiaCobertura3.Sigla__c = 'IP';
        garantiaCobertura3.Tipo__c = 'Cobertura';
        update garantiaCobertura3;

		RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantiaCobertura, ramoSeguro).createRecord();
        RamoGarantia__c ramoGarantia2 = new RamoGarantia__c(
            Garantia__c = garantiaCobertura2.Id,
            RamoSeguro__c = ramoSeguro.Id
        );
        insert ramoGarantia2;

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();

        List<Account> conta1 = [SELECT id FROM Account WHERE LastName = 'Teste'];
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.Segmento__c = 'Viagem';
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
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.Segmento__c = 'Viagem';
		update produtoComercial;  

        //TKCL-246 FIX05 INICIO
        Product2 produtoTecnicoAp = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnicoAp.Status__c = 'Em ativação';
        produtoTecnicoAp.NumeroSusep__c = '123';
        produtoTecnicoAp.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnicoAp;
        produtoTecnicoAp.Status__c = 'Ativo';
        produtoTecnicoAp.ProductCode = '49';
        produtoTecnicoAp.Segmento__c = 'Viagem';
        update produtoTecnicoAp;
        Product2 produtoComercialAp = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnicoAp).createRecord();
        produtoComercialAp.Status__c = 'Ativo';
        produtoComercialAp.ProductCode = 'APTLMKT';
        produtoComercialAp.Segmento__c = 'Viagem';
        produtoComercialAp.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercialAp;
        //TKCL-246 FIX05 FIM

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

		Opportunity oportunidade = new Opportunity(
			Name = 'Teste Contrato',
			StageName = 'Em criação',
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
			AccountId = conta.Id,
			CloseDate = Date.today()
		);
		insert oportunidade;

		Quote proposta = new Quote(
			Name= 'Teste Contrato',
			OpportunityId=oportunidade.Id,
			DataProtocolo__c = Date.today(),
			DataCalculo__c =  Date.today(),
			Empresa__c = conta.Id,
			ExpirationDate = Date.today(),
            Produto__c = produtoComercial.Id
		);
		insert proposta;

        // //TKCL-246 FIX05 INICIO
        // Quote propostaAP = new Quote(
		// 	Name= 'Teste Contrato',
		// 	OpportunityId=oportunidade.Id,
		// 	DataProtocolo__c = Date.today(),
		// 	DataCalculo__c =  Date.today(),
		// 	Empresa__c = conta.Id,
		// 	ExpirationDate = Date.today(),
        //     Produto__c = produtoComercial.Id 
		// );
		// insert propostaAP;
        // //TKCL-246 FIX05 FIM

		ContratanteProposta__c segurado = new ContratanteProposta__c(
			conta__c = conta.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Principal'
		);
		insert segurado;

		GrupoProposta__c grupo = new GrupoProposta__c(
			Name = 'Teste',
			QuantidadeVidas__c = 1,
			ContratanteProposta__c = segurado.Id
		);
		insert grupo;

		SeguradoProposta__c vida = new SeguradoProposta__c(
			Conta__c = conta.Id,
			GrupoProposta__c = grupo.Id
		);
		insert vida;

		BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c(
			SeguradoProposta__c = vida.Id,
			CpfCnpj__c = '00478394659',
			Nome__c = 'Teste Contrato',
			TipoBeneficiario__c = 'Nome do beneficiário',
			GrauParentesco__c = 'Pai',
			Participacao__c = 100,
			Pep__c = 'Não'
		);
		insert beneficiario;

		BeneficiarioSeguradoProposta__c beneficiario2 = new BeneficiarioSeguradoProposta__c(
			SeguradoProposta__c = vida.Id,
			CpfCnpj__c = '99235310075',
			Nome__c = 'Teste Contrato',
			TipoBeneficiario__c = 'Nome do beneficiário',
			GrauParentesco__c = 'Pai',
			Participacao__c = 100,
			Pep__c = 'Não'
		);
        insert beneficiario2;
        
        Quote proposta1 = [SELECT Id FROM Quote WHERE Name = 'Teste Contrato'];
		Opportunity oportunidade1 = [SELECT Id FROM Opportunity WHERE Name = 'Teste Contrato'];	
        
		Account contaParceiro = new Account(Name = 'ParceiroTeste', CodigoEmpresa__c = '12', IdExterno__c = '67708896000139', Inscricao_Municipal__c = '123456789', Cnpj__c = '67.708.896/0001-39'); // PLV-4445
        insert contaParceiro;
        FormaPagamento__c formaPagamento2 = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
		Parceiro__c parceiro  = TestDataFactory.gerarParceiro(contaParceiro,formaPagamento2);	
		Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();

		contrato.Empresa__c = '1';
        contrato.Sucursal__c = '1';
        contrato.NumeroApolice__c = '12345';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c=System.today().addDays(360);  
        contrato.MeioComercializacao__c = 'ARQ';
        contrato.Proposta__c = proposta.Id;
        contrato.RamoSeguro__c = ramoSeguro.Id;
        update contrato;

		insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantiaCobertura.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme');
        insert new GarantiaContrato__c(Contrato__c = contrato.Id, Garantia__c = garantiaCobertura3.Id, Capital__c = 10000.00, TipoCapital__c = 'Capital uniforme');
        
		TestDataFactory.gerarRemuneracaoContrato(contrato, TestDataFactory.gerarTipoRemuneracao('AGENCIAMENTO', 100, 200, null));
        TestDataFactory.gerarRemuneracaoContrato(contrato, TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 100, 200, null));
                
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, conta, conta);
		GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c seguradoContrato = TestDataFactory.gerarSeguradoContrato(grupoContrato, conta);
        
        ParcelamentoContratoTO parcelamentoContrato = new ParcelamentoContratoTO();
        
        ParcelamentoContratoTO.MetaTO meta = new ParcelamentoContratoTO.MetaTO();
        meta.dataExecucao = '';
        meta.servico = '';
        meta.statusHttp = 0;
        meta.mensagem = '';
        
        List<ParcelamentoContratoTO.DataTO> lstData = new List<ParcelamentoContratoTO.DataTO>();
        ParcelamentoContratoTO.DataTO data = new ParcelamentoContratoTO.DataTO();
        data.idfatura = 0;
        data.status = '';
        data.endosso = '';
        data.idexterno = '';
        data.valorparcela = '';
        data.seguradosalesforce = '';
        data.vidasalesforce = '';
        data.valoriof = '';
        data.id = 0;
        data.empresa = '';
        data.ramo = '';
        data.numeroparcela = 1;
        data.apolice = '';
        data.responsavelfinanceiro = '';
        data.titulo = '';
        data.origemproposta = 1;
        data.idparceiro = '';
        data.datavencimento = '';
        data.contrato = '';
        data.numeroproposta = '';
        data.valorliquido = '';
        data.sucursal = '';
        
        lstData.add(data);
        
        parcelamentoContrato.meta = meta;
        parcelamentoContrato.data = lstData;
        
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(parcelamentoContrato), 200, 'OK'));

        Account contaCorretor = new Account(Name = 'ContaCorretor', Papel__c = 'Corretor', IdExterno__c = '38012786532', Cnpj__c = '38.579.897/0001-22');       
        insert contaCorretor;                   
        
        Account contaCorretorTest = [SELECT Id,Name FROM Account  WHERE Papel__c = 'Corretor' LIMIT 1];
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaCorretorTest);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaCorretorTest);
        InformacaoBancaria__c informacaoBancariaParceiro = TestDataFactory.gerarInformacaoBancaria(contaParceiro);
        informacaoBancariaParceiro.Principal__c = true;
        update informacaoBancariaParceiro;

        //PLV-5063 - FIX01 - REMOÇÃO DE CODIGO - INICIO/FIM
        
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
            Name = 'CORRETAGEM',
            Codigo__c = 'COR',
            LimiteMinimo__c = 0,
            LimiteMaximo__c = 100
        );		
		insert tipoRemuneracao;

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro = new RemuneracaoProdutoParceiro__c(
                Percentual__c = 20,
                TipoRemuneracao__c = tipoRemuneracao.Id,
                ProdutoParceiro__c = produtoParceiro.Id
        );
        insert remuneracaoProdutoParceiro;

        FavorecidoRemuneracao__c favorecidoRemuneracao = new FavorecidoRemuneracao__c(
            Conta__c = contaCorretorTest.Id,
            Percentual__c = 80.00,
            Papel__c = 'Corretor',
            Lider__c = true,            
            DadosCorretor__c = (dadosCorretor != null) ? dadosCorretor.Id : null,
            RemuneracaoProdutoParceiro__c = remuneracaoProdutoParceiro.Id,
            InformacaoBancaria__c = informacaoBancaria.Id
        );
        insert favorecidoRemuneracao;

        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);        

        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c(
            Conta__c = contaCorretorTest.Id,
            CorretorLider__c = TRUE,
            RemuneracaoContrato__c = remuneracaoContrato.Id,
            Susep__c ='p5005j',
            SusepEmissao__c ='p5005j',
            SusepOrcamento__c='p5005j',
            DadosCorretor__c = dadosCorretor.Id,
            Papel__c ='Corretor',
            Participacao__c =100
        );
        insert favorecidoRemuneracaoContrato;

        ParametroVigencia__c parVGViagem = new ParametroVigencia__c(
            Produto__c = produtoComercial.Id,
            PeriodoMaximoVigencia__c = 10,
            PeriodoMinimoVigencia__c = 1,
            PeriodoMaximoInadimplencia__c = 90
        );
        insert parVGViagem;   
        
        DeclaracaoSaude__c healthStatement = new DeclaracaoSaude__c(
            Contrato__c = contrato.Id,
			Conta__c = conta.Id,
        	Proposta__c = proposta.Id
        );
		insert healthStatement;
    }
    @isTest static void testInvalidContract(){    
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);
        
        Contract tempCtr = new Contract();
        
        testPage.getParameters().put('Id', '123');
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(tempCtr);      
        
        Test.startTest();
        String calloutMessage = null;
        try{
            GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        } catch (CalloutException expt){
            calloutMessage = expt.getMessage();
        }
        Test.stopTest();
    } 
    
    @isTest static void testContratoNaoEmitido(){    
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id from Contract limit 1];
        ctr.Status = 'Em elaboração';
        update ctr;

        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();
        String calloutMessage = null;
        try{
            GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        } catch (CalloutException expt){
            calloutMessage = expt.getMessage();
        }
        Test.stopTest(); 
        system.assertEquals(calloutMessage, 'Endosso não permitido - Contrato não Emitido');       
    } 
    
    @isTest static void testContratoValido(){    
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();
        String calloutMessage = null;
        GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);        
        Test.stopTest();
    } 
    
    @isTest static void testSegmentoInvalido(){    
        PageReference testPage = Page.GerarEndossoViagem; 
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
        String calloutMessage = null;
        try{
            GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        } catch (CalloutException expt){
            calloutMessage = expt.getMessage();
        }        
        Test.stopTest();
        system.assertEquals(calloutMessage, 'Endosso não permitido - Segmento de produto não permite endosso de contrato');
    } 

    @isTest static void testSegmentoValido(){    
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id, Produto__c from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Viagem';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();        
        GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);            
        Test.stopTest();        
    } 
    @isTest static void testGetProfessions(){
        //AV-824 - INICIO            
        Test.startTest();
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id, Produto__c from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Viagem';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        pageController.getProfessions();
        Test.stopTest();
        //AV-824 - FIM
    } 
    
    @isTest static void testcalculoEndossoForaVigencia(){
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);     
        
        Contract ctr = [Select id, Produto__c from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Viagem';
        update prod; 

        ParametroVigencia__c parametroVigencia = [ 
            SELECT PeriodoMaximoVigencia__c 
            FROM ParametroVigencia__c 
            WHERE Produto__c =: ctr.Produto__c
        ];

        GerarEndossoViagemPageController.EntradaPessoa entradaPessoa = new GerarEndossoViagemPageController.EntradaPessoa();
        GerarEndossoViagemPageController.EntradaCobertura cobertura = new GerarEndossoViagemPageController.EntradaCobertura();
        List<GerarEndossoViagemPageController.EntradaCobertura> coberturas = new List<GerarEndossoViagemPageController.EntradaCobertura>();
        GerarEndossoViagemPageController.DestinoTo destino = new GerarEndossoViagemPageController.DestinoTo();
        List<GerarEndossoViagemPageController.DestinoTo> destinos = new List<GerarEndossoViagemPageController.DestinoTo>();

        destino.codigo = 'DESTINO';
        destino.pais = 'BRASIL';        
        destinos.add(destino);        

        entradaPessoa.destinos = destinos;        
        
        cobertura.sigla = 'RPR'; 
        cobertura.valor = 5000.00;
        cobertura.moeda = 'BRL'; 
        cobertura.cotacaoMoeda = '4.04720000';
        cobertura.quantidade = '';
        cobertura.cobrado = 'Remarcação de Passagem para Regresso';
        coberturas.add(cobertura);      

        entradaPessoa.inicioVigencia = Date.valueOf('2021-06-23');
        entradaPessoa.finalVigencia = Date.valueOf('2021-12-01');
        entradaPessoa.tipoViagem = 'NACIONAL';
        entradaPessoa.passageirosIdosos = 0;
        entradaPessoa.passageirosNaoIdosos = 1;
        entradaPessoa.utilizaraMotocicleta = false;
        entradaPessoa.praticaEsportesAventura = false;        
                
        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();        
    
        profissao.IdExterno__c = '2111-05';      
        profissao.Name = 'Atuário';
        insert profissao;

        grupoRisco.Name = 'DIT';
        insert grupoRisco;

        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;    
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);                
        
        Test.startTest();
        GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        pageController.entradaCalculo = JSON.serialize(entradaPessoa);
        pageController.calculoEndosso();
        Test.stopTest();
    }
    
    // @isTest static void testcalculoEndossoDentroVigencia(){
    //     PageReference testPage = Page.GerarEndossoViagem; 
    //     Test.setCurrentPage(testPage);     
        
    //     Contract ctr = [Select id, Produto__c from Contract limit 1];
    //     ctr.Status = 'Emitido';
    //     update ctr;
        
    //     Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
    //     prod.Segmento__c = 'Viagem';
    //     update prod; 

    //     ParametroVigencia__c parametroVigencia = [ 
    //         SELECT PeriodoMaximoVigencia__c 
    //         FROM ParametroVigencia__c 
    //         WHERE Produto__c =: ctr.Produto__c
    //     ];

    //     FavorecidoRemuneracao__c favorecidoRemuneracaoEndosso = [ 
    //         SELECT Conta__c, Percentual__c, Papel__c, Lider__c, DadosCorretor__c, 
    //         RemuneracaoProdutoParceiro__c, InformacaoBancaria__c 
    //         FROM FavorecidoRemuneracao__c 
    //         LIMIT 1
    //     ];

    //     RemuneracaoContrato__c remuneracaoContratoEndosso = [ 
    //         SELECT Contrato__c, TipoRemuneracao__c 
    //         FROM RemuneracaoContrato__c 
    //         LIMIT 1
    //     ];

    //     FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = [ 
    //         SELECT Conta__c, CorretorLider__c, RemuneracaoContrato__c, Susep__c, SusepEmissao__c, 
    //         SusepOrcamento__c, DadosCorretor__c, Papel__c, Participacao__c 
    //         FROM FavorecidoRemuneracaoContrato__c 
    //         LIMIT 1
    //     ];        

    //     GerarEndossoViagemPageController.EntradaPessoa entradaPessoa = new GerarEndossoViagemPageController.EntradaPessoa();
    //     GerarEndossoViagemPageController.EntradaCobertura cobertura = new GerarEndossoViagemPageController.EntradaCobertura();
    //     List<GerarEndossoViagemPageController.EntradaCobertura> coberturas = new List<GerarEndossoViagemPageController.EntradaCobertura>();
    //     GerarEndossoViagemPageController.DestinoTo destino = new GerarEndossoViagemPageController.DestinoTo();
    //     List<GerarEndossoViagemPageController.DestinoTo> destinos = new List<GerarEndossoViagemPageController.DestinoTo>();           

    //     destino.codigo = 'DESTINO';
    //     destino.pais = 'BRASIL';        
    //     destinos.add(destino);        

    //     entradaPessoa.destinos = destinos;        
        
    //     cobertura.sigla = 'RPR'; 
    //     cobertura.valor = 5000.00;
    //     cobertura.moeda = 'BRL'; 
    //     cobertura.cotacaoMoeda = '4.04720000';
    //     cobertura.quantidade = '';
    //     cobertura.cobrado = 'Remarcação de Passagem para Regresso';
    //     coberturas.add(cobertura);      

    //     entradaPessoa.inicioVigencia = Date.valueOf('2021-06-23');
    //     entradaPessoa.finalVigencia = Date.valueOf('2021-06-29');
    //     entradaPessoa.tipoViagem = 'NACIONAL';
    //     entradaPessoa.passageirosIdosos = 0;
    //     entradaPessoa.passageirosNaoIdosos = 1;
    //     entradaPessoa.utilizaraMotocicleta = false;
    //     entradaPessoa.praticaEsportesAventura = false;        
                
    //     GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
    //     GrupoRisco__c grupoRisco = new GrupoRisco__c();
    //     Profissao__c profissao = new Profissao__c();        
    
    //     profissao.IdExterno__c = '2111-05';      
    //     profissao.Name = 'Atuário';
    //     insert profissao;

    //     grupoRisco.Name = 'DIT';
    //     insert grupoRisco;

    //     grupoProfissao.grupoRisco__c = grupoRisco.Id;
    //     grupoProfissao.profissao__c = profissao.Id;
    //     insert grupoProfissao;    
        
    //     testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
    //     ApexPages.StandardController sc = new  ApexPages.StandardController(ctr); 
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(entradaPessoa), 200, 'OK')); 
        
    //     Test.startTest();
    //     //MGRC-1657 - INICIO
    //     // CIVServices services = CIVServices.getInstance();
    //     // String retorno = services.criacaoCalculo(JSON.serialize(entradaPessoa));

    //     GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
    //     pageController.entradaCalculo = JSON.serialize(entradaPessoa);
    //     pageController.calculoEndosso();
    //     //MGRC-1657 - FIM
    //     Test.stopTest();
    // }

    @isTest static void testRedirectContractRecord(){
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [SELECT id, Produto__c FROM Contract LIMIT 1];
        ctr.Status = 'Emitido';
        update ctr;        
                
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        
        Test.startTest();
        pageController.RedirectContractRecord();
        Test.stopTest();
    }
    
    @isTest static void testContratoNaoVigente(){    
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);
        
        Contract ctr = [Select id from Contract limit 1];
        ctr.Status = 'Emitido';
        ctr.VigenciaFinal__c = Date.valueOf('2021-06-23');
        update ctr;

        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();
        String calloutMessage = null;
        try{
            GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        } catch (CalloutException expt){
            calloutMessage = expt.getMessage();
        }
        Test.stopTest(); 
        system.assertEquals(calloutMessage, 'Endosso não permitido - Contrato não vigente');       
    } 

		@isTest static void testsetupGetHealthStatement(){    
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);

		Quote prp = [SELECT id FROM Quote LIMIT 1];

        Contract ctr = [SELECT id FROM Contract LIMIT 1];
        ctr.Status = 'Emitido';
        ctr.VigenciaFinal__c = System.today().addDays(360);
        update ctr;

        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        Test.startTest();
        GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
        pageController.getHealthStatement(prp.Id);
        Test.stopTest(); 
        
    } 
    
    // @isTest
    // public static void testGerarPayload(){
        
    //     PageReference testPage = Page.GerarEndossoViagem; 
    //     Test.setCurrentPage(testPage);        
        
    //     Contract ctr = [SELECT id, Produto__c FROM Contract LIMIT 1];
    //     ctr.Status = 'Emitido';
    //     update ctr;
        
    //     Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
    //     prod.Segmento__c = 'Viagem';
    //     update prod; 
        
    //     testPage.getParameters().put('Id', String.valueOf(ctr.Id));
    //     ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
    //     GerarEndossoViagemPageController.EntradaPessoa entradaPessoa = new GerarEndossoViagemPageController.EntradaPessoa();
    //     GerarEndossoViagemPageController.EntradaCobertura cobertura = new GerarEndossoViagemPageController.EntradaCobertura();
    //     List<GerarEndossoViagemPageController.EntradaCobertura> coberturas = new List<GerarEndossoViagemPageController.EntradaCobertura>();
    //     GerarEndossoViagemPageController.DestinoTo destino = new GerarEndossoViagemPageController.DestinoTo();
    //     List<GerarEndossoViagemPageController.DestinoTo> destinos = new List<GerarEndossoViagemPageController.DestinoTo>();

    //     destino.codigo = 'DESTINO';
    //     destino.pais = 'BRASIL';        
    //     destinos.add(destino);        

    //     entradaPessoa.destinos = destinos;        
        
    //     cobertura.sigla = 'RPR'; 
    //     cobertura.valor = 5000.00;
    //     cobertura.moeda = 'BRL'; 
    //     cobertura.cotacaoMoeda = '4.04720000';
    //     cobertura.quantidade = '';
    //     cobertura.cobrado = 'Remarcação de Passagem para Regresso';
    //     coberturas.add(cobertura);      

    //     entradaPessoa.inicioVigencia = Date.valueOf('2021-06-23');
    //     entradaPessoa.finalVigencia = Date.valueOf('2021-12-01');
    //     entradaPessoa.tipoViagem = 'NACIONAL';
    //     entradaPessoa.passageirosIdosos = 0;
    //     entradaPessoa.passageirosNaoIdosos = 1;
    //     entradaPessoa.utilizaraMotocicleta = false;
    //     entradaPessoa.praticaEsportesAventura = false;        
               
    //     GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
    //     GrupoRisco__c grupoRisco = new GrupoRisco__c();
    //     Profissao__c profissao = new Profissao__c();        
	
    //     profissao.IdExterno__c = '2111-05';      
    //     profissao.Name = 'Atuário';
    //     insert profissao;

    //     grupoRisco.Name = 'DIT';
    //     insert grupoRisco;

    //     grupoProfissao.grupoRisco__c = grupoRisco.Id;
    //     grupoProfissao.profissao__c = profissao.Id;
    //     insert grupoProfissao;

    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(entradaPessoa), 200, 'OK')); 
        
    //     Test.startTest();
    //     //MGRC-1657 - INICIO
    //     // CIVServices services = CIVServices.getInstance();
    //     // String retorno = services.criacaoCalculo(JSON.serialize(entradaPessoa));
    //     // GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
    //     // pageController.entradaCalculo = JSON.serialize(entradaPessoa);
    //     // pageController.gerarPayload();
    //     //MGRC-1657 - FIM     
    //     Test.stopTest();
    // }

    @isTest 
    public static void testGerarPayloadErro(){
        
        PageReference testPage = Page.GerarEndossoViagem; 
        Test.setCurrentPage(testPage);        
        
        Contract ctr = [Select id, Produto__c from Contract limit 1];
        ctr.Status = 'Emitido';
        update ctr;
        
        Product2 prod = [SELECT ID FROM Product2 WHERE ID =: ctr.Produto__c];
        prod.Segmento__c = 'Viagem';
        update prod; 
        
        testPage.getParameters().put('Id', String.valueOf(ctr.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(ctr);        
        
        GerarEndossoViagemPageController.EntradaPessoa entradaPessoa = new GerarEndossoViagemPageController.EntradaPessoa();
        GerarEndossoViagemPageController.EntradaCobertura cobertura = new GerarEndossoViagemPageController.EntradaCobertura();
        List<GerarEndossoViagemPageController.EntradaCobertura> coberturas = new List<GerarEndossoViagemPageController.EntradaCobertura>();
        GerarEndossoViagemPageController.DestinoTo destino = new GerarEndossoViagemPageController.DestinoTo();
        List<GerarEndossoViagemPageController.DestinoTo> destinos = new List<GerarEndossoViagemPageController.DestinoTo>();

        destino.codigo = 'DESTINO';
        destino.pais = 'BRASIL';        
        destinos.add(destino);        

        entradaPessoa.destinos = destinos;        
        
        cobertura.sigla = 'RPR'; 
        cobertura.valor = 5000.00;
        cobertura.moeda = 'BRL'; 
        cobertura.cotacaoMoeda = '4.04720000';
        cobertura.quantidade = '';
        cobertura.cobrado = 'Remarcação de Passagem para Regresso';
        coberturas.add(cobertura);      

        entradaPessoa.inicioVigencia = Date.valueOf('2021-06-23');
        entradaPessoa.finalVigencia = Date.valueOf('2021-12-01');
        entradaPessoa.tipoViagem = 'NACIONAL';
        entradaPessoa.passageirosIdosos = 0;
        entradaPessoa.passageirosNaoIdosos = 1;
        entradaPessoa.utilizaraMotocicleta = false;
        entradaPessoa.praticaEsportesAventura = false;        
               
        GrupoProfissoes__c grupoProfissao = new GrupoProfissoes__c();
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        Profissao__c profissao = new Profissao__c();        
	
        profissao.IdExterno__c = '2111-05';      
        profissao.Name = 'Atuário';
        insert profissao;

        grupoRisco.Name = 'DIT';
        insert grupoRisco;

        grupoProfissao.grupoRisco__c = grupoRisco.Id;
        grupoProfissao.profissao__c = profissao.Id;
        insert grupoProfissao;
		
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('', 500, 'Bad request'));

        Test.startTest();
        try {
            //MGRC-1657 - INICIO
            // CIVServices services = CIVServices.getInstance();
            // String retorno = services.criacaoCalculo(JSON.serialize(entradaPessoa));
            //MGRC-1657 - FIM                   
            GerarEndossoViagemPageController pageController = new GerarEndossoViagemPageController(sc);
            pageController.entradaCalculo = JSON.serialize(entradaPessoa);
            pageController.gerarPayload();
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains(''));
        }        
        Test.stopTest();       
        
    }
}