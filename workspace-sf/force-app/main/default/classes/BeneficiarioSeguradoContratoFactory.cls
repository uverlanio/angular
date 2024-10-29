/**
 * @author AVX - Iskander Bittencourt
 * @date 2019-05-23
 * @description Beneficiario do Contrato do segurado Factory Class
 */
@isTest
public class BeneficiarioSeguradoContratoFactory extends SObjectFactory{
	private static BeneficiarioSeguradoContrato__c staticRecord;

    private static BeneficiarioSeguradoContrato__c getRecordBeneficiarioContrato(Account conta, SeguradoContrato__c segurado){
        if(staticRecord == null){
			staticRecord = new BeneficiarioSeguradoContrato__c(
                Conta__c = conta.Id,
                SeguradoContrato__c = segurado.Id,
                CpfCnpj__c = '000.000.000-11',
                Nome__c = 'Teste AVX'
            );
		}
		return staticRecord;
	}

    public BeneficiarioSeguradoContratoFactory() {
		this(
        	(Account) new AccountFactory.PessoaFisica().createRecord(),
            (SeguradoContrato__c) new SeguradoContratoFactory().createRecord()
        );
	}
    public BeneficiarioSeguradoContratoFactory(Account conta, SeguradoContrato__c segurado) {
		super(getRecordBeneficiarioContrato(conta, segurado));
	}
}