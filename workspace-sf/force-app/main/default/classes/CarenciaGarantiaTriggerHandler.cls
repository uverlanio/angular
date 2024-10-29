public class CarenciaGarantiaTriggerHandler extends TriggerHandler {
	private static CarenciaGarantiaBO bo = CarenciaGarantiaBO.getInstance();

	public override void beforeUpdate() {
        //PLV-4106 - Início
		//bo.validarPermissaoEdicaoExclusaoItemProdutoComercial(trigger.new);
        //PLV-4106 - fim
	}	

	public override void beforeDelete() {
        //PLV-4106 - Início
		//bo.validarPermissaoEdicaoExclusaoItemProdutoComercial(trigger.old);
        bo.bloquearExclusaoProdutoComercial(trigger.old);
        //PLV-4106 - Início
	}	
}