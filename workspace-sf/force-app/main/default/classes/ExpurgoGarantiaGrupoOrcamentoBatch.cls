/**
 * Expurgo de dados
 * 
 * Description: excluir dados obsoletos da base para evitar 'inchaço'
 */
public with sharing class ExpurgoGarantiaGrupoOrcamentoBatch implements Database.Batchable<GarantiaGrupoOrcamento__c> {
    public static ExpurgoGarantiaGrupoOrcamento obj= new ExpurgoGarantiaGrupoOrcamento();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GarantiaGrupoOrcamento__c> start(Database.BatchableContext bc) {
        List<GarantiaGrupoOrcamento__c> expList= new List<GarantiaGrupoOrcamento__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GarantiaGrupoOrcamento__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GarantiaGrupoOrcamento__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GarantiaGrupoOrcamento__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}