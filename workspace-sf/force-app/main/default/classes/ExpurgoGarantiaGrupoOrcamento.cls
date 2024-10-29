/**
 * Expurgo de dados para o Orçamento
 *  objeto: GarantiaGrupoOrcamento__c
 * caminho do objeto:
 * GarantiaGrupoOrcamento__c 
 *  > GrupoOrcamento__c
 *  > ContratanteOrcamento__c
 *  > Opportunity
 * 
 * 20/02/2024
 */
public with sharing class ExpurgoGarantiaGrupoOrcamento { 

    public List<GarantiaGrupoOrcamento__c> getDadosExpurgo(Integer qt) {
        List<GarantiaGrupoOrcamento__c> expList = new List<GarantiaGrupoOrcamento__c>();  
        String query= 'SELECT Id '//', Name, PremioTotal__c, IsDeleted'
            +'FROM GarantiaGrupoOrcamento__c '
            +'WHERE GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.USER_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<GarantiaGrupoOrcamento__c> expList) {
        if (!Test.isRunningTest()) {  
           delete (List<GarantiaGrupoOrcamento__c>)expList;
        }
    }
}