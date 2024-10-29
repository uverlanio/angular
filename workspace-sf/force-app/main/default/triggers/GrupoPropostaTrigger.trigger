/**
 * Trigger Handler Grupo Proposta
 * @author Jeferson santana
 * Estória: AV-824
 **/
trigger GrupoPropostaTrigger on GrupoProposta__c (after insert, after update, before delete, before insert, before update) {
    new GrupoPropostaTriggerHandler().run();
}