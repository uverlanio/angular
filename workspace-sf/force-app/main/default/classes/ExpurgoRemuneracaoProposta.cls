/**
 * Expurgo de dados para o Proposta
 *  objeto: RemuneracaoProposta__c 
 * caminho do objeto:
 *  > RemuneracaoProposta__c 
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoRemuneracaoProposta {

    public List<RemuneracaoProposta__c> getDadosExpurgo(Integer qt) { 
        List<RemuneracaoProposta__c> expList= new List<RemuneracaoProposta__c>();
        String query= 'SELECT Id '
            +'FROM RemuneracaoProposta__c '
            +'WHERE Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<RemuneracaoProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<RemuneracaoProposta__c>)expList;
        }
    }
}