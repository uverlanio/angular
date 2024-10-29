/**
 * Trigger Handler FormaPagamentoCampanha__c
 * @author Fernando Barcellos @ 25/02/2018
 *
 **/
public class FormaPagamentoCampanhaTriggerHandler extends TriggerHandler {
	private static FormaPagamentoCampanhaBO bo = FormaPagamentoCampanhaBO.getInstance();
	
	public override void beforeInsert() {
		bo.validarFormasPagamento(trigger.new);
	}

	public override void beforeUpdate() {
		bo.validarFormasPagamento(trigger.new);
	}
}