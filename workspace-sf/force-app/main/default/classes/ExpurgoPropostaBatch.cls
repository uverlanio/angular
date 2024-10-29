public with sharing class ExpurgoPropostaBatch implements Database.Batchable<Quote> {
    public static ExpurgoProposta obj= new ExpurgoProposta();
    /**
     * Coleta os dados a serem excluídos
     * @param   Database.BatchableContext
     * @return  Map<String, List<Id>>
     */
    public List<Quote> start(Database.BatchableContext bc) {
        List<Quote> expList= new List<Quote>();
        
        try {
            expList= obj.getDadosExpurgo(0);
        } catch (Exception e) {
            System.assert(false, 'Erro buscando dados de Proposta '+e.getMessage());
        }

        return expList;
    }

    public void execute(Database.BatchableContext bc, List<Quote> expList) {
        try {
            // obj.deleteDadosExpurgo(expList);
        } catch (Exception e) {
            System.assert(false, 'Erro expurgando dados de Proposta '+e.getMessage());
        }
    }

    public void finish (Database.BatchableContext bc) {
        // finish method
    }
}