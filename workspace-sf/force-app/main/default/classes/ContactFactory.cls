/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-19
 * @description Contact Factory Class
 */
 @isTest
public class ContactFactory extends SObjectFactory{
	private static Contact staticRecord;

	private static Contact getRecordStatic(Account conta){
		Date dataContato = Date.newInstance(1999, 11, 28);

		if(staticRecord == null){
			staticRecord = new Contact(
        	FirstName = 'TestFirstNameContato',
        	LastName = 'TestLastNameContato',
        	AccountId = conta.Id,
        	PEP__c = 'Não',
        	CPF__c = '427.709.828-26',
        	Birthdate = dataContato);
		}
		return staticRecord;
	}

	public ContactFactory(){

		this(
			(Account) new AccountFactory.PessoaJuridica().createRecord()
		);
	}

	public ContactFactory(Account conta) {

		super(getRecordStatic(conta));
	}

}