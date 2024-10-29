/**
 * Created by Alessandro Ponte on 02/11/2018.
 */

public with sharing class ParceiroTriggerHandler extends TriggerHandler {
    private static ParceiroBO bo = ParceiroBO.getInstance();

    public override void afterInsert() {
        bo.geracaoNumeroApolice(Trigger.new);
    }

}