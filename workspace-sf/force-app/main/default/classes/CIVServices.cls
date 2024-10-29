/**
* Serviços - CIV
*
**/
public class CIVServices extends ServiceBase {
    private static final String CLASS_NAME = 'CIVServices';

    private static final CIVServices instance = new CIVServices();
    private static final String NOME_ENDPOINT = 'ProcessarCancelamentoPropostasCIV';
    private static final String MENSAGEM_ERRO = 'Erro ao efetuar Consulta.';
    //private static String CIV_API_TOKEN = CIVServices.getInstance().gerarTokenOAuth2('CIV');
    
    private CIVServices() { }
    
    public static CIVServices getInstance() {
        return instance;
    }
    
    //Realiza a transmissão da proposta
    public RetornoPropostaRestTO transmitirProposta(List<EmissaoTO> listEmissaoTO) {
        RetornoPropostaRestTO tempList = new RetornoPropostaRestTO();
        String endEndpoint = 'ProcessarCancelamentoPropostasCIV';
        String body = JSON.serialize(listEmissaoTO);
        HttpResponse resposta;
        
        try {
            // PLV-2468-30 INICIO
            resposta = Util.executarHttpRequest(this.gerarEndpoint(endEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000);
            // PLV-2468-30 FIM
            
            System.debug('Resposta do CIV de transmissão ---------- ' + resposta.getBody());
            
            if (resposta.getStatusCode() < 400) {
                tempList = (RetornoPropostaRestTO)JSON.deserialize(resposta.getBody(), RetornoPropostaRestTO.class);
            }
            else {
                throw new CIVServicesException(' Status Code: ' + resposta.getStatusCode());
            }
        }
        catch (Exception e) {
            System.debug(e.getMessage());
            
            String corpoResposta = '';
            if(resposta != null){
                corpoResposta = ' Retorno CIV: ' + resposta.getBody();
            }
            
            throw new CIVServicesException('Erro ao transmitir ' + e.getMessage() + corpoResposta);
        }
        return tempList;
    }
    
    //PLV-3393 - INICIO - Integração BCP
    //[PLV-3393] O CIV não retorna mais o contrato com o número da Apólice, com isso este retorno ficara momentaneamente vazio e o método não retornará nada.
    //Realiza a emissão do contrato
    //public ServiceTO.ContratoTO emitirContrato(ContratoTO.PayloadTO parEntrada) {
    public void emitirContrato(ContratoTO.PayloadTO parEntrada) {
        
        //ServiceTO.ContratoTO tempList = new ServiceTO.ContratoTO();
        //PLV-3393 - FIM - Integração BCP
        String body = JSON.serialize(parEntrada, true);
        String nomeEndpoint = 'EnvioPropostaCIV';
        HttpResponse resposta;
        
        try {
            Debug.getInstance().setStart().log(new Map<Object, Object> { 'Request body' => body }); // LECVP-69 - Inicio/Fim

            //PLV-3393 - INICIO - Integração BCP
            // if(Test.isRunningTest()){
            //     String payloadResponse = '{"contrato": {"codigoEmpresa": "22","codigoSucursal": "999","ramoSeguro": "1391","numeroApolice": "14889","numeroEndosso": "0"},"integracoesObrigatorias": [],"integracoesComplementares": []}';
            //     return (ServiceTO.ContratoTO)JSON.deserialize(payloadResponse, ServiceTO.ContratoTO.class);
            // }
            //PLV-3393 - FIM - Integração BCP

            // PLV-2468-30 INICIO
            resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000);
            // PLV-2468-30 FIM

            Debug.getInstance().log(new Map<Object, Object> { // LECVP-69 - Inicio
                'Status' => resposta?.getStatusCode(),
                'Response body' => resposta?.getBody()
            }); // LECVP-69 - Fim
            
            
            if (resposta.getStatusCode() < 400) {                
                //PLV-3393 - INICIO - Integração BCP
                //tempList = (ServiceTO.ContratoTO)JSON.deserialize(resposta.getBody(), ServiceTO.ContratoTO.class);
                return;
                //PLV-3393 - FIM - Integração BCP
            }
            else {
				throw new CIVServicesException('CIVServicesException - Body: ' + resposta.getBody());
            }            
        }
        catch (Exception e) {
            Debug.getInstance().log(e); // // LECVP-69 - Inicio/Fim
            
            String corpoResposta = '';
            if(resposta != null){
                corpoResposta = ' Retorno CIV: ' + resposta.getBody();
            }
            throw new CIVServicesException('Erro ao emitir contrato linha ' + e.getLineNumber() + ' mensagem: ' + e.getMessage() + corpoResposta);
        } finally { // LECVP-69 - Inicio
            Debug.getInstance().end();
        } // LECVP-69 - Fim
        
        //return tempList; //PLV-3393 - INICIO/FIM
    }

    //LECVP-72 - INICIO
    public BCPContratoTcktTO reemitirContrato(ReenvioContratoTO.PayloadTO payload) {
        
        String body = JSON.serialize(payload, true);
        String nomeEndpoint = 'ReenvioContratoBCP';
        BCPContratoTcktTO bCPContratoTcktTO = new BCPContratoTcktTO();
        HttpResponse resposta;
        
        try {
            resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000);
            
            if(resposta.getStatusCode() < 400){    
                bCPContratoTcktTO = (BCPContratoTcktTO) JSON.deserialize(resposta.getBody(), BCPContratoTcktTO.class);       
                return bCPContratoTcktTO;
            } else {
                bCPContratoTcktTO = (BCPContratoTcktTO) JSON.deserialize(resposta.getBody(), BCPContratoTcktTO.class);
				return bCPContratoTcktTO;
            }            
        }
        catch (Exception e) {
            String corpoResposta = '';
            if(resposta != null){
                corpoResposta = ' Retorno CIV: ' + resposta.getBody();
            }
            throw new CIVServicesException('Erro ao reemitir contrato linha ' + e.getLineNumber() + ' mensagem: ' + e.getMessage() + corpoResposta);
        }         
    }
    //LECVP-72 - FIM

    // PLV-4667-INICIO
    //MGRC-1657 - INICIO
    // public void integrarNaoClientesBCP(String body) {
        
    //     String nomeEndpoint = 'BCPNaoClientes';
    //     HttpResponse resposta;
        
    //     try {
    //         String endpoint = this.gerarEndpoint(nomeEndpoint);
    //         Map<String,String> headerAuth = this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV'));
    //         System.debug('endpoint');
    //         System.debug(endpoint);
    //         System.debug('headerAuth');
    //         System.debug(headerAuth);
    //         system.debug('body');
    //         system.debug(body);
    //         resposta = Util.executarHttpRequest(endpoint, 'POST', headerAuth, body, 60000);

    //         System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
            
    //         if (resposta.getStatusCode() < 400) {                
    //             return;
    //         }
    //         else {
	// 			throw new CIVServicesException('CIVServicesException - Body: ' + resposta.getBody());
    //         }            
    //     }
    //     catch (Exception e) {
    //         System.debug(e.getMessage());
    //         String corpoResposta = '';
    //         if(resposta != null){
    //             corpoResposta = ' Retorno CIV: ' + resposta.getBody();
    //         }
            
    //         System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
    //         throw new CIVServicesException('Erro integração bcp nao clientes' + e.getLineNumber() + ' mensagem: ' + e.getMessage() + corpoResposta);
    //     }
        
    // }
    //MGRC-1657 - FIM
    // PLV-4667-FIM

    public String validarComposicaoBancaria(String dadosBancarios) {
        
        system.debug('gfs dadosBancarios ' + dadosBancarios);
        
        ValidarComposicaoBancariaTO tempList = new ValidarComposicaoBancariaTO();
        
        String responsenew;  
        
        String body = dadosBancarios;
        
        system.debug('gfs body de envio pro serviço ' + body);
        
        String nomeEndpoint = 'ValidarComposicaoBancaria';
        HttpResponse resposta;
        
        try {
            // PLV-2468-30 INICIO
            resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000);
            // PLV-2468-30 FIM
            System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
            
            if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
                responsenew = resposta.getBody();
                system.debug('gfs responsenew ' + responsenew);
            }
            else {
                throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
            }
        }
        catch (Exception e) {
            System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new CIVServicesException(mensagemErro + e.getMessage());
        }
        
        return responsenew;
    }
	
    //AVX SP23 - Realiza a validação do bloqueio bancário 
	public String validarBloqueioBancario(String dadosBancarios) {
        String responsenew;  
		String body = dadosBancarios;

		system.debug('gfs ============= body'); 
		system.debug(body);
 
		String nomeEndpoint = 'ValidarBloqueioBancario';
		HttpResponse resposta; 

		try {
            // PLV-2468-30 INICIO
			resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000);
            // PLV-2468-30 FIM

			System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

			if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				responsenew = resposta.getBody();
			}
			else {
				throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
			throw new CIVServicesException(mensagemErro + e.getMessage());
		}

		return responsenew;
	}

    
    
    
    //AVX SP26 - Criacao de Orcamento Sinistro -  Cancela contrato 
	//PLV-1096 - Início - Comentario removido e código ajustado 
    //MGRC-1657 - INICIO
	public String criacaodeorcamentosinistro(String dadoscaso) {
        String responsenew;  
		String body = dadoscaso;

		system.debug('gfs =============> body =>'); 
		system.debug(body);
 
		String nomeEndpoint = 'Criacao_de_Orcamento_Sinistro';
		HttpResponse resposta; 

		try {
            //MGRC-1657 - INICIO
			// resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
            resposta.setStatusCode(200);
            resposta.setBody('');
            //MGRC-1657 - FIM
			system.debug('resposta');
            system.debug(resposta);
            
			System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

			if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				responsenew = resposta.getBody();
			}
			else {
				throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
			throw new CIVServicesException(mensagemErro + e.getMessage());
		}

		return responsenew;
	}
    //MGRC-1657 - FIM
	//PLV-1096 - Fim - Comentario removido e código ajustado

    //AVX SP26 - criação proposta - Cancela contrato - Início
    //PLV-1096 - Início - Comentario removido e código ajustado
    //PLV-3872 - INICIO - Metodo para realizar a integração de endosso 
    
    //MGRC-1657 - INICIO
	public String criacaodepropostasinistro(String dadosproposta) {
        String responsenew;  
		String body = dadosproposta;

		system.debug('gfs =============> body =>'); 
		system.debug(body);
 
		String nomeEndpoint = 'Criacao_de_Proposta_Sinistro';
		HttpResponse resposta; 

		try {
            //MGRC-1657 - INICIO
			// resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
            resposta.setStatusCode(200);
            resposta.setBody('');
            //MGRC-1657 - FIM

			System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

			if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
				responsenew = resposta.getBody();
			}
			else {
				throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
			throw new CIVServicesException(mensagemErro + e.getMessage());
		}

		return responsenew;
    }
    //MGRC-1657 - FIM

    //PLV-3872 -FIM
	//PLV-1096 - Fim - Comentario removido e código ajustado

    //PLV-1096 - Inicio -  Chamada do serviço do ODM 

    public String servicoConsultaODM(String dadosODM){
        String responsenew;
        String nomeEndpoint = 'ConsultaODM';
        String body = dadosODM;

        HttpResponse resposta;

        try{
            //MGRC-1657 - INICIO
            // resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
            resposta.setStatusCode(200);
            resposta.setBody('');
            //MGRC-1657 - FIM
            System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

            if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
                responsenew = resposta.getBody();
            }
            else {
                throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
            }
        }catch(Exception e){ 
            System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new CIVServicesException(mensagemErro + e.getMessage());
        }
        return responsenew;
    }

    //MGRC-1657 - INICIO
    //PLV-1096 - Fim -  Chamada do serviço do ODM 

    //AVX SP27 - PLV - 1673 - Consulta serasa - Início
	// public String servicoconsultanomeserasa(String tipo, String cpfcnpj) {
    //     String responsenew;  
	// 	String nomeEndpoint = 'Consulta_Nome_Serasa';
	// 	String method = 'GET';
    //     String EndPoint = this.gerarEndpoint(nomeEndpoint) +'?tipo='+ tipo + '&documento=' + cpfcnpj;
		
	// 	HttpResponse resposta; 
	// 	try {
    //         Map<String, String> Mapheader = this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV'));
	// 		resposta = Util.executarHttpRequest(EndPoint, method, Mapheader , null , 60000);
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		}
	// 		else {
	// 			responsenew = resposta.getBody();
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}

	// 	return responsenew; 
	// }
	//AVX SP27 - PLV - 1673 - Consulta serasa - Fim
    //MGRC-1657 - FIM

    //MGRC-1657 - INICIO
	// AV-85 INICIO
    // public String servicoCIVLTM(String payloadIdPortoPlus) {
    //     String responsenew;  
	// 	String body = payloadIdPortoPlus;

	// 	String nomeEndpoint = 'ConsultaIdPortoPlus';
	// 	HttpResponse resposta; 

	// 	try {
    
	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
            
    //         system.debug('resposta 1= '+ resposta );
    //         system.debug(resposta);
            
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		}
	// 		else {
	// 			responsenew = 'Erro na requisição';
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}
	// 	return responsenew;
	// }


    // public String servicoConsultaCPFativoLTM(String cpfVoucher) {
        
    //     String responsenew;  
	// 	String body = cpfVoucher;
    //     System.debug('body: ' + body);
        
    //     System.debug('responsenew: ' + responsenew);

	// 	String nomeEndpoint = 'ConsultaCPFAtivoLTM';
    //     String generatedEndpoint;
	// 	HttpResponse resposta; 

	// 	try {

    //         //VIDA-179 - INICIO
    //         Servico__mdt servico =  this.buscarMetadadoServico(nomeEndpoint);
	// 		String endpoint =  String.isNotBlank(servico.Endpoint__c) ? servico.Endpoint__c : '';
			
	// 		generatedEndpoint = System.Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint3' : 'callout:' + servico.NomeCredencial__c + endpoint;

	// 		resposta = Util.executarHttpRequest(generatedEndpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
    //         //VIDA-179 - FIM

    //         system.debug('resposta 1= '+ resposta );
    //         system.debug(resposta);
            
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		}
	// 		else {
	// 			responsenew = 'Erro na requisição';
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}
	// 	return responsenew;
	// }
    //MGRC-1657 - FIM
    //AV-85 FIM

    //PLV-5230 - INICIO
    //MGRC-1657 - INICIO
    // public String incluirProdutoVidaOpin(String payloadOpin) {
    //     String responsenew;  
	// 	String body = payloadOpin;
	// 	String nomeEndpoint = 'IncluirProdutoVidaOPIN';
	// 	HttpResponse resposta; 

	// 	try {
    
	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);            
                       
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		} else {
	// 		    responsenew = 'ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody();             
    //             //PARA AUMENTAR A COBERTURA DA CLASSE DE TESTE
    //             if(Test.isRunningTest()) throw new CIVServicesException(responsenew);                
	// 		}
	// 	} catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(e.getMessage());
	// 	}
	// 	return responsenew;
	// }
    //PLV-5230 - FIM
    //MGRC-1657 - FIM
    // Gerar token oauth2 para ser usado nas chamadas do CIV
    public String gerarTokenOAuth2(String nomeCredencial) {
        try {
            // Chave para salvar/buscar o token no cache da plataforma
            String ACCESS_TOKEN_CACHE_KEY = nomeCredencial;
            Integer MAX_TTL_SECS = Cache.Org.MAX_TTL_SECS;
            Integer MIN_TTL_SECS = 300; // 5min
            
            String accessToken;
            Integer expiresIn;
            
			if (Test.isRunningTest()) {
				nomeCredencial = 'TestToken';
			}
			System.debug('nomeCredencial');
            System.debug(nomeCredencial); 
            
            // Buscar a credencial oauth2 do Auth0
            CredencialOAuth2__mdt credencialOAuth2 = this.buscarCredencial(nomeCredencial);
            
            system.debug('.: credencialOAuth2 ' + credencialOAuth2);
            
            if (!credencialOAuth2.Status__c) {
				System.debug('Credencial "' + nomeCredencial + '" com Status__c FALSE');
                return '';
            }
            
			
            if (Cache.Org.contains(ACCESS_TOKEN_CACHE_KEY)) {
                // Token já existe no cache da plataforma, use-o
				// PLV 4518
				System.debug('Token já existe no cache da plataforma, use-o');
                accessToken = (String)Cache.Org.get(ACCESS_TOKEN_CACHE_KEY);
            }
            else {
                // Objeto que será serializado para JSON no body da requisição
                Map<String, String> mapBody = new Map<String, String>();
                mapBody.put('grant_type', credencialOAuth2.GrantType__c);
                mapBody.put('client_secret', credencialOAuth2.ClientSecret__c);
                mapBody.put('client_id', credencialOAuth2.ClientId__c);
                
                String body = '';
                
                system.debug('mapBody ' + mapBody);
                
                for (String chave : mapBody.keySet()) {
                    body += (chave + '=' + mapBody.get(chave) + '&');
                }
                
                Map<String, String> header = new Map<String, String>();
                header.put('Content-Type', 'application/x-www-form-urlencoded');

                System.debug('header: '+ header);
                
                // Solicitar o token mediante a credencial informada no mapBody
                HttpResponse resposta = new HttpResponse();

                if (Test.isRunningTest()) {
                    resposta.setStatus('OK');
                    resposta.setStatusCode(200);
                    resposta.setHeader('Content-Type', 'application/json');
                    resposta.setBody('{"access_token":"00000000-0000-0000-0000-000000000000","scope":"abc","expires_in":86400,"token_type":"Bearer"}');
                }
                else {
                    resposta = Util.executarHttpRequest(this.gerarEndpoint('GerarTokenCIV'), 'POST', header, body, 60000);
                }
                
                if (resposta.getStatusCode() < 400) {
                    // Deserializa para um tipo padrão sem TO.
                    Map<String, Object> mapResposta = (Map<String, Object>)JSON.deserializeUntyped(resposta.getBody());
                    
                    // Formato 'Bearer TOKEN_XXXXXXXXXXXXXXX'
                    accessToken = (String)mapResposta.get('token_type') + ' ' + (String)mapResposta.get('access_token');
                    expiresIn = (Integer)mapResposta.get('expires_in');
                    
                    // Valores serão ajustados se estiverem fora da faixa mínima e máxima
                    expiresIn = (expiresIn < MIN_TTL_SECS) ? MIN_TTL_SECS : expiresIn;
                    expiresIn = (expiresIn > MAX_TTL_SECS) ? MAX_TTL_SECS : expiresIn;
                }
                else {
                    String mensagemErro = 'ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody();
                    System.debug(mensagemErro);
                    throw new CIVServicesException(mensagemErro);
                }
                // Salvar o token no cache da plataforma com o tempo de expiração em segundos
                Cache.Org.put(ACCESS_TOKEN_CACHE_KEY, accessToken, expiresIn);
            }
            // Devolve o token já formatado para uso
            System.debug('::: accessToken: ' + accessToken);
            return accessToken;
        }
        catch(Exception e) {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new CIVServicesException('Erro ao recuperar o token.' + e.getMessage());
        }
    }
    
    // Gerar token oauth2 para ser usado nas chamadas do CIV
    public String gerarTokenOAuth2Heroku(String nomeCredencial) {
        try {
            // Chave para salvar/buscar o token no cache da plataforma
            String ACCESS_TOKEN_CACHE_KEY = nomeCredencial;
            Integer MAX_TTL_SECS = Cache.Org.MAX_TTL_SECS;
            Integer MIN_TTL_SECS = 300; // 5min
            
            String accessToken;
            Integer expiresIn;
            
			if (Test.isRunningTest()) {
				nomeCredencial = 'TestToken';
			}

            // Buscar a credencial oauth2 do Auth0
            CredencialOAuth2__mdt credencialOAuth2 = this.buscarCredencial(nomeCredencial);
            if (!credencialOAuth2.Status__c) {
				System.debug('Credencial "' + nomeCredencial + '" com Status__c FALSE');
                return '';
            }
            
            if (Cache.Org.contains(ACCESS_TOKEN_CACHE_KEY)) {
                // Token já existe no cache da plataforma, use-o
                accessToken = (String)Cache.Org.get(ACCESS_TOKEN_CACHE_KEY);
            }
            else {
                // Objeto que será serializado para JSON no body da requisição
                Map<String, String> mapBody = new Map<String, String>();
                mapBody.put('grant_type', credencialOAuth2.GrantType__c);
                mapBody.put('client_secret', credencialOAuth2.ClientSecret__c);
                mapBody.put('client_id', credencialOAuth2.ClientId__c);
                
                String body = '';
                
                for (String chave : mapBody.keySet()) {
                    body += (chave + '=' + mapBody.get(chave) + '&');
                }
                
                Map<String, String> header = new Map<String, String>();
                header.put('Content-Type', 'application/x-www-form-urlencoded');
                
                // Solicitar o token mediante a credencial informada no mapBody
                HttpResponse resposta = new HttpResponse();

                if (Test.isRunningTest()) {
                    resposta.setStatus('OK');
                    resposta.setStatusCode(200);
                    resposta.setHeader('Content-Type', 'application/json');
                    resposta.setBody('{"access_token":"00000000-0000-0000-0000-000000000000","scope":"abc","expires_in":86400,"token_type":"Bearer"}');
                }
                else {
                    resposta = Util.executarHttpRequest(this.gerarEndpoint('GerarTokenCIV'), 'POST', header, body, 60000);
                }
                
                if (resposta.getStatusCode() < 400) {
                    // Deserializa para um tipo padrão sem TO.
                    Map<String, Object> mapResposta = (Map<String, Object>)JSON.deserializeUntyped(resposta.getBody());
                    
                    // Formato 'Bearer TOKEN_XXXXXXXXXXXXXXX'
                    accessToken = (String)mapResposta.get('token_type') + ' ' + (String)mapResposta.get('access_token');
                    expiresIn = (Integer)mapResposta.get('expires_in');
                    
                    // Valores serão ajustados se estiverem fora da faixa mínima e máxima
                    expiresIn = (expiresIn < MIN_TTL_SECS) ? MIN_TTL_SECS : expiresIn;
                    expiresIn = (expiresIn > MAX_TTL_SECS) ? MAX_TTL_SECS : expiresIn;
                }
                else {
                    String mensagemErro = 'ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody();
                    System.debug(mensagemErro);
                    throw new CIVServicesException(mensagemErro);
                }
                // Salvar o token no cache da plataforma com o tempo de expiração em segundos
                Cache.Org.put(ACCESS_TOKEN_CACHE_KEY, accessToken, expiresIn);
            }
            // Devolve o token já formatado para uso
            System.debug('::: accessToken: ' + accessToken);
            return accessToken;
        }
        catch(Exception e) {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new CIVServicesException('Erro ao recuperar o token.' + e.getMessage());
        }
    }
    
 
    // PLV-1197-27: Calculo Orçamento
    //MGRC-1657 - INICIO
    public ServiceTO.DataCancelamentoTO calculoOrcamentoOferta(ServiceTO.ParamOrcamentoCalculoTO dadosParam) {
        
        system.debug('Param Calculo Orcamento: ' + dadosParam);
                
        ServiceTO.DataCancelamentoTO parSaida = new  ServiceTO.DataCancelamentoTO();
        
        String body = JSON.serialize(dadosParam);
        
        system.debug('gfs body de envio pro serviço ' + body);
        
        String nomeEndpoint = 'EfetuarCalculo';
        HttpResponse resposta;
        
        System.debug('Endpoint: ' + this.gerarEndpoint(nomeEndpoint));

        try {
            // PLV-2468-30 INICIO
            //MGRC-1657 - INICIO
            // resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000); //PLV-4695 - INICIO FIM
            resposta.setStatusCode(200);
            resposta.setBody('');
            //MGRC-1657 - FIM
            // PLV-2468-30 FIM
            
            System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
            
            if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {

                System.debug('====> parSaida: ' + resposta.getBody());
                
                parSaida = (ServiceTO.DataCancelamentoTO) JSON.deserialize(resposta.getBody(), ServiceTO.DataCancelamentoTO.class);
            }
            else {
                throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
            }
        }
        catch (Exception e) {
            System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new CIVServicesException(mensagemErro + e.getMessage());
        }
        System.debug('************* saindo do civservice ' + parSaida);
        return parSaida;
    }
    //MGRC-1657 - FIM
    // PLV-1197-27: Calculo Orçamento
    // PLV-2430-29 INICIO
    public RetornoPropostaRestTO.ValidacaopropostaTO calculoPropostaTransmissao(ServiceTO.ParamPropostaCalculoTO dadosParam) {
    // PLV-2430-29 FIM
        
        system.debug('Param Calculo Orcamento: ' + dadosParam);

        // PLV-2430-29 INICIO
        RetornoPropostaRestTO retorno;
        // PLV-2430-29 FIM
        
        String body = JSON.serialize(dadosParam);

        system.debug('gfs body de envio pro serviço ' + body);
        
        String nomeEndpoint = 'EfetuarTransmProposta';
        HttpResponse resposta;
   
        System.debug('Endpoint: ' + this.gerarEndpoint(nomeEndpoint));

        try {

            // PLV-2430-29 INICIO
            if(Test.isRunningTest()){
                String payloadResponse = '{"data":{"proposta":{"vigenciaInicial":"2016-09-23","vigenciaFinal":"2019-04-03","tipoAdesao":"INA","sucursal":1,"status":"Em criação","ramo":1377,"qtdDiasVigencia":922,"origem":18,"numeroOrcamento":480955,"numero":480955,"meioComercializacao":"SFC","empresa":1,"dataCalculo":"2019-01-19","apolice":200011388},"devolutivas":[{"tipoRegistro":1,"origem":"INT","numeroCampo":0,"descricao":"EMISSÃO: - registro inserido/atualizado com sucesso.","codigo":0}]},"meta":{"dataExecucao":"2019-07-08T15:28:45.261Z","mensagem":"OK","servico":"GeracaoProposta","statusHttp":200}}';//PLV-4550 INICIO/FIM
                return (RetornoPropostaRestTO.ValidacaopropostaTO) JSON.deserialize(payloadResponse,RetornoPropostaRestTO.ValidacaopropostaTO.class);
            }
            // PLV-2430-29 FIM

            // PLV-2468-30 INICIO
            resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000);
            // PLV-2468-30 INICIO
            
            System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
            
            if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
                // PLV-2430-29 INICIO
                system.debug('gfs responsenew ' + resposta.getBody());
                retorno = (RetornoPropostaRestTO) JSON.deserialize(resposta.getBody(),RetornoPropostaRestTO.class);
                // PLV-2430-29 FIM
            }
            else {
                throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
            }
        }
        catch (Exception e) {
            System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new CIVServicesException(mensagemErro + e.getMessage());
        }

        // PLV-2430-29 INICIO
        return retorno.data;
    }
   
   // PLV-2430-29 FIM 
	//PLV-2903 - Inicio - Remover credencial nomeada CIVPORTAL
  //Inicio da lógica para a história - PVL 2318
    // Gerar token oauth2 para ser usado nas chamadas do CIV
    /*
    public String gerarTokenOAuth2CIVPORTAL(String nomeCredencial) {
          system.debug('entrouuuuuuuuuuuuuuuu');
          system.debug('rm ---- nomeCredencial ' + nomeCredencial);
        try {
            // Chave para salvar/buscar o token no cache da plataforma
            String ACCESS_TOKEN_CACHE_KEY = nomeCredencial;
            Integer MAX_TTL_SECS = Cache.Org.MAX_TTL_SECS;
            Integer MIN_TTL_SECS = 300; // 5min
            
            String accessToken;
            Integer expiresIn;
            
			if (Test.isRunningTest()) {
				nomeCredencial = 'TestToken';
			}
			System.debug('nomeCredencial');
            System.debug(nomeCredencial); 
            
            // Buscar a credencial oauth2 do Auth0
            system.debug('rm ---- nomeCredencial ' + nomeCredencial);
            CredencialOAuth2__mdt credencialOAuth2 = this.buscarCredencial(nomeCredencial);
            
            system.debug('.: rm --- credencialOAuth2 ' + credencialOAuth2);
            
            if (!credencialOAuth2.Status__c) {
				System.debug('Credencial "' + nomeCredencial + '" com Status__c FALSE');
                return '';
            }
            
            if (Cache.Org.contains(ACCESS_TOKEN_CACHE_KEY)) {
                // Token já existe no cache da plataforma, use-o
                accessToken = (String)Cache.Org.get(ACCESS_TOKEN_CACHE_KEY);
            }
            else {
                // Objeto que será serializado para JSON no body da requisição
                Map<String, String> mapBody = new Map<String, String>();
                mapBody.put('grant_type', credencialOAuth2.GrantType__c);
                mapBody.put('client_secret', credencialOAuth2.ClientSecret__c);
                mapBody.put('client_id', credencialOAuth2.ClientId__c);
                
                String body = '';
                
                system.debug('mapBody ' + mapBody);
                
                for (String chave : mapBody.keySet()) {
                    body += (chave + '=' + mapBody.get(chave) + '&');
                }
                
                Map<String, String> header = new Map<String, String>();
                header.put('Content-Type', 'application/x-www-form-urlencoded');
                
                // Solicitar o token mediante a credencial informada no mapBody
                HttpResponse resposta = new HttpResponse();

                if (Test.isRunningTest()) {
                    resposta.setStatus('OK');
                    resposta.setStatusCode(200);
                    resposta.setHeader('Content-Type', 'application/json');
                    resposta.setBody('{"access_token":"00000000-0000-0000-0000-000000000000","scope":"abc","expires_in":86400,"token_type":"Bearer"}');
                }
                else {
                    system.debug('rm ----- ');
                    system.debug('header ' + header);
                    system.debug('body ' + body);
                    
                    //rm token civ com problema
                    resposta = Util.executarHttpRequest(this.gerarEndpoint('GerarTokenCIVPORTAL'), 'POST', header, body, 60000);
                    system.debug('resposta rm --- '+ resposta);
                }
                
                if (resposta.getStatusCode() < 400) {
                    // Deserializa para um tipo padrão sem TO.
                    Map<String, Object> mapResposta = (Map<String, Object>)JSON.deserializeUntyped(resposta.getBody());
                    
                    // Formato 'Bearer TOKEN_XXXXXXXXXXXXXXX'
                    accessToken = (String)mapResposta.get('token_type') + ' ' + (String)mapResposta.get('access_token');
                    expiresIn = (Integer)mapResposta.get('expires_in');
                    
                    // Valores serão ajustados se estiverem fora da faixa mínima e máxima
                    expiresIn = (expiresIn < MIN_TTL_SECS) ? MIN_TTL_SECS : expiresIn;
                    expiresIn = (expiresIn > MAX_TTL_SECS) ? MAX_TTL_SECS : expiresIn;
                }
                else {
                    String mensagemErro = 'ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody();
                    System.debug(mensagemErro);
                    throw new CIVServicesException(mensagemErro);
                }
                // Salvar o token no cache da plataforma com o tempo de expiração em segundos
                Cache.Org.put(ACCESS_TOKEN_CACHE_KEY, accessToken, expiresIn);
            }
            // Devolve o token já formatado para uso
            System.debug('::: accessToken: ' + accessToken);
            return accessToken;
        }
        catch(Exception e) {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new CIVServicesException('Erro ao recuperar o token.' + e.getMessage());
        }
    }
    */

    //PLV-2903 - Fim - Remover credencial nomeada CIVPORTAL
    //Fim da lógica para a história - PVL 2318

    //AVX HACKATHON- Criacao de Consulta Para Contratação-  Consulta Para Contratação - PVL 2318
    //Inicio da lógica para a história - PVL 2318
    //MGRC-1657 - INICIO
	// public String consultivoContratacao(String entradaConsultivo) {
    //     String responsenew;  
	// 	String body = entradaConsultivo;

	// 	system.debug('rm =============> body =>'); 
	// 	system.debug(body);
        
    //     //Metadado>serviço>Calculo Contratação
	// 	String nomeEndpoint = 'Consultivo_Contracao';
	// 	HttpResponse resposta; 

	// 	try {
    //         system.debug('Entrou no try!'); 
    //         System.System.debug('PASSOU NO BODY CIV SERVICE'+ body);
            
    //         //PLV2533 - INÍCIO - Alteração de CIVPORTAL para CIV
    //         //PLV-2903 - Inicio - Remover credencial nomeada CIVPORTAL
    //         //resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2CIVPORTAL('CIVPORTAL')), body, 60000, nomeEndpoint);
	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000, nomeEndpoint);//PLV-4398 - INICIO/FIM
    //         //PLV-2903 - Fim - Remover credencial nomeada CIVPORTAL
    //         //PLV2533 - FIM - Alteração de CIVPORTAL para CIV
            
    //         system.debug('resposta 1= '+ resposta );
    //         system.debug(resposta);
            
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		}
	// 		else {

    //             //PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
	// 			responsenew = 'Erro na requisição';
    //             //throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
    //             //PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}

	// 	return responsenew;
	// }
    //MGRC-1657 - FIM
    
    //Fim da lógica para a história - PVL 2318
    //MGRC-1657 - INICIO
    //AVX HACKATHON- Criacao de Calculo Para Contratação-  Calcula Contratação - PVL 2318
    //Inicio da lógica para a história - PVL 2318

	// public String criacaoCalculo(String entradaCalculo) {
    //     String responsenew;  
	// 	String body = entradaCalculo;
        
    //     //Metadado>serviço>Calculo Contratação
	// 	String nomeEndpoint = 'Calculo_Contratacao';
	// 	HttpResponse resposta; 

    //     System.debug('criacaoCalculo');
    //     System.debug('Endpoint --> ' + this.gerarEndpoint(nomeEndpoint));
    //     System.debug('Body --> ' + body);
	// 	try {
    //         //PLV-2903 - Inicio - Remover credencial nomeada CIVPORTAL
	// 		//resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2CIVPORTAL('CIVPORTAL')), body, 60000, nomeEndpoint);
	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000, nomeEndpoint);
    //         //PLV-2903 - Fim - Remover credencial nomeada CIVPORTAL
    //         system.debug('teste ' + resposta);
	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		}
	// 		else {
    //               //PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
    //               responsenew = 'Erro na requisição';
    //             //throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
    //             //PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}
	// 	return responsenew;
	// }
    //MGRC-1657 - FIM
        //Fim da lógica para a história - PVL 2318


    //AVX HACKATHON- Criacao de Transmissao Para Contratação-  Transmissao Contratação - PVL 2318
    //Inicio da lógica para a história - PVL 2389
    //MGRC-1657 - INICIO
	// public String criacaoTransmissao(String entradaTransmissao) {
    //     String responsenew;  
	// 	String body = entradaTransmissao;

	// 	system.debug('rm =============> body =>'); 
	// 	system.debug(body);
        
    //     //Metadado>serviço>Transmissao Contratação
	// 	String nomeEndpoint = 'Transmissao_Contratacao';
	// 	HttpResponse resposta; 

    //     try {
    //         //PLV-2903 - Inicio - Remover credencial nomeada CIVPORTAL
    //         //resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2CIVPORTAL('CIVPORTAL')), body, 60000, nomeEndpoint);
    //         //PLV-3285 - INICIO
    //         resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000, nomeEndpoint); //PLV-4398-INICIO/FIM
    //         //PLV-3285 - FIM
    //         //PLV-2903 - Fim - Remover credencial nomeada CIVPORTAL
	// 		system.debug('resposta');
    //         system.debug(resposta);
            
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
    //             //PLV-2687 - Início - Retorno de erros no CIV Transmissão (erro 500)
    //         //PLV-2948 Fix1 - Inicio/Fim - Remoção de condição na clausula if
	// 		if (resposta.getStatusCode() < 400) {
                
    //                 responsenew = resposta.getBody();

    //         }else{
    //             //PLV-2687 - Fim -  Retorno de erros no CIV Transmissão (erro 500)

    //             //PLV-2411-Sniper - Início - Lógica para tratamento de exceção.
    //              responsenew = 'Erro na requisição';
	// 		   //throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
    //            //PLV-2411-Sniper - Fim - Lógica para tratamento de exceção.
	// 		}
		
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}
    //     System.debug('Returno CIV: ' + responsenew);
	// 	return responsenew;		
	// }
    //MGRC-1657 - FIM
        //Fim da lógica para a história - PVL 2389  

   	//AVX HACKATHON- Criacao de Opções de Serviços-  Opções de Serviços - PVL 2318
    //Inicio da lógica para a história - PVL 2318
    //MGRC-1657 - FIM
    //PLV-4779 - INÍCIO
    public String opcaoServicos(OpcoesServicoTO op) {
        System.debug('SERVICO >>'+JSON.serialize(op));
        String responsenew, body = op.body, method = op.metodo;

        Servico__mdt servico =  this.buscarMetadadoServico(op.servico);
        String endPoint =  String.isNotBlank(servico.Endpoint__c) ? servico.Endpoint__c : '';
        endPoint = Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint' : 'callout:' + servico.NomeCredencial__c + endpoint;
        
        try {
            Map<String, String> Mapheader = this.gerarHeaderOAuth2(this.gerarTokenOAuth2(servico.NomeCredencial__c));
            HttpResponse resposta = Util.executarHttpRequest(endPoint, method, Mapheader, body, 60000);
    
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
            throw new CIVServicesException(mensagemErro + e.getMessage());
        }

        return responsenew; 
    }
    //PLV-4779 - FIM

    //PLV-4891 - INÍCIO
    //MGRC-1657 - INICIO
    public String consultarDocumento(String orcamento) {
        String responsenew;  
		String body = orcamento;

		String nomeEndpoint = 'ConsultarDocumento';
		HttpResponse resposta; 

		try {
            System.debug('PASSOU NO BODY CIV SERVICE'+ body);
    		
            if (Test.isRunningTest()) {
                resposta = new HttpResponse();
                resposta.setStatus('OK');
                resposta.setStatusCode(200);
                resposta.setHeader('Content-Type', 'application/json');
                resposta.setBody('{"jsonResponseCalculo": {"ofertas": [{"resultadoTeste":"ok"}, {"resultadoTeste":"ok"}]}}');
            }
            else {
            //MGRC-1657 - INICIO
                //resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
                resposta.setStatusCode(200);
                resposta.setBody('');
            //MGRC-1657 - FIM
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
			throw new CIVServicesException(mensagemErro + e.getMessage());
		}
		return responsenew;
	}
    //PLV-4891 - FIM
    //PLV-3223 - INÍCIO
    //MGRC-1657 - FIM

    //MGRC-1657 - INICIO
    // public String consultarOferta(String entradaConsultaOferta) {
    //     String responsenew;  
	// 	String body = entradaConsultaOferta;

	// 	String nomeEndpoint = 'Consulta_Ofertas';
	// 	HttpResponse resposta; 

	// 	try {
    //         System.debug('PASSOU NO BODY CIV SERVICE'+ body);
    
	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
            
    //         system.debug('resposta 1= '+ resposta );
    //         system.debug(resposta);
            
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		}
	// 		else {
	// 			responsenew = 'Erro na requisição';
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}
	// 	return responsenew;
	// }
    //PLV-3223 - FIM
    //MGRC-1657 - FIM
    
    // PLV-2015 - INICIO
    //MGRC-1657 - INICIO
	// public String enviaSinistroBCP(String dadosproposta) {
    //     String response;  
    //     String body = dadosproposta;
 
	// 	String nomeEndpoint = 'Envia_Sinistro_BCP';
	// 	HttpResponse resposta; 

	// 	try {
	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);

	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			response = resposta.getBody();
	// 		}
	// 		else {
	// 			throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}

	// 	return response;
	// }
    //MGRC-1657 - FIM
    // PLV-2015 - FIM

    //PLV-4016 - Inicio
    //MGRC-1657 - INICIO
    // public String consultaSessaoLegado(String dadosEntrada) {
    //     String response;  
    //     String body = dadosEntrada;
 
	// 	String nomeEndpoint = 'AutenticacaoLegado';
	// 	HttpResponse resposta; 

	// 	try {
	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);

	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			response = resposta.getBody();
	// 		}
	// 		else {
	// 			response = 'CIV Error';
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}

	// 	return response;
	// }

    //PLV-4016 - Fim

    //PLV-4217 - INICIO = Criacao de chamada de servico para CIV Liquidacao
    // public String civLiquidacao(String entrada) {
    //     String responsenew;  
	// 	String body = entrada;

	// 	system.debug('gfs ============= body'); 
	// 	system.debug(body);
 
	// 	String nomeEndpoint = 'CIVLiquidacao';
	// 	HttpResponse resposta; 

	// 	try {

	// 		resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 60000, nomeEndpoint);
 
	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
	// 			responsenew = resposta.getBody();
	// 		}
	// 		else {
	// 			throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
	// 	}

	// 	return responsenew;
    // }
    //MGRC-1657 - FIM
    //PLV-4217 - FIM

    //PLV-4179 - INICIO       
    public String  integracaoAS(String entrada){
        String METHOD_NAME = 'integracaoAS';

        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => entrada: ' + entrada);
        String requestBody = entrada;
        
        HttpResponse response;
        String responseBody;

        try {
            String endpoint = this.gerarEndpoint('IntegracaoAS');
            response = Util.executarHttpRequest( endpoint, 'POST', this.gerarHeaderOAuth2( this.gerarTokenOAuth2( 'CIV' ) ), requestBody, 60000 );
  
            Integer statusCode = response.getStatusCode();
            responseBody = response.getBody();

            //PLV-5111 - Inicio
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => response.getHeaderKeys(): ' + response.getHeaderKeys());
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => response.getHeader(\'Server\'): ' + response.getHeader('Server'));
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => response.getHeader(\'Content-Length\'): ' + response.getHeader('Content-Length'));
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => response.getHeader(\'Date\'): ' + response.getHeader('Date'));
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => response.getHeader(\'Content-Type\'): ' + response.getHeader('Content-Type'));
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => responseBody: ' + responseBody);
           

            if ( statusCode < 400 || statusCode == 500 ) {
                System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => statusCode: ' + statusCode);

            } else {
                System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => statusCode: ' + statusCode + 'responseBody: ' + responseBody);
                throw new CIVServices.CIVServicesException( 'HTTP ERROR: ' + responseBody );
            }
        }
        catch ( Exception e ) {
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => AS Integration error: ' + e.getCause());

            
            String corpoResposta = '';
            if ( response != null ) {
                corpoResposta = ' - Retorno CIV: ' + responseBody;
            }
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => AS Integration error: ' +  e.getMessage() + ' (line ' + e.getLineNumber() + ')' + corpoResposta);
            throw new CIVServices.CIVServicesException( 'Erro na integração AS: ' + e.getMessage() + ' (linha ' + e.getLineNumber() + ')' + corpoResposta );
        }
        //PLV-5111 - FIM
        system.debug('RESPONSE>>>> ' + response.getStatusCode());
        return responseBody;
    }
    //PLV-4179 - FIM


    //PLV-4449 - INICIO - PEDRO AUGUSTO BRAZ - Cobrança Offline
    //MGRC-1657 - INICIO
    // public void integracaoCartaoOffline(ServiceTO.CobrancaCartaoOfflineTO pEntrada) { 
        
    //     String body = JSON.serialize(pEntrada, true);
    //     String nomeEndpoint = 'CobrancaCartaoOffline';
    //     HttpResponse resposta;
        
    //     try {

    //         system.debug('ENTRADA '+ body);
    //         resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000);

    //         System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
            
            
    //         if (resposta.getStatusCode() > 400) {                
    //             throw new CIVServicesException('CIVServicesException - Body: ' + resposta.getBody());
    //         }
        
    //     }
    //     catch (Exception e) {
    //         System.debug(e.getMessage());
            
    //         String corpoResposta = '';
    //         if(resposta != null){
    //             corpoResposta = ' Retorno CIV: ' + resposta.getBody();
    //         }
            
    //         System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
    //         throw new CIVServicesException('Erro ao realziar cobrança offline linha ' + e.getLineNumber() + ' mensagem: ' + e.getMessage() + corpoResposta);
    //     }
    // }
    //MGRC-1657 - FIM
    //MGRC-1657 - INICIO
    // public void integracaoNovoCartao(ServiceTO.NovoCartaoTO pEntrada) {
        
    //     String body = JSON.serialize(pEntrada, true);
    //     String nomeEndpoint = 'NovoCartao'; // apivida/vida/v1/cartoes/novo
    //     HttpResponse resposta;
    //     try {

    //         system.debug('ENTRADA '+ body);
    //         resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000);

    //         System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
            
            
    //         if (resposta.getStatusCode() > 400) {                
    //             throw new CIVServicesException('CIVServicesException - Body: ' + resposta.getBody());
    //         }
    //     }
    //     catch (Exception e) {
    //         System.debug(e.getMessage());
            
    //         String corpoResposta = '';
    //         if(resposta != null){
    //             corpoResposta = ' Retorno CIV: ' + resposta.getBody();
    //         }
            
    //         System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
    //         throw new CIVServicesException('Erro ao realziar cobrança offline linha ' + e.getLineNumber() + ' mensagem: ' + e.getMessage() + corpoResposta);
    //     }
    // }
    //MGRC-1657 - FIM
    //PLV-4449 - FIM - PEDRO AUGUSTO BRAZ - Cobrança Offline

    //PLV-4544 - Inicio - Isabela Fin
    public String integracaoRecalculoProposta(String body) {
        
        String nomeEndpoint = 'RecalculoProposta'; // apivida/vida/v1/...
        HttpResponse resposta;
        try {
            System.debug('ENTRADA '+ body);
            resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000);
            System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
            if (resposta.getStatusCode() > 400) {                
                throw new CIVServicesException('CIVServicesException - Body: ' + resposta.getBody());
            }
            return resposta.getBody();
        }
        catch (Exception e) {
            System.debug(e.getMessage());
            
            String corpoResposta = '';
            if(resposta != null){
                corpoResposta = ' Retorno CIV: ' + resposta.getBody();
            }
            
            System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new CIVServicesException('Erro ao realizar recálculo da proposta ' + e.getLineNumber() + ' mensagem: ' + e.getMessage() + corpoResposta);
        }
    }
    //PLV-4544 - Fim - Isabela Fin

    //PLV-4361 - Inicio
    //MGRC-1657 - INICIO
	// public String criacaoPropostaSampleMed(String dadosproposta) {
        
    //     String responsenew;   
	// 	String nomeEndpoint = 'IntegracaoSampleMed';
	// 	HttpResponse resposta; 

	// 	try {
			
    //         resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), dadosproposta, 60000, nomeEndpoint);

	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
			
    //             responsenew = resposta.getBody();
			
    //         }else {
			
    //             throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
			
    //         }
            
	// 	}catch (Exception e) {
			
    //         System.debug('###### ERROR: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
		
    //     }

	// 	return responsenew;
    // }
    //MGRC-1657 - FIM
    // PLV-4361 - Fim 
    
    // PLV-4516 INICIO
    //MGRC-1657 - INICIO
    // public String enviarSinistroEmRegulacao(String dadosSinistro) {
        
    //     String responsenew;   
	// 	String nomeEndpoint = 'IntegracaoRegulacaoSinistro';
	// 	HttpResponse resposta; 

	// 	try {
			
    //         resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), dadosSinistro, 60000, nomeEndpoint);

	// 		System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

	// 		if (resposta.getStatusCode() < 400 || resposta.getStatusCode() == 500) {
			
    //             responsenew = resposta.getBody();
			
    //         }else {
			
    //             throw new CIVServicesException('ERROR HTTP ' + resposta.getBody());
			
    //         }
            
	// 	}catch (Exception e) {
			
    //         System.debug('###### ERROR CIV: (' + e.getLineNumber() + '): ' + e.getMessage());
	// 		throw new CIVServicesException(mensagemErro + e.getMessage());
		
    //     }

	// 	return responsenew;
    // }
    //MGRC-1657 - FIM
    //PLV-4516 FIM  

    //INICIO - PLV-4656 Guilherme Brito 
    //MGRC-1657 - INICIO
    public String consultarCEP(String CEPlogradouro, String CEPcomplemento) {
        system.debug('CIVSERVICES');
        System.debug('gerarTokenOAuth2 retorno => ' + this.gerarTokenOAuth2('CIV'));
        String nomeEndpoint = 'Guia_Postal';
		String mensagemErro = 'Erro ao buscar Endereço por CEP.';
        String retorno;
        
		try {
            HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint)
            .replace('#CEPlogradouro', CEPlogradouro)
            .replace('#CEPcomplemento', CEPcomplemento),
            'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), null, 120000, nomeEndpoint);
    
            if(!String.isEmpty(resposta.getBody())) {
                retorno = resposta.getBody();
            }
        
            system.debug('Retorno: ' + retorno);
            return retorno;

        }  catch (Exception e) {
            System.debug('###### ERROR CIV: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new CIVServicesException(mensagemErro + e.getMessage());
        }
    }
    //MGRC-1657 - FIM
    //FIM - PLV-4656 Guilherme Brito
    //PLV-4535 - INICIO
    // public String GerarAtualizacaoMonetaria(String body){

    //     String nomeEndPoint = 'AtualizacaoMonetaria';
    //     HttpResponse resposta; 

    //     resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000);
        
    //     System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

    //     return resposta.getBody();
    // }

    //MGRC-1657 - INICIO
    // public String GeraAtualizacaoTaxaJuros(String body){

    //     String nomeEndPoint = 'TaxaJuros';
    //     HttpResponse resposta;

    //     resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000);
    //     System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

    //     return resposta.getBody();
    // }
    //MGRC-1657 - FIM

    //PLV-4535 - FIM
    //PLV-4891 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    //MGRC-1657 - INICIO
    // public String criarArquivo(String body){

    //     String nomeEndPoint = 'CriarArquivo';
    //     HttpResponse resposta;

    //     resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000);
    //     System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());

    //     return resposta.getBody();
    // }
    //MGRC-1657 - FIM
    //PLV-4891 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

    //PLV-4883 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    //MGRC-1657 - INICIO
    // public String proxyAutomacao(String pRequest){
    //     /*
    //         exemplo de BODY OBRIGATÓRIO
    //         {
    //             "api": "/services/apexrest/usertools",
    //             "payload": {
    //                 "batch": [
    //                         {
    //                             "name": "BatchGerarPDF",
    //                             "tempo": "",
    //                             "descricao": "",
    //                             "agendado": false
    //                         }
    //                     ]
    //             }
    //             "metodo":"POST",
    //             "stripNull":false
    //         }
    //     */
    //     if(String.isblank(pRequest))return null;
    //     Map<String,Object> requestToSend = (Map<String,Object>) JSON.deserializeUntyped(pRequest);
    //     Map<String,Object> responseToReturn = new Map<String,Object>();
        
    //     String api = requestToSend.containsKey('api') ? (String)requestToSend.get('api'):'';
    //     String metodo = requestToSend.containsKey('metodo') ? (String)requestToSend.get('metodo') : '';
    //     Boolean stripnull = requestToSend.containsKey('stripnull') ? (Boolean)requestToSend.get('stripnull') : false; //VALOR PADRÃO DA API false, ou seja, manda itens nullos no body;
    //     String payload = requestToSend.containsKey('payload') && metodo!='GET' ? JSON.serialize(requestToSend.get('payload'),stripnull): null;
    //     if(String.isNotBlank(api) && api.left(1)!='/')
    //         requestToSend.put('api','/'+(String)requestToSend.get('api'));
    //     System.debug('### payload s: ' + payload);

    //     String nomeEndPoint = 'AutomacaoSF';
    //     HttpResponse resposta;
    //     resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint)+api, metodo, this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), payload, 120000);
    //     System.debug('### pRequest: ' + pRequest);
    //     System.debug('### API: ' + this.gerarEndpoint(nomeEndpoint)+api);
    //     System.debug('### Metodo: ' + metodo);
    //     System.debug('### Payload: ' + payload);
    //     System.debug('### Strip Null: ' + stripnull);
    //     System.debug('### Status: ' + resposta.getStatusCode() + ', Body: ' + resposta.getBody());
    //     Map<String,String> headersToReturn = new Map<String,String>();
    //     if(!resposta.getHeaderKeys().isEmpty()){
    //         for(String hk : resposta.getHeaderKeys()){
    //             headersToReturn.put(hk,resposta.getHeader(hk));
    //         }
    //     }
    //     try {
    //         Map<String,Object> bodyToreturn = String.isNotBlank(resposta.getBody()) ? (Map<String,Object>)JSON.deserializeUntyped(resposta.getBody()): null;
    //         responseToReturn.put('responsebody',bodyToreturn);
    //     } catch (Exception e) {
    //         List<Object> bodyToreturn = String.isNotBlank(resposta.getBody()) ? (List<Object>)JSON.deserializeUntyped(resposta.getBody()): null;
    //         responseToReturn.put('responsebody',bodyToreturn);
    //     }
    //     responseToReturn.put('code',resposta.getStatusCode());
    //     responseToReturn.put('headers',headersToReturn);
    //     responseToReturn.put('body',resposta.getBody());
    //     System.debug('### responseToReturn: ' + JSON.serialize(responseToReturn));
    //     return JSON.serialize(responseToReturn);
    // }
    //MGRC-1657 - FIM
    //PLV-4883 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

    //PLV-5675 - INICIO
    public String sendDocusign(String body) {
        system.debug('CIVSERVICES');
        
        String nomeEndpoint = 'CivDocusign';
		String mensagemErro = 'Erro ao enviar para o CIV.';
        String retorno;

        
		try {
            HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 
            'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('CIV')), body, 120000);
    
            if(!String.isEmpty(resposta.getBody())) {
                retorno = resposta.getBody();
            }
                        
            return retorno;

        }  catch (Exception e) {
            System.debug('###### ERROR CIV: (' + e.getLineNumber() + '): ' + e.getMessage());
            throw new CIVServicesException(mensagemErro + e.getMessage());
        }
    }
    //PLV-5675 - FIM

    public class CIVServicesException extends Exception { }
}