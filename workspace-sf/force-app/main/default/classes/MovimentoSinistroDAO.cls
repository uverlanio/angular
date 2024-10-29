// POR062-1 - INICIO
public inherited sharing class MovimentoSinistroDAO {
    private static final MovimentoSinistroDAO INSTANCIA = new MovimentoSinistroDAO();
    private MovimentoSinistroDAO() {}

	public static MovimentoSinistroDAO getInstance()
    {
		return instancia;
	}
    
    public List<MovimentoSinistro__c> buscarPorIdCaso(Set<Id> idCasos)
    {
        List<MovimentoSinistro__c> movimentos = [
            SELECT
                Id, Caso__c, ValorMovimento__c, DescricaoMovimento__c, SequenciaMovimento__c, SinistroJudicial__c,
                PagamentoGarantia__r.Id, PagamentoGarantia__r.Name
            FROM MovimentoSinistro__c
            WHERE Caso__c IN: idCasos
            ORDER By Name ASC   // LECVPV-140-FIX04 INICIO/FIM
        ];
        return movimentos;
    }
    //LECVP-216 - INICIO
    //LECVPV-140 - INICIO
    public List<MovimentoSinistro__c> buscarMovimentosPorGarantia(Set<Id> garantias){
        List<MovimentoSinistro__c> movimentos = [
            SELECT 
                Id,
                DescricaoMovimento__c,
                PagamentoGarantia__c,
                SinistroJudicial__c,
                ValorMovimento__c, // LECVPV-216 INICIO/FIM
                SequenciaMovimento__c // LECVPV-216 INICIO/FIM
            FROM
                MovimentoSinistro__c 
            WHERE
                PagamentoGarantia__c IN :garantias
        ];
        
        return movimentos;
    }
    //LECVP-216 - FIM
    //LECVPV-140 - FIM
}
// POR062-1 - FIM