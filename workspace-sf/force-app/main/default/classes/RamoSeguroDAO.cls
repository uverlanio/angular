/**
 * Camada de abstração de dados do objeto RamoSeguro__c
 * @author Fernando Barcellos @ 09/11/2017
 *
 **/
public class RamoSeguroDAO {
	private static final RamoSeguroDAO instance = new RamoSeguroDAO();
	
	private RamoSeguroDAO() {
	}

	public static RamoSeguroDAO getInstance() {
		return instance;
	}	

	/**
	 * Realiza a listagem de todos os ramos
	 *
	 */
	public List<RamoSeguro__c> listarRamos() {
		return [
			SELECT
				Id,
				Name,
				Codigo__c,
				CodigoEmpresa__c,
				Empresa__c,
				Status__c
			FROM 
				RamoSeguro__c
		];
	}

	public RamoSeguro__c obterRamoPorCodigo(String codigo) 
	{
		return 
		[
			SELECT
				Id,
				Name,
				Codigo__c,
				CodigoEmpresa__c,
				Empresa__c,
				Status__c
			FROM 
				RamoSeguro__c
			WHERE 
				Codigo__c = : codigo
			LIMIT 1
		];
	}

	public List<RamoSeguro__c> buscarRamosPorStatus(String status) {
		return buscarRamosPorStatus(new Set<String>{ status });
	}

	public List<RamoSeguro__c> buscarRamosPorStatus(Set<String> setStatus) {
		return [
			SELECT
				Id,
				Name,
				Codigo__c,
				CodigoEmpresa__c,
				Empresa__c,
				Status__c
			FROM 
				RamoSeguro__c
			WHERE
				Status__c IN : setStatus
		];
	}

	public List<RamoSeguro__c> buscarRamosPorIds(Set<Id> ramoSeguroIds) {
		return [
			SELECT
				Id,
				Name,
				Codigo__c,
				CodigoEmpresa__c,
				Empresa__c,
				Status__c,
				(
					Select
						Id,
						Name
					FROM	
						Modalidades__r	
				)
			FROM 
				RamoSeguro__c
			WHERE
				Id IN : ramoSeguroIds
		];
	}

	public List<RamoGarantia__c> buscarRamosGarantiaPorGarantia(Id garantiaId) {
		return [
			SELECT
				Id,
				Name,
				RamoSeguro__c,
				RamoSeguro__r.Name
			FROM 
				RamoGarantia__c
			WHERE
				Garantia__c =: garantiaId
		];
	}

	public List<RamoSeguro__c> obterRamoPorCodigos(Set<String> setCodigos) 
	{
		return 
		[
			SELECT
				Id,
				Name,
				Codigo__c,
				CodigoEmpresa__c,
				Empresa__c,
				Status__c
			FROM 
				RamoSeguro__c
			WHERE 
				Codigo__c IN : setCodigos
		];
	}




}