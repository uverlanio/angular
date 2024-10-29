/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de ParametroRenovacao__c
 *
 **************************************************************************************************************************************************************************/
public  class ParametroRenovacaoBO {
	private static final ParametroRenovacaoBO instancia = new ParametroRenovacaoBO();
	//private ParametroRenovacaoDAO dao = ParametroRenovacaoDAO.getInstance();

	private ParametroRenovacaoBO() {	
	}

	public static ParametroRenovacaoBO getInstance(){
		return instancia;
	}

	/*********************************************************************************************************
	*
	* Verifica criação/edição de Parametro de renovação para o produto comercial 
	*
	*********************************************************************************************************/
	public void validarParametroRenovacalProdutoComercial(List<ParametroRenovacao__c> parametrosRenovacao){
		RegrasFabricaProdutos.validarPossibilidadeDMLProdutoComercialFilhosGarantiaProduto(parametrosRenovacao, 'ParametroRenovacao__c', 'ParametrosRenovacao__r');
	}

	/*********************************************************************************************************
	*
	* Habilita novamente a flag que permite que as regra de limite sejam executadas
	*
	*********************************************************************************************************/
	public void habilitarValidacaoRegrasProdutoComercial(List<ParametroRenovacao__c> parametrosRenovacao){
		RegrasFabricaProdutos.habilitarValidacaoRegrasProdutoComercial(parametrosRenovacao, 'ParametroRenovacao__c', 'ParametroRenovacaoTriggerHandler');
	}

	/*********************************************************************************************************
	*
	* Vincula tipo de registro comercial de acordo com o produto que estiver vinculado
	*
	*********************************************************************************************************/
	public void vincularTipoRegistroComercial(List<ParametroRenovacao__c> parametrosRenovacao){
		RegrasFabricaProdutos.vincularTipoRegistroComercialFilhoGarantiaProduto(parametrosRenovacao, 'ParametroRenovacao__c');
	}
}