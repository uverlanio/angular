public class AccountTriggerHandler extends TriggerHandler {
	private static AccountBO bo = AccountBO.getInstance();

	public override void beforeInsert() {
		System.debug('chamou before insert');
		bo.validarCPFCNPJ(trigger.new);
		bo.validaFormatoTelefone(Trigger.New); // ANNVI-55 INICIO-FIM
	}

	public override void beforeUpdate() {
		System.debug('chamou before update');
		bo.validarCPFCNPJ(trigger.new);
		bo.validaFormatoTelefone(Trigger.New); // ANNVI-55 INICIO-FIM
	}

	public override void afterUpdate() {
		bo.analisarPapeisInformacoesBancarias(trigger.new);
	}
	//PLV-3748 - INICIO - Criacao da trigger de before delete
	public override void beforeDelete() {
		bo.alteraContatoDoCaso(trigger.old);
	}
	//PLV-3748 - FIM
}