/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-27
 * @description Informação Bancária Factory Class
 */
 @isTest
public class InformacaoBancariaFactory{

	private static Map<String,InformacaoBancaria__c> mStaticRecord = new Map<String,InformacaoBancaria__c>();

//-----------------------------Info Bancaria Pessoa Física------------------------------------------

	private static InformacaoBancaria__c getRecordInfoPessoaFisica(Account contaFisica){
		//PLV-4363 - INICIO
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '246';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'A B C ROMA S/A';
        banconew.Ativo__c = true;
        insert banconew; 
        //PLV-4363 - FIM
		if(!mStaticRecord.containsKey('InfoPessoaFisica')){
			
			mStaticRecord.put('InfoPessoaFisica', new InformacaoBancaria__c(
				Banco__c = '246',
				Agencia__c = '3758',
				NumeroConta__c = '35958',
                //PLV-3918 -FIX6 - INICIO
                //PLV-3918 -FIX7 - INICIO
				Digito__c = '6',
                //PLV-3918 -FIX7 - FIM
                //PLV-3918 -FIX6 - FIM
				StatusIntegracao__c = 'Validada',
				BancoNew__c = banconew.Id, //PLV-4363 -INICIO/FIM
				Conta__c = contaFisica.Id)
			);
		}
		return mStaticRecord.get('InfoPessoaFisica');
	}

public class InfoPessoaFisica extends SObjectFactory {

	public InfoPessoaFisica() {

		this(
			(Account) new AccountFactory.PessoaFisica().createRecord()
		);
	}

	public InfoPessoaFisica(Account contaFisica){

		super(getRecordInfoPessoaFisica(contaFisica));
	}

}

//------------------------------Info Bancaria Pessoa Jurídica----------------------------------------

	private static InformacaoBancaria__c getRecordInfoPessoaJuridica(Account contaJuridica){
		//PLV-4363 - INICIO
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '246';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'A B C ROMA S/A';
        banconew.Ativo__c = true;
        insert banconew; 
        //PLV-4363 - FIM
		if(!mStaticRecord.containsKey('InfoPessoaJuridica')){

			mStaticRecord.put('InfoPessoaJuridica', new InformacaoBancaria__c(
				Banco__c = '246',
				Agencia__c = '2028',
				NumeroConta__c = '522100',
                //PLV-3918 -FIX6 - INICIO
                //PLV-3918 -FIX7 - INICIO
				Digito__c = '5',
                //PLV-3918 -FIX7 - FIM
                //PLV-3918 -FIX6 - FIM
				StatusIntegracao__c = 'Validada',
				BancoNew__c = banconew.Id, //PLV-4363 -INICIO/FIM
				Conta__c = contaJuridica.Id)
			);
		}
		return mStaticRecord.get('InfoPessoaJuridica');
	}

public class InfoPessoaJuridica extends SObjectFactory {
	
	public InfoPessoaJuridica() {

		this(
			(Account) new AccountFactory.PessoaJuridica().createRecord()
		);
	}

	public InfoPessoaJuridica(Account contaJuridica) {

		super(getRecordInfoPessoaJuridica(contaJuridica));
	}
}

}