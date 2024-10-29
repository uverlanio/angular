/**
 * Testes do objeto ProdutoCanal__c 
 * @author Fernando Barcellos @ 23/01/2018
 *
 **/
@isTest
private class ProdutoCanalTest {

	@testSetup
	private static void setup() {
		List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>{
			new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
			new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
		};
		insert contadoresProduto;
	}

	@isTest
	private static void componenteCadastroDocumentosNaoNecessarios() {
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
		coberturaTec.TipoGarantia__c = 'Cobertura';
		coberturaTec.TipoCapital__c = 'Capital uniforme';
		insert coberturaTec;

		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

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

		Product2 produtoComercial = [SELECT Id, Name, Status__c FROM Product2 WHERE Id =: produtoCom.Id];
		produtoComercial.Status__c = 'Em ativação';
		produtoComercial.NumeroSusep__c = '1234';
		update produtoComercial;

		produtoComercial.Status__c = 'Ativo';
		update produtoComercial;

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

		TipoRemuneracao__c tipoRemuneracao1 = new TipoRemuneracao__c();
		tipoRemuneracao1.Name = 'Remuneração 001';
		tipoRemuneracao1.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracao1.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracao1;

		TipoRemuneracao__c tipoRemuneracao2 = new TipoRemuneracao__c();
		tipoRemuneracao2.Name = 'Remuneração 002';
		tipoRemuneracao2.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracao2.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracao2;

		RemuneracaoProduto__c remuneracaoProduto1 = new RemuneracaoProduto__c();
		remuneracaoProduto1.Produto__c = produtoComercial.Id;
		remuneracaoProduto1.TipoRemuneracao__c = tipoRemuneracao1.Id;
		remuneracaoProduto1.Obrigatoria__c = false;
		insert remuneracaoProduto1;

		RemuneracaoProduto__c remuneracaoProduto2 = new RemuneracaoProduto__c();
		remuneracaoProduto2.Produto__c = produtoComercial.Id;
		remuneracaoProduto2.TipoRemuneracao__c = tipoRemuneracao2.Id;
		remuneracaoProduto2.Obrigatoria__c = true;
		insert remuneracaoProduto2;

		DocumentoProduto__c documentoProdutoEntrada1 = new DocumentoProduto__c();
		documentoProdutoEntrada1.Produto__c = produtoComercial.Id;
		documentoProdutoEntrada1.MomentoEnvio__c = 'Endosso';
		documentoProdutoEntrada1.Tipo__c = 'Entrada';
		documentoProdutoEntrada1.MeioEnvio__c = 'Email';
		documentoProdutoEntrada1.Documento__c = 'Declaração Pessoal de Saúde';
		documentoProdutoEntrada1.Papel__c = 'Corretor';
		documentoProdutoEntrada1.Descricao__c = 'Documento do produto - Entrada';
		insert documentoProdutoEntrada1;

		DocumentoProduto__c documentoProdutoSaida1 = new DocumentoProduto__c();
		documentoProdutoSaida1.Produto__c = produtoComercial.Id;
		documentoProdutoSaida1.MomentoEnvio__c = 'Novo';
		documentoProdutoSaida1.Tipo__c = 'Saída';
		documentoProdutoSaida1.MeioEnvio__c = 'Portal do cliente';
		documentoProdutoSaida1.Documento__c = 'Apólice de Seguro';
		documentoProdutoSaida1.Papel__c = 'Parceiro';
		documentoProdutoSaida1.Descricao__c = 'Documento do produto - Saída';
		insert documentoProdutoSaida1;

		ProdutoCanal__c produtoCanal = new ProdutoCanal__c();
		produtoCanal.CanalDistribuicao__c = canalDistribuicao.Id;
		produtoCanal.Produto__c = produtoComercial.Id;
		produtoCanal.MeioComercializacao__c = 'PMC'; //PLV-4550 INICIO/FIM
		insert produtoCanal;


//		ProductBO.getInstance().atribuirVersaoMaxima(new List<Product2>{produtoComercial});

		//Simula uso do componente realizando as chamadas

		//Teste: busca dados do produto do canal
		ProdutoCanal__c produtoCanalBusca = DocumentosNaoNecessariosController.buscarProdutoCanal(produtoCanal.Id);
		System.assertEquals(produtoCanal.Id, produtoCanalBusca.Id);

		//Teste: busca documentos do produto
		List<DocumentoProduto__c> documentos = DocumentosNaoNecessariosController.buscarDocumentosProduto(produtoCanalBusca.Produto__c);
		System.assertEquals(2, documentos.size());

		//Teste: altera ProdutoCanal e salva as alterações
		produtoCanalBusca.DocumentosNaoNecessariosEntrada__c = 'Declaração Pessoal de Saúde';
		produtoCanalBusca.DocumentosNaoNecessariosSaida__c = 'Apólice de Seguro';
		DocumentosNaoNecessariosController.salvarProdutoCanal(produtoCanalBusca);

		ProdutoCanal__c produtoCanalVerificacao = DocumentosNaoNecessariosController.buscarProdutoCanal(produtoCanal.Id);
		System.assertEquals(produtoCanal.Id, produtoCanalVerificacao.Id);
		System.assertEquals(produtoCanalVerificacao.DocumentosNaoNecessariosEntrada__c, documentoProdutoEntrada1.Documento__c);
		System.assertEquals(produtoCanalVerificacao.DocumentosNaoNecessariosSaida__c, documentoProdutoSaida1.Documento__c);
		System.assertEquals(produtoCanal.Id, produtoCanalVerificacao.Id);

		Test.stopTest();
	}
}