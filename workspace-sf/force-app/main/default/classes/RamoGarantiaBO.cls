/**
 * Regras de Negócio do Objeto RamoGarantia__c
 * @author Fernando Barcellos
 *
 **/
public class RamoGarantiaBO {
	private static RamoGarantiaBO classInstance;

	static {
		classInstance = new RamoGarantiaBO();
	}

	private RamoGarantiaBO() {
		
	}

	public static RamoGarantiaBO getInstance() {
		return classInstance;
	}

	public List<RamoGarantia__c> buscarRamosGarantiaPorGarantiasRamosSeguro(Set<Id> idsGarantias, Set<Id> idsRamoSeguro) {
        List<RamoGarantia__c> ramoG = RamoGarantiaDAO.getInstance().buscarRamosGarantiaPorGarantiasRamosSeguro(idsGarantias, idsRamoSeguro);
        System.debug('ISA idsGarantias ' + idsGarantias);
        System.debug('Isa idsRamoSeguro ' + idsRamoSeguro);
        System.debug('ISA ramoG ' + ramoG);
		return ramoG;
	}

	/*
	public List<RamoGarantia__c> buscarRamosGarantiaPorId(Set<Id> idsRamosGarantia) {
		return RamoGarantiaDAO.getInstance().buscarRamosGarantiaPorId(idsRamosGarantia);
	}
	*/
}