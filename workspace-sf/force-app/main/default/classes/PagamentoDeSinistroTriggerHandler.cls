// história: PLV-4065
// descrição da história: aviso de liquidação de sinistros
// Data de Criação: 31/07/2020
// Desenvolvedor: Tiago Welter - Sys4b
public class PagamentoDeSinistroTriggerHandler extends TriggerHandler {
	private static PagamentoDeSinistroBO bo = PagamentoDeSinistroBO.getInstance();
    public static Boolean isFirstTime = true;

    public override void afterInsert(){
        //PLV-4065 inicio
        bo.enviaAvisoLiberacaoPagamento(trigger.new);
        //PLV-4065 fim    
    }
    
    public override void afterUpdate(){
        //PLV-4065 inicio
        bo.enviaAvisoLiberacaoPagamento(trigger.new);
        //PLV-4065 fim

		//PLV-4034 Inicio
		bo.createRecordControleIntegracaoBO(trigger.new);

		bo.updateStatusPagamentoDeSinistroBO(trigger.new);
		
		//PLV-4034 FDS
		bo.cancelRecordControleIntegracaoBO(trigger.new);  
		bo.cancelRecordPagamentoSinistro(trigger.new, (Map<Id,Pagamento_de_Sinistro__c>) Trigger.oldMap);
		//PLV-4034 FDS
		//PLV-4034 Fim
        //PLV-4604 - INICIO
        bo.updateOPSAPRequisicao(trigger.new, (Map<Id,Pagamento_de_Sinistro__c>) Trigger.oldMap);
        //PLV-4604 - FIM
        if(isFirstTime){//LECVP-344 - INICIO
            bo.atualizarValorPagoCaso(Trigger.new);
            bo.atualizarValorPagoGarantia(Trigger.new);         
            //bo.calcularSaldResrvCaso(Trigger.new); //LECVP-344 - INICIO/FIM
            //bo.calcularSaldResrvGarantia(Trigger.new); //LECVP-344 - INICIO/FIM
            isFirstTime = false;
        }//LECVP-344 - FIM
        
    }
     //PLV-4335 - Inicio
    public override void beforeInsert(){

        bo.atualizaAprovacaoPorValor(trigger.new);
        
    }
    //PLV-4335 - Fim
	/*public override void beforeUpdate(){
		//PLV-4034 Inicio
		bo.updateStatusPagamentoDeSinistroBO(trigger.new);
		//PLV-4034 Fim
    }*/

}