/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Grupo Factory Class
 */

@isTest
public class GrupoFactory extends SObjectFactory{
	private static GrupoContrato__c staticRecord;
    
    private static GrupoContrato__c getRecordStatic(ContratanteContrato__c contratante){
        
		if(staticRecord == null){
			staticRecord = new GrupoContrato__c(
				ContratanteContrato__c = contratante.Id,
                Name = 'TesteGrupoContrato'
            );
		}
		return staticRecord;
	}
    
    public GrupoFactory() {

		this(
        	(ContratanteContrato__c) new ContratanteFactory().createRecord()
        );
	}

	public GrupoFactory(ContratanteContrato__c contratante) {

		super(getRecordStatic(contratante));
	}
}