/**
 * CanalCampanhaDAO
 * @author Fernando Barcellos @ 27/02/2018
 *
 **/
public class CanalCampanhaDAO {
	private static final CanalCampanhaDAO instancia = new CanalCampanhaDAO();

	private CanalCampanhaDAO() {	
	}

	public static CanalCampanhaDAO getInstance(){
		return instancia;
	}

	public List<CanalCampanha__c> buscarCanaisCampanhaPorId(Set<ID> setIds) {
		return [
			SELECT
				Id,
				Produto__c
			FROM
				CanalCampanha__c
			WHERE
				Id IN : setIds
		];
	}

}