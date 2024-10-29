/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelas captura dos eventos de trigger do objeto GarantiaRelacionada__c
 *
 **************************************************************************************************************************************************************************/
 public class GarantiaRelacionadaTriggerHandler extends TriggerHandler {
 	private GarantiaRelacionadaBO bo = GarantiaRelacionadaBO.getInstance();

	public override void beforeInsert() {
		bo.vincularTipoRegistroComercial(trigger.new);
		//bo.validarGarantiaRelacionadaProdutoComercial(trigger.new);
	}
	//PLV-3667 - INICIO
	//public override void beforeUpdate() {
		//bo.validarGarantiaRelacionadaProdutoComercial(trigger.new); Este item já estava comentado, então foi comentado o metodo.
	//}

	//public override void beforeDelete() {
		//bo.validarGarantiaRelacionadaProdutoComercial(trigger.old); Este item já estava comentado, então foi comentado o metodo.
	//}
	//PLV-3667 - FIM
	public override void afterInsert() {
		bo.habilitarValidacaoRegrasProdutoComercial(trigger.new);
        bo.validarGarantiaRelacionadaProdutoComercial(trigger.new);
	}
     
     public override void afterUpdate(){
         bo.validarGarantiaRelacionadaProdutoComercial(trigger.new);
     }
}