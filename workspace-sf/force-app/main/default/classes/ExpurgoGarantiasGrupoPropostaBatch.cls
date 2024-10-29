public with sharing class ExpurgoGarantiasGrupoPropostaBatch implements Database.Batchable<GarantiasGrupoProposta__c> {
    public static ExpurgoGarantiasGrupoProposta obj= new ExpurgoGarantiasGrupoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GarantiasGrupoProposta__c> start(Database.BatchableContext bc) {
        List<GarantiasGrupoProposta__c> expList= new List<GarantiasGrupoProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GarantiasGrupoProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GarantiasGrupoProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GarantiasGrupoProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}