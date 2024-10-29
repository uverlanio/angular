public with sharing class ExpurgoRemuneracaoPropostaBatch implements Database.Batchable<RemuneracaoProposta__c> {
    public static ExpurgoRemuneracaoProposta obj= new ExpurgoRemuneracaoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<RemuneracaoProposta__c> start(Database.BatchableContext bc) {
        List<RemuneracaoProposta__c> expList= new List<RemuneracaoProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de RemuneracaoProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<RemuneracaoProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de RemuneracaoProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}