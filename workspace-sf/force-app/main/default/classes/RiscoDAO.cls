/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pela busca de dados nos objetos relacionados a risco
 *
 **************************************************************************************************************************************************************************/
public  class RiscoDAO {
	private static final RiscoDAO instancia = new RiscoDAO();

	private RiscoDAO() {	
	}

	public static RiscoDAO getInstance(){
		return instancia;
	}

	public List<RiscoGarantia__c> buscarRiscosGarantiasPorGarantiaProduto (Set<Id> garantiaProdutoIds){
		return [
			Select 
				Id, 
				GarantiaProduto__c
			From 
				RiscoGarantia__c 
			Where 
				GarantiaProduto__c IN: garantiaProdutoIds
		];
	}
}