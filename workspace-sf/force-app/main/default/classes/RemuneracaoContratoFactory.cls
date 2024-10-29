/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-06
 * @description RemuneracaoContrato__c Factory Class
 */
@isTest
public class RemuneracaoContratoFactory extends SObjectFactory{
	private static RemuneracaoContrato__c staticRecord;

	private static RemuneracaoContrato__c getRecordStatic(TipoRemuneracao__c tipoRemuneracao, Contract contrato){

		if(staticRecord == null){
			staticRecord = new RemuneracaoContrato__c(
				Contrato__c = contrato.Id,
            	TipoRemuneracao__c = tipoRemuneracao.Id);
		}
		return staticRecord;
	}

	public RemuneracaoContratoFactory(){

		this(
			(TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord(),
			(Contract) new ContratoFactory.ContratoFactorySemParam().createRecord()
		);
	}

	public RemuneracaoContratoFactory(TipoRemuneracao__c tipoRemuneracao, Contract contrato) {

		super(getRecordStatic(tipoRemuneracao, contrato));
	}
}