/**
 * @author AVX - Leonardo Camacho
 * @date 2019-12-27
 * @description: Classe que contém a lógica para o objeto LimiteGarantiaProduto__c
 * Criada para a história PLV_3046
 */
public class LimiteGarantiaProdutoTriggerHandler extends TriggerHandler{

    private List<LimiteGarantiaProduto__c> listaLimiteGPOld {get;set;}
    private List<LimiteGarantiaProduto__c> listaLimiteGPNew {get;set;}
    private Map<Id, LimiteGarantiaProduto__c> mapLimiteGPOld {get;set;}
    private map<Id, LimiteGarantiaProduto__c> mapLimiteGPNew {get;set;}

    public LimiteGarantiaProdutoTriggerHandler(){
        this.listaLimiteGPOld = (List<LimiteGarantiaProduto__c>) Trigger.old;
        this.listaLimiteGPNew = (List<LimiteGarantiaProduto__c>) Trigger.new;
        this.mapLimiteGPOld = (Map<Id, LimiteGarantiaProduto__c>) Trigger.oldMap;
        this.mapLimiteGPNew = (Map<Id, LimiteGarantiaProduto__c>) Trigger.newMap;
    }

    public override void beforeInsert(){
        this.validaRegistroMoedaDuplicada();
    }

    public override void beforeUpdate(){
        this.validaRegistroMoedaDuplicada();
    }

    public void validaRegistroMoedaDuplicada(){

        set<Id> setGarantiaProduto = new Set<Id>();
  
        for(LimiteGarantiaProduto__c limiteObj : this.listaLimiteGPNew){
            setGarantiaProduto.add(limiteObj.garantiaProduto__c);
        }
        
        Map<Id, GarantiaProduto__c> mapGarantiaProduto = new Map<Id, GarantiaProduto__c>(
                                                        [SELECT id, (SELECT id, garantiaProduto__c, CurrencyIsoCode 
                                                                     FROM limitesGarantiaProduto__r)
                                                        FROM garantiaProduto__c
                                                        WHERE id IN : setGarantiaProduto]);

        
        if(mapGarantiaProduto.IsEmpty()) return;

        for(limiteGarantiaProduto__c limiteGPNew : listaLimiteGPNew){
            if(!mapGarantiaProduto.containsKey(limiteGPNew.garantiaProduto__c)) continue;

            GarantiaProduto__c garantiaProdutoObj = mapGarantiaProduto.get(limiteGPNew.garantiaProduto__c);

            for(limiteGarantiaProduto__c limiteObj : garantiaProdutoObj.limitesGarantiaProduto__r){

                if(Trigger.IsUpdate && mapLimiteGPOld.containsKey(limiteObj.id) && (!TriggerHelper.isChanged(limiteObj, 'CurrencyIsoCode'))) continue;

                if(limiteObj.currencyIsoCode == limiteGPNew.currencyIsoCode){
                    limiteGPNew.currencyIsoCode.addError('Existe um limite de garantia cadastrado com a moeda escolhida. Por favor, selecione uma moeda diferente');
                }
            }
        }
    }
}