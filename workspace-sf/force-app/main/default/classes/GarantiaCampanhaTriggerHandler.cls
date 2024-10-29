/**
 * Trigger Handler GarantiaCampanha__c
 * @author Fernando Barcellos @ 19/02/2018
 *
 **/
public with sharing class GarantiaCampanhaTriggerHandler extends TriggerHandler {
	private static GarantiaBO bo = GarantiaBO.getInstance();

	public override void beforeInsert() {
		bo.validarGarantias(trigger.new);
	}

	public override void beforeUpdate() {
		bo.validarGarantias(trigger.new);
	}
}