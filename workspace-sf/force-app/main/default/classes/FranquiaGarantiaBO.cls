/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de FranquiaGarantia__c
 *
 **************************************************************************************************************************************************************************/

public class FranquiaGarantiaBO {
	private static final FranquiaGarantiaBO instancia = new FranquiaGarantiaBO();

	private FranquiaGarantiaBO() {
	}

	public static FranquiaGarantiaBO getInstance(){
		return instancia;
	}

	/**
     * Realiza validação se alguma operação poderá ser executa no registro de produto comercial
     *
     */
    public void validarPermissaoEdicaoExclusaoItemProdutoComercial(List<FranquiaGarantia__c> franquiasGarantia){
    	RegrasFabricaProdutos.validarPermissaoEdicaoExclusaoItemProdutoComercial(franquiasGarantia, 'FranquiaGarantia__c');
    }
    
    //PLV-4106 - Início
    public void bloquearExclusaoProdutoComercial(List<FranquiaGarantia__c> lstFranquiasGarantia){
    	
        Id recTypeIdProdutoComercial = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoComercial').Id;
        
        for( FranquiaGarantia__c franquiaGarantia : lstFranquiasGarantia ){
            if( franquiaGarantia.RecordTypeId == recTypeIdProdutoComercial ){
                franquiaGarantia.addError('Não é possível excluir uma Franquia de Garantia de um Produto Comercial.');
			}
		}
    }
    //PLV-4106 - Fim    
}