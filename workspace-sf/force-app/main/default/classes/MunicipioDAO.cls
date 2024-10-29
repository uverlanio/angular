public class MunicipioDAO {

	private static final MunicipioDAO instance = new MunicipioDAO();

	public static MunicipioDAO getInstance() {
		return instance;
	}

	private MunicipioDAO(){}

	public List<Municipio__c> buscarMunicipiosPorEstados(Set<String> setEstados) {
		return [SELECT 
					Id, 
					Name,
					Uf__c
				FROM 
					Municipio__c 
				WHERE 
					Uf__c IN: setEstados
				Order By 
					Uf__c,
					Name
		];
	}
}