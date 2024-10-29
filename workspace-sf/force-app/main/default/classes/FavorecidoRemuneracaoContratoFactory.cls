/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-06
 * @description FavorecidoRemuneracaoContrato__c Factory Class
 */
@isTest
public class FavorecidoRemuneracaoContratoFactory extends SObjectFactory{
	private static FavorecidoRemuneracaoContrato__c staticRecord;

	private static FavorecidoRemuneracaoContrato__c getRecordStatic(RemuneracaoContrato__c remCont, DadosCorretor__c dadosCorretor){

		if(staticRecord == null){
			staticRecord = new FavorecidoRemuneracaoContrato__c(
				DadosCorretor__c = dadosCorretor.Id,
            	RemuneracaoContrato__c = remCont.Id,
            	CorretorLider__c = true);
		}
		return staticRecord;
	}

	public FavorecidoRemuneracaoContratoFactory(){

		this(
			(RemuneracaoContrato__c) new RemuneracaoContratoFactory().createRecord(),
			(DadosCorretor__c) new DadosCorretorFactory().createRecord()
		);
	}

	public FavorecidoRemuneracaoContratoFactory(RemuneracaoContrato__c remCont, DadosCorretor__c dadosCorretor) {

		super(getRecordStatic(remCont, dadosCorretor));
	}
}