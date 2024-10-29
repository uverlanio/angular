/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-06
 * @description DadosCorretor__c Factory Class
 */
@isTest 
public class DadosCorretorFactory extends SObjectFactory{
	private static DadosCorretor__c staticRecord;

	private static DadosCorretor__c getRecordStatic(Account conta){

		if(staticRecord == null){
			staticRecord = new DadosCorretor__c(
				Name = '001',
            	NomeCorretor__c = conta.Id);
		}
		return staticRecord;
	}

	public DadosCorretorFactory(){

		this(
			(Account) new AccountFactory.PessoaJuridica().createRecord()
		);
	}

	public DadosCorretorFactory(Account conta) {

		super(getRecordStatic(conta));
	}
}