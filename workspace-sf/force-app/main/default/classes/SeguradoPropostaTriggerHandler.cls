/**
 * Created by Alessandro Ponte on 23/07/2018.
 */

public class SeguradoPropostaTriggerHandler extends TriggerHandler
{
    private static SeguradoPropostaBO bo = SeguradoPropostaBO.getInstance();
	private static QuoteBO propostaBO = QuoteBO.getInstance();
	private static PepBO pep = PepBO.getInstance();

	public override void beforeInsert() 
	{
		propostaBO.validarDadosPagamentoVidaProposta(trigger.new);
	}

	public override void beforeUpdate() 
	{
		propostaBO.validarDadosPagamentoVidaProposta(trigger.new);
	}

	public override void afterInsert() 
	{
		bo.validarVidasCpfRepetidosProposta(trigger.new);
		propostaBO.getGarantiasGrupoPropostaSegurado(trigger.new); //AV-824 - INICIO/FIM
		//pep.getListObjectPep(Trigger.new); //INICIO/FIM LECVPV-218 INICIO/FIM LECVPV-235-FIX1
	}	
}