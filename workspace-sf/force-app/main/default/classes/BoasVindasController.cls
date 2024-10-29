//INICIO | PLV-4566
/*
*  @author Squad Avanxo 
*  @Descrição: Controller do componente BoasVindas
*/
public class BoasVindasController {
    public Contract contrato {get;set;}
    public FavorecidoRemuneracaoContrato__c corretor {get;set;}
    public Id assignedContratoId {
        get;
        set{
            if(value != null){
                contrato = [SELECT Id, Account.Name, Account.NomeSocial__c, Account.PersonEmail, Account.PersonMobilePhone, NumeroApolice__c, ApolicePdfDownloadUrl__c,Senha__c, DistributionPublicUrl__c,  (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR') FROM Contract WHERE Id =: value]; // MGRC-635 INICIO-FIM && LECVPV 189-FIX02
                if(contrato.RemuneracoesContrato__r.size() > 0){
                    corretor = [SELECT Id, Conta__r.Name, Conta__r.Phone, Conta__r.Email__c FROM FavorecidoRemuneracaoContrato__c
                                WHERE RemuneracaoContrato__c = : contrato.RemuneracoesContrato__r[0].Id AND CorretorLider__c = true];
                }
            }
        }
    }
      
}
//FIM | PLV-4566