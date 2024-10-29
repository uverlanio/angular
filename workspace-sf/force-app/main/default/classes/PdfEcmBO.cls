/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pelo negócio das manipulações de conteúdo do ECM
 *
 **************************************************************************************************************************************************************************/
public class PdfEcmBO {
	private static final PdfEcmBO instancia = new PdfEcmBO();
	private GarantiaProdutoDAO dao = GarantiaProdutoDAO.getInstance();
	private EcmService servico = EcmService.getInstance();

	private PdfEcmBO() {
	}

	public static PdfEcmBO getInstance(){
		return instancia;
	}

	//Retorna dominio de serviço
  	public String buscarDominioSf(){
  		String nomeSandbox = '';
		Site siteApi = [SELECT Subdomain FROM Site Where Name = 'Api' Limit 1 ];
		Organization org = [Select IsSandbox, InstanceName From Organization Limit 1];

		if(org.IsSandbox){
			nomeSandbox = UserInfo.getUserName().substringAfterLast('.') + '-';
		}

		return 'https://' + nomeSandbox + siteApi.Subdomain + '.' + org.InstanceName + '.force.com';
  	}

  	//Retorna código de documento no ECM
  	public String buscarCodigoEcmDocumento(String objetoId){
  		Map<String, Schema.SObjectType> globalDescribe  = Schema.getGlobalDescribe();
  		String prefixoObjeto = objetoId.substring(0, 3);
  		String idDocumentoEcm = '';

  		if(prefixoObjeto == globalDescribe.get('Contract').getDescribe().getKeyPrefix()){
  			idDocumentoEcm = ContractBO.getInstance().buscarContratos(new Set<Id>{objetoId}).get(0).IdContrato__c;
  		}
  		else if(prefixoObjeto == globalDescribe.get('Fatura__c').getDescribe().getKeyPrefix()){
  			idDocumentoEcm = FaturaBO.getInstance().buscarFaturas(new Set<Id>{objetoId}).get(0).IdFatura__c;
  		}

  		return idDocumentoEcm;
  	}

    // PLV-1393-27 - INICIO
  	//Retorna código de documento no ECM
  	public Blob buscarDocumento(String codigoDocumento){ 
  		Blob documento;
  		HttpResponse resposta;

  		try {
  			resposta = servico.buscarDocumento(codigoDocumento);
        
	  		EcmService.EcmTO respostaTo = (EcmService.EcmTO)JSON.deserialize(resposta.getBody(), EcmService.EcmTO.class);
        // PLV-1393-27-v5 - INICIO
        System.debug('buscarDocumento = ' + resposta.getBody());
        System.debug('buscarDocumento = ' + JSON.serialize(respostaTo));
        System.debug('buscarDocumento = ' + respostaTo.base64);
        documento = EncodingUtil.base64Decode(respostaTo.base64);
        // PLV-1393-27-v5 - FINAL

  		} catch(Exception ex) {
  			documento = resposta.getBodyAsBlob();
  		}

  		return documento;
  	}
    // PLV-1393-27 - FINAL

  	public class PdfEcmBOException extends Exception { }

}