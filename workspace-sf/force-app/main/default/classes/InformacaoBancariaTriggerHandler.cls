/**
 * InformacaoBancariaTriggerHandler
 * @author Fernando Barcellos @ 06/02/2018
 * @modified GFS @ 21/01/2019
 **/
public class InformacaoBancariaTriggerHandler extends TriggerHandler {
	private InformacaoBancariaBO bo = InformacaoBancariaBO.getInstance();
    public static Boolean isFirstTime = true; 

	// 2666 - INICIO
	public override void beforeInsert() {
		bo.setDefaultValues(trigger.new);
		//bo.verificarDuplicidade(trigger.new);
		bo.preencherNomenclaturaInformacaoBancaria(trigger.new);
	}

	public override void beforeUpdate() {
		bo.setDefaultValues(trigger.new);
		bo.preencherNomenclaturaInformacaoBancaria(trigger.new);
        bo.MudaStatusIntegracao(trigger.new, (Map<Id,InformacaoBancaria__c>)trigger.oldMap);
		//bo.verificarDuplicidade(trigger.new);    
	}

	// 2666 - FIM
}