public class GarantiaSeguradoContratoTriggerHandler extends TriggerHandler {
	private static GarantiaSeguradoContratoBO bo = GarantiaSeguradoContratoBO.getInstance();
    
    public override void afterInsert(){
        bo.preencherNomenclatura(trigger.new);
        //PLV-4830 INICIO
        bo.preencherLimiteUtilizacao(trigger.new);
        //PLV-4830 FIM
    }
    
    
}