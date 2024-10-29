// POR062-1 - INICIO
@RestResource(urlMapping='/sinistro/atualizarjuridico')
global with sharing class AtualizarSinistroJuridicoRest {
	@HttpPost
	global static void processarPost()
	{
		RestResponse resposta = RestContext.response;
		SinistroJuridicoBO.ResponseAtualizar retorno;
		try {
			String payload = RestContext.request?.requestBody?.toString();
			SinistroJuridicoBO.Request payloadRequisicao = (SinistroJuridicoBO.Request) JSON.deserialize(payload, SinistroJuridicoBO.Request.class);
			payloadRequisicao.atualizarInit();
			retorno = atualizarProcesso(payloadRequisicao);
		} catch (Exception e) {
			retorno = new SinistroJuridicoBO.ResponseAtualizar();
			String mensagemErro = String.format(
				'Inconsistências no payload de requisição: {0} : {1}',
				new String[] { String.valueOf(e.getCause()), e.getStackTraceString() }
			);
			retorno.setError(mensagemErro, new SinistroJuridicoBO.Request());
		}
		resposta.responseBody = Blob.valueOf(JSON.serialize(retorno));
		resposta.addHeader('Content-Type', 'application/json');
    }

	@TestVisible
	private static List<MovimentoSinistro__c> juntarListasMovClone(List<List<MovimentoSinistro__c>> lista)
	{
		List<MovimentoSinistro__c> movimentos = new List<MovimentoSinistro__c>();
		for(List<MovimentoSinistro__c> movimentosAux : lista)
		{
			movimentos.addAll(movimentosAux.deepClone(true, true, true));
		}
		return movimentos;
	}

	public static SinistroJuridicoBO.ResponseAtualizar atualizarProcesso(SinistroJuridicoBO.Request sinistro)
	{
		SinistroJuridicoBO.ResponseAtualizar retorno = new SinistroJuridicoBO.ResponseAtualizar();
		String mensagem = sinistro.validar('AtualizarSinistro');
		if(String.isNotBlank(mensagem))
		{
			return retorno.setError(mensagem, sinistro);
		}
		String numeroSinistro = String.format(
			'{0}.{1}.{2}.{3}',
			new String[] {
				sinistro.empresa, sinistro.ramo, sinistro.ano, sinistro.numero
			}
		);

		List<Case> casoLista = CaseDAO.getInstance().buscarPorNumeroDoSinistro(new Set<String> { numeroSinistro });
		Case casoDoSinistro;
		if(casoLista.isEmpty())
		{
			return retorno.setError('Caso não encontrado', sinistro);
		}
		else
		{
			casoDoSinistro = casoLista.get(0);
		}
		Set<Id> idCasos = Util.recuperarIdsPorCampoDeSObject(casoLista, Schema.Case.Id);
		Set<Id> idsContratos = Util.recuperarIdsPorCampoDeSObject(casoLista, Schema.Case.Contrato__c);
		Map<Id, Contract> mapaContratoPorIdDeCaso = ContractBO.getInstance().mapearContratosPorIdCaso(casoLista);
		
		PagamentoGarantia__c pagamentoParaCriar = null;
		PagamentoGarantia__c pagamentoParaAtualizar = null;
		List<PagamentoGarantia__c> pagamentosParaFechar = new List<PagamentoGarantia__c>();

		List<PagamentoGarantia__c> garantiasSinistroLista = PagamentoGarantiaDAO.getInstance().buscarPorCaso(mapaContratoPorIdDeCaso.keySet());
		PagamentoGarantia__c pagAux = PagamentoGarantiaBO.getInstance().recuperarPorCasoESigla(casoDoSinistro?.Id, sinistro?.cobertura, garantiasSinistroLista);
		List<PagamentoGarantia__c> garantiaSinistroDaCobertura = new List<PagamentoGarantia__c>();
		if(pagAux != null)
		{
			garantiaSinistroDaCobertura.add(pagAux);
		}
		if(
			garantiaSinistroDaCobertura.isEmpty() &&
			sinistro.movimento != MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.valor
		) { // PLV-4624
			List<GarantiaSeguradoContrato__c> garantiasContratoLista = GarantiaSeguradoContratoDAO.getInstance().buscarPorIdDeContratoECobertura(
				idsContratos, new Set<String> { sinistro.cobertura }
			);
			if(garantiasContratoLista.isEmpty())
			{ // PLV-4624
				return retorno.setError('A Cobertura não faz parte do Contrato', sinistro);
			}
			else
			{
				pagamentoParaCriar = new PagamentoGarantia__c();
				pagamentoParaCriar.Garantia_do_segurado_do_contrato__c = garantiasContratoLista[0].Id;
				pagamentoParaCriar.Name = garantiasContratoLista[0].Garantia__r.Name;
				pagamentoParaCriar.Caso__c = casoDoSinistro.Id;
				pagamentoParaCriar.ValorIndenizadoInicial__c = sinistro.valor;
				pagamentoParaCriar.Capital__c = sinistro.valor;
				pagamentoParaCriar.Valor_indenizado__c = sinistro.valor;
			}
		}
		if(casoLista.isEmpty())
		{
			return retorno.setError('Sinistro não localizado', sinistro);
		}
		else if(
			garantiaSinistroDaCobertura.isEmpty() && pagamentoParaCriar == null &&
			sinistro.movimento != MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.valor
		) { // PLV-4624
			return retorno.setError('Garantias não localizadas', sinistro);
		}
		
		List<Garantia__c> garantias = GarantiaDAO.getInstance().buscarGarantiasPorSigla(new Set<String> { sinistro.cobertura });
		Map<String, Garantia__c> garantiaPorCobertura = GarantiaBO.getInstance().mapearGarantiaPorCobertura(garantias);

		String nomePagamentoGarantia = garantiaPorCobertura.get(sinistro.cobertura)?.Name;
		PagamentoGarantia__c pagamentoGarantia = PagamentoGarantiaBO.getInstance().filtrarPorCasoECobertura(
			casoDoSinistro.Id, nomePagamentoGarantia, garantiaSinistroDaCobertura
		);
		
		List<MovimentoSinistro__c> movimentos = MovimentoSinistroDAO.getInstance().buscarPorIdCaso(idCasos);
		List<MovimentoSinistro__c> movimentosDaCobertura = MovimentoSinistroBO.getInstance().filtrarCobertura(
			movimentos, pagamentoGarantia?.Id, true
		);

		List<Case> casosParaAtualizar = new List<Case>();
		List<CaseMilestone> CMSsParaAtualizar = new List<CaseMilestone>();
		// LECVPV-140-FIX02 INICIO
		List<MovimentoSinistro__c> movimentosParaCriar = new List<MovimentoSinistro__c>();
		// CasoBO.getInstance().gerarFechamentoAdministrativoEReaberturaJuridico(casoLista)
		// );
		List<ComplementoIndenizacao__c> complementosParaCriar = new List<ComplementoIndenizacao__c>();
		// if(!casoLista[0].Sinistro_Judicial__c)
		// {
		// 	casoLista[0].Sinistro_Judicial__c = true;
		// } /* Necessário ficar após o método: gerarFechamentoAdministrativoEReaberturaJuridico. */
		// LECVPV-140-FIX02 FIM
		Case casoParaAtualizar = null;
		if(sinistro.movimento != MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.valor)
		{ // PLV-4624

			// LECVPV-140-FIX03 INICIO
			if(casoParaAtualizar == null)
			{
				casoParaAtualizar = casoLista[0];
			}
			// LECVPV-140-FIX04 INICIO  
			if (casoParaAtualizar.Sinistro_Judicial__c == false 
				&& pagamentoGarantia != null 
				&& !'Fechado'.equals(pagamentoGarantia.Fase__c) 
				&& MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor != sinistro.movimento)
			// LECVPV-140-FIX04 FIM
			{
				Boolean existePagamento = MovimentoSinistroBO.getInstance().verificarSeExistePagamentosIndenizacao(
					AtualizarSinistroJuridicoRest.juntarListasMovClone(
						new List<List<MovimentoSinistro__c>> { movimentos, movimentosParaCriar }
					)
				);
				// LECVPV-216-FIX01 - INICIO
				// if(existePagamento)
				// {
				// 	return retorno.setError('Não é possível encerrar um caso que já possui pagamento', sinistro);
				// }
				// LECVPV-216-FIX01 - FIM
				// if(casoParaAtualizar == null)
				// {
				// 	casoParaAtualizar = casoLista[0];
				// }
				// LECVPV-140-FIX02 INICIO
				List<MovimentoSinistro__c> movimentosEncerramento =  new List<MovimentoSinistro__c>(
					CasoBO.getInstance().gerarMovimentosEncerramento(casoLista) 
				);
				if (movimentosEncerramento !=null && movimentosEncerramento.size()>0) {
					movimentosParaCriar.addAll(movimentosEncerramento);
					if(!casoLista[0].Sinistro_Judicial__c)
					{
						casoLista[0].Sinistro_Judicial__c = true;
					} /* Necessário ficar após o método: gerarFechamentoAdministrativoEReaberturaJuridico. */
				}
				AtualizarSinistroJuridicoRest.fecharCaso(casoParaAtualizar);
				pagamentosParaFechar.addAll(PagamentoGarantiaBO.getInstance().fecharPagamentosDeCaso(casoParaAtualizar?.Id, garantiasSinistroLista));
				// LECVPV-140-FIX02 FIM
				pagamentoGarantia.Fase__c = 'Fechado';
			}
			// LECVPV-140-FIX03 FIM
			if(pagamentoGarantia != null && 'Fechado'.equals(pagamentoGarantia.Fase__c))
			{ // PLV-4624
				// LECVPV140-FIX04 INICIO
				// if(casoParaAtualizar == null)
				// {
				// 	casoParaAtualizar = casoLista[0];
				// }
				// LECVPV140-FIX04 FIM
				if(MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor == sinistro.movimento)
				{
					return retorno.setError('A cobertura informada já esta fechada', sinistro);
				}
				Decimal valorReabertura = MovimentoSinistroBO.getInstance().calcularValorReabertura(
					AtualizarSinistroJuridicoRest.juntarListasMovClone(
						new List<List<MovimentoSinistro__c>>
						{
							movimentosDaCobertura,
							MovimentoSinistroBO.getInstance().filtrarCobertura(movimentosParaCriar, pagamentoGarantia?.Id, true)
						}
					)
				);
				//LECVP-216 - INICIO
				Set<Id> casoId = new Set<Id>{casoParaAtualizar.Id};
				// LECVPV-142 INICIO
				List<Garantia__c> garantia = GarantiaDAO.getInstance().buscarGarantiasPorSigla(new Set<String>{sinistro.cobertura});
				Set<String> cobertura = new Set<String>{garantia[0].Sigla__c};
				List<PagamentoGarantia__c> pgtoGarantiaValorIndenizado = PagamentoGarantiaDAO.getInstance().buscarPorIdDeCasoECobertura(casoId, cobertura);
				// LECVPV-142 FIM
				//LECVP-216 - FIM

				MovimentoSinistro__c movimentoReabertura = MovimentoSinistroBO.getInstance().criarMovimentoEncerramentoJuridico(  // LECVPV-140-FIX02 INICIO/FIM
					casoParaAtualizar.Id, MovimentoSinistroTO.REATIVACAO, pgtoGarantiaValorIndenizado[0].Capital__c, null, pagamentoGarantia?.Id //LECVP-216 - INICIO / FIM
				);	
					
				movimentosParaCriar.add(movimentoReabertura);


				if(String.isNotBlank(pagAux?.Id) || String.isNotBlank(pagamentoParaAtualizar?.Id))
				{
					pagamentoParaAtualizar = String.isNotBlank(pagamentoParaAtualizar?.Id) ? pagamentoParaAtualizar : pagAux;
					pagamentoParaAtualizar.Valor_indenizado__c = valorReabertura;
				}
				AtualizarSinistroJuridicoRest.reabrirCaso(casoParaAtualizar, sinistro);
			}
			
			if(sinistro.movimento == MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor)
			{
				Boolean existePagamento = MovimentoSinistroBO.getInstance().verificarSeExistePagamentosIndenizacao(
					AtualizarSinistroJuridicoRest.juntarListasMovClone(
						new List<List<MovimentoSinistro__c>> { movimentos, movimentosParaCriar }
					)
				);
				// LECVPV-216-FIX01 - INICIO
				// if(existePagamento)
				// {
				// 	return retorno.setError('Não é possível encerrar um caso que já possui pagamento', sinistro);
				// }
				// LECVPV-216-FIX01 - FIM
				if(casoParaAtualizar == null)
				{
					casoParaAtualizar = casoLista[0];
				}
				// LECVPV-140-FIX02 INICIO
				List<MovimentoSinistro__c> movimentosEncerramento =  new List<MovimentoSinistro__c>(
					CasoBO.getInstance().gerarMovimentosEncerramento(casoLista) 
				);
				if (movimentosEncerramento !=null && movimentosEncerramento.size()>0) {
					movimentosParaCriar.addAll(movimentosEncerramento);
					if(!casoLista[0].Sinistro_Judicial__c)
					{
						casoLista[0].Sinistro_Judicial__c = true;
					} /* Necessário ficar após o método: gerarFechamentoAdministrativoEReaberturaJuridico. */
				}

				// LECVPV-216 INICIO
				// LECVPV-140-FIX04 INICIO
				// if(!garantiasSinistroLista.isEmpty())
				// {
				// 	for(PagamentoGarantia__c pagamentoAux : garantiasSinistroLista)
				// 	{
				// 		if (!'Fechado'.equals(pagamentoAux?.Fase__c)) {
				// 			complementosParaCriar.addAll(
				// 				ComplementoIndenizacaoBO.getInstance().criarComplementosDeFechamento(
				// 					sinistro, pagamentoAux?.ComplementosIndenizacoes__r, pagamentoAux?.Id
				// 				)
				// 			);
				// 		}
				// 	}
				// }
				// LECVPV-140-FIX04 FIM
				// LECVPV-216 FIM

				AtualizarSinistroJuridicoRest.fecharCaso(casoParaAtualizar);
				pagamentosParaFechar.addAll(PagamentoGarantiaBO.getInstance().fecharPagamentosDeCaso(casoParaAtualizar?.Id, garantiasSinistroLista));
				// LECVPV-140-FIX02 FIM
			}
			else if(
				MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_REAJUSTE).contains(
					sinistro.movimento
				)
			) {
				if(casoParaAtualizar == null)
				{
					casoParaAtualizar = casoLista[0];
				}
				casoParaAtualizar.Status = 'Em regulação';
				casoParaAtualizar.Status_Dependente__c = 'Judicial';
				casoParaAtualizar.Sinistro_Judicial__c = true;
			}
			// PLV-4624 INICIO - PEDRO AUGUSTO BRAZ - SYS4B
			
			if(
				!MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_VALOR_CAPITAL).contains(
					sinistro.movimento
				)
			) {
				//PLV-4818 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
				/* MovimentoSinistroTO.CONJ_MOV_JUROS: { 52, 53 } */
				if(
					MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_JUROS).contains(
						sinistro.movimento
					)
				) {
					Decimal valorJuros = MovimentoSinistroBO.getInstance().calcularValorJuros(
						AtualizarSinistroJuridicoRest.juntarListasMovClone(
							new List<List<MovimentoSinistro__c>>
							{
								movimentosDaCobertura,
								MovimentoSinistroBO.getInstance().filtrarCobertura(movimentosParaCriar, pagamentoGarantia?.Id, true)
							}
						),
						true  // movimento de juros sempre serão jurídicos
					);
					Decimal valorMovimento = sinistro.valor - valorJuros;
					if(valorMovimento != 0)
					{
						MovimentoSinistroTO.Movimento movimentoTO = valorMovimento > 0 ?
							MovimentoSinistroTO.ACERTO_JUROS_MAIS : MovimentoSinistroTO.ACERTO_JUROS_MENOS;
					    // LECVPV-140-FIX02 INICIO
							MovimentoSinistro__c movimentoParaCriar = MovimentoSinistroBO.getInstance().criarMovimento(
							casoLista[0].Id, movimentoTO, valorMovimento, null, pagamentoGarantia?.Id, true  // movimento de juros sempre serão jurídicos
							);
						// LECVPV-140-FIX02 FIM						
						movimentosParaCriar.add(movimentoParaCriar);

						// LECVPV-140-FIX04 INICIO
						complementosParaCriar.add(ComplementoIndenizacaoBO.getInstance()
						.criarComplemento(sinistro, valorMovimento, pagamentoGarantia?.Id, movimentoTO.tipoComplemento)); // LECVPV-200 INICIO/FIM // LECVPV-216 INICIO/FIM

						// LECVPV-140-FIX04 FIM
					}
				/* MovimentoSinistroTO.CONJ_MOV_JUROS: { 62, 63 } */
				}
				else if(
					MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_CORRECAO_MONETARIA).contains(
						sinistro.movimento
					)
				) {
					Decimal valorCorrecao = MovimentoSinistroBO.getInstance().calcularValorCorrecao(
						AtualizarSinistroJuridicoRest.juntarListasMovClone(
							new List<List<MovimentoSinistro__c>>
							{
								movimentosDaCobertura,
								MovimentoSinistroBO.getInstance().filtrarCobertura(movimentosParaCriar, pagamentoGarantia?.Id, true)
							}
						),
						true // movimento de correção monetária sempre serão jurídicos
					);
					Decimal valorMovimento = sinistro.valor - valorCorrecao;
					if(valorMovimento != 0)
					{
						MovimentoSinistroTO.Movimento movimentoTO = valorMovimento > 0 ?
							MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS : MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS;
							// LECVPV-140-FIX02 INICIO
								MovimentoSinistro__c movimentoParaCriar = MovimentoSinistroBO.getInstance().criarMovimento(
								casoLista[0].Id, movimentoTO, valorMovimento, null, pagamentoGarantia?.Id, true // movimento de correção monetária sempre serão jurídicos
								);
					        // LECVPV-140-FIX02 FIM
						movimentosParaCriar.add(movimentoParaCriar);

						// LECVPV-140-FIX04 INICIO
						complementosParaCriar.add(ComplementoIndenizacaoBO.getInstance().criarComplemento(sinistro, valorMovimento, pagamentoGarantia?.Id,  movimentoTO.tipoComplemento)); // LECVPV-200 INICIO/FIM // LECVPV-216 INICIO/FIM

						// LECVPV-140-FIX04 FIM
					}
				}
				// LECVPV-140-FIX05 INICIO
					// else
					// {
						// LECVPV-142 INICIO
						// LECVPV-142_FIX04 INICIO
						// Set<Id> casoId = new Set<Id>{casoParaAtualizar.Id};
						// List<Garantia__c> garantia = GarantiaDAO.getInstance().buscarGarantiasPorSigla(new Set<String>{sinistro.cobertura});
						// Set<String> cobertura = new Set<String>{garantia[0].Sigla__c};
						// List<PagamentoGarantia__c> PgtoGarantia = PagamentoGarantiaDAO.getInstance().buscarPorIdDeCasoECobertura(casoId, cobertura);

						// System.debug('PgtoGarantia: ' +  PgtoGarantia);
						// System.debug('PgtoGarantiaId: ' +  PgtoGarantia[0].Id);
						// LECVPV-142 FIM
						// MovimentoSinistroTO.Movimento movimentoTO = MovimentoSinistroTO.MAPA_MOV_POR_VALOR.get(sinistro.movimento);
						// LEC_VPV-148 INICIO
						// MovimentoSinistro__c movimentoEncerramento = MovimentoSinistroBO.getInstance().criarMovimentoJuridico(
						// 	casoLista[0].Id, movimentoTO, null, null, PgtoGarantia[0].Id
						// );
						// LEC_VPV-148 FIM
						// LECVPV-142_FIX04 FIM
						// if(sinistro.movimento == MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor)
						// {
							// LECVPV-140-FIX02 INICIO
								// List<MovimentoSinistro__c> movimentosAux = AtualizarSinistroJuridicoRest.juntarListasMovClone(
								// 	new List<List<MovimentoSinistro__c>> { movimentos, movimentosParaCriar }
								// );
							// LECVPV-140-FIX02 FIM
							// LEC_VPV-148 INICIO
							// Decimal valorFechamento = MovimentoSinistroBO.getInstance().calcularValorFechamento(movimentosAux, PgtoGarantia[0].Id);
							// movimentoEncerramento.ValorMovimento__c = valorFechamento * MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.multiplicadorMaisMenos;
							// movimentosParaCriar.add(movimentoEncerramento);
							// LEC_VPV-148 FIM
							// LECVPV-140-FIX04 INICIO
							// if(!garantiasSinistroLista.isEmpty())
							// {
							// 	for(PagamentoGarantia__c pagamentoAux : garantiasSinistroLista)
							// 	{
							// 		// LECVPV-140-FIX02 INICIO
							// 		if (!'Fechado'.equals(pagamentoAux?.Fase__c)) {
							// 			complementosParaCriar.addAll(
							// 				ComplementoIndenizacaoBO.getInstance().criarComplementosDeFechamento(
							// 					sinistro, pagamentoAux?.ComplementosIndenizacoes__r, pagamentoAux?.Id
							// 				)
							// 			);
							// 		}
							// 		// LECVPV-140-FIX02 FIM
							// 	}
							// }
							//	LECVPV-140-FIX04 FIM
						// }
					// }
					//PLV-4818 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
				// LECVPV-140-FIX05 FIM
			}
			else if(
				MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_REAJUSTE).contains(
					sinistro.movimento
				)
			) {
				if(casoParaAtualizar == null)
				{
					casoParaAtualizar = casoLista[0];
				}
				List<MovimentoSinistro__c> movimentosDessaGarantia = AtualizarSinistroJuridicoRest.juntarListasMovClone(
					new List<List<MovimentoSinistro__c>>
					{
						movimentosDaCobertura,
						MovimentoSinistroBO.getInstance().filtrarCobertura(movimentosParaCriar, pagamentoGarantia?.Id, true)
					}
				);
				Boolean existeIndenizacao = MovimentoSinistroBO.getInstance().verificarSeExistePagamentosIndenizacao(movimentosDessaGarantia);
				Decimal valorIndenizado = MovimentoSinistroBO.getInstance().calcularValorIndenizado(movimentosDessaGarantia);
				Decimal valorDeAjuste = sinistro.valor - valorIndenizado;

				if(valorIndenizado < sinistro.valor)
				{
					MovimentoSinistroTO.Movimento movimentoTO = existeIndenizacao ?
						MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS : MovimentoSinistroTO.AC_AVISADO_MAIS;
					
					// LECVPV-140-FIX02 INICIO
					MovimentoSinistro__c movimentoParaCriar = MovimentoSinistroBO.getInstance().criarMovimento(
						casoLista[0].Id, movimentoTO, valorDeAjuste, null, pagamentoGarantia?.Id, true // PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
					);
					// LECVPV-140-FIX02 FIM
					movimentosParaCriar.add(movimentoParaCriar);
				}
				else if(valorIndenizado > sinistro.valor)
				{
					MovimentoSinistroTO.Movimento movimentoTO = existeIndenizacao ?
						MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS : MovimentoSinistroTO.AC_AVISADO_MENOS;
					
					// LECVPV-140-FIX02 INICIO
					MovimentoSinistro__c movimentoParaCriar = MovimentoSinistroBO.getInstance().criarMovimento(
						casoLista[0].Id, movimentoTO, valorDeAjuste, null, pagamentoGarantia?.Id, true // PLV-4818 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
					);
					// LECVPV-140-FIX02 FIM
					movimentosParaCriar.add(movimentoParaCriar);
				}
				if(String.isNotBlank(pagAux?.Id))
				{
					pagamentoParaAtualizar = String.isNotBlank(pagamentoParaAtualizar?.Id) ?
						pagamentoParaAtualizar : new PagamentoGarantia__c(Id = pagAux?.Id);
					pagamentoParaAtualizar.Valor_indenizado__c = sinistro.valor;
				}
			}
			//PLV-4624 FIM - PEDRO AUGUSTO BRAZ - SYS4B

			if(pagamentoParaCriar != null && sinistro.valor != null && sinistro.valor > 0)
			{
				pagamentoParaCriar.Fase__c = 'Aberto';
				pagamentoParaCriar.Status_do_pagamento__c = 'Em análise';
				pagamentoParaCriar.CurrencyIsoCode = 'BRL';
			}

			if(pagamentoParaCriar == null && sinistro.valor != null && sinistro.valor > 0)
			{
				if(String.isNotBlank(pagAux?.Id))
				{
					pagamentoParaAtualizar = String.isNotBlank(pagamentoParaAtualizar?.Id) ? pagamentoParaAtualizar : new PagamentoGarantia__c(Id = pagAux?.Id); // PLV-4624
					if(sinistro.movimento != MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor)
					{
						pagamentoParaAtualizar.Fase__c = 'Em análise';
						pagamentoParaAtualizar.Status_do_pagamento__c = 'Em análise';
					}
				}
			}
			
			// LECVPV-140-FIX04 INICIO
			// Set<Integer> conjMovComplemento = MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_COMPLEMENTO);

			// if(sinistro.valor != null && sinistro.valor > 0 && (conjMovComplemento.contains(sinistro.movimento)))
			// {
			// 	Decimal valorComplemento = movimentosParaCriar.isEmpty() ? sinistro.valor : movimentosParaCriar.get(movimentosParaCriar.size() - 1).ValorMovimento__c;
			// 	complementosParaCriar.add(ComplementoIndenizacaoBO.getInstance().criarComplemento(sinistro, valorComplemento, pagamentoGarantia?.Id, null));
			// }
			// LECVPV-140-FIX04 FIM
		// PLV-4624 INICIO - PEDRO AUGUSTO BRAZ - SYS4B
		}
		else
		{
			if(casoParaAtualizar == null)
			{
				casoParaAtualizar = new Case();
			}
			casoParaAtualizar.id = casoLista[0].id;
			casoParaAtualizar.Sinistro_Judicial__c = true;
		}
		// PLV-4624 FIM - PEDRO AUGUSTO BRAZ - SYS4B
	
		List<MovimentoSinistro__c> todosMovimentos = new List<MovimentoSinistro__c>(); /* Inclui movimentos existentes e que serão criados independented da cobertura. */
		todosMovimentos.addAll(movimentos);
		todosMovimentos.addAll(movimentosParaCriar);
		system.debug('Giordano -> Movimentos Para Criar: '+movimentosParaCriar);

		Savepoint sp = Database.setSavepoint();
		try {
			retorno.setSucesso(sinistro);
			if(pagamentoParaCriar != null)
			{
				PagamentoGarantiaTriggerHandler.isFirstTime = false;
				insert pagamentoParaCriar;
				if(sinistro.movimento != MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor)
				{
					pagamentoParaCriar.Fase__c = 'Em análise';
					pagamentoParaCriar.Status_do_pagamento__c = 'Em análise';
				}
				update pagamentoParaCriar;
			}

			if(pagamentoParaAtualizar != null && pagamentoParaCriar == null)
			{
				PagamentoGarantiaTriggerHandler.isFirstTime = false;
				update pagamentoParaAtualizar;
			}

			// LEC-VPV-148 INICIO
			// if(!movimentosParaCriar.isEmpty())
			// {
			// 	PagamentoGarantiaBO pgbo = new PagamentoGarantiaBO();
			// 	Integer sequenciaMovimento = MovimentoSinistroBO.getInstance().recuperarSequenciaMovimento(todosMovimentos);
			// 	for(MovimentoSinistro__c movimento : movimentosParaCriar)
			// 	{
			// 		if(String.isBlank(movimento.SequenciaMovimento__c))
			// 		{
			// 			movimento.SequenciaMovimento__c = String.valueOf(++sequenciaMovimento);
			// 		}
			// 		if(
			// 			!MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricaoValor.equals(movimento.DescricaoMovimento__c) &&
			// 			String.isBlank(movimento.PagamentoGarantia__c) &&
			// 			String.isNotBlank(pagamentoParaCriar?.Id)
			// 		) {
			// 			movimento.PagamentoGarantia__c = pagamentoParaCriar.Id;
			// 		}
			// 	}
			// 	PagamentoGarantiaTriggerHandler.isFirstTime = false;
			// 	insert movimentosParaCriar;
			// }
			// LEC-VPV-148 FIM

			if(!complementosParaCriar.isEmpty())
			{
				PagamentoGarantiaTriggerHandler.isFirstTime = false; // LECVPV-140-FIX05 INICIO/FIM 
				insert complementosParaCriar;
			}

			if(casoParaAtualizar != null)
			{
				PagamentoGarantiaTriggerHandler.fechamentoSinistro = true;
				update casoParaAtualizar;
				PagamentoGarantiaTriggerHandler.fechamentoSinistro = false;
			}
			if(!pagamentosParaFechar.isEmpty())
			{
				System.debug('Giordano..... ' + JSON.serialize(pagamentosParaFechar[0]));
				update pagamentosParaFechar;
			}

			// LEC-VPV-148 INICIO
			if(!movimentosParaCriar.isEmpty())
			{
				PagamentoGarantiaBO pgbo = new PagamentoGarantiaBO();
				Integer sequenciaMovimento = MovimentoSinistroBO.getInstance().recuperarSequenciaMovimento(todosMovimentos);
				for(MovimentoSinistro__c movimento : movimentosParaCriar)
				{
					if(String.isBlank(movimento.SequenciaMovimento__c))
					{
						movimento.SequenciaMovimento__c = String.valueOf(++sequenciaMovimento);
					}
					if(
						!MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricaoValor.equals(movimento.DescricaoMovimento__c) &&
						String.isBlank(movimento.PagamentoGarantia__c) &&
						String.isNotBlank(pagamentoParaCriar?.Id)
					) {
						movimento.PagamentoGarantia__c = pagamentoParaCriar.Id;
					}
				}
				PagamentoGarantiaTriggerHandler.isFirstTime = false;
				insert movimentosParaCriar;
			}
			// LEC-VPV-148 FIM
			// LECVPV-148-FIX01 INICIO
			// if(!complementosParaCriar.isEmpty())
			// {
			// 	insert complementosParaCriar;
			// }

			// if(casoParaAtualizar != null)
			// {
			// 	PagamentoGarantiaTriggerHandler.fechamentoSinistro = true;
			// 	update casoParaAtualizar;
			// 	PagamentoGarantiaTriggerHandler.fechamentoSinistro = false;
			// }
			// if(!pagamentosParaFechar.isEmpty())
			// {
			// 	update pagamentosParaFechar;
			// }
			// LECVPV-148-FIX01 FIM

		} catch (Exception e) {
			Database.rollback(sp);
			retorno = new SinistroJuridicoBO.ResponseAtualizar();
			String mensagemErro = String.format(
				'Inconsistências no payload de requisição:\nCausa: {0}\nMensagem: {1}\nStacktrace: {2}',
				new String[] { String.valueOf(e.getCause()), e.getMessage(), e.getStackTraceString() }
			);
			retorno.setError(mensagemErro, sinistro);
		}
		return retorno;
	}

	public static Case reabrirCaso(Case casoParaAtualizar, SinistroJuridicoBO.Request sinistro)
	{
		casoParaAtualizar.Status = 'Em Regulação';
		casoParaAtualizar.Status_Dependente__c = 'Avisado';
		casoParaAtualizar.DataReabertura__c = System.now();
		casoParaAtualizar.MotivosReabertura__c = 'Sinistros reabertos judicialmente';
		casoParaAtualizar.ConsideracoesReabertura__c = 'API - Reabertura Jurídico - Matricula: ' + sinistro.matricula;
		
		if(String.isBlank(casoParaAtualizar.Motivos_de_recusa__c))
		{
			casoParaAtualizar.Motivos_de_recusa__c =  '49';
		} // PLV-4624
		return casoParaAtualizar;
	}

	public static Case fecharCaso(Case casoParaAtualizar)
	{
		casoParaAtualizar.Status = 'Fechado';
		casoParaAtualizar.Status_Dependente__c = 'Cancelado';
		if(String.isBlank(casoParaAtualizar.Motivos_de_recusa__c))
		{
			casoParaAtualizar.Motivos_de_recusa__c = '49';
		}
		return casoParaAtualizar;
	}
}
// POR062-1 - FIM