/**
 * Camada de negócios do objeto ProdutoCanal__c
 * @author Fernando Barcellos @ 06/02/2017
 *
 **/
public class ProdutoCanalBO {
	private static ProdutoCanalBO classInstance;
	private static ProdutoCanalDAO dao = ProdutoCanalDAO.getInstance();

	static {
		classInstance = new ProdutoCanalBO();
	}

	private ProdutoCanalBO() { }

	public static ProdutoCanalBO getInstance() {
		return classInstance;
	}

	//Retorna um registro de produto do canal de acordo com o Id
	public ProdutoCanal__c buscarProdutoCanal(Id produtoCanalId){
		return dao.buscarProdutoCanalPorId(produtoCanalId);
	}

	//Retorna registros de produtos do canal de acordo com os Ids
	public List<ProdutoCanal__c> buscarProdutoCanal(Set<Id> produtoCanalIds){
		return dao.buscarProdutoCanalPorIds(produtoCanalIds);
	}

	public List<ProdutoCanal__c> buscarProdutoCanalPorProdutos(Set<Id> produtoIds){
		return dao.buscarProdutoCanalPorProdutoIds(produtoIds);
	}

	//Realiza criação ou alteração de um produto do canal
	public void salvarProdutoCanal(ProdutoCanal__c produtoCanal){
		upsert produtoCanal;
	}

	public void gerarRemuneracaoObrigatoria(Map<Id, ProdutoCanal__c> mapNew) {
		try {
			Map<Id, Id> mapProdutoComercialProdutoCanal = new Map<Id, Id>();

			for (ProdutoCanal__c pc : mapNew.values()) {
				mapProdutoComercialProdutoCanal.put(pc.Produto__c, pc.Id);
			}

			List<RemuneracaoProduto__c> lstRemuneracaoProdutoObrigatorias = RemuneracaoProdutoBO.getInstance().buscarRemuneracoesObrigatoriasPorProduto(mapProdutoComercialProdutoCanal.keySet());

			if (lstRemuneracaoProdutoObrigatorias.isEmpty()) {
				return;
			}

			List<RemuneracaoCanal__c> lstRemuneracaoCanalObrigatorias = new List<RemuneracaoCanal__c>();

			for (RemuneracaoProduto__c rp : lstRemuneracaoProdutoObrigatorias) {
				RemuneracaoCanal__c temp = new RemuneracaoCanal__c();
				temp.TipoRemuneracao__c = rp.TipoRemuneracao__c;
				temp.ProdutoCanal__c = mapProdutoComercialProdutoCanal.get(rp.Produto__c);
				lstRemuneracaoCanalObrigatorias.add(temp);
			}

			insert lstRemuneracaoCanalObrigatorias;

		}
		catch(Exception e) {
			System.debug('::: Error: ' + e.getLineNumber() + ': ' + e.getMessage());
		}
	}

	//TODO: CRIAR METODO GENERICO
	public void atualizarVersaoProdutoCanal(Map<String, Product2> mapProdutoMaximaVersao, List<ProdutoCanal__c> produtosCanal){
		List<ProdutoCanal__c> produtoCanalAtualizar = new List<ProdutoCanal__c>();

		for(ProdutoCanal__c produtoCanal : produtosCanal){

			// Verifica se existe um produto com a versão maxima e ativo
			if(!mapProdutoMaximaVersao.containsKey(produtoCanal.Produto__r.ProductCode)) continue;

			Product2 produtoAtualizado = mapProdutoMaximaVersao.get(produtoCanal.Produto__r.ProductCode);

			if(produtoCanal.Produto__r.Versao__c != produtoAtualizado.Versao__c){

				produtoCanal.Produto__c = produtoAtualizado.Id;
				produtoCanalAtualizar.add(produtoCanal);
			}
		}

		if (!produtoCanalAtualizar.isEmpty()) {
			update produtoCanalAtualizar;
		}
	}
}