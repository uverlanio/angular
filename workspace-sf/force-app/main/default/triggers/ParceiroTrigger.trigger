/**
 * Created by Alessandro Ponte on 02/11/2018.
 */

trigger ParceiroTrigger on Parceiro__c (after insert) {
    new ParceiroTriggerHandler().run();
}