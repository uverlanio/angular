/**
 * @author Isabela (Globant) & Jeferson (Sys4B)
 * @date 2020-03-28
 * @description RestECM
 * Classe criada por conta da história PLV-3413
 */
public class RestECM {   
    public static retornoECMArquivo conectaECM(){
        retornoECMArquivo objRetorno;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Servico__mdt servico = MetadataDAO.getInstance().buscarServico('ECMAUTH');
        request.setEndpoint('callout:PortoSeguroECM'+servico.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body = 'username={!$Credential.Username}&password={!$Credential.Password}';
        request.setBody(body);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
             objRetorno = (retornoECMArquivo)System.JSON.deserialize(response.getBody(),retornoECMArquivo.class);
             System.debug(objRetorno);
        } else {
            System.debug('Erro: ' + response.getStatusCode() + ' ' + response.getStatus());
             objRetorno = (retornoECMArquivo)System.JSON.deserialize(response.getBody(),retornoECMArquivo.class);
        }
		return objRetorno;
    }
           
    public class retornoECMArquivo{
        String error{get;set;}
        string sucesso{get;set;}
        string ticket{get;set;}
    }
    
    public static HttpResponse buscarArquivoECM(String identificador){
        retornoECMArquivo ch = conectaECM();
        Servico__mdt servico = MetadataDAO.getInstance().buscarServico('ECMDOC');
        String endpoint = servico.Endpoint__c;
        endpoint = endpoint.replace('{{ID_ECM}}',identificador);
       
        if(ch.ticket != null && !String.isBlank(ch.ticket)){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:PortoSeguroECM'+endpoint);
            request.setMethod('GET');
            request.setHeader('OTCSTicket',ch.ticket);
            HttpResponse response = http.send(request);
            return response;
        }else{
            return null;
        }
    }
}