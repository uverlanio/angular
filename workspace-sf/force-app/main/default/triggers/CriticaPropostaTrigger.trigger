//PLV-4179 - INICIO
//PLV-4449-VI - INICIO
trigger CriticaPropostaTrigger on CriticaProposta__c (before update, before insert, after update, after insert) {
//PLV-4449-VI - FIM
    new CriticaPropostaTriggerHandler().run();
}
//PLV-4179 - FIM