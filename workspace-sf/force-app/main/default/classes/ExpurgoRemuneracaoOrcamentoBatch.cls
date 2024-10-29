/**
 * Expurgo de dados
 * 
 * Description: excluir dados obsoletos da base para evitar 'inchaço'
 */
public with sharing class ExpurgoRemuneracaoOrcamentoBatch implements Database.Batchable<RemuneracaoOrcamento__c> {
    public static ExpurgoRemuneracaoOrcamento obj= new ExpurgoRemuneracaoOrcamento();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<RemuneracaoOrcamento__c> start(Database.BatchableContext bc) {
        List<RemuneracaoOrcamento__c> expList= new List<RemuneracaoOrcamento__c>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de RemuneracaoOrcamento__c '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<RemuneracaoOrcamento__c> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de RemuneracaoOrcamento__c '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}