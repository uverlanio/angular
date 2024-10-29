/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description RamoAtividade__c Factory Class
 */
 @isTest
public class RamoAtividadeFactory extends SObjectFactory {

	private static RamoAtividade__c staticRecord;

	private static RamoAtividade__c getRecordStatic(){

		if(staticRecord == null){
			staticRecord = new RamoAtividade__c(
				Name = 'Alimentação');
		}
		return staticRecord;
	}

public RamoAtividadeFactory() {

	super(getRecordStatic());
}

}