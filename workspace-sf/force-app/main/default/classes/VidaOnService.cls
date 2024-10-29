/*
@author Kevin Vogado - Globant
@date 26/06/2023
@Classe criada por conta da história VIDA-27
*/
public with sharing class VidaOnService extends ServiceBase {

    private static final VidaOnService instance = new VidaOnService();
    
    private VidaOnService() { }

    @TestVisible
    private Servico__mdt gerarTokenSensedia;

    @TestVisible
    private Servico__mdt consultaRendaVidaOn;
    
    @TestVisible
    private CredencialOAuth2__mdt sensedia;

    public static VidaOnService getInstance() {
        return instance;
    }

    public String buscaRendaVidaON() {

        String nomeEndPoint = 'Consulta_Renda_Vida_ON';
        String endpointToken = 'Token_Sensedia_AWS';
        String tokenSensedia = this.gerarTokenSensediaOAuth2('Sensedia', endpointToken); 
        System.debug('XXX - tokenSensedia: ' + tokenSensedia); 

        HttpResponse response = getRendas(nomeEndPoint, tokenSensedia); 
		List<RendaTO> rendas = new List<RendaTO>();
		
		String resposta = '';

		if (response.getStatusCode() == 200) {
			
			List<Object> jsonResponse = (List<Object>)JSON.deserializeUntyped(response.getBody());

			for (Object obj : jsonResponse) {
				Map<String, Object> jsonMap = (Map<String, Object>)obj;

				String codigo = (String)jsonMap.get('codigo');
				String descricao = (String)jsonMap.get('descricao');

				RendaTO renda = new RendaTO(codigo, descricao);
				rendas.add(renda);
			}

			resposta = JSON.serialize(rendas);
            System.debug('Rendas: ' + resposta);
		} else {
			System.debug('Erro na chamada da API: ' + response.getStatusCode() + ' ' + response.getStatus());
		}

		return resposta;
	}

    public String gerarTokenSensediaOAuth2(String nomeCredencial, String endpointToken) {
        try {

            String ACCESS_TOKEN_CACHE_KEY = nomeCredencial;
            Integer MAX_TTL_SECS = Cache.Org.MAX_TTL_SECS;
            Integer MIN_TTL_SECS = 300; // 5min

            String accessToken;
            Integer expiresIn;

            CredencialOAuth2__mdt credencialOAuth2 = buscaCredencial(nomeCredencial);
                    
            if (Cache.Org.contains(ACCESS_TOKEN_CACHE_KEY)) {

                System.debug('Token já existe no cache da plataforma, use-o');
                accessToken = (String)Cache.Org.get(ACCESS_TOKEN_CACHE_KEY);
            }else{

                HttpResponse response = getToken(endpointToken, credencialOAuth2);
                system.debug('response ' + response.getBody());

                if (response.getStatusCode() < 400) {

                    TokenApiVidaOn tokenApi = new TokenApiVidaOn(response.getBody());
                    accessToken = tokenApi.token_type + ' ' + tokenApi.access_token;
                    expiresIn = tokenApi.expires_in;

                    expiresIn = (expiresIn < MIN_TTL_SECS) ? MIN_TTL_SECS : expiresIn;
                    expiresIn = (expiresIn > MAX_TTL_SECS) ? MAX_TTL_SECS : expiresIn;
                }else {
                    String mensagemErro = 'ERROR HTTP ' + response.getStatusCode() + ' ERROR MESSAGE ' + response.getBody();
                    System.debug(mensagemErro);
                    throw new VidaOnServiceException(mensagemErro);
                }
                Cache.Org.put(ACCESS_TOKEN_CACHE_KEY, accessToken, expiresIn);
            }  
            
           
            System.debug('::: accessToken: ' + accessToken);
            return accessToken;
                
        }catch(Exception e) {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new VidaOnServiceException('Erro ao recuperar o token.' + e.getMessage());
        }
    }

    public HttpResponse getRendas(String nomeEndpoint, String tokenSensedia){
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String endpointVida = this.gerarEndpointVida(nomeEndPoint);
        
        Http http = new Http();

        request.setEndpoint(endpointVida);
        request.setMethod('GET');
        request.setTimeout(3600);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', tokenSensedia);

        try{
            if(Test.isRunningTest()){
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setHeader('Content-Type', 'application/json');
                response.setBody('[{"codigo": "8000", "descricao": "R$ 4.000,01 a R$ 8.000,00"}, '
                            + '{"codigo": "4000", "descricao": "Até R$ 4.000,00"}, '
                            + '{"codigo": "12000", "descricao": "R$ 8.000,01 a R$ 12.000,00"}, '
                            + '{"codigo": "16000", "descricao": "R$ 12.000,01 a R$ 16.000,00"}, '
                            + '{"codigo": "20000", "descricao": "R$ 16.000,01 a R$ 20.000,00"}, '
                            + '{"codigo": "39000", "descricao": "Acima de R$ 20.000,00"}]');
            }else{
                response = http.send(request);
            }
        }catch(Exception e){  
            response.setBody(e.getMessage());
        }

        return response;

    }

    public HttpResponse getToken(String nomeEndPoint, CredencialOAuth2__mdt credencialOAuth2){

        String endpointToken = this.gerarEndpointVida(nomeEndPoint);

        String auth = EncodingUtil.base64Encode(Blob.valueof(credencialOAuth2.ClientId__c + ':' + credencialOAuth2.ClientSecret__c));

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();

        String payload = '{"grant_type":"client_credentials"}';

        request.setEndpoint(endpointToken);
        request.setMethod('POST');
        request.setBody(payload);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic ' + auth);

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
            response.setBody(e.getMessage());
        }

        return response;
    }

    public String gerarEndpointVida(String nomeServico) {
		Servico__mdt servico =  buscarServico(nomeServico);
		String endpoint =  String.isNotBlank(servico.Endpoint__c) ? servico.Endpoint__c : '';
		return System.Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint' : servico.NomeCredencial__c + endpoint;
	}

    public class TokenApiVidaOn {

        public String access_token {get; set;}
        public String token_type {get; set;}
        public Integer expires_in {get; set;}
        public String scope {get; set;}
    
        public TokenApiVidaOn(String json) {
            TokenApiVidaOn tokenObj = (TokenApiVidaOn) System.JSON.deserialize(json, TokenApiVidaOn.class);
            access_token = tokenObj.access_token;
            token_type = tokenObj.token_type;
            expires_in = tokenObj.expires_in;
            scope = tokenObj.scope;
        }
    }

    public class RendaTO {
		public String codigo { get; set; }
		public String descricao { get; set; }
	
		public RendaTO(String codigo, String descricao) {
			this.codigo = codigo;
			this.descricao = descricao;
		}
	}

    public Servico__mdt buscarServico(String nomeServico) {

        if (gerarTokenSensedia != null) {
            return gerarTokenSensedia;
        }
        
        return [
            SELECT NomeCredencial__c, NomeToken__c, Endpoint__c
            FROM Servico__mdt
            WHERE DeveloperName =: nomeServico
            LIMIT 1
        ];
    }

    public CredencialOAuth2__mdt buscaCredencial(String nomeCredencial) {

        if (sensedia != null) {
            return sensedia;
        }

        return [
            SELECT
                Audience__c,
                ClientId__c,
                ClientSecret__c,
                GrantType__c,
                Status__c
            FROM
                CredencialOAuth2__mdt
            WHERE
                DeveloperName =: nomeCredencial
            LIMIT 1
        ];
    }

    public class VidaOnServiceException extends Exception{}

}