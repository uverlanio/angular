/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pela buscade dados do objeto de CanalDistribuicao__c
 *
 **************************************************************************************************************************************************************************/
public class CanalDistribuicaoDAO {
	private static final CanalDistribuicaoDAO instancia = new CanalDistribuicaoDAO();

	private CanalDistribuicaoDAO() {	
	}

	public static CanalDistribuicaoDAO getInstance(){
		return instancia;
	}

	public List<CanalDistribuicao__c> buscarCanalDistribuicaoComFilhos(Set<Id> canalDistribuicaoIds){
		return [
			Select 
				Id, 
				(Select 
					Id, 
					Produto__c 
				From 
					ProdutosCanal__r)
			From 
				CanalDistribuicao__c 
			Where 
				Id IN: canalDistribuicaoIds
		];
	}

	public CanalDistribuicao__c buscarCanalDistribuicaoOrcamentoPorSigla(String sigla) {
		return [
			SELECT
				Id,
				Name,
				Sigla__c
			FROM
				CanalDistribuicao__c
			WHERE
				Sigla__c =: sigla
			LIMIT 1
		];
	}
}