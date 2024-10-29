public with sharing class PropostaRegrasValidacao
{
	private static final PropostaRegrasValidacao instancia = new PropostaRegrasValidacao();
	public static PropostaRegrasValidacao getInstance(){ return instancia; }
	public PropostaRegrasValidacao() { }

	private final String	PESSOA_FISICA	= 'FIS';
	private final String	PESSOA_JURIDICA	= 'JUR';
	private static List<MeioComercializacao__mdt> mdtsMeiosComercializacao = CustomMetadataTypesDAO.getInstance().obtemMeiosComercializacaoValidacoes();

	public void validaProposta(RetornoPropostaRestTO.ValidacaopropostaTO retorno, EmissaoTO.PayloadTO objPayload, String origem, Map<Integer, CriticaParceiro__c> mapCriticas)
	{
		try
		{
			retorno.devolutivas = this.validaPayload(objPayload, objPayload.proposta.meioComercializacao, origem, mapCriticas);
		}
		catch (Exception e)
		{
			throw new PropostaRegrasValidacaoException('Origem: PropostaRegrasValidacao/gerarProposta/validaProposta/validaPayload <br> - Causa: ' + e.getCause() + ' <br> - linha: ' +  e.getLineNumber() + ' <br> - Mensagem: ' + e.getMessage());
		}
	}

	// PLV 1660-22 | valida se o desconto agravo esta dentro dos paramentros do produto comercial
	public RetornoPropostaRestTO.DevolutivasTO validaPremioDescontoAgravoMassificados(String origem, EmissaoTO.calculoTO noCalculo, Product2 produtoComercial, Map<Integer, CriticaParceiro__c> mapCriticas)
	{
		Decimal descontoAgravo = 0;
		RetornoPropostaRestTO.DevolutivasTO devolutiva = null; 

		// Soma os descontos Agravo do payload
		for(EmissaoTO.DescontoagravoTO descontoAgravoTO : noCalculo.precificacao.descontoAgravo)
			descontoAgravo += descontoAgravo + descontoAgravoTO.percentual;
	
		if(descontoAgravo >= 0)
		{
			if(descontoAgravo > produtoComercial.PercentualAgravoMaximo__c || descontoAgravo < produtoComercial.PercentualAgravoMinimo__c) //  crítica do parceiro código 51 - Prêmio Inválido
				devolutiva = mapeiaDevolutiva(mapCriticas.get(51), origem, null, 51);
		}
		else
		{
			Decimal desconto = descontoAgravo * -1;

			if(desconto > produtoComercial.PercentualDescontoMaximo__c || desconto < produtoComercial.PercentualDescontoMaximo__c)
				 devolutiva = mapeiaDevolutiva(mapCriticas.get(51), origem, null, 51); //  crítica do parceiro código 51 - Prêmio Inválido
		}

		if(devolutiva !=null)
			return devolutiva;
		else
			return null;
	}

	//incli as criticas do retorna de aceitação nas devolutivas
	public List<RetornoPropostaRestTO.DevolutivasTO> validaRetornoAceitacaoProposta(EmissaoTO.PayloadTO objPayload, String origem, List<CriticaParceiro__c> mdtsCriticasProposta)
	{
		List<RetornoPropostaRestTO.DevolutivasTO> devolutivas = new List<RetornoPropostaRestTO.DevolutivasTO>();

		if(objPayload.retornoAceitacao != null)
		{
			Map<Integer, CriticaParceiro__c> mapCriticasRetornoAcc = new Map<Integer, CriticaParceiro__c>();

			

			for(CriticaParceiro__c cr : mdtsCriticasProposta)
			{
				if(cr.CodigoCriticaMotorRegras__c != null)
					mapCriticasRetornoAcc.put(Integer.valueOf(cr.CodigoCriticaMotorRegras__c), cr);
			}

			if(objPayload.retornoAceitacao.analises != null)
			{
				for(EmissaoTO.AnaliseTO analise : objPayload.retornoAceitacao.analises)
				{
					CriticaParceiro__c metadado = mapCriticasRetornoAcc.get(analise.codigo);
					if(metadado != null)
						devolutivas.add(mapeiaDevolutiva(metadado, origem, null, analise.codigo));
					else
						devolutivas.add(mapeiaDevolutiva(null, origem, 'Erro não mapeado, Critica ' + analise.codigo + ' não encontrada no cadastro do parceiro', analise.codigo ));
				}
			}

			if(objPayload.retornoAceitacao.avisos != null)
			{
				for(EmissaoTO.AvisoTO aviso : objPayload.retornoAceitacao.avisos)
				{
					CriticaParceiro__c metadado = mapCriticasRetornoAcc.get(aviso.codigo);
					if(metadado != null)
						devolutivas.add(mapeiaDevolutiva(metadado, origem, null, aviso.codigo));
					else
						devolutivas.add(mapeiaDevolutiva(null, origem, 'Erro não mapeado, Critica ' + aviso.codigo + ' não encontrada no cadastro do parceiro', aviso.codigo));
				}
			}

			if(objPayload.retornoAceitacao.recusas != null)
			{
				for(EmissaoTO.RecusaTO recusa : objPayload.retornoAceitacao.recusas)
				{
					CriticaParceiro__c metadado = mapCriticasRetornoAcc.get(recusa.codigo);
					if(metadado != null)
						devolutivas.add(mapeiaDevolutiva(metadado, origem, null, recusa.codigo));
					else
						devolutivas.add(mapeiaDevolutiva(null, origem, 'Erro não mapeado, Critica ' + recusa.codigo + ' não encontrada no cadastro do parceiro', recusa.codigo));
				}
			}

			if(objPayload.retornoAceitacao.pendencias != null)
			{
				for(EmissaoTO.PendenciaTO pendencia : objPayload.retornoAceitacao.pendencias)
				{
					CriticaParceiro__c metadado = mapCriticasRetornoAcc.get(pendencia.codigo);
					if(metadado != null)
						devolutivas.add(mapeiaDevolutiva(metadado, origem, null, pendencia.codigo));
					else
						devolutivas.add(mapeiaDevolutiva(null, origem, 'Erro não mapeado, Critica ' + pendencia.codigo + ' não encontrada no cadastro do parceiro', pendencia.codigo));
				}
			}
		}

		return devolutivas;
	}

	public List<RetornoPropostaRestTO.DevolutivasTO> validaPayload(EmissaoTO.PayloadTO objPayload, String meioComercializacao, String origem, Map<Integer, CriticaParceiro__c> mapCriticas)
	{
		Product2 psegurado = null;
		Map<String, EmissaoTO.ContratanteTO> 		mapContratantesTO 	= new Map<String, EmissaoTO.ContratanteTO>();
		Map<String, EmissaoTO.SeguradoTO> 			mapseguradosTO 		= new Map<String, EmissaoTO.SeguradoTO>();
		List<RetornoPropostaRestTO.DevolutivasTO> 	lstRetorno 			= new List<RetornoPropostaRestTO.DevolutivasTO>();
		Date dataAtual = System.today();
		
		psegurado = ProductDAO.getInstance().obterPorCodigo(String.valueOf(objPayload.proposta.codigoProdutoVida));

		System.debug('VALIDA PAYLOAD>>>> ' + JSON.serialize(objPayload));
		System.debug('VALIDA meioComercializacao>>>> ' + meioComercializacao);
		System.debug('VALIDA origem>>>> ' + origem);
		System.debug('VALIDA mapCriticas>>>> ' + mapCriticas);
		System.debug('VALIDA meioComercializacao>>>> ' + meioComercializacao);

		if(psegurado != null)
		{
			try
			{
				for(MeioComercializacao__mdt meio : mdtsMeiosComercializacao)
				{
					if(objPayload.proposta.meioComercializacao !=  meio.DeveloperName){
						continue;
					}

					//Data de Gravação inválida | regra: dataArquivo.after(dataAtual)
					if(Date.valueOf(objPayload.proposta.dataCriacaoPortal) > Date.today())
						if(mapCriticas.get(23) != null) {lstRetorno.add(mapeiaDevolutiva(mapCriticas.get(23), origem, null, 23));} //VEP-421 validação critica devolutiva

					//Data da Compra Invalida | Regra: dataCompra.after(dataAtual)
					if(Date.valueOf(objPayload.proposta.dataCriacaoPortal) > Date.today())
						if(mapCriticas.get(33) != null) {lstRetorno.add(mapeiaDevolutiva(mapCriticas.get(33), origem, null, 33));} //VEP-421 validação critica devolutiva

					for (EmissaoTO.ContratanteTO contratante : objPayload.proposta.contratantes)
					{
						if(contratante.numero == null){
							contratante.numero = '1';
						}

						mapContratantesTO.put(contratante.numero, contratante);

						for (EmissaoTO.GrupoTO grupo : contratante.grupos)
						{
							for (EmissaoTO.SeguradoTO segurado : grupo.segurados)
							{
								if(segurado.numero == null){
									segurado.numero = '1';
								}

								mapseguradosTO.put(segurado.numero, segurado);

								Date dataNascimentoSegurado = Date.valueOf(segurado.pessoa.dadosPessoaFisica.dataNascimento);
								// PLV-2294-28 INICIO Alteracao na validacao de idade ao contratar o seguro
								Date dataCalculo = Date.valueOf(objPayload.proposta.dataCalculo);

								//Data de nascimento Invalida ou não aceita, verificar se a data não é maior que a data atual"|"verificar se a idade está entre 18 e 70
								if(dataNascimentoSegurado.addYears(18) > dataCalculo || dataNascimentoSegurado.addYears(71) <= dataCalculo){
									if(mapCriticas.get(73) != null) {lstRetorno.add(mapeiaDevolutiva(mapCriticas.get(73), origem, null, 73));} //VEP-421 validação critica devolutiva
								}
								// PLV-2294-28 FIM Alteracao na validacao de idade ao contratar o seguro

								if(segurado.coberturas == null){
									lstRetorno.add(mapeiaDevolutiva(null, origem, 'Garantias do segurado da proposta não preenchidas no payload de entrada.', null));
									return lstRetorno;
								}
							}
						}
						
                        // --> Internalização Renner (remoção da critica: 36)- INICIO
						//Data de vencimento da parcela invalida |dataVencimentoParcela.before(dataAtual)
						//PLV-5235 : Ação emergencial - INICIO
						// if(contratante.dadosPagamento != null){
						// 	if(date.ValueOf(contratante.dadosPagamento.vencimentoPrimeiraParcela) < Date.today())
						// 		if(mapCriticas.get(36) != null) {lstRetorno.add(mapeiaDevolutiva(mapCriticas.get(36), origem, null, 36));} //VEP-421 validação critica devolutiva
						// }
						//PLV-5235 : Ação emergencial - FIM
                        //--> Internalização Renner (remoção da critica: 36)- FIM 
					}
					
					for(EmissaoTO.ContratanteTO contratante : objPayload.calculo.precificacao.contratantes)
					{
						if(contratante.numero == null){
							contratante.numero = '1';
						}

						EmissaoTO.ContratanteTO contratanteProposta = mapContratantesTO.get(contratante.numero);

						if(contratanteProposta != null)
						{
							if(contratanteProposta.dadosPagamento != null)
							{
								Decimal valorParcela = ContractBO.getInstance().calcularValor(Integer.valueOf(contratanteProposta.dadosPagamento.quantidadeParcelas), 0, objPayload.calculo.precificacao.premio.total);
								System.debug('VALIDA>>>> ' + valorParcela);
								for(PremioMinimoProduto__c pMinimoProduto : psegurado.PremiosMinimoProduto__r)
								{
									if(pMinimoProduto.PremioMinimoParcela__c > valorParcela)
										if(mapCriticas.get(51) != null){lstRetorno.add(mapeiaDevolutiva(mapCriticas.get(51), origem, null, 51));} //VEP-421 validação critica devolutiva
								}
							}
							else
							{
								for(EmissaoTO.GrupoTO grupo : contratante.grupos)
								{
									for(EmissaoTO.SeguradoTO segurado : grupo.segurados)
									{
										if(segurado.numero == null)
											segurado.numero = '1';

										EmissaoTO.SeguradoTO seguradoProposta = mapseguradosTO.get(segurado.numero);
										if(seguradoProposta != null)
										{
											if(seguradoProposta.dadosPagamento != null)
											{
												Decimal valorParcela = ContractBO.getInstance().calcularValor(Integer.valueOf(seguradoProposta.dadosPagamento.quantidadeParcelas), 0, objPayload.calculo.precificacao.premio.total);

												for(PremioMinimoProduto__c pMinimoProduto : psegurado.PremiosMinimoProduto__r)
												{
													if(pMinimoProduto.PremioMinimoParcela__c > valorParcela)
														if(mapCriticas.get(51) != null) {lstRetorno.add(mapeiaDevolutiva(mapCriticas.get(51), origem, null, 51));} //VEP-421 validação critica devolutiva
												}
											}
										}
									}
								}
							}
						}

					}

					// 40 No. de contrato Invalido | != && > 0
					// 61 Rejeitado por erro em registro correspondente |	verifica se a adesão é nula ou vazia
					// 80 Limite de Capital Excedido |"Verifica se o capital é maior que o limite do capital para o CCT (3065), que é 8000.
					// 85 Pagamento já processado anteriormente |	Crítica lançada se em uma lista de pagamentos a chave origem+proposta já está presente

				}
			}
			catch (Exception e){
				throw new PropostaRegrasValidacaoException('Origem: PropostaRegrasValidacao/gerarProposta/mapeiaDevolutiva - Causa: ' + e.getCause() + ' - linha: ' +  e.getLineNumber() + ' - Mensagem: ' + e.getMessage());
			}
		}
		else
			lstRetorno.add(mapeiaDevolutiva(null, origem, 'Produto não encontrado', null));
		
		return lstRetorno;
	}

	public RetornoPropostaRestTO.DevolutivasTO mapeiaDevolutiva(CriticaParceiro__c critica, String origem, String criticaCustomizada, Integer codigo)
	{
		System.debug('MapeiaDevolutiva - Critica>>>>' + critica);
		try
		{
			RetornoPropostaRestTO.DevolutivasTO linha = new RetornoPropostaRestTO.DevolutivasTO();

			if(critica == null)
			{
				if(codigo == null)
					codigo = -3;

				if(String.isBlank(criticaCustomizada)){
					criticaCustomizada = 'Erro não mapeado, Critica ' + codigo + ' não encontrada no cadastro do parceiro';
				}

				linha.codigo		= -3;
				linha.origem		= origem;
				linha.tipoRegistro	= null;
				linha.numeroCampo	= null;
				linha.descricao		= criticaCustomizada;
			}
			else
			{
				linha.codigo		= Integer.valueOf(critica.Name);
				linha.origem		= origem;
				linha.numeroCampo	=  String.isNotBlank(critica.IdentificacaoCampo__c) ? Integer.valueOf(critica.IdentificacaoCampo__c) : null;
				linha.descricao		= critica.Rotulo__c.touppercase() + ' - ' + critica.Mensagem__c;
				linha.tipoRegistro	= critica.TipoRegistro__c != null ? Integer.valueOf(critica.TipoRegistro__c) : null;
			}
	
			return linha;
		}
		catch (Exception e)
		{
	
			throw new PropostaRegrasValidacaoException('Origem: PropostaRegrasValidacao/gerarProposta/mapeiaDevolutiva - Causa: ' + e.getCause() + ' - linha: ' +  e.getLineNumber() + ' - Mensagem: ' + e.getMessage());
		}
	}

	public RetornoPropostaRestTO.DevolutivasTO validaCpfsCnpjsPayload(EmissaoTO.PayloadTO objPayload, Map<Integer, CriticaParceiro__c> mapCriticas, string origem){

		Set<String> setContas = new Set<String>();

		if(objPayload.proposta.remuneracoes != null){
	      if(objPayload.proposta.remuneracoes != null){
	        for(EmissaoTO.RemuneracaoTO remuneracaoTO : objPayload.proposta.remuneracoes){
	          for(EmissaoTO.FavorecidoTO agenteTO : remuneracaoTO.favorecidos)
	            setContas.add( montarChavePessoa( agenteTO.pessoa ) );
	        }
	      }
	    }

	    if(objPayload.proposta.contratantes != null){
	      for(EmissaoTO.ContratanteTO contratanteTO : objPayload.proposta.contratantes){
	      	string idExternoConta = montarChavePessoa(contratanteTO.pessoa);
	        setContas.add(idExternoConta);
	        
	        for(EmissaoTO.GrupoTO gp : contratanteTO.grupos){
	        	for(EmissaoTO.SeguradoTO seg : gp.segurados)
	            	setContas.add(montarChavePessoa(seg.pessoa));
	        }

	        if(contratanteTO.dadosPagamento != null){
	          if(contratanteTO.dadosPagamento.responsavelPagamento != null){
	            string idExternoDadosPGTO;

	            if(contratanteTO.dadosPagamento.responsavelPagamento.tipo == PESSOA_FISICA)
	              idExternoDadosPGTO = contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaFisica.numeroCpf + contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaFisica.digitoCpf;
	            else if(contratanteTO.dadosPagamento.responsavelPagamento.tipo == PESSOA_FISICA)
	              idExternoDadosPGTO = contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaJuridica.numeroCnpj + contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaJuridica.ordemCnpj + contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaJuridica.digitoCnpj;

	            setContas.add(IdExternoDadosPGTO);
	          }
	        }
	      }
	    }

	  

	    if(setContas.size() > 0)
	    {
	    	for(String cpfCnj : setContas)
	    	{
	    		if(cpfCnj.length() <= 11){
	    			if(!Util.isCPF(cpfCnj)){
	    		
						return mapeiaDevolutiva(mapCriticas.get(32), origem, null, 32);
					}
	    		}
	    			
	    		else{
	    			if(!Util.isCNPJ(cpfCnj)){
	    		
						return mapeiaDevolutiva(mapCriticas.get(32), origem, null, 32);
					}
    			}
	    	}
	    }

	    return null;
	}

	public String montarChavePessoa(EmissaoTO.PessoaTO pessoa)
	{
		String IdExterno;

		if(pessoa.tipo == PESSOA_JURIDICA)
			IdExterno = pessoa.dadosPessoaJuridica.numeroCnpj + pessoa.dadosPessoaJuridica.ordemCnpj + pessoa.dadosPessoaJuridica.digitoCnpj;
		else if(pessoa.tipo == PESSOA_FISICA)
			IdExterno = pessoa.dadosPessoaFisica.numeroCpf + pessoa.dadosPessoaFisica.digitoCpf;

		return IdExterno;
	}

	public class PropostaRegrasValidacaoException extends Exception {}
}