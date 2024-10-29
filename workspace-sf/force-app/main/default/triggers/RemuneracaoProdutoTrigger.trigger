trigger RemuneracaoProdutoTrigger on RemuneracaoProduto__c (before insert, before update) {
	new RemuneracaoProdutoTriggerHandler().run();
}