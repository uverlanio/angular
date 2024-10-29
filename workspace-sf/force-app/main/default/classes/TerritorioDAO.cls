/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelas buscas no objeto de Território da garantia
 *
 **************************************************************************************************************************************************************************/
public class TerritorioDAO {
	private static final TerritorioDAO instance = new TerritorioDAO();
	
	private TerritorioDAO() {
	}

	public static TerritorioDAO getInstance() {
		return instance;
	}	

	/**
	 * Realiza a busca de todos os territorios da garantia referente a uma garantia de produto
	 *
	 * @param   garantiaProdutoId  - id de uma garantia de produto
	 */
	public List<Territorio__c> buscarTerritoriosGarantia(Id garantiaProdutoId) {
		return [
			Select 
				Id,
				Continente__c,
				Estado__c,
				Municipio__c,
				Pais__c,
				Tipo__c,
				RecordTypeId
			From 
				Territorio__c	
			Where 
				GarantiaProduto__c =: garantiaProdutoId
			Order By CreatedDate	
		];
	}

	/**
	 * Realiza a busca de todos os territorios do produto
	 *
	 * @param  produtoId  - id do produto
	 */
	public List<Territorio__c> buscarTerritoriosProduto(Id produtoId) {
		return [
			Select 
				Id,
				Continente__c,
				Estado__c,
				Municipio__c,
				Pais__c,
				Tipo__c,
				RecordTypeId
			From 
				Territorio__c	
			Where 
				Produto__c =: produtoId
			Order By CreatedDate	
		];
	}
}