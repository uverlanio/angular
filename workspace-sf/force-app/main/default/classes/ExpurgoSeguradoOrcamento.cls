/**
 * Expurgo de dados para o Orçamento
 *  objeto: SeguradoOrcamento__c
 * caminho do objeto:
 * SeguradoOrcamento__c 
 *  > GrupoOrcamento__c
 *  > ContratanteOrcamento__c
 *  > Opportunity
 * 
 * 20/02/2024
 */
public with sharing class ExpurgoSeguradoOrcamento { 
  
    public List<SeguradoOrcamento__c> getDadosExpurgo(Integer qt) {
        List<SeguradoOrcamento__c> expList = new List<SeguradoOrcamento__c>(); 
        String query= 'SELECT Id '//', Name, PremioTotal__c, IsDeleted'
                      +'FROM SeguradoOrcamento__c '
                      +'WHERE GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.Segmento__c = \'Massificados\' ';
        if (qt != 0) {
            query+= 'LIMIT :qt';
        }
        expList= Database.queryWithBinds(query, new Map<String,Object>{'qt' => qt}, AccessLevel.SYSTEM_MODE);
        System.debug(expList);
        return expList;
    }

    public void deleteDadosExpurgo(List<SeguradoOrcamento__c> expList) {
        if (!Test.isRunningTest()) {
          delete (List<SeguradoOrcamento__c>)expList;
        }
    }

}