/**
 * Expurgo de dados para o Proposta
 *  objeto: DeclaracaoSaude__c 
 * caminho do objeto:
 *  > DeclaracaoSaude__c 
 *  > Proposta__c
 * 
 * 28/02/2024
 */

public with sharing class ExpurgoDeclaracaoSaude {
   
    public List<DeclaracaoSaude__c> getDadosExpurgo(Integer qt) { 
        List<DeclaracaoSaude__c> expList= new List<DeclaracaoSaude__c>();
        String query= 'SELECT Id '
            +'FROM DeclaracaoSaude__c '
            +'WHERE Proposta__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<DeclaracaoSaude__c> expList) {
        if (!Test.isRunningTest()) {
           delete (List<DeclaracaoSaude__c>)expList;
        }
    }
}