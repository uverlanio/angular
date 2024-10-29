public with sharing class ExpurgoOpportunityHistory {
    public ExpurgoOpportunityHistory() {

    }
    /**
     * Buscar dados
     */
    public List<OpportunityHistory> getDadosExpurgo(Integer qt) {
        List<OpportunityHistory> expList = new List<OpportunityHistory>(); 
        String query= 'SELECT Id '//', Name, PremioTotal__c, IsDeleted'
            +'FROM OpportunityHistory '
            +'WHERE Opportunity.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    // public void deleteDadosExpurgo(List<OpportunityHistory> expList) {
    //     if (!Test.isRunningTest()) {  
    //        delete (List<OpportunityHistory>)expList;
    //     }
    // }
}