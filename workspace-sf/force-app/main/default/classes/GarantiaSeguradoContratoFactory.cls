/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Garantia do Seegurado do Contrato Factory Class
 */

@isTest
public class GarantiaSeguradoContratoFactory extends SObjectFactory{
	private static GarantiaSeguradoContrato__c staticRecord;
    
    private static GarantiaSeguradoContrato__c getRecordStatic(SeguradoContrato__c segurado, Garantia__c garantia){
        
		if(staticRecord == null){
            //PLV-4559 - INICIO
			staticRecord = new GarantiaSeguradoContrato__c(
                SeguradoContrato__c = segurado.Id,
                Garantia__c = garantia.Id,
                Tipo_de_limite_de_utilizacao__c = 'Dia(s)', //PLV-5747 INICIO/FIM
                Limite_de_Uso__c = 900
            );
            //PLV-4559 -FIM
		}
		return staticRecord;
	}
    
    public GarantiaSeguradoContratoFactory() {

		this(
        	(SeguradoContrato__c) new SeguradoContratoFactory().createRecord(),
            (Garantia__c) new GarantiaFactory().createRecord()
        );
	}

	public GarantiaSeguradoContratoFactory(SeguradoContrato__c segurado, Garantia__c garantia) {

		super(getRecordStatic(segurado, garantia));
	}
}