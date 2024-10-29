public with sharing class ExpurgoGarantiaContratantePropostaBatch implements Database.Batchable<GarantiaContratanteProposta__c> {
    public static ExpurgoGarantiaContratanteProposta obj= new ExpurgoGarantiaContratanteProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GarantiaContratanteProposta__c> start(Database.BatchableContext bc) {
        List<GarantiaContratanteProposta__c> expList= new List<GarantiaContratanteProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GarantiaContratanteProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GarantiaContratanteProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GarantiaContratanteProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}