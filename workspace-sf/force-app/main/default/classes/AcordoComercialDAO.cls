/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pela buscade dados do objeto de AcordoComercial__c
 *
 **************************************************************************************************************************************************************************/
public class AcordoComercialDAO {
	private static final AcordoComercialDAO instancia = new AcordoComercialDAO();

	private AcordoComercialDAO() {	
	}

	public static AcordoComercialDAO getInstance(){
		return instancia;
	}

	public List<AcordoComercial__c> buscarAcordoComercialPorId(Set<Id> acordoComercialIds){
		return [
			Select
				Id,
				CanalDistribuicao__c
			From	
				AcordoComercial__c	
			Where
				Id IN :acordoComercialIds
		];
	}

	public List<ProdutoAcordo__c> buscarProdutosAcordoPorAcordoId(Set<Id> acordoComercialIds){
		return [
			Select
				Id
			From	
				ProdutoAcordo__c	
			Where
				AcordoComercial__c IN :acordoComercialIds
		];
	}

	public List<ProdutoAcordo__c> buscarProdutosPorProductCode(Set<String> setProductCode){
        return [
                SELECT
                        Id,
                        AcordoComercial__c,
                        Produto__r.VersaoMaxima__c,
												Produto__r.Versao__c,
                        Produto__r.ProductCode,
						Produto__r.CodigoPrecificaProduto__c // PLV-5331 INÍCIO / FIM 
                FROM
                        ProdutoAcordo__c
                WHERE
                        Produto__r.ProductCode =: setProductCode
        ];
    }
}