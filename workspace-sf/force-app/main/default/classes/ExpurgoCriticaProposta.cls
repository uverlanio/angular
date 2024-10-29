/**
 * Expurgo de dados para o Proposta
 *  objeto: CriticaProposta__c  
 * caminho do objeto:
 *  > CriticaProposta__c  
 *  > Proposta__c
 * 
 * 28/02/2024
 */


public with sharing class ExpurgoCriticaProposta {
    public List<CriticaProposta__c> getDadosExpurgo(Integer qt) { 
        List<CriticaProposta__c> expList= new List<CriticaProposta__c>();
        String query= 'SELECT Id '
            +'FROM CriticaProposta__c '
            +'WHERE Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<CriticaProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<CriticaProposta__c>)expList;
        }
    }
}