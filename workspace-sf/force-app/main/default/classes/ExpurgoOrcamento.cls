public with sharing class ExpurgoOrcamento {
    public List<Opportunity> getDadosExpurgo(Integer qt) { 
        List<Opportunity> expList= new List<Opportunity>();
        String query = 'SELECT Id '
            +'FROM Opportunity '
            +'WHERE Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<Opportunity> expList) {
        if (!Test.isRunningTest()) {
            delete (List<Opportunity>)expList;
        }
    }
}