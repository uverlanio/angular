/**
 * BO CanalCampanha__c
 * @author Fernando Barcellos @ 18/01/2018
 *
 **/
public class CanalCampanhaBO {
	private static final CanalCampanhaBO instance = new CanalCampanhaBO();
	
	public static CanalCampanhaBO getInstance() {
		return instance;
	}

	private CanalCampanhaBO() { }

	public void validarProdutoCanalDistribuicao(List<CanalCampanha__c> lstCanalCampanha) {
		for (CanalCampanha__c canalCampanha : lstCanalCampanha) {
			List<ProdutoCanal__c> produtosCanal = ProdutoCanalDAO.getInstance().buscarProdutoCanalPorCanalDistribuicao(canalCampanha.CanalDistribuicao__c);
			Set<Id> setIdsProdutos = new Set<Id>();
			for (ProdutoCanal__c produtoCanal : produtosCanal) {
				setIdsProdutos.add(produtoCanal.Produto__c);
			}
			if (!setIdsProdutos.contains(canalCampanha.Produto__c)) {
				canalCampanha.addError('Este produto não está no canal de distribuição.');
			}
		}
	}
}