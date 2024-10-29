//INICIO | PLV-2233-27-v2
public with sharing class NotaFiscalTriggerHandler extends TriggerHandler {

    public override void afterInsert(){
        executeFutureMethod(JSON.serialize(trigger.new));
    }

    public override void afterUpdate(){
        executeFutureMethod(JSON.serialize(trigger.new));
    }
    
    public static void executeFutureMethod(String json){
        String jsonParameter = json;
        NotaFiscalBO.atualizaPagamento(jsonParameter);
    }
}
//FIM | PLV-2233-27-v2