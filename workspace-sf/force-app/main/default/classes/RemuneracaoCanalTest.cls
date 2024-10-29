/** 
 * Testes Remuneração do canal
 *
 **/
@isTest
private class RemuneracaoCanalTest {
	@testSetup
	private static void setup() {
		List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>{
			new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
			new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
		};
		insert contadoresProduto;
	}

	@isTest
	private static void testeValidacaoParcelasAgenciamento(){
		TipoRemuneracao__c tipoRemuneracaoAgenciamento = new TipoRemuneracao__c();
		tipoRemuneracaoAgenciamento.Name = 'Agenciamento';
		tipoRemuneracaoAgenciamento.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracaoAgenciamento.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracaoAgenciamento;

		TipoRemuneracao__c tipoRemuneracaoCorretagem = new TipoRemuneracao__c();
		tipoRemuneracaoCorretagem.Name = 'CORRETAGEM';
		tipoRemuneracaoCorretagem.Descricao__c = 'Corretagem.';
		tipoRemuneracaoCorretagem.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracaoCorretagem;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
		canalDistribuicao.Name = 'Canal Distribuição Teste 001';
		insert canalDistribuicao;

		//Criação da estrutura do produto técnico
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

		RemuneracaoProduto__c remuneracaoProduto = new RemuneracaoProduto__c();
		remuneracaoProduto.Produto__c = produtoTec.Id;
		remuneracaoProduto.Obrigatoria__c = true;
		remuneracaoProduto.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
		remuneracaoProduto.ParcelasAgenciamento__c = '1ª parcela;2ª parcela';
		insert remuneracaoProduto;

		//Criação da estrutura do produto comercial
		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		RemuneracaoProduto__c remuneracaoProdutoCom = new RemuneracaoProduto__c();
		remuneracaoProdutoCom.Produto__c = produtoCom.Id;
		remuneracaoProdutoCom.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
		remuneracaoProdutoCom.Obrigatoria__c = true;
		remuneracaoProdutoCom.ParcelasAgenciamento__c = '1ª parcela';
		insert remuneracaoProdutoCom;

		RemuneracaoProduto__c remuneracaoProdutoCom2 = new RemuneracaoProduto__c();
		remuneracaoProdutoCom2.Produto__c = produtoCom.Id;
		remuneracaoProdutoCom2.TipoRemuneracao__c = tipoRemuneracaoCorretagem.Id;
		insert remuneracaoProdutoCom2;
		//correcao ambientes inicio
		// Cria a versão do documento
		/* ContentVersion cv1 = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
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

		produtoCom.Status__c = 'Em ativação';
		produtoCom.NumeroSusep__c = '1234';
		update produtoCom;

		produtoCom.Status__c = 'Ativo';
		update produtoCom;

		ProdutoCanal__c produtoCanal = new ProdutoCanal__c();
		produtoCanal.CanalDistribuicao__c = canalDistribuicao.Id;
		produtoCanal.Produto__c = produtoCom.Id;
		insert produtoCanal;

		RemuneracaoCanal__c remuneracaoCanal = new RemuneracaoCanal__c();
		remuneracaoCanal.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoCanal.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;

		RemuneracaoCanal__c remuneracaoCanal2 = new RemuneracaoCanal__c();
		remuneracaoCanal2.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoCanal2.TipoRemuneracao__c = tipoRemuneracaoCorretagem.Id;
		insert remuneracaoCanal2;

		//Teste 1: tenta inserir um remuneracao do canal com parcelas de agenciamento diferentes da remuneracao do produto
		String erro = '';

		try{
			insert remuneracaoCanal;
		}
		catch(Exception ex){
			erro = ex.getMessage();
		}

		System.assert(erro.indexOf('As Parcelas de agenciamento devem ser iguais as Parcelas de agenciamento da Remuneração do produto.') > -1);

		//Teste 2: tenta inserir um remuneracao do canal com parcelas de agenciamento iguais da remuneracao do produto
		erro = '';
		remuneracaoCanal.ParcelasAgenciamento__c = '1ª parcela';
		insert remuneracaoCanal;
		System.assert(remuneracaoCanal.Id != null);

		// verifica se a remuneracao do produto é obrigatória, impedindo a remoção

		try {
			delete remuneracaoCanal;
		}
		catch(Exception ex) {
			erro = ex.getMessage();
		}

		System.assert(erro.indexOf('Esta Remuneração do canal é obrigatória no Produto comercial e não será excluída.') > -1);

		remuneracaoCanal2.ObrigatorioNotaFiscalPagamento__c = true;
		update remuneracaoCanal2;

		delete remuneracaoCanal2;
	}

	@isTest
	private static void testeValidacaoLimites(){
		TipoRemuneracao__c tipoRemuneracaoAgenciamento = new TipoRemuneracao__c();
		tipoRemuneracaoAgenciamento.Name = 'Agenciamento';
		tipoRemuneracaoAgenciamento.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracaoAgenciamento.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracaoAgenciamento;

		TipoRemuneracao__c tipoRemuneracaoCorretagem = new TipoRemuneracao__c();
		tipoRemuneracaoCorretagem.Name = 'CORRETAGEM';
		tipoRemuneracaoCorretagem.Descricao__c = 'Corretagem.';
		tipoRemuneracaoCorretagem.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracaoCorretagem;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
		canalDistribuicao.Name = 'Canal Distribuição Teste 001';
		insert canalDistribuicao;

		//Criação da estrutura do produto técnico
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

		RemuneracaoProduto__c remuneracaoProduto = new RemuneracaoProduto__c();
		remuneracaoProduto.Produto__c = produtoTec.Id;
		remuneracaoProduto.Obrigatoria__c = true;
		remuneracaoProduto.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
		remuneracaoProduto.ParcelasAgenciamento__c = '1ª parcela;2ª parcela';
		insert remuneracaoProduto;

		//Criação da estrutura do produto comercial
		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		RemuneracaoProduto__c remuneracaoProdutoCom = new RemuneracaoProduto__c();
		remuneracaoProdutoCom.Produto__c = produtoCom.Id;
		remuneracaoProdutoCom.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
		remuneracaoProdutoCom.Obrigatoria__c = true;
		remuneracaoProdutoCom.ParcelasAgenciamento__c = '1ª parcela';
		remuneracaoProdutoCom.LimiteMinimo__c = 10;
		remuneracaoProdutoCom.LimiteMaximo__c = 50;
		insert remuneracaoProdutoCom;
		//correcao ambientes inicio
		// Cria a versão do documento
		/* ContentVersion cv1 = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
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

		produtoCom.Status__c = 'Em ativação';
		produtoCom.NumeroSusep__c = '1234';
		update produtoCom;

		produtoCom.Status__c = 'Ativo';
		update produtoCom;

		ProdutoCanal__c produtoCanal = new ProdutoCanal__c();
		produtoCanal.CanalDistribuicao__c = canalDistribuicao.Id;
		produtoCanal.Produto__c = produtoCom.Id;
		insert produtoCanal;

		RemuneracaoCanal__c remuneracaoCanal = new RemuneracaoCanal__c();
		remuneracaoCanal.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoCanal.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
		remuneracaoCanal.LimiteMinimo__c = 5;
		remuneracaoCanal.LimiteMaximo__c = 40;
		remuneracaoCanal.ParcelasAgenciamento__c = '1ª parcela';


		//Teste 1: tenta inserir um remuneracao do canal com limite minimo invalido
		String erro = '';

		try{
			insert remuneracaoCanal;
		}
		catch(Exception ex){
			erro = ex.getMessage();
		}

		System.assert(erro.indexOf('Limite mínimo inválido. O limite informado menor que o limite permitido no produto.') > -1);


		//Teste 2: tenta inserir um remuneracao do canal com limite maximo invalido	
		try{
			remuneracaoCanal.LimiteMinimo__c = 20;
			remuneracaoCanal.LimiteMaximo__c = 400;
			insert remuneracaoCanal;
		}
		catch(Exception ex){
			erro = ex.getMessage();
		}

		System.assert(erro.indexOf('Limite máximo inválido. O limite informado maior que o limite permitido no produto') > -1);

		//Teste 3: tenta inserir um remuneracao do canal com limites OK
		remuneracaoCanal.LimiteMinimo__c = 20;
		remuneracaoCanal.LimiteMaximo__c = 40;
		insert remuneracaoCanal;

		System.assert(remuneracaoCanal.Id != null);
	}

	@isTest
	private static void testeValidarMeioComercializacao(){
		TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c();
		tipoRemuneracao.Name = 'PRO-LABORE';
		tipoRemuneracao.Descricao__c = 'PRO-LABORE';
		tipoRemuneracao.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracao;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Cobertura';
		insert garantia;

		CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c();
		canalDistribuicao.Name = 'Canal Distribuição Teste 001';
		insert canalDistribuicao;

		//Criação da estrutura do produto técnico
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

		RemuneracaoProduto__c remuneracaoProduto = new RemuneracaoProduto__c();
		remuneracaoProduto.Produto__c = produtoTec.Id;
		remuneracaoProduto.Obrigatoria__c = true;
		remuneracaoProduto.TipoRemuneracao__c = tipoRemuneracao.Id;
		insert remuneracaoProduto;

		//Criação da estrutura do produto comercial
		Product2 produtoCom = new Product2();
		produtoCom.ProdutoTecnico__c = produtoTec.Id;
		produtoCom.Name = 'Nome ProdutoCom 001';
		produtoCom.Status__c = 'Em criação';
		produtoCom.ProductCode = '201700001';
		produtoCom.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		produtoCom.TipoResponsavelPagamento__c = 'SEG';
		insert produtoCom;

		RemuneracaoProduto__c remuneracaoProdutoCom = new RemuneracaoProduto__c();
		remuneracaoProdutoCom.Produto__c = produtoCom.Id;
		remuneracaoProdutoCom.TipoRemuneracao__c = tipoRemuneracao.Id;
		remuneracaoProdutoCom.Obrigatoria__c = true;
		insert remuneracaoProdutoCom;
		//correcao ambientes inicio
		// Cria a versão do documento
		/* ContentVersion cv1 = new ContentVersion(
			Title = 'Test 001 - ' + System.now(),
			PathOnClient = 'test_001.txt',
			VersionData = Blob.valueOf('Arquivo #001 de amostra ' + System.now()),
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

		produtoCom.Status__c = 'Em ativação';
		produtoCom.NumeroSusep__c = '1234';
		update produtoCom;

		produtoCom.Status__c = 'Ativo';
		update produtoCom;

		ProdutoCanal__c produtoCanal = new ProdutoCanal__c();
		produtoCanal.CanalDistribuicao__c = canalDistribuicao.Id;
		produtoCanal.Produto__c = produtoCom.Id;
		insert produtoCanal;

		RemuneracaoCanal__c remuneracaoCanal = new RemuneracaoCanal__c();
		remuneracaoCanal.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoCanal.TipoRemuneracao__c = tipoRemuneracao.Id;
		remuneracaoCanal.MeioComercializacao__c = 'PMC'; //PLV-4550 INICIO/FIM
		insert remuneracaoCanal;

		RemuneracaoCanal__c remuneracaoCanal2 = new RemuneracaoCanal__c();
		remuneracaoCanal2.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoCanal2.TipoRemuneracao__c = tipoRemuneracao.Id;
		remuneracaoCanal.MeioComercializacao__c = 'PMC'; //PLV-4550 INICIO/FIM

		//Teste inserir o mesmo meio de comercialização e tipo de remuneração 
		String erro = '';

		try{
			insert remuneracaoCanal2;
		}
		catch(Exception ex){
			erro = ex.getMessage();
		}

		System.debug(erro);

		System.assert(erro.indexOf('Tipo Remuneração/Meio de Comercialização já cadastrado.') > -1);

	}


}