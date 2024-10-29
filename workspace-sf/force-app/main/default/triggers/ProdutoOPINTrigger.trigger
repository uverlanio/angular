//PLV-5230 - INICIO
/**
 * Trigger do objeto ProdutoOPIN__c
 * @author Julio Duarte @ 07/12/2021
 *
 **/
trigger ProdutoOPINTrigger on ProdutoOPIN__c (before insert, before update) {

    new ProdutoOPINTriggerHandler().run();

}
//PLV-5230 - FIM