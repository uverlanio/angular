public with sharing class ExpurgoSeguradoPropostaBatch implements Database.Batchable<SeguradoProposta__c> {
    public static ExpurgoSeguradoProposta obj= new ExpurgoSeguradoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<SeguradoProposta__c> start(Database.BatchableContext bc) {
        List<SeguradoProposta__c> expList= new List<SeguradoProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de SeguradoProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<SeguradoProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de SeguradoProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}