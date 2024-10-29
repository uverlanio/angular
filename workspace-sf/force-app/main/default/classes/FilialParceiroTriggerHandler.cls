public with sharing class FilialParceiroTriggerHandler extends TriggerHandler{
	public override void beforeInsert() {
		FilialParceiroBO.getInstance().impedirFilialDuplicada(Trigger.new);
	}
		
}