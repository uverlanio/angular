public with sharing class ExpurgoCriticaPropostaBatch implements Database.Batchable<CriticaProposta__c> {
    public static ExpurgoCriticaProposta obj= new ExpurgoCriticaProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<CriticaProposta__c> start(Database.BatchableContext bc) {
        List<CriticaProposta__c> expList= new List<CriticaProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de CriticaProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<CriticaProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de CriticaProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}