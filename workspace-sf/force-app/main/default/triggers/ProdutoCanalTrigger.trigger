/**
 * Trigger ProdutoCanal__c
 * @author Fernando Barcellos @ 07/03/2018
 *
 **/
trigger ProdutoCanalTrigger on ProdutoCanal__c (after insert) {
	new ProdutoCanalTriggerHandler().run();
}