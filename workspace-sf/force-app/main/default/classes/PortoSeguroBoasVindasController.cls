//INICIO | PLV-4433-VI (Digital)
/*
*  @author Squad Avanxo 
*  @Descrição: Controller PortoSeguroBoasVindas
*/
public class PortoSeguroBoasVindasController {

    public Contract contrato {get;set;}
    public FavorecidoRemuneracaoContrato__c corretor {get;set;}
    public String errorMessage {get;set;}

    public PortoSeguroBoasVindasController(){
        this.getContrato();
        this.getCorretor();
    }

    private void getContrato(){
        String numeroContrato = ApexPages.currentPage().getParameters().get('numeroContrato'); 
        if(!string.isBlank(numeroContrato)){
            try{
                this.contrato = [SELECT Id, Account.Name, Account.PersonEmail, Account.PersonMobilePhone, NumeroApolice__c, (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR') FROM Contract WHERE Name =: numeroContrato];
            }
            catch(Exception ex){
                this.errorMessage = 'Número de contrato inválido';
            }
            
        }
        else{
            try{
                String token = ApexPages.currentPage().getParameters().get('token');
                token = token.replace(' ','+');
                CryptoToken c = new CryptoToken();                     
                String chaveDescript = c.decrypt(token);  
                String[] trataChave = chaveDescript.split('\\|');
                this.contrato = [SELECT Id, Account.Name, Account.PersonEmail, Account.PersonMobilePhone, NumeroApolice__c, (SELECT Id FROM RemuneracoesContrato__r WHERE TipoRemuneracao__r.Codigo__c = 'COR') FROM Contract WHERE Id =: Id.valueof(trataChave[0])];
            }
            catch(Exception ex){
                this.errorMessage = 'Token inválido';
            }
        }
    }

    private void getCorretor(){
        if(this.contrato != null && this.contrato.RemuneracoesContrato__r.size() > 0){
            this.corretor = [SELECT Id, Conta__r.Name, Conta__r.Phone, Conta__r.Email__c FROM FavorecidoRemuneracaoContrato__c
                        WHERE RemuneracaoContrato__c = : this.contrato.RemuneracoesContrato__r[0].Id AND CorretorLider__c = true];
        }
    }
}
//FIM | PLV-4433-VI (Digital)