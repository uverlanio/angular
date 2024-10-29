@isTest
private class ConfiguradorOfertaControllerTest {

	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
		gerarDadosConfiguracao();
	}

	@isTest
	static void testarChamadasPagina() {
		//Testa busca da configuracao 
		Configuracao__c conf = [SELECT Id FROM Configuracao__c LIMIT 1];
		Configuracao__c confBusca = ConfiguradorOfertaController.buscarConfiguracao(conf.Id);
		System.assertEquals(conf.Id, confBusca.Id);

		//Teste busca do produto por segmento
		List<Product2> produtos = ConfiguradorOfertaController.buscarProdutosComerciais('Individual');
		System.assert(!produtos.isEmpty());

		//Teste busca garantias do produto
		List<GarantiaProduto__c> garantias = ConfiguradorOfertaController.buscarGarantiasProdutos(produtos[0].Id);
		System.assert(!garantias.isEmpty());

		//Teste busca produto da configuracao
		ProdutoConfiguracao__c prodConf = [SELECT Id FROM ProdutoConfiguracao__c LIMIT 1];
		List<GarantiaProdutoConfiguracao__c> garantiasConfBusca = ConfiguradorOfertaController.buscarGarantiasProdutosConfiguracao(prodConf.Id);
		System.assert(!garantiasConfBusca.isEmpty());

		//Teste salvar produto configuracao
		Id idRegistroSalvo = ConfiguradorOfertaController.salvarProdutosConfiguracao(prodConf);
		System.assertEquals(prodConf.Id, idRegistroSalvo);

		//Teste salvar as garantias
		ConfiguradorOfertaController.salvarGarantiasProdutosConfiguracao(JSON.serialize(garantiasConfBusca));

		//Teste salvar os criterios configuracao
		List<CriterioConfiguracao__c> criteriosConf = [SELECT Id FROM CriterioConfiguracao__c];
		ConfiguradorOfertaController.salvarCriteriosConfiguracao(JSON.serialize(criteriosConf));

		//Teste exclusao garantias configuracao
		ConfiguradorOfertaController.excluirGarantiasProdutosConfiguracao(JSON.serialize(garantiasConfBusca));
		List<GarantiaProdutoConfiguracao__c> garantiasConfBuscaDel = [SELECT Id FROM GarantiaProdutoConfiguracao__c];
		System.assertEquals(0, garantiasConfBuscaDel.size());

		//Tete exclusao produto configuracao
		ConfiguradorOfertaController.excluirProdutoConfiguracao(prodConf.Id);
		List<ProdutoConfiguracao__c> produtosConf = [SELECT Id FROM ProdutoConfiguracao__c];
		System.assertEquals(0, produtosConf.size());


		for(CriterioConfiguracao__c c : [SELECT Id FROM CriterioConfiguracao__c]){
			ConfiguradorOfertaController.excluirCriterioConfiguracao(c.Id);
		}
		List<CriterioConfiguracao__c> criterios = [SELECT Id FROM CriterioConfiguracao__c];
		System.assertEquals(0, criterios.size());

		//Teste busca opções criterios		
		String picklists = ConfiguradorOfertaController.buscarOpcoesCamposCriterio(new List<String> {'Opportunity'}, 'Individual', 'ConfiguradorOferta');
		System.assert(String.isNotBlank(picklists));

		String mapInfoCriterios = ConfiguradorOfertaController.buscarMapInformacoesCamposCriterio(new List<String> {'Opportunity'}, 'Individual', 'ConfiguradorOferta');
		System.assert(String.isNotBlank(mapInfoCriterios));
	}

	//Gera dados e retorna informação que deverá ser encontrada no processamento de uma configuração
	static void gerarDadosConfiguracao(){
		//Cria produto
		Account contaTeste = new Account(Name = 'Conta 14', CodigoEmpresa__c = '14', Cnpj__c = '38.579.897/0001-22');
		insert contaTeste;

		FormaPagamento__c formaPagamento = new FormaPagamento__c(
                Codigo__c = '1234',
                Name = '3X'
        );
        insert formaPagamento;

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

		Garantia__c garantia = new Garantia__c();
		garantia.Name = 'XPTO';
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		RamoGarantia__c ramoGarantia = new RamoGarantia__c(
			Garantia__c = garantia.Id,
			RamoSeguro__c = ramoVida.Id
		);
		insert ramoGarantia;

		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome produtoTec 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '260';
		produtoTec.Status__c = 'Em criação';
		produtoTec.TipoResponsavelPagamento__c = 'PAR';
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
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

		//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
		LimiteGarantiaProduto__c limiteGarantiaProduto = (LimiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord();
		//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem

		PremioMinimoProduto__c premioMinimoTec = new PremioMinimoProduto__c(
            Produto__c = produtoTec.Id,
            FormaPagamento__c = formaPagamento.Id,
            PeriodicidadePagamento__c = 'Anual',
            TipoContratacao__c = 'Novo',
            PremioMinimoParcela__c = 100,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('PremioMinimoProduto__c', 'ProdutoTecnico').Id
        );
        insert premioMinimoTec;

        CondicaoCobranca__c condicaoCobrancaTec = new CondicaoCobranca__c(
                Produto__c = produtoTec.Id,
                FormaPagamento__c = formaPagamento.Id,
                QuantidadeParcelas__c = '1;2'
        );
        insert condicaoCobrancaTec;

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '260';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.VigenciaInicial__c = System.today();
		produtoCom.TipoResponsavelPagamento__c = 'PAR';
		produtoCom.Segmento__c = 'Individual';
		insert produtoCom;

		produtoCom.Status__c = 'Em ativação';
		produtoCom.NumeroSusep__c = '1234x';
		update produtoCom;

		produtoCom.Status__c = 'Ativo';
		update produtoCom;

		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.GarantiaProduto__c = coberturaTec.Id;
		coberturaCom1.Garantia__c = garantia.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoCapital__c = 'Capital uniforme';
		coberturaCom1.RamoSeguro__c = ramoVida.Id;
		coberturaCom1.TipoGarantia__c = 'Cobertura';
		//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
		coberturaCom1.LimiteCapitalMinimo__c = 100;
		coberturaCom1.LimiteCapitalMaximo__c = 1000;
		coberturaCom1.CurrencyIsoCode = 'BRL';
		//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem

		insert coberturaCom1;

		PremioMinimoProduto__c premioMinimoCom = new PremioMinimoProduto__c(
            Produto__c = produtoCom.Id,
            FormaPagamento__c = formaPagamento.Id,
            PeriodicidadePagamento__c = 'Anual',
            TipoContratacao__c = 'Novo',
            PremioMinimoParcela__c = 100,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('PremioMinimoProduto__c', 'ProdutoComercial').Id
        );
        insert premioMinimoCom;

        CondicaoCobranca__c condicaoCobrancaCom = new CondicaoCobranca__c(
                Produto__c = produtoCom.Id,
                FormaPagamento__c = formaPagamento.Id,
                QuantidadeParcelas__c = '1;2'
        );
        insert condicaoCobrancaCom;

		//Cria configuracao
		Configuracao__c configuracao = new Configuracao__c(
			Name = 'Produto para macho',
			Segmento__c = 'Individual',
			Status__c = 'Em criação',
			VigenciaInicial__c = System.today().addDays(-2),
			VigenciaFinal__c = System.today().addDays(2)
		);
		insert configuracao;

		configuracao.Status__c = 'Em aprovação';
		update configuracao;

		configuracao.Status__c = 'Em ativação';
		update configuracao;

		configuracao.Status__c = 'Ativo';
		update configuracao;

		ProdutoConfiguracao__c produtoConf = new ProdutoConfiguracao__c(
			Configuracao__c = configuracao.Id,
			Produto__c = produtoCom.Id
		);
		insert produtoConf;

		GarantiaProdutoConfiguracao__c garantiaConf = new GarantiaProdutoConfiguracao__c(
			ProdutoConfiguracao__c = produtoConf.Id,
			GarantiaProduto__c = coberturaCom1.Id
		);
		insert garantiaConf;

		List<CriterioConfiguracao__c> criterios = new List<CriterioConfiguracao__c>{
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.Sexo__pc',
				Operador__c = 'Igual',
				Valor__c = 'Masculino'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.Profissao__pc',
				Operador__c = 'Igual',
				Valor__c = 'Programador'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.Renda__c',
				Operador__c = 'Maior',
				Valor__c = '1000.50'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Account.PersonBirthdate',
				Operador__c = 'Igual',
				Valor__c = '1990-03-13'
			),
			new CriterioConfiguracao__c(
				Configuracao__c = configuracao.Id,
				Campo__c = 'Opportunity.TipoSegurado__c',
				Operador__c = 'Contém',
				Valor__c = 'Alunos;Cooperados;PRI'
			)
		};
		insert criterios;
	}
}