/**
 * Fatura Facade
 *
 **/
public class FaturaFacade {

	private static final FaturaFacade classInstance;
	public static FaturaBO bo = FaturaBO.getInstance();

	private Map<String,String> mapConversorStatus = new Map<String, String>{
			'PENDENTE' => 'pendente',
			'EM CRIACAO' => 'Em criação',
			'PAGA' => 'Paga',
			'CANCELADA' => 'Cancelada'};

	static {
		classInstance = new FaturaFacade();
	}

	private FaturaFacade() {}

	public static FaturaFacade getInstance() {
		return classInstance;
	}

	public RetornoFaturaRestTO gerarFatura(String payload) {

		System.debug('Inicio');

		Savepoint sp = Database.setSavepoint();
		List<FaturaTO.DadosFaturaTO> objPayload;
		RetornoFaturaRestTO retorno = new RetornoFaturaRestTO();
		Boolean success = false;
		String codProduto;

		List<Fatura__c> lstFaturas = new List<Fatura__c>();
		Set<Id> lstParceiroBatimentoIds = new Set<Id>();
		Set<String> setCodigoParceiro = new Set<String>();
		List<Id> lstParceiroIds = new List<Id>();
		Map<String, Conversao__mdt> mapConversao = new Map<String, Conversao__mdt>();
		Map<Id, Parceiro__c> mapParceiros = new Map<Id, Parceiro__c>();
		Map<String, Parceiro__c> mapParceiroPorCodigo = new Map<String, Parceiro__c>();

		System.debug('Inicio da Leitura do Json');
		try {
			// Parser do Payload
			objPayload = (List<FaturaTO.DadosFaturaTO>) JSON.deserialize(payload, List<FaturaTO.DadosFaturaTO>.class);

			// Itera as faturas
			for (FaturaTO.DadosFaturaTO payloadFatura : objPayload) {
				setCodigoParceiro.add(payloadFatura.codigoparceiro);
			}

			//System.debug('Carregar Parceiros');
			for(Parceiro__c	parceiro :  ParceiroDAO.getInstance().buscarParceirosPorCodigo(setCodigoParceiro))
			{
				mapParceiros.put(parceiro.Id, parceiro);
				mapParceiroPorCodigo.put(parceiro.Codigo__c, parceiro);
			}

			// Itera as faturas recebidas
			for (FaturaTO.DadosFaturaTO payloadFatura : objPayload) {

				Fatura__c newFatura = new Fatura__c();

				//codProduto = montarCodigoProduto(payloadFatura.codigosproduto, mapConversao);

				newFatura.Apolice__c = payloadFatura.apolice;
				newFatura.Empresa__c = payloadFatura.empresa;
				newFatura.Conta__c = payloadFatura.conta;
				newFatura.Sucursal__c = payloadFatura.sucursal;
				newFatura.Ramo__c = payloadFatura.ramo;
				newFatura.CodigoProdutoComercial__c = payloadFatura.codigosproduto;
				newFatura.DataEmissao__c = payloadFatura.dataemissao;
				newFatura.DataVencimento__c = payloadFatura.datavencimento;
				newFatura.Endosso__c = String.valueOf(payloadFatura.endosso);
				newFatura.FinalCompetencia__c = payloadFatura.finalcompetencia;
				newFatura.InicioCompetencia__c = payloadFatura.iniciocompetencia;
				newFatura.Origem__c = String.valueOf(payloadFatura.origemproposta);
				newFatura.Proposta__c = String.valueOf(payloadFatura.numeroproposta);
				newFatura.TipoFatura__c = payloadFatura.tipofatura;
				newFatura.ValorIOF__c = payloadFatura.valoriof;
				newFatura.ValorLiquido__c = payloadFatura.valorliquido;
				newFatura.ValorTotal__c = payloadFatura.valortotal;
				newFatura.Status__c = mapConversorStatus.get(payloadFatura.status);
				newFatura.NumeroContratoFinanceiro__c = bo.gerarNumeroContratoFinanceiro(
						String.valueOf(payloadFatura.origemproposta),
						String.valueOf(payloadFatura.numeroproposta),
						payloadFatura.sucursal,
						payloadFatura.ramo,
						payloadFatura.apolice,
						String.valueOf(payloadFatura.endosso)
				);

				// Verifica se existe o parceiro
				if(mapParceiroPorCodigo.containsKey(payloadFatura.codigoparceiro))
				{
					Parceiro__c dadosParceiro = new Parceiro__c();
					dadosParceiro = mapParceiroPorCodigo.get(payloadFatura.codigoparceiro);

					newFatura.Parceiro__c = dadosParceiro.Id;
					newFatura.Conta__c    = dadosParceiro.Conta__c;
				}

				lstFaturas.add(newFatura);

				/* PLV-2206 Remocao de cancelamento das faturas anteriors
				//-- prepara cancelamento da fatura batimento contabil
				if(payloadFatura.TipoFatura == 'BatimentoContabil')
				{
					lstParceiroBatimentoIds.add(newFatura.Parceiro__c);
				}
				 */
			}

			//------ grava faturas
			System.debug('Gravar Fatura');
			insert lstFaturas;

			//------ atualiza endosso nos parceiros
			System.debug('Atualzar Endosso');
			atualizarEndossoParceiros(mapParceiros, lstFaturas);

			/* PLV-2206 Remocao de cancelamento das faturas anteriors
			//------ atualiza faturas anteriores (Batimento Contabil)
			System.debug('Atualizar Faturas Anteriores');
			if(!lstParceiroBatimentoIds.isEmpty())
			{
				cancelarFaturaAnterior(lstParceiroBatimentoIds, lstFaturas);
			}
			*/

			//------ gera retorno
			System.debug('Criar Retorno');
			List<FaturasGeradasTO> lstRetornoFaturas = criarRetorno(lstFaturas);
			retorno.faturas = lstRetornoFaturas;

		}
		catch(Exception e) {
			success = false;
			Database.rollback(sp);
			System.debug(e.getLineNumber() + ': ' + e.getMessage());
			throw new FaturaException(e.getLineNumber() + ': ' + e);
		}
		finally {
			//if (success && Test.isRunningTest()) {
			System.debug('');
			System.debug('========================================================================');
			System.debug('::: JSON Payload');
			System.debug(JSON.serialize(objPayload));
			System.debug('========================================================================');
			//}
		}


		System.debug('');
		System.debug('========================================================================');
		System.debug('::: JSON Retorno');
		System.debug('::: ' + JSON.serialize(retorno.faturas, true));
		System.debug('========================================================================');

		return retorno;
	}

/*
	private String montarCodigoProduto(String codigosProduto, Map<String, Conversao__mdt> mapConversao)
	{
		String prodRetorno = '';

		List<String> produtos = codigosProduto.split('_');
		for(String prod : produtos)
		{
			if(mapConversao.containsKey(prod))
			{
				if(!String.isBlank(prodRetorno))
					prodRetorno += '_';

				prodRetorno += mapConversao.get(prod).ValorInterno__c;
			}
		}

		return prodRetorno;
	}
*/

	private List<FaturasGeradasTO> criarRetorno(List<Fatura__c> lstFaturas)
	{
		Set<Id> Ids = new Set<Id>();
		List<FaturasGeradasTO> lstRetornoFaturas = new List<FaturasGeradasTO>();

		for(Fatura__c objFatura : lstFaturas)
		{
			Ids.add(objFatura.Id);
		}
		System.debug('AQUI ------------------------- ');

		for(Fatura__c objFatura : FaturaDAO.getInstance().buscarFaturasPorIds(Ids))
		{
			FaturasGeradasTO fatura = new FaturasGeradasTO();

			fatura.proposta	= Integer.valueOf(objFatura.Proposta__c);
			fatura.numeroFatura = objFatura.Name;
			fatura.origem = Integer.valueOf(objFatura.Origem__c);
			fatura.parceiro = objFatura.Parceiro__c;
			fatura.idSaleforce = objFatura.Id;
			fatura.codigoParceiro = objFatura.Parceiro__r.Codigo__c;

			lstRetornoFaturas.add(fatura);
		}

		return lstRetornoFaturas;
	}


	private void atualizarEndossoParceiros(Map<Id, Parceiro__c> mapParceiros, List<Fatura__c>lstFaturas)
	{
		Map<Id,Parceiro__c> mapParceiroPorId = new Map<Id, Parceiro__c>();
		List<Parceiro__c> listParceiro = new List<Parceiro__c>();

		try {

			// Itera as faturas
			for(Fatura__c objFatura : lstFaturas)
			{
				Parceiro__c objParceiro = new Parceiro__c();

				// Recupera o parceiro
				if(mapParceiros.containsKey(objFatura.Parceiro__c))
				{
					System.debug('Atualizar Parceiro');

					objParceiro = mapParceiros.get(objFatura.Parceiro__c);

					// Verifica se nesse processo ja foi gerado alguma fatura para esse parceiro
					if(mapParceiroPorId.containsKey(objParceiro.Id)){

						Parceiro__c parceiroTemp = mapParceiroPorId.get(objParceiro.Id);

						if(objFatura.TipoFatura__c == 'Cobranca') {

							// Verifica qual endosso eh mais novo e atualiza no parceiro se necessario
							Integer sequencialEndossoParceiro = extrairSequencialEndosso(parceiroTemp.EndossoCobranca__c);
							Integer sequencialEndosso = extrairSequencialEndosso(objFatura.Endosso__c);

							if(sequencialEndossoParceiro < sequencialEndosso){

								for(Parceiro__c parceiro : listParceiro) {
									// Atualiza o endosso no parceiro
									if(parceiro.Id == objParceiro.Id) {
										parceiro.EndossoCobranca__c = objFatura.Endosso__c;
										mapParceiroPorId.put(objParceiro.Id, objParceiro);
										break;
									}
								}
							}

						}else if(objFatura.TipoFatura__c == 'BatimentoContabil'){

							// Verifica qual endosso eh mais novo e atualiza no parceiro se necessario
							Integer sequencialEndossoParceiro = extrairSequencialEndosso(parceiroTemp.EndossoBatimentoContabil__c);
							Integer sequencialEndosso = extrairSequencialEndosso(objFatura.Endosso__c);

							if(sequencialEndossoParceiro < sequencialEndosso){

								for(Parceiro__c parceiro : listParceiro){
									// Atualiza o endosso no parceiro
									if(parceiro.Id == objParceiro.Id){
										objParceiro.EndossoBatimentoContabil__c = objFatura.Endosso__c;
										mapParceiroPorId.put(objParceiro.Id,objParceiro);
									}
								}
							}
						}
					}else{

						if(objFatura.TipoFatura__c == 'Cobranca'){

							objParceiro.EndossoCobranca__c = objFatura.Endosso__c;
							mapParceiroPorId.put(objParceiro.Id,objParceiro);
							listParceiro.add(objParceiro);

						}else if(objFatura.TipoFatura__c == 'BatimentoContabil'){

							objParceiro.EndossoBatimentoContabil__c = objFatura.Endosso__c;
							mapParceiroPorId.put(objParceiro.Id,objParceiro);
							listParceiro.add(objParceiro);

						}
					}
				}
			}

			// Atualiza o parceiro
			if(!listParceiro.isEmpty()){
				update listParceiro;
			}

		}
		catch(Exception e) {
			System.debug(e.getLineNumber() + ': ' + e.getMessage());
			throw new FaturaException(e.getLineNumber() + ': ' + e);
		}
	}

	private Integer extrairSequencialEndosso (String endosso){
		return Integer.valueOf(endosso.substring( endosso.length() - 3, endosso.length() ));
	}

	/* PLV-2206 Remocao de cancelamento das faturas anteriors
	private void cancelarFaturaAnterior(Set<Id> lstParceiros, List<Fatura__c> faturasGeradas)
	{
		Boolean bProximo;
		List<Fatura__c> lstFaturasToCancel = new List<Fatura__c>();

		try {

			for(Fatura__c objFatura : FaturaDAO.getInstance().buscarFaturasPorParceiro(lstParceiros))
			{

				bProximo = false;
				for(Fatura__c objFaturaGerada : faturasGeradas)
				{
					if(objFaturaGerada.Id == objFatura.Id)
					{
						bProximo = true;
						break;
					}
				}

				if(bProximo)
					continue;

				objFatura.Status__c = 'Cancelada';

				lstFaturasToCancel.add(objFatura);
			}

			update lstFaturasToCancel;
		}
		catch(Exception e) {
			System.debug(e.getLineNumber() + ': ' + e.getMessage());
			throw new FaturaException(e.getLineNumber() + ': ' + e);
		}
	}
 	*/

	public class RetornoFaturaRestTO {
		public List<FaturasGeradasTO> faturas { get; set; }
	}

	public class FaturasGeradasTO {
		public Integer proposta { get; set; }
		public String numeroFatura { get; set; }
		public Integer origem { get; set; }
		public String parceiro { get; set; }
		public String idSaleforce { get; set; }
		public String codigoParceiro { get; set; }
	}

	public class dadosParceiroTO
	{
		public Id idParceiro  { get; set; }
		public Id idConta { get; set; }
	}

	public class FaturaException extends Exception {}
}