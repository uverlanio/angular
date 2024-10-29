/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-01-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class BotaoCancelarContratoController {
	
	//PLV-3872 - INICIO - Inclusão de novas classes para o fluxo
	private class BotaoCancelarException extends Exception {}

	
	private static ContractBO bo = ContractBO.getInstance();
	private static ContractDAO dao = ContractDAO.getInstance(); // analise 5331
	private static CIVServices civServ = CIVServices.getInstance();
	//PLV-3872 - FIM

	//PLV-3872 - INICIO - Ajuste na chamada de serviço de orçamento
	@AuraEnabled
	public static String cancelarContratoSelecionado(Id idContrato, String tipoEndosso){
		ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
		ServiceTO.OrcamentoCalculoTO orcamento = new ServiceTO.OrcamentoCalculoTO();
		
		Contract contrato = dao.buscarContratoById(idContrato);
		System.debug('************** contrato.status ' + contrato.Status);
		if(contrato.Status == 'Cancelado')
		{

			return '{"message":"Contrato já cancelado."}';  
		} else {
			orcamento.empresa         = contrato.Empresa__c;
			orcamento.sucursal        = contrato.Sucursal__c;
			orcamento.ramo            = contrato.RamoSeguro__r.Codigo__c;
			orcamento.apolice         = contrato.NumeroApolice__c;
			orcamento.tipoSeguro      = 'CAN';
			orcamento.tipoEndosso     = tipoEndosso;
			orcamento.dataCalculo     = System.today(); //mudar para hoje
			orcamento.vigenciaInicial = contrato.StartDate;
			orcamento.meioComercializacao = contrato.MeioComercializacao__c;
			orcamento.tarifa = contrato.Tarifa__c; //PLV-5300 - INICIO/FIM
			
			param.orcamento = orcamento;

			try{				
				System.debug('***************** entrou no try');
				// PLV-4606 - INCIO
				ServiceTO.DataCancelamentoTO retornoCalculo;
				if(!Test.IsRunningTest()) {
					//VIAG-271 - INICIO
					System.debug('***************** orcamento ---> '+ orcamento);
					System.debug('***************** param ---> '+ param);
					// if(orcamento.segmento == 'Viagem'){

						String response =  SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.OFERTAS_CANCELAMENTO_VIAGEM, JSON.serialize(param));//SensediaServices.getInstance().chamadasViagem(JSON.serialize(param), 'Ofertas_Cancelamento_Viagem_Sensedia');
						if(response != null && response != ''){
							retornoCalculo = (ServiceTO.DataCancelamentoTO) JSON.deserialize(response, ServiceTO.DataCancelamentoTO.class);
						}
						
						//retornoCalculo = CIVServices.getInstance().calculoOrcamentoOferta(param);
					// } else {
					// 	retornoCalculo = CIVServices.getInstance().calculoOrcamentoOferta(param);
					// }
					//VIAG-271 - FIM
				}
				// PLV-4606 - FIM
				System.debug('===> Retorno: ' + JSON.serialize(retornoCalculo));

				return JSON.serialize(retornoCalculo);
			} catch(Exception e){
				System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
        		throw new BotaoCancelarException(e.getLineNumber() + ': ' + e);
			}
		}
	}
	//PLV-3872 - FIM

	//PLV-3872 - INICIO - Criação do chamada de endosso
	@AuraEnabled
	public static String gerarPropostaEndosso(Integer numeroOrcamento, Id idContrato,  Date dataCancel){ // PLV-4172
		//PLV-4695-FIX6 - INICIO
		system.debug('dados para geração da proposta:');
		system.debug('numeroOrcamento:'+numeroOrcamento);
		system.debug('idContrato:'+idContrato);
		system.debug('dataCancel:'+dataCancel);
		
		//PLV-4695-FIX6 - FIM
		// PLV-4606-INICIO
		EmissaoTO.PayloadTO propostas = new EmissaoTO.PayloadTO();
		populaEmissaoTO(propostas, numeroOrcamento, idContrato, dataCancel);
	
		// PropostaEndossoTO propostas = new PropostaEndossoTO();
		
		// PropostaTO proposta = new PropostaTO();
		
		// proposta.numeroOrcamento = numeroOrcamento;
		// proposta.tipoSeguro = 'CAN';
		// propostas.propostas = new List<PropostaTO>();
		// propostas.propostas.add(proposta);
		
		dataCancel = validarDataInicialVigencia(idContrato, dataCancel); //PLV-4678 Inicio/Fim
		
		system.debug('JSON entrada ' + JSON.serialize(propostas, true));
		String retorno;
		
		//VIAG-271 INICIO
		//MGRC-1571-INICIO TRANSMISSAO CANCELAMENTO

		String jsonEntrada = JSON.serialize(propostas, true);
		system.debug('JSON entrada ' + jsonEntrada);

		Map<String, Object> calculosMap = (Map<String, Object>) JSON.deserializeUntyped(jsonEntrada);
		String codigoProdutoVida;

		if (calculosMap.containsKey('propostas') && calculosMap.get('propostas') != null) {
			List<Object> propostasList = (List<Object>) calculosMap.get('propostas');

			if (!propostasList.isEmpty()) {
				// Acessa o primeiro item da lista 'propostas'
				Map<String, Object> propostaMap = (Map<String, Object>) propostasList[0];
				
				// Acessa o campo 'proposta'
				if (propostaMap.containsKey('proposta') && propostaMap.get('proposta') != null) {
					Map<String, Object> propostaInnerMap = (Map<String, Object>) propostaMap.get('proposta');
					
					// Acessa o campo 'contratoOriginal'
					if (propostaInnerMap.containsKey('contratoOriginal') && propostaInnerMap.get('contratoOriginal') != null) {
						Map<String, Object> contratoOriginalMap = (Map<String, Object>) propostaInnerMap.get('contratoOriginal');
						
						// Acessa o campo 'codigoProdutoVida'
						if (contratoOriginalMap.containsKey('codigoProdutoVida')) {
							codigoProdutoVida = (String) contratoOriginalMap.get('codigoProdutoVida');
							System.debug('codigoProdutoVida => ' + codigoProdutoVida);
						}
					}
				}
			}

			if(!Test.IsRunningTest()){
				Opportunity orcamento = OpportunityDAO.getInstance().obterOportunidadesPorNumero(String.valueOf(numeroOrcamento).leftPad(8,'0'));
				if (orcamento.segmento__c == 'Viagem') {
					retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.TRANSMISSAO_CANCELAMENTO_VIAGEM, JSON.serialize(propostas, true));//SensediaServices.getInstance().chamadasViagem(JSON.serialize(propostas, true), 'Transmissao_Cancelamento_Viagem_Sensedia');
				} else {
					switch on codigoProdutoVida {
						//MGRC-1580-INICIO
						when 'VIDA_ON' {
							retorno = SensediaServices.getInstance().montagemServicoSensedia(
								SensediaServices.VERB.POST, 
								SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
								SensediaServices.TRANSMISSAO_CANCELAMENTO_VIDA_ON, 
								JSON.serialize(propostas, true)
							);
						}
						//MGRC-1580-FIM
						//MGRC-1578-INICIO
						when 'VI-PESSOAS' {
							System.debug('VI-PESSOAS entrou => ');
							System.debug('JSON.serialize(propostas, true) entrou => '+ JSON.serialize(propostas, true));
							retorno = SensediaServices.getInstance().montagemServicoSensedia(
								SensediaServices.VERB.POST, 
								SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
								SensediaServices.TRANSMISSAO_CANCELAMENTO_VDSJ, 
								JSON.serialize(propostas, true)
							);
						}
						//MGRC-1578-FIM
						//MGRC-1579-INICIO
						when 'APTLMKT' {
							retorno = SensediaServices.getInstance().montagemServicoSensedia(
								SensediaServices.VERB.POST, 
								SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
								SensediaServices.TRANSMISSAO_CANCELAMENTO_APTLMKT, 
								JSON.serialize(propostas, true)
							);
						}
						//MGRC-1579-FIM
					}
				}
				// retorno = civServ.criacaodepropostasinistro(JSON.serialize(propostas, true));
			}

		}
		//VIAG-271 FIM	
		//MGRC-1571-FIM TRANSMISSAO CANCELAMENTO

		// PLV-4606-FIM

		system.debug('retorno integraçao => ' + retorno); 	//MGRC-1571-BUGFIX-INICIO/FIM

		gerarPremioRecuperaAGE(idContrato,dataCancel); // PLV-4172 
		gerarPremioRecuperaCOR(idContrato,dataCancel); // PLV-4450
				
		return retorno;
	}
	//PLV-3872 - FIM

	//PLV-4154 - INICIO - Criacao de metodo para atender a nova necessidade da data ser informada
	@AuraEnabled
	public static String gerarOrcamentoEndosso(Id idContrato, String tipoEndosso, Date dataCancelar){ // analise 5331 
		ServiceTO.ParamOrcamentoCalculoTO param = new ServiceTO.ParamOrcamentoCalculoTO();
		ServiceTO.OrcamentoCalculoTO orcamento = new ServiceTO.OrcamentoCalculoTO();
		Contract contrato = dao.buscarContratoById(idContrato); // analise 5331 
		System.debug('************** contrato.status ' + contrato.Status);
		dataCancelar = validarDataInicialVigencia(idContrato, dataCancelar); //PLV4678 Inicio/Fim // analise 5331
		//PLV-4695-FIX6 - INICIO
		system.debug('teste santana:'+contrato.Tipo__c);
		system.debug('teste santana:'+contrato.Endosso__c);
		
		if(contrato.Status != 'Emitido' || contrato.Tipo__c == 'Cancelamento')
		{

			return '{"message":"Status do contrato diferente de Emitido. Contrato não pode ser cancelado."}';  
		} else {
			orcamento.empresa         = contrato.Empresa__c;
			orcamento.sucursal        = contrato.Sucursal__c;
			orcamento.ramo            = contrato.RamoSeguro__r.Codigo__c;
			orcamento.apolice         = contrato.NumeroApolice__c;
			orcamento.tipoSeguro      = 'CAN';
			orcamento.tipoEndosso     = tipoEndosso;
			orcamento.dataCalculo     = dataCancelar;
			orcamento.vigenciaInicial = dataCancelar; //PLV-4678 - Inicio/Fim
			orcamento.meioComercializacao = contrato.MeioComercializacao__c;
			orcamento.segmento = contrato.Segmento__c; //PLV-4695-VI-INICIO/FIM
			orcamento.endosso = contrato.Endosso__c; //PLV-4695-FIX6 - INICIO/FIM
			orcamento.tarifa = contrato.Tarifa__c; //PLV-5300 - INICIO/FIM


			param.orcamento = orcamento;
			System.debug('analise 5331 serialize');
			System.debug(JSON.serialize(param));
            
			try{
				System.debug('***************** entrou no try');
                //PLV-4678 Inicio
                ServiceTO.DataCancelamentoTO retornoCalculo = new ServiceTO.DataCancelamentoTO();

                if(!Test.isRunningTest()){
                    //VIAG-271 - INICIO
					//MGRC-1489-INICIO
					//MGRC-1509-INICIO
					System.debug('***************** orcamento ---> '+ orcamento);
					System.debug('***************** param ---> '+ param);

					// if(orcamento.segmento == 'Viagem'){

						String response =  SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.OFERTAS_CANCELAMENTO_VIAGEM, JSON.serialize(param));//SensediaServices.getInstance().chamadasViagem(JSON.serialize(param), 'Ofertas_Cancelamento_Viagem_Sensedia');
						if(response != null && response != ''){
							retornoCalculo = (ServiceTO.DataCancelamentoTO) JSON.deserialize(response, ServiceTO.DataCancelamentoTO.class);
						}

						//retornoCalculo = CIVServices.getInstance().calculoOrcamentoOferta(param);
					// } else {
					// 	retornoCalculo = CIVServices.getInstance().calculoOrcamentoOferta(param);
					// }
					//VIAG-271 - FIM
					//MGRC-1509-FIM
					//MGRC-1489-FIM
                      
                }else{
                    String retorno = '{"data":{"ofertas":[{"orcamento":{"valorTotalPremio":null,"tipoSeguro":"CAN","status":"Disponível para contratação","numeroOrcamento":"30339"}}]}}';
                    retornoCalculo = (ServiceTO.DataCancelamentoTO) JSON.deserialize(retorno, ServiceTO.DataCancelamentoTO.class);
                }

				System.debug('===> Retorno: ' + JSON.serialize(retornoCalculo));
				if(retornoCalculo.data != null){
					if(!retornoCalculo.data.ofertas.isEmpty()){
						if(retornoCalculo.data.ofertas[0].orcamento != null){
							retornoCalculo.data.ofertas[0].orcamento.valorTotalPremio = preencherValorTotalPremio(retornoCalculo.data.ofertas[0].orcamento.numeroOrcamento);
						}
					}
				}
				//PLV-4678 - Fim
				
				//PLV-5057 INICIO
				Contract ctrOld = new Contract(ID = idContrato, Usuario_temporario__c = UserInfo.getUserId());
				update ctrOld;
				//PLV-5057 FIM

				return JSON.serialize(retornoCalculo);
			} catch(Exception e){
				System.debug('ERRO:' + e.getLineNumber() + ': ' + e.getMessage());
        		throw new BotaoCancelarException(e.getLineNumber() + ': ' + e);
			}
		}
		//PLV-4695-FIX6 - FIM
	}
	//PLV-4154 - FIM

	//PLV-3872 - INICIO - Criação de estrutura para criar a chamada do serviço de proposta
	public class PropostaEndossoTO {
		public List<PropostaTO> propostas {get;set;}
	}

	public class PropostaTO {
		public Integer numeroOrcamento {get;set;}
		public String tipoSeguro { get; set; }
	}
	//PLV-3872 - FIM

    //PLV-4270 - INÍCIO
	@AuraEnabled
	public static String obterPerfil(){
        Id profileId = userinfo.getProfileId();
        String profileName = [ SELECT Id, Name FROM Profile WHERE Id =: profileId ].Name;
		System.debug('profileName: ' + profileName);
		return profileName;
    }
    //PLV-4270 - FIM

	//PLV-4172 - INICIO - recuperação agenciamento
	@AuraEnabled
	public static void gerarPremioRecuperaAGE(Id idContrato,  Date dataCancel){
		
		System.debug( ' @  gerarPremioRecupera => ');
		
		List<Contract> contractLst = new List<Contract>([	
			SELECT 	
				Id, 
				Name,
				StartDate, 
				VigenciaFinal__c, 
				PremioTotal__c, 
				PremioPuro__c, 
				Endosso__c, 
				NumeroPropostaUnico__c,
				AccountId,
				NumeroApolice__c,
				Empresa__c,
				CodigoRamo__c,
				Sucursal__c,
				CodigoModalidade__c,
				Account.Cpf__c,
				Account.Cnpj__c,
				Account.RamoAtividade__c,
				Account.Papel__c,
				Account.Tributavel__c,
				CodigoCorretor__r.Name,
				RamoSeguro__r.Codigo__c,
				PremioComercial__c,
				Proposta__r.QuantidadeParcelas__c,
				Proposta__r.Origem__c,
				Origem__c,  //PLV-5884 FIX-12 INICIO/FIM
				(	
					SELECT 
						Id,
						QuantidadeParcelas__c
					FROM ContratantesContrato__r
				),
				(	
					SELECT 
						Id,
						TipoRemuneracao__c, 
						TipoRemuneracao__r.Name, 
						Percentual__c
					FROM RemuneracoesContrato__r 
					WHERE TipoRemuneracao__r.Name ='AGENCIAMENTO'
				)
				FROM Contract
				WHERE Id = :idContrato 
		]);
		System.debug(' @@ contractLst ' + contractLst);

		If(contractLst.isEmpty() || contractLst[0].RemuneracoesContrato__r.isEmpty()) return;
		Contract contrato = contractLst[0];
		Id remuneracao = contrato.RemuneracoesContrato__r[0].Id;

		List<FavorecidoRemuneracaoContrato__c> participacao = [
			SELECT 	
				Participacao__c,
				Papel__c
			FROM FavorecidoRemuneracaoContrato__c
			WHERE RemuneracaoContrato__c = :remuneracao
		];

		if(participacao.isEmpty()) return;

		String papel = participacao[0].Papel__c;
		if(papel != 'Corretor') return;

		System.debug('participacao ==> ' + participacao[0].Participacao__c);

		integer qntParcelaPaga = 0;
		double	totalpago = 0;
		ParcelamentoContratoTO retornoPercela = ContractFacade.getInstance().ObterParcelasContratoSegurado(contrato.ContratantesContrato__r[0].Id);
		
		double valorParcela = Double.valueOf(retornoPercela.data[0].valorliquido); // PLV-4172 - FIX 3

		for(ParcelamentoContratoTO.DataTO parc : retornoPercela.data) {
			if ( parc.status=='PAGA' ) {
				qntParcelaPaga ++ ;
				totalpago += Double.valueOf(parc.valorliquido); // PLV-4172 - FIX 3
			}
		}
		
		double premioRecupera;
		if(contrato.StartDate < dataCancel){
			// PLV-4172 - FIX 3 - INICIO
			Decimal qtdDiasInicio = contrato.StartDate.daysBetween( dataCancel ) + 1; 
			Decimal pRata = qtdDiasInicio.divide(contrato.StartDate.daysBetween( contrato.VigenciaFinal__c ) + 1, 5);
			double percAgenc = contrato.RemuneracoesContrato__r[0].Percentual__c;

			double premioTotal = valorParcela;

			double min;
			min = math.min( percAgenc, 100*qntParcelaPaga ) ;
			
			premioRecupera = premioTotal * ( ( min - ( pRata*percAgenc ) ) / 1200 ); 
			
			System.debug( ' @  inicio vigencia  => ' + contrato.StartDate );
			System.debug( ' @  final vigencia  => ' + contrato.VigenciaFinal__c );
			System.debug( ' @  dataCancel  => ' + dataCancel );
			System.debug( ' @  pRata  => ' + pRata );
			System.debug( ' @  percAgenc  => ' + percAgenc );
			System.debug( ' @  qntParcelaPaga  => ' + qntParcelaPaga );
			System.debug( ' @  premioTotal  => ' + premioTotal );
			System.debug( ' @  min  => ' + min );
			System.debug( ' @  premioRecupera 1 => ' + premioRecupera );

			if( premioRecupera < 0 ) premioRecupera = 0;
			if( premioRecupera > 0 ) premioRecupera = -premioRecupera;

			System.debug( ' @  premioRecupera 2 => ' + premioRecupera );
			// PLV-4172 - FIX 3 - FIM
		}
		else premioRecupera = totalpago;
		
		HerokuService.extRemuneracaoCancelaTO req = new HerokuService.extRemuneracaoCancelaTO();

		req.idconta = contrato.AccountId;
		req.cnpjcpf = contrato.Account.Cpf__c != null? contrato.Account.Cpf__c : contrato.Account.Cnpj__c;
		req.datacancelamento = String.valueOf(dataCancel);
		req.datavencimentoparcela = String.valueOf(System.today()); // PLV-4846-INICIO/FIM HENRIQUE R. META
		req.empresa = contrato.Empresa__c;
		req.sucursal = contrato.Sucursal__c;
		req.ramo = contrato.CodigoRamo__c;
		req.apolice = contrato.Name.substring(0, contrato.Name.length()-1) + (Integer.valueOf(contrato.Endosso__c) + 1); // PLV-4172 - FIX 4
		req.endosso = String.valueOf(Integer.valueOf(contrato.Endosso__c) + 1); // PLV-4172 - FIX 4
		req.origem = contrato.Origem__c; //PLV-5884 FIX-12 INICIO/FIM
		req.numeroproposta = contrato.NumeroPropostaUnico__c;
		req.quantidadeparcelas = contrato.ContratantesContrato__r[0].QuantidadeParcelas__c;
		req.ramogarantia = contrato.RamoSeguro__r.Codigo__c;
		req.modalidade = contrato.CodigoModalidade__c;
		req.tipoconta = papel;
		req.tiporemuneracao = 'AGE';
		req.percentualtiporemuneracao = contrato.RemuneracoesContrato__r[0].Percentual__c;
		req.valorremuneracao = String.valueOf(premioRecupera);
		req.percentualparticipacaofavorecido = participacao[0].Participacao__c;
		req.premioliquido = 0 - valorParcela; // PLV-4172 - FIX 3
		req.susepcorretor = contrato.CodigoCorretor__r.Name;
		req.tributacao = contrato.Account.Tributavel__c;
		
		System.debug( ' @  req ext rem => ' + JSON.serialize(req) );
		String respExtRem = HerokuService.getInstance().startHerokuExtratoRemuneracaoCancelamento(req);
		System.debug( ' @  resp ext rem => ' + respExtRem );

	}
	//PLV-4172 - FIM
	//PLV-4601-FIX3 - INICIO
	@AuraEnabled
	public static void gerarPremioRecuperaCOR(Id idContrato,  Date dataCancel){
		gerarPremioRecuperaCOR(idContrato, dataCancel, true);
	}
	//PLV-4601-FIX3 - FIM

	//PLV-4450 - INICIO
	@AuraEnabled
	public static double gerarPremioRecuperaCOR(Id idContrato,  Date dataCancel, Boolean geraExtrato){ //PLV-4601-FIX3 - INICIO/FIM
		System.debug('id contrato Danilo BTNCONTROLLER: '+ idContrato);
		System.debug( ' @  gerarPremioRecupera => ');
		
		List<Contract> contractLst = new List<Contract>([	
			SELECT 	
				Id,
				Name, // PLV-4450 - FIX 3
				StartDate, 
				VigenciaFinal__c, 
				PremioTotal__c, 
				PremioPuro__c, 
				Endosso__c, 
				NumeroPropostaUnico__c,
				AccountId,
				NumeroApolice__c,
				Empresa__c,
				CodigoRamo__c,
				Sucursal__c,
				CodigoModalidade__c,
				Account.Cpf__c,
				Account.Cnpj__c,
				Account.RamoAtividade__c,
				Account.Papel__c,
				Account.Tributavel__c,
				CodigoCorretor__r.Name,
				RamoSeguro__r.Codigo__c,
				PremioComercial__c,
				Proposta__r.QuantidadeParcelas__c,
				Proposta__r.Origem__c, 
				Origem__c,  //PLV-5884 FIX-13 INICIO/FIM
				Oportunidade__r.PremioComercial__c, // PLV-4450 - FIX 3
				(	
					SELECT 
						Id,
						QuantidadeParcelas__c
					FROM ContratantesContrato__r
				),
				(	
					SELECT 
						Id,
						TipoRemuneracao__c, 
						TipoRemuneracao__r.Name, 
						Percentual__c
					FROM RemuneracoesContrato__r 
				)
			FROM Contract
			WHERE Id = :idContrato
		]);
		
		System.debug(' @@ contractLst COR =>>> ' + contractLst);

		If(contractLst.isEmpty() || contractLst[0].RemuneracoesContrato__r.isEmpty()) return null; //PLV-4601-FIX3 - INICIO/FIM
		Contract contrato = contractLst[0];
		// Id remuneracao = contrato.RemuneracoesContrato__r[0].Id;

		integer qntParcelaPaga = 0;
		double	totalpago = 0;
		system.debug('Contratante Contrato>> ' + contrato.ContratantesContrato__r[0].Id);
		ParcelamentoContratoTO retornoPercela = ContractFacade.getInstance().ObterParcelasContratoSegurado(contrato.ContratantesContrato__r[0].Id);
		
		for(ParcelamentoContratoTO.DataTO parc : retornoPercela.data) {
			if ( parc.status == 'PAGA') {
				qntParcelaPaga++;
				totalpago += Double.valueOf(parc.valorparcela);
			}
		}

		//
		// VALIDAÇÕES DE AGENCIAMENTO PARA GERAR DADOS NA EXTRATO REMUNERACAO - INICIO
		//
		List<Id> idsRemuneracoes = new List<Id>();
		for(RemuneracaoContrato__c remuneracao : contrato.RemuneracoesContrato__r){
			idsRemuneracoes.add(remuneracao.Id);
		}

		Boolean validacaoAgenciamento = false;
		Boolean validacaoParcelas = false;

		RemuneracaoContrato__c idRemuneracaoCorretagem;
		RemuneracaoContrato__c idRemuneracaoAgenciamento;
		for(RemuneracaoContrato__c remuneracao : contrato.RemuneracoesContrato__r){
			if(remuneracao.TipoRemuneracao__r.Name == 'CORRETAGEM'){
				idRemuneracaoCorretagem = remuneracao;
			}
			if(remuneracao.TipoRemuneracao__r.Name == 'AGENCIAMENTO'){
				idRemuneracaoAgenciamento = remuneracao;
				if(remuneracao.Percentual__c > 0){
					validacaoAgenciamento = true;
				}
			}
		}
		System.debug('VALIDAÇÂOAGENCIAMENTO ===>' + validacaoAgenciamento);
		if(validacaoAgenciamento){
			if((qntParcelaPaga - (idRemuneracaoAgenciamento.Percentual__c / 100)) > 0){
				validacaoParcelas = true;
			}
		}
		System.debug('VALIDACAOPARCELAS ===>' + validacaoParcelas);
		
		// Encerra o processo caso o cliente já tiver pago para o agenciador, 
		// os agenciadores nao recebem pelo cancelamento
		if(validacaoAgenciamento){
			if((qntParcelaPaga - (idRemuneracaoAgenciamento.Percentual__c / 100)) == 0){
				return null; //PLV-4601-FIX3 - INICIO/FIM
			}
			if(validacaoAgenciamento != validacaoParcelas){
				return null; //PLV-4601-FIX3 - INICIO/FIM
			}
		}

		List<FavorecidoRemuneracaoContrato__c> favorecidos = [
			SELECT 	
				Id,
				Participacao__c,
				Susep__c
			FROM FavorecidoRemuneracaoContrato__c
			WHERE RemuneracaoContrato__c = :idRemuneracaoCorretagem.Id
		];

		if(favorecidos.isEmpty()) return null; //PLV-4601-FIX3 - INICIO/FIM

		System.debug(favorecidos);

		//
		// VALIDAÇÕES DE AGENCIAMENTO PARA GERAR DADOS NA EXTRATO REMUNERACAO - FIM
		//
		
		
		
		HerokuService.extRemuneracaoCancelaTO req = new HerokuService.extRemuneracaoCancelaTO();

		req.idconta = contrato.AccountId;
		req.cnpjcpf = contrato.Account.Cpf__c != null? contrato.Account.Cpf__c : contrato.Account.Cnpj__c;
		req.datacancelamento = String.valueOf(dataCancel);
		req.datavencimentoparcela = String.valueOf(System.today()); // PLV-4846-INICIO/FIM HENRIQUE R. META
		req.empresa = contrato.Empresa__c;
		req.sucursal = contrato.Sucursal__c;
		req.ramo = contrato.CodigoRamo__c;
		req.apolice = contrato.Name.substring(0, contrato.Name.length()-1) + (Integer.valueOf(contrato.Endosso__c) + 1); // PLV-4172 - FIX 4
		req.endosso = String.valueOf(Integer.valueOf(contrato.Endosso__c) + 1); // PLV-4172 - FIX 4
		req.origem = contrato.Origem__c; //PLV-5884 FIX-13 INICIO/FIM
		req.numeroproposta = contrato.NumeroPropostaUnico__c;
		req.quantidadeparcelas = contrato.ContratantesContrato__r[0].QuantidadeParcelas__c;
		req.ramogarantia = contrato.RamoSeguro__r.Codigo__c;
		req.modalidade = contrato.CodigoModalidade__c;
		req.tipoconta = 'Corretor';
		req.tiporemuneracao = 'COR';
		req.percentualtiporemuneracao = idRemuneracaoCorretagem.Percentual__c;
		req.premioliquido = contrato.Oportunidade__r.PremioComercial__c == null ?  0 - contrato.PremioComercial__c : 0 - contrato.Oportunidade__r.PremioComercial__c; // PLV-4450 - FIX 3 //PLV-5884 FIX-14 INICIO/FIM 
		req.tributacao = contrato.Account.Tributavel__c;
		
		System.debug( ' @  req ext rem => ' + JSON.serialize(req) );
		double premioRecuperaTotal = 0.0; //PLV-4601-FIX3 - INICIO/FIM
		for(FavorecidoRemuneracaoContrato__c favorecido : favorecidos){
			System.debug( ' ID FAVORECIDO => ' + favorecido.Id );
			double premioRecupera = (contrato.PremioComercial__c * (idRemuneracaoCorretagem.Percentual__c / 100)) * (favorecido.Participacao__c / 100);
			premioRecuperaTotal = premioRecuperaTotal + premioRecupera; //PLV-4601-FIX3 - INICIO/FIM		
			req.percentualparticipacaofavorecido = favorecido.Participacao__c;
			req.susepcorretor = favorecido.Susep__c;
			req.valorremuneracao = String.valueOf(premioRecupera);
			
			//PLV-4601-FIX3 - INICIO
			if(geraExtrato == true){
				String respExtRem = HerokuService.getInstance().startHerokuExtratoRemuneracaoCancelamento(req);
				System.debug( ' @  resp ext rem => ' + respExtRem );
			}
			//PLV-4601-FIX3 - FIM
		}
		return premioRecuperaTotal; //PLV-4601-FIX3 - INICIO/FIM
	}
	//PLV-4450 - FIM

	//PLV-4678 - Inicio
	private static string preencherValorTotalPremio(String numeroOrcamento){
		String valorPremio = '';
		
		List<Opportunity> ltOppOrcamento = [SELECT 	Id, Numero__c, NumeroOferta__c, PremioTotal__c 
											FROM 	Opportunity 
											WHERE 	Numero__c LIKE: '%' + numeroOrcamento];
		if(!ltOppOrcamento.isEmpty()){
			valorPremio = String.valueOf(ltOppOrcamento[0].PremioTotal__c.setScale(2));
		}

		return valorPremio;
	}

	@TestVisible//FCVEP-29 - INICIO
    private static Date validarDataInicialVigencia(Id contractId, Date dataCancelar) {
        
        Date returnedDate = dataCancelar;
        List<Contract> ltContrato = new List<Contract>();
        ParcelamentoContratoTO parcCtrTO = new ParcelamentoContratoTO();
        String idExterno = '';

        ltContrato = [SELECT VigenciaFinal__c, StartDate FROM Contract WHERE Id = :contractId];

            try{
                if (ltContrato.isEmpty()){
                    throw new BotaoCancelarException('Contrato não encontrado.');
                }

                Contract contratoVerificar = ltContrato[0];
                if (contratoVerificar.StartDate != null && contratoVerificar.VigenciaFinal__c != null) {
                    if (dataCancelar >= contratoVerificar.StartDate && dataCancelar <= contratoVerificar.VigenciaFinal__c) {
                        returnedDate = dataCancelar;
                    } else {
                        List<ContratanteContrato__c> cttsCtr = ContratanteContratoDAO.getInstance().obterContratCtr(contractId);
                        idExterno = contractId + '_' + cttsCtr[0].Id;

                        try {
                            if(!Test.isRunningTest()){
                                parcCtrTO = HerokuService.getInstance().consultarParcelasContrato(idExterno);                           
                                returnedDate = retonarDataParcInadim(parcCtrTO);
                            }
                        } catch (Exception e) {
                            returnedDate = retornarParcContrExtHerokuExcp(idExterno);
                        }                   
                    }
                }
            }catch (BotaoCancelarException bce){
                returnedDate = retornarParcContrExtHerokuExcp(idExterno);
            }
        return returnedDate;
    }

    public static Date retornarParcContrExtHerokuExcp(String idExterno) {
        Date dataParcInadim = System.today();
        
        List<public_parcelacontrato__x> parcelas = ContratanteContratoDAO.getInstance().obterParcCtr(idExterno);
        
        if (Test.isRunningTest()) {
            public_parcelacontrato__x parcelaPendente = new public_parcelacontrato__x(status__c = 'PENDENTE', datavencimento__c = System.today());
            public_parcelacontrato__x parcelaInadimplente = new public_parcelacontrato__x(status__c = 'INADIMPLENTE', datavencimento__c = System.today().addDays(1));
            
            parcelas.add(parcelaPendente);
            parcelas.add(parcelaInadimplente); 
        }
        
        for (public_parcelacontrato__x parcela : parcelas) {
            if (parcela.status__c == 'INADIMPLENTE') {
                dataParcInadim = parcela.datavencimento__c;
                break;
            }
        }
        
        return dataParcInadim;
    }

	public static Date retonarDataParcInadim(ParcelamentoContratoTO parcCtrTO) {

        Date dataParcInadim = System.today();
        
        for (ParcelamentoContratoTO.DataTO parcela : parcCtrTO.data) {
            if (parcela.status == 'INADIMPLENTE') {
                dataParcInadim = Date.valueOf(parcela.datavencimento);
                break;
            }
        }        
        return dataParcInadim;
    }
	//FCVEP-29 - FIM
	//PLV-4678 - Fim
	
	// PLV-4606-INICIO
	public static void populaEmissaoTO(EmissaoTO.PayloadTO payloadTO, Integer numeroOrcamento, Id idContrato, Date dataCancelamento) {
		Opportunity orcamento = OpportunityDAO.getInstance().obterOportunidadesPorNumero(String.valueOf(numeroOrcamento).leftPad(8,'0'));
		system.debug('teste segmento ' + orcamento.segmento__c);
		if (orcamento.segmento__c == 'Individual') {
			populaEmissaoTOVI(payloadTO, numeroOrcamento, idContrato, dataCancelamento, orcamento);
		} else if (orcamento.segmento__c == 'Viagem') {
			populaEmissaoTOViagem(payloadTO, numeroOrcamento, idContrato, dataCancelamento, orcamento);
		}
	}

	public static void populaEmissaoTOViagem(EmissaoTO.PayloadTO payloadTO, Integer numeroOrcamento, Id idContrato, Date dataCancelamento, Opportunity orcamento){
		payloadTO.propostas = new List<EmissaoTO.PayloadTO>();
		EmissaoTO.PayloadTO payloadtoProposta = new EmissaoTO.PayloadTO();
		payloadtoProposta.proposta = new EmissaoTO();
		
		// -------------------------------------------- Montagem Payload EmissaoTO.PayloadTO -------------------------------------------
		payloadtoProposta.proposta.meioComercializacao = orcamento.MeioComercializacao__c;
		payloadtoProposta.proposta.canalDistribuicao = orcamento.CanalDistribuicao__r.Sigla__c;
		payloadtoProposta.proposta.dataCalculo = dataCancelamento != null ? String.valueOf(dataCancelamento) : null;
		payloadtoProposta.proposta.tipoEndosso = orcamento.TipoEndosso__c;
			
		// ------------------------------------------------------------------------------------------------------------------ RemuneracaoTO
		List<EmissaoTO.RemuneracaoTO> remuneracoesTO = new List<EmissaoTO.RemuneracaoTO>();
		for(RemuneracaoOrcamento__c rem : orcamento.RemuneracoesOrcamento__r){
			EmissaoTO.RemuneracaoTO remuneracaoTO = new EmissaoTO.RemuneracaoTO();
			remuneracaoTO.agentes = new List<EmissaoTO.AgenteTO>();
			EmissaoTO.AgenteTO agenteTO = new EmissaoTO.AgenteTO();
			agenteTO.susepBloqueios = new EmissaoTO.SusepBloqueioTO();
			agenteTO.susepBloqueios.bloqueios = new List<EmissaoTO.BloqueioTO>();
			EmissaoTO.BloqueioTO bloqueioTO = new EmissaoTO.BloqueioTO();
			bloqueioTO.bloqueioProducao = '';
			bloqueioTO.bloqueioComissoes = '';
			bloqueioTO.bloqueioFenacor = '';
			bloqueioTO.bloqueioInativos = '';
			bloqueioTO.susepPorto = '';
			bloqueioTO.status = '';
			agenteTO.susepBloqueios.bloqueios.add(bloqueioTO);
			remuneracaoTO.agentes.add(agenteTO);
		}
		payloadtoProposta.proposta.remuneracoes = remuneracoesTO;
		
		// ------------------------------------------------------------------------------------------------------------------ ContratanteTO
		List<EmissaoTO.ContratanteTO> contratantesTO = new List<EmissaoTO.ContratanteTO>();
		for(ContratanteOrcamento__c con : orcamento.ContratantesOrcamento__r){
			EmissaoTO.ContratanteTO contratanteTO = new EmissaoTO.ContratanteTO();
			contratanteTO.tipo = 'PRI';
			contratanteTO.numero = con.Numero__c != null ? String.valueOf(con.Numero__c) : null;
			
			// --------------------------------------------------------------- PessoaTO
			contratanteTO.pessoa = new EmissaoTO.PessoaTO();
			contratanteTO.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
			contratanteTO.pessoa.dadosPessoaFisica.serasa = new EmissaoTO.SerasaViagemTO();
			contratanteTO.pessoa.dadosPessoaFisica.serasa.dadosCadastrais = new EmissaoTO.DadosCadastraisTO();
			contratanteTO.pessoa.dadosPessoaFisica.serasa.dadosCadastrais.numeroCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(0, 11) : '';
			contratanteTO.pessoa.dadosPessoaFisica.serasa.dadosCadastrais.nome = con.Conta__r.Name;
			contratanteTO.pessoa.dadosPessoaFisica.serasa.dadosCadastrais.dataNascimento = con.Conta__r.PersonBirthdate != null ? String.valueOf(con.Conta__r.PersonBirthdate) : null;
			contratanteTO.pessoa.dadosPessoaFisica.serasa.dadosCadastrais.digitoCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(12, 14) : '';

			contratanteTO.pessoa.dadosPessoaFisica.serasa.score = new EmissaoTO.ScoreViagemTO();
			contratanteTO.pessoa.dadosPessoaFisica.serasa.score.scores = new EmissaoTO.ScoresTO();
			contratanteTO.pessoa.dadosPessoaFisica.serasa.score.faixa = '';
			contratanteTO.pessoa.dadosPessoaFisica.serasa.score.taxa = '';
			contratanteTO.pessoa.dadosPessoaFisica.serasa.score.mensagem = '';

			contratantesTO.add(contratanteTO);
		}
		payloadtoProposta.proposta.contratantes = contratantesTO;
		// --------------------------------------------------------------------------------------------------------------- FIM ContratanteTO

		Set<Id> ids = new Set<Id>();
		ids.add(idContrato);
		List<Contract> contratos = ContractDao.getInstance().buscarContratos(ids);
		Contract contrato = contratos[0];

		payloadtoProposta.proposta.origem = contrato.Proposta__r.Origem__c != null ? Integer.valueOf(contrato.Proposta__r.Origem__c) : null;
		payloadtoProposta.proposta.tipoSeguro = orcamento.Type;
		payloadtoProposta.proposta.numeroOrcamento = orcamento.Numero__c;

		payloadtoProposta.calculo = new EmissaoTO.CalculoTO();
		payloadtoProposta.calculo.precificacao = new EmissaoTO.PrecificacaoTO();
		payloadtoProposta.calculo.precificacao.premio = new EmissaoTO.PremioTO();
		payloadtoProposta.calculo.precificacao.premio.total = orcamento.PremioTotal__c;
		
				
		payloadtoProposta.calculo.precificacao.descontoAgravo = new List<EmissaoTO.DescontoAgravoTO>();
		EmissaoTO.DescontoagravoTO descontoAgravoTO = new EmissaoTO.DescontoagravoTO();
		descontoAgravoTO.percentual = contrato.DescontoAgravoPercentualFormaPagto__c;
		descontoAgravoTO.monetario = contrato.DescontoAgravoMonetarioFormaPagto__c;
		descontoAgravoTO.tipo = 'FPG';
		payloadtoProposta.calculo.precificacao.descontoAgravo.add(descontoAgravoTO);

		// payloadtoProposta.decisionid = 'string';
		
		payloadTO.propostas.add(payloadtoProposta);
		System.debug('karin viagem');
		System.debug(JSON.serialize(payloadTO, true));
	}


	static Map<String, String> mapProfissaoGrupoRiscoProfissao = new Map<String, String>();
	public static void populaEmissaoTOVI(EmissaoTO.PayloadTO payloadTO, Integer numeroOrcamento, Id idContrato, Date dataCancelamento, Opportunity orcamento){
		payloadTO.propostas = new List<EmissaoTO.PayloadTO>();
		EmissaoTO.PayloadTO payloadtoProposta = new EmissaoTO.PayloadTO();
		payloadtoProposta.proposta = new EmissaoTO();
		// ---------------------------------------- SOQLs -----------------------------------------
		String segmento = orcamento.Segmento__c;
		Map<String, Endereco__c> mapContratanteEndereco = new Map<String, Endereco__c>();
		
		Set<Id> listAccountIdContratante = new Set<Id>();
		Set<Id> listIdContratante = new Set<Id>();
		Set<Id> listIdProfissao = new Set<Id>();
		for(ContratanteOrcamento__c con : orcamento.ContratantesOrcamento__r){
			listIdContratante.add(con.Id);
			listAccountIdContratante.add(con.Conta__c);
			mapContratanteEndereco.put(con.Id + 'Comercial', new Endereco__c());
			mapContratanteEndereco.put(con.Id + 'Residencial', new Endereco__c());
		}
		for(Account conta : [SELECT Id, Profissao__c FROM Account WHERE Id IN: listAccountIdContratante]){
			listIdProfissao.add(conta.Profissao__c);
		}
		//RVI-175 - INICIO
		/*for(GrupoProfissoes__c grupoProf : [SELECT Id, Profissao__c, GrupoRisco__r.Name FROM GrupoProfissoes__c WHERE Profissao__c IN: listIdProfissao]){
			mapProfissaoGrupoRiscoProfissao.put(grupoProf.Profissao__c, grupoProf.GrupoRisco__r.Name);
		}*/
		for(SeguradoContrato__c grupoProf : [SELECT id, Profissao__c,  GrupoRisco__c FROM SeguradoContrato__c WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: idContrato]){
			mapProfissaoGrupoRiscoProfissao.put(grupoProf.Profissao__c, grupoProf.GrupoRisco__c);
			System.debug('mapProfissaoGrupoRiscoProfissao>>>> :' + mapProfissaoGrupoRiscoProfissao);
		}
		//RVI-175 - FIM
		
		for(Endereco__c endContratante : [SELECT Id, Estado__c, Cidade__c, Complemento__c, Numero__c,
										Logradouro__c, Bairro__c, Cep__c, TipoEndereco__c , Conta__c
										FROM Endereco__c 
										WHERE Conta__c IN: listAccountIdContratante AND MaisAtual__c = true 
										ORDER BY CreatedDate DESC]){
			if(mapContratanteEndereco.get(endContratante.Conta__c + 'Comercial') == null && endContratante.TipoEndereco__c == 'Comercial'){
				mapContratanteEndereco.put(endContratante.Conta__c + 'Comercial', endContratante);
			}
			if(mapContratanteEndereco.get(endContratante.Conta__c + 'Residencial') == null && endContratante.TipoEndereco__c == 'Residencial'){
				mapContratanteEndereco.put(endContratante.Conta__c + 'Residencial', endContratante);
			}

		}
		
		List<GrupoOrcamento__c> listGrupoOrcamento = GrupoOrcamentoDAO.getInstance().listarGrupoOrcamento(listIdContratante);
		Set<Id> listIdSeguradoOrcamento = new Set<Id>();
		Map<String, List<GarantiaSeguradoOrcamento__c>> mapGrupoSeguradoGarantia = new Map<String, List<GarantiaSeguradoOrcamento__c>>();
		for(GrupoOrcamento__c grupo : listGrupoOrcamento){
			for(SeguradoOrcamento__c segurado : grupo.SeguradosOrcamento__r){
				listIdSeguradoOrcamento.add(segurado.Id);
				mapGrupoSeguradoGarantia.put(segurado.Id, new List<GarantiaSeguradoOrcamento__c>());
			}
		}

		for(GarantiaSeguradoOrcamento__c garantia : [SELECT Id, SeguradoOrcamento__c, Garantia__r.Sigla__c, Valor__c, Quantidade__c FROM GarantiaSeguradoOrcamento__c WHERE SeguradoOrcamento__c IN: listIdSeguradoOrcamento]){
			List<GarantiaSeguradoOrcamento__c> listGarantia = mapGrupoSeguradoGarantia.get(garantia.SeguradoOrcamento__c);
			listGarantia.add(garantia);
			mapGrupoSeguradoGarantia.put(garantia.SeguradoOrcamento__c, listGarantia);
		}


		system.debug('Teste ProductCode');
		
		// -------------------------------------------- Montagem Payload EmissaoTO.PayloadTO -------------------------------------------
		payloadtoProposta.proposta.meioComercializacao = orcamento.MeioComercializacao__c;
		payloadtoProposta.proposta.canalDistribuicao = orcamento.CanalDistribuicao__r.Sigla__c;
		payloadtoProposta.proposta.dataProtocolo = dataCancelamento != null ? String.valueOf(dataCancelamento) : null;
		payloadtoProposta.proposta.dependentesFinanceiros = orcamento.Dependentes__c != null && orcamento.Dependentes__c != '' ? true : false;
		payloadtoProposta.proposta.numeroOrcamento = orcamento.Numero__c;
		payloadtoProposta.proposta.tipoSeguro = orcamento.Type;
		payloadtoProposta.proposta.numeroPortal = orcamento.NumeroPortal__c;
		payloadtoProposta.proposta.codigoProdutoVida = orcamento.Produto__r.ProductCode;
		payloadtoProposta.proposta.segmento = orcamento.Segmento__c;
		payloadtoProposta.proposta.tempoRendaProtegida = orcamento.PorQuantoTempoQuerGarantirRenda__c;
		payloadtoProposta.proposta.entradaNegocio = orcamento.EntradaNegocio__c;
		payloadtoProposta.proposta.tipoEndosso = orcamento.TipoEndosso__c;
		payloadtoProposta.calculo = new EmissaoTO.CalculoTO();
		payloadtoProposta.calculo.precificacao = new EmissaoTO.PrecificacaoTO();
		payloadtoProposta.calculo.precificacao.premio = new EmissaoTO.PremioTO();
		payloadtoProposta.calculo.precificacao.premio.total = orcamento.PremioTotal__c;


		
			
		// ------------------------------------------------------------------------------------------------------------------ RemuneracaoTO
		List<EmissaoTO.RemuneracaoTO> remuneracoesTO = new List<EmissaoTO.RemuneracaoTO>();
		for(RemuneracaoOrcamento__c rem : orcamento.RemuneracoesOrcamento__r){
			EmissaoTO.RemuneracaoTO remuneracaoTO = new EmissaoTO.RemuneracaoTO();
			remuneracaoTO.percentual = rem.Percentual__c;
			remuneracaoTO.tipoRemuneracao = rem.TipoRemuneracao__r.Codigo__c;
			remuneracoesTO.add(remuneracaoTO);
		}
		payloadtoProposta.proposta.remuneracoes = remuneracoesTO;
		
		// ------------------------------------------------------------------------------------------------------------------ ContratanteTO
		List<EmissaoTO.ContratanteTO> contratantesTO = new List<EmissaoTO.ContratanteTO>();
		for(ContratanteOrcamento__c con : orcamento.ContratantesOrcamento__r){
			EmissaoTO.ContratanteTO contratanteTO = new EmissaoTO.ContratanteTO();
			contratanteTO.tipo = 'PRI';//con.Tipo__c;
			contratanteTO.numero = con.Numero__c != null ? String.valueOf(con.Numero__c) : null;
			// --------------------------------------------------------------- PessoaTO
			Endereco__c endComercial = mapContratanteEndereco.get(con.Conta__c + 'Comercial');
			Endereco__c endResidencial = mapContratanteEndereco.get(con.Conta__c + 'Residencial');
			contratanteTO.pessoa = montarPessoaTO(con, endComercial, endResidencial);
			// --------------------------------------------------------------------------------------------------------------- GrupoTO
			List<EmissaoTO.GrupoTO> gruposTO = new List<EmissaoTO.GrupoTO>();
			EmissaoTO.GrupoTO grupoTO = new EmissaoTO.GrupoTO();
			for(GrupoOrcamento__c grupo : listGrupoOrcamento){
				grupoTO.numero = grupo.Numero__c != null ? String.valueOf(grupo.Numero__c) : null;
				grupoTO.nome = grupo.Name;
				grupoTO.qtdeVidas = grupo.QuantidadeVidas__c;
				
				List<EmissaoTO.SeguradoTO> seguradosTO = new List<EmissaoTO.SeguradoTO>();
				for(SeguradoOrcamento__c segurado : grupo.SeguradosOrcamento__r){
					EmissaoTO.SeguradoTO seguradoTO = new EmissaoTO.SeguradoTO();
					seguradoTO.ocupacaoProfissionalPrincipal = segurado.Profissao__r.CodigoProfissao__c;
					seguradoTO.limiteProfissao = segurado.Profissao__r.Limite_de_capital_maximo__c;
					seguradoTO.faixaRenda = segurado.FaixaRenda__c;
					seguradoTO.numero = segurado.Numero__c != null ? String.valueOf(segurado.Numero__c) : null;
					seguradoTO.formaTrabalho = segurado.RegimeTrabalho__c;
					
					seguradoTO.pessoa = montarPessoaTO(segurado, endComercial, endResidencial);

					List<EmissaoTO.CoberturaTO> coberturasTO = new List<EmissaoTO.CoberturaTO>();
					for(GarantiaSeguradoOrcamento__c garantia : mapGrupoSeguradoGarantia.get(segurado.Id)){
						EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
						coberturaTO.valor = garantia.Valor__c == null ? 0 : garantia.Valor__c;
						coberturaTO.sigla = garantia.Garantia__r.Sigla__c;
						coberturaTO.quantidade = String.valueOf(garantia.Quantidade__c) == null ? '0' : String.valueOf(garantia.Quantidade__c);
						coberturasTO.add(coberturaTO);
					}

					seguradoTO.coberturas = coberturasTO;

					// ------------------------------------------------------ QuestionarioTO
					seguradoTO.questionario = new EmissaoTO.QuestionarioTO();
					//seguradoTO.questionario.idQuestionario = null;
					seguradoTO.questionario.idquestionario = null; //RVI-138 INICIO-FIM FIX01
					seguradoTO.questionario.respostas = new List<EmissaoTO.RespostaTO>();

					seguradosTO.add(seguradoTO);
				}
				
				grupoTO.segurados = seguradosTO;
				gruposTO.add(grupoTO);
			}

			
			contratanteTO.grupos = gruposTO;
			contratantesTO.add(contratanteTO);
		}
		payloadtoProposta.proposta.contratantes = contratantesTO;
		// --------------------------------------------------------------------------------------------------------------- FIM ContratanteTO

		// -------------------------------------------------------------------------------------------------------------------- ContratoOriginal
		payloadtoProposta.proposta.contratoOriginal = new EmissaoTO();
		montarContratoOriginal(idContrato, payloadtoProposta.proposta.contratoOriginal, payloadtoProposta);

		// -------------------------------------------------------------------------------------------------------------------- FIM ContratoOriginal
		payloadtoProposta.resultadosIntegracoes = new EmissaoTO.ResultadosIntegracoesTO();
		

		payloadTO.propostas.add(payloadtoProposta);
		System.debug('karin vi');
		System.debug(JSON.serialize(payloadTO, true));
	}


	public static EmissaoTO.PessoaTO montarPessoaTO(SeguradoOrcamento__c con, Endereco__c endComercial, Endereco__c endResidencial){
		EmissaoTO.PessoaTO pessoaTO = new EmissaoTO.PessoaTO();
			pessoaTO.melhorPeriodo = con.Conta__r.MelhorPeriodoContato__c; // ?
			pessoaTO.pessoaExpostaPoliticamente = con.Conta__r.Pep__c;
			pessoaTO.tipo = con.Conta__r.Type;
			pessoaTO.rendaMensal = con.Conta__r.Renda__c;
			pessoaTO.nome = con.Conta__r.Name;
			pessoaTO.nomeSocial = con.Conta__r.NomeSocial__c; // LECVPV-188(CANCELAMENTO) INICIO/FIM
			pessoaTO.email = con.Conta__r.PersonEmail;
			
			// -------------------------------------------------------------------------------------------------------------- DadosPessoaFisicaTO
			EmissaoTO.DadosPessoaFisicaTO dadospessoafisicaTO = new EmissaoTO.DadosPessoaFisicaTO();

			dadospessoafisicaTO.grupoProfissao = mapProfissaoGrupoRiscoProfissao.get(con.Conta__r.Profissao__c) != null ? mapProfissaoGrupoRiscoProfissao.get(con.Conta__r.Profissao__c) : '';
			dadospessoafisicaTO.paisResidente = con.Conta__r.PaisResidencia__c;
			dadospessoafisicaTO.profissao = con.Profissao__r.Codigo__c;
			dadospessoafisicaTO.orgaoExpedidor = con.Conta__r.OrgaoExpedidor__c;
			
			if(con.Conta__r.EstadoCivil__c == 'Solteiro (a)')
				dadospessoafisicaTO.estadoCivil = 'SOLTEIRO';
			if(con.Conta__r.EstadoCivil__c == 'Divorciado(a)')
				dadospessoafisicaTO.estadoCivil = 'DIVORCIADO';
			if(con.Conta__r.EstadoCivil__c == 'Viúvo(a)')
				dadospessoafisicaTO.estadoCivil = 'VIUVO';
			if(con.Conta__r.EstadoCivil__c == 'Desquitado(a)')
				dadospessoafisicaTO.estadoCivil = 'DESQUITADO';
			if(con.Conta__r.EstadoCivil__c == 'Casado (a)')
				dadospessoafisicaTO.estadoCivil = 'CASADO';
			if(con.Conta__r.EstadoCivil__c == 'Vive maritalmente')
				dadospessoafisicaTO.estadoCivil = 'VIVEMARITALMENTE';
				
			dadospessoafisicaTO.docIdentificacao = con.Conta__r.DocIndentificacao__c;
			dadospessoafisicaTO.resideBrasil = con.Conta__r.ResideBrasil__c;
			dadospessoafisicaTO.fumante = con.Conta__r.Fumante__c != null ?  Boolean.valueOf(con.Conta__r.Fumante__c) : null;
			dadospessoafisicaTO.digitoCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(12, 14) : '';
			dadospessoafisicaTO.numeroCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(0, 11) : '';
			dadospessoafisicaTO.dataExpedicao = con.Conta__r.DataExpedicao__c;
			dadospessoafisicaTO.idade = con.Conta__r.Idade__c != null ?  Integer.ValueOf(con.Conta__r.Idade__c) : null;
			// dadospessoafisicaTO.tipoDocIdentificacao = con.Conta__r.TipoDocidentificacao__c; // PLV-4606-FIX
			dadospessoafisicaTO.sexo = con.Conta__r.Sexo__c;
			dadospessoafisicaTO.dataNascimento = con.Conta__r.PersonBirthdate != null ? String.valueOf(con.Conta__r.PersonBirthdate) : null;
			dadospessoafisicaTO.nacionalidade = con.Conta__r.Nacionalidade__c;
			dadospessoafisicaTO.regimeTrabalho = con.Conta__r.RegimeTrabalho__c;
			pessoaTO.dadosPessoaFisica = dadosPessoaFisicaTO;

			// ----------------------------------------------------------------------------------------------------------------- EnderecoTO
			List<EmissaoTO.EnderecoTO> enderecosTO = new List<EmissaoTO.EnderecoTO>();
			
			if(endComercial != null){
				EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
				enderecoTO.uf = endComercial.Estado__c;
				enderecoTO.cidade = endComercial.Cidade__c;
				enderecoTO.complemento = endComercial.Complemento__c != null ? endComercial.Complemento__c : '';
				enderecoTO.logradouro = endComercial.Logradouro__c;
				enderecoTO.bairro = endComercial.Bairro__c;
				enderecoTO.complementoCep = endComercial.Cep__c != null ? endComercial.Cep__c.subString(5,8) : null; 
				enderecoTO.tipoEndereco = endComercial.TipoEndereco__c != null ? endComercial.TipoEndereco__c.toUpperCase() : null; 
				enderecoTO.numeroLogradouro = endComercial.Numero__c;
				enderecoTO.cep = endComercial.Cep__c != null ? endComercial.Cep__c.subString(0,5) : null; 
				enderecosTO.add(enderecoTO);
			}
			if(endResidencial != null){
				EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
				enderecoTO.uf = endResidencial.Estado__c;
				enderecoTO.cidade = endResidencial.Cidade__c;
				enderecoTO.complemento = endResidencial.Complemento__c != null ? endResidencial.Complemento__c : '';
				enderecoTO.logradouro = endResidencial.Logradouro__c;
				enderecoTO.bairro = endResidencial.Bairro__c;
				enderecoTO.complementoCep = endResidencial.Cep__c != null ? endResidencial.Cep__c.subString(5,8) : null; 
				enderecoTO.tipoEndereco = endResidencial.TipoEndereco__c != null ? endResidencial.TipoEndereco__c.toUpperCase() : null; 
				enderecoTO.numeroLogradouro = endResidencial.Numero__c;
				enderecoTO.cep = endResidencial.Cep__c != null ? endResidencial.Cep__c.subString(0,5) : null; 
				enderecosTO.add(enderecoTO);
			}
			pessoaTO.enderecos = enderecosTO;
			// ------------------------------------------------------------------------------------------------------------------------ TelefonesTO
			List<EmissaoTO.TelefoneTO> telefonesTO = new List<EmissaoTO.TelefoneTO>();
			
			EmissaoTO.TelefoneTO telefoneTO1 = new EmissaoTO.TelefoneTO();
			telefoneTO1.tipoTelefone = 'CEL';
			if (con.Conta__r.PersonMobilePhone != null && con.Conta__r.PersonMobilePhone != '') {
				telefoneTO1.numeroTelefone = con.Conta__r.PersonMobilePhone.subString(5, con.Conta__r.PersonMobilePhone.length()).replace('-', '');
				telefoneTO1.dddTelefone = con.Conta__r.PersonMobilePhone.subString(1,3);
			}
			EmissaoTO.TelefoneTO telefoneTO2 = new EmissaoTO.TelefoneTO();
			telefoneTO2.tipoTelefone = 'RES';
			if (con.Conta__r.PersonHomePhone != null && con.Conta__r.PersonHomePhone != '') {
				telefoneTO2.numeroTelefone = con.Conta__r.PersonHomePhone.subString(5, con.Conta__r.PersonHomePhone.length()).replace('-', '');
				telefoneTO2.dddTelefone = con.Conta__r.PersonHomePhone.subString(1,3);
			}
			EmissaoTO.TelefoneTO telefoneTO3 = new EmissaoTO.TelefoneTO();
			telefoneTO3.tipoTelefone = 'PES';
			if (con.Conta__r.Phone != null && con.Conta__r.Phone != '') {
				telefoneTO3.numeroTelefone = con.Conta__r.Phone.subString(5, con.Conta__r.Phone.length()).replace('-', ''); //PLV-5129 inicio/fim
				telefoneTO3.dddTelefone = con.Conta__r.Phone.subString(1,3);
			}
			telefonesTO.add(telefoneTO1);
			telefonesTO.add(telefoneTO2);
			telefonesTO.add(telefoneTO3);
			pessoaTO.telefones = telefonesTO;
			return pessoaTO;
	}

	public static EmissaoTO.PessoaTO montarPessoaTO(ContratanteOrcamento__c con, Endereco__c endComercial, Endereco__c endResidencial){
		EmissaoTO.PessoaTO pessoaTO = new EmissaoTO.PessoaTO();
			pessoaTO.melhorPeriodo = con.Conta__r.MelhorPeriodoContato__c; // ?
			pessoaTO.pessoaExpostaPoliticamente = con.Conta__r.Pep__c;
			pessoaTO.tipo = con.Conta__r.Type;
			pessoaTO.rendaMensal = con.Conta__r.Renda__c;
			pessoaTO.nome = con.Conta__r.Name;
			pessoaTO.nomeSocial = con.Conta__r.NomeSocial__c; // LECVPV-188(CANCELAMENTO) INICIO/FIM
			pessoaTO.email = con.Conta__r.PersonEmail;
			
			// -------------------------------------------------------------------------------------------------------------- DadosPessoaFisicaTO
			EmissaoTO.DadosPessoaFisicaTO dadospessoafisicaTO = new EmissaoTO.DadosPessoaFisicaTO();

			dadospessoafisicaTO.grupoProfissao = mapProfissaoGrupoRiscoProfissao.get(con.Conta__r.Profissao__c) != null ? mapProfissaoGrupoRiscoProfissao.get(con.Conta__r.Profissao__c) : '';
			dadospessoafisicaTO.paisResidente = con.Conta__r.PaisResidencia__c;
			dadospessoafisicaTO.profissao = con.Conta__r.Profissao__r.Codigo__c;
			dadospessoafisicaTO.orgaoExpedidor = con.Conta__r.OrgaoExpedidor__c;

			if(con.Conta__r.EstadoCivil__c == 'Solteiro (a)')
				dadospessoafisicaTO.estadoCivil = 'SOLTEIRO';
			if(con.Conta__r.EstadoCivil__c == 'Divorciado(a)')
				dadospessoafisicaTO.estadoCivil = 'DIVORCIADO';
			if(con.Conta__r.EstadoCivil__c == 'Viúvo(a)')
				dadospessoafisicaTO.estadoCivil = 'VIUVO';
			if(con.Conta__r.EstadoCivil__c == 'Desquitado(a)')
				dadospessoafisicaTO.estadoCivil = 'DESQUITADO';
			if(con.Conta__r.EstadoCivil__c == 'Casado (a)')
				dadospessoafisicaTO.estadoCivil = 'CASADO';
			if(con.Conta__r.EstadoCivil__c == 'Vive maritalmente')
				dadospessoafisicaTO.estadoCivil = 'VIVEMARITALMENTE';
			
			system.debug('teste segurado');
			system.debug(JSON.serialize(con, true));
			dadospessoafisicaTO.docIdentificacao = con.Conta__r.DocIndentificacao__c;
			dadospessoafisicaTO.resideBrasil = con.Conta__r.ResideBrasil__c;
			dadospessoafisicaTO.fumante = con.Conta__r.Fumante__c != null ? Boolean.valueOf(con.Conta__r.Fumante__c) : null;
			dadospessoafisicaTO.digitoCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(12, 14) : '';
			dadospessoafisicaTO.numeroCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(0, 11) : '';
			dadospessoafisicaTO.dataExpedicao = con.Conta__r.DataExpedicao__c;
			dadospessoafisicaTO.idade = con.Conta__r.Idade__c != null ? Integer.ValueOf(con.Conta__r.Idade__c) : null;
			// // dadospessoafisicaTO.tipoDocIdentificacao = con.Conta__r.TipoDocidentificacao__c; // PLV-4606-FIX
			dadospessoafisicaTO.sexo = con.Conta__r.Sexo__c;
			dadospessoafisicaTO.dataNascimento = con.Conta__r.PersonBirthdate != null ? String.valueOf(con.Conta__r.PersonBirthdate) : null;
			dadospessoafisicaTO.nacionalidade = con.Conta__r.Nacionalidade__c;
			dadospessoafisicaTO.regimeTrabalho = con.Conta__r.RegimeTrabalho__c;
			pessoaTO.dadosPessoaFisica = dadosPessoaFisicaTO;

			// ----------------------------------------------------------------------------------------------------------------- EnderecoTO
			List<EmissaoTO.EnderecoTO> enderecosTO = new List<EmissaoTO.EnderecoTO>();
			
			if(endComercial != null){
				EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
				enderecoTO.uf = endComercial.Estado__c;
				enderecoTO.cidade = endComercial.Cidade__c;
				enderecoTO.complemento = endComercial.Complemento__c != null ? endComercial.Complemento__c : '';
				enderecoTO.logradouro = endComercial.Logradouro__c;
				enderecoTO.bairro = endComercial.Bairro__c;
				enderecoTO.complementoCep = endComercial.Cep__c != null ? endComercial.Cep__c.subString(5,8) : null;
				enderecoTO.tipoEndereco = endComercial.TipoEndereco__c != null ? endComercial.TipoEndereco__c.toUpperCase() : null;
				enderecoTO.numeroLogradouro = endComercial.Numero__c;
				enderecoTO.cep = endComercial.Cep__c != null ? endComercial.Cep__c.subString(0,5) : null;
				enderecosTO.add(enderecoTO);
			}
			if(endResidencial != null){
				EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
				enderecoTO.uf = endResidencial.Estado__c;
				enderecoTO.cidade = endResidencial.Cidade__c;
				enderecoTO.complemento = endResidencial.Complemento__c != null ? endResidencial.Complemento__c : '';
				enderecoTO.logradouro = endResidencial.Logradouro__c;
				enderecoTO.bairro = endResidencial.Bairro__c;
				enderecoTO.complementoCep = endResidencial.Cep__c != null ? endResidencial.Cep__c.subString(5,8) : null;
				enderecoTO.tipoEndereco = endResidencial.TipoEndereco__c != null ? endResidencial.TipoEndereco__c.toUpperCase() : null;
				enderecoTO.numeroLogradouro = endResidencial.Numero__c;
				enderecoTO.cep = endResidencial.Cep__c != null ? endResidencial.Cep__c.subString(0,5) : null;
				enderecosTO.add(enderecoTO);
			}
			pessoaTO.enderecos = enderecosTO;
			// ------------------------------------------------------------------------------------------------------------------------ TelefonesTO
			List<EmissaoTO.TelefoneTO> telefonesTO = new List<EmissaoTO.TelefoneTO>();
			
			EmissaoTO.TelefoneTO telefoneTO1 = new EmissaoTO.TelefoneTO();
			telefoneTO1.tipoTelefone = 'CEL';
			if (con.Conta__r.PersonMobilePhone != null && con.Conta__r.PersonMobilePhone != '') {
				telefoneTO1.numeroTelefone = con.Conta__r.PersonMobilePhone.subString(5, con.Conta__r.PersonMobilePhone.length()).replace('-', '');
				telefoneTO1.dddTelefone = con.Conta__r.PersonMobilePhone.subString(1,3);
			}
			EmissaoTO.TelefoneTO telefoneTO2 = new EmissaoTO.TelefoneTO();
			telefoneTO2.tipoTelefone = 'RES';
			if (con.Conta__r.PersonHomePhone != null && con.Conta__r.PersonHomePhone != '') {
				telefoneTO2.numeroTelefone = con.Conta__r.PersonHomePhone.subString(5, con.Conta__r.PersonHomePhone.length()).replace('-', '');
				telefoneTO2.dddTelefone = con.Conta__r.PersonHomePhone.subString(1,3);
			}
			EmissaoTO.TelefoneTO telefoneTO3 = new EmissaoTO.TelefoneTO();
			telefoneTO3.tipoTelefone = 'PES';
			if (con.Conta__r.Phone != null && con.Conta__r.Phone != '') {
				System.debug('con.Conta__r.Phone> ' + con.Conta__r.Phone);
				System.debug('con.Conta__r.PersonHomePhone> ' + con.Conta__r.PersonHomePhone);
				System.debug('telefoneTO1>> ' + telefoneTO1);
				System.debug('telefoneTO2>> ' + telefoneTO2);
				System.debug('telefoneTO3>> ' + telefoneTO3);
				// PLV-5129 - FIX01 - Inicio
				telefoneTO3.numeroTelefone = con.Conta__r.Phone.subString(5, con.Conta__r.Phone.length()).replace('-', '');
				//telefoneTO3.numeroTelefone = '993067953';
				telefoneTO3.dddTelefone = con.Conta__r.Phone.subString(1,3);
				//telefoneTO3.dddTelefone = '31';
				// PLV-5129 - FIX01 - Fim
			}
			
			telefonesTO.add(telefoneTO1);
			telefonesTO.add(telefoneTO2);
			telefonesTO.add(telefoneTO3);
			pessoaTO.telefones = telefonesTO;
			return pessoaTO;
	}

	public static EmissaoTO.PessoaTO montarPessoaTO(SeguradoContrato__c con, Endereco__c endComercial, Endereco__c endResidencial){
		EmissaoTO.PessoaTO pessoaTO = new EmissaoTO.PessoaTO();
			pessoaTO.melhorPeriodo = con.Conta__r.MelhorPeriodoContato__c; // ?
			pessoaTO.pessoaExpostaPoliticamente = con.Conta__r.Pep__c;
			pessoaTO.tipo = con.Conta__r.Type;
			pessoaTO.rendaMensal = con.Conta__r.Renda__c;
			pessoaTO.nome = con.Conta__r.Name;
			pessoaTO.nomeSocial = con.Conta__r.NomeSocial__c; // LECVPV-188(CANCELAMENTO) INICIO/FIM
			pessoaTO.email = con.Conta__r.PersonEmail;
			
			// -------------------------------------------------------------------------------------------------------------- DadosPessoaFisicaTO
			EmissaoTO.DadosPessoaFisicaTO dadospessoafisicaTO = new EmissaoTO.DadosPessoaFisicaTO();

			dadospessoafisicaTO.grupoProfissao = mapProfissaoGrupoRiscoProfissao.get(con.Conta__r.Profissao__c) != null ? mapProfissaoGrupoRiscoProfissao.get(con.Conta__r.Profissao__c) : '';
			dadospessoafisicaTO.paisResidente = con.Conta__r.PaisResidencia__c;
			dadospessoafisicaTO.profissao = con.Conta__r.Profissao__r.Codigo__c;
			dadospessoafisicaTO.orgaoExpedidor = con.Conta__r.OrgaoExpedidor__c;
						
			if(con.Conta__r.EstadoCivil__c == 'Solteiro (a)')
				dadospessoafisicaTO.estadoCivil = 'SOLTEIRO';
			if(con.Conta__r.EstadoCivil__c == 'Divorciado(a)')
				dadospessoafisicaTO.estadoCivil = 'DIVORCIADO';
			if(con.Conta__r.EstadoCivil__c == 'Viúvo(a)')
				dadospessoafisicaTO.estadoCivil = 'VIUVO';
			if(con.Conta__r.EstadoCivil__c == 'Desquitado(a)')
				dadospessoafisicaTO.estadoCivil = 'DESQUITADO';
			if(con.Conta__r.EstadoCivil__c == 'Casado (a)')
				dadospessoafisicaTO.estadoCivil = 'CASADO';
			if(con.Conta__r.EstadoCivil__c == 'Vive maritalmente')
				dadospessoafisicaTO.estadoCivil = 'VIVEMARITALMENTE';
				
			dadospessoafisicaTO.docIdentificacao = con.Conta__r.DocIndentificacao__c;
			dadospessoafisicaTO.resideBrasil = con.Conta__r.ResideBrasil__c;
			dadospessoafisicaTO.fumante = con.Conta__r.Fumante__c != null ? Boolean.valueOf(con.Conta__r.Fumante__c) : null;
			dadospessoafisicaTO.digitoCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(12, 14) : '';
			dadospessoafisicaTO.numeroCpf = (con.Conta__r.Cpf__c != '' && con.Conta__r.Cpf__c != null) ? con.Conta__r.Cpf__c.substring(0, 11) : '';
			dadospessoafisicaTO.dataExpedicao = con.Conta__r.DataExpedicao__c;
			dadospessoafisicaTO.idade = con.Conta__r.Idade__c != null ? Integer.ValueOf(con.Conta__r.Idade__c) : null;
			// dadospessoafisicaTO.tipoDocIdentificacao = con.Conta__r.TipoDocidentificacao__c; // PLV-4606-FIX
			dadospessoafisicaTO.sexo = con.Conta__r.Sexo__c;
			dadospessoafisicaTO.dataNascimento = con.Conta__r.PersonBirthdate != null ? String.valueOf(con.Conta__r.PersonBirthdate) : null;
			dadospessoafisicaTO.nacionalidade = con.Conta__r.Nacionalidade__c;
			dadospessoafisicaTO.regimeTrabalho = con.Conta__r.RegimeTrabalho__c;
			pessoaTO.dadosPessoaFisica = dadosPessoaFisicaTO;

			// ----------------------------------------------------------------------------------------------------------------- EnderecoTO
			List<EmissaoTO.EnderecoTO> enderecosTO = new List<EmissaoTO.EnderecoTO>();
			system.debug('endComercial');
			system.debug(endComercial);
			if(endComercial != null){
				EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
				enderecoTO.uf = endComercial.Estado__c;
				enderecoTO.cidade = endComercial.Cidade__c;
				enderecoTO.complemento = endComercial.Complemento__c != null ? endComercial.Complemento__c : '';
				enderecoTO.logradouro = endComercial.Logradouro__c;
				enderecoTO.bairro = endComercial.Bairro__c;
				enderecoTO.complementoCep = endComercial.Cep__c != null ? endComercial.Cep__c.subString(5,8) : null;
				enderecoTO.tipoEndereco = endComercial.TipoEndereco__c != null ? endComercial.TipoEndereco__c.toUpperCase() : null;
				enderecoTO.numeroLogradouro = endComercial.Numero__c;
				enderecoTO.cep = endComercial.Cep__c != null ? endComercial.Cep__c.subString(0,5) : null;
				enderecosTO.add(enderecoTO);
			}
			system.debug('endResidencial');
			system.debug(endResidencial);
			if(endResidencial != null){
				EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
				enderecoTO.uf = endResidencial.Estado__c;
				enderecoTO.cidade = endResidencial.Cidade__c;
				enderecoTO.complemento = endResidencial.Complemento__c != null ? endResidencial.Complemento__c : '';
				enderecoTO.logradouro = endResidencial.Logradouro__c;
				enderecoTO.bairro = endResidencial.Bairro__c;
				enderecoTO.complementoCep = endResidencial.Cep__c != null ? endResidencial.Cep__c.subString(5,8) : null;
				enderecoTO.tipoEndereco = endResidencial.TipoEndereco__c != null ? endResidencial.TipoEndereco__c.toUpperCase() : null;
				enderecoTO.numeroLogradouro = endResidencial.Numero__c;
				enderecoTO.cep = endResidencial.Cep__c != null ? endResidencial.Cep__c.subString(0,5) : null;
				enderecosTO.add(enderecoTO);
			}
			pessoaTO.enderecos = enderecosTO;
			// ------------------------------------------------------------------------------------------------------------------------ TelefonesTO
			List<EmissaoTO.TelefoneTO> telefonesTO = new List<EmissaoTO.TelefoneTO>();
			
			EmissaoTO.TelefoneTO telefoneTO1 = new EmissaoTO.TelefoneTO();
			telefoneTO1.tipoTelefone = 'CEL';
			if (con.Conta__r.PersonMobilePhone != null && con.Conta__r.PersonMobilePhone != '') {
				telefoneTO1.numeroTelefone = con.Conta__r.PersonMobilePhone.subString(5, con.Conta__r.PersonMobilePhone.length()).replace('-', '');
				telefoneTO1.dddTelefone = con.Conta__r.PersonMobilePhone.subString(1,3);
			}
			EmissaoTO.TelefoneTO telefoneTO2 = new EmissaoTO.TelefoneTO();
			telefoneTO2.tipoTelefone = 'RES';
			if (con.Conta__r.PersonHomePhone != null && con.Conta__r.PersonHomePhone != '') {
				telefoneTO2.numeroTelefone = con.Conta__r.PersonHomePhone.subString(5, con.Conta__r.PersonHomePhone.length()).replace('-', '');
				telefoneTO2.dddTelefone = con.Conta__r.PersonHomePhone.subString(1,3);
			}
			EmissaoTO.TelefoneTO telefoneTO3 = new EmissaoTO.TelefoneTO();
			telefoneTO3.tipoTelefone = 'PES';
			if (con.Conta__r.Phone != null && con.Conta__r.Phone != '') {
				System.debug('con.Conta__r.Phone> ' + con.Conta__r.Phone);
				System.debug('con.Conta__r.PersonHomePhone> ' + con.Conta__r.PersonHomePhone);
				System.debug('telefoneTO1>> ' + telefoneTO1);
				System.debug('telefoneTO2>> ' + telefoneTO2);
				System.debug('telefoneTO3>> ' + telefoneTO3);
				// PLV-5129 - FIX01 - Inicio
				telefoneTO3.numeroTelefone = con.Conta__r.Phone.subString(5, con.Conta__r.Phone.length()).replace('-', '');
				//telefoneTO3.numeroTelefone = '993067953';
				telefoneTO3.dddTelefone = con.Conta__r.Phone.subString(1,3);
				//telefoneTO3.dddTelefone = '31';
				// PLV-5129 - FIX01 - Fim
			}
			
			telefonesTO.add(telefoneTO1);
			telefonesTO.add(telefoneTO2);
			telefonesTO.add(telefoneTO3);
			pessoaTO.telefones = telefonesTO;
			return pessoaTO;
	}

	public static void montarContratoOriginal(Id idContratoOriginal, EmissaoTO contratoOriginal, EmissaoTO.PayloadTO novaPropostaTO){
		Set<Id> ids = new Set<Id>();
		ids.add(idContratoOriginal);
		List<Contract> contratos = ContractDao.getInstance().buscarContratos(ids);
		Contract contrato = contratos[0];
		
		System.debug('contrato Danilo: '+ contrato);

		Set<Id> idsRemuneracoes = new Set<Id>();
		Map<String, List<FavorecidoRemuneracaoContrato__c>> mapFavorecidos = new Map<String, List<FavorecidoRemuneracaoContrato__c>>();
		for (RemuneracaoContrato__c remuneracoes : contrato.RemuneracoesContrato__r) {
			idsRemuneracoes.add(remuneracoes.Id);
			mapFavorecidos.put(remuneracoes.Id, new List<FavorecidoRemuneracaoContrato__c>());
		}
		
		for (FavorecidoRemuneracaoContrato__c favorecido : [SELECT Id, Participacao__c, AntecipacaoComissao__c, Papel__c, RemuneracaoContrato__c, CorretorLider__c, Susep__c
															 FROM FavorecidoRemuneracaoContrato__c
															 WHERE RemuneracaoContrato__c IN: idsRemuneracoes]) {
			List<FavorecidoRemuneracaoContrato__c> listFavorecidos = mapFavorecidos.get(favorecido.RemuneracaoContrato__c);
			listFavorecidos.add(favorecido);
			mapFavorecidos.put(favorecido.RemuneracaoContrato__c, listFavorecidos);
		}

		Set<Id> idsContratantes = new Set<Id>();
		Map<String, List<GrupoContrato__c>> mapGruposContrato = new Map<String, List<GrupoContrato__c>>();
		for (ContratanteContrato__c contratante : contrato.ContratantesContrato__r) {
			idsContratantes.add(contratante.Id);
			mapGruposContrato.put(contratante.Id, new List<GrupoContrato__c>());
		}

		// LECVPV-188(CANCELAMENTO) INICIO
		List<GrupoContrato__c> listGrupoContratoQuery = [SELECT Id, ContratanteContrato__c, QuantidadeVidas__c, Name, IOF__c, PremioComercial__c, PremioPuro__c,
												PremioTotal__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c, TipoDescontoAgravo__c,
												DescontoAgravoPercentualTecnico__c, DescontoAgravoMonetarioTecnico__c,
												DescontoAgravoPercentualFormaPagto__c, DescontoAgravoMonetarioFormaPagto__c,
												(SELECT Id, IOF__c, TaxaComercial__c,TaxaPura__c,TaxaTotal__c,PremioComercial__c, Conta__r.EmpresaTrabalhaSocio__c,
														PremioPuro__c,PremioTotal__c,DescontoAgravoMonetarioFormaPagto__c,DescontoAgravoMonetarioTecnico__c,
														DescontoAgravoPercentualFormaPagto__c,DescontoAgravoPercentualTecnico__c,TipoDescontoAgravo__c,
														Conta__c, Conta__r.MelhorPeriodoContato__c, Conta__r.Pep__c, Conta__r.Type, Conta__r.Renda__c,
														Conta__r.Name, Conta__r.NomeSocial__c, Conta__r.PersonEmail, Conta__r.PaisResidencia__c, Conta__r.Profissao__r.Codigo__c,
														Conta__r.OrgaoExpedidor__c, Conta__r.EstadoCivil__c, Conta__r.DocIndentificacao__c,
														Conta__r.ResideBrasil__c, Conta__r.Fumante__c, Conta__r.Cpf__c, Conta__r.DataExpedicao__c,
														Conta__r.Idade__c, Conta__r.TipoDocidentificacao__c, Conta__r.Sexo__c, Conta__r.PersonBirthdate,
														Conta__r.Nacionalidade__c, Conta__r.RegimeTrabalho__c, Conta__r.PersonMobilePhone,
														Conta__r.PersonHomePhone, Conta__r.Phone, ResponsavelFinanceiroSeguro__c, RamoAtividade__c
												FROM SeguradosContrato__r) 
										FROM GrupoContrato__c
										WHERE ContratanteContrato__c IN: idsContratantes];
		// LECVPV-188(CANCELAMENTO) FIM
		for (GrupoContrato__c grupo : listGrupoContratoQuery) {
			List<GrupoContrato__c> listGrupoContrato = mapGruposContrato.get(grupo.ContratanteContrato__c);
			listGrupoContrato.add(grupo);
			mapGruposContrato.put(grupo.ContratanteContrato__c, listGrupoContrato);
		}

		List<Id> listAccountIdSegurado = new List<Id>();
		List<Id> listIdSegurado = new List<Id>();
		Map<String, Endereco__c> mapSeguradoEndereco = new Map<String, Endereco__c>();
		Map<String, List<BeneficiarioSeguradoContrato__c>> mapSeguradoBeneficiario = new Map<String, List<BeneficiarioSeguradoContrato__c>>();
		Map<String, List<GarantiaSeguradoContrato__c>> mapSeguradoGarantia = new Map<String, List<GarantiaSeguradoContrato__c>>();
		for (GrupoContrato__c grupo : listGrupoContratoQuery) {
			for (SeguradoContrato__c segurado : grupo.SeguradosContrato__r) {
				listAccountIdSegurado.add(segurado.Conta__c);
				listIdSegurado.add(segurado.Id);
				mapSeguradoEndereco.put(segurado.Conta__c + 'Comercial', null);
				mapSeguradoEndereco.put(segurado.Conta__c + 'Residencial', null);
				mapSeguradoBeneficiario.put(segurado.Id, new List<BeneficiarioSeguradoContrato__c>());
				mapSeguradoGarantia.put(segurado.Id, new List<GarantiaSeguradoContrato__c>());
			}
		}
		
		for(Endereco__c endSegurado : [SELECT Id, Estado__c, Cidade__c, Complemento__c, Numero__c,
		Logradouro__c, Bairro__c, Cep__c, TipoEndereco__c , Conta__c
		FROM Endereco__c 
		WHERE Conta__c IN: listAccountIdSegurado AND MaisAtual__c = true 
		ORDER BY CreatedDate DESC]){
			if(mapSeguradoEndereco.get(endSegurado.Conta__c + 'Comercial') == null && endSegurado.TipoEndereco__c == 'Comercial'){
				mapSeguradoEndereco.put(endSegurado.Conta__c + 'Comercial', endSegurado);
			}
			if(mapSeguradoEndereco.get(endSegurado.Conta__c + 'Residencial') == null && endSegurado.TipoEndereco__c == 'Residencial'){
				mapSeguradoEndereco.put(endSegurado.Conta__c + 'Residencial', endSegurado);
			}
		}
		
		for(BeneficiarioSeguradoContrato__c beneficiario : [SELECT Id, PercentualIndenizacao__c, Participacao__c, 
																ImprimirCertificadoSeguro__c, TipoBeneficiario__c, SeguradoContrato__c 
															FROM BeneficiarioSeguradoContrato__c 
															WHERE SeguradoContrato__c IN: listIdSegurado]){
			List<BeneficiarioSeguradoContrato__c> listBeneficiarios = mapSeguradoBeneficiario.get(beneficiario.SeguradoContrato__c);
			listBeneficiarios.add(beneficiario);
			mapSeguradoBeneficiario.put(beneficiario.SeguradoContrato__c, listBeneficiarios);
		}

		for(GarantiaSeguradoContrato__c garantia : [SELECT Id, IOF__c, Valor__c, Garantia__r.Sigla__c, SeguradoContrato__c
															FROM GarantiaSeguradoContrato__c 
															WHERE SeguradoContrato__c IN: listIdSegurado]){
			List<GarantiaSeguradoContrato__c> listGarantia = mapSeguradoGarantia.get(garantia.SeguradoContrato__c);
			listGarantia.add(garantia);
			mapSeguradoGarantia.put(garantia.SeguradoContrato__c, listGarantia);
		}

		novaPropostaTO.proposta.termoGuarda = contrato.Proposta__r.TermoGuarda__c;
		novaPropostaTO.proposta.termoResponsabilidade = contrato.Proposta__r.TermoResponsabilidade__c;
		novaPropostaTO.proposta.assinaturaEletronica = contrato.Proposta__r.AssinaturaEletronica__c;
		novaPropostaTO.proposta.scoreFraude = contrato.Proposta__r.ScoreFraude__c;
		novaPropostaTO.proposta.formaReceberApolice = contrato.Proposta__r.FormaReceberApolice__c;
		novaPropostaTO.proposta.origem = contrato.Proposta__r.Origem__c != null ? Integer.valueOf(contrato.Proposta__r.Origem__c) : 0;
		novaPropostaTO.proposta.ramoSeguro = contrato.Proposta__r.RamoSeguro__r.Codigo__c != null ? Integer.valueOf(contrato.Proposta__r.RamoSeguro__r.Codigo__c) : 0;
		novaPropostaTO.proposta.codigoEmpresa = contrato.Proposta__r.Modalidade__r.CodigoEmpresa__c != null ? Integer.valueOf(contrato.Proposta__r.Modalidade__r.CodigoEmpresa__c) : 0;
		novaPropostaTO.proposta.indice = 1;


		if (!contratos.isEmpty()) {
			contratoOriginal.tarifa = contrato.Tarifa__c;
			contratoOriginal.vigenciaFinal = contrato.VigenciaFinal__c != null ? String.valueOf(contrato.VigenciaFinal__c) : null;
			contratoOriginal.numeroOrcamento = contrato.Proposta__r.Opportunity.Numero__c;
			contratoOriginal.ramo = contrato.CodigoRamo__c != null ? Integer.valueOf(contrato.CodigoRamo__c) : 0;
			contratoOriginal.endosso = contrato.Endosso__c;
			contratoOriginal.codigoProdutoVida = contrato.Produto__r.CodigoPrecificaProduto__c; //PLV-5392-INICIO/FIM
			contratoOriginal.apolice = contrato.NumeroApolice__c;
			contratoOriginal.sucursal = contrato.Empresa__c != null ? Integer.valueOf(contrato.Empresa__c) : 0;
			contratoOriginal.empresa = contrato.Sucursal__c;
			contratoOriginal.vigenciaInicial = contrato.StartDate != null ? String.valueOf(contrato.StartDate) : null;

			//if(!Test.isRunningTest()) //II-179 - INICIO/FIM
				contratoOriginal = populaPrecificacao(contratoOriginal, contrato.Proposta__r.Opportunity.Numero__c, contrato.DescontoAgravoPercentualFormaPagto__c, contrato); //PLV-5883 INICIO/FIM
				system.Debug('contratoOriginal +++' + contratoOriginal);
			

			// ----------------------------------------------------------------------- RemuneracaoTO
			List<EmissaoTO.RemuneracaoTO> remuneracoesTO = new List<EmissaoTO.RemuneracaoTO>();
			for (RemuneracaoContrato__c remuneracao : contrato.RemuneracoesContrato__r) {
				EmissaoTO.RemuneracaoTO remuneracaoTO = new EmissaoTO.RemuneracaoTO();
				remuneracaoTO.percentual = remuneracao.Percentual__c;
				remuneracaoTO.tipoRemuneracao = remuneracao.TipoRemuneracao__r.Name;
				remuneracaoTO.favorecidos = new List<EmissaoTO.FavorecidoTO>();
				for (FavorecidoRemuneracaoContrato__c favorecido : mapFavorecidos.get(remuneracao.Id)) {
					EmissaoTO.FavorecidoTO favorecidoTO = new EmissaoTO.FavorecidoTO();
					// fav.pessoa = 
					favorecidoTO.corretorLider = favorecido.CorretorLider__c;
					favorecidoTO.susep = favorecido.Susep__c;
					favorecidoTO.participacao = favorecido.Participacao__c;
					favorecidoTO.antecipacaoComissao = favorecido.AntecipacaoComissao__c;
					favorecidoTO.papel = favorecido.papel__c;
					remuneracaoTO.favorecidos.add(favorecidoTO);
				}

				remuneracoesTO.add(remuneracaoTO);
			}
			contratoOriginal.remuneracoes = remuneracoesTO;

			// ------------------------------------------------------------------------ ContratantesTO
			EmissaoTO.DadosPagamentoTO dadosPagamentoOriginal = new EmissaoTO.DadosPagamentoTO();
			SeguradoContrato__c seguradoNovo = new SeguradoContrato__c();
			List<EmissaoTO.ContratanteTO> contratantes = new List<EmissaoTO.ContratanteTO>();
			for (ContratanteContrato__c contratante : contrato.ContratantesContrato__r) {
				EmissaoTO.ContratanteTO contratanteTO = new EmissaoTO.ContratanteTO();
				contratanteTO.iof = contratante.iof__c;
				contratanteTO.tipo = 'PRI';
				contratanteTO.numero = '1';

				contratanteTO.taxa = new EmissaoTO.TaxaTO();
				contratanteTO.taxa.pura = contratante.TaxaPura__c != null ? contratante.TaxaPura__c : 0;
				contratanteTO.taxa.comercial = contratante.TaxaComercial__c != null ? contratante.TaxaComercial__c : 0;
				contratanteTO.taxa.total = contratante.TaxaTotal__c != null ? contratante.TaxaTotal__c : 0;

				System.debug('XXX - TAXA PURA: '+ contratanteTO.taxa.pura);
				System.debug('XXX - TAXA COMERCIAL: '+ contratanteTO.taxa.comercial);
				System.debug('XXX - TAXA TOTAL: '+ contratanteTO.taxa.total);

				contratanteTO.premio = new EmissaoTO.PremioTO();
				contratanteTO.premio.puro = contratante.PremioPuro__c != null ? contratante.PremioPuro__c : 0;
				contratanteTO.premio.comercial = contratante.PremioComercial__c != null ? contratante.PremioComercial__c : 0;
				contratanteTO.premio.total = contratante.PremioTotal__c != null ? contratante.PremioTotal__c : 0;

				contratanteTO.descontoAgravo = new List<EmissaoTO.DescontoagravoTO>();
				EmissaoTO.DescontoagravoTO descontoAgravoTecContratante = new EmissaoTO.DescontoagravoTO();
				EmissaoTO.DescontoagravoTO descontoAgravoFpgContratante = new EmissaoTO.DescontoagravoTO();
				if (contratante.TipoDescontoAgravo__c == 'Técnico') {
					descontoAgravoTecContratante.tipo = 'TEC';
					descontoAgravoTecContratante.percentual = contratante.DescontoAgravoPercentualTecnico__c;
					descontoAgravoTecContratante.monetario = contratante.DescontoAgravoMonetarioTecnico__c;
					descontoAgravoFpgContratante.tipo = 'FPG';
					descontoAgravoFpgContratante.percentual = 0;
					descontoAgravoFpgContratante.monetario = 0;
				} else {
					descontoAgravoFpgContratante.tipo = 'FPG';
					descontoAgravoFpgContratante.percentual = contratante.DescontoAgravoPercentualFormaPagto__c;
					descontoAgravoFpgContratante.monetario = contratante.DescontoAgravoMonetarioFormaPagto__c;
					descontoAgravoTecContratante.tipo = 'TEC';
					descontoAgravoTecContratante.percentual = 0;
					descontoAgravoTecContratante.monetario = 0;
				}
				contratanteTO.descontoAgravo.add(descontoAgravoFpgContratante);
				contratanteTO.descontoAgravo.add(descontoAgravoTecContratante);

				contratanteTO.dadosPagamento = new EmissaoTO.DadosPagamentoTO();
				contratanteTO.dadosPagamento.quantidadeParcelas = contratante.QuantidadeParcelas__c != null ? Integer.valueOf(contratante.QuantidadeParcelas__c) : 0;
				contratanteTO.dadosPagamento.codigoFormaPagamento = contratante.FormaPagamento__r.Codigo__c != null ? Integer.valueOf(contratante.FormaPagamento__r.Codigo__c) : 0;
				contratanteTO.dadosPagamento.vencimentoDemaisParcelas = contratante.VencimentoDemaisParcelas__c;
				contratanteTO.dadosPagamento.idPlanoParcelamento = contratante.PlanoParcelamento__c;
				contratanteTO.dadosPagamento.vencimentoPrimeiraParcela = contratante.VencimentoPrimeiraParcela__c != null ? String.valueOf(contratante.VencimentoPrimeiraParcela__c) : null;
				contratanteTO.dadosPagamento.tipoResponsavelPagamento = contratante.TipoResponsavelPagamento__c;
				contratanteTO.dadosPagamento.descricao = contratante.PlanoParcelamento__r.DescricaoMeioRecebimento__c;
				contratanteTO.dadosPagamento.codigoMeioRecebimento = contratante.PlanoParcelamento__r.CodigoMeioRecebimento__c;
				contratanteTO.dadosPagamento.codigo = contratante.FormaPagamento__r.Codigo__c != null ? Integer.valueOf(contratante.FormaPagamento__r.Codigo__c) : 0;
				
				dadosPagamentoOriginal = contratanteTO.dadosPagamento;
				

				contratanteTO.pessoa = new EmissaoTO.PessoaTO();
				contratanteTO.pessoa.tipo = contratante.Conta__r.RecordType.DeveloperName == 'PessoaFisica' ? 'FIS' : 'JUR' ; 
				contratanteTO.pessoa.nome = contratante.NomeContratante__c;
				contratanteTO.pessoa.nomeSocial = contratante.NomeSocial_do_Contratante__c; // LECVPV-188(CANCELAMENTO) INICIO/FIM
				if (contratanteTO.pessoa.tipo == 'FIS') {
					contratanteTO.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
					contratanteTO.pessoa.dadosPessoaFisica.numeroCpf = (contratante.CpfCnpj__c != '' && contratante.CpfCnpj__c != null) ? contratante.CpfCnpj__c.substring(0, 11) : '';
					contratanteTO.pessoa.dadosPessoaFisica.digitoCpf = (contratante.CpfCnpj__c != '' && contratante.CpfCnpj__c != null) ? contratante.CpfCnpj__c.substring(12, 14) : '';
					contratanteTO.pessoa.dadosPessoaFisica.fumante = null;
					contratanteTO.pessoa.dadosPessoaFisica.temDependentes = null;
				} else {
					contratanteTO.pessoa.dadosPessoaJuridica = new EmissaoTO.DadosPessoaJuridicaTO();
					contratanteTO.pessoa.dadosPessoaJuridica.numeroCnpj = (contratante.CpfCnpj__c != '' && contratante.CpfCnpj__c != null) ? contratante.CpfCnpj__c.replace('.','').split('/')[0] : '';
					contratanteTO.pessoa.dadosPessoaJuridica.ordemCnpj  = (contratante.CpfCnpj__c != '' && contratante.CpfCnpj__c != null) ? contratante.CpfCnpj__c.split('/')[1].split('-')[0] : '';
					contratanteTO.pessoa.dadosPessoaJuridica.digitoCnpj = (contratante.CpfCnpj__c != '' && contratante.CpfCnpj__c != null) ? contratante.CpfCnpj__c.split('/')[1].split('-')[1] : '';
				}
				
				


				// -------------------------------------------------------------------------------------- SeguradoTO
				// List<EmissaoTO.> segurados = new List<EmissaoTO.>();


				// -------------------------------------------------------------------------------------- GrupoTO
				List<EmissaoTO.GrupoTO> grupos = new List<EmissaoTO.GrupoTO>();
				for (GrupoContrato__c grupoContrato : mapGruposContrato.get(contratante.Id)) {
					EmissaoTO.GrupoTO grupoTO = new EmissaoTO.GrupoTO();
					grupoTO.iof = grupoContrato.IOF__c;
					grupoTO.numero = '1'; // Ajustar
					grupoTO.nome = grupoContrato.Name;
					grupoTO.qtdeVidas = grupoContrato.QuantidadeVidas__c;

					// -------------------------------------------------------------------------------------- PremioTO
					grupoTO.premio = new EmissaoTO.PremioTO();
					grupoTO.premio.comercial = grupoContrato.PremioComercial__c != null ? grupoContrato.PremioComercial__c : 0;
					grupoTO.premio.total = grupoContrato.PremioTotal__c != null ? grupoContrato.PremioTotal__c : 0;
					grupoTO.premio.puro = grupoContrato.PremioPuro__c != null ? grupoContrato.PremioPuro__c : 0;

					// -------------------------------------------------------------------------------------- TaxaTO
					grupoTO.taxa = new EmissaoTO.TaxaTO();
					grupoTO.taxa.pura = grupoContrato.TaxaPura__c != null ? grupoContrato.TaxaPura__c : 0;
					grupoTO.taxa.comercial = grupoContrato.TaxaComercial__c != null ? grupoContrato.TaxaComercial__c : 0;
					grupoTO.taxa.total = grupoContrato.TaxaTotal__c != null ? grupoContrato.TaxaTotal__c : 0;

					// -------------------------------------------------------------------------------------- DescontoAgravoTO
					grupoTO.descontoAgravo = new List<EmissaoTO.DescontoagravoTO>();
					EmissaoTO.DescontoagravoTO descontoAgravoTec = new EmissaoTO.DescontoagravoTO();
					EmissaoTO.DescontoagravoTO descontoAgravoFpg = new EmissaoTO.DescontoagravoTO();
					if (grupoContrato.TipoDescontoAgravo__c == 'Técnico') {
						descontoAgravoTec.tipo = 'TEC';
						descontoAgravoTec.percentual = grupoContrato.DescontoAgravoPercentualTecnico__c;
						descontoAgravoTec.monetario = grupoContrato.DescontoAgravoMonetarioTecnico__c;
						descontoAgravoFpg.tipo = 'FPG';
						descontoAgravoFpg.percentual = 0;
						descontoAgravoFpg.monetario = 0;
					} else {
						descontoAgravoFpg.tipo = 'FPG';
						descontoAgravoFpg.percentual = grupoContrato.DescontoAgravoPercentualFormaPagto__c;
						descontoAgravoFpg.monetario = grupoContrato.DescontoAgravoMonetarioFormaPagto__c;
						descontoAgravoTec.tipo = 'TEC';
						descontoAgravoTec.percentual = 0;
						descontoAgravoTec.monetario = 0;
					}
					grupoTO.descontoAgravo.add(descontoAgravoFpg);
					grupoTO.descontoAgravo.add(descontoAgravoTec);

					// -------------------------------------------------------------------------------------- SeguradoTO
					grupoTO.segurados = new List<EmissaoTO.SeguradoTO>();
					for (SeguradoContrato__c segurado : grupoContrato.SeguradosContrato__r) {
						seguradoNovo = segurado;
						EmissaoTO.SeguradoTO seguradoTO = new EmissaoTO.SeguradoTO();
						seguradoTO.iof = segurado.IOF__c;
						seguradoTO.numero = '1';
						
						// ------------------------------------------------------ TaxaTO
						seguradoTO.taxa = new EmissaoTO.TaxaTO();
						seguradoTO.taxa.pura = segurado.TaxaPura__c != null ? segurado.TaxaPura__c : 0;
						seguradoTO.taxa.comercial = segurado.TaxaComercial__c != null ? segurado.TaxaComercial__c : 0;
						seguradoTO.taxa.total = segurado.TaxaTotal__c != null ? segurado.TaxaTotal__c : 0;
						
						// ------------------------------------------------------ PremioTO
						seguradoTO.premio = new EmissaoTO.PremioTO();
						seguradoTO.premio.comercial = segurado.PremioComercial__c != null ? segurado.PremioComercial__c : 0;
						seguradoTO.premio.total = segurado.PremioTotal__c != null ? segurado.PremioTotal__c : 0;
						seguradoTO.premio.puro = segurado.PremioPuro__c != null ? segurado.PremioPuro__c : 0;

						// ------------------------------------------------------ DescontoagravoTO
						seguradoTO.descontoAgravo = new List<EmissaoTO.DescontoagravoTO>();
						EmissaoTO.DescontoagravoTO segDescontoAgravoTec = new EmissaoTO.DescontoagravoTO();
						EmissaoTO.DescontoagravoTO segDescontoAgravoFpg = new EmissaoTO.DescontoagravoTO();
						if (segurado.TipoDescontoAgravo__c == 'Técnico') {
							segDescontoAgravoTec.tipo = 'TEC';
							segDescontoAgravoTec.percentual = segurado.DescontoAgravoPercentualTecnico__c;
							segDescontoAgravoTec.monetario = segurado.DescontoAgravoMonetarioTecnico__c;
							segDescontoAgravoFpg.tipo = 'FPG';
							segDescontoAgravoFpg.percentual = 0;
							segDescontoAgravoFpg.monetario = 0;
						} else {
							segDescontoAgravoFpg.tipo = 'FPG';
							segDescontoAgravoFpg.percentual = segurado.DescontoAgravoPercentualFormaPagto__c;
							segDescontoAgravoFpg.monetario = segurado.DescontoAgravoMonetarioFormaPagto__c;
							segDescontoAgravoTec.tipo = 'TEC';
							segDescontoAgravoTec.percentual = 0;
							segDescontoAgravoTec.monetario = 0;

						}
						seguradoTO.descontoAgravo.add(segDescontoAgravoFpg);
						seguradoTO.descontoAgravo.add(segDescontoAgravoTec);
						
						// ------------------------------------------------------ PessoaTO
						seguradoTO.pessoa = montarPessoaTO(segurado, mapSeguradoEndereco.get(segurado.Conta__c + 'Comercial'), mapSeguradoEndereco.get(segurado.Conta__c + 'Residencial'));

						// ------------------------------------------------------ BeneficiarioTO
						seguradoTO.beneficiarios = new List<EmissaoTO.BeneficiarioTO>();
						
						for (BeneficiarioSeguradoContrato__c beneficiario : mapSeguradoBeneficiario.get(segurado.Id)) {
							EmissaoTO.BeneficiarioTO beneficiarioTO = new EmissaoTO.BeneficiarioTO();
							beneficiarioTO.percentualIndenizacao = beneficiario.PercentualIndenizacao__c;
							beneficiarioTO.imprimirCertificado = beneficiario.ImprimirCertificadoSeguro__c;
							beneficiarioTO.participacao = beneficiario.Participacao__c;
							beneficiarioTO.tipoBeneficiario = beneficiario.TipoBeneficiario__c;
							seguradoTO.beneficiarios.add(beneficiarioTO);
						}
						
						
						
						

						// ------------------------------------------------------ CoberturaTO
						seguradoTO.coberturas = new List<EmissaoTO.CoberturaTO>();
						for(GarantiaSeguradoContrato__c garantia : mapSeguradoGarantia.get(segurado.Id)){
							EmissaoTO.CoberturaTO coberturaTO = new EmissaoTO.CoberturaTO();
							coberturaTO.iof = garantia.IOF__c != null ? garantia.IOF__c : 0;
							coberturaTO.franquia = ''; // Ajustar
							coberturaTO.sigla = garantia.Garantia__r.Sigla__c;
							coberturaTO.valor = garantia.valor__c != null ? garantia.valor__c : 0;
							coberturaTO.quantidade = '0'; // Ajustar
							seguradoTO.coberturas.add(coberturaTO);
						}

						grupoTO.segurados.add(seguradoTO);
					}

					grupos.add(grupoTO);
				}
				contratanteTO.grupos = grupos;

				contratantes.add(contratanteTO);
				for(EmissaoTO.ContratanteTO contratanteNovo : novaPropostaTO.proposta.contratantes){
					contratanteNovo.dadosPagamento = dadosPagamentoOriginal;
					for(EmissaoTO.GrupoTO grupoNovo : contratanteNovo.grupos){
						for(EmissaoTO.SeguradoTO seg : grupoNovo.segurados){
							seg.empresaQueTrabalha = seguradoNovo.Conta__r.EmpresaTrabalhaSocio__c;
							seg.responsavelFinanceiro = seguradoNovo.ResponsavelFinanceiroSeguro__c;
							seg.ramoAtividade = seguradoNovo.RamoAtividade__c;
							seg.beneficiarios = new List<EmissaoTO.BeneficiarioTO>();
							for (BeneficiarioSeguradoContrato__c beneficiario : mapSeguradoBeneficiario.get(seguradoNovo.Id)) {
								EmissaoTO.BeneficiarioTO beneficiarioTO = new EmissaoTO.BeneficiarioTO();
								beneficiarioTO.percentualIndenizacao = beneficiario.PercentualIndenizacao__c;
								beneficiarioTO.imprimirCertificado = beneficiario.ImprimirCertificadoSeguro__c;
								beneficiarioTO.participacao = beneficiario.Participacao__c;
								beneficiarioTO.tipoBeneficiario = beneficiario.TipoBeneficiario__c;
								seg.beneficiarios.add(beneficiarioTO);
							}
						}
					}
				}
			}
			contratoOriginal.contratantes = contratantes;
		}

	}

	private static EmissaoTO populaPrecificacao(EmissaoTO contratoOriginal, String numeroOrcamento, Decimal percentualFPG, Contract dadosContrato){ //PLV-5883 INICIO/FIM
		ConsultaDocumentoREST.ConsultaParam param = new ConsultaDocumentoREST.ConsultaParam();
		param.orcamento = numeroOrcamento;
		ConsultaDocumentoService service = new ConsultaDocumentoService(param);
		ConsultaDocumentoRest.DataTO dataTO = service.consultar();
		//PLV-5883 INICIO
		Set<Id> idContrato = new  Set<Id>();
		idContrato.add(dadosContrato.Id);
		List<SeguradoContrato__c> seguradosContratoDados = ContractDao.getInstance().buscarSeguradoContratoPorContractId(idContrato); 
		List<GrupoContrato__c> gruposContratoDados = ContractDao.getInstance().buscarListGrupoContratoByContrato(idContrato); 
		
		System.debug('dataTO>>>> '+JSON.serialize(dataTO));
		Map<String, Object> dataTOLocalstorage = new Map<String, Object>();
		EmissaoTO.PayloadTO jsonResponseCalculoTO = null;
		//PLV-5147 - INICIO
		if(dataTO != null){
			dataTOLocalstorage = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(dataTO));
			jsonResponseCalculoTO = (EmissaoTO.PayloadTO) JSON.deserialize(dataTO.ofertaPadrao, EmissaoTO.PayloadTO.class);	
		}
		System.debug('jsonResponseCalculoTO '+JSON.serialize(jsonResponseCalculoTO));
		
		if(jsonResponseCalculoTO == null && dataTO != null){
			jsonResponseCalculoTO = new EmissaoTO.PayloadTO();
			
			jsonResponseCalculoTO.ofertas = new List<EmissaoTO.OfertasTO>{
				(EmissaoTO.OfertasTO) JSON.deserialize(dataTO.localstorage, EmissaoTO.OfertasTO.class)				
			};
		}
		System.debug('jsonResponseCalculoTO ' + JSON.serialize(jsonResponseCalculoTO));
		//PLV-5147 - FIM
		
		EmissaoTO.OfertasTO ofertaSelecionada = null;
		
		EmissaoTO.RetornoCalculoTO retornoCalculoTOSelecionado = new EmissaoTO.RetornoCalculoTO();
		if(jsonResponseCalculoTO != null){
			for(EmissaoTO.OfertasTO oferta : jsonResponseCalculoTO.ofertas){
				// System.debug('oferta.orcamento');
				// System.debug(JSON.serialize(oferta.orcamento, true));
				if(oferta.orcamento.numeroOrcamento == String.valueOf(numeroOrcamento)){
					ofertaSelecionada = oferta;
				}
			}
		}
		//PLV-5883 FIM

		if(ofertaSelecionada != null){
			//PLV-5147 - FIX02 - INICIO
			if (ofertaSelecionada.retornosCalculo != null){ 
				for(EmissaoTO.RetornoCalculoTO retornoCalculo : ofertaSelecionada.retornosCalculo){
					for(EmissaoTO.DescontoAgravoTO descontoAgravo : retornoCalculo.precificacao.descontoAgravo){
						if(descontoAgravo.tipo == 'FPG' && descontoAgravo.percentual == percentualFPG){
							retornoCalculoTOSelecionado = retornoCalculo;
						}
					}
				}
			}
			//PLV-5147 - FIX02 - FIM
		}else{  //PLV-5883 INICIO
			System.debug('Danilo dadosContrato ' + dadosContrato); 
			System.debug('Danilo dadosContrato ' + dadosContrato.PremioTotal__c); 
			System.debug('Danilo retornoCalculoTOSelecionado ' + retornoCalculoTOSelecionado); 
			
			EmissaoTO.PrecificacaoTO dadosPreci = new EmissaoTO.PrecificacaoTO();
			EmissaoTO.PremioTO dadosPremio = new EmissaoTO.PremioTO();

			dadosPremio.total = dadosContrato.PremioTotal__c;
			dadosPremio.puro = dadosContrato.PremioPuro__c;
			dadosPremio.comercial = dadosContrato.PremioComercial__c;
			
			dadosPreci.premio = dadosPremio;
			dadosPreci.iof = dadosContrato.ValorIOF__c;
			
			retornoCalculoTOSelecionado.precificacao = dadosPreci;			
			retornoCalculoTOSelecionado.opcao = 1;

			EmissaoTO.DescontoagravoTO descontoAgravoObjeto = new EmissaoTO.DescontoagravoTO();
			List<EmissaoTO.DescontoagravoTO> listDescontoAgravoObjeto = new List<EmissaoTO.DescontoagravoTO>();
			if(dadosContrato.DescontoAgravoPercentualFormaPagto__c != null){
				descontoAgravoObjeto.tipo = 'FPG';
				descontoAgravoObjeto.percentual = dadosContrato.DescontoAgravoPercentualFormaPagto__c;
				descontoAgravoObjeto.monetario = dadosContrato.DescontoAgravoMonetarioFormaPagto__c;
				listDescontoAgravoObjeto.add(descontoAgravoObjeto);
			}
			retornoCalculoTOSelecionado.precificacao.descontoAgravo = listDescontoAgravoObjeto;
			
			List<EmissaoTO.CoberturaTO> listCoberturasObjeto = new List<EmissaoTO.CoberturaTO>();
			for(GarantiaContrato__c dadosGarantia : dadosContrato.GarantiasContrato__r){
				EmissaoTO.CoberturaTO coberturasObjeto = new EmissaoTO.CoberturaTO();
				EmissaoTO.PremioTO dadosPremioCobertura = new EmissaoTO.PremioTO();
				dadosPremioCobertura.puro = dadosGarantia.PremioPuro__c;
				dadosPremioCobertura.total = dadosGarantia.PremioTotal__c;
				dadosPremioCobertura.comercial = dadosGarantia.PremioComercial__c;
				coberturasObjeto.premio = dadosPremioCobertura;
				coberturasObjeto.iof = dadosGarantia.IOF__c;
				coberturasObjeto.sigla = dadosGarantia.Garantia__r.Sigla__c;
				coberturasObjeto.descontoAgravo = listDescontoAgravoObjeto;
				listCoberturasObjeto.add(coberturasObjeto);
			}
			retornoCalculoTOSelecionado.precificacao.coberturas = listCoberturasObjeto;
			
			EmissaoTO.SeguradoTO seguradosObjeto = new EmissaoTO.SeguradoTO();
			List<EmissaoTO.SeguradoTO> listSeguradosObjeto = new List<EmissaoTO.SeguradoTO>();

			for(SeguradoContrato__c dadosSegurado : seguradosContratoDados){
				EmissaoTO.PremioTO dadosPremioSegurados = new EmissaoTO.PremioTO();
				dadosPremioSegurados.total = dadosSegurado.PremioTotal__c;
				dadosPremioSegurados.puro = dadosSegurado.PremioPuro__c;
				dadosPremioSegurados.comercial = dadosSegurado.PremioComercial__c;
				seguradosObjeto.premio = dadosPremiosegurados;
				seguradosObjeto.numero = '1';
				seguradosObjeto.iof = dadosSegurado.IOF__c;
				seguradosObjeto.descontoAgravo = listDescontoAgravoObjeto;
				seguradosObjeto.coberturas = listCoberturasObjeto;
				listSeguradosObjeto.add(seguradosObjeto);
			}
			
			EmissaoTO.GrupoTO gruposObjeto = new EmissaoTO.GrupoTO();
			List<EmissaoTO.GrupoTO> listGruposObjeto = new List<EmissaoTO.GrupoTO>();

			for(GrupoContrato__c dadosGrupo : gruposContratoDados){
				EmissaoTO.PremioTO dadosPremioGrupo = new EmissaoTO.PremioTO();
				dadosPremioGrupo.total = dadosGrupo.PremioTotal__c;
				dadosPremioGrupo.puro = dadosGrupo.PremioPuro__c;
				dadosPremioGrupo.comercial = dadosGrupo.PremioComercial__c;
				gruposObjeto.premio = dadosPremioGrupo;
				gruposObjeto.iof = dadosGrupo.IOF__c;
				gruposObjeto.numero = '1';
				gruposObjeto.coberturas = listCoberturasObjeto;
				gruposObjeto.descontoAgravo = listDescontoAgravoObjeto;
				gruposObjeto.segurados = listSeguradosObjeto;
				listGruposObjeto.add(gruposObjeto);
			}
			
			EmissaoTO.ContratanteTO contratantesObjeto = new EmissaoTO.ContratanteTO();
			List<EmissaoTO.ContratanteTO> listContratantesObjeto = new List<EmissaoTO.ContratanteTO>();
			for(ContratanteContrato__c dadosContratantes : dadosContrato.ContratantesContrato__r){
				EmissaoTO.PremioTO dadosPremioContratantes = new EmissaoTO.PremioTO();
				dadosPremioContratantes.total = dadosContratantes.PremioTotal__c;
				dadosPremioContratantes.puro = dadosContratantes.PremioPuro__c;
				dadosPremioContratantes.comercial =  dadosContratantes.PremioComercial__c;
				contratantesObjeto.premio = dadosPremioContratantes;
				contratantesObjeto.numero = '1';
				contratantesObjeto.descontoAgravo = listDescontoAgravoObjeto;
				contratantesObjeto.coberturas = listCoberturasObjeto;
				contratantesObjeto.grupos = listGruposObjeto;
				listContratantesObjeto.add(contratantesObjeto);
			}
			retornoCalculoTOSelecionado.precificacao.contratantes = listContratantesObjeto;
		}
		contratoOriginal.precificacao = retornoCalculoTOSelecionado.precificacao;
		contratoOriginal.versoesCalculos = new List<EmissaoTO.VersoesCalculo>();
		EmissaoTO.VersoesCalculo versaoCalculo = new EmissaoTO.VersoesCalculo();
		versaoCalculo.opcao = retornoCalculoTOSelecionado.opcao;
		versaoCalculo.tipo = 'FPG';
		versaoCalculo.descontoAgravo = percentualFPG;
		contratoOriginal.versoesCalculos.add(versaoCalculo);
		return contratoOriginal;
		//PLV-5883 FIM

	}
	// PLV-4606-FIM
}