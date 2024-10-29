public class PagamentoGarantiaTriggerHandler extends TriggerHandler {
	private static PagamentoGarantiaBO bo = PagamentoGarantiaBO.getInstance();
    public static Boolean isFirstTime = true;
    public static Boolean gerarMovimento = true;
    public static Boolean fechamentoSinistro = false; // POR062-1 INICIO/FIM
     
    public override void afterUpdate() {
        bo.efetuaPagamentoGarantia(Trigger.new, (Map<Id,PagamentoGarantia__c>) Trigger.oldMap);
        //bo.listarBeneficiarios(Trigger.new, (Map<Id,PagamentoGarantia__c>) Trigger.oldMap); Comentado pois a inserção será feita em CasoBO - Inicio/ Fim
        //PLV-4037 INICIO
        if(isFirstTime && gerarMovimento) { // POR062-92 INICIO
            System.debug('ENTROU AQUI HENRIQUE');
            bo.gerarMovimentoSinistroGarantiaUpdate(Trigger.new, (Map<Id,PagamentoGarantia__c>) Trigger.oldMap);
        } // POR062-92 FIM
        //PLV-4037 FIM

        //PLV-4070 - INICIO
        if(isFirstTime) {
            bo.atualizaPercentualIndenizacao((Map<Id,PagamentoGarantia__c>) Trigger.newMap);
            bo.zeraValorIndenizado(Trigger.new, (Map<Id,PagamentoGarantia__c>) Trigger.oldMap); // LECVPV-216 INICIO/FIM
        }
        //PLV-4070 - FIM
        bo.UpdateGarantiaSegurado(Trigger.new, (Map<Id,PagamentoGarantia__c>) Trigger.oldMap); //PLV-4559 - INICIO/FIM
    }
    //PLV-3854 INICIO
	public override void afterInsert() {
        if(!Test.isRunningTest()) { bo.updateMoedaEstrangeira(Trigger.new); }
        
        //PLV-4037 INICIO
        if(isFirstTime) {
            bo.gerarMovimentoSinistroInsert(Trigger.new);
        }
      	//PLV-4037 FIM
    }
    //PLV-3854 FIM

    //PLV-4070 - INICIO
    public override void beforeUpdate(){
        bo.atualizaValorIndenizado(Trigger.new); //PLV-4070_FIX - INICIO/FIM
    }
    //PLV-4070 - FIM
}