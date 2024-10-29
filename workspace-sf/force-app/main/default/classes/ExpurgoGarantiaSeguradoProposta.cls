/**
 * Expurgo de dados para o Proposta
 *  objeto: GarantiaSeguradoProposta__c
 * caminho do objeto:
 *  GarantiaSeguradoProposta__c
 *  > SeguradoProposta__c
 *  > GrupoProposta__c
 *  > ContratanteProposta__c
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoGarantiaSeguradoProposta {

    public List<GarantiaSeguradoProposta__c> getDadosExpurgo(Integer qt) { 
        List<GarantiaSeguradoProposta__c> expList= new List<GarantiaSeguradoProposta__c>();
        String query= 'SELECT Id '
            +'FROM GarantiaSeguradoProposta__c '
            +'WHERE SeguradoProposta__r.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiaSeguradoProposta__c> expList) {
        if (!Test.isRunningTest()) {
            delete (List<GarantiaSeguradoProposta__c>)expList;
        }
    }

}