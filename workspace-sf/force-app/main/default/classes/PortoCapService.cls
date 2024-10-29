/*****************************************************

	 Interface para chamadas dos serviço a Porto Cap

*******************************************************/
public class PortoCapService extends ServiceBase {

	private static final PortoCapService instance = new PortoCapService();

	private PortoCapService() { }

	public static PortoCapService getInstance() {
		return instance;
	}

	//Solicita titulos na PortoCap
	public List<ServiceTO.RetornoPortoCapTO> solicitarRecompraTitulos(List<TituloCapitalizacaoTO> listTituloCapitalizacaoTO){
        String body = JSON.serialize(listTituloCapitalizacaoTO);
        System.debug('solicitarRecompraTitulos');
        System.debug(body);

        List<ServiceTO.RetornoPortoCapTO> listRetornoPortoCap;

        try {
            HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('SolicitarTitulosPortoCap'), 'POST', new Map<String, String>{'content-type' => 'application/json'}, body, 60000);

            if (resposta.getStatusCode() < 400) {
                listRetornoPortoCap = (List<ServiceTO.RetornoPortoCapTO>)JSON.deserialize(resposta.getBody(), List<ServiceTO.RetornoPortoCapTO>.class);
            }
            else {
                throw new PortoCapServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
            }
        }
        catch (Exception e) {
            System.debug(e.getMessage());
            throw new PortoCapServiceException('Erro ao enviar título de capitalização para a PortoCap.' + e.getMessage());
        }

        return listRetornoPortoCap;
    }

    //Recupera titulos na PortoCap
    public GarantiaContratoTO.RetornoConsultaTitulosTO recuperarTitulosSolicitados(GarantiaContratoTO.DadosPortoCap parametroPortoCap) {
	    GarantiaContratoTO.RetornoConsultaTitulosTO tempList = new GarantiaContratoTO.RetornoConsultaTitulosTO();
	    String body = JSON.serialize(parametroPortoCap);

	    try {
	      HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('PortoCapTitulo'), 'POST', new Map<String, String>{'content-type' => 'application/json'}, body, 60000);

	      if (resposta.getStatusCode() < 400) {
	        tempList = (GarantiaContratoTO.RetornoConsultaTitulosTO)JSON.deserialize(resposta.getBody(), GarantiaContratoTO.RetornoConsultaTitulosTO.class);
	      }
	      else {
	        throw new PortoCapServiceException('ERROR HTTP ' + resposta.getStatusCode());
	      }
	    }
	    catch (Exception e) {
	      System.debug(e.getMessage());
	      throw new PortoCapServiceException('Erro ao efetuar Consulta PortoCAP Titulos].' + e.getMessage());
	    }

	    return tempList;
  	}

	public class PortoCapServiceException extends Exception { }
}