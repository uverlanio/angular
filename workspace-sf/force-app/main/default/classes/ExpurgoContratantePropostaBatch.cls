public with sharing class ExpurgoContratantePropostaBatch implements Database.Batchable<ContratanteProposta__c> {
    public static ExpurgoContratanteProposta obj= new ExpurgoContratanteProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<ContratanteProposta__c> start(Database.BatchableContext bc) {
        List<ContratanteProposta__c> expList= new List<ContratanteProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de ContratanteProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<ContratanteProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de ContratanteProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}