/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de DependenteGarantia__c
 *
 **************************************************************************************************************************************************************************/
public  class DependenteGarantiaBO {
	private static final DependenteGarantiaBO instancia = new DependenteGarantiaBO();

	private DependenteGarantiaBO() {	
	}

	public static DependenteGarantiaBO getInstance(){
		return instancia;
	}

	/*********************************************************************************************************
	*
	* Verifica criação/edição de Dependente Garantia para o produto comercial 
	*
	*********************************************************************************************************/
	public void validarDependeteGarantiaProdutoComercial(List<DependenteGarantia__c> dependentesGarantia){
		RegrasFabricaProdutos.validarPossibilidadeDMLProdutoComercialFilhosGarantiaProduto(dependentesGarantia, 'DependenteGarantia__c', 'DependentesGarantia__r');
	}

	/*********************************************************************************************************
	*
	* Habilita novamente a flag que permite que as regra de limite sejam executadas
	*
	*********************************************************************************************************/
	public void habilitarValidacaoRegrasProdutoComercial(List<DependenteGarantia__c> dependentesGarantia){
		RegrasFabricaProdutos.habilitarValidacaoRegrasProdutoComercial(dependentesGarantia, 'DependenteGarantia__c', 'DependenteGarantiaTriggerHandler');
	}

	/*********************************************************************************************************
	*
	* Validar a criação dependentes garantia
	*
	*********************************************************************************************************/
	public void validarCriacaoDependentesGarantia(List<DependenteGarantia__c> dependentesGarantia) {
		// record type produto comercial
		Id recordTypeIdProdutoComercial = RecordTypeBO.buscarTipoRegistro('DependenteGarantia__c', 'ProdutoComercial').Id;
		
		// set com ids das garantias de produto
		Set<Id> garantiasProduto = new Set<Id>();

		for (DependenteGarantia__c dg : dependentesGarantia) {
			if (dg.RecordTypeId == recordTypeIdProdutoComercial) {
				garantiasProduto.add(dg.GarantiaProduto__c);
			}
		}

		// todas as garantias do produto destas dependentes da garantia
		List<GarantiaProduto__c> lstGarantiaProduto = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(garantiasProduto);

		// relacionamento garantia comercial e garantia técnica
		Map<Id, Id> map1 = new Map<Id, Id>();
		
		// set garantia do produto técnico
		Set<Id> setGarantiaProdutoTecnico = new Set<Id>();

		// varre todo o resultado da query
		for (GarantiaProduto__c gp : lstGarantiaProduto) {
			// id produto comercial + id produto técnico
			map1.put(gp.Id, gp.GarantiaProduto__c);
			
			// set garantia do produto técnico
			setGarantiaProdutoTecnico.add(gp.GarantiaProduto__c);
		}

		// todas as garantias de produto técnico com o objeto relacionado de dependentes da garantia
		List<GarantiaProduto__c> lstGarantiaProdutoTecnico = GarantiaProdutoDAO.getInstance().buscarGarantiasMaisFilhosPorId(setGarantiaProdutoTecnico);

		// map garantia tecnica + dependentes
		Map<Id, GarantiaProduto__c> map2 = new Map<Id, GarantiaProduto__c>();
		
		// varre todas as garantias de produto técnico 
		for (GarantiaProduto__c gp : lstGarantiaProdutoTecnico) {
			// map relacionando as garantias do produto técnico (id, objeto)
			map2.put(gp.Id, gp);
		}

		List<String> inexistentesEntrada = new List<String>();

		// varre novamente todos os dependentes da garantia 
		for (DependenteGarantia__c dg : dependentesGarantia) {
			// filtra apenas comercial
			if (dg.RecordTypeId == recordTypeIdProdutoComercial) {
				Id idGarantiaTecnico = map1.get(dg.GarantiaProduto__c);
				GarantiaProduto__c garantiaProdutoTecnico = map2.get(idGarantiaTecnico);

				for (DependenteGarantia__c dependentesGarantiaTecnico : garantiaProdutoTecnico.DependentesGarantia__r) {
					Set<String> dependentesTecnico = new Set<String>(dependentesGarantiaTecnico.Dependente__c.split(';'));
					Set<String> dependentesComercial = new Set<String>(dg.Dependente__c.split(';'));
					if (!dependentesTecnico.containsAll(dependentesComercial)) {
						inexistentesEntrada = retornarDiferenca(dependentesComercial, dependentesTecnico);
						String mensagemErro = '';
						if (inexistentesEntrada.size() > 1) {
							mensagemErro = 'Estes dependentes não estão no produto técnico: ' + inexistentesEntrada;
						}
						else {
							mensagemErro = 'Este dependente não está no produto técnico: ' + inexistentesEntrada;
						}
						dg.addError(mensagemErro);
					}
				}
			}
		}
	}

	private List<String> retornarDiferenca(Set<String> a, Set<String> b) {
		List<String> diferenca = new List<String>();
		for (String v : a) {
			if (!b.contains(v)) {
				diferenca.add(v);
			}
		}
		return diferenca;
	}
}