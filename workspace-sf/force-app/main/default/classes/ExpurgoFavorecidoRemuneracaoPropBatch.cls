public with sharing class ExpurgoFavorecidoRemuneracaoPropBatch implements Database.Batchable<FavorecidoRemuneracaoProposta__c> {
    public static ExpurgoFavorecidoRemuneracaoProposta obj= new ExpurgoFavorecidoRemuneracaoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<FavorecidoRemuneracaoProposta__c> start(Database.BatchableContext bc) {
        List<FavorecidoRemuneracaoProposta__c> expList= new List<FavorecidoRemuneracaoProposta__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de FavorecidoRemuneracaoProposta__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<FavorecidoRemuneracaoProposta__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de FavorecidoRemuneracaoProposta__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}