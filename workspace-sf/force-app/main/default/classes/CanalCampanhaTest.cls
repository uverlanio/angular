/**
 * Test CanalCampanha__c
 * @author Fernando Barcellos @ 18/01/2018
 *
 **/
@isTest
private class CanalCampanhaTest {
	@testSetup
	private static void setup() {
		List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>{
			new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
			new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
		};
		insert contadoresProduto;
	}

	@isTest
	static void testarValidacaoCanalCampanha() {
		Test.startTest();
		Datetime now = System.now();

		Garantia__c garantia1 = new Garantia__c();
		garantia1.Name = 'Cobertura #001';
		garantia1.Sigla__c = 'C001';
		garantia1.Status__c = 'Ativo';
		garantia1.VigenciaInicial__c = System.today();
		garantia1.Tipo__c = 'Cobertura';
		insert garantia1;

		Garantia__c garantia2 = new Garantia__c();
		garantia2.Name = 'Benefício #001';
		garantia2.Sigla__c = 'B001';
		garantia2.Status__c = 'Ativo';
		garantia2.VigenciaInicial__c = System.today();
		garantia2.Tipo__c = 'Benefício';
		insert garantia2;

		Garantia__c garantiaParaErro = new Garantia__c();
		garantiaParaErro.Name = 'Assistência #001';
		garantiaParaErro.Sigla__c = 'A001';
		garantiaParaErro.Status__c = 'Ativo';
		garantiaParaErro.VigenciaInicial__c = System.today();
		garantiaParaErro.Tipo__c = 'Assistência';
		insert garantiaParaErro;

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
		coberturaTec.Garantia__c = garantia1.Id;
		coberturaTec.Produto__c = produtoTec.Id; //
		coberturaTec.TipoCapital__c = 'Capital global';
		coberturaTec.OrdemPrioridade__c = 1;
		coberturaTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec.TipoGarantia__c = 'Cobertura';
		insert coberturaTec;
        limiteGarantiaProduto__c limGarantiaProdTec = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec).createRecord(); //PLV - 3046

		GarantiaProduto__c coberturaTec2 = new GarantiaProduto__c();
		coberturaTec2.Garantia__c = garantia2.Id;
		coberturaTec2.Produto__c = produtoTec.Id; //
		coberturaTec2.TipoCapital__c = 'Capital global';
		coberturaTec2.OrdemPrioridade__c = 2;
		coberturaTec2.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id;
		coberturaTec2.TipoGarantia__c = 'Benefício';
		insert coberturaTec2;
        // limiteGarantiaProduto__c limGarantiaProdTec2 = (limiteGarantiaProduto__c) new LimiteGarantiaProdutoFactory(coberturaTec2).createRecord(); //PLV - 3046

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		// coberturas comerciais
		GarantiaProduto__c coberturaCom1 = new GarantiaProduto__c();
		coberturaCom1.Garantia__c = garantia1.Id;
		coberturaCom1.Produto__c = produtoCom.Id; //
		coberturaCom1.TipoCapital__c = 'Capital global';
		//coberturaCom1.OrdemPrioridade__c = 1;
		coberturaCom1.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom1.TipoGarantia__c = 'Cobertura';
		insert coberturaCom1;

		GarantiaProduto__c coberturaCom2 = new GarantiaProduto__c();
		coberturaCom2.Garantia__c = garantia2.Id;
		// coberturaCom2.Produto__c = produtoCom.Id; ////PLV - 3046
		coberturaCom2.TipoCapital__c = 'Capital global';
		//coberturaCom2.OrdemPrioridade__c = 2;
		coberturaCom2.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		coberturaCom2.TipoGarantia__c = 'Benefício';
		insert coberturaCom2;
		//correcao ambientes inicio
		// Cria a versão do documento
		/* ContentVersion cv1 = new ContentVersion(
			Title = 'Test 001 - ' + now,
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + now),
			IsMajorVersion = true
		);
		insert cv1;

		// Cria a relação de produto produtoCom com documento documento
		ContentDocumentLink cdl1 = new ContentDocumentLink();
		cdl1.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv1.Id].ContentDocumentId;
		cdl1.LinkedEntityId = produtoCom.Id;
		cdl1.ShareType = 'V'; // ??
		insert cdl1; */
		//correcao ambientes fim

		Product2 produtoComercialAtivo = [SELECT Id, Name, Status__c FROM Product2 WHERE Id =: produtoCom.Id];
		produtoComercialAtivo.Status__c = 'Em ativação';
		produtoComercialAtivo.NumeroSusep__c = '1234';
		update produtoComercialAtivo;

		produtoComercialAtivo.Status__c = 'Ativo';
		update produtoComercialAtivo;

		//
		FormaPagamento__c formaPagamento1 = new FormaPagamento__c();
		formaPagamento1.Name = 'À VISTA';
		formaPagamento1.Codigo__c = '123';
		insert formaPagamento1;

		FormaPagamento__c formaPagamento2 = new FormaPagamento__c();
		formaPagamento2.Name = 'BOLETO';
		formaPagamento2.Codigo__c = '456';
		insert formaPagamento2;

		FormaPagamento__c formaPagamento3 = new FormaPagamento__c();
		formaPagamento3.Name = 'CARTÃO DE CRÉDITO';
		formaPagamento3.Codigo__c = '789';
		insert formaPagamento3;

		CondicaoCobranca__c condicaoCobranca1 = new CondicaoCobranca__c();
		condicaoCobranca1.Produto__c = produtoComercialAtivo.Id;
		condicaoCobranca1.FormaPagamento__c = formaPagamento1.Id;
		condicaoCobranca1.QuantidadeParcelas__c = '1';
		insert condicaoCobranca1;

		CondicaoCobranca__c condicaoCobranca2 = new CondicaoCobranca__c();
		condicaoCobranca2.Produto__c = produtoComercialAtivo.Id;
		condicaoCobranca2.FormaPagamento__c = formaPagamento2.Id;
		condicaoCobranca2.QuantidadeParcelas__c = '3';
		insert condicaoCobranca2;

		CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
		canalDistribuicao.Name = 'Canal Distribuição Teste 001';
		insert canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Em aprovação';
		update canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Em revisão';
		update canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Em ativação';
		update canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Ativo';
		update canalDistribuicao;

		TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
		tipoRemuneracao.Name = 'Remuneração Teste';
		tipoRemuneracao.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracao.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracao;

		RemuneracaoProduto__c remuneracaoProduto = new RemuneracaoProduto__c();
		remuneracaoProduto.Produto__c = produtoComercialAtivo.Id;
		remuneracaoProduto.TipoRemuneracao__c = tipoRemuneracao.Id;
		insert remuneracaoProduto;

		ProdutoCanal__c produtoCanal = new ProdutoCanal__c();
		produtoCanal.CanalDistribuicao__c = canalDistribuicao.Id;
		produtoCanal.Produto__c = produtoComercialAtivo.Id;
		//produtoCanal.TipoRemuneracao__c = tipoRemuneracao.Id;
		insert produtoCanal;

		produtoCanal = [SELECT Id, MeioComercializacao__c FROM ProdutoCanal__c WHERE Id =: produtoCanal.Id LIMIT 1];
		produtoCanal.MeioComercializacao__c = 'PMC'; //PLV-4550 INICIO/FIM
		update produtoCanal;

		CampanhaIncentivo__c campanhaIncentivo1 = new CampanhaIncentivo__c();
		campanhaIncentivo1.Name = 'Campanha de incentivo 001';
		campanhaIncentivo1.VigenciaInicial__c = Date.valueOf(now);
		campanhaIncentivo1.VigenciaFinal__c = Date.valueOf(now.addDays(365));
		campanhaIncentivo1.TipoRemuneracao__c = tipoRemuneracao.Id;
		campanhaIncentivo1.MomentoPagamento__c = 'Emissão';
		campanhaIncentivo1.ModeloRemuneracao__c = 'Monetário';
		campanhaIncentivo1.Valor__c = 100.0;
		insert campanhaIncentivo1;

		CanalCampanha__c canalCampanha1 = new CanalCampanha__c();
		canalCampanha1.CampanhaIncentivo__c = campanhaIncentivo1.Id;
		canalCampanha1.CanalDistribuicao__c = canalDistribuicao.Id;
		canalCampanha1.Meio__c = 'Meio 1';
		canalCampanha1.Produto__c = produtoComercialAtivo.Id;
		insert canalCampanha1;

		// FormaPagamentoCampanhaTriggerHandler --------------------------------
		List<FormaPagamentoCampanha__c> ls1 = new List<FormaPagamentoCampanha__c>();

		FormaPagamentoCampanha__c formaPagamentoCampanha1 = new FormaPagamentoCampanha__c();
		formaPagamentoCampanha1.CanalCampanha__c = canalCampanha1.Id;
		formaPagamentoCampanha1.FormaPagamento__c = formaPagamento1.Id;
		ls1.add(formaPagamentoCampanha1);

		FormaPagamentoCampanha__c formaPagamentoCampanha2 = new FormaPagamentoCampanha__c();
		formaPagamentoCampanha2.CanalCampanha__c = canalCampanha1.Id;
		formaPagamentoCampanha2.FormaPagamento__c = formaPagamento2.Id;
		ls1.add(formaPagamentoCampanha2);

		insert ls1;

		formaPagamentoCampanha2 = [SELECT Id, FormaPagamento__c FROM FormaPagamentoCampanha__c WHERE Id =: formaPagamentoCampanha2.Id LIMIT 1];
		formaPagamentoCampanha2.FormaPagamento__c = formaPagamento3.Id;
		try {
			update formaPagamentoCampanha2;
		}
		catch(Exception e) {
			String mensagemEsperada = 'Forma de pagamento inexistente nas Condições de cobrança.';
			System.assert(e.getMessage().contains(mensagemEsperada), 'Mensagem de erro diferente da esperada: ' + mensagemEsperada);
			System.debug('::: mensagemEsperada: ' + mensagemEsperada);
		}

		ls1 = [SELECT Id, CanalCampanha__c, FormaPagamento__c FROM FormaPagamentoCampanha__c];
		System.assert(ls1.size() == 2, 'Quantidade de FormaPagamentoCampanha__c incorreto: ' + ls1.size() + '. Valor esperado: 2');
		// ---------------------------------------------------------------------

		// GarantiaCampanhaTriggerHandler --------------------------------------
		List<GarantiaCampanha__c> ls2 = new List<GarantiaCampanha__c>();

		GarantiaCampanha__c garantiaCampanha1 = new GarantiaCampanha__c();
		garantiaCampanha1.CanalCampanha__c = canalCampanha1.Id;
		garantiaCampanha1.Garantia__c = garantia1.Id;
		ls2.add(garantiaCampanha1);

		GarantiaCampanha__c garantiaCampanha2 = new GarantiaCampanha__c();
        //PLV-3667 - INICIO - Trecho comentado
		//garantiaCampanha2.CanalCampanha__c = canalCampanha1.Id;
		//garantiaCampanha2.Garantia__c = garantia2.Id;
		//ls2.add(garantiaCampanha2);
		//PLV-3667 - FIM
        //PLV - 3046 - INICIO
		try {
			insert ls2;

			ls2 = [SELECT Id, Garantia__c FROM GarantiaCampanha__c];
			//System.assert(ls2.size() == 2, 'Quantidade de GarantiaCampanha__c incorreto: ' + ls2.size() + '. Valor esperado: 2'); //PLV-3667 - INICIO/FIM - Trecho comentado

			garantiaCampanha2 = [SELECT Id, Garantia__c FROM GarantiaCampanha__c WHERE Id =: garantiaCampanha1.Id LIMIT 1]; //PLV-3667 - INICIO/FIM - Ajuste na query
			System.debug('garantiaCampanha2 ' + garantiaCampanha1);
			System.debug('garantiaParaErro ' + garantiaParaErro);
			garantiaCampanha2.Garantia__c = garantiaParaErro.Id;
		
			update garantiaCampanha2;
		}
        
        //PLV - 3046 - FIM
		catch(Exception e) {
			String mensagemEsperada = 'Garantia inexistente nas Garantias do produto.';
			System.assert(e.getMessage().contains(mensagemEsperada), 'Mensagem de erro diferente da esperada: ' + mensagemEsperada);
			System.debug('::: mensagemEsperada: ' + mensagemEsperada);
		}
		// ---------------------------------------------------------------------
		Test.stopTest();
	}


	/*@isTest
	static void testarValidacaoCanalCampanhaErro() {
		Test.startTest();
		Datetime now = System.now();

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		Product2 produtoTec = new Product2();
		produtoTec.Name = 'Nome produtoTec 001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.ProductCode = '201700001';
		produtoTec.Status__c = 'Em criação';
		produtoTec.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		insert produtoTec;

		ContentVersion versaoArquivoTec = new ContentVersion(
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
		insert arquivoTec;

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
		insert coberturaTec;

		Product2 produtoCom = new Product2();
		produtoCom.Produto__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		insert produtoCom;


		// Cria a versão do documento
		ContentVersion cv1 = new ContentVersion(
			Title = 'Test 001 - ' + now,
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + now),
			IsMajorVersion = true
		);
		insert cv1;

		// Cria a relação de produto produtoCom com documento documento
		ContentDocumentLink cdl1 = new ContentDocumentLink();
		cdl1.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv1.Id].ContentDocumentId;
		cdl1.LinkedEntityId = produtoCom.Id;
		cdl1.ShareType = 'V'; // ??
		insert cdl1;


		Product2 p2 = [SELECT Id, Name, Status__c FROM Product2 WHERE Id =: produtoCom.Id];
		p2.Status__c = 'Em ativação';
		p2.NumeroSusep__c = '1234';
		update p2;

		p2.Status__c = 'Ativo';
		update p2;

		CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
		canalDistribuicao.Name = 'Canal Distribuição Teste 001';
		insert canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Em aprovação';
		update canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Em revisão';
		update canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Em ativação';
		update canalDistribuicao;

		canalDistribuicao = [SELECT Id, Status__c FROM CanalDistribuicao__c WHERE Id =: canalDistribuicao.Id LIMIT 1];
		canalDistribuicao.Status__c = 'Ativo';
		update canalDistribuicao;

		TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
		tipoRemuneracao.Name = 'Remuneração Teste';
		tipoRemuneracao.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracao.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracao;

		RemuneracaoProduto__c remuneracaoProduto = new RemuneracaoProduto__c();
		remuneracaoProduto.Produto__c = p2.Id;
		remuneracaoProduto.TipoRemuneracao__c = tipoRemuneracao.Id;
		insert remuneracaoProduto;

		ProdutoCanal__c produtoCanal = new ProdutoCanal__c();
		produtoCanal.CanalDistribuicao__c = canalDistribuicao.Id;
		produtoCanal.Produto__c = p2.Id;
		//produtoCanal.TipoRemuneracao__c = tipoRemuneracao.Id;
		insert produtoCanal;

		produtoCanal = [SELECT Id, MeioComercializacao__c FROM ProdutoCanal__c WHERE Id =: produtoCanal.Id LIMIT 1];
		produtoCanal.MeioComercializacao__c = 'Meio 1';
		update produtoCanal;

		CampanhaIncentivo__c ci = new CampanhaIncentivo__c();
		ci.Name = 'Campanha de incentivo 001';
		ci.VigenciaInicial__c = Date.valueOf(now);
		ci.VigenciaFinal__c = Date.valueOf(now.addDays(365));
		ci.TipoRemuneracao__c = tipoRemuneracao.Id;
		ci.MomentoPagamento__c = 'Emissão';
		ci.ModeloRemuneracao__c = 'Monetário';
		ci.Valor__c = 100.0;
		insert ci;

		CanalCampanha__c cc = new CanalCampanha__c();
		cc.CampanhaIncentivo__c = ci.Id;
		cc.CanalDistribuicao__c = canalDistribuicao.Id;
		cc.Meio__c = 'Meio 1';
		cc.Produto__c = p2.Id;
		insert cc;

		Test.stopTest();
	}*/

}