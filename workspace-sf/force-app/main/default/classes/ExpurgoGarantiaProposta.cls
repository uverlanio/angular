/**
 * Expurgo de dados para o Proposta
 *  objeto: GarantiaProposta__c 
 * caminho do objeto:
 *  > GarantiaProposta__c 
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoGarantiaProposta {

    public List<GarantiaProposta__c> getDadosExpurgo(Integer qt) { 
        List<GarantiaProposta__c> expList= new List<GarantiaProposta__c>();
        String query= 'SELECT Id '
            +'FROM GarantiaProposta__c '
            +'WHERE Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiaProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<GarantiaProposta__c>)expList;
        }
    }
}