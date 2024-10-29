/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Contratante Factory Class
 */
@isTest
public class ContratanteFactory extends SObjectFactory{
	
    private static ContratanteContrato__c staticRecord;
    
    private static ContratanteContrato__c getRecordStatic(Contract contrato){
        
		if(staticRecord == null){
			staticRecord = new ContratanteContrato__c(
				Contrato__c = contrato.Id,
                TipoResponsavelPagamento__c = 'SEG'
            );
		}
		return staticRecord;
	}
    
    public ContratanteFactory() {

		this(
        	(Contract) new ContratoFactory.ContratoFactorySemParam().createRecord()
        );
	}

	public ContratanteFactory(Contract contrato) {

		super(getRecordStatic(contrato));
	}
}