/**
 * Testes GarantiaProduto__c
 * @author Fernando Barcellos @ 16/03/2018
 *
 **/
@isTest
private class GarantiaProdutoTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}

	@isTest
	static void validarOrdemExibicaoGarantia() {
		// PLV-4472 INICIO
		Account contaTeste = new Account(Name = 'Conta 14', CodigoEmpresa__c = '14', Cnpj__c = '08.370.609/0001-64');
		// PLV-4472 FIM
		insert contaTeste;

		RamoSeguro__c ramoVida = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = contaTeste.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoVida;

		RamoSeguro__c ramoMorte = new RamoSeguro__c(
			Name = 'Morte',
			CodigoEmpresa__c = '15',
			Codigo__c = '2',
			IdExterno__c = '15_2',
			Empresa__c = contaTeste.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoMorte;

		Modalidade__c modalidade1 = new Modalidade__c(
			RamoSeguro__c = ramoVida.Id,
			Name = 'Mod teste'
		);
		insert modalidade1;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		RamoGarantia__c ramoGarantiaVida = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoVida.Id
		);
		insert ramoGarantiaVida;

		RamoGarantia__c ramoGarantiaMorte = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoMorte.Id
		);
		insert ramoGarantiaMorte;

		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome produtoTec 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;

		//correcao ambientes inicio
		/* ContentVersion versaoArquivoTec = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
			IsMajorVersion = true
		);
		insert versaoArquivoTec;

		ContentDocumentLink arquivoTec = new ContentDocumentLink();
		arquivoTec.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivoTec.Id].ContentDocumentId;
		arquivoTec.LinkedEntityId = produtoTec.Id;
		arquivoTec.ShareType = 'V';
		insert arquivoTec; */
		//correcao ambientes fim

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id; //
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.RamoSeguro__c = ramoVida.Id;
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
		coberturaCom1.RamoSeguro__c = ramoVida.Id;
        coberturaCom1.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom1.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom1.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom1.CurrencyIsoCode = 'BRL';
        coberturaCom1.LimiteCapitalMinimo__c = 10;
        coberturaCom1.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		GarantiaProduto__c coberturaCom2 = new GarantiaProduto__c();
		coberturaCom2.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom2.Garantia__c = garantia.Id;
		coberturaCom2.Produto__c = produtoCom.Id; //
		coberturaCom2.OrdemPrioridade__c = 1;
		coberturaCom2.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom2.TipoCapital__c = 'Capital uniforme';
		coberturaCom2.RamoSeguro__c = ramoMorte.Id;
        coberturaCom2.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom2.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom2.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom2.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom1.CurrencyIsoCode = 'BRL';
        coberturaCom1.LimiteCapitalMinimo__c = 10;
        coberturaCom1.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		List<GarantiaProduto__c> garantiasInsert = new List<GarantiaProduto__c>{coberturaCom1, coberturaCom2};

		//Tenta inserir 2 garantia com do mesmo produto com a mesma ordem e ramo de seguro diferente
		String erro = '';

		try {
			insert garantiasInsert;
		}
		catch(DmlException e) {
			erro = e.getMessage();
		}

		System.assert(erro.indexOf('Ordem de Exibição já foi utilizada:') > -1);

		//Tenta inserir novamente, mas com as ordens OK
		coberturaCom2.OrdemPrioridade__c = 2;
		insert garantiasInsert;

		System.assert(coberturaCom1.Id != null);
		System.assert(coberturaCom2.Id != null);


		//Tenta atualizar para uma ordem que já está sendo usada
		erro = '';

		try {
			coberturaCom2.OrdemPrioridade__c = 1;
			update coberturaCom2;
		}
		catch(DmlException e) {
			erro = e.getDmlStatusCode(0);
		}

		System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', erro);

		//Tenta atualizar para uma ordem não utilizada
		erro = '';

		try {
			coberturaCom2.OrdemPrioridade__c = 3;
			update coberturaCom2;
		}
		catch(DmlException e) {
			erro = e.getDmlStatusCode(0);
		}

		System.assertEquals('', erro);
	}

	@isTest
	static void validarVinculacaoGarantiaComericialAoTecnico() {
		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome Produto 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.VigenciaInicial__c = System.today().addDays(3);
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';		insert produtoTec;

		// PLV-4472 INICIO
		 Account contaTeste = new Account(Name = 'Conta 14', CodigoEmpresa__c = '14', Cnpj__c = '08.370.609/0001-64');
		 // PLV-4472 FIM
		insert contaTeste;

		RamoSeguro__c ramoVida = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = contaTeste.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoVida;

		Modalidade__c modalidade1 = new Modalidade__c(
			RamoSeguro__c = ramoVida.Id,
			Name = 'Mod teste'
		);
		insert modalidade1;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		RamoGarantia__c ramoGarantia = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoVida.Id
		);
		insert ramoGarantia;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id;
		coberturaTec.CapitalRiscos__c = true;
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.RamoSeguro__c = ramoVida.Id;
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		//Ativa produto
		//correcao ambientes inicio
		/* ContentVersion versaoArquivo = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
			IsMajorVersion = true
		);
		insert versaoArquivo;

		ContentDocumentLink arquivo = new ContentDocumentLink();
		arquivo.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivo.Id].ContentDocumentId;
		arquivo.LinkedEntityId = produtoTec.Id;
		arquivo.ShareType = 'V';
		insert arquivo; */
		//correcao ambientes fim

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		//Cria produto comercial
		Product2 produtoCom = new Product2();
		produtoCom.Name = 'Nome Produto 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.ProductCode = '201700001';
		produtoCom.VigenciaInicial__c = System.today().addDays(3);
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		Garantia__c garantiaInexistenteTecnico = new Garantia__c();
		garantiaInexistenteTecnico.VigenciaInicial__c = System.today();
		garantiaInexistenteTecnico.Tipo__c = 'Cobertura';
		garantiaInexistenteTecnico.Name = 'garantiaInexistenteTecnico';
		insert garantiaInexistenteTecnico;

		//Testar não vinculação da garantia, pois não existe no produto técnico
		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.Garantia__c = garantiaInexistenteTecnico.Id;
		coberturaCom1.Produto__c = produtoCom.Id;
		coberturaCom1.CapitalRiscos__c = true;
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
		coberturaCom1.TipoGarantia__c = 'Cobertura';
		

		//coberturaCom1.RamoSeguro__c = ramoVida.Id;
		//coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;

		String erro = '';

		try {
			insert coberturaCom1;
		} catch(DmlException e) {
			erro = e.getMessage();
		}

		System.assert(erro.indexOf('Este Tipo de Garantia não existe no produto técnico. Não pode ser utilizado.') > -1);

		//Testar vinculação da garantia
		GarantiaProduto__c coberturaCom2 = new GarantiaProduto__c();
		coberturaCom2.Garantia__c = garantia.Id;
		coberturaCom2.Produto__c = produtoCom.Id;
		coberturaCom2.CapitalRiscos__c = true;
		coberturaCom2.OrdemPrioridade__c = 1;
		coberturaCom2.TipoCapital__c = 'Capital uniforme';
		coberturaCom2.RamoSeguro__c = ramoVida.Id;
        coberturaCom2.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom2.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom2.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom2.TipoGarantia__c = 'Cobertura';
		//coberturaCom2.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		insert coberturaCom2;

		coberturaCom2 = [Select Id, GarantiaProduto__c From GarantiaProduto__c Where Id =: coberturaCom2.Id];
		System.assertEquals(coberturaCom2.GarantiaProduto__c, coberturaTec.Id);
	}

	@isTest
	static void validarCriacaoDependenciaGarantiaComercial() {
		RetornoAcaoBotaoTO resposta;

		Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
		TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
		RemuneracaoProduto__c remuneracao = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
		ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
		FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
		PremioMinimoProduto__c premioMinimo = TestDataFactory.gerarPremioMinimoProdutoTecnico(produtoTec, formaPagamento);
    	Account contaTeste = TestDataFactory.gerarConta();
		RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste);
		Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
		Garantia__c garantia = TestDataFactory.gerarGarantia();
		RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
		//ContentDocumentLink arquivo = TestDataFactory.gerarDocumentoProduto(produtoTec); //correcao ambientes
		GarantiaProduto__c coberturaTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem
		DependenteGarantia__c dependenteGarantia = TestDataFactory.gerarDependenteGarantiaTecnica(coberturaTec);
		//Territorio__c territorioProduto = TestDataFactory.gerarTerritorioProdutoTecnico(produtoTec);
		//Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaTecnica(garantiaProduto);

		//Ativa produto
		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		//Ativa produto
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Gera produto comercial
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovoProdutoComercial(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		GarantiaProduto__c garantiaProdClone = TestDataFactory.gerarGarantiaProdutoComercial(new Product2(Id=resposta.linkRedirecionar), garantia, coberturaTec, ramoVida);

		DependenteGarantia__c dependenciaClone = new DependenteGarantia__c(
			GarantiaProduto__c = garantiaProdClone.Id,
			ValidarRegrasProdutoComercial__c = false,
			Dependente__c = 'Filhos',
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('DependenteGarantia__c', 'ProdutoComercial').Id,
			DependenteGarantia__c = dependenteGarantia.Id
		);
		insert dependenciaClone;

		String erro = '';


		//Tenta editar a dependencia comercial (clone)
		TriggerHandler.clearbypass('DependenteGarantiaTriggerHandler');

		try {
			dependenciaClone.ValidarRegrasProdutoComercial__c = true;
			update dependenciaClone;
		}
		catch(Exception e) {
			erro = e.getMessage();
		}
        system.debug('Erro ao laldo: '+erro);
		//System.assert(erro.indexOf('Não é possível criar, editar ou excluir registros neste objeto. Para este produto comercial, esses dados devem ser iguais ao do técnico.') > -1); // PLV-5348 INÍCIO/FIM

		//Tenta criar uma nova dependencia para a a garantia clone
		erro = '';

		try {
			DependenteGarantia__c novaDependenteComercial = new DependenteGarantia__c(
				GarantiaProduto__c = dependenciaClone.GarantiaProduto__c,
				Dependente__c = 'Filhos',
				RecordTypeId = RecordTypeBO.buscarTipoRegistro('DependenteGarantia__c', 'ProdutoComercial').Id
			);
			insert novaDependenteComercial;

		}
		catch(Exception e) {
			erro = e.getMessage();
		}
		//System.assert(erro.indexOf('Não é possível criar, editar ou excluir registros neste objeto. Para este produto comercial, esses dados devem ser iguais ao do técnico.') > -1); // PLV-5348 INÍCIO/FIM

		//Tenta excluir uma dependecencia comercial
		erro = '';

		try {
			delete dependenciaClone;
		}
		catch(Exception e) {
			erro = e.getMessage();
		}
		//System.assert(erro.indexOf('Não é possível criar, editar ou excluir registros neste objeto. Para este produto comercial, esses dados devem ser iguais ao do técnico.') > -1); // PLV-5348 INÍCIO/FIM

		// tenta adicionar um depentende na garantia comercial que não está no técnico - plural
		erro = '';
		try {
			dependenciaClone = [Select Id, Dependente__c, GarantiaProduto__c, RecordTypeId From DependenteGarantia__c Where DependenteGarantia__c =: dependenteGarantia.Id Limit 1];
			dependenciaClone.Dependente__c = 'Avós;Cônjuge';
			update dependenciaClone;
		}
		catch(Exception e) {
			erro = e.getMessage();
		}
		//System.assert(erro.indexOf('Estes dependentes não estão no produto técnico:') > -1); //PLV-5348 INÍCIO/FIM

		// tenta adicionar um depentende na garantia comercial que não está no técnico - singular
		erro = '';
		try {
			dependenciaClone = [Select Id, Dependente__c, GarantiaProduto__c, RecordTypeId From DependenteGarantia__c Where DependenteGarantia__c =: dependenteGarantia.Id Limit 1];
			dependenciaClone.Dependente__c = 'Cônjuge';
			update dependenciaClone;
		}
		catch(Exception e) {
			erro = e.getMessage();
		}
		//System.assert(erro.indexOf('Este dependente não está no produto técnico:') > -1); // PLV-5348 INÍCIO/FIM
	}

	//PLV-2549 - Codigo removido para ajuste de cobertura da classe GarantiaRelacionadaBO
	
	@isTest
	static void validarEdicaoCarenciaGarantiaComercial() {
		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome Produto 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.VigenciaInicial__c = System.today().addDays(3);
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;
		// PLV-4472 INICIO
		Account contaTeste = new Account(Name = 'Conta 14', CodigoEmpresa__c = '14', Cnpj__c = '08.370.609/0001-64');
		// PLV-4472 FIM
		insert contaTeste;

		RamoSeguro__c ramoVida = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = contaTeste.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoVida;

		Modalidade__c modalidade1 = new Modalidade__c(
			RamoSeguro__c = ramoVida.Id,
			Name = 'Mod teste'
		);
		insert modalidade1;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		RamoGarantia__c ramoGarantia = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoVida.Id
		);
		insert ramoGarantia;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id;
		coberturaTec.CapitalRiscos__c = true;
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.RamoSeguro__c = ramoVida.Id;
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		Carencia__c carencia = new Carencia__c(
			Name = 'Carencia 1'
		);
		insert carencia;

		CarenciaGarantia__c carenciaGarantiaTec = new CarenciaGarantia__c(
			GarantiaProduto__c = coberturaTec.Id,
			Carencia__c = carencia.Id,
			PermiteAlterarProdutoComercial__c = false,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoTecnico').Id
		);
		insert carenciaGarantiaTec;

		//Ativa produto
		//correcao ambientes inicio
		/* ContentVersion versaoArquivo = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
			IsMajorVersion = true
		);
		insert versaoArquivo;

		ContentDocumentLink arquivo = new ContentDocumentLink();
		arquivo.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivo.Id].ContentDocumentId;
		arquivo.LinkedEntityId = produtoTec.Id;
		arquivo.ShareType = 'V';
		insert arquivo;
 		*/ //Correcao ambientes fim
		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
        coberturaCom1.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom1.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom1.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom1.CurrencyIsoCode = 'BRL';
		coberturaCom1.LimiteCapitalMinimo__c = 10;
		coberturaCom1.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem
		insert coberturaCom1;

		//Clona carencia da garantia
		CarenciaGarantia__c carenciaGarantiaCom = carenciaGarantiaTec.clone(false, true);
		carenciaGarantiaCom.GarantiaProduto__c = coberturaCom1.Id;
		carenciaGarantiaCom.CarenciaGarantia__c = carenciaGarantiaTec.Id;
 		carenciaGarantiaCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoComercial').Id;
 		insert carenciaGarantiaCom;

 		//Tenta alterar a carencia da garantia do produto comercial
 		String erro = '';

 		try {
 			update carenciaGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
 		}

 		System.assert(erro.indexOf('Não é possível editar uma Carência da Garantia de um Produto Comercial.') > -1); //PLV-4106

 		 //Tenta excluir a carencia da garantia do produto comercial
 		 erro = '';

 		try {
 			delete carenciaGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
 		}

 		//System.assert(erro.indexOf('Não é permitido editar ou excluir este registro, devido as configurações no produto técnico.') > -1); //PLV-4106

 		//Altera o produto técnico para permitir alterar/excluir o registro
 		carenciaGarantiaTec.PermiteAlterarProdutoComercial__c = true;
 		update carenciaGarantiaTec;

 		//Realiza alteração na carencia do produto técnico
 		erro = '';

 		try {
 			update carenciaGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
 		}

 		//System.assertEquals('', erro); //PLV-4106
	}

	@isTest
	static void validarEdicaoRiscoGarantiaComercial() {
		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome Produto 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.VigenciaInicial__c = System.today().addDays(3);
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id;
		coberturaTec.CapitalRiscos__c = true;
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		Risco__c risco = new Risco__c(
			Name = 'Risco 1'
		);
		insert risco;

		RiscoGarantia__c riscoGarantiaTec = new RiscoGarantia__c(
			GarantiaProduto__c = coberturaTec.Id,
			Risco__c = risco.Id,
			PermiteAlterarProdutoComercial__c = false,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('RiscoGarantia__c', 'ProdutoTecnico').Id
		);
		insert riscoGarantiaTec;

		//Ativa produto
		//correcao ambientes inicio
		/* ContentVersion versaoArquivo = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
			IsMajorVersion = true
		);
		insert versaoArquivo;

		ContentDocumentLink arquivo = new ContentDocumentLink();
		arquivo.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivo.Id].ContentDocumentId;
		arquivo.LinkedEntityId = produtoTec.Id;
		arquivo.ShareType = 'V';
		insert arquivo; */
		//correcao ambientes fim

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
        coberturaCom1.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom1.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom1.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom1.CurrencyIsoCode = 'BRL';
		coberturaCom1.LimiteCapitalMinimo__c = 10;
		coberturaCom1.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem
		insert coberturaCom1;

		//Clona carencia da garantia
		RiscoGarantia__c riscoGarantiaCom = riscoGarantiaTec.clone(false, true);
		riscoGarantiaCom.GarantiaProduto__c = coberturaCom1.Id;
		riscoGarantiaCom.RiscoGarantia__c = riscoGarantiaTec.Id;
 		riscoGarantiaCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('RiscoGarantia__c', 'ProdutoComercial').Id;
 		insert riscoGarantiaCom;

 		//Tenta alterar a carencia da garantia do produto comercial
 		String erro = '';

 		try {
 			update riscoGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
 		}

 		System.assert(erro.indexOf('Não é permitido editar ou excluir este registro, devido as configurações no produto técnico.') > -1);

 		 //Tenta excluir a carencia da garantia do produto comercial
 		 erro = '';

 		try {
 			delete riscoGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
 		}

 		System.assert(erro.indexOf('Não é permitido editar ou excluir este registro, devido as configurações no produto técnico.') > -1);

 		//Altera o produto técnico para permitir alterar/excluir o registro
 		riscoGarantiaTec.PermiteAlterarProdutoComercial__c = true;
 		update riscoGarantiaTec;

 		//Realiza alteração na carencia do produto técnico
 		erro = '';

 		try {
 			update riscoGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
 		}

 		System.assertEquals('', erro);
	}

	@isTest
	static void validarEdicaoFranquiaGarantiaComercial() {
		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome Produto 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.VigenciaInicial__c = System.today().addDays(3);
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id;
		coberturaTec.CapitalRiscos__c = true;
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		Franquia__c franquia = new Franquia__c(
			Name = 'Franquia 1'
		);
		insert franquia;

		FranquiaGarantia__c franquiaGarantiaTec = new FranquiaGarantia__c(
			GarantiaProduto__c = coberturaTec.Id,
			Franquia__c = franquia.Id,
			PermiteAlterarProdutoComercial__c = false,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoTecnico').Id
		);
		insert franquiaGarantiaTec;

		//Ativa produto
		//correcao ambientes inicio
		/* ContentVersion versaoArquivo = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
			IsMajorVersion = true
		);
		insert versaoArquivo;

		ContentDocumentLink arquivo = new ContentDocumentLink();
		arquivo.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivo.Id].ContentDocumentId;
		arquivo.LinkedEntityId = produtoTec.Id;
		arquivo.ShareType = 'V';
		insert arquivo; */
		//correcao ambientes fim

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
        coberturaCom1.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom1.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom1.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		//coberturaCom1.Agrupamento_Coberturas__c = 'Saude'; //VIAG-265 - INICIO/FIM
		coberturaCom1.CurrencyIsoCode = 'BRL';
		coberturaCom1.LimiteCapitalMinimo__c = 10;
		coberturaCom1.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem
		insert coberturaCom1;

		//Clona carencia da garantia
		FranquiaGarantia__c franquiaGarantiaCom = franquiaGarantiaTec.clone(false, true);
		franquiaGarantiaCom.GarantiaProduto__c = coberturaCom1.Id;
		franquiaGarantiaCom.FranquiaGarantia__c = franquiaGarantiaTec.Id;
 		franquiaGarantiaCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoComercial').Id;
 		insert franquiaGarantiaCom;

 		//Tenta alterar a carencia da garantia do produto comercial
 		String erro = '';

 		try {
 			update franquiaGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
			System.Debug('Quebra aqui 1');
 		}

 		System.assert(erro.indexOf('Não é possível editar uma Franquia de Garantia de um Produto Comercial.') > -1); //PLV-4106

 		 //Tenta excluir a carencia da garantia do produto comercial
 		 erro = '';

 		try {
 			delete franquiaGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
			 System.Debug('Quebra aqui 2');
 		}

 		//System.assert(erro.indexOf('Não é permitido editar ou excluir este registro, devido as configurações no produto técnico.') > -1); //PLV-4106

 		//Altera o produto técnico para permitir alterar/excluir o registro
 		franquiaGarantiaTec.PermiteAlterarProdutoComercial__c = true;
 		update franquiaGarantiaTec;

 		//Realiza alteração na carencia do produto técnico
 		erro = '';

 		try {
 			update franquiaGarantiaCom;
 		} catch(Exception e) {
 			erro = e.getMessage();
			 System.Debug('Quebra aqui 3');
 		}

 		//System.assertEquals('', erro); //PLV-4106
	}

	@isTest
	static void validarCriacaoParametroRenovacaoComercial() {
		RetornoAcaoBotaoTO resposta;

		Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
		TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
		RemuneracaoProduto__c remuneracao = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
		ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
		FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
		PremioMinimoProduto__c premioMinimo = TestDataFactory.gerarPremioMinimoProdutoTecnico(produtoTec, formaPagamento);
    	Account contaTeste = TestDataFactory.gerarConta();
		RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste);
		Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
		Garantia__c garantia = TestDataFactory.gerarGarantia();
		RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
		GarantiaProduto__c coberturaTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem
		Territorio__c territorioProduto = TestDataFactory.gerarTerritorioProdutoTecnico(produtoTec);
		Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaTecnica(coberturaTec);
		DependenteGarantia__c dependenteGarantia = TestDataFactory.gerarDependenteGarantiaTecnica(coberturaTec);
		//ContentDocumentLink arquivo = TestDataFactory.gerarDocumentoProduto(produtoTec); //correcao ambientes

		ParametroRenovacao__c parametroRenovacao = new ParametroRenovacao__c(
			GarantiaProduto__c = coberturaTec.Id,
			TipoSegurado__c = 'Filhos',
			IdadeMaximaRenovacao__c = 5,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroRenovacao__c', 'ProdutoTecnico').Id
		);
		insert parametroRenovacao;

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234';
		update produtoTec;

		//Ativa produto
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.ativarProduto(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Gera produto comercial
		resposta = (RetornoAcaoBotaoTO)JSON.deserialize(ProductAcaoBotaoController.gerarNovoProdutoComercial(produtoTec.Id), RetornoAcaoBotaoTO.class);
		System.assertEquals(resposta.tipo, RetornoAcaoBotaoTO.SUCCESS);

		//Verifia se criou a garantia produto comercial
		//GarantiaProduto__c garantiaProdClone = [Select Id, GarantiaProduto__c, RecordTypeId From GarantiaProduto__c Where GarantiaProduto__c =: coberturaTec.Id Limit 1];
		//System.assert(garantiaProdClone != null);
		//System.assertEquals(garantiaProdClone.RecordTypeId, RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id);

		//Verifia se criou a dependencia comercial
		//ParametroRenovacao__c parametroClone = [Select Id, GarantiaProduto__c, RecordTypeId From ParametroRenovacao__c Where ParametroRenovacao__c =: parametroRenovacao.Id Limit 1];
		//System.assert(parametroClone != null);
		//System.assertEquals(parametroClone.RecordTypeId, RecordTypeBO.buscarTipoRegistro('ParametroRenovacao__c', 'ProdutoComercial').Id);

		GarantiaProduto__c coberturaCom = new GarantiaProduto__c();
		coberturaCom.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom.Garantia__c = garantia.Id;
		coberturaCom.Produto__c = resposta.linkRedirecionar;
		coberturaCom.OrdemPrioridade__c = 1;
		coberturaCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom.TipoCapital__c = 'Capital uniforme';
        coberturaCom.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaCom.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaCom.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaCom.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom.CurrencyIsoCode = 'BRL';
		coberturaCom.LimiteCapitalMinimo__c = 10;
		coberturaCom.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem
		insert coberturaCom;

		ParametroRenovacao__c parametroClone = new ParametroRenovacao__c(
			GarantiaProduto__c = coberturaCom.Id,
			ValidarRegrasProdutoComercial__c = false,
			TipoSegurado__c = 'Filhos',
			IdadeMaximaRenovacao__c = 5,
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroRenovacao__c', 'ProdutoComercial').Id,
			ParametroRenovacao__c = parametroRenovacao.Id
		);
		insert parametroClone;

		String erro = '';


		//Tenta editar a a dependencia comercial (clone)
		TriggerHandler.clearbypass('ParametroRenovacaoTriggerHandler');

		//try {
		//	parametroClone.ValidarRegrasProdutoComercial__c = true;
		//	update parametroClone;
		//}
		//catch(Exception e) {
		//	erro = e.getMessage();
		//}
		//System.assert(erro.indexOf('Não é possível criar, editar ou excluir registros neste objeto. Para este produto comercial, esses dados devem ser iguais ao do técnico.') > -1);

		//Altera idade maxima para um valor acima do que foi cadastrado no técnico
		try {
			parametroClone.IdadeMaximaRenovacao__c = 10;
			update parametroClone;
		}
		catch(Exception e) {
			erro = e.getMessage();
		}
		System.assert(erro.indexOf('A Idade máxima de renovação não pode ser maior do que foi cadastrado no produto técnico.') > -1);

		erro = 'OK';

		try {
			parametroClone.IdadeMaximaRenovacao__c = 3;
			update parametroClone;
		}
		catch(Exception e) {
			erro = e.getMessage();
		}
		System.assertEquals('OK', erro);

		//Tenta criar uma nova dependencia para a a garantia clone
		erro = '';

		try {
			ParametroRenovacao__c novaParametroComercial = new ParametroRenovacao__c(
				GarantiaProduto__c = parametroClone.GarantiaProduto__c,
				TipoSegurado__c = 'Filhos',
				RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroRenovacao__c', 'ProdutoComercial').Id
			);
			insert novaParametroComercial;

		}
		catch(Exception e) {
			erro = e.getMessage();
		}
		//System.assert(erro.indexOf('Não é possível criar, editar ou excluir registros neste objeto. Para este produto comercial, esses dados devem ser iguais ao do técnico.') > -1);

		//Teste exclusão
		erro = '';

		//try {
		//	parametroClone.ValidarRegrasProdutoComercial__c = true;
		//	delete parametroClone;
		//}
		//catch(Exception e) {
		//	erro = e.getMessage();
		//}
		//System.assert(erro.indexOf('Não é possível criar, editar ou excluir registros neste objeto. Para este produto comercial, esses dados devem ser iguais ao do técnico.') > -1);

	}

	@isTest
	static void testeValidarTiposGarantiaProdutoComercial() {
		Id rtGarantiaComercialId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		String erro = '';

		//Cria estrutura produto técnico
		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome Produto 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.VigenciaInicial__c = System.today().addDays(3);
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;

		// PLV-4472 INICIO
		Account contaTeste = new Account(Name = 'Conta 14', CodigoEmpresa__c = '14', Cnpj__c = '38.579.897/0001-22');
		// PLV-4472 FIM
		insert contaTeste;

		RamoSeguro__c ramoVida = new RamoSeguro__c(
			Name = 'VIDA',
			CodigoEmpresa__c = '14',
			Codigo__c = '2',
			IdExterno__c = '14_2',
			Empresa__c = contaTeste.Id,
			Status__c = 'Ativo',
			CodigoOrigemDoMovimentoBCP__c = '32' //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		);
		insert ramoVida;

		Modalidade__c modalidade1 = new Modalidade__c(
			RamoSeguro__c = ramoVida.Id,
			Name = 'Mod teste'
		);
		insert modalidade1;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		RamoGarantia__c ramoGarantia = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoVida.Id
		);
		insert ramoGarantia;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id;
		coberturaTec.CapitalRiscos__c = true;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.RamoSeguro__c = ramoVida.Id;
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		//Cria estrutura produto comercial e realiza as validações
		Product2 produtoComercial = new Product2();
		produtoComercial.Name = 'Nome Produto 001';
		produtoComercial.Status__c = 'Em criação';
		produtoComercial.ProductCode = '201700001';
		produtoComercial.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoComercial.TipoResponsavelPagamento__c = 'SEG';
		insert produtoComercial;

		//Tenta inserir garantia do produto com um tipo diferente do produto técnico
		Garantia__c garantia2 = new Garantia__c();
		garantia2.VigenciaInicial__c = System.today();
		garantia2.Tipo__c = 'Cobertura';
		garantia2.Name = 'garantia2';
		insert garantia2;

		GarantiaProduto__c coberturaComercial = new GarantiaProduto__c();
		coberturaComercial.GarantiaProduto__c = coberturaTec.Id;
		coberturaComercial.Garantia__c = garantia2.Id;
		coberturaComercial.Produto__c = produtoComercial.Id;
		coberturaComercial.CapitalRiscos__c = true;
		coberturaComercial.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaComercial.TipoCapital__c = 'Capital uniforme';
        coberturaComercial.TipoCaracteristicaEspecial__c = 'Cestas';
        coberturaComercial.LimiteMinimoCaracteristicaEspecial__c = 10;
        coberturaComercial.LimiteMaximoCaracteristicaEspecial__c = 100;
        coberturaComercial.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaComercial.CurrencyIsoCode = 'BRL';
		coberturaComercial.LimiteCapitalMinimo__c = 10;
		coberturaComercial.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		erro = '';

		try{

			insert coberturaComercial;
		}
		catch(DmlException e){

			erro = e.getDmlStatusCode(0);
		}

		System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', erro);

		//Utiliza tipo der remuneração existente no produto técnico
		coberturaComercial.Garantia__c = garantia.Id;
		insert coberturaComercial;
		System.assert(coberturaComercial.Id != null);
	}

	@isTest
	static void validarRamoSeguro() {
		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		garantia.Status__c = 'Em análise';
		insert garantia;

		garantia = [SELECT Id, Status__c FROM Garantia__c WHERE Id =: garantia.Id LIMIT 1];
		garantia.Status__c = 'Ativo';
		update garantia;

		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome produtoTec 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		produtoTec.TipoResponsavelPagamento__c = 'SEG';
		insert produtoTec;

		//correcao ambientes inicio
		/* ContentVersion versaoArquivoTec = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
			IsMajorVersion = true
		);
		insert versaoArquivoTec;

		ContentDocumentLink arquivoTec = new ContentDocumentLink();
		arquivoTec.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: versaoArquivoTec.Id].ContentDocumentId;
		arquivoTec.LinkedEntityId = produtoTec.Id;
		arquivoTec.ShareType = 'V';
		insert arquivoTec; */
		//correcao ambientes fim

		produtoTec.Status__c = 'Em ativação';
		produtoTec.NumeroSusep__c = '1234x';
		update produtoTec;

		produtoTec.Status__c = 'Ativo';
		update produtoTec;

		GarantiaProduto__c coberturaTec = new GarantiaProduto__c();
		coberturaTec.Garantia__c = garantia.Id;
		coberturaTec.Produto__c = produtoTec.Id; //
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;

		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		limiteGarantiaProduto__c limiteGarantia = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).CreateRecord();
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		Account contaPorto = new Account();
		contaPorto.Name = 'PORTO SEGURO CIA DE SEGUROS GERAIS';
		// PLV-4472 INICIO
		contaPorto.Cnpj__c = '08.370.609/0001-64';
		// PLV-4472 FIM
		insert contaPorto;

		RamoSeguro__c ramoSeguro = new RamoSeguro__c();
		ramoSeguro.Empresa__c = contaPorto.Id;
		ramoSeguro.Codigo__c = '123';
		ramoSeguro.Status__c = 'Ativo';
		ramoSeguro.CodigoOrigemDoMovimentoBCP__c = '32'; //PLV-3773 INICIO/FIM - incluso campo para rega de validação
		insert ramoSeguro;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id;
		coberturaCom1.RamoSeguro__c = ramoSeguro.Id;
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
		coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom1.CurrencyIsoCode = 'BRL';
		coberturaCom1.LimiteCapitalMinimo__c = 10;
		coberturaCom1.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		GarantiaProduto__c coberturaCom2 = new GarantiaProduto__c();
		coberturaCom2.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom2.Garantia__c = garantia.Id;
		coberturaCom2.Produto__c = produtoCom.Id; //
		coberturaCom2.RamoSeguro__c = ramoSeguro.Id;
		coberturaCom2.OrdemPrioridade__c = 2;
		coberturaCom2.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom2.TipoCapital__c = 'Capital uniforme';
		coberturaCom2.TipoGarantia__c = 'Cobertura';
		//PLV-3046 - INICIO - Cadastro de Produto - Viagem
		coberturaCom1.CurrencyIsoCode = 'BRL';
		coberturaCom1.LimiteCapitalMinimo__c = 10;
		coberturaCom1.LimiteCapitalMaximo__c = 100;
		//PLV-3046 - FIM - Cadastro de Produto - Viagem

		RamoGarantia__c ramoGarantia = new RamoGarantia__c();
		ramoGarantia.Garantia__c = garantia.Id;
		ramoGarantia.RamoSeguro__c = ramoSeguro.Id;
		insert ramoGarantia;

		System.debug('::: ramoGarantia: ' + ramoGarantia);

		List<GarantiaProduto__c> garantiasInsert = new List<GarantiaProduto__c>{coberturaCom1, coberturaCom2};

		//Tenta inserir 2 garantia com do mesmo produto com a mesma ordem
		String erro = '';

		try {
			insert garantiasInsert;
		}
		catch(DmlException e) {
			erro = e.getMessage();
		}
	}

	//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
	@IsTest 
	public static void validaLimiteCapitalTest(){

		String erro;

	    Product2 produtoTecnico = (Product2) new produtoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new produtoFactory.produtoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;

		TipoRemuneracao__c TipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord(); 
        remuneracaoProduto__c remuneracaoProduto = (remuneracaoProduto__c) new RemuneracaoProdutoFactory(TipoRemuneracao, produtoComercial).createRecord();
        RamoSeguro__c ramoSegurado = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        Garantia__c garantia = (garantia__c) new GarantiaFactory().createRecord();
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantia, ramoSegurado).createRecord(); 
        GarantiaProduto__c garantiaProdutoTEC = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantia, produtoTecnico, ramoSegurado).createRecord();
		update garantiaProdutoTEC;
		GarantiaProduto__c garantiaProduto = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantia, garantiaProdutoTEC, ramoSegurado).createRecord();

		Test.startTest();
		try{
			garantiaProduto.currencyIsoCode = 'USD';
			garantiaProduto.LimiteCapitalMinimo__c = 200;
			garantiaProduto.LimiteCapitalMaximo__c = 999999999;
			update garantiaProduto;
		}catch(DmlException e){
			erro = e.getDmlStatusCode(0); 
		}

		System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', erro);        		
		Test.StopTest();
	}
	//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
}