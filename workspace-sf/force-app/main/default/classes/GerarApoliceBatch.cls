//PLV-5387 INICIO
global class GerarApoliceBatch implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator([SELECT Id, Name FROM Contract WHERE Segmento__c = 'Viagem' AND ApolicePdfDownloadUrl__c = NULL AND Status='Emitido'AND Tipo__c != 'Endosso' AND Tipo__c != 'Cancelamento' LIMIT 50]); //PLV-5387 FIX 1 - Início/Fim 
    }

    global void execute(Database.BatchableContext bc, List<SObject> contratos){
        Set<Id> setIdsContrato = new Set<Id>();

        if(contratos != null){
            for(SObject queryResult : contratos){
                Contract contrato = (Contract)queryResult;

                setIdsContrato.add(contrato.Id);
                System.debug(contrato.Id);
            }
        }
        
        // List<ContentDocumentLink> listPDF = [SELECT ContentDocumentId, Id FROM ContentDocumentLink WHERE LinkedEntityId = :setIdsContrato];

        GerarApolicePDF.criarApoliceAsync(setIdsContrato); // PLV-5387 INICIO/FIM - FIX 01
    }

    global void finish(Database.BatchableContext bc){}

    global void execute(SchedulableContext ctx){
        Database.executeBatch(this, 50);  //PLV-5387 FIX 1 - Início/Fim
    }
}
//PLV-5387 FIM