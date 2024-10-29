/**
 * Trigger Handler Grupo Proposta
 * @author Jeferson santana
 * Estória: AV-824
 **/
public class GrupoPropostaTriggerHandler  extends TriggerHandler{
    private static QuoteBO proposta = QuoteBO.getInstance();
    public override void afterInsert() {
        proposta.getGarantiasGrupoProposta(trigger.new);
	}
}