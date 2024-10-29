/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelas buscas no objeto de Premios minimo do produto
 *
 **************************************************************************************************************************************************************************/
public class PremioMinimoProdutoDAO {
	private static final PremioMinimoProdutoDAO instance = new PremioMinimoProdutoDAO();
	
	private PremioMinimoProdutoDAO() {
	}

	public static PremioMinimoProdutoDAO getInstance() {
		return instance;
	}	

	/**
	 * Realiza busca dos premios de acordo com os parametros
	 *
	 * @param   formaPagamentoId  - id da forma de pagamento
	 * @param   tipoContratacao  - valor de tipo de contratação
	 * @param   periodicidade  - valor de tipo de periodicidade
	 */
	public List<PremioMinimoProduto__c> buscarPremios(Set<Id> produtosIds, Set<Id> premiosMinimosIds) {
		return [
			Select 
				Id,
				FormaPagamento__c,
				PeriodicidadePagamento__c,
				PremioMinimoParcela__c,
				TipoContratacao__c
			From 
				PremioMinimoProduto__c	
			Where 
				Produto__c IN: produtosIds
			And Id NOT IN: premiosMinimosIds
		];
	}

	public List<PremioMinimoProduto__c> buscarPremiosProduto(Set<Id> produtosIds) 
	{
		return [
			Select 
				Id,
				FormaPagamento__c,
				PeriodicidadePagamento__c,
				PremioMinimoParcela__c,
				TipoContratacao__c,
			//PLV-5230 - INICIO
				Produto__c,
				FormaPagamento__r.Codigo__c
			//PLV-5230 - FIM
			From 
				PremioMinimoProduto__c	
			Where 
				Produto__c IN: produtosIds
		];
	}

	public List<PremioMinimoProduto__c> buscarPremiosPorId(Set<Id> premiosMinimosIds) {
		return [
			Select 
				Id,
				FormaPagamento__c,
				PeriodicidadePagamento__c,
				PremioMinimoParcela__c,
				TipoContratacao__c,
				ValidarRegrasProdutoComercial__c
			From 
				PremioMinimoProduto__c	
			Where 
				Id IN: premiosMinimosIds
		];
	}
}