/**
 * Testes Remuneração multinível
 *
 **/
@isTest
private class RemuneracaoMultinivelTest {
	@testSetup
	private static void setup() {
		List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>{
			new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
			new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
		};
		insert contadoresProduto;
	}

	@isTest
	private static void testeValidacaoTipoRemuneracao(){
		TipoRemuneracao__c tipoRemuneracaoAgenciamento = new TipoRemuneracao__c();
		tipoRemuneracaoAgenciamento.Name = 'Agenciamento';
		tipoRemuneracaoAgenciamento.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
		tipoRemuneracaoAgenciamento.ModeloRecuperacao__c = 'Integral';
		insert tipoRemuneracaoAgenciamento;

		TipoRemuneracao__c tipoRemuneracaoCorretagem = new TipoRemuneracao__c();
		tipoRemuneracaoCorretagem.Name = 'Corretagem';
		tipoRemuneracaoCorretagem.Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.';
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
		remuneracaoProduto.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
		remuneracaoProduto.ParcelasAgenciamento__c = '1ª parcela';
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
		remuneracaoProdutoCom.ParcelasAgenciamento__c = '1ª parcela';
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

		RemuneracaoMultinivel__c remuneracaoMultinivel = new RemuneracaoMultinivel__c();
		remuneracaoMultinivel.ProdutoCanal__c = produtoCanal.Id;
		remuneracaoMultinivel.TipoRemuneracao__c = tipoRemuneracaoCorretagem.Id;
		remuneracaoMultinivel.Tipo__c = 'Nível 1';
		remuneracaoMultinivel.Participacao__c = 10;

		//Teste 1: tenta inserir uma remuneracao multinivel com o tipo de remuneracao diferente da remuneracao do produto
		String erro = '';

		try{
			insert remuneracaoMultinivel;
		}
		catch(Exception ex){
			erro = ex.getMessage();
		}

		System.assert(erro.indexOf('Este tipo de remuneração não está na remuneração do produto.') > -1);

		//Teste 2: tenta inserir um remuneracao do canal com parcelas de agenciamento iguais da remuneracao do produto
		erro = '';
		remuneracaoMultinivel.TipoRemuneracao__c = tipoRemuneracaoAgenciamento.Id;
		insert remuneracaoMultinivel;

		System.assert(remuneracaoMultinivel.Id != null);
	}
}