/**
 * Trigger Handler ProdutoCanal__c
 * @author Fernando Barcellos @ 07/03/2018
 *
 **/
public class ProdutoCanalTriggerHandler extends TriggerHandler {
	private static ProdutoCanalBO bo = ProdutoCanalBO.getInstance();

	// trazer todas as remunerações de produto obrigatórias
	public override void afterInsert() {
		bo.gerarRemuneracaoObrigatoria((Map<Id, ProdutoCanal__c>)trigger.newMap);
	}
}