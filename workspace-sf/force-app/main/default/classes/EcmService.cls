/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pela implementação do serviço da ECM
 *
 **************************************************************************************************************************************************************************/
public class EcmService extends ServiceBase {

  private static final EcmService instance = new EcmService();
  private String nomeEndpoint = 'ECM';

  private EcmService() { }

  public static EcmService getInstance() {
    return instance;
  }

  /**
   * Retorna uma lista do serviço externo
   */
  public String gerarToken() {
    EcmTO respostaTo = new EcmTO();

    try {
		String body = 'username={!$Credential.Username}&password={!$Credential.Password}';
      	HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'POST', new Map<String, String>{'Content-Type' => 'application/x-www-form-urlencoded'}, body, 60000);

		if (resposta.getStatusCode() < 400) {
      System.debug('resposta> ' + JSON.serialize(resposta.getBody()));
			respostaTo = (EcmTO)JSON.deserialize(resposta.getBody(), EcmTO.class);

			if (String.isNotBlank(respostaTo.status)) {
				throw new EcmServiceException(respostaTo.codigo + ' - ' + respostaTo.mensagem);
			}
		}
		else {
			throw new EcmServiceException('ERROR HTTP ' + resposta.getStatusCode());
		}
    }
    catch (Exception e) {
      System.debug(e.getMessage());
      throw new EcmServiceException('ECM ' + e.getMessage());
    }

    return respostaTo.ticket;
  }

   /**
   * Retorna uma lista do serviço externo
   */
  public HttpResponse buscarDocumento(String codigoDocumento) {
    HttpResponse resposta;

    try {
        // PLV-1393-27-v5 - INICIO
        resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint) + '?id=' + codigoDocumento, 'GET' , this.gerarHeaderOAuth2(CIVServices.getInstance().gerarTokenOAuth2('CIV')), null, 60000);
        // PLV-1393-27-v5 - FINAL

      System.debug('RESPOSTA DO ECM --------------------------------------------------------------------- ' + resposta);
      System.debug('resposta.getStatusCode() ------------------------------------------------------------ ' + resposta.getStatusCode());

		if (resposta.getStatusCode() >= 400) {
			throw new EcmServiceException('ERROR HTTP ' + resposta.getStatusCode());
		}
    }
    catch (Exception e) {
      System.debug(e.getMessage());
      throw new EcmServiceException('ECM ' + e.getMessage());
    }

    return resposta;
  }

   /**
   * Everymind | Fábio Rente - 30/04/2019
   */
  public RetornoDocumentoIdEntradaTO buscarDocumentoId(BuscarDocumentoIdEntradaTO payload) {
    HttpResponse resposta;

    try {
      Map<String, String> headers = new Map<String, String> {
        'content-type' => 'application/json'
      };

      resposta = Util.executarHttpRequest(this.gerarEndpoint('ConsultaArquivosECM'), 'POST', headers, JSON.serialize(payload), 60000);

      if (resposta.getStatusCode() >= 400) {
        throw new EcmServiceException('ERROR HTTP ' + resposta.getStatusCode());
      }
    }
    catch (Exception e) {
      System.debug(e.getMessage());
      throw new EcmServiceException('ECM ' + e.getMessage());
    }

    return (RetornoDocumentoIdEntradaTO)JSON.deserialize(resposta.getBody(), RetornoDocumentoIdEntradaTO.class );
  }

  public class EcmTO {
    public String ticket {get; set;}
    public String status {get; set;}
    public String codigo {get; set;}
    public String mensagem {get; set;}
    // PLV-1393-27-v5 - INICIO
    public String base64 {get; set;}
    // PLV-1393-27-v5 - FINAL
  }

  /**
   * Everymind | Fábio Rente - 30/04/2019
   */
  public class AttrList
  {
      public String attr { get; set; }
      public String valor { get; set; }
  }

  /**
   * Everymind | Fábio Rente - 30/04/2019
   */
  public class BuscarDocumentoIdEntradaTO{
    public List<AttrList> attrList { get; set; }
  }

  public class RetornoDocumentoIdEntradaTO{
    public String id { get; set; }
  }
  
 public class EcmServiceException extends Exception { }
}