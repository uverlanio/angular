/**
 * Trigger Handler GarantiaProduto__c
 * @author Fernando Barcellos @ 16/11/2017
 *
 **/
public class GarantiaProdutoTriggerHandler extends TriggerHandler {
	private static final GarantiaProdutoBO bo = GarantiaProdutoBO.getInstance();

	public override void beforeInsert() {
		//bo.validarExistenciaRiscoGarantia(trigger.new);
		
		bo.vincularTipoRegistroComercial(trigger.new);
		bo.verificarOrdemExibicaoGarantias(trigger.new, (Map<Id, GarantiaProduto__c>)trigger.oldMap);
		bo.vincularGarantiaProdutoTecnico(trigger.new);
		bo.validarTiposGarantiaProdutoComercial(trigger.new);
		bo.validarRamoSeguro(trigger.new);
		//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
		bo.validaMoedaLimiteCapital(trigger.new);
		//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
	}

	public override void beforeUpdate() {
		//bo.validarExistenciaRiscoGarantia(trigger.new);

		bo.verificarOrdemExibicaoGarantias(trigger.new, (Map<Id, GarantiaProduto__c>)trigger.oldMap);
		bo.vincularGarantiaProdutoTecnico(trigger.new);
		bo.validarTiposGarantiaProdutoComercial(trigger.new);
		bo.validarRamoSeguro(trigger.new);
		//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
		bo.validaMoedaLimiteCapital(trigger.new);
		//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
	}
}