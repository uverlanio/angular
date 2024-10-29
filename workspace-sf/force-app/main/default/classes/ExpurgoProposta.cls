/**
 * Expurgo de dados para o Proposta
 *  objeto: Quote  
 * caminho do objeto:
 *  > Quote
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoProposta {
    public List<Quote> getDadosExpurgo(Integer qt) { 
        List<Quote> expList= new List<Quote>();
        String query = 'SELECT Id '
            +'FROM Quote '
            +'WHERE Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<Quote> expList) {
        if (!Test.isRunningTest()) {
           delete (List<Quote>)expList;
        }
    }
}