/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Account Factory Class
 */

@isTest
public class AccountFactory{

	private static Map<String,Account> mStaticRecord = new Map<String,Account>();

// --------------------------------------Pessoa Física--------------------------------------------------

	private static Account getRecordPessoaFisica(){

		if(!mStaticRecord.containsKey('PessoaFisica')){
			Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica');
			Date datePersonBirthdate = Date.newInstance(1985, 02, 02);

			mStaticRecord.put('PessoaFisica', new Account(
				RecordtypeId = REC_ID_PERSONACCOUNT.Id,
				FirstName = 'TestFirstNamePessoaFisica',
				LastName = 'TestLastNamePessoaFisica',
				Cpf__c = '438.912.318-14',
                Pis__c = '123456789', // PLV-4445
				Pep__c = 'Não',
				Nacionalidade__c = 'Brasileira',
				Phone 					= '11 900000000', //MGRC-1253 - INICIO/FIM - ANNVI-55 - INICIO/FIM
				PersonMobilePhone 		= '11 900000000', // ANNVI-55 - INICIO/FIM
				PersonOtherPhone 		= '11 900000000', // ANNVI-55 - INICIO/FIM
				PersonAssistantPhone 	= '11 900000000', // ANNVI-55 - INICIO/FIM
				PersonHomePhone 		= '11 900000000', // ANNVI-55 - INICIO/FIM
				//TipoDocidentificacao__c = 'rg', //PLV5231 - INICIO/FIM
				PersonBirthdate = datePersonBirthdate)
			);
		}
		return mStaticRecord.get('PessoaFisica');
	}

public class PessoaFisica extends SObjectFactory {

	public PessoaFisica() {

		super(getRecordPessoaFisica());
		super.FIELD_INTERATOR = 'LastName';
	}
}

//---------------------------------------Pessoa Jurídica------------------------------------------------

	private static Account getRecordPessoaJuridica(RamoAtividade__c ramoAtividade){

		if(!mStaticRecord.containsKey('PessoaJuridica')){

			Recordtype REC_ID_ACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaJuridica');

			mStaticRecord.put('PessoaJuridica', new Account(
				RecordtypeId = REC_ID_ACCOUNT.Id,
				Name = 'TestNamePessoaJuridica',
				Cnpj__c = '31.838.851/0001-31',
                Inscricao_Municipal__c = '123456789', // PLV-4445
				TipoAdministracao__c = 'Privada',
				Phone = '(11) 90000-0000',	// ANNVI-55 - INICIO/FIM
				RamoAtividade__c = ramoAtividade.id)
			);
		}
		return mStaticRecord.get('PessoaJuridica');
	}

public class PessoaJuridica extends SObjectFactory {
	
	public PessoaJuridica() {

		this(
			(RamoAtividade__c) new RamoAtividadeFactory().createRecord()
		);
	}

	public PessoaJuridica(RamoAtividade__c pRamoAtividade) {

		super(getRecordPessoaJuridica(pRamoAtividade));
		super.FIELD_INTERATOR = 'Name';
	}
}

}