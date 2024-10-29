/**
 * Expurgo de dados
 * Test: ExpurgoOrcamentoBatchTest
 * 
 * Description: excluir dados obsoletos da base para evitar 'inchaço'
 */
public with sharing class ExpurgoOrcamentoBatch implements Database.Batchable<Opportunity> {
    public static ExpurgoOrcamento obj= new ExpurgoOrcamento();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<Opportunity> start(Database.BatchableContext bc) {
        List<Opportunity> expList= new List<Opportunity>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de Opportunity '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> expList) {
        try {
            obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de Opportunity '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}