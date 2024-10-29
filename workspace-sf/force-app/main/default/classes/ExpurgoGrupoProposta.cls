/**
 * Expurgo de dados para o Proposta
 *  objeto: GrupoProposta__c
 * caminho do objeto:
 *  > GrupoProposta__c
 *  > ContratanteProposta__c
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoGrupoProposta {

    public List<GrupoProposta__c> getDadosExpurgo(Integer qt) { 
        List<GrupoProposta__c> expList= new List<GrupoProposta__c>();
        String query= 'SELECT Id '
            +'FROM GrupoProposta__c '
            +'WHERE ContratanteProposta__r.Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GrupoProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<GrupoProposta__c >)expList;
        }
    }
}