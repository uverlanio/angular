public class SeguradoContratoTriggerHandler extends TriggerHandler {
	private static SeguradoContratoBO bo = SeguradoContratoBO.getInstance();
    
    public override void afterInsert(){
        bo.preencherNomenclaturaSegurado(trigger.new);
    }
}