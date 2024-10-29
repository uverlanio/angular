public with sharing class ExpurgoGrupoPropostaBatch implements Database.Batchable<GrupoProposta__c> {
    public static ExpurgoGrupoProposta obj= new ExpurgoGrupoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GrupoProposta__c> start(Database.BatchableContext bc) {
        List<GrupoProposta__c> expList= new List<GrupoProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GrupoProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GrupoProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GrupoProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}