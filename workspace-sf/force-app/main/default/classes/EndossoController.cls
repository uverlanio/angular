//INICIO | PLV-4568
/*
*  @author Squad Avanxo 
*  @Descrição: Controller do componente Endossso
*/
public class EndossoController {
    public Contract contrato {get;set;}
    public Id assignedContratoId {
        get;
        set{
            if(value != null){
                contrato = [SELECT Id, Account.Name, Account.NomeSocial__c, EndossoPdfDownloadUrl__c, Senha__c, DistributionPublicUrl__c FROM Contract WHERE Id =: value];  // MGRC-635 INICIO-FIM & LECVPV 190-INICIO/FIM - LECVPV-188-FIX04 INICIO/FIM
            }
        }
    }
}
//FIM | PLV-4568