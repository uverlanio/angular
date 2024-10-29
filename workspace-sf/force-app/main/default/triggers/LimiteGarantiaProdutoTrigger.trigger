/**
 * @author AVX - Leonardo Camacho
 * @date 2019-12-27
 * @description: Trigger do objeto LimiteGarantiaProduto__c
 * Criada para a história PLV_3046
 */
trigger LimiteGarantiaProdutoTrigger on LimiteGarantiaProduto__c (before insert, before update) {
        new LimiteGarantiaProdutoTriggerHandler().run();
}