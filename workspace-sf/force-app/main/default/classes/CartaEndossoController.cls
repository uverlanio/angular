//INICIO | PLV-4452-VI (Digital)
/*
*  @author Squad Avanxo 
*  @Descrição: Controller CartaEndosso
*/
public class CartaEndossoController {

    public Contract contrato {get;set;}
    public String errorMessage {get;set;}

    public CartaEndossoController(){
        this.getContrato();
    }

    private void getContrato(){
        String numeroContrato = ApexPages.currentPage().getParameters().get('numeroContrato'); 
        if(!string.isBlank(numeroContrato)){
            try{
                this.contrato = [SELECT Id, Account.Name FROM Contract WHERE Name =: numeroContrato];
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
                this.contrato = [SELECT Id, Account.Name FROM Contract WHERE Id =: Id.valueof(trataChave[0])];
            }
            catch(Exception ex){
                this.errorMessage = 'Token inválido';
            }
        }
    }
}
//FIM | PLV-4452-VI (Digital)