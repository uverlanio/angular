public with sharing class ExpurgoOpportunityHistoryBatch implements Database.Batchable<OpportunityHistory> {
    public static ExpurgoOpportunityHistory obj= new ExpurgoOpportunityHistory();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<OpportunityHistory> start(Database.BatchableContext bc) {
        List<OpportunityHistory> expList= new List<OpportunityHistory>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de OpportunityHistory '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<OpportunityHistory> expList) {
        try {
            // obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de OpportunityHistory '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}