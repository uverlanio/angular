/**
 * Camada de abstração de dados do objeto Profissao__c
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
public class ProfissaoDAO {
	private static ProfissaoDAO classInstance;

	static {
		classInstance = new ProfissaoDAO();
	}

	private ProfissaoDAO() { }

	public static ProfissaoDAO getInstance() {
		return classInstance;
	}

	public List<Profissao__c> buscarProfissoesPorStatus(String status) {
		return buscarProfissoesPorStatus(new Set<String>{ status });
	}

	public List<Profissao__c> buscarProfissoesPorStatus(Set<String> setStatus) {
		return [
			SELECT
				Id,
				Name,
				Codigo__c,
				Status__c
			FROM 
				Profissao__c
			WHERE
				Status__c IN : setStatus
		];
	}

	public List<Profissao__c> buscarProfisoesAtivasPorCodigo(Set<String> codigos) {
		return [
			SELECT 
				Id,
				Name,
				Codigo__c,
				Status__c
			FROM
				Profissao__c
			WHERE
				Status__c =: 'Ativo'
				AND Codigo__c IN : codigos
		];
	}

	//INICIO | PLV-1586-29-v1
	public List<Profissao__c> buscarProfissoesTodas() {
		return [
			SELECT 
				Id,
				Name,
				Codigo__c,
				Status__c
			FROM
				Profissao__c
		];
	}
	//FIM | PLV-1586-29-v1

	//PLV-2495 - INICIO
	public List<Profissao__c> buscarProfissoesNaoExistentesNoWS(Set<String> IdsExterno) {
		return [
			SELECT 
				Id,
				Name,
				Codigo__c,
				Status__c
			FROM
				Profissao__c
			WHERE
				IdExterno__c NOT IN :IdsExterno
		];
	}
	//PLV-2495 - FINAL

}