/**
 * EnderecoTriggerHandler
 * @author Fernando Barcellos @ 19/12/2017
 *
 **/
public class EnderecoTriggerHandler extends TriggerHandler {
	private static EnderecoBO bo = EnderecoBO.getInstance();

	// PLV-3995 - INICIO
	public override void beforeInsert() {
		bo.validaEnderecoCobranca(trigger.new,null);
	}
	// PLV-3995 - FIM
		
	public override void afterInsert() {
		bo.atualizarEnderecoSegurados(trigger.new);
		bo.desmarcarEnderecosAntigos(trigger.new);
	}

	// PLV-3995 - INICIO
	public override void beforeUpdate() {
		bo.validaEnderecoCobranca(trigger.new, (Map<Id,Endereco__c>) trigger.oldMap);
	}
	// PLV-3995 - FIM

	public override void afterUpdate() {
		bo.atualizarEnderecoSegurados(trigger.new);
		bo.desmarcarEnderecosAntigos(trigger.new);
	}
}