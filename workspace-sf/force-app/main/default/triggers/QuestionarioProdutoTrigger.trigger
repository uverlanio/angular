trigger QuestionarioProdutoTrigger on QuestionarioProduto__c (before insert, before update) {
	new QuestionarioProdutoTriggerHandler().run();
}