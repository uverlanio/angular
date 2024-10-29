/**
 * @author AVX - Daniel Zampieri
 * @date 2019-06-27
 * @description Carencia__c Factory Class
 */
@isTest
public class CarenciaFactory extends SObjectFactory{

	private static Carencia__c staticRecord;

	private static Carencia__c getRecordStatic(){

		if(staticRecord == null){
			staticRecord = new Carencia__c(
				Name = 'TesteCarencia',
				FormaCarencia__c = 'Simples',
				TipoPeriodo__c = 'Dia(s)',
				ValorBase__c = 'Capital'
				//PLV-4175-Início
				//InicioPeriodo__c = 1,
				//FimPeriodo__c = 10
				//PLV-4175-Fim
            );
		}
		return staticRecord;
	}

	public CarenciaFactory() {

		super(getRecordStatic());
	}

}