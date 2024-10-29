//LECVP-212 - INICIO
public with sharing class PagamentoSinistroDAO {
    
    private static final PagamentoSinistroDAO instancia = new PagamentoSinistroDAO();

    public static PagamentoSinistroDAO getInstance(){
        return instancia;
    }

    public Pagamento_de_Sinistro__c buscar(Set<Id> id){
        return [
                SELECT 
                    Id,
                    Name 
                FROM 
                    Pagamento_de_Sinistro__c 
                WHERE 
                    Id = :id
        ];
    }
}
//LECVP-212 - FIM