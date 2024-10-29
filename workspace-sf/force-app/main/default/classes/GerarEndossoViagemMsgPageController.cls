/********************************************************************************************************************
* Gerar Endosso Viagem Mensagem Controler
* @author Squad_Globant
* @date 28/06/2021
* Classe criada por conta da história PLV-5063
*********************************************************************************************************************/

public class GerarEndossoViagemMsgPageController {

    public String contrato          { get; set; }
    public String numeroContrato    { get; set; }    
    public String mensagem          { get; set; }


    public GerarEndossoViagemMsgPageController(ApexPages.StandardController controller) {
        contrato = ApexPages.currentPage().getParameters().get('idContrato');
        mensagem = ApexPages.currentPage().getParameters().get('mensagem');
        numeroContrato = ApexPages.currentPage().getParameters().get('numeroContrato');        
    }    

    public PageReference redirectEndossoViagem() {                                           
         
        PageReference retURL = Page.GerarEndossoViagem;               
        retURL.getParameters().put('idContrato',contrato);             
        retURL.setRedirect(true);          
        
        return retURL;
    }   
}