/**
 * Camada de abstração de dados do objeto Garantia__c
 * @author Fernando Barcellos
 *
 **/
public class GarantiaDAO {
	private static GarantiaDAO classInstance;

	static {
		classInstance = new GarantiaDAO();
	}

	private GarantiaDAO() {
		
	}

	public static GarantiaDAO getInstance() {
		return classInstance;
	}

	public List<Garantia__c> buscarGarantiasPorId(Set<Id> idsGarantias, Set<Id> idsProdutos) {
		return [
			SELECT
				Id,
				Name,
				Sigla__c,            	
				(
					SELECT
						Id,
						Garantia__c,
						Garantia__r.Name,
						Produto__c,
						Produto__r.Name
					FROM
						GarantiasProduto__r
					WHERE
						Produto__c IN : idsProdutos
				)
			FROM
				Garantia__c
			WHERE
				Id IN : idsGarantias
		];
	}

	public List<Garantia__c> buscarGarantiasPorSigla(Set<String> siglas) {
		return [
			SELECT
				Id,
				Name,
				Sigla__c
			FROM
				Garantia__c
			WHERE
				Sigla__c IN : siglas
		];
	}

	//PLV2365: INICIO
	public List<Garantia__c> buscarGarantias() {
		return [
			SELECT
				Id,
				Name,
				Sigla__c
			FROM
				Garantia__c
		];
	}
	//PLV2365: FIM


}