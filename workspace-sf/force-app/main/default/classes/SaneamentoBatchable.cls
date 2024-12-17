global class SaneamentoBatchable implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // SOQL para selecionar registros mais antigos que 30 dias
        return Database.getQueryLocator('SELECT Id FROM ObjectName WHERE CreatedDate < LAST_N_DAYS:30');
        // List<RemuneracaoOrcamento__c> oldRecords = [SELECT Id, Name FROM RemuneracaoOrcamento__c WHERE CreatedDate <= :Date.today().addDays(-30)];
    }

    global void execute(Database.BatchableContext context, List<SObject> scope) {
        // Removendo registros
        delete scope;
    }

    global void finish(Database.BatchableContext context) {
        // Logs ou notificações opcionais
        System.debug('Batch Apex concluded successfully.');
    }
}