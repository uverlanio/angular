public class MovimentoSinistroTriggerHandler extends TriggerHandler {
	private static MovimentoSinistroBO bo = MovimentoSinistroBO.getInstance();
	private static PagamentoDeSinistroBO pagBo = PagamentoDeSinistroBO.getInstance(); //LECVP-344 - INICIO/FIM

	public override void afterInsert(){
		bo.insereControleIntegracao(Trigger.new);
		pagBo.calcularSaldResrvGarantia(Trigger.new); //LECVP-344 - INICIO/FIM
		pagBo.calcularSaldResrvCaso(Trigger.new); //LECVP-344 - INICIO/FIM
		// LECVPV-216 INICIO
		bo.criarComplementosEncerramento(Trigger.new); 
		// LECVPV-216 FIM
		pagBO.efetuarBaixasPorPagamento(Trigger.new); // LECVPV-200 INICIO/FIM
	}

}