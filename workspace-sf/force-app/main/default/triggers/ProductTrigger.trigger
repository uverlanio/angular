trigger ProductTrigger on Product2 (before insert, before update, after update) {
	new ProductTriggerHandler().run();
}