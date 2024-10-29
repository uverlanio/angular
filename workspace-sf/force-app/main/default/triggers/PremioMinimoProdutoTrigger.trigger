trigger PremioMinimoProdutoTrigger on PremioMinimoProduto__c (before insert, after insert, before update) {
	new PremioMinimoProdutoHandler().run();
}