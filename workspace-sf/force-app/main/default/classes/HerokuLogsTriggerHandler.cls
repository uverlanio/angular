/**
 * Created by Alessandro Ponte on 16/07/2019.
 */
// PLV-2312 INICIO
public with sharing class HerokuLogsTriggerHandler extends TriggerHandler {
    public override void afterInsert(){
        QuoteBO.getInstance().logarHeroku(Trigger.new);
    }
}
// PLV-2312 FIM