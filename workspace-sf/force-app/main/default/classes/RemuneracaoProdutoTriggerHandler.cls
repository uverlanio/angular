public class RemuneracaoProdutoTriggerHandler extends TriggerHandler {
	private static final RemuneracaoProdutoBO bo = RemuneracaoProdutoBO.getInstance();

	public override void beforeInsert() {
		bo.validarTiposRemuneracaoExistentes(trigger.new);
		bo.validarTiposRemuneracaoProdutoComercial(trigger.new);
	}

	public override void beforeUpdate() {
		bo.validarTiposRemuneracaoExistentes(trigger.new);
		bo.validarTiposRemuneracaoProdutoComercial(trigger.new);
	}
}