/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-19
 * @description FormaPagamento__c Factory Class
 */
@isTest
public class FormaPagamentoFactory extends SObjectFactory{
	private static FormaPagamento__c staticRecord;

	private static FormaPagamento__c getRecordStatic(){

		if(staticRecord == null){
			staticRecord = new FormaPagamento__c(
				Codigo__c = '1234',
                Name = '3X');
		}
		return staticRecord;
	}

	public FormaPagamentoFactory() {

		super(getRecordStatic());
	}
}