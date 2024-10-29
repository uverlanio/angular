/**
 * Trigger Handler ParametroVigencia__c
 * @author Fernando Barcellos @ 17/05/2018
 *
 **/
public class ParametroVigenciaTriggerHandler extends TriggerHandler {
	private static ParametroVigenciaBO bo = ParametroVigenciaBO.getInstance();

	public override void beforeInsert() {
		bo.validarParametros(trigger.new);
	}	

	public override void beforeUpdate() {
		bo.validarParametros(trigger.new);
	}	
}