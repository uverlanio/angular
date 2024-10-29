public with sharing class ContratantePropostaTriggerHandler  extends TriggerHandler 
{
	private static QuoteBO bo = QuoteBO.getInstance();

    public override void beforeInsert(){
        bo.validarDadosPagamentoSeguradoProposta(Trigger.new);
    }

    public override void beforeUpdate(){
        bo.validarDadosPagamentoSeguradoProposta(Trigger.new);
    }
    //AV-824 - INICIO
    public override void afterInsert(){
        bo.getGarantiasOportunityContratante(Trigger.new);
    }
    //AV-824 - FIM
}