/**
 * Trigger Handler Contract
 * @author João Losada @ 25/06/2018
 *
 **/
public class ContractTriggerHandler extends TriggerHandler {
    private static final String CLASS_NAME = 'ContractTriggerHandler';
	private static ContractBO bo = ContractBO.getInstance();
	private static VoucherPdfGenerator voucherGeneratorClass = VoucherPdfGenerator.getInstance(); //ZSVEP-47
    
    private static PriContratRenova objRenova = PriContratRenova.getInstance(); //RVI-95 - INICIO/FIM

	public override void beforeInsert() {
        system.debug('Usuário = ' + userinfo.getName());
        bo.processarContasContrato(trigger.new);
        //PLV-4536 inicio
        bo.gravarUltimoModificador(trigger.new);
        //PLV-4536 fim
        ContractBO.setUltimoModificador(trigger.new);
    

	}
   //PLV-3672 inicio
	public override void afterInsert() {
		/*if (!Test.isRunningTest())
			bo.executarRegrasLog(trigger.new);*/
     
     
     
          
	}

	//PLV-3392 - INICIO
	//PLV-3392-FIX2 - INICIO/FIM - Codigo comentado para correcao
	/*public override void beforeUpdate() {
		//bo.atualizarIOF(trigger.new, (Map<Id,Contract>)trigger.oldMap);
	}*/
	//PLV-3392 - FIM

    //PLV-4871 - INICIO
    public override void beforeUpdate(){
        bo.atualizarVigencia(trigger.new, (Map<Id,Contract>)trigger.oldMap);

        ContractBO.setUltimoModificador(trigger.new);

        //RVI-95 - INICIO           
        objRenova.updContracts(trigger.new); //RVI-95 - FIX01 - INICIO/FIM                   
        //RVI-95 - FIM 
    }
    //PLV-4871 - FIM

 	public override void afterUpdate() {
        //  voucherGeneratorClass.criarVoucher(Trigger.new); //ZSVEP-47 // LECVPV-188 INICIO/FIM
        Debug.getInstance().start(); // LECVP-69 - Inicio/Fim
        if(System.isBatch()) return; //PLV-5266 INÍCIO/FIM FIX 01

       // bo.EnderecoSeguradoContrato(trigger.new); // VIAG-19  inicio-fim  
        String METHOD_NAME = 'afterUpdate';
        bo.processarStatusHeroku((List<Contract>) Trigger.new); //PLV-4556 - INÍCIO/FIM
        bo.processarIntegracaoAntares(trigger.new, (Map<Id,Contract>)trigger.oldMap); //PLV-4905 - INÍCIO/FIM
        //PLV-3460 - INICIO
        List<Contract> contratos = new List<Contract>();
        for (Contract contrato : (List<Contract>)trigger.new) {
            if (TriggerHelper.isChanged(contrato, 'Status') && contrato.Status == 'Emitido') {
                contratos.add(contrato);
                bo.executarRegrasLog(trigger.new);
                //FNPVVEP-114 INICIO
                if(contrato.Segmento__c == 'Individual'){
                    ComunicacaoTelemedicina.enviarComunicacaoTelemed(contrato.Id);
                }
                //FNPVVEP-114 FIM
                ContractBO.emissaoBoletoVida(trigger.new); //FNPVVEP-108 INICIO
                System.debug(LoggingLevel.ERROR + 'CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => contrato.id: ' + contrato.id);
        //PLV-3672 fim                                            
            }
            
        }
        List<QueueableQTD__c> listCsRegistrosContrato = [SELECT Quantidade__c FROM QueueableQTD__c WHERE Name = 'QueueableSendContract']; //PLV-3460 Fix - INICIO/FIM
        Debug.getInstance().log(new Map<Object, Object> { 'Contratos(Size)' => contratos.size(), 'Contratos size maior que 0?' => contratos.size()> 0 }); // LECVP-69 - Inicio/Fim
        if(System.isQueueable()) return; //PLV-3459 - INICO/FIM
        if(listCsRegistrosContrato.size() > 0){
            Integer qtdRegistrosPorFila = Integer.valueOf(listCsRegistrosContrato[0].Quantidade__c);
            if(qtdRegistrosPorFila == null || qtdRegistrosPorFila <= 0) {
                System.debug('A configuração personalizada QueueableQTD deve ter um registro com nome "QueueableSendContract" e conter um valor maior que 0'); //PLV-3460 Fix - INICIO/FIM
            }
            else if(contratos.size() > 0) {
                System.enqueueJob(new QueueableSendContract(contratos, qtdRegistrosPorFila));
            }
            else {
                System.debug('Não há contratos a serem processados');
            }
        }
        else{
            System.debug('A configuração personalizada QueueableQTD deve ter um registro com nome "QueueableSendContract" e conter um valor maior que 0'); //PLV-3460 Fix - INICIO/FIM
        }
        //PLV-3460 - FIM
        Debug.getInstance().end(); // LECVP-69 - Inicio/Fim
       
    }
}