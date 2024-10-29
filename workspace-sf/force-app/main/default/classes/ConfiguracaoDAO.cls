/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pela busca de dados de Configuracao__c
 *
 **************************************************************************************************************************************************************************/
public  class ConfiguracaoDAO {
	private static final ConfiguracaoDAO instancia = new ConfiguracaoDAO();

	private ConfiguracaoDAO() {	
	}

	public static ConfiguracaoDAO getInstance(){
		return instancia;
	}

	public Configuracao__c buscarConfiguracao(Id configuracaoId){
		List<Configuracao__c> lista = this.buscarConfiguracoes(new Set<Id>{configuracaoId});
		return !lista.isEmpty() ? lista.get(0) : null;
	}

	public List<Configuracao__c> buscarConfiguracoes(Set<Id> configuracaoIds){
		return [
			Select
				Id,
				Name,
				Segmento__c,
				(
					Select
						Id,
						Produto__c,
						Configuracao__c,
						Editavel__c,
						Ordem__c
					From
						ProdutosConfiguracao__r	
				),
				(
					Select
						Id,
						Campo__c,
						Operador__c,
						Valor__c
					From
						CriteriosConfiguracao__r	
				)
			From	
				Configuracao__c
			Where 
				Id IN :configuracaoIds
		];
	}

	public List<Configuracao__c> buscarConfiguracoesVigentesPorSegmento(String segmento){
		return [
			Select
				Id,
				Name,
				Segmento__c,
				(
					Select
						Id,
						Campo__c,
						Operador__c,
						Valor__c
					From
						CriteriosConfiguracao__r	
				)
			From	
				Configuracao__c
			Where 
				Segmento__c Includes (:segmento)
			And VigenciaInicial__c <= TODAY
			And (VigenciaFinal__c >= TODAY OR VigenciaFinal__c = null)
			And Status__c = 'Ativo'
		];
	}

	public List<ProdutoConfiguracao__c> buscarProdutosConfiguracaoPorConfIds(Set<Id> configuracoesIds){
		return [
			Select
				Id,
				Produto__c,
				Produto__r.Name,
				Produto__r.ProductCode,
				Produto__r.Versao__c,
				(
					Select
						Id,
						ProdutoConfiguracao__c,
						TipoLimiteCapital__c,
						LimiteCapital__c,
						GarantiaProduto__c,
						GarantiaProduto__r.Name,
						GarantiaProduto__r.CapitalRiscos__c,
						GarantiaProduto__r.Produto__c,
						GarantiaProduto__r.OrdemPrioridade__c,
						GarantiaProduto__r.Garantia__c,
						GarantiaProduto__r.Garantia__r.Name,
						GarantiaProduto__r.GarantiaProduto__c,
						GarantiaProduto__r.TipoCapital__c,
						GarantiaProduto__r.ValorInicial__c,
						GarantiaProduto__r.ValorFinal__c,
						GarantiaProduto__r.PercentualAgravoMinimo__c,
						GarantiaProduto__r.PercentualAgravoMaximo__c,
						GarantiaProduto__r.PercentualDescontoMinimo__c,
						GarantiaProduto__r.PercentualDescontoMaximo__c,
						GarantiaProduto__r.CurrencyIsoCode,
						GarantiaProduto__r.Garantia__r.Sigla__c
					From
						GarantiasProdutoConfiguracao__r	
				)
			From	
				ProdutoConfiguracao__c
			Where 
				Configuracao__c IN :configuracoesIds
		];
	}

	public List<GarantiaProdutoConfiguracao__c> buscarGarantiasProdutosConfiguracao(Id produtoConfiguracaoId){
		return [
			Select
				Id,
				ProdutoConfiguracao__c,
				GarantiaProduto__c,
				TipoLimiteCapital__c,
				LimiteCapital__c
			From	
				GarantiaProdutoConfiguracao__c
			Where 
				ProdutoConfiguracao__c = :produtoConfiguracaoId
		];
	}
}