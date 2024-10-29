public class GarantiaPropostaTriggerHandler extends TriggerHandler {
	private static GarantiaPropostaBO objBO = GarantiaPropostaBO.getInstance();

	public override void beforeInsert() {
		objBO.validarGarantias(Trigger.new);
		objBO.atualizarFranquia(Trigger.new); //PLV-4598 - INICIO/FIM
	}

	public override void beforeUpdate() {
		objBO.validarGarantias(Trigger.new);
		objBO.atualizarFranquia(Trigger.new); //PLV-4598 - INICIO/FIM
	}
}