/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelas captura dos eventos de trigger do objeto ParametroRenovacao__c
 *
 **************************************************************************************************************************************************************************/
 public class ParametroRenovacaoTriggerHandler extends TriggerHandler {
 	private ParametroRenovacaoBO bo = ParametroRenovacaoBO.getInstance();

	public override void beforeInsert() {
		bo.vincularTipoRegistroComercial(trigger.new);
		bo.validarParametroRenovacalProdutoComercial(trigger.new);
	}

	public override void beforeUpdate() {
		//bo.validarParametroRenovacalProdutoComercial(trigger.new);
	}

	public override void beforeDelete() {
		bo.validarParametroRenovacalProdutoComercial(trigger.old);
	}

	public override void afterInsert() {
		bo.habilitarValidacaoRegrasProdutoComercial(trigger.new);
	}
}