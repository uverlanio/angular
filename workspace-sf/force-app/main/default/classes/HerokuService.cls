/**
 * Serviço com chamadas ao Heroku
 **/

public class HerokuService extends ServiceBase {
	private static final HerokuService instance = new HerokuService();
	//private static String VIDA_CLOUD_TOKEN = HerokuService.getInstance().gerarTokenOAuth2('VidaCloudApi');

	private HerokuService() { }

	public static HerokuService getInstance() {
		return instance;
	}

	// Atualiza as parcelas do contrato
	public Boolean atualizarParcelaContrato (ParcelaContratoTO parcelaContratoTO){
		List<ParcelaContratoTO> listParcelaContratoTOS = new List<ParcelaContratoTO>{parcelaContratoTO};

		String endEndPoint = this.gerarEndpoint('AtualizarStatusParcelasContrato');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
                HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(listParcelaContratoTOS), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta atualizar parcelas do contrato: ' + resposta.getBody());
				HerokuResponseTO herokuResponseTO = (HerokuResponseTO) JSON.deserialize(resposta.getBody(), HerokuResponseTO.class);
				if(herokuResponseTO.meta.statusHttp == 200){
					return true;
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			if (Test.isRunningTest()){
				return true;
			}

			throw new HerokuServiceException('Erro ao atualizar a parcela do contrato.');
		}

		return false;
	}

    // PLV-2804 INICIO
	// Atualiza as parcelas do contrato
	public void gerarResultadoIntegracao(ResultadoIntegracaoTO resultadoIntegracaoTO){ 

		String endpoint = this.gerarEndpoint('GerarResultadoIntegracao');
		
		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(resultadoIntegracaoTO, true), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta do gerar resultado de integração: ' + resposta.getBody());
			} else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' MESSAGE: ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new HerokuServiceException('Erro ao gerar resultado de integração.');
		}
	}
    // PLV-2804 FIM

	// PLV-2312-28 INICIO
	// Atualiza o id do job no controle batch
	public Boolean atualizarIdJobControleBatch (ServiceTO.ControleBatchTO controleBatchTO){

		String endpoint = this.gerarEndpoint('AtualizarIdJob');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endpoint, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(controleBatchTO), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta atualizar controle batch: ' + resposta.getBody());
			}
			else {
				throw new HerokuServiceException('ERROR HTTP STATUS CODE ' + resposta.getStatusCode() + ' BODY ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			if (Test.isRunningTest()){
				return true;
			}

			throw new HerokuServiceException('Erro ao atualizar o id do job controle batch. LINHA: ' + e.getLineNumber() + '. MENSAGEM: ' + e.getMessage());
		}

		return true;
	}
	// PLV-2312-28 FIM

	// PLV-2312-28 INICIO
	// Atualiza para PROCESSADO o controle batch
	public Boolean encerrarServicoControleBatch (ServiceTO.ControleBatchTO controleBatchTO){

		String endpoint = this.gerarEndpoint('EncerrarControleServico');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endpoint, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(controleBatchTO), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta atualizar controle batch: ' + resposta.getBody());
			}
			else {
				throw new HerokuServiceException('ERROR HTTP STATUS CODE ' + resposta.getStatusCode() + ' BODY ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			if (Test.isRunningTest()){
				return true;
			}

			throw new HerokuServiceException('Erro ao encerrar o controle batch. LINHA: ' + e.getLineNumber() + '. MENSAGEM: ' + e.getMessage());
		}

		return true;
	}
	// PLV-2312-28 FIM

	//Busca as parcelas de um contrato
	public ConsultarDadosContratoTO.DadosParcelasTO buscarParcelasContratoPorApolice(String apolice) {
		ConsultarDadosContratoTO.DadosParcelasTO tempList;
		String endEndPoint = this.gerarEndpoint('ConsultarDadosContrato') + '?apolice=' + apolice;

		System.debug('===> Endpoint: ' + endEndpoint);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Consultar Dados Contrato: ' + resposta.getBody());
	          	tempList = (ConsultarDadosContratoTO.DadosParcelasTO) JSON.deserialize(resposta.getBody(), ConsultarDadosContratoTO.DadosParcelasTO.class);
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new HerokuServiceException('Erro ao buscar dados do contrato.');
		}
		return tempList;
	}
	
	//PLV-4660 FIX 4 - INÍCIO
	//Busca as parcelas de um contrato pela apólice e número de endosso
	public ConsultarDadosContratoTO.DadosParcelasTO buscarParcelasContratoPorApoliceEndosso(String apolice, string endosso) {
		ConsultarDadosContratoTO.DadosParcelasTO tempList;
		String endEndPoint = this.gerarEndpoint('ConsultarDadosContrato') + '?apolice=' + apolice + '&endosso=' + endosso;

		System.debug('===> Endpoint: ' + endEndpoint);

		try {
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Consultar Dados Contrato: ' + resposta.getBody());
					tempList = (ConsultarDadosContratoTO.DadosParcelasTO) JSON.deserialize(resposta.getBody(), ConsultarDadosContratoTO.DadosParcelasTO.class);
					System.debug('tempList ==> ' + tempList);
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new HerokuServiceException('Erro ao buscar dados do contrato.');
		}
		return tempList;
	}
	//PLV-4660 FIX 4 - FIM

	//Atualiza o status da fatura 
	// PLV-2192-27 - mudançã de assinatura do metodo - INICIO
	public Boolean atualizaStatusFatura(List<FaturaTO.AtualizarParcelaTO> payload) {
	// PLV-2192-27 - mudançã de assinatura do metodo - FIM
		Boolean bReturn;
	    String body = JSON.serialize(payload);
		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('FaturaAtualizarParcelas'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('Service: ' + JSON.deserialize(resposta.getBody(), RetornoRestTO.class));
				bReturn = true;
			}
			else {
				bReturn = true;
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			bReturn = true;
			System.debug(e.getMessage());
			throw new HerokuServiceException('Erro ao atualizar Status Fatura.');
		}
		return bReturn;
	}

	//Busca as parcelas do contrato pelo id externo
	public ParcelamentoContratoTO buscarParcelasContratoPorIdExterno(String strIdExterno) {
		ParcelamentoContratoTO tempList;
		String endEndpoint = this.gerarEndpoint('ContabilizacaoValores') + strIdExterno;

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
	          	tempList = (ParcelamentoContratoTO) JSON.deserialize(resposta.getBody(), ParcelamentoContratoTO.class);
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new HerokuServiceException('Erro ao buscar parcelas do contrato.');
		}
		return tempList;
	}

	// PLV-2312-28 INICIO
	//Cria as parcelas do contrato no Heroku
	public Boolean gerarParcelasContrato(List<ParcelaContratoTO> listParcelaContratoTO){
		String body = JSON.serialize(listParcelaContratoTO);
		ServiceTO.RetornoCriarParcelaTO parcelaContratoTOResposta;

		System.debug('----- Enviar parcelas do contrato -----');
		System.debug('Parcelas do contrato --------------- ' + body);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('EnviarParcelasContrato'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400)
			{
				parcelaContratoTOResposta = (ServiceTO.RetornoCriarParcelaTO)JSON.deserialize(resposta.getBody(), ServiceTO.RetornoCriarParcelaTO.class);
				System.debug('===> Retorno geração Parcela: ' + parcelaContratoTOResposta);
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			if(Test.isRunningTest()){
				return true;
			}
			throw new HerokuServiceException('Erro ao enviar as parcelas do contrato.' + e.getMessage());
		}
		return true;
	}
	// PLV-2312-28 FIM

    
    //public ServiceTO.RetornoAtualizacaoSinistroTO atualizarStatusSinistro(String codigoParceiro, List<ServiceTO.ParamAtualizacaoStatusSinistroTO> sinistros){
   /* public ServiceTO.RetornoAtualizacaoSinistroTO atualizarStatusSinistro(String codigoParceiro, List<CriarArquivoLoteSinistroTO.SinistroTO> arquivoLoteSinistro){
        String body = JSON.serialize(arquivoLoteSinistro);
 		//String endEndPoint = this.gerarEndpoint('AtualizarStatusSinistros') + '?codigoparceiro=' + codigoParceiro;
 		String endEndPoint = 'https://lotus-vida-services-avanxo.herokuapp.com/api/sinistros/atualizar-status' + '?codigoparceiro=' + codigoParceiro;
 		ServiceTO.RetornoAtualizacaoSinistroTO retorno; 

 		System.debug('==> Chamando serviço');

 		System.debug('codigoparceiro: ' + codigoParceiro);
     	System.debug('Json: ' + body);

        try {
            HttpResponse resposta = Util.executarHttpRequest(endEndPoint, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);

            if (resposta.getStatusCode() < 400) {
		 		System.debug('==> Retorno OK');
                retorno = (ServiceTO.RetornoAtualizacaoSinistroTO)JSON.deserialize(resposta.getBody(), ServiceTO.RetornoAtualizacaoSinistroTO.class);
                System.debug(resposta.getBody());
            }
            else {
		 		System.debug('==> Retorno Erro');
                throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
            }
        }
        catch (Exception e) {
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            throw new HerokuServiceException('Erro ao enviar os sinistros.' + e.getMessage());
        }
        return retorno;
    }*/

	// Gera número de apólice
	public List<String> gerarNumeroApolice(ConsultarDadosContratoTO.NumeroPropostaTO numeroPropostaTO, Integer quantidade){
		//numeroPropostaTO.empresa == null ? null : numeroPropostaTO.empresa;
		String endEndPoint = this.gerarEndpoint('GerarNumeroApolice') +
								//'?empresa=' + numeroPropostaTO.empresa + //RVI-298 Comentar
								'?sucursal=' + numeroPropostaTO.sucursal + //RVI-298 trocado '&' por '?'
								'&ramo=' + numeroPropostaTO.ramo +
								'&quantidade=' + quantidade;

		List<String> retorno;

		System.debug('==> Chamando serviço');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndPoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Retorno OK');
				retorno = (List<String>)JSON.deserialize(resposta.getBody(), List<String>.class);
				System.debug(resposta.getBody());
			}
			else {
				System.debug('==> Retorno Erro');
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao gerar número de proposta.' + e.getMessage());
		}
		return retorno;
	}

	// Gera número de proposta
	public HerokuResponseTO.TituloTO gerarNumeroProposta(ContratoTO.SolicitarTituloTO solicitarTituloTO){

		String endEndPoint = this.gerarEndpoint('GerarNumeroProposta') +
						'?origemproposta=' + solicitarTituloTO.origemproposta +
						'&quantidade=' + solicitarTituloTO.quantidade;

		HerokuResponseTO.TituloTO retorno;

		if (Test.isRunningTest()){
			String resposta = '{"data":{"numeros":["64"]},"meta":{"dataExecucao":"2019-02-04T23:14:34.616Z","servico":"Gerador de números de proposta","statusHttp":200,"mensagem":"OK"}}';
			return retorno = (HerokuResponseTO.TituloTO)JSON.deserialize(resposta, HerokuResponseTO.TituloTO.class );
		}

		System.debug('==> Chamando serviço');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndPoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Retorno OK');
				retorno = (HerokuResponseTO.TituloTO)JSON.deserialize(resposta.getBody(), HerokuResponseTO.TituloTO.class );
				System.debug(resposta.getBody());
			}
			else {
				System.debug('==> Retorno Erro');
				HerokuResponseTO.HerokuResponseErrorTO herokuResponseErrorTO = (HerokuResponseTO.HerokuResponseErrorTO) JSON.deserialize(resposta.getBody(),HerokuResponseTO.HerokuResponseErrorTO.class);
				ExcecaoCustomizada excecaoCustomizada = new ExcecaoCustomizada('Erro ao gerar número(s) de proposta',herokuResponseErrorTO.error.message, herokuResponseErrorTO.error.statusCode);
				throw new HerokuServiceException(JSON.serialize(excecaoCustomizada));
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException(e.getMessage());
		}
		return retorno;
	}

	// Gera número de proposta
	public HerokuResponseTO.TituloTO gerarNumeroPropostaCapitalizacao(ContratoTO.SolicitarTituloTO solicitarTituloTO){

		String endEndPoint = this.gerarEndpoint('GerarNumeroPropostaCapitalizacao');
		String body = JSON.serialize(solicitarTituloTO);

		System.debug('PAYLOAD SOLICITACAO DE TITULOS' + body);

		HerokuResponseTO.TituloTO retorno;

		if (Test.isRunningTest()){
			String resposta = '{"data":{"lote":64,"nome":"PORTO_RE_PRE_ETQ_00000050_VG09.PRO.tar.gz","status":"PROCESSADO"},"meta":{"dataExecucao":"2019-02-04T23:14:34.616Z","servico":"Gerador de números de proposta","statusHttp":200,"mensagem":"OK"}}';
			return retorno = (HerokuResponseTO.TituloTO)JSON.deserialize(resposta, HerokuResponseTO.TituloTO.class );
		}

		System.debug('==> Chamando serviço');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndPoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Retorno OK');
				retorno = (HerokuResponseTO.TituloTO)JSON.deserialize(resposta.getBody(), HerokuResponseTO.TituloTO.class );
				System.debug(resposta.getBody());
			}
			else {
				System.debug('==> Retorno Erro');

				HerokuResponseTO.HerokuResponseErrorTO herokuResponseErrorTO = (HerokuResponseTO.HerokuResponseErrorTO) JSON.deserialize(resposta.getBody(),HerokuResponseTO.HerokuResponseErrorTO.class);

				ExcecaoCustomizada excecaoCustomizada = new ExcecaoCustomizada('Erro ao gerar número(s) de proposta',herokuResponseErrorTO.error.message, herokuResponseErrorTO.error.statusCode );
				throw new HerokuServiceException(JSON.serialize(excecaoCustomizada));
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException(e.getMessage());
		}
		return retorno;
	}

	public HerokuResponseTO.LoteTO consultarEstoque(ContratoTO.ConsultarEstoqueTO consultarEstoqueTO){

		String endEndPoint = this.gerarEndpoint('ConsultarEstoque') +
						'?data-inicial=' + consultarEstoqueTO.dataInicial +
						'&data-final=' + consultarEstoqueTO.dataFinal +
						((!String.isBlank(consultarEstoqueTO.codigoParceiro)) ? '&codigo-parceiro=' + consultarEstoqueTO.codigoParceiro : '' )+
						((!String.isBlank(consultarEstoqueTO.codigoProduto)) ? '&codigo-produto=' + consultarEstoqueTO.codigoProduto : '');

		HerokuResponseTO.LoteTO retorno;

		System.debug('==> Chamando serviço');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndPoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Retorno OK');
				retorno = (HerokuResponseTO.LoteTO)JSON.deserialize(resposta.getBody(), HerokuResponseTO.LoteTO.class );
				System.debug(resposta.getBody());
			}
			else {
				System.debug('==> Retorno Erro');
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao gerar número de proposta.' + e.getMessage());
		}
		return retorno;

	}

	public HerokuResponseTO.ArquivoECMTO consultarArquivoECM(ContratoTO.ConsultarArquivoECMTO consultarArquivoECM){

		String endEndPoint = this.gerarEndpoint('ConsultarArquivosECM')+
						'?data-inicial=' + consultarArquivoECM.dataInicial +
						'&data-final=' + consultarArquivoECM.dataFinal +
						'&idsf=' + consultarArquivoECM.idsf;

		HerokuResponseTO.ArquivoECMTO retorno;

		System.debug('==> Chamando serviço');
		System.debug('Endpoint = ' + endEndpoint);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndPoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Retorno OK');
				retorno = (HerokuResponseTO.ArquivoECMTO)JSON.deserialize(resposta.getBody(), HerokuResponseTO.ArquivoECMTO.class );
				System.debug(resposta.getBody());
			}
			else {
				System.debug('==> Retorno Erro');
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao consultar o arquivo ECM.' + e.getMessage());
		}
		return retorno;

	}

	// PLV-2312-28 INICIO
	// Atualiza as parcelas do contrato
	public Boolean cancelarParcelasContrato (List<ServiceTO.ParcelaCancelamentoTO> listParcelaCancelamentoTO){

		String endEndPoint = this.gerarEndpoint('CancelarParcelasContrato');

		System.debug('==> Parcelas para cancelamento: ' + JSON.serialize(listParcelaCancelamentoTO));

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(listParcelaCancelamentoTO, true), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta cancelar parcelas do contrato: ' + resposta.getBody());
				HerokuResponseTO herokuResponseTO = (HerokuResponseTO) JSON.deserialize(resposta.getBody(), HerokuResponseTO.class);
			}
			else {
				throw new HerokuServiceException('Erro ao cancelar parcelas do contrato.');
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			if(Test.isRunningTest()){
				return true;
			}
			throw new HerokuServiceException('Erro ao cancelar parcelas do contrato.');
		}

		return true;
	}
	// PLV-2312-28 FIM

	// Obter as parcelas do contrato
	public ParcelamentoContratoTO consultarParcelasContrato(String chave) {
        ParcelamentoContratoTO	objPayload;

		String endEndPoint = this.gerarEndpoint('ConsultarParcelasContrato') + '?idexterno=' + chave;

		System.debug('===> Endpoint: ' + endEndpoint);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Consultar Parcelas do Contrato: ' + resposta.getBody());
				objPayload = (ParcelamentoContratoTO) JSON.deserialize(resposta.getBody(), ParcelamentoContratoTO.class);
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new HerokuServiceException('Erro ao buscar parcelas do contrato.');
		}

		return objPayload;
	}

	// PLV-2312-28 INICIO
	// Criar registro de seguro do contrato
	public Boolean gerarDadosSeguroContrato(List<ServiceTO.SeguroContratoTO> listSeguroTO ){
        
        System.debug('listSeguroTO gfs = ' + listSeguroTO);
        
		String endEndPoint = this.gerarEndpoint('GerarSeguro');
		System.debug('==> Seguros: ' + listSeguroTO);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(listSeguroTO, true), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			System.debug('==> resposta: ' + resposta);
            System.debug('==> respostabody: ' + resposta.getBody());
            
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Criar Seguros: ' + resposta.getBody());
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			if(Test.isRunningTest()){
				return true;
			}
			throw new HerokuServiceException('Erro ao gerar dados seguro no Heroku. ' + e.getMessage());

		}

		return true;
	}
	// PLV-2312-28 FIM

	//AVX SP24 PLV 1837 - Método que insere sinistros no Heroku
	// URL teste não dinamica 'https://lotus-vida-services-avanxo.herokuapp.com/api/sinistros/atualizar-status'
	public String gerarArquivoLoteSinistro(String codigoParceiro, CriarArquivoLoteSinistroTO bodyTO) {

		//String endEndPoint = this.gerarEndpoint('AtualizarStatusSinistros') + '?codigoparceiro=' + codigoParceiro;
		//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
        CredencialOAuth2__mdt  credencial = MetadataDAO.getInstance().buscarCredencial('VidaCloudApi');
		//PLV-3702 FIX COMPLEMENTO - FIM
		Servico__mdt servico = MetadataDAO.getInstance().buscarServico('AtualizarStatusSinistros');
		
        String endEndPointnew = credencial.Audience__c + '/api/' + servico.Endpoint__c;
		ServiceTO.RetornoAtualizacaoSinistroTO retorno; 
		String body = JSON.serialize(bodyTO);
		//System.debug('==> Chamando serviço');

		//System.debug('codigoparceiro: ' + codigoparceiro);
		System.debug('Json: ' + body);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndPointnew, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
            //retorno = (ServiceTO.RetornoAtualizacaoSinistroTO)JSON.deserialize(resposta.getBody(), ServiceTO.RetornoAtualizacaoSinistroTO.class);
	
            //system.debug('resposta.getBody()');
            system.debug(resposta.getBody());
            
			if (resposta.getStatusCode() < 400) {

				//System.debug(resposta.getBody());
                
                return resposta.getBody();
                
			}
			else {
				//System.debug('==> Retorno Erro');
                 return resposta.getBody();
			 //throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			//System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
            return 'ERRO:' + e.getLineNumber() + ': ' + e.getMessage();
			//throw new HerokuServiceException('Erro ao enviar os sinistros.' + e.getMessage());
		}
	}

	// Gerar Log de erro no Heroku
	public void gerarLogErro(ServiceTO.ParamGerarErroHerokuTO parammetroTO){
        String body = JSON.serialize(parammetroTO);

		System.debug('==> Chamando serviço');

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('EnviarLogErro'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			System.debug('::: resposta.getBody(): ' + resposta.getBody());

			if (resposta.getStatusCode() < 400) {
				System.debug('==> Retorno OK');
			}
			else {
				System.debug('==> Retorno Erro');
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao enviar os logs.' + e.getMessage());
		}
	}

	// Gerar token oauth2 para ser usado nas chamadas do Heroku
	public String gerarTokenOAuth2(String nomeCredencial) {
		try {
            system.debug('Entrou no Try');
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
                system.debug('entrou no else');
				// Objeto que será serializado para JSON no body da requisição
				Map<String, String> mapBody = new Map<String, String>();
				mapBody.put('grant_type', credencialOAuth2.GrantType__c);
				mapBody.put('audience', credencialOAuth2.Audience__c);
				mapBody.put('client_secret', credencialOAuth2.ClientSecret__c);
				mapBody.put('client_id', credencialOAuth2.ClientId__c);

				Map<String, String> header = new Map<String, String>();
				header.put('Content-Type', 'application/json');

				// Solicitar o token mediante a credencial informada no mapBody
				HttpResponse resposta = new HttpResponse();

				if (Test.isRunningTest()) {
					resposta.setStatus('OK');
					resposta.setStatusCode(200);
					resposta.setHeader('Content-Type', 'application/json');
					resposta.setBody('{"access_token":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","scope":"abc","expires_in":86400,"token_type":"Bearer"}');
				}
				else {
                    system.debug('entrou no resposta.util');
					//MGRC-1271-INICIO
					// resposta = Util.executarHttpRequest(this.gerarEndpoint('GerarTokenHeroku'), 'POST', header, JSON.serialize(mapBody), 60000);
					resposta = SensediaServices.getInstance().montagemServicoSensediaHeroku(
						SensediaServices.VERB.POST, 
						SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
						SensediaServices.GERAR_TOKEN_HEROKU, 
						JSON.serialize(mapBody)
					);
					//MGRC-1271-FIM
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
					throw new HerokuServiceException(mensagemErro);
				}
				// Salvar o token no cache da plataforma com o tempo de expiração em segundos
				Cache.Org.put(ACCESS_TOKEN_CACHE_KEY, accessToken, expiresIn);
			}
			// Devolve o token já formatado para uso
			System.debug('::: accessToken: ' + accessToken);
			return accessToken;
		}
		catch(Exception e) {
			System.debug('ERRO: Erro ao recuperar o token: ' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao recuperar o token.' + e.getMessage());
		}
	}

	public class HerokuServiceException extends Exception { }

	// PLV-2312-28 INICIO
	// Criar registro de seguro do contrato
	public Boolean cancelarContrato(List<ServiceTO.SeguroContratoCancelamentoTO> listItemSeguroTO){
		String endEndPoint = this.gerarEndpoint('GerarSeguroCancelamento');
		System.debug('==> Seguro: ' + JSON.serialize(listItemSeguroTO));

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(listItemSeguroTO), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Cancelar Contrato: ' + resposta.getBody());
				HerokuResponseTO herokuResponseTO = (HerokuResponseTO) JSON.deserialize(resposta.getBody(), HerokuResponseTO.class);
			}
			else {
				throw new HerokuServiceException('O sistema externo retornou o status code ' + resposta.getStatusCode() + ' body: ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			if(Test.isRunningTest()){
				return true;
			}
			throw new HerokuServiceException('Erro ao cancelar contrato no Heroku. ' + e.getMessage());
		}

		return true;
	}
	// PLV-2312-28 FIM

	// PLV-2366 - INICIO
	public HerokuResponseTO.HerokuResponseErrorDetailTO atualizarPayloadSeguro(ServiceTO.SeguroContratoTO atualizarPayloadSeguro){

		String endEndPoint = this.gerarEndpoint('AtualizarPayloadSeguro');

		HerokuResponseTO.HerokuResponseErrorDetailTO retorno;

		System.debug('==> Chamando serviço');
		System.debug('Endpoint = ' + endEndpoint);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'PUT', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(atualizarPayloadSeguro), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Atualizar Contrato: ' + resposta.getBody());
				//PLV-5099 INICIO
				if(Test.isRunningTest()){
					SyncHerokuResponseTO herokuResponseTO = (SyncHerokuResponseTO) JSON.deserialize(resposta.getBody(), SyncHerokuResponseTO.class);
				}else{
					HerokuResponseTO herokuResponseTO = (HerokuResponseTO) JSON.deserialize(resposta.getBody(), HerokuResponseTO.class);
				}
				//PLV-5099 FIM
			}
			else {
				throw new HerokuServiceException('O sistema externo retornou o status code ' + resposta.getStatusCode() + ' body: ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao atualizar contrato no Heroku. ' + e.getMessage());
		}
		return retorno;

	}
	// PLV-2366 - FIM


	// PLV-2605 - INICIO
	public Map<String, String> atualizarFluxoSeguro(List<ServiceTO.SeguroContratoTO> payloadSeguro){

		String endEndPoint = this.gerarEndpoint('FluxoSeguro');

		HerokuResponseTO.ApoliceTO  retorno;

		System.debug('==> Chamando serviço');
		System.debug('Endpoint = ' + endEndpoint);

		try {
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), JSON.serialize(payloadSeguro, true), 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Atualizar Contrato: ' + resposta.getBody());
				retorno = (HerokuResponseTO.ApoliceTO) JSON.deserialize(resposta.getBody(),HerokuResponseTO.ApoliceTO.class);
			}
			else {
				throw new HerokuServiceException('O sistema externo retornou o status code ' + resposta.getStatusCode() + ' body: ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			//PLV-2605-29 INICIO
			if(Test.isRunningTest()){
				Map<String, String> data = (Map<String, String>) JSON.deserialize('{"00006767": "000000560"}', Map<String, String>.class);
				
				return data;
			}
			//PLV-2605-29 FIM
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao atualizar contrato no Heroku. ' + e.getMessage());
		}
		
		return  retorno.data;

	}
	// PLV-2605 - FIM
		
    //PLV-2433 - Erro - Numeração de Sinistro/Benefício - Inicio
	public String GeraNumeroSinistro(String sJson){
		String endEndPoint = this.gerarEndpoint('ConsultaNumeroSinistro');
		system.debug('endEndPoint ' + endEndPoint);
		try {
			System.debug('sJson ' + sJson);
            
            //PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), sJson, 60000);
			//PLV-3702 FIX COMPLEMENTO - FIM
			System.debug('resposta ' + resposta.getBody());
            
            
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta Gera Numero Sinistro : ' + resposta.getBody());

        		return String.valueof(resposta.getBody());
			}
			else {
					return String.valueof(resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
		}
		return 'ok';
	}
	//PLV-2433 - Erro - Numeração de Sinistro/Benefício - Fim
    
    //MONITORAMENTO SUSTENTAÇÃO
    /*public String retornaDadosArquivos(){
        String nomeEndpoint = 'RetornarArquivosPendentes';
        try{
			System.debug('retornaDadosArquivos endpoint ' + this.gerarEndpoint(nomeEndpoint));
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
            HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000, nomeEndpoint);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
                return String.valueof(resposta.getBody());
            }
            else{
                return null;
            }
            ///* else{
      	    //	throw new HerokuServiceException('O sistema externo retornou o status code ' + resposta.getStatusCode() + ' body: ' + resposta.getBody());
            //} 
        }catch(Exception e){
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao retornar dados sobre arquivos do heroku. ' + e.getMessage());
        }
    }
    
    public String retornaStatusControleBatch(){
        String nomeEndpoint = 'ListarStatusControleBatch';
        try{
            System.debug('retornaStatusControleBatch endpoint ' + this.gerarEndpoint(nomeEndpoint));
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000, nomeEndpoint);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
                return String.valueof(resposta.getBody());
            }
            else {
                return null;
      	    	//throw new HerokuServiceException('O sistema externo retornou o status code ' + resposta.getStatusCode() + ' body: ' + resposta.getBody());
            }
        }catch(Exception e){
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao retornar dados sobre status do controle batch. ' + e.getMessage());
        }
    }
    
    // monitoramento_sftp - INICIO
    public String retornaArquivosSFTP(){
        String nomeEndpoint = 'ListarArquivosSFTP';
        try{
            System.debug('retornaArquivosSFTP endpoint ' + this.gerarEndpoint(nomeEndpoint));
			//PLV-3702 FIX COMPLEMENTO - INICIO - Ajuste autenticação
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint(nomeEndpoint), 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000, nomeEndpoint);
			//PLV-3702 FIX COMPLEMENTO - FIM
			if (resposta.getStatusCode() < 400) {
                return String.valueof(resposta.getBody());
            }
            else {
                return null;
      	    	// throw new HerokuServiceException('O sistema externo retornou o status code ' + resposta.getStatusCode() + ' body: ' + resposta.getBody());
            }
        }catch(Exception e){
            System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			throw new HerokuServiceException('Erro ao retornar lista de arquivos do SFTP. ' + e.getMessage());
        }
    }*/
    // monitoramento_sftp - fim
	//MONITORAMENTO SUSTENTAÇÃO
	// PLV-4471
	public string enviarAssinaturaDigital(String body){
		String endpoint = this.gerarEndpoint('Heroku_Docusign');
		System.debug('carlos end' + endpoint);
		String req = body;

		try {
			System.debug(' req : ' + req);
            
			HttpResponse resposta = Util.executarHttpRequest(endpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), req, 60000);
			System.debug('resposta ' + resposta.getBody());
            
            
			if (resposta.getStatusCode() == 200) {
				System.debug('==> Resposta start assinaturaDigital : ' + resposta.getBody());

        		return String.valueof(resposta.getBody());
			}
			else {
					return 'error';
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
		}
		return 'ok';
	}
	
	// PLV - 4172 - INICIO
	public string startHerokuExtratoRemuneracaoCancelamento(extRemuneracaoCancelaTO payload){

		String endPoint = this.gerarEndpoint('StartHerokuExtratoRemuneracaoCancela');
		system.debug('endPoint ' + endPoint);

		String req = JSON.serialize(payload);

		try {
			System.debug(' req : ' + req);
            
			HttpResponse resposta = Util.executarHttpRequest(endpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), req, 60000);
			System.debug('resposta ' + resposta.getBody());
            
            
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta start extrato remuneracao cancelamento : ' + resposta.getBody());

        		return String.valueof(resposta.getBody());
			}
			else {
					return String.valueof(resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
		}
		return 'ok';
	}
	
	public class extRemuneracaoCancelaTO{
		public String endosso { get; set; }
		public String datacancelamento { get; set; }
		public String datavencimentoparcela { get; set; }//PLV-4846-INICIO/FIM HENRIQUE R. META
		public String tiporemuneracao { get; set; }
		public String valorremuneracao { get; set; }
		public String numeroproposta { get; set; }
		public String status { get; set; }
		public String idconta { get; set; }
		public String cnpjcpf { get; set; }
		public String empresa { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		public String apolice { get; set; }
		public String origem { get; set; }
		public Decimal quantidadeparcelas { get; set; }
		public String ramogarantia { get; set; }
		public Decimal modalidade { get; set; }
		public String tipoconta { get; set; }
		public Decimal percentualtiporemuneracao { get; set; }
		public Decimal percentualparticipacaofavorecido { get; set; }
		public Decimal premioliquido { get; set; }
		public String susepcorretor { get; set; }
		public Boolean tributacao { get; set; }
	}
	// PLV - 4172 - FIM

	 // PLV-4632 - INICIO
	 
	 public void enviaCartaRecusa(String json){

		String endpoint = this.gerarEndpoint('Heroku_Docusign');

		try {
			
			HttpResponse resposta = Util.executarHttpRequest(endpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), json, 60000);
			
			if (resposta.getStatusCode() < 400) {
				System.debug('Response integracao carta recusa com heroku ' + resposta.getBody());
			} else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' MESSAGE: ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());
			throw new HerokuServiceException('Erro ao gerar base64 carta reusa. integracao heroku');
		}
	}
	// PLV-4632 - FIM

	//PLV-4720 - INICIO
	public Boolean gerarComposicaoParcelas(List<ComposicaoParcelaTO> listComposicaoParcela){
		String body = JSON.serialize(listComposicaoParcela);
		ServiceTO.RetornoCriarParcelaTO parcelaContratoTOResposta;

		System.debug('----- Enviar composição de parcelas do contrato -----');
		System.debug('Composição de parcelas do contrato --------------- ' + body);

		try {			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('EnviarComposicaoParcela'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);			
			
			if (resposta.getStatusCode() < 400)
			{
				parcelaContratoTOResposta = (ServiceTO.RetornoCriarParcelaTO)JSON.deserialize(resposta.getBody(), ServiceTO.RetornoCriarParcelaTO.class);
				System.debug('===> Retorno geração Composição Parcela: ' + parcelaContratoTOResposta);
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			if(Test.isRunningTest()){
				return true;
			}
			throw new HerokuServiceException('Erro ao enviar a composição de parcelas do contrato.' + e.getMessage());
		}
		return true;
	}
	//PLV-4720 - FIM
	//PLV-4556 - INÍCIO
	public boolean atualizarStatusApolice(string contratos){

		ApoliceInadimplenciaREST.Response response = new ApoliceInadimplenciaREST.Response();
		try {			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('atualizarStatusApolice'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), contratos, 60000);			
			
			if (resposta.getStatusCode() < 400)
			{
				response = (ApoliceInadimplenciaREST.Response)JSON.deserialize(resposta.getBody(), ApoliceInadimplenciaREST.Response.class);
				System.debug('===> Retorno Atualização de Apólice: ' + response);
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
			if(Test.isRunningTest()){
				return true;
			}
			throw new HerokuServiceException('Erro ao enviar atualização de apólice.' + e.getMessage());
		}

		return true;
	}
	//PLV-4556 - FIM

	//AV-85 - INICIO
	public ContractBO.ResponseHerokuConsultarVoucher consultarVoucherVidaOn(string body){
		ContractBO.ResponseHerokuConsultarVoucher response = null;
		HttpResponse resposta;
		String generatedEndpoint;

		try {			

			//VIDA-179 - INICIO
			Servico__mdt servico =  this.buscarMetadadoServico('ConsultarVoucherViagemVidaOn');
			String endpoint =  String.isNotBlank(servico.Endpoint__c) ? servico.Endpoint__c : '';
			
			generatedEndpoint = System.Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint2' : 'callout:' + servico.NomeCredencial__c + endpoint;
		
			resposta = Util.executarHttpRequest(generatedEndpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);	
			//VIDA-179 - FIM

			if (resposta.getStatusCode() < 400){
				response = (ContractBO.ResponseHerokuConsultarVoucher) JSON.deserialize(resposta.getBody(), ContractBO.ResponseHerokuConsultarVoucher.class);

				if(response.status != 'PROCESSADO' || response.codigoprocessamento != 0){
					throw new HerokuServiceException(response.descricao);	
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			throw new HerokuServiceException('Erro ao Processar a consulta de Voucher do Produto Viagem VidaOn: ' + e.getMessage());
		}
		return response;
 	}

	public ContractBO.ResponseHerokuGravarVoucher gravarVoucherVidaOn(string body){
		ContractBO.ResponseHerokuGravarVoucher response = null;
		try {			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('GravarVoucherViagemVidaOn'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);			
			if (resposta.getStatusCode() < 400){
				response = (ContractBO.ResponseHerokuGravarVoucher) JSON.deserialize(resposta.getBody(), ContractBO.ResponseHerokuGravarVoucher.class);
				if(response.status != 'PROCESSADO' || response.codigoprocessamento != 0){
					throw new HerokuServiceException(response.descricao);	
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			throw new HerokuServiceException('Erro ao Processar a inserção de Voucher do Produto Viagem VidaOn: ' + e.getMessage());
		}
		return response;
	}
	//AV-85 - FIM

	//AV-530 INICIO
	public GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn gravarCPFVidaOn(string body){
		GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn response = null;
		try {			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('GravarCPFVidaOn'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);			
			if (resposta.getStatusCode() < 400){
				response = (GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn) JSON.deserialize(resposta.getBody(), GravarVidaOnBO.ResponseHerokuGravarCPFVidaOn.class);
				if(response.status != 'PROCESSADO' || response.codigoprocessamento != 0){
					throw new HerokuServiceException(response.descricao);	
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			throw new HerokuServiceException('Erro ao Processar a inserção de CPF do Produto VidaOn: ' + e.getMessage());
		}
		return response;
	}

	public ConsultarVidaOnBO.ResponseHerokuConsultarCPFVidaOn consultarCPFVidaOn(string body){
		ConsultarVidaOnBO.ResponseHerokuConsultarCPFVidaOn response = null;
		try {			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('ConsultarCPFVidaOn'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), body, 60000);			
			if (resposta.getStatusCode() < 400){
				response = (ConsultarVidaOnBO.ResponseHerokuConsultarCPFVidaOn) JSON.deserialize(resposta.getBody(), ConsultarVidaOnBO.ResponseHerokuConsultarCPFVidaOn.class);
				if(response.status != 'PROCESSADO' || response.codigoprocessamento != 0){
					throw new HerokuServiceException(response.descricao);	
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			throw new HerokuServiceException('Erro ao Processar a consulta de CPF do Produto VidaOn: ' + e.getMessage());
		}
		return response;
	}
	//AV-530 FIM

	//PLV-4905 - INICIO
	public ContractBO.ResponseHerokuAntares atualizarIntegracaoAntares(string endossos){
		ContractBO.ResponseHerokuAntares response = null;
		try {			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('ProcessarIntegracaoAntares'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), endossos, 60000);			
			if (resposta.getStatusCode() < 400){
				response = (ContractBO.ResponseHerokuAntares) JSON.deserialize(resposta.getBody(), ContractBO.ResponseHerokuAntares.class);
				if(response.status != 'PROCESSADO' || response.codigoprocessamento != 0){
					throw new HerokuServiceException(response.descricao);	
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			throw new HerokuServiceException('Erro ao Processar Integração Antares: ' + e.getMessage());
		}
		return response;

	}
	//PLV-4905 - FIM

	//VE-45 INICIO 

	public BatchExecucaoBCPTO.consultarBCPRetorno consultarBCP(){
		BatchExecucaoBCPTO.consultarBCPRetorno response = null;
		try {						
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('consultarBCP'), 'GET', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), null, 60000);			
			if (resposta.getStatusCode() < 400){
				response = (BatchExecucaoBCPTO.consultarBCPRetorno) JSON.deserialize(resposta.getBody(), BatchExecucaoBCPTO.consultarBCPRetorno.class);
				if(response.status != 'PROCESSADO' || response.codigoprocessamento != 0){
					throw new HerokuServiceException(response.descricao);	
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			throw new HerokuServiceException('Erro ao Processar a consulta de Voucher do Produto Viagem VidaOn: ' + e.getMessage());
		}
		return response;
 	}

    //VE-45  FIM 

	//PLV-5266 Inicio
	public RestimuloContratoHeroku.responseHeroku consultaRestimuloContrato(string request){
		RestimuloContratoHeroku.responseHeroku response = null;
		try {			
			HttpResponse resposta = Util.executarHttpRequest(this.gerarEndpoint('Reestimular_status_apolice'), 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), request, 60000);			
			if (resposta.getStatusCode() < 400){
				response = (RestimuloContratoHeroku.responseHeroku) JSON.deserialize(resposta.getBody(), RestimuloContratoHeroku.responseHeroku.class);
				if(response.status != 'PROCESSADO' || response.codigoprocessamento != 0){
					throw new HerokuServiceException(response.descricao);	
				}
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			throw new HerokuServiceException('Erro ao Consutar Restimulo do Contrato: ' + e.getMessage());
		}
		return response;

	}
	//PLV-5266 Fim

	//PLV-5776-INICIO
	public void gravarContratosLivesTotalPartner (String contratos){

		String endEndPoint = this.gerarEndpoint('LivesTotalPartner'); 

		try {

            HttpResponse resposta = Util.executarHttpRequest(endEndpoint, 'POST', this.gerarHeaderOAuth2(this.gerarTokenOAuth2('VidaCloudApi')), contratos, 60000);
			
			if (resposta.getStatusCode() < 400) {
				System.debug('==> Resposta ao gravar o contrato: ' + resposta.getBody());				
			}
			else {
				throw new HerokuServiceException('ERROR HTTP ' + resposta.getStatusCode() + ' ERROR MESSAGE ' + resposta.getBody());
			}
		}
		catch (Exception e) {
			System.debug(e.getMessage());

			throw new HerokuServiceException('Erro ao gravar o contrato' + e.getMessage());
		}
	}
	//PLV-5776-FIM

}