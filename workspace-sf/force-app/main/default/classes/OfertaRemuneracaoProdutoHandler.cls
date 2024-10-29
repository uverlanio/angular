public class OfertaRemuneracaoProdutoHandler extends TriggerHandler  {

    private List<OfertaRemuneracaoProduto__c> listORPNew {get;set;}
    private List<OfertaRemuneracaoProduto__c> listORPOld {get;set;}
    private Map<Id,OfertaRemuneracaoProduto__c> mapORPNew {get;set;}
    private Map<Id,OfertaRemuneracaoProduto__c> mapORPOld {get;set;}

    public OfertaRemuneracaoProdutoHandler() {

        this.listORPNew = (List<OfertaRemuneracaoProduto__c>) Trigger.new;
        this.listORPOld = (List<OfertaRemuneracaoProduto__c>) Trigger.old;
        this.mapORPNew = (Map<Id,OfertaRemuneracaoProduto__c>) Trigger.newMap;
        this.mapORPOld = (Map<Id,OfertaRemuneracaoProduto__c>) Trigger.oldMap;
    }
    
    public override void beforeDelete(){
        this.impedeDelRemuneracaoObrigatoria();
    }
    
    private void impedeDelRemuneracaoObrigatoria(){
        
        List<String> rpIdList = new List<String>();
        for(OfertaRemuneracaoProduto__c orp : listORPOld) rpIdList.add(orp.RemuneracaoProduto__c);
            
        Map<Id,RemuneracaoProduto__c> mapRP = new Map<Id,RemuneracaoProduto__c>([
            SELECT Id, Obrigatoria__c FROM RemuneracaoProduto__c WHERE Id IN :rpIdList
        ]);
        
        for(OfertaRemuneracaoProduto__c orp : listORPOld){
            if(mapRP.get(orp.RemuneracaoProduto__c).Obrigatoria__c) orp.addError('Oferta de remuneração obrigatória não pode ser excluida.');
        }
    }

}