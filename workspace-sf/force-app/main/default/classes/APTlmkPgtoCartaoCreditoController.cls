/*
@description Gera link de pagamento é uma funcionalidade que permite o envio de um link para que o cliente
@author Uverlanio Pereira - Globant
@date 05/09/2022
@Classe criada por conta da história TKCL-263
*/
@RestResource(urlMapping='/aptlmk/api')
global with sharing class APTlmkPgtoCartaoCreditoController {
    
    @HttpPost
    global static String getLinkPagtoCartaoCredito(){

        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        API_Link_de_Pagamento__mdt metadados = MetadataDAO.getInstance().apiLinkDePgto('API_Link_de_Pagamento'); //RVI-294
        APTlmkGeraLinkPgtoCartaoCreditoService service = new APTlmkGeraLinkPgtoCartaoCreditoService();
  
        HttpRequest request = new HttpRequest();
        Http http = new Http();

        HttpResponse tokenResponse = service.getToken(metadados);
        String tokenMensagem = '';

        if(tokenResponse != null &&
             tokenResponse.getStatusCode() != null &&
              tokenResponse.getStatusCode() != 200){                
            restResponse.statusCode = tokenResponse.getStatusCode();
            tokenMensagem = tokenResponse.getBody();
            return tokenMensagem;
        }else{
            restResponse.statusCode = 401;
            tokenResponse.setStatusCode(401);
            tokenMensagem = 'Credenciais inválidas';
        }            

        TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito = new TokenApiLinkPgtoCartaoCredito(tokenResponse.getBody());
        HttpResponse urlResponse = new HttpResponse();
        
        String jsonRequest = restRequest.requestBody.toString();        

        try{
            urlResponse = service.getLinkPgtoCartaoCredito(
                jsonRequest, metadados, tokenApiLinkPgtoCartaoCredito);

                if(urlResponse != null){
                    if(urlResponse.getStatusCode() == 200) {
                        restResponse.statusCode = 200;
                        urlResponse.setStatusCode(200);                              
                    }

                    String retornoLinkPgtoCartaoCredito = urlResponse.getBody();
                    if(retornoLinkPgtoCartaoCredito.contains('Dados inválidos') ||
                        retornoLinkPgtoCartaoCredito.contains('Revise o corpo da sua requisição')){               
                        restResponse.statusCode = 400;
                        urlResponse.setStatusCode(400);
                    }else{
                        retornoLinkPgtoCartaoCredito = '';
                    }
                }
        }catch(Exception e){
            urlResponse.setBody(e.getMessage());            
        }        
        return urlResponse.getBody();
    }
}