/**
 * Expurgo de dados para o Proposta
 *  objeto: FavorecidoRemuneracaoProposta__c  
 * caminho do objeto:
 *  > FavorecidoRemuneracaoProposta__c  
 *  > RemuneracaoProposta__c
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoFavorecidoRemuneracaoProposta {

    public List<FavorecidoRemuneracaoProposta__c> getDadosExpurgo(Integer qt) { 
        List<FavorecidoRemuneracaoProposta__c> expList= new List<FavorecidoRemuneracaoProposta__c>();
        String query= 'SELECT Id '
            +'FROM FavorecidoRemuneracaoProposta__c '
            +'WHERE RemuneracaoProposta__r.Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<FavorecidoRemuneracaoProposta__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<FavorecidoRemuneracaoProposta__c>)expList;
        }
    }
}