/**
 * Expurgo de dados para o Orçamento
 *  objeto: CriticaOrcamento__c
 * caminho do objeto:
 * CriticaOrcamento__c 
 *  > Opportunity
 * 
 * 20/02/2024
 */
public with sharing class ExpurgoCriticaOrcamento { // extends ExpurgoAbstract {
    
    public List<CriticaOrcamento__c> getDadosExpurgo(Integer qt) {
        List<CriticaOrcamento__c> expList = new List<CriticaOrcamento__c>();
        String query= 'SELECT Id '//', Name, IsDeleted'
            +'FROM CriticaOrcamento__c '
            +'WHERE Orcamento__r.Segmento__c = \'Massificados\' ';
    if (qt != 0) {
        query+= 'LIMIT :qt';
    }
    expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
    System.debug(expList);
    return expList;
    }

    public void deleteDadosExpurgo(List<CriticaOrcamento__c> expList) {
        if (!Test.isRunningTest()) {
          delete (List<CriticaOrcamento__c>)expList;
        }
    }
}