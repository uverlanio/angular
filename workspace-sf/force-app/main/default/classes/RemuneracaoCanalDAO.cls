public class RemuneracaoCanalDAO {

	private static final RemuneracaoCanalDAO instance = new RemuneracaoCanalDAO();

	public static RemuneracaoCanalDAO getInstance() {
		return instance;
	}

	public List<RemuneracaoCanal__c> buscarRemuneracaoCanalPorProdutos(Set<Id> produtoCanalIds){
		return [
				Select
					Id,
					TipoRemuneracao__c,
					MeioComercializacao__c
				From 
					RemuneracaoCanal__c	
				Where 
					ProdutoCanal__c IN: produtoCanalIds
				];
	}
}