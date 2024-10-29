public class AssociacaoRamoGarantiaProdutoController {
	
	/**
	* Realiza a busca dos ramos de uma garantia
	*
	* @param garantiaId - id da garantia 
	*/
    @AuraEnabled
    public static String buscarRamosSeguro(Id garantiaId){
     	return JSON.serialize(gerarListaRamosSeguro(garantiaId));
    }

	/**
	* Gera lista de CustomPickListOptionTO com os valores dos estados
	*
	* @return List<CustomPickListOptionTO> - Lista contendo os estados
	*/
    private static List<CustomPickListOptionTO> gerarListaRamosSeguro(Id garantiaId){
    	List<CustomPickListOptionTO> ramosSeguro = new List<CustomPickListOptionTO>();

    	for(RamoGarantia__c ramo : RamoSeguroBO.getInstance().buscarRamosSeguro(garantiaId)){
    		ramosSeguro.add(new CustomPickListOptionTO(ramo.RamoSeguro__r.Name, ramo.RamoSeguro__c));
    	}

        return ramosSeguro;
    }
}