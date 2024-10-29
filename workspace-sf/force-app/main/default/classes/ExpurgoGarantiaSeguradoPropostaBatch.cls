public with sharing class ExpurgoGarantiaSeguradoPropostaBatch implements Database.Batchable<GarantiaSeguradoProposta__c> {
    public static ExpurgoGarantiaSeguradoProposta obj= new ExpurgoGarantiaSeguradoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GarantiaSeguradoProposta__c> start(Database.BatchableContext bc) {
        List<GarantiaSeguradoProposta__c> expList= new List<GarantiaSeguradoProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GarantiaSeguradoProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GarantiaSeguradoProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GarantiaSeguradoProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}