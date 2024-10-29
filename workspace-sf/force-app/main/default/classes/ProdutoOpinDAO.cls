//PLV-5230 - INICIO
/**
 * Camada de abstração de dados do objeto ProdutoOPIN__c
 * @author Julio Duarte @ 07/12/2021
 *
 **/
public class ProdutoOpinDAO {

    private static final ProdutoOpinDAO instance = new ProdutoOpinDAO();
	public static ProdutoOpinDAO getInstance() {
		return instance;
	}

    public ProdutoOpinDAO() { }


    public List<ProdutoOPIN__c> buscarProdutosOPIN() {

        return  [
                    SELECT Id, Name, SiglaProduto__c, SistemaOrigem__c, DetalhesJson__c
                    FROM ProdutoOPIN__c
                    WHERE SistemaOrigem__c = 'SALESFORCE'  //PLV-5230 - FIX01 - INICIO/FIM
                    LIMIT 1000
                ];
    }

}
//PLV-5230 - FIM