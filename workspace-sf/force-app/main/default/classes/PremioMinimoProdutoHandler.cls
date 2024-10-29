/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelas captura dos eventos de trigger do objeto PremioMinimoProduto__c
 *
 **************************************************************************************************************************************************************************/

public class PremioMinimoProdutoHandler extends TriggerHandler {
	public override void beforeInsert() {
		PremioMinimoProdutoBO.getInstance().validarPremiosMinimo(trigger.new);		
	}

	public override void beforeUpdate() {
		PremioMinimoProdutoBO.getInstance().validarPremiosMinimo(trigger.new);
	}

	public override void afterInsert(){
		PremioMinimoProdutoBO.getInstance().habilitarValidacaoRegrasProdutoComercial(trigger.new);
	}
}