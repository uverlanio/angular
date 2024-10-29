//ANNVI-208 - INICIO
public with sharing class MulesoftServices extends ServiceBase {
    public enum VERB {
        GET,
        POST
    }

    /*############################################################################################
      ##            NOVOS DOMINIOS MULESOFT DEVEM SER INSERIDOS ABAIXO.                         ##
      ############################################################################################*/

    public enum DOMAIN{
        AWS_EXTERNO,
        AWS_INTERNO
    }

    private static final String CLASS_NAME = 'MulesoftServices';
    
    @TestVisible
    private Servico__mdt gerarTokenMulesoft;
    
    @TestVisible
    private CredencialOAuth2__mdt mulesoft;

    private static final MulesoftServices instance = new MulesoftServices();
    public static MulesoftServices getInstance() {
        return instance;
    } 

    public String selectDomain(String prefix){
    
        String prefixSelected;

        for(Dominios_Mulesoft__mdt domain : [ SELECT Endpoint__c, Nome_credencial__c, Label, DeveloperName FROM Dominios_Mulesoft__mdt WHERE DeveloperName =: prefix LIMIT 1]){
            prefixSelected = domain.Endpoint__c;
        }

        return prefixSelected;
    }

    public String selectEndpoint(String service){
       
        String endPointSelected;

        for(Servico__mdt domain : [SELECT NomeCredencial__c, NomeToken__c, Endpoint__c FROM Servico__mdt WHERE DeveloperName =: service LIMIT 1]){
            endPointSelected = domain.Endpoint__c;
        }

        return endPointSelected;
    }

    public String getAccessToken(String selectDomain, String selectEndpoint) {

        HttpResponse httpResponse = getTokenMulesoft(selectDomain, selectEndpoint);
        
        String accessToken = null;
    
        if (httpResponse.getStatusCode() == 200) {
            
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
    
            if (jsonResponse.containsKey('access_token')) {

                accessToken = 'Bearer ' + (String) jsonResponse.get('access_token');
            }
        }

        return accessToken;
    }

    public HttpResponse getTokenMulesoft(String selectDomain, String selectEndpoint){

        CredencialOAuth2__mdt credencialOAuth2 = this.buscarCredencial('Mulesoft');
        String prefixo = this.selectDomain(selectDomain);
        String url = this.selectEndpoint(selectEndpoint);
        String endpoint = prefixo + url;
        
        if(url.contains('token')){
            endpoint = url;
        }

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        
        request.setEndpoint(endpoint);
        request.setMethod(MulesoftServices.VERB.POST.toString());
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String payload = 'client_id='+EncodingUtil.urlEncode(credencialOAuth2.ClientId__c,'UTF-8')+
                         '&client_secret='+EncodingUtil.urlEncode(credencialOAuth2.ClientSecret__c,'UTF-8')+
                         '&username='+credencialOAuth2.Username__c+
                         '&password='+credencialOAuth2.Password__c+
                         '&grant_type='+credencialOAuth2.GrantType__c;

        request.setBody(payload);

        try{
            if(Test.isRunningTest()){
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"00000000-0000-0000-0000-000000000000","expires_in":3600,"token_type":"Basic"}'); 
            }else{
                response = http.send(request);
                System.debug('Response >'+ response);
            }
        }catch(Exception e){  
            response.setBody('Erro de conexão com o Mulesoft');
        }

        return response;
    }

    /*############################################################################################
      ##            NOVOS SERVIÇOS Mulesoft DEVEM SER INSERIDOS ABAIXO.                         ##
      ############################################################################################*/

      public static final String CONSULTA_DADOS_BCP = 'Consulta_Dados_BCP_Mulesoft';
      public static final String MULESOFT_TOKEN = 'Token_Mulesoft';

      public String consultarDadosBCP(String numDocumento) {
        String prefixo = this.selectDomain(MulesoftServices.DOMAIN.AWS_EXTERNO.toString());
        String url = this.selectEndpoint(CONSULTA_DADOS_BCP);
        String token = this.getAccessToken(MulesoftServices.DOMAIN.AWS_EXTERNO.toString(), MULESOFT_TOKEN);
        String endpoint = prefixo + url +'?numDocumento='+ numDocumento;

        String responsenew;
		String nomeEndpoint = CONSULTA_DADOS_BCP;
		HttpResponse resposta;

		try {
            Map<String, String> mapHeader = this.gerarHeaderOAuth2(token);
			resposta = Util.executarHttpRequest(endpoint, MulesoftServices.VERB.GET.toString(), mapHeader , null , 60000);
			System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

			if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				responsenew = resposta.getBody();
			}
			else {
				responsenew = resposta.getBody();
			}
		}
		catch (Exception e) {
			System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
			throw new MulesoftServicesException(e.getMessage());
		}

		return responsenew; 
	}

    public String chamarServico(MulesoftServices.VERB verboHTTP, MulesoftServices.DOMAIN dominio, String servico, String body) {

        String verbo = verboHTTP.toString();
        String servicoDominio = dominio.toString();

        String prefixo = this.selectDomain(servicoDominio);                              
        String url = this.selectEndpoint(servico);                            
        String token = this.getAccessToken(servicoDominio, MULESOFT_TOKEN); 
        String endpoint = prefixo + url;
        
        String retorno;                                             
        
        try {   

            HttpResponse resposta;
            resposta = Util.executarHttpRequest(endpoint, verbo, this.gerarHeaderOAuth2(token), body, 120000);

			if(resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				retorno = resposta.getBody();
			} else {
                retorno = 'Erro na requisição';
			}
            
        } catch (Exception e) {
            throw new MulesoftServicesException(e.getMessage());
        }
        System.debug('retorno ' + retorno);
        return retorno;
    }

    public class MulesoftServicesException extends Exception{}
}
//ANNVI-208 - FIM