public with sharing class GarantiaTriggerHandler extends TriggerHandler {
    private List<Garantia__c> listGarantiasNew;

    public GarantiaTriggerHandler() {
        this.listGarantiasNew = (List<Garantia__c>) Trigger.new;
    }
    public override void beforeInsert() {
        validarCampoTipoUnico();
    }
    public override void beforeUpdate() {
        validarCampoTipoUnico();
    }
    
    public void validarCampoTipoUnico() {
        for(Garantia__c garantia : listGarantiasNew){
            if(TriggerHelper.isChanged(garantia, 'Tipo__c') && garantia.Tipo__c.contains(';')){
                garantia.Tipo__c.addError('O campo de Tipo deve conter apenas uma opção selecionada');   
            }   
        }
    }
}