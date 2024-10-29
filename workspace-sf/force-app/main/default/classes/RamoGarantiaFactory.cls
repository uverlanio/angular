/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-06
 * @description RamoSeguro__c Factory Class
 */
@isTest
public class RamoGarantiaFactory extends SObjectFactory{
	private static RamoGarantia__c staticRecord;

	private static RamoGarantia__c getRecordStatic(Garantia__c garantia, RamoSeguro__c ramoSegurado){

		if(staticRecord == null){
			staticRecord = new RamoGarantia__c(
				Garantia__c = garantia.Id,
                RamoSeguro__c = ramoSegurado.Id);
		}
		return staticRecord;
	}

	public RamoGarantiaFactory(){

		this(
			(Garantia__c) new GarantiaFactory().createRecord(),
			(RamoSeguro__c) new RamoSeguroFactory().createRecord()
		);
	}

	public RamoGarantiaFactory(Garantia__c garantia, RamoSeguro__c ramoSegurado) {

		super(getRecordStatic(garantia, ramoSegurado));
	}
}