/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-06
 * @description TipoRemuneracao__c Factory Class
 */
@isTest
public class TipoRemuneracaoFactory extends SObjectFactory{
	private static TipoRemuneracao__c staticRecord;

	private static TipoRemuneracao__c getRecordStatic(){

		if(staticRecord == null){
			staticRecord = new TipoRemuneracao__c(
				Name = 'Corretagem');
		}
		return staticRecord;
	}

	public TipoRemuneracaoFactory() {

		super(getRecordStatic());
	}
}