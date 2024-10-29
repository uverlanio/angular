@isTest
private class RiscoTest {
	
	@testSetup
	private static void setup() {
		List<ContadorCodigo__c> contadoresProduto = new List<ContadorCodigo__c>{
			new ContadorCodigo__c(Name='ProdutoTecnico', Numero__c = 0),
			new ContadorCodigo__c(Name='ProdutoComercial', Numero__c = 0)
		};
		insert contadoresProduto;
	}
	
	@isTest
	static void testeAtivacaoDesativacaoCapitalRiscoGarantia() {
		Product2 produto = new Product2();
		produto.Name = 'Nome Produto 00';
		produto.Status__c = 'Em criação';
		produto.ProductCode = '2070000';
		produto.TipoResponsavelPagamento__c = 'SEG';
		insert produto;

		Garantia__c garantia = new Garantia__c();
		garantia.VigenciaInicial__c = System.today();
		garantia.Tipo__c = 'Benefício';
		insert garantia;

		//Insere garantia do produto e verifica situacao da flag de capital de risco
		GarantiaProduto__c garantiaProduto = new GarantiaProduto__c();
		garantiaProduto.Garantia__c = garantia.Id;
		garantiaProduto.Produto__c = produto.Id;
		garantiaProduto.TipoGarantia__c = 'Benefício';
		garantiaProduto.TipoCapital__c = 'Capital uniforme';
		insert garantiaProduto;

		garantiaProduto = [Select Id, CapitalRiscos__c From GarantiaProduto__c Where Id =: garantiaProduto.Id];
		System.assertEquals(garantiaProduto.CapitalRiscos__c, false);

		//Insere risco da garantia e verifica situacao da flag de capital de risco
		Risco__c risco = new Risco__c(Tabela__c = 'Majoração - Vida individual', Name = 'Risco 1');
		insert risco;

		RiscoGarantia__c riscoGarantia = new RiscoGarantia__c(Risco__c = risco.Id, GarantiaProduto__c = garantiaProduto.Id, TabelaRisco__c = 'Majoração - Vida individual');
		insert riscoGarantia;

		garantiaProduto = [Select Id, CapitalRiscos__c From GarantiaProduto__c Where Id =: garantiaProduto.Id];
		System.assertEquals(garantiaProduto.CapitalRiscos__c, true);

		//Exclui risco da garantia e verifica situacao da flag de capital de risco
		delete riscoGarantia;

		garantiaProduto = [Select Id, CapitalRiscos__c From GarantiaProduto__c Where Id =: garantiaProduto.Id];
		System.assertEquals(garantiaProduto.CapitalRiscos__c, false);
	}
}