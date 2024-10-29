public with sharing class SensediaServices extends ServiceBase {
    //MGRC-1384 - INICIO
    public enum VERB {
        GET,
        POST,
        PUT
    }

    /*############################################################################################
      ##            NOVOS DOMINIOS SENSEDIA DEVEM SER INSERIDOS ABAIXO.                         ##
      ############################################################################################*/

    public enum DOMAIN{
        AWS_EXTERNO,
        AWS_EXTERNO_EMISSAO,
        AWS_INTERNO,
        ON_PREMISES_EXTERNO,
        ON_PREMISES_INTERNO
    }

    /*############################################################################################
      ##            NOVOS SERVIÇOS SENSEDIA DEVEM SER INSERIDOS ABAIXO.                         ##
      ############################################################################################*/

    public static final String ATUALIZACAO_MONETARIA = 'Atualizacao_Monetaria_Sensedia';
    public static final String AUTOMACAO_SF = 'AutomacaoSF_Sensedia';
    public static final String CIV_LIQUIDACAO = 'CIV_Liquidacao_Sensedia';
    public static final String COBRANCA_CARTAO_OFFLINE = 'Cobranca_Cartao_Offline_Sensedia';
    public static final String CONSULTA_BANCO = 'Consulta_Banco_Sensedia';
    public static final String CONSULTA_CPF_ATIVO_LTM = 'Consulta_CPF_Ativo_LTM_Sensedia';
    public static final String CONSULTA_CIV_TICKET_BCP = 'Consulta_Civ_Ticket_BCP_Sensedia';
    public static final String CONSULTA_ID_PORTO_PLUS = 'Consulta_Id_Porto_Plus_Sensedia';
    public static final String CONSULTA_NOME_SERASA = 'Consulta_Nome_Serasa_Sensedia';
    public static final String CONSULTA_PROFISSAO = 'Consulta_Profissao_Sensedia';
    public static final String CONSULTA_TICKET_BCP = 'Consulta_Ticket_BCP_Sensedia';
    public static final String CONSULTAR_DOCUMENTO = 'Consultar_Documento_Sensedia';
    public static final String CONSULTIVO_CONTRATACAO = 'Consultivo_Contratacao_Sensedia';
    public static final String CRIAR_ARQUIVO = 'CriarArquivo_Sensedia';
    public static final String DOCUSIGN = 'Docusign_Sensedia';
    public static final String SENSEDIA_TOKEN = 'Gerar_Token_Sensedia';
    public static final String GUIA_POSTAL = 'Guia_Postal_Sensedia';
    public static final String INCLUIR_PRODUTO_VIDA_OPIN = 'IncluirProdutoVidaOPIN_Sensedia';
    public static final String INTEGRACAO_AS = 'IntegracaoAS_Sensedia';
    public static final String INTEGRACAO_SAMPLEMED = 'Integracao_SampleMed_Sensedia';
    public static final String LIQUIDACAO = 'Liquidacao_Sensedia';
    public static final String NOVO_CARTAO = 'NovoCartao_Sensedia';
    public static final String OFERTAS_CANCELAMENTO_VIAGEM = 'Ofertas_Cancelamento_Viagem_Sensedia'; //MGRC-1509-INICIO/FIM
    public static final String OFERTAS_CONTRATACAO_VIAGEM = 'Ofertas_Contratacao_Viagem_Sensedia';
    public static final String PAISES = 'Paises_Sensedia';
    public static final String RECALCULO_PROPOSTA = 'RecalculoProposta_Sensedia';
    public static final String TRANSMISSAO_CANCELAMENTO_VIAGEM = 'Transmissao_Cancelamento_Viagem_Sensedia';
    public static final String TRANSMISSAO_CONTRATACAO_VIAGEM = 'Transmissao_Contratacao_Viagem_Sensedia';
    public static final String SENSEDIA_TOKEN_ON_PROMISE = 'Token_Sensedia_OnPremise';
    //MGRC-1489-INICIO
    public static final String OFERTAS_CONTRATACAO_VDSJ = 'Ofertas_Contratacao_VDSJ_Sensedia'; //MGRC-1506-INICIO/FIM
    public static final String OFERTAS_CONTRATACAO_APTLMKT = 'Ofertas_Contratacao_APTLMKT_Sensedia'; //MGRC-1507-INICIO/FIM
    public static final String OFERTAS_CONTRATACAO_VIDA_ON = 'Ofertas_Contratacao_Vida_ON_Sensedia'; //MGRC-1508-INICIO/FIM
    public static final String OFERTAS_CONTRATACAO_PERSONALIZADA_VDSJ = 'Ofertas_Contratacao_Person_VDSJ_Sensedia'; //MGRC-1519-INICIO/FIM
    
    public static final String OFERTAS_CONTRATACAO_ENDOSSO_VDSJ = 'Orcamento_Seguro_Endosso_VDSJ';    //MGRC-1516-INICIO/FIM
    public static final String OFERTAS_CONTRATACAO_ENDOSSO_APTLMK = 'Orcamento_Seguro_Endosso_APTLMK'; //MGRC-1517-INICIO/FIM
    public static final String OFERTAS_CONTRATACAO_ENDOSSO_VIDA_ON = 'Orcamento_Seguro_Endosso_Vida_ON'; //MGRC-1518-INICIO/FIM
    
    public static final String TRANSMISSAO_CANCELAMENTO_VDSJ = 'Transmissao_Seguro_Cancelamento_VDSJ'; //MGRC-1578-INICIO/FIM
    public static final String TRANSMISSAO_CANCELAMENTO_APTLMKT = 'Transmissao_Seguro_Cancelamento_APTLMKT'; //MGRC-1579-INICIO/FIM
    public static final String TRANSMISSAO_CANCELAMENTO_VIDA_ON = 'Transmissao_Seguro_Cancelamento_Vida_ON'; //MGRC-1580-INICIO/FIM

    public static final String TRANSMISSAO_CONTRATACAO_ENDOSSO_VDSJ = 'Transmissao_Seguro_Endosso_VDSJ'; //MGRC-1581-INICIO/FIM
    public static final String TRANSMISSAO_CONTRATACAO_ENDOSSO_APTLMKT = 'Transmissao_Seguro_Endosso_APTLMKT'; //MGRC-1582-INICIO/FIM
    public static final String TRANSMISSAO_CONTRATACAO_ENDOSSO_VIDA_ON = 'Transmissao_Seguro_Endosso_Vida_ON'; //MGRC-1583-INICIO/FIM

    public static final String TRANSMISSAO_CONTRATACAO_VDSJ = 'Transmissao_Seguro_Novo_VDSJ'; //MGRC-1584-INICIO/FIM
    public static final String TRANSMISSAO_CONTRATACAO_APTLMKT = 'Transmissao_Seguro_Novo_APTLMKT'; //MGRC-1585-INICIO/FIM
    public static final String TRANSMISSAO_CONTRATACAO_VIDA_ON = 'Transmissao_Seguro_Novo_Vida_ON'; //MGRC-1586-INICIO/FIM
    //MGRC-1489-FIM

    //MGRC-1271-INICIO
    public static final String GERAR_TOKEN_HEROKU = 'Gerar_Token_Heroku_Sensedia';
    //MGRC-1271-FIM

    public static final String VALIDAR_BLOQUEIO_BANCARIO = 'Validar_Bloqueio_Bancario_Sensedia'; //MGRC-1821-INICIO/FIM
    public static final String VALIDAR_COMPOSICAO_BANCARIA = 'Validar_Composicao_Bancaria_Sensedia'; //MGRC-1822-INICIO/FIM

    public static final String SOLICITACAO_PAGAMENTO_PIX = 'Pix_Solicitacao_Pagamento'; //FCVEP-33

    public static final String PEP_CPF = 'PEP_CPF';
    public List<Object> params;
    //MGRC-1384 - FIM
//ZSVEP-66 - INICIO
    private static final String CLASS_NAME = 'SensediaServices';
    
    @TestVisible
    private Servico__mdt gerarTokenSensedia;
    
    @TestVisible
    private CredencialOAuth2__mdt sensedia;

    private static final SensediaServices instance = new SensediaServices();
    public static SensediaServices getInstance() {
        return instance;
    }    

    SensediaServices(){
        System.debug('INICIALIZADA A CLASSE SENSEDIA SERVICES - 2024');
    }

    //FNPVVEP-99 - INICIO
    @AuraEnabled(cacheable=true)
    public static String enviarDPS(String idProponente, String linguagem) {

        Map<String, Object> requestBody = new Map<String, Object>{
            'idProponente' => idProponente,
            'linguagem' => linguagem
        };

        String jsonBody = JSON.serialize(requestBody);
        String endpointUrl = Test.isRunningTest()  ? '/mock/endpoint' : [SELECT Endpoint__c FROM Servico__mdt WHERE DeveloperName = 'Enviar_dps'].Endpoint__c; 

        String prefixo = SensediaServices.getInstance().selectDomain('AWS_EXTERNO'); 
        String token = SensediaServices.getInstance().getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        
        String fullEndpoint = prefixo + endpointUrl;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(fullEndpoint);
        req.setMethod('POST');
        req.setBody(jsonBody);
        req.setHeader('Authorization', token);
        req.setHeader('Content-Type', 'application/json');

        system.debug('req - enviarDPS: ' + req);


        Http http = new Http();
        HttpResponse res = http.send(req);

        system.debug('res - enviarDPS: ' + res);


        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseMap.get('status') == 'success') {
                return (String) responseMap.get('message');
            } else {
                throw new CalloutException('Falha ao enviar DPS: ' + res.getBody());
            }
        } else {
            throw new CalloutException('Erro HTTP: ' + res.getStatusCode() + ' - ' + res.getStatus());
        }
    }
    //FNPVVEP-99 - FIM

    //FNPVVEP-108 INICIO
    public static String gerarBoleto(String payload) {

        String endpointUrl = Test.isRunningTest()  ? '/mock/endpoint' : [SELECT Endpoint__c FROM Servico__mdt WHERE DeveloperName = 'Gerar_Boleto'].Endpoint__c; 
        String prefixo = SensediaServices.getInstance().selectDomain('AWS_EXTERNO'); 
        String token = SensediaServices.getInstance().getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        String fullEndpoint = prefixo + endpointUrl;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(fullEndpoint);
        req.setMethod('POST');
        req.setBody(payload);
        req.setHeader('Authorization', token);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('descricao');
        } else {
            throw new CalloutException('Erro HTTP: ' + res.getStatusCode() + ' - ' + res.getStatus() + ' - ' + res.getBody());
        }
    }
    //FNPVVEP-108 FIM

    //FNPVVEP-114 INICIO
    public static String comunicarTelemed(String payload) {
        system.debug('req - comunicarTelemed teste: ');
        String endpointUrl = Test.isRunningTest()  ? '/mock/endpoint' : [SELECT Endpoint__c FROM Servico__mdt WHERE DeveloperName = 'Enviar_segurado_Telemedicina'].Endpoint__c; 

        String prefixo = SensediaServices.getInstance().selectDomain('AWS_EXTERNO'); 
        String token = SensediaServices.getInstance().getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        
        String fullEndpoint = prefixo + endpointUrl;
        system.debug('token - token: ' + token);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(fullEndpoint);
        req.setMethod('POST');
        req.setBody(payload);
        req.setHeader('Authorization', token);
        req.setHeader('Content-Type', 'application/json');

        system.debug('req - comunicarTelemed: ' + req);

        Http http = new Http();
        HttpResponse res = http.send(req);

        system.debug('res - comunicarTelemed: ' + res);


        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseMap.get('status') == 'success') {
                return (String) responseMap.get('message');
            } else {
                throw new CalloutException('Falha ao gerar comunicar Telemed: ' + res.getBody());
            }
        } else {
            throw new CalloutException('Erro HTTP: ' + res.getStatusCode() + ' - ' + res.getStatus());
        }
    }
    //FNPVVEP-114 FIM

    public String consultarCEP(String CEPlogradouro, String CEPcomplemento) {
        system.debug('Guia Postal - Sensedia Services');

        String prefixo = this.selectDomain('ON_PREMISES_EXTERNO');                              //https://portoapi-hml.portoseguro.com.br/governancadados/v1/guiapostal/logradouro
        String url = this.selectEndpoint('Guia_Postal_Sensedia');                             // /governancadados/v1/guiapostal/logradouro
        String token = this.getAccessToken('ON_PREMISES_EXTERNO', 'Token_Sensedia_OnPremise'); // Bearer MGMyZGYyODUtODRkNC00OTFjL....
        String endpoint = prefixo + url;                                                       //https://portoapi-hml.portoseguro.com.br/governancadados/v1/guiapostal/logradouro/governancadados/v1/guiapostal/logradouro
        // String endpoint = 'https://webhook.site/d81d9b0e-1393-4c92-9c85-962699784f01';
        
		String mensagemErro = 'Erro ao buscar Endereço por CEP.';
        String retorno;

        System.debug('endpoint ' + endpoint);
        System.debug('token ' + token);
        try {
            // Constructing the full endpoint URL with parameters
            String fullEndpoint = endpoint + '?numeroCepLogradouro=' + CEPlogradouro + '&numeroCepComplementoLogradouro=' + CEPcomplemento;
            fullEndpoint.replace('#CEPlogradouro', CEPlogradouro).replace('#CEPcomplemento', CEPcomplemento);

            // Creating the HTTP request
            HttpRequest request = new HttpRequest();
            request.setEndpoint(fullEndpoint);
            request.setMethod('GET');
            request.setHeader('Authorization', token);
            request.setHeader('Content-Type', 'application/json');
            System.debug('request ' + request);

            // Sending the HTTP request
            Http http = new Http();
            HttpResponse resposta = http.send(request);
    
            // Processing the response
            if(!String.isEmpty(resposta.getBody())) {
                retorno = resposta.getBody();
            }
    
            system.debug('Retorno: ' + retorno);
            return retorno;
    
        } catch (Exception e) {
            System.debug('###### ERROR SENSEDIA: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new SensediaServicesException(mensagemErro + e.getMessage());
        }
    }
    //ZSVEP-66 - FIM

    //Farol
    //SensediaServices.getInstance().buscaCredencial('Sensedia');
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

    //Farol
    // SensediaServices.getInstance().selectDomain('AWS_EXTERNO');
    public String selectDomain(String prefix){
        System.debug('Entrando na seleção do Prefixo para iniciar o procedimento de montagem da URL do Sensedia');
        String prefixSelected;

        for(DominiosSensedia__mdt domain : [ SELECT Endpoint__c, Nome_credencial__c, Label, DeveloperName FROM DominiosSensedia__mdt WHERE DeveloperName =: prefix LIMIT 1]){
            prefixSelected = domain.Endpoint__c;
        }

        System.debug('prefixSelected ' + prefixSelected);

        return prefixSelected;
    }  

    //Farol
    // SensediaServices.getInstance().selectEndpoint('Token_Sensedia_AWS');
    public String selectEndpoint(String service){
        System.debug('Entrando na seleção do EndPoint (Servico__mdt) para iniciar o procedimento de montagem da URL do Sensedia');
        String endPointSelected;

        //[SELECT Id, ExternalId__c FROM Order WHERE ExternalId__c IN : orderLookups]

        for(Servico__mdt domain : [SELECT NomeCredencial__c, NomeToken__c, Endpoint__c FROM Servico__mdt WHERE DeveloperName =: service LIMIT 1]){
            endPointSelected = domain.Endpoint__c;
        }

        System.debug('endPointSelected ' + endPointSelected);

        return endPointSelected;
    }    

    /*
    Chamada para o endpoint de autenticaçao do sensedia - Por hora temos apenas AWS_EXTERNO (DominiosSensedia__mdt) e o Token_Sensedia_AWS (Servico__mdt),
    mas ja esta com parametros para futuros desenvolvimentos    
    */
    //Chamada exemplo: SensediaServices.getInstance().getTokenSensedia('AWS_EXTERNO', 'Token_Sensedia_AWS');
    public HttpResponse getTokenSensedia(String selectDomain, String selectEndpoint){

        System.debug('getTokenSensedia selectDomain ' + selectDomain);
        System.debug('getTokenSensedia selectEndpoint ' + selectEndpoint);

        CredencialOAuth2__mdt credencialOAuth2 = this.buscaCredencial('Sensedia');
        String prefixo = this.selectDomain(selectDomain);
        String url = this.selectEndpoint(selectEndpoint);
        String endpoint = prefixo + url;
        String auth = EncodingUtil.base64Encode(Blob.valueof(credencialOAuth2.ClientId__c + ':' + credencialOAuth2.ClientSecret__c));

        System.debug('auth ' + auth);
        System.debug('endpoint ' + endpoint);

        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        String payload = '{"grant_type":"client_credentials"}';

        request.setEndpoint(endpoint);
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

    //Para pegar apenas o token e usar numa HttpRequest, basta chamar this.getAccessToken(dominio, nome do serviço);
    //SensediaServices.getInstance().getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
    public String getAccessToken(String selectDomain, String selectEndpoint) {
        System.debug('getAccessToken selectDomain ' + selectDomain);
        System.debug('getAccessToken selectEndpoint ' + selectEndpoint);

        HttpResponse httpResponse = getTokenSensedia(selectDomain, selectEndpoint); // Chama o método para obter o token
        
        String accessToken = null;
        System.debug('getTokenSensedia httpResponse ' + httpResponse);
        if (httpResponse.getStatusCode() == 200) {
            // A resposta foi bem-sucedida, processar o corpo da resposta para extrair o access token
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
    
            if (jsonResponse.containsKey('access_token')) {
                // Extrair o access token da resposta
                accessToken = 'Bearer ' + (String) jsonResponse.get('access_token');
            }
        }
        System.debug('accessToken >'+ accessToken);
        return accessToken;
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

    //MGRC-1260 - INICIO
    public String servicoconsultanomeserasa(String tipo, String cpfcnpj) {
        String prefixo = this.selectDomain('AWS_EXTERNO');
        String url = this.selectEndpoint('Consulta_Nome_Serasa_Sensedia');
        String token = this.getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        String endpoint = prefixo + url +'?tipo='+ tipo + '&documento=' + cpfcnpj;

        String responsenew;
		String nomeEndpoint = 'Consulta_Nome_Serasa_Sensedia';
		HttpResponse resposta;

		try {
            Map<String, String> mapHeader = this.gerarHeaderOAuth2(token);
			resposta = Util.executarHttpRequest(endpoint, 'GET', mapHeader , null , 60000);
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
			throw new SensediaServicesException(mensagemErro + e.getMessage());
		}

		return responsenew; 
	}
    //MGRC-1260 - FIM
    //MGRC-1263 - INICIO
    public String consultarDocumento(String orcamento) {
        String prefixo = this.selectDomain('AWS_EXTERNO');
        String url = this.selectEndpoint('Consultar_Documento_Sensedia');
        String token = this.getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        String endpoint = prefixo + url;

        String responsenew;  
		String body = orcamento;

		String nomeEndpoint = 'Consultar_Documento_Sensedia';
		HttpResponse resposta; 

		try {
            System.debug('PASSOU NO BODY SENSEDIA SERVICE'+ body);
    		
            if (Test.isRunningTest()) {
                resposta = new HttpResponse();
                resposta.setStatus('OK');
                resposta.setStatusCode(200);
                resposta.setHeader('Content-Type', 'application/json');
                resposta.setBody('{"jsonResponseCalculo": {"ofertas": [{"resultadoTeste":"ok"}, {"resultadoTeste":"ok"}]}}');
            }
            else {
               resposta = Util.executarHttpRequest(endpoint, 'POST', this.gerarHeaderOAuth2(token), body, 60000, nomeEndpoint);
            }
			
            system.debug('resposta 1= '+ resposta );
            system.debug(resposta);
            
			System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

			if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				responsenew = resposta.getBody();
			}
			else {
				responsenew = 'Erro na requisição';
			}
		}
		catch (Exception e) {
			System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
			throw new SensediaServicesException(mensagemErro + e.getMessage());
		}
		return responsenew;
	}
    //MGRC-1263 - FIM
    //MGRC-1250 - INICIO
    public String proxyAutomacao(String pRequest){
        /*
            exemplo de BODY OBRIGATÓRIO
            {
                "api": "/services/apexrest/usertools",
                "payload": {
                    "batch": [
                            {
                                "name": "BatchGerarPDF",
                                "tempo": "",
                                "descricao": "",
                                "agendado": false
                            }
                        ]
                }
                "metodo":"POST",
                "stripNull":false
            }
        */
        if(String.isblank(pRequest))return null;
        Map<String,Object> requestToSend = (Map<String,Object>) JSON.deserializeUntyped(pRequest);
        Map<String,Object> responseToReturn = new Map<String,Object>();
        
        String api = requestToSend.containsKey('api') ? (String)requestToSend.get('api'):'';
        String metodo = requestToSend.containsKey('metodo') ? (String)requestToSend.get('metodo') : '';
        Boolean stripnull = requestToSend.containsKey('stripnull') ? (Boolean)requestToSend.get('stripnull') : false; //VALOR PADRÃO DA API false, ou seja, manda itens nullos no body;
        String payload = requestToSend.containsKey('payload') && metodo!='GET' ? JSON.serialize(requestToSend.get('payload'),stripnull): null;
        if(String.isNotBlank(api) && api.left(1)!='/')
            requestToSend.put('api','/'+(String)requestToSend.get('api'));
        System.debug('### payload s: ' + payload);

        String nomeEndPoint = 'AutomacaoSF_Sensedia';
        HttpResponse resposta;

        String prefixo = this.selectDomain('AWS_EXTERNO');
        String url = this.selectEndpoint('AutomacaoSF_Sensedia');
        String token = this.getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        String endpoint = prefixo + url;


        resposta = Util.executarHttpRequest(endpoint, metodo, this.gerarHeaderOAuth2(token), payload, 120000);
        System.debug('### pRequest: ' + pRequest);
        System.debug('### Metodo: ' + metodo);
        System.debug('### Payload: ' + payload);
        System.debug('### Strip Null: ' + stripnull);
        System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
        Map<String,String> headersToReturn = new Map<String,String>();
        if(!resposta.getHeaderKeys().isEmpty()){
            for(String hk : resposta.getHeaderKeys()){
                headersToReturn.put(hk,resposta.getHeader(hk));
            }
        }
        try {
            Map<String,Object> bodyToreturn = String.isNotBlank(resposta.getBody()) ? (Map<String,Object>)JSON.deserializeUntyped(resposta.getBody()): null;
            responseToReturn.put('responsebody',bodyToreturn);
        } catch (Exception e) {
            List<Object> bodyToreturn = String.isNotBlank(resposta.getBody()) ? (List<Object>)JSON.deserializeUntyped(resposta.getBody()): null;
            responseToReturn.put('responsebody',bodyToreturn);
        }
        responseToReturn.put('code',resposta.getStatusCode());
        responseToReturn.put('headers',headersToReturn);
        responseToReturn.put('body',resposta.getBody());
        System.debug('### responseToReturn: ' + JSON.serialize(responseToReturn));
        return JSON.serialize(responseToReturn);
    }
    //MGRC-1250 - FIM
    //MGRC-1259 - INICIO
    public void ConsultaCivSinistroTicketBCPIntegracao(Set<Id> listIds){        
        System.debug('ConsultaCivSinistroIntegracao ******************* ');
		System.debug('ConsultaCivSinistroIntegracao.listIds = '+ listIds);

		//4096
        List<Case> listSinistros = [select Id, Contrato__r.Empresa__c, Contrato__r.RamoSeguro__r.Codigo__c, SinistroBeneficioAvisado__c, Nome_Segurado__c, Cpf_Segurado__c, Dataocorrencia__c, Subject, Description, Numero_titulo__c,
		Vitima__c, IdPrestadora__c, TipoEvento__c, EmpresaSplit__c, sucursal__c, RamoSplit__c, Numero_Apolice__c, SinistroPrioritario__c from Case where Id =: listIds];                                                                
        
        Case casoObj = listSinistros[0];

        String prefixo = this.selectDomain('AWS_EXTERNO');
        String url = this.selectEndpoint('Consulta_Civ_Ticket_BCP_Sensedia');
        String token = this.getAccessToken('AWS_EXTERNO', 'Token_Sensedia_AWS');
        String endpoint = prefixo + url;
            
		if(!test.isRunningTest())
            
			String nomeServico = 'Consulta_Civ_Ticket_BCP_Sensedia';
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', token); //MGRC-1259 BUGFIX-INICIO-FIM
            request.setHeader('Content-Type', 'application/json');                        						
			
			CivSinistroTO.Request objCasoSinistro = new CivSinistroTO.Request();
			
			objCasoSinistro.nomeSegurado = casoObj.Nome_Segurado__c;
			//PLV-4096 - inicio fix
			if(casoObj.Cpf_Segurado__c != null && casoObj.Cpf_Segurado__c != ''){
				objCasoSinistro.cpfSegurado = casoObj.Cpf_Segurado__c.substring(0, 11);
				objCasoSinistro.digitoCpfSegurado = casoObj.Cpf_Segurado__c.substring(12, 14); //Digito CPF
			}
			//PLV-4096 - fim fix						
			objCasoSinistro.dataOcorrencia = String.valueOf(casoObj.Dataocorrencia__c);
			objCasoSinistro.assunto = casoObj.Subject;
			objCasoSinistro.descricao = casoObj.Description;			
			objCasoSinistro.origem = 'SFDC';
			objCasoSinistro.prestadora = casoObj.Numero_titulo__c;
			objCasoSinistro.vitima = casoObj.Vitima__c;
			objCasoSinistro.idAtendimentoPrestadora = casoObj.IdPrestadora__c;
			objCasoSinistro.caseId = casoObj.Id;
			objCasoSinistro.tipoEvento = casoObj.TipoEvento__c;
			objCasoSinistro.avisado = 'true';
			//objCasoSinistro.empresa = String.valueOf(Integer.valueOf(casoObj.EmpresaSplit__c));
			//PLV-4096 - inicio fix-1
			objCasoSinistro.empresa = casoObj.Contrato__r.Empresa__c;
			//PLV-4096 - fim fix-1
			objCasoSinistro.sucursal = casoObj.sucursal__c;
			//objCasoSinistro.ramo = String.valueOf(Integer.valueOf(casoObj.RamoSplit__c));
			//PLV-4096 - inicio fix-1
			objCasoSinistro.ramo = casoObj.Contrato__r.RamoSeguro__r.Codigo__c;
			//PLV-4096 - fim fix-1
			objCasoSinistro.apolice = casoObj.Numero_Apolice__c;
			//PLV-4096 - inicio fix
			if(casoObj.Numero_Apolice__c != null && casoObj.Numero_Apolice__c != ''){
				objCasoSinistro.endosso = objCasoSinistro.apolice.substring(10, 11); //Digito da apolice
			}
			//PLV-4096 - fim fix
			objCasoSinistro.sinistroPrioritario = casoObj.SinistroPrioritario__c;
			objCasoSinistro.edsTip = '2';
						
			List<PagamentoGarantia__c> listaPG = [select Id, Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c, CurrencyIsoCode, Valor_indenizado__c from PagamentoGarantia__c where  Caso__c =: casoObj.Id];
			
			List<CivSinistroTO.GarantiaSinistroTO> listGarantiasTO = new List<CivSinistroTO.GarantiaSinistroTO>();
												
			for(PagamentoGarantia__c pg : listaPG){
				CivSinistroTO.GarantiaSinistroTO garantiaTO = new CivSinistroTO.GarantiaSinistroTO();
				garantiaTO.sigla = pg.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c;
				garantiaTO.valorIndenizado = pg.Valor_indenizado__c;
				garantiaTO.moedaIndenizacao = pg.CurrencyIsoCode;
				
				listGarantiasTO.add(garantiaTO);
			}									

			objCasoSinistro.garantias = listGarantiasTO;
			CivSinistroTO.Sinistro sinistroObj = new CivSinistroTO.Sinistro();

			sinistroObj.Sinistro = objCasoSinistro;
			
			//Sinistro jsSinistro = new Sinistro();
			//jsSinistro.Sinistro	 = 	objCasoSinistro;												
			            
            request.setBody(System.JSON.serialize(sinistroObj));
                        
            System.debug('ConsultaCivSinistroIntegracao.Sinistro = ' + System.JSON.serialize(sinistroObj));
            
            HttpResponse response = http.send(request);
            
            if( response.getStatusCode() == 200 ){
                
                System.debug('Ok');
                System.debug(response.getBody());
                String response2 = response.getBody();
                
				System.debug('retorno1 = ' + response2);
				System.debug('retorno 2= ' + (CivSinistroTO.Response) System.JSON.deserialize(response2, CivSinistroTO.Response.class));
				CivSinistroTO.Response retorno = (CivSinistroTO.Response) System.JSON.deserialize(response2, CivSinistroTO.Response.class);
                
                System.debug('Ticket BCP ==> ' + retorno.data.sinistro);
				casoObj.Ticket_BCP__c = retorno.data.sinistro.idTicketBCP;
				casoObj.NumeroSinistro__c = retorno.data.sinistro.numeroSinistro;
				casoObj.SinistroBeneficioAvisado__c = true;
				//PLV-4096 - inicio fix-1
				casoObj.EmpresaSplit__c = Decimal.valueOf(retorno.data.sinistro.empresa);
				casoObj.RamoSplit__c = Decimal.valueOf(retorno.data.sinistro.ramo);
				//PLV-4096 - fim fix-1
				update casoObj;
                //Setar dados de retorno no objeto
                
                //System.debug('retorno = '+ retorno);                                 
                
            }else{
                System.debug('Erro');
                System.debug('Erro serviço = ' + response.getBody());               
				
                String response2 = response.getBody();
                //JsonCIVConsultaMoeda retorno = JsonCIVConsultaMoeda.parseErro(response2);
                erroRetorno erroRetornoObj = (erroRetorno) System.JSON.deserialize(response2, erroRetorno.class);
                System.debug('erroRetornoObj = ' + erroRetornoObj);
				System.debug('erroRetornoObj.mensagem = ' + erroRetornoObj.mensagem);
				
            }     		        		
        
    }

    public class erroRetorno{
        public Integer codigo;
		public String mensagem;
		public String dataOcorrencia;
		public String fonte;
		public String tipo;
		public String additionalInfo;                
    }
    //MGRC-1259 - FIM

    //MGRC-1653 - INICIO
    public void emitirContrato(ContratoTO.PayloadTO parEntrada) {
        String prefixo = this.selectDomain('AWS_EXTERNO_EMISSAO');
        String url = this.selectEndpoint('Emissao_BCP');
        String token = this.getAccessToken('AWS_EXTERNO_EMISSAO', 'Token_Sensedia_AWS');
        String endpoint = prefixo + url;

		HttpResponse resposta; 
        String body = JSON.serialize(parEntrada, true);
        
        try {
            Debug.getInstance().setStart().log(new Map<Object, Object> { 'Request body' => body });   
            resposta = Util.executarHttpRequest(endpoint, 'POST', this.gerarHeaderOAuth2(token), body, 60000);

            Debug.getInstance().log(new Map<Object, Object> {
                'Status' => resposta?.getStatusCode(),
                'Response body' => resposta?.getBody()
            });            
            
            if (resposta.getStatusCode() < 400) {            
                return;
            }
            else {
				throw new SensediaServicesException('SensediaServicesException - Body: ' + resposta.getBody());
            }            
        }
        catch (Exception e) {
            Debug.getInstance().log(e);            
            String corpoResposta = '';
            if(resposta != null){
                corpoResposta = ' Retorno Sensedia: ' + resposta.getBody();
            }
            throw new SensediaServicesException('Erro ao emitir contrato linha ' + e.getLineNumber() + ' mensagem: ' + e.getMessage() + corpoResposta);
        } finally {
            Debug.getInstance().end();
        } 
    }
    //MGRC-1653 - FIM

    //MGRC-1384 - INICIO
    public String montagemServicoSensedia(SensediaServices.VERB verboHTTP, SensediaServices.DOMAIN dominio, String servico, String body) {

        String verbo = verboHTTP.toString();
        String servicoDominio = dominio.toString();

        String prefixo = this.selectDomain(servicoDominio);                              
        String url = this.selectEndpoint(servico);                            
        String token = this.getAccessToken(servicoDominio, SENSEDIA_TOKEN); 
        String endpoint = prefixo + url;
        // String endpoint = 'https://webhook.site/d81d9b0e-1393-4c92-9c85-962699784f01';
        String retorno;   
        //INICIO - LECVPV-218
        if(endpoint.contains('/v1/pep/busca-pessoa-exposta')){
            endpoint = String.format(endpoint, this.params);
        }
        //FIM - LECVPV-218
        try {   

            HttpResponse resposta;
            resposta = Util.executarHttpRequest(endpoint, verbo, this.gerarHeaderOAuth2(token), body, 120000);
            System.debug('resposta montagemServicoSensedia ' + resposta);
			if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				retorno = resposta.getBody();
			}
			else {
                //MGRC-1533-INICIO
                // throw new SensediaServicesException('ERROR HTTP ' +'Status: '+resposta.getStatusCode()+' Body: '+resposta.getBody());
                retorno = 'Erro na requisição';
                //MGRC-1533-FIM
			}
            
        } catch (Exception e) {
            System.debug('###### ERROR SENSEDIA: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new SensediaServicesException(mensagemErro + e.getMessage());
        }
        System.debug('retorno ' + retorno);
        return retorno;
    }

    //MGRC-1271-INICIO
    public HttpResponse montagemServicoSensediaHeroku(SensediaServices.VERB verboHTTP, SensediaServices.DOMAIN dominio, String servico, String body) {
        String verbo = verboHTTP.toString();
        String servicoDominio = dominio.toString();

        String prefixo = this.selectDomain(servicoDominio);                              
        String url = this.selectEndpoint(servico);                            
        String token = this.getAccessToken(servicoDominio, SENSEDIA_TOKEN); 
        String endpoint = prefixo + url;
        String retorno;   
        HttpResponse resposta;
        //INICIO - LECVPV-218
        if(endpoint.contains('/v1/pep/busca-pessoa-exposta')){
            endpoint = String.format(endpoint, this.params);
        }
        //FIM - LECVPV-218
        try {   
            resposta = Util.executarHttpRequest(endpoint, verbo, this.gerarHeaderOAuth2(token), body, 120000);

            if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
                resposta.getBody();
            }
            else {
                //MGRC-1533-INICIO
                // throw new SensediaServicesException('ERROR HTTP ' +'Status: '+resposta.getStatusCode()+' Body: '+resposta.getBody());
                retorno = 'Erro na requisição';
                //MGRC-1533-FIM
            }
            
        } catch (Exception e) {
            System.debug('###### ERROR SENSEDIA: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new SensediaServicesException(mensagemErro + e.getMessage());
        }
        System.debug('retorno ' + retorno);
        System.debug('resposta ' + resposta);
        return resposta;
    }
    //MGRC-1271-FIM

    public String montagemServicoSensedia2(SensediaServices.VERB verboHTTP, SensediaServices.DOMAIN dominio, String servico, String body) {

        String verbo = verboHTTP.toString();
        String servicoDominio = dominio.toString();

        String prefixo = this.selectDomain(servicoDominio);                              
        String url = this.selectEndpoint(servico);                            
        String token = this.getAccessToken(servicoDominio, SENSEDIA_TOKEN); 
        // String endpoint = prefixo + url;
        String endpoint = 'https://webhook.site/b11f6cd2-dc99-43ab-9c8f-c75762efb87e';
        String retorno;                                             
        
        try {   

            HttpResponse resposta;
            resposta = Util.executarHttpRequest(endpoint, verbo, this.gerarHeaderOAuth2(token), body, 120000);

			if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				retorno = resposta.getBody();
			}
			else {
                //MGRC-1533-INICIO
                // throw new SensediaServicesException('ERROR HTTP ' +'Status: '+resposta.getStatusCode()+' Body: '+resposta.getBody());
                retorno = 'Erro na requisição';
                //MGRC-1533-FIM
			}
            
        } catch (Exception e) {
            System.debug('###### ERROR SENSEDIA: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new SensediaServicesException(mensagemErro + e.getMessage());
        }
        System.debug('retorno ' + retorno);
        return retorno;
    }
    //MGRC-1384 - FIM
    
    public class SensediaServicesException extends Exception{}
}