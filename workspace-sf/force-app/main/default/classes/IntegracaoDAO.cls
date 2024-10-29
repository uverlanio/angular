/**
 * IntegracaoDAO
 * @author Fernando Barcellos @ 01/12/2017
 *
 **/
public class IntegracaoDAO {
	
	private static final IntegracaoDAO instance = new IntegracaoDAO();
	
	public static IntegracaoDAO getInstance() {
		return instance;
	}

	private IntegracaoDAO() { }

	public Integracao__c buscarIntegracaoPorId(Id idIntegracao) {
		return [
			SELECT
				Id,
				Name,
				DeveloperName__c,
				UltimaExecucao__c
			FROM
				Integracao__c
			WHERE
				Id =: idIntegracao
			LIMIT 1
		];
	}

	public Integracao__c buscarIntegracaoPorNomeObjeto(String nomeObjeto) {
		return [
			SELECT
				Id,
				Name,
				DeveloperName__c,
				UltimaExecucao__c
			FROM
				Integracao__c
			WHERE
				DeveloperName__c =: nomeObjeto
			LIMIT 1
		];
	}
}