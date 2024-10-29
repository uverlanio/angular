/**
 * InformacaoBancariaTrigger
 * @author Fernando Barcellos @ 06/02/2018
 *
 **/
trigger InformacaoBancariaTrigger on InformacaoBancaria__c (before insert, before update, after insert, after update) {
	new InformacaoBancariaTriggerHandler().run();
}