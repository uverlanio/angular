/**
 * CriticaOrcamentoBO
 *
 **/
public class CriticaOrcamentoTriggerHandler extends TriggerHandler 
{
	//AVX - PLV2608 - INÍCIO - Criação do workflow de orçamento
    public override void beforeInsert() 
	{
		CriticaOrcamentoBO.getInstance().atribuiProprietarioCriticaOrcamento(trigger.new);
	}
    
    public override void afterInsert() 
	{        
		//CriticaOrcamentoBO.getInstance().enviarOrcamentoAreaTecnica(trigger.new);
		CriticaOrcamentoBO.getInstance().iniciaProcessoAprovacaoCriticaOrcamento(trigger.new);
	}
	//AVX - PLV2608 - FIM - Criação do workflow de orçamento
	public override void afterUpdate() 
	{
		CriticaOrcamentoBO.getInstance().atualizarOportunidade(trigger.new);
	}
}