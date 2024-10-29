/**
 * @author AVX - Daniel Zampieri
 * @date 2019-03-08
 * @description ControleIntegracao__c Factory Class
 */
@isTest 
public class ControleIntegracaoFactory extends SObjectFactory{
	private static ControleIntegracao__c staticRecord;

	private static ControleIntegracao__c getRecordStatic(String codigoIntegracao){

		if(staticRecord == null){
			staticRecord = new ControleIntegracao__c(
				CodigoIntegracao__c = codigoIntegracao
				);
		}
		return staticRecord;
	}


	public ControleIntegracaoFactory(){

		this(
			'69'
		);
	}


public ControleIntegracaoFactory(String codigoIntegracao) {

	super(getRecordStatic(codigoIntegracao));
}
}