/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pelo controle de execução de triggers do objeto de RemuneracaoOrcamento__c
 *
 **************************************************************************************************************************************************************************/
public class RemuneracaoOrcamentoTriggerHandler extends TriggerHandler {
	private static RemuneracaoOrcamentoBO objBO = RemuneracaoOrcamentoBO.getInstance();

	public override void beforeInsert() {
		//objBO.validarDadosEmProdutoCanal(trigger.new); //PLV-4698 INICIO/FIM
	}

	public override void beforeUpdate() {
		//objBO.validarDadosEmProdutoCanal(trigger.new); //PLV-4698 INICIO/FIM
	}

	public override void afterInsert() {
//		objBO.validarTipoRemuneracaoExistente(trigger.new);
        //objBO.validarPercentualCarregamento(trigger.new); //PLV-4698 INICIO/FIM
	}

	public override void afterUpdate() {
//		objBO.validarTipoRemuneracaoExistente(trigger.new);
        objBO.validarPercentualCarregamento(trigger.new);
	}
}