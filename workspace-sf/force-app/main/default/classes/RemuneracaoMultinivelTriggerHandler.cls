public class RemuneracaoMultinivelTriggerHandler extends TriggerHandler {
	private RemuneracaoMultinivelBO bo = RemuneracaoMultinivelBO.getInstance();

	public override void beforeUpdate() {
		bo.validarTipoRemuneracao(trigger.new);
	}

	public override void beforeInsert() {
		bo.validarTipoRemuneracao(trigger.new);
	}
}