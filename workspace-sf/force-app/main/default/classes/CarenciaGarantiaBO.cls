/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de CarenciaGarantia__c
 *
 **************************************************************************************************************************************************************************/

public class CarenciaGarantiaBO {
	private static final CarenciaGarantiaBO instancia = new CarenciaGarantiaBO();

	private CarenciaGarantiaBO() {
	}

	public static CarenciaGarantiaBO getInstance(){
		return instancia;
	}

	/**
     * Realiza validação se alguma operação poderá ser executa no registro de produto comercial
     *
     */
    public void validarPermissaoEdicaoExclusaoItemProdutoComercial(List<CarenciaGarantia__c> carenciasGarantia){
    	RegrasFabricaProdutos.validarPermissaoEdicaoExclusaoItemProdutoComercial(carenciasGarantia, 'CarenciaGarantia__c');
    }
    
    //PLV-4106 - Início
    public void bloquearExclusaoProdutoComercial(List<CarenciaGarantia__c> lstCarenciasGarantia){
    	
        Id recTypeIdProdutoComercial = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoComercial').Id;
        
        for( CarenciaGarantia__c carenciasGarantia : lstCarenciasGarantia ){
            if( carenciasGarantia.RecordTypeId == recTypeIdProdutoComercial ){
            	carenciasGarantia.addError('Não é possível excluir uma Carência da Garantia de um Produto Comercial.');
            }
        }
    }
    //PLV-4106 - Fim
}