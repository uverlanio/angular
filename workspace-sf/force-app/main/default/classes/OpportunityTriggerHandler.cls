public class OpportunityTriggerHandler extends TriggerHandler {
	private static OpportunityBO bo = OpportunityBO.getInstance();

	public override void beforeInsert() {
		bo.vencimentoOrcamento(Trigger.new);
		bo.validarProdutoCanal(trigger.new);
	}

	public override void beforeUpdate() {
        bo.vencimentoOrcamento(Trigger.new);
        //PLV-4693 INICIO
        //bo.preencherRamoOrcamento(Trigger.new); //PLV-4498 - Inicio/Fim
        //PLV-4693 FIM

	}

	public override void afterUpdate() {
//		bo.replicarOportunidadeProposta(Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
		//bo.deleteLocalStorageDocument(Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap); //PLV-4393
	}
    
    //PLV-2589 INICIO
    public override void afterInsert() {
		bo.atualizarGerarNumeroOrcamento(Trigger.new);
	}
    //PLV-2589 FIM
}