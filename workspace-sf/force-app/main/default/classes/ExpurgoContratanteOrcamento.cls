/**
 * Expurgo de dados para o Orçamento
 *  objeto: ContratanteOrcamento__c
 * caminho do objeto:
 *  ContratanteOrcamento__c
 *  > Opportunity
 * 
 * 17/02/2024
 */
public with sharing class ExpurgoContratanteOrcamento { 
 
    public List<ContratanteOrcamento__c> getDadosExpurgo(Integer qt) {
        List<ContratanteOrcamento__c> expList = new List<ContratanteOrcamento__c>(); 
        String query= 'SELECT Id '// , Name, PremioTotal__c, IsDeleted'
        +'FROM ContratanteOrcamento__c '
        +'WHERE Orcamento__r.Segmento__c = \'Massificados\' ';
    if (qt != 0) {
        query+= 'LIMIT :qt';
    }
    expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
    System.debug(expList);
    return expList;
    }

    public void deleteDadosExpurgo(List<ContratanteOrcamento__c> expList) {
        // só pode executar o delete qdo não for teste pois está rodando com SeeAllData = true
        if (!Test.isRunningTest()) {
            delete (List<ContratanteOrcamento__c>)expList;
        }
    }
}