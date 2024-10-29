/**
 * Camada de abstração de dados do objeto RamoGarantia__c
 * @author Fernando Barcellos
 *
 **/
public class RamoGarantiaDAO {
	private static RamoGarantiaDAO classInstance;

	static {
		classInstance = new RamoGarantiaDAO();
	}

	private RamoGarantiaDAO() {
		
	}

	public static RamoGarantiaDAO getInstance() {
		return classInstance;
	}

	public List<RamoGarantia__c> buscarRamosGarantiaPorGarantiasRamosSeguro(Set<Id> idsGarantias, Set<Id> idsRamoSeguro) {
		return [
			SELECT
				Id,
				Name,
				Garantia__c,
				RamoSeguro__c,
				RamoSeguro__r.Name,
				NomeRamo__c
			FROM
				RamoGarantia__c
			WHERE
				Garantia__c IN : idsGarantias
				AND RamoSeguro__c IN : idsRamoSeguro
		];
	}

	/*
	public List<RamoGarantia__c> buscarRamosGarantiaPorId(Set<Id> idsRamosGarantia) {
		return [
			SELECT
				Id,
				Name,
				RamoSeguro__c,
				RamoSeguro__r.Name
			FROM
				RamoGarantia__c
			WHERE
				Id IN : idsRamosGarantia
		];
	}
	*/
}