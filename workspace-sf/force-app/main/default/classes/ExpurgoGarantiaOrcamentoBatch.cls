/**
 * Expurgo de dados
 * 
 * Description: excluir dados obsoletos da base para evitar 'inchaço'
 */
public with sharing class ExpurgoGarantiaOrcamentoBatch implements Database.Batchable<GarantiaOrcamento__c> {
    public static ExpurgoGarantiaOrcamento obj= new ExpurgoGarantiaOrcamento();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<GarantiaOrcamento__c> start(Database.BatchableContext bc) {
        List<GarantiaOrcamento__c> expList= new List<GarantiaOrcamento__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de GarantiaOrcamento__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<GarantiaOrcamento__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de GarantiaOrcamento__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}