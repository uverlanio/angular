/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-19
 * @description Garantia__c Factory Class
 */
@isTest 
public class GarantiaFactory extends SObjectFactory {

	private static Garantia__c staticRecord;

	private static Garantia__c getRecordStatic(){

		if(staticRecord == null){
			staticRecord = new Garantia__c(
				Name = 'TestGarantia',
				Status__c = 'Ativo',
				Sigla__c = 'ABC',
				Tipo__c = 'Cobertura',
				VigenciaInicial__c = System.today(),
				TipoEvento__c = 'Morte');
		}
		return staticRecord;
	}

public GarantiaFactory() {

	super(getRecordStatic());
}

}