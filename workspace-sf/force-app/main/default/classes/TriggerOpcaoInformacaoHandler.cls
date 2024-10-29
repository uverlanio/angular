/*********************************************************************************************************************************************************************
@description  Utilizada para dar apoio ao trigger.
@author Carlos Pessoa - META
@date 12/05/2021
@Classe criada por conta da história PLV-4946    
**********************************************************************************************************************************************************************/

public class TriggerOpcaoInformacaoHandler {
    public TriggerOpcaoInformacaoHandler() {

    }

    public static void validaDefault(List<OpcaoInformacao__c> listOpcaoInformacao){
        Set<Id> listIdInformacaoOferta = new Set<Id>();
        for(OpcaoInformacao__c oi : listOpcaoInformacao){listIdInformacaoOferta.add(oi.InformacaoOferta__c);}
        List<OpcaoInformacao__c> listInformacaoOferta = [SELECT Id, Default__c, InformacaoOferta__c  FROM OpcaoInformacao__c WHERE InformacaoOferta__c IN: listIdInformacaoOferta];
        if(listInformacaoOferta.size() == 0)
            return;
        Map<Id, List<OpcaoInformacao__c>> mapInfoOpcoes = new Map<Id, List<OpcaoInformacao__c>>();
        
        for(OpcaoInformacao__c oi : listInformacaoOferta ){
            if(mapInfoOpcoes.get(oi.InformacaoOferta__c) == null){
                mapInfoOpcoes.put(oi.InformacaoOferta__c, new List<OpcaoInformacao__c>());
            }
            List<OpcaoInformacao__c> listOi = mapInfoOpcoes.get(oi.InformacaoOferta__c);
            listOi.add(oi);
            mapInfoOpcoes.put(oi.InformacaoOferta__c, listOi);
        }

        for(OpcaoInformacao__c opInfoBase : listOpcaoInformacao){
            Decimal qtdDefault = 0;
            if(opInfoBase.Default__c){
                qtdDefault++;
            }
            System.debug('karin ' + mapInfoOpcoes);
            for(OpcaoInformacao__c oi : mapInfoOpcoes.get(opInfoBase.InformacaoOferta__c)){
                if(oi.Default__c){
                    qtdDefault++;
                }
            }
            if(qtdDefault > 1){
                opInfoBase.addError('Já existe um registro com o campo Default marcado.');
            }
        }
    }
}