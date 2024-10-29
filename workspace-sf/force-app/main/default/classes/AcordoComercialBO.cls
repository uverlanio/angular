/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de AcordoComercial__c
 *
 **************************************************************************************************************************************************************************/
public class AcordoComercialBO {
	private static final AcordoComercialBO instancia = new AcordoComercialBO();
	private static AcordoComercialDAO dao = AcordoComercialDAO.getInstance();

	private AcordoComercialBO() {	
	}

	public static AcordoComercialBO getInstance(){
		return instancia;
	}

	/**
	 * Gera produtos do acordo, de acordo com o canal vinculado com o Acordo
	 *
	 */
	public void gerarProdutosAcordoComercial(Id acordoComercialId){
		AcordoComercial__c acordo = dao.buscarAcordoComercialPorId(new Set<Id> {acordoComercialId}).get(0);

		//Verifica se há canal de distribuição no acordo
		if(String.isNotBlank(acordo.CanalDistribuicao__c)){
			List<ProdutoAcordo__c> produtosAcordoInsert = new List<ProdutoAcordo__c>();

			//Busca os produtos do canal de distribuição e preenche map com a relação de canal/produtos
			for(CanalDistribuicao__c canalDist : CanalDistribuicaoBO.getInstance().buscarCanalDistribuicaoComFilhos(new Set<Id>{acordo.CanalDistribuicao__c})){
				//Recupera todo os produtos de um canal de distribuição
				for(ProdutoCanal__c produtoCanal : canalDist.ProdutosCanal__r){
					produtosAcordoInsert.add(new ProdutoAcordo__c(
						Produto__c = produtoCanal.Produto__c,
						AcordoComercial__c = acordo.Id
					));
				}
			}

			//Verifica se já há produtos no acordo
			List<ProdutoAcordo__c> produtosAcordoDelete = dao.buscarProdutosAcordoPorAcordoId(new Set<Id> {acordoComercialId});

			if(!produtosAcordoDelete.isEmpty()){
				delete produtosAcordoDelete;
			}

			//Insere produtos do acordo
			if(!produtosAcordoInsert.isEmpty()){
				insert produtosAcordoInsert;
			}
		}
		else{
			throw new AcordoComercialException('Não foi possível gerar os produtos do acordo, pois não foi encontrado Canal de distribuição.');
		}
	}
	public void atualizarVersaoProdutoAcordoComercial(Map<String, Product2> mapProdutoMaximaVersao, List<ProdutoAcordo__c> produtosAcordoComercial){

	    List<ProdutoAcordo__c> produtoAcordoComercialAtualizar = new List<ProdutoAcordo__c>();
	    for(ProdutoAcordo__c produtoAcordoComercial : produtosAcordoComercial){

				// Verifica se existe um produto com a versão maxima e ativo
				if(!mapProdutoMaximaVersao.containsKey(produtoAcordoComercial.Produto__r.ProductCode)) continue;

				Product2 produtoAtualizado = mapProdutoMaximaVersao.get(produtoAcordoComercial.Produto__r.ProductCode);

	        if(produtoAcordoComercial.Produto__r.Versao__c != produtoAtualizado.Versao__c){
	        
	            produtoAcordoComercial.Produto__c = produtoAtualizado.Id;
	            produtoAcordoComercialAtualizar.add(produtoAcordoComercial);
	        }
	    
	    }

		if (!produtoAcordoComercialAtualizar.isEmpty()) {
			update produtoAcordoComercialAtualizar;
		}
	}

	public class AcordoComercialException extends Exception{}
}