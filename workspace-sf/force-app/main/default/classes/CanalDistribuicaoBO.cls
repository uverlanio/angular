/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de AcordoComercial__c
 *
 **************************************************************************************************************************************************************************/
public class CanalDistribuicaoBO {
	private static final CanalDistribuicaoBO instancia = new CanalDistribuicaoBO();
	private static CanalDistribuicaoDAO dao = CanalDistribuicaoDAO.getInstance();

	private CanalDistribuicaoBO() {	
	}

	public static CanalDistribuicaoBO getInstance(){
		return instancia;
	}

	/**
	 * Busca os canais de distribuição juntamente com o seus filhos
	 *
	 */
	 public List<CanalDistribuicao__c> buscarCanalDistribuicaoComFilhos(Set<Id> canalDistribuicaoIds){
		return dao.buscarCanalDistribuicaoComFilhos(canalDistribuicaoIds);
	}
}