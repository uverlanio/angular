/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de RemuneracaoMultinivel__c
 *
 **************************************************************************************************************************************************************************/
public class RemuneracaoMultinivelBO {
	private static final RemuneracaoMultinivelBO instancia = new RemuneracaoMultinivelBO();

	private RemuneracaoMultinivelBO() {	
	}

	public static RemuneracaoMultinivelBO getInstance(){
		return instancia;
	}

	/**
	 * Valida se um tipo de remuneração pode ou não ser utilizado
	 *
	 */
	public void validarTipoRemuneracao(List<RemuneracaoMultinivel__c> remuneracoesMultinivel){
		RegrasFabricaProdutos.validarTipoRemuneracaoFilhosProdutoCanal(remuneracoesMultinivel, 'RemuneracaoMultinivel__c');
	}
}