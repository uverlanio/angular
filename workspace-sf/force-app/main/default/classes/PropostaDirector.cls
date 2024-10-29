/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável administrar qual tipo de builder será processado
 *
 **************************************************************************************************************************************************************************/
public without sharing class PropostaDirector {
	private static final PropostaDirector instance = new PropostaDirector();
	public static PropostaDirector getInstance() { return instance;	}
	private PropostaDirector() { }

	// Constantes
	private static final String SIGLA_MASSIFICADOS = 'massificados';
	private static final String SIGLA_GRAVAR_GENERICO = 'gravar';
	private static final String SIGLA_ATUALIZAR_DEVOLUTIVA = 'devolutiva';

	private static final String SIGLA_CANCELAMENTO = 'cancelamento';
	private static final String SIGLA_ENDOSSO = 'endosso';
	private static final String SIGLA_NOVO = 'Novo';
	private static final String SIGLA_RENOVACAO = 'renovacao';

	private final List<String> SIGLA_DESISTENCIA_SEGURO = new List<String>(); //PLV-5288 - INICIO/FIM	
	private static final String SIGLA_DESISTENCIA_INADIMPLENCIA = 'INA'; //VEP-896 - INICIO/FIM


	/*
  	 * @author Everymind - Sprint 21
  	 * @Descrição: recebe o payload de proposta e deireciona ao processamento (bulder) especifica de acordo com os parametros de entrada
 	*/
	public RetornoPropostaRestTO.ValidacaopropostaTO processarProposta(String payload, String path){

		// Instancias
		RetornoPropostaRestTO.ValidacaopropostaTO retorno = new RetornoPropostaRestTO.ValidacaopropostaTO();
		PropostaGenericaBuilder propostaGenerica = PropostaGenericaBuilder.getInstance();
		// INICIO | PLV-2355-Hackathon
		// PLV- 3285 - INICIO
		PropostaGenericaCancelamentoBuilder propostaGenericaCancelamento = PropostaGenericaCancelamentoBuilder.getInstance();
		// PLV- 3285 - FIM
		// FIM | PLV-2355-Hackathon
		Proposta propostaGerada;
		//PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
		List<Proposta> propostasGeradas;
		//PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista

		// trata parametros url p/ redirecionar p/ builder correta
		
		String fluxoProduto = path.split('/')[path.split('/').size()-2];
		String tipo = path.substring(path.lastIndexOf('/') + 1);
        system.debug('tipo: ' + tipo);

		//PLV-5288 - INICIO
		SIGLA_DESISTENCIA_SEGURO.add('DES');
		SIGLA_DESISTENCIA_SEGURO.add('INA');
		//PLV-5288 - FIM

		//PLV-3285 - INICIO
		System.debug('payload entrada ' + payload);
		 // PLV - 4594 - INICIO   ODEMIR SYS4B
		// EmissaoTO.PayloadTO objPayload=null;
		EmissaoTO.PayloadTO objPayload;
		 // este ajuste foi feito para corrigir ajuste no CIV que transformou o no proposta do json em proposta[]
		 // o codigo abaixo faz a substituicao de proposta[] para proposta, se necessario, mas
		 // o risco é grande de invalidar o json todo .. O CORRETO É ACERTAR NO CIV E TIRAR os replace abaxio
		try {
			objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
			//objPayload.proposta.contratantes[0].pessoa.nivelRelacionamento = '5';
			System.debug('1DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
		} catch (Exception e ) {
			System.debug('payload entrada erro .. tentando com replace '+ e.getStackTraceString());
			String payloadString = payload.replace('"proposta":[{','"proposta":{').replace('"COR"}]}]}]','"COR"}]}]}').replace('"AGE"}]}]}]','"AGE"}]}]}');
			System.debug('payload entrada ajustado ' + payloadString);
			objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payloadString, EmissaoTO.PayloadTO.class);
			System.debug('2DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
			system.debug('Json de entrada - objPayload: ' + objPayload);
		}
        // PLV - 4594 - FIM   ODEMIR SYS4B
      
		try 
		{            
		//PLV-3285 - FIM
            //ValidaInformacoesPayloadTO = (ValidaInformacoesPayloadTO) JSON.deserialize(payload, ValidaInformacoesPayloadTO.class);
			//List<ValidaInformacoesPayloadTO> lValida = ValidaInformacoesPayload.ValidarInformacoes(objPayload);

			// Verifica se eh uma proposta de massificados
			if(fluxoProduto == SIGLA_MASSIFICADOS) 
			{
				System.debug('MASSIFICADOS');
				// Verifica se eh um seguro novo
				if(tipo == SIGLA_NOVO)
				{
					System.debug('NOVA EMISSAO MASSIFICADOS');
					return PropostaFacade.getInstance().processaPayload(payload, retorno);
				}
				//PLV-5288 - INICIO				
				else if(tipo == SIGLA_CANCELAMENTO && (SIGLA_DESISTENCIA_SEGURO.contains(objPayload.proposta.tipoEndosso) || objPayload.proposta.tipoEndosso == SIGLA_DESISTENCIA_INADIMPLENCIA)) //VEP-896 - INICIO/FIM // Verifica se eh um cancelamento por desistencia 
				{
					System.debug('CANCELAMENTO MASSIFICADOS');
					propostaGerada = PropostaMassificadosCancelamentoBuilder.getInstance().montarProposta(objPayload, null, true);
					retorno = PropostaMassificadosCancelamentoBuilder.getInstance().converterPropostaParaRetornoProposta();
				}
				//PLV-5288 - FIM
			} 
			else 
			{
				// INICIO | PLV 2234
				if(tipo == 'MOCK'){
					System.debug('MOCK');
					retorno.proposta = SniperMock.retornoTransmissao();
					
					System.debug(retorno.proposta);
				}
				else{
					// INICIO | PLV-2355-Hackathon
					// 2.2.E // PLV-3285
					if(tipo == SIGLA_GRAVAR_GENERICO){
						// System.debug('EMISSAO GENERICA (payload)');
						//PLV-2704 - Inicio - Adição de possivel retorno
						// PLV-2681 - Inicio - Inclusão das validações de favorecidos
						// PLV-4711 - INICIO
						System.debug('3DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
						if(objPayload != null && objPayload.proposta != null && objPayload.proposta.remuneracoes != null && objPayload.proposta.remuneracoes.size() > 0){
							List<String> listSusep = new List<String>();
							for(EmissaoTO.RemuneracaoTO remu : objPayload.proposta.remuneracoes){
								if(remu.tipoRemuneracao == 'AGE'){
									for(EmissaoTO.FavorecidoTO fav : remu.favorecidos){
										listSusep.add(fav.susep);
									}
								}
							}
							List<DadosCorretor__c> listDadosCorretor = [SELECT id, Name, NomeCorretor__r.Cpf__c, NomeCorretor__r.CNAE__c, NomeCorretor__r.Cnpj__c, NomeCorretor__r.Name, NomeCorretor__r.RecordType.DeveloperName FROM DadosCorretor__c WHERE Name IN: listSusep];
							Map<String, DadosCorretor__c> mapDadosCorretor = new Map<String, DadosCorretor__c>();
							for(DadosCorretor__c dc : listDadosCorretor){
								mapDadosCorretor.put(dc.name, dc);
							}
							for(EmissaoTO.RemuneracaoTO remu : objPayload.proposta.remuneracoes){
								if(remu.tipoRemuneracao == 'AGE'){
									for(EmissaoTO.FavorecidoTO fav : remu.favorecidos){
										if(mapDadosCorretor.get(fav.susep) != null){
											DadosCorretor__c corretor = mapDadosCorretor.get(fav.susep);
											if(corretor.NomeCorretor__r.RecordType.DeveloperName == 'PessoaJuridica'){
												if(fav.pessoa != null && corretor.NomeCorretor__r.Cnpj__c != null){
													fav.pessoa.tipo = 'JUR';
													fav.pessoa.dadosPessoaJuridica = new EmissaoTO.DadosPessoaJuridicaTO();
													fav.pessoa.dadosPessoaJuridica.numeroCnpj = corretor.NomeCorretor__r.Cnpj__c.replace('.','').split('/')[0];
													fav.pessoa.dadosPessoaJuridica.ordemCnpj = corretor.NomeCorretor__r.Cnpj__c.split('/')[1].split('-')[0];
													fav.pessoa.dadosPessoaJuridica.digitoCnpj = corretor.NomeCorretor__r.Cnpj__c.split('/')[1].split('-')[1];
												}
											}else{
												if(fav.pessoa != null && corretor.NomeCorretor__r.CPF__c != null){
													fav.pessoa.tipo = 'FIS';
													fav.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
													fav.pessoa.dadosPessoaFisica.numeroCpf = corretor.NomeCorretor__r.CPF__c.replace('.','').split('-')[0];
													fav.pessoa.dadosPessoaFisica.digitoCpf = corretor.NomeCorretor__r.CPF__c.split('-')[1];
												}
											}
										}
									}
								}
							}
						}
						// PLV-4711 - FIM
						System.debug('4DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));				
						List<RetornoPropostaRestTO.DevolutivasTO> lDevolutivas = ValidarOrcamentoProposta.validarExistenciaOrcamento(objPayload);
						System.debug('Retorno devolutiva2: ' + lDevolutivas); 
						System.debug('5DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
                        List<RetornoPropostaRestTO.DevolutivasTO> lDevolutivas2 = ValidaFavorecidos.validarExistenciaOrcamento(objPayload);
						System.debug('6DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
                        //PLV-3294 - Inicio
						List<RetornoPropostaRestTO.DevolutivasTO> lDevolutivas3 = ValidaInformacoesSegurados.ValidaInformacoes(objPayload);
                        System.debug('Retorno devolutiva3: '+lDevolutivas3);
						System.debug('7DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
                        //PLV-3294 - Fim
                        
                        System.debug('Retorno devolutiva2: ' + lDevolutivas2); 
						if(lDevolutivas == null && lDevolutivas2 != null) lDevolutivas = lDevolutivas2 ;

                        if(lDevolutivas == null || lDevolutivas.IsEmpty() && (lDevolutivas2 == null || lDevolutivas2.IsEmpty()) && lDevolutivas3 != null) lDevolutivas = lDevolutivas3;
                        //PLV-3294 - Fim
                        System.debug('8DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
                        System.debug('Retorno devolutiva: ' + lDevolutivas);
						if(lDevolutivas != null && !lDevolutivas.isEmpty()){	
							retorno.devolutivas = lDevolutivas;
						}else {
							propostaGerada = propostaGenerica.montarProposta(objPayload, null, true);
							System.debug('9DEBUG PAYLOAD >> '+ JSON.serialize(objPayload));
							System.debug('PropostaDirector - AccountId da Proposta: ' + propostaGerada.propostaWrapper.sfProposta.AccountId);
							// 2.2.S // 3285
							system.debug('!!propostaGerada: ' + JSON.serialize(propostaGerada));
							retorno = propostaGenerica.converterPropostaParaRetornoProposta(propostaGerada);
						}
						//PLV-2681 - Fim
						//PLV-2704 - Fim - Adição de possivel retorno
					}
					else if(tipo == SIGLA_ATUALIZAR_DEVOLUTIVA){// Caso seja uma proposta generica, com payload com numero de orcamento
						System.debug('EMISSAO GENERICA (atualiza status / DEVOLUTIVAS )');
						//PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
						if(objPayload.devolutivas == null || objPayload.devolutivas.isEmpty()){
							propostaGerada = propostaGenerica.atualizarStatusProposta(objPayload);
							retorno = propostaGenerica.converterPropostaParaRetornoProposta(propostaGerada);
						}else{
							System.debug('objPayload >>' + objPayload);
							propostasGeradas = propostaGenerica.atualizarStatusListaPropostas(objPayload);
							System.debug('PROPOSTAS GERADAS HENRIQUE: ' + propostasGeradas );
							retorno = propostaGenerica.converterListaPropostasParaRetorno(propostasGeradas);							
						}
						//PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
					}
					else{
						System.debug('EMISSAO GENERICA (numero de orcamento)'); 
						propostaGerada = propostaGenericaCancelamento.montarProposta(objPayload, null, true);
						retorno = propostaGenericaCancelamento.converterPropostaParaRetornoProposta(propostaGerada);
					}
					// FIM | PLV-2355-Hackathon
				}
			}
			// FIM | PLV 2234

			System.debug('RETORNO DA PROPOSTA ' + JSON.serialize(retorno));
			
            // System.debug(' @#$%$#$#@ objPayload:> ' + JSON.serialize(objPayload));
            // System.debug('objPayload.proposta.indice ' + objPayload.proposta.indice);
			// System.debug('objPayload.proposta ' + objPayload.proposta);
			//PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
			//system.debug('proposta TESTE'+objPayload.proposta);
			//VIAG-84 INICIO
			if(objPayload != null && objPayload.proposta != null && retorno !=null && retorno.proposta != null){
				retorno.proposta.indice = objPayload.proposta.indice;
			}
			//PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
			//VIAG-84 FIM
			return retorno;
       // AV-620 E AV-699 Inicio 
		} catch(Exception e) {
			// retorno.proposta.indice = objPayload.proposta.indice;
			System.debug(e.getMessage());
			throw new PropostaDirectorException('Erro: Mensagem: ' + e.getMessage() + ' Linha: ' + e.getLineNumber()  + '. StackTrace: '+e.getStackTraceString());
		}
       // AV-620 E AV-699 FIM

       
       
	}
    

	public class PropostaDirectorException extends Exception {}
}