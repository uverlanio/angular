/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelas captura dos eventos de trigger do objeto DependenteGarantia__c
 *
 **************************************************************************************************************************************************************************/
 public class DependenteGarantiaTriggerHandler extends TriggerHandler {
 	private DependenteGarantiaBO bo = DependenteGarantiaBO.getInstance();

	public override void beforeInsert() {
		bo.validarDependeteGarantiaProdutoComercial(trigger.new);
		bo.validarCriacaoDependentesGarantia(trigger.new);
	}

	public override void beforeUpdate() {
		bo.validarDependeteGarantiaProdutoComercial(trigger.new);
		bo.validarCriacaoDependentesGarantia(trigger.new);
	}

	public override void beforeDelete() {
		bo.validarDependeteGarantiaProdutoComercial(trigger.old);
	}

	public override void afterInsert() {
		bo.habilitarValidacaoRegrasProdutoComercial(trigger.new);
	}
}