public class BeneficiarioGarantiaTriggerHandler extends TriggerHandler {
	private static BeneficiarioGarantiaBO bo = BeneficiarioGarantiaBO.getInstance();
    public static Boolean isFirstTime = true;
    public static Boolean criarMovimento = true;//PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
    public static PepBO pep = PepBO.getInstance(); //INICIO/FIM LECVPV-218

    public override void beforeInsert(){
        bo.preencherIdExterno(Trigger.new);
        
        String message = bo.validaTotalIndenizacao(Trigger.new);
        if(message == 'O valor Indenizado é maior que o Saldo da reserva!'){
            Trigger.new[0].addError(message);
        }
        //PLV-2403 - Inicio - Foi criado para chamar o metódo da Classe BeneficiarioGarantiaBO
        bo.atualizavalorindenizacao(Trigger.new, (Map<Id,BeneficiarioGarantia__c>) Trigger.oldMap);
        //PLV-2403 - Fim - Foi criado para chamar o metódo da Classe BeneficiarioGarantiaBO        
    }  

    public override void afterUpdate(){
        if(!Test.IsRunningTest()){
            if (isFirstTime)
                bo.efetuaPagamento(Trigger.new, (Map<Id,BeneficiarioGarantia__c>) Trigger.oldMap);
        }else{
            bo.efetuaPagamento(Trigger.new, (Map<Id,BeneficiarioGarantia__c>) Trigger.oldMap);
        }
        //PLV-4818 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        if(criarMovimento)
            bo.criaMovimentoDeSinistro(Trigger.new, (Map<Id,BeneficiarioGarantia__c>) Trigger.oldMap);    
        //PLV-4818 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    }

    //PLV-2403 - Inicio - Foi criado para chamar o metódo da Classe BeneficiarioGarantiaBO
    public override void beforeUpdate(){ 

        String message = bo.validaTotalIndenizacao(Trigger.new);
        if(message == 'O valor Indenizado é maior que o Saldo da reserva!'){
            Trigger.new[0].addError(message);
        }

        if(isFirstTime) //PLV-4448 - INICIO/FIM
            bo.atualizavalorindenizacao(Trigger.new, (Map<Id,BeneficiarioGarantia__c>) Trigger.oldMap);
        //PLV-2403 - Fim - Foi criado para chamar o metódo da Classe BeneficiarioGarantiaBO
    }
    //INICIO - LECVPV-218-V1
    public override void afterInsert(){ 
        pep.getListObjectPep(Trigger.new); 
    }
    //FIM - LECVPV-218-V1
}