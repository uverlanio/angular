//PLV-5230 - INICIO
/**
 * Camada de abstração de dados do objeto ProdutoIntegracaoOpin__c
 * @author Julio Duarte @ 11/10/2021
 *
 **/
public class ProdutoIntegracaoOpinDAO {

    private static final ProdutoIntegracaoOpinDAO instance = new ProdutoIntegracaoOpinDAO();
	public static ProdutoIntegracaoOpinDAO getInstance() {
		return instance;
	}

    public ProdutoIntegracaoOpinDAO() { }


    public ProdutoIntegracaoOpin__c buscarProdutoIntegracaoOpin(Id idProduto) {
        List<ProdutoIntegracaoOpin__c> lst = [
                                        SELECT id, Data_Ultima_Integracao__c, Dados_Ultima_Integracao__c, Produto__c
                                        FROM ProdutoIntegracaoOpin__c
                                        WHERE Produto__c = :idProduto 
                                        LIMIT 1
                                    ];
        return (lst.size() > 0 ? lst[0]: null);
    }

}
//PLV-5230 - FIM