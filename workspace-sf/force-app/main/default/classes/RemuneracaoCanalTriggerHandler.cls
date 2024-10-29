/**
 * TriggerHandler RemuneracaoCanal__c
 *
 **/
public class RemuneracaoCanalTriggerHandler extends TriggerHandler {
	private RemuneracaoCanalBO bo = RemuneracaoCanalBO.getInstance();

	public override void beforeUpdate() {
		bo.validarTipoRemuneracao(trigger.new);
		bo.validarParcelasAgenciamento(trigger.new);
		bo.validarLimites(trigger.new);
		bo.validarMeioComercializacao(trigger.new);
	}

	public override void beforeInsert() {
		bo.validarTipoRemuneracao(trigger.new);
		bo.validarParcelasAgenciamento(trigger.new);
		bo.validarLimites(trigger.new);
		bo.validarMeioComercializacao(trigger.new);
	}

	public override void beforeDelete() {
		// Validar se Remuneração do canal pode ser removida
		bo.validarRemuneracaoObrigatoria((Map<Id, RemuneracaoCanal__c>)trigger.oldMap);
	}
}