/**
 * TriggerHandler CanalCampanha__c
 * @author Fernando Barcellos @ 18/01/2018
 *
 **/
public class CanalCampanhaTriggerHandler extends TriggerHandler {
	private static CanalCampanhaBO bo = CanalCampanhaBO.getInstance();

	public override void beforeInsert() {
		bo.validarProdutoCanalDistribuicao(trigger.new);
	}

	public override void beforeUpdate() {
		bo.validarProdutoCanalDistribuicao(trigger.new);
	}
}