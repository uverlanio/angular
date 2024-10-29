public class RiscoGarantiaTriggerHandler extends TriggerHandler {
	private static final RiscoBO bo = RiscoBO.getInstance();

	public override void afterInsert() {
		bo.ativarCapitalRiscoGarantiaProduto(trigger.new);
	}

	public override void afterDelete() {
		bo.desativarCapitalRiscoGarantiaProduto(trigger.new, (Map<Id, RiscoGarantia__c>)trigger.oldMap);
	}

	public override void beforeUpdate() {
		bo.validarPermissaoEdicaoExclusaoItemProdutoComercial(trigger.new);
	}

	public override void beforeDelete() {
		bo.validarPermissaoEdicaoExclusaoItemProdutoComercial(trigger.old);
	}
}