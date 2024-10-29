/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de GarantiaRelacionada__c
 *
 **************************************************************************************************************************************************************************/
public  class GarantiaRelacionadaBO {
	private static final GarantiaRelacionadaBO instancia = new GarantiaRelacionadaBO();

	private GarantiaRelacionadaBO() {	
	}

	public static GarantiaRelacionadaBO getInstance(){
		return instancia;
	}

	/*********************************************************************************************************
	*
	* Verifica criação/edição de Dependente Garantia para o produto comercial 
	*
	*********************************************************************************************************/
	public void validarGarantiaRelacionadaProdutoComercial(List<GarantiaRelacionada__c> garantiasRelacionadas){
    //PLV- 2549 - Inicio
		//RegrasFabricaProdutos.validarPossibilidadeDMLProdutoComercialFilhosGarantiaProduto(garantiasRelacionadas, 'GarantiaRelacionada__c', 'GarantiasRelacionada__r');
		RegrasFabricaProdutos.validarGarantiaRelacionada(garantiasRelacionadas);
    }
    //PLV- 2549 - Fim

	/*********************************************************************************************************
	*
	* Habilita novamente a flag que permite que as regra de limite sejam executadas
	*
	*********************************************************************************************************/
	public void habilitarValidacaoRegrasProdutoComercial(List<GarantiaRelacionada__c> garantiasRelacionadas){
		RegrasFabricaProdutos.habilitarValidacaoRegrasProdutoComercial(garantiasRelacionadas, 'GarantiaRelacionada__c', 'GarantiaRelacionadaTriggerHandler');
	}

	/*********************************************************************************************************
	*
	* Vincula tipo de registro comercial de acordo com o produto que estiver vinculado
	*
	*********************************************************************************************************/
	public void vincularTipoRegistroComercial(List<GarantiaRelacionada__c> garantiasRelacionadas){
		RegrasFabricaProdutos.vincularTipoRegistroComercialFilhoGarantiaProduto(garantiasRelacionadas, 'GarantiaRelacionada__c');
	}
}