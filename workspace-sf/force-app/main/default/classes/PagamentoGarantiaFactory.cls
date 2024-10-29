/**
 * @author AVX - Daniel Zampieri
 * @date 2019-02-19
 * @description PagamentoGarantia__c Factory Class
 */
@isTest
public class PagamentoGarantiaFactory extends SObjectFactory{
	private static PagamentoGarantia__c staticRecord;

	private static PagamentoGarantia__c getRecordStatic(Case caso, GarantiaSeguradoContrato__c garanSegCont){

		if(staticRecord == null){
			staticRecord = new PagamentoGarantia__c(
				Caso__c = caso.Id,
				Garantia_do_segurado_do_contrato__c = garanSegCont.Id,
				Name = 'TestPagamentoGarantia',
				// PLV-4002 - INICIO
				Capital__c = 100000.00, //PLV-4070 - INICIO/FIM
				Motivo_da_Recusa__c = '1',
				// PLV-4002 - FIM 
				Fase__c = 'Aberto',
				Valor_indenizado__c = 50				
			);
		}
		return staticRecord;
	}

	public PagamentoGarantiaFactory(){

		this(
			(Case) new CasoFactory.Sinistro().createRecord(),
			(GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory().createRecord()
		);
	}

	public PagamentoGarantiaFactory(Case caso, GarantiaSeguradoContrato__c garanSegCont) {

		super(getRecordStatic(caso, garanSegCont));
	}

}