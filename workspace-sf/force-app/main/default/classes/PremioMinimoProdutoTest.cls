@isTest
private class PremioMinimoProdutoTest {

	@testSetup
	private static void setup() {
		List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>{
			new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
			new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
		};
		insert contadoresProduto;
	}
	
	@isTest 
	static void testeCriacaoPremioProduto() {
		//Cria base de dados
		Product2 produto = new Product2(
			Name = 'Nome Produto 001 - ' + System.now(),
			Status__c = 'Em criação',
			ProductCode = '201700001',
			TipoResponsavelPagamento__c = 'SEG'
		);		
		
		insert produto;

		FormaPagamento__c formaPagamento = new FormaPagamento__c(
			Codigo__c = '1234',
			Name = '3X'
		);

		insert formaPagamento;

		//Insere um premio
		PremioMinimoProduto__c premio1 = new PremioMinimoProduto__c(
			Produto__c = produto.Id,
			FormaPagamento__c = formaPagamento.Id,
			PeriodicidadePagamento__c = 'Anual',
			TipoContratacao__c = 'Novo',
			PremioMinimoParcela__c = 100
		);

		insert premio1;
		System.assert(String.isNotBlank(premio1.Id));

		//Tenta inserir um novo premio com os mesmos valores do anterior
		PremioMinimoProduto__c premio2 = new PremioMinimoProduto__c(
			Produto__c = produto.Id,
			FormaPagamento__c = formaPagamento.Id,
			PeriodicidadePagamento__c = 'Anual',
			TipoContratacao__c = 'Novo',
			PremioMinimoParcela__c = 100
		);

		String mensagemErro = '';

		try {
			insert premio2;	
		} catch(Exception ex) {
			mensagemErro = ex.getMessage();
		}

		System.assert(mensagemErro.indexOf('Cadastro de prêmio já existente para estes valores') > -1);

		//Altera um valor e insere 
		premio2.PeriodicidadePagamento__c = 'Mensal';
		insert premio2;
		System.assert(String.isNotBlank(premio2.Id));


		//Altera um valor para que o registro seja igual a um outro já cadastrado
		premio2.PeriodicidadePagamento__c = 'Anual';
		mensagemErro = '';

		try {
			update premio2;	
		} catch(Exception ex) {
			mensagemErro = ex.getMessage();
		}
		
		System.assert(mensagemErro.indexOf('Cadastro de prêmio já existente para estes valores') > -1);
	}
	
}