/*********************************************************************************************************************************************************************

@description  Classe para controlar a trigger "PerguntaTrigger".
@author Matheus Takata - Avanxo
@date 21/08/2019
@Classe criada por conta da história PLV-2578
        
**********************************************************************************************************************************************************************/

public class PerguntaTriggerHandler extends TriggerHandler {
	
    private static PerguntaBO bo = PerguntaBO.getInstance();
	
    public override void beforeInsert() {
        
        bo.preencherResumoPergunta(Trigger.new, null);
    }
    public override void beforeUpdate() {
        
        bo.preencherResumoPergunta(Trigger.new,(Map<Id,Pergunta__c>) Trigger.oldMap);
    }
    
    //PLV-2578 - Fim - Classe para controlar a trigger "PerguntaTrigger".
}