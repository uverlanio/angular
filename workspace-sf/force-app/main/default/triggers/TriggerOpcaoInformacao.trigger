/*********************************************************************************************************************************************************************
@description  Utilizada para dar apoio ao trigger.
@author Carlos Pessoa - META
@date 12/05/2021
@Classe criada por conta da história PLV-4946    
**********************************************************************************************************************************************************************/

trigger TriggerOpcaoInformacao on OpcaoInformacao__c (before insert, before update) {
    if(Trigger.isBefore && Trigger.isInsert || Trigger.isUpdate){
        TriggerOpcaoInformacaoHandler.validaDefault((List<OpcaoInformacao__c>) Trigger.new);
    }
}