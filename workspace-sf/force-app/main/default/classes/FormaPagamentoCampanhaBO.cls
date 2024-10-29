/**
 * FormaPagamentoCampanhaBO
 * @author Fernando Barcellos @ 27/02/2018
 *
 **/
public class FormaPagamentoCampanhaBO {
	private static final FormaPagamentoCampanhaBO instancia = new FormaPagamentoCampanhaBO();
	//private InformacaoBancariaDAO dao = InformacaoBancariaDAO.getInstance();

	private FormaPagamentoCampanhaBO() {	
	}

	public static FormaPagamentoCampanhaBO getInstance(){
		return instancia;
	}

	public void validarFormasPagamento(List<FormaPagamentoCampanha__c> formasPagamentoCampanhas) {
		// MAPA IDS: FORMA PAGAMENTO X CANAL CAMPANHA
		Set<Id> idsCanalCampanha = new Set<Id>();
		Set<Id> idsFormasPagamento = new Set<Id>();
		for (FormaPagamentoCampanha__c formaPagamentoCampanha : formasPagamentoCampanhas) {
			idsCanalCampanha.add(formaPagamentoCampanha.CanalCampanha__c);
			idsFormasPagamento.add(formaPagamentoCampanha.FormaPagamento__c);
		}
		// ---------------------------------------------------------------------

		// CANAIS CAMPANHA
		List<CanalCampanha__c> canaisCampanha = CanalCampanhaDAO.getInstance().buscarCanaisCampanhaPorId(idsCanalCampanha);
		Map<Id, Product2> mapCanalCampanhaProduto = new Map<Id, Product2>();
		Map<Id, Id> mapProdutoCanalCampanha = new Map<Id, Id>();

		for (CanalCampanha__c canalCampanha : canaisCampanha) {
			mapCanalCampanhaProduto.put(canalCampanha.Id, null);
			mapProdutoCanalCampanha.put(canalCampanha.Produto__c, canalCampanha.Id);
		}
		// ---------------------------------------------------------------------

		// PRODUTO x CONDICOES COBRANCA
		List<Product2> produtosCondicaoCobranca = ProductDAO.getInstance().buscarProdutosComCondicoesCobranca(mapProdutoCanalCampanha.keySet());
		for (Product2 produto : produtosCondicaoCobranca) {
			mapCanalCampanhaProduto.put(mapProdutoCanalCampanha.get(produto.Id), produto);
		}
		// ---------------------------------------------------------------------

		// VALIDAÇÃO
		for (FormaPagamentoCampanha__c formaPagamentoCampanha : formasPagamentoCampanhas) {
			Set<Id> idsFormasPagamentoExistentesProduto = new Set<Id>();
			Product2 produto = mapCanalCampanhaProduto.get(formaPagamentoCampanha.CanalCampanha__c);

			for (CondicaoCobranca__c condicaoCobranca : produto.CondicoesCobranca__r) {
				idsFormasPagamentoExistentesProduto.add(condicaoCobranca.FormaPagamento__c);
			}

			if (!idsFormasPagamento.containsAll(idsFormasPagamentoExistentesProduto)) {
				formaPagamentoCampanha.addError('Forma de pagamento inexistente nas Condições de cobrança.');
			}
		}
		// ---------------------------------------------------------------------
	}
}