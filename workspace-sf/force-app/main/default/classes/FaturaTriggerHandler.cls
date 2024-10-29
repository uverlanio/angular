public class FaturaTriggerHandler extends TriggerHandler {
	private static FaturaBO objBO = FaturaBO.getInstance();

	public override void beforeUpdate() {
		objbo.atualizarFaturasPagasHeroku(trigger.new, (Map<Id, Fatura__c>)trigger.oldMap);
	}

	public override void beforeInsert() {
		objbo.atualizarFaturasPagasHeroku(trigger.new, (Map<Id, Fatura__c>)trigger.oldMap);
	}

	public override void afterUpdate(){
		objbo.gerarControleIntegracao(trigger.new, (Map<Id, Fatura__c>)trigger.oldMap);
	}
}