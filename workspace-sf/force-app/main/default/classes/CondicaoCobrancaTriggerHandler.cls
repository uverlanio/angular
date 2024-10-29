/**
 * CondicaoCobrancaTriggerHandler
 * @author Fernando Barcellos @ 11/01/2018
 *
 **/
public class CondicaoCobrancaTriggerHandler extends TriggerHandler {
	private static CondicaoCobrancaBO bo = CondicaoCobrancaBO.getInstance();

	public override void beforeInsert() {
		bo.verificarExistenciaDuplicidade(trigger.new, null);
	}

	public override void beforeUpdate() {
		bo.verificarExistenciaDuplicidade(trigger.new, (Map<Id, CondicaoCobranca__c>)trigger.oldMap);
	}
}