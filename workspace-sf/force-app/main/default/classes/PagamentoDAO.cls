public with sharing class PagamentoDAO {
    private static final PagamentoDAO instancia = new PagamentoDAO();
    //INICIO | PLV-2233-27
    @TestVisible private static List<Pagamento__x> mockedPagamentos = new List<Pagamento__x>();
    //FIM | PLV-2233-27
    
    private PagamentoDAO(){}

    public static PagamentoDAO getInstance(){
        return instancia;
    }


    public List<Pagamento__x> buscarPagamentosPorIds(List<Id> setPagamentosIds) {

        //INICIO | PLV-2233-27
        if(Test.isRunningTest()) {
            return (mockedPagamentos.size() > 0) ? mockedPagamentos : null;
        }
        

        return [SELECT 
                    id, 
                    Status__c, 
                    DataProgramadaPagamento__c,
                    Descricao__c, 
                    ExternalId , 
                    Id__c, 
                    IdConta__c, 
                    IdConta__r.Cnpj__c, 
                    IdConta__r.Cpf__c, 
                    idObjeto__c, 
                    Matricula__c, 
                    TipoConta__c, 
                    TipoPagamento__c 
                FROM 
                    Pagamento__x
                WHERE
                    Id IN :setPagamentosIds];
        
        //FIM | PLV-2233-27
    }
    
    //INICIO | PLV-2233-27-v2
    public List<Pagamento__x> buscarPagamentosPorIdcs(List<Integer> setPagamentosIdcs) {

        if(Test.isRunningTest()) {
            return (mockedPagamentos.size() > 0) ? mockedPagamentos : null;
        }
        

        return [SELECT 
                    id, 
                    Status__c, 
                    DataProgramadaPagamento__c,
                    Descricao__c, 
                    ExternalId , 
                    Id__c, 
                    IdConta__c, 
                    IdConta__r.Cnpj__c, 
                    IdConta__r.Cpf__c, 
                    idObjeto__c, 
                    Matricula__c, 
                    TipoConta__c, 
                    TipoPagamento__c 
                FROM 
                    Pagamento__x
                WHERE
                    Id__c IN :setPagamentosIdcs];
    }
    //FIM | PLV-2233-27-v2

}