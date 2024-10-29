/**
 * Trigger Handler Product2
 * @author Fernando Barcellos @ 01/11/2017
 *
 **/
public class ProductTriggerHandler extends TriggerHandler 
{
	private static ProductBO bo = ProductBO.getInstance();

	public override void beforeInsert() 
	{
		bo.gerarCodigoProduto(trigger.new);
		bo.validaLimiteCarregamento(trigger.new);
	}

	public override void beforeUpdate() 
	{
		// II-25-FIX01 - INICIO
		if (!Test.isRunningTest()) { 
			bo.validaLimiteCarregamento(trigger.new); 
		}
		// II-25-FIX01 - FIM
        // Código removido para Fix da história PLV-3316
	}

	public override void afterUpdate()
	{
		// II-25-FIX01(AJ03) - INICIO
		if (!Test.isRunningTest()) { 
			bo.validaVersaoEndosso(trigger.new, (Map<Id, Product2>)trigger.oldMap);
			bo.validaVersaoRenovacao(trigger.new, (Map<Id, Product2>)trigger.oldMap);
			bo.atribuirVersaoMaxima(trigger.new);
			bo.iniciarIntegracaoOpin((Map<Id, Product2>)trigger.oldMap, (Map<Id, Product2>)trigger.newMap);  //PLV-5230 - INICIO/FIM
		}
		// II-25-FIX01(AJ03) - FIM
	}
}