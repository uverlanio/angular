/**
 * Camada de abstração de dados do objeto RamoAtividade__c
 * @author Fernando Barcellos @ 05/12/2017
 *
 **/
public with sharing class RamoAtividadeDAO {
    private static RamoAtividadeDAO classInstance;

    static {
        classInstance = new RamoAtividadeDAO();
    }

    private RamoAtividadeDAO() {
        
    }

    public static RamoAtividadeDAO getInstance() {
        return classInstance;
    }

    public List<RamoAtividade__c> buscarRamoAtividadePorStatus(String status) {
    	return buscarRamoAtividadePorStatus(new Set<String>{ status });
    }

    public List<RamoAtividade__c> buscarRamoAtividadePorStatus(Set<String> setStatus) {
    	return [
    		SELECT
    			Id,
    			Name,
    			Status__c
    		FROM 
    			RamoAtividade__c
    		WHERE
    			Status__c IN : setStatus
    	];
    }

}