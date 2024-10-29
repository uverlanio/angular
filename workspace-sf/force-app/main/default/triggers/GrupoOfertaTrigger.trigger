/****
@description Trigger para evitar criação de grupos de oferta com o mesmo numero
@author Isabela Fin - Globant
@date 28/07/2020
-Trigger criada por conta da historia PLV-4100    
*****/
trigger GrupoOfertaTrigger on GrupoOferta__c (before insert, before update) {    
    List<GrupoOferta__c> grupoNew = new List<GrupoOferta__c>();
    
    if(Trigger.isUpdate) {
        for(GrupoOferta__c grupo :trigger.new) {
            if(TriggerHelper.isChanged(grupo,'Numero__c')) {
                grupoNew.add(grupo);
            }
        }	        
    }
    else {
    	grupoNew = trigger.new;
    }
    
    if(grupoNew.isEmpty()) return;
    
    Set<Id> ofertaId = new Set<Id>();
    Map<Id, Set<Decimal>> ofertaGrupoMap = new Map<Id, Set<Decimal>>();
    
    for(GrupoOferta__c go :grupoNew) {
        if(go.Oferta__c == null || go.Numero__c == null) continue;
        if(ofertaGrupoMap.containsKey(go.Oferta__c)) {
            if(ofertaGrupoMap.get(go.Oferta__c).contains(go.Numero__c)) {
                System.debug('erro 1');
                go.Numero__c.addError('Este número já foi cadastrado em outro grupo. Favor utilizar outro.');
                return;
            }
            else{
                ofertaGrupoMap.get(go.Oferta__c).add(go.Numero__c);
            }
        }
        else{
            ofertaGrupoMap.put(go.Oferta__c, new Set<Decimal>{go.Numero__c});	
        }
    }    
    ofertaGrupoMap.clear();
    
    for(GrupoOferta__c go :grupoNew) {
        if(go.Oferta__c != null) {
            ofertaGrupoMap.put(go.Oferta__c, new Set<Decimal>());
        }
    }
    
    if(ofertaGrupoMap.isEmpty()) return;
    
    for(GrupoOferta__c go :[SELECT Id, Numero__c, Oferta__c FROM GrupoOferta__c WHERE Oferta__c = :ofertaGrupoMap.keySet()]) {
        ofertaGrupoMap.get(go.Oferta__c).add(go.Numero__c);
    }
    
    for(GrupoOferta__c go :grupoNew) {
        Set<Decimal> goSet = ofertaGrupoMap.get(go.Oferta__c);
        if(goSet.contains(go.Numero__c) && go.Numero__c != null) {
            System.debug('erro 2');
            go.Numero__c.addError('Este número já foi cadastrado em outro grupo. Favor utilizar outro.');
        } 
    }
}