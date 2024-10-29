public class APITokenizacaoService { //RVI-262  e RVI-223- INCIO
    
    HttpRequest request = new HttpRequest();
    Http http = new Http();
    HttpResponse response = new HttpResponse();

    public HttpResponse getToken(API_Link_de_Pagamento__mdt metadados){            

        String authorization = EncodingUtil.base64Encode(Blob.valueof(metadados.client_id__c + ':' + metadados.secret_id__c));

        String payload = '{"grant_type":"client_credentials"}';
        request.setEndpoint(metadados.token_url__c);
        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic '+ authorization);         

        request.setBody(payload);

            try{
                if(Test.isRunningTest()){
                     response = APTlmkPgtoCartaoCreditoCalloutMock.gerarTokenMock();
                }else{
                     response = http.send(request);
                }
            }catch(Exception e){  
                response.setBody(e.getMessage());
            }
            return response;
    }

    public HttpResponse getLinkPgtoCartaoCredito(String json, API_Link_de_Pagamento__mdt metadados, TokenApiLinkPgtoCartaoCredito tokenApiLinkPgtoCartaoCredito){

        String token = tokenApiLinkPgtoCartaoCredito.token_type + ' ' + tokenApiLinkPgtoCartaoCredito.access_token;

        request.setHeader('Authorization', token);
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(metadados.endpoint__c); //RVI-294
        request.setMethod('POST');
        request.setBody(json);
        request.setTimeout(Integer.valueOf(metadados.timeOut__c));

        try{  
            if(Test.isRunningTest()){          
                response = APTlmkPgtoCartaoCreditoCalloutMock.gerarLinkMock();
            }else{
                response = http.send(request);                
            }            
        }catch(Exception e){
            throw new GerarLinkException('Não foi possível gerar o link: ' + e.getMessage());
        }        
        return response;
    }

    public class GerarLinkException extends Exception{}

}//RVI-262  e RVI-223- FIM