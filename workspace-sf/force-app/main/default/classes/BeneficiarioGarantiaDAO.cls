// POR062-1 - INICIO
public inherited sharing virtual class BeneficiarioGarantiaDAO {
    private static final BeneficiarioGarantiaDAO INSTANCIA = new BeneficiarioGarantiaDAO();
    private BeneficiarioGarantiaDAO() {}

    public static BeneficiarioGarantiaDAO getInstance(){
        return instancia;
    }

    public List<BeneficiarioGarantia__c> buscarPorIdDePagamentosDeGarantia(Set<Id> idsPagamentoGarantia) {
        List<BeneficiarioGarantia__c> beneficiarios = [
            SELECT Id, Status__c, ValorIndenizacao__c //LECVP-193 - INICIO/FIM
            FROM BeneficiarioGarantia__c
            WHERE Pagamento_de_garantia__c IN :idsPagamentoGarantia
        ];
        return beneficiarios;
    }

    //LECVP-344 - INICIO
    public AggregateResult[] buscarValPagoGarSin(String statusPgto, Id pgtoGarId){

        AggregateResult[] ar = 
          [
            SELECT 
              Id, 
              SUM(ValorIndenizacao__c)valorPagoGar 
            FROM 
              BeneficiarioGarantia__c 
            WHERE 
              Status__c = :statusPgto
            AND 
              Pagamento_de_garantia__r.Id = :pgtoGarId
            GROUP BY
              Id
            ];
            
        return ar;
      }
      
    public AggregateResult[] buscarValPagoGarsSin(String statusPgto, Set<Id> pgtosGarId){

      AggregateResult[] ar = 
        [
          SELECT 
            Id, 
            SUM(ValorIndenizacao__c)valorPagoGar 
          FROM 
            BeneficiarioGarantia__c 
          WHERE 
            Status__c = :statusPgto
          AND 
            Pagamento_de_garantia__r.Id IN :pgtosGarId
          GROUP BY
            Id
          ];
          
      return ar;
    }
    //LECVP-344 - FIM
}
// POR062-1 - FIM