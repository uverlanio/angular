public class FranquiaGarantiaTriggerHandler extends TriggerHandler {
    private static FranquiaGarantiaBO bo = FranquiaGarantiaBO.getInstance();
    
    //PLV 4282 - INICIO
    private List<FranquiaGarantia__c> listFGNew {get;set;}
    private List<FranquiaGarantia__c> listFGOld {get;set;}
    private Map<Id,FranquiaGarantia__c> mapFGNew {get;set;}
    private Map<Id,FranquiaGarantia__c> mapFGOld {get;set;}
    
    public FranquiaGarantiaTriggerHandler() {
        
        this.listFGNew = (List<FranquiaGarantia__c>) Trigger.new;
        this.listFGOld = (List<FranquiaGarantia__c>) Trigger.old;
        this.mapFGNew = (Map<Id,FranquiaGarantia__c>) Trigger.newMap;
        this.mapFGOld = (Map<Id,FranquiaGarantia__c>) Trigger.oldMap;
    }
    //PLV 4282 - FIM
    
    public override void beforeUpdate() {
        //PLV-4106 - Início
        //bo.validarPermissaoEdicaoExclusaoItemProdutoComercial(trigger.new);
        //PLV-4106 - Fim
        this.validarPadrao();//PLV - 4282 INICIO / FIM        
    }	
    
    public override void beforeDelete() {
        //PLV-4106 - Início
        //bo.validarPermissaoEdicaoExclusaoItemProdutoComercial(trigger.old);
        bo.bloquearExclusaoProdutoComercial(trigger.old);
        //PLV-4106 - Fim
    }   
    
    //PLV 4282 - INICIO
    public override void afterInsert() {
        
        this.validarPadrao();   
        
    }
    
    public void validarPadrao(){
        
        
        system.debug('validando padrão');
        if(listFGNew.size() == 1){
            Set<id> getIdGarantia = new Set<Id>();
            List<FranquiaGarantia__c> lGarantiaFranquia = new List<FranquiaGarantia__c>();
            
            lGarantiaFranquia = [SELECT Id, Franquia_Padrao__c
                                 FROM FranquiaGarantia__c 
                                 WHERE GarantiaProduto__c =: mapFGNew.values().GarantiaProduto__c];
            
            for(FranquiaGarantia__c fg: lGarantiaFranquia){
                if(fg.Id != mapFGNew.values().Id){
                    if(mapFGNew.values().Franquia_Padrao__c){
                        if(fg.Franquia_Padrao__c ){
                            if(fg.id !=mapFGNew.values().Id && fg.Franquia_Padrao__c){
                                system.debug('Id da franquia: '+fg.id);
                                system.debug('É Franquia_Padrao__c: '+fg.Franquia_Padrao__c);
                                FranquiaGarantia__c franquia = mapFGNew.values();
                                franquia.addError('É possível marcar somente uma franquia padrão por garantia');
                            }
                        }
                    }
                }                
            }           
        }else{
            Integer count = 0;
            Set<Id> getGarantiaProduto = new Set<Id>();
            
            for(FranquiaGarantia__c f: listFGNew){
                getGarantiaProduto.add(f.garantiaProduto__c);
            }
            
            List<FranquiaGarantia__c> franquiasExistentes = new List<FranquiaGarantia__c>();
            
            franquiasExistentes = [SELECT Id, Franquia_Padrao__c, garantiaProduto__c
                                   FROM FranquiaGarantia__c 
                                   WHERE GarantiaProduto__c IN: getGarantiaProduto];
            if(franquiasExistentes.size() > 0){
                for(FranquiaGarantia__c fe: franquiasExistentes){
                    for(FranquiaGarantia__c fg: listFGNew){
                        if(fe.GarantiaProduto__c == fg.GarantiaProduto__c){
                            if(fe.Franquia_Padrao__c){
                                if(fg.Franquia_Padrao__c){
                                    count ++;
                                }
                            }                    
                        }
                        if(count > 1){
                            FranquiaGarantia__c franquia = fg;
                            franquia.addError('É possível marcar somente uma franquia padrão por garantia');  
                        }
                    } 
                }            
            }
        }
    }
    //PLV 4282 - FIM
    
}