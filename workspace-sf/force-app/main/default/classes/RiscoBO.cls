/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio dos objetos relacionados a Risco
 *
 **************************************************************************************************************************************************************************/
public  class RiscoBO {
	private static final RiscoBO instancia = new RiscoBO();
	private RiscoDAO dao = RiscoDAO.getInstance();

	private RiscoBO() {	
	}

	public static RiscoBO getInstance(){
		return instancia;
	}

	/**
	 * Verifica se uma ordem de exibição foi ou não utiliziada
	 *
	 */
	public List<RiscoGarantia__c> buscarRiscosGarantiasPorGarantiaProduto(Set<Id> garantiaProdutoIds){
		return dao.buscarRiscosGarantiasPorGarantiaProduto(garantiaProdutoIds);
	}


	/**
	 * Ativa a flag de capital de risco no objeto de Garantia do produto
	 *
	 */
	public void ativarCapitalRiscoGarantiaProduto(List<RiscoGarantia__c> riscosGarantia){
		List<GarantiaProduto__c> garantiasProduto = new List<GarantiaProduto__c>();
		Set<Id> garantiasProdutoSelecionadas = new Set<Id>();

		for(RiscoGarantia__c risco : riscosGarantia){
			if(!garantiasProdutoSelecionadas.contains(risco.GarantiaProduto__c)){
				garantiasProduto.add(new GarantiaProduto__c(Id = risco.GarantiaProduto__c, CapitalRiscos__c = true));
				garantiasProdutoSelecionadas.add(risco.GarantiaProduto__c);
			}
		}

		update garantiasProduto;
	}

	/**
	 * Desativa a flag de capital de risco no objeto de Garantia do produto
	 *
	 */
	public void desativarCapitalRiscoGarantiaProduto(List<RiscoGarantia__c> riscosGarantia, Map<Id, RiscoGarantia__c> riscosGarantiaOld){
		Set<Id> garantiasProdutoIds = new Set<Id>();
		Map<Id, List<RiscoGarantia__c>> mapGarantiaRiscos = new Map<Id, List<RiscoGarantia__c>>();
		List<GarantiaProduto__c> garantiasProduto = new List<GarantiaProduto__c>();

		//Recupera as ids das garantias a serem analizadas e realiza query 
		for(RiscoGarantia__c riscoOld : riscosGarantiaOld.values()){
			garantiasProdutoIds.add(riscoOld.GarantiaProduto__c);
			mapGarantiaRiscos.put(riscoOld.GarantiaProduto__c, new List<RiscoGarantia__c>());
		}

		//Gera map separando os riscos por garantia do produto
		for(RiscoGarantia__c risco : this.buscarRiscosGarantiasPorGarantiaProduto(garantiasProdutoIds)){
			mapGarantiaRiscos.get(risco.GarantiaProduto__c).add(risco);			
		}

		//Separa garantia que precisa terem a flag de capital de risco desativada
		for(RiscoGarantia__c riscoOld : riscosGarantiaOld.values()){
			if(mapGarantiaRiscos.get(riscoOld.GarantiaProduto__c).isEmpty()){
				garantiasProduto.add(new GarantiaProduto__c(Id = riscoOld.GarantiaProduto__c, CapitalRiscos__c = false));
			}
		}

		if(!garantiasProduto.isEmpty()){
			update garantiasProduto;
		}	
	}

	/**
     * Realiza validação se alguma operação poderá ser executa no registro de produto comercial
     *
     */
    public void validarPermissaoEdicaoExclusaoItemProdutoComercial(List<RiscoGarantia__c> riscosGarantia){
    	RegrasFabricaProdutos.validarPermissaoEdicaoExclusaoItemProdutoComercial(riscosGarantia, 'RiscoGarantia__c');
    }
}