/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//PLV-2418 - Início - Classe para atender as regras de negócio do objeto "Critica Proposta".
/**
 * @author AVX - Leonardo Camacho / Diogo Borges / Isabela Fin
 * @date 2019-07-11
 * @description Classe para atender as regras de negócio do objeto "Critica Proposta".
 */

public class CriticaPropostaBO {
	private final string CLASS_NAME = 'CriticaPropostaBO';
	//4591 - Inicio
	private final string STATUS_PENDENTE 			= 'Pendente';
	private final string STATUS_LIBERADO			= 'Liberado';
	private final string STATUS_RECUSADO 			= 'Recusado';
	private final string STATUS_CONDICIONADA		= 'Condicionada';
	private final string STATUS_PENDENCIADO			= 'Pendenciado';
	private final string STATUS_CANCELADA			= 'Cancelada';//PLV-4872 INICIO-FIM
	private final string STATUS_EMAPROVACAO			= 'Em aprovação';
	private final string SETOR_EMISSAO				= 'Emissão';
	private final string SETOR_ACEITACAO			= 'Aceitação';
	private final string MOMENTOANALISE_RESSEGURO	= 'Resseguro';
	private final string MOMENTOANALISE_SUBSCRICAO	= 'Subscrição';
	private final string MOMENTOANALISE_PALAVRAFINAL = 'Palavra Final';//PLV-5100 - INICIO/FIM
	private final string ACAOCRITICA_AUTO			= 'auto';
	private final string ACAOCRITICA_Video			= 'video';
	private final string ACAOCRITICA_Tele			= 'tele';
	//4591 - Fim	

	private final string MSG_ERRO_PALAVRAFINAL = 'Não é permitida a liberação da Palavra Final. Favor verificar as outras críticas.'; //PLV-5100 - INICIO/FIM

	public CriticaPropostaBO() { } 

	private static final CriticaPropostaBO instancia = new CriticaPropostaBO();

	public static CriticaPropostaBO getInstance(){
		return instancia;
	}

	//PLV-4517 INICIO 
	/*
    //Método para atribuir os registros de criticas de propostas para as Filas correspondentes
    public void atribuiProprietarioCriticaProposta(List<CriticaProposta__c> criticaProposta){
    	
    	Map<String, QueueSobject> mapFila = new Map<String, QueueSobject>();  

    	List<QueueSobject> listaFila = [SELECT QueueID, Queue.developerName 
								    	FROM QueueSObject 
								    	WHERE Queue.developerName IN ('FilaTecnica', 'FilaMedica', 'Fila_Coordenador') 
								    	ORDER BY Queue.developerName];


    	if(listaFila.isEmpty()) return;


    	for(QueueSObject sObj : listaFila){
    		mapFila.put(sObj.Queue.developerName, sObj);
    	}

    	for(CriticaProposta__c critica : criticaProposta){
    		if(critica.Tipo__c == 'Analise' || critica.Tipo__c == 'Pendencia'){

    			if(critica.Area__c == 'MED'){
    				System.debug('Dentro do IF : Area__c == MED');
    				critica.OwnerId = mapFila.get('FilaMedica').QueueID;
    			}
    			if(critica.Area__c != 'MED' && critica.Severidade__c == 1) {
    				System.debug('Dentro do IF: FilaTecnica - Severidade 1');
    				critica.OwnerId = mapFila.get('FilaTecnica').QueueID;
    			}
    			if(critica.Area__c != 'MED' && critica.Severidade__c > 1) {
    				System.debug('Dentro do IF: Fila_Coordenacao - Severidade > 1');
    				critica.OwnerId = mapFila.get('Fila_Coordenador').QueueID;
    			}		
    		}
    	}	
	}
	*/
	//PLV-4517 FIM
	// II-53 INICIO
	public void atualizarDataInicioPendencia(Map<Id, CriticaProposta__c> objetosAntigosMap, List<CriticaProposta__c> objetosAtualizados) {
		for (CriticaProposta__c critica : objetosAtualizados) {
			CriticaProposta__c criticaAntiga = objetosAntigosMap.get(critica.Id);
			if (critica.Status__c == 'Pendenciado' && critica.Status__c != criticaAntiga.Status__c) {
				critica.DataInicioPendencia__c = Date.today();
			}
		}
	}
	// II-53 FIM
	
	//PLV-5100 - INICIO
	public boolean validarLiberacaoPalavraFinal(Map<Id, CriticaProposta__c> mapCriticaNew) {
		
		Map<Id, CriticaProposta__c> propostasEcriticas = new Map<Id, CriticaProposta__c>();
		for (CriticaProposta__c c : (List<CriticaProposta__c>)mapCriticaNew.values()) {
			if (c.MomentoAnalise__c == MOMENTOANALISE_PALAVRAFINAL && c.Status__c == STATUS_LIBERADO) {
				propostasEcriticas.put(c.Proposta__c, c);
			}
		}
		List<CriticaProposta__c> criticasNaoResolvidas = [
					SELECT Id, Proposta__c
					FROM CriticaProposta__c 
					WHERE Proposta__c = :propostasEcriticas.keySet() AND 
						MomentoAnalise__c <> :MOMENTOANALISE_PALAVRAFINAL AND
						Status__c NOT IN (:STATUS_LIBERADO, :STATUS_CONDICIONADA, :STATUS_CANCELADA, :STATUS_RECUSADO)];
		
		if (criticasNaoResolvidas.size() > 0){
			CriticaProposta__c cpTrigger = propostasEcriticas.get(criticasNaoResolvidas[0].Proposta__c);
			cpTrigger.addError(MSG_ERRO_PALAVRAFINAL);
			return false; 	
		}
		
		return true;
	}
	//PLV-5100 - FIM
	
	//PLV-4179 and PLV- 4239 - INICIO    
	// PLV-4875 INICIO
	public void salvarCriticaPropostaIntegracaoAS(List<CriticaProposta__c> listCriticaNew, Map<Id, CriticaProposta__c> mapCriticaOld){	 
		//PLV-4588-INICIO
		List<CriticaProposta__c> listCriticaAS = new List<CriticaProposta__c>();
		Set<Id> setPropostaFinal = new Set<Id>();
		Map<Id, CriticaProposta__c> mapPropostaCriticaFinal = new Map<Id, CriticaProposta__c>();
		for(CriticaProposta__c critica : listCriticaNew){
			if(critica.MomentoAnalise__c == 'Palavra final'){
				setPropostaFinal.add(critica.Proposta__c);
				mapPropostaCriticaFinal.put(critica.Proposta__c, critica);
			}else{
				listCriticaAS.add(critica);
			}
		}

		for(Quote proposta : [SELECT Id, Tipo__c FROM Quote WHERE Id IN: setPropostaFinal]){
			if(proposta.Tipo__c != 'Cancelamento'){
				listCriticaAS.add(mapPropostaCriticaFinal.get(proposta.Id));
			}
		}

		IntegracaoAS.execute(listCriticaAS, mapCriticaOld);       
		//PLV-4588-FIM    
	} 
	// PLV-4875 FIM
	 //PLV-4179 and PLV- 4239 - FIM


    //PLV-4365 INICIO
	public void integrarSampleMed(List<CriticaProposta__c> criticasNew, Map<Id, CriticaProposta__c> criticasOldMap) {
		Set<Id> criticasIds = new Set<Id>();
		String fullFileURL = URL.getSalesforceBaseUrl().getAuthority(); //PLV 4879 Inicio/Fim

		//filtrando criticas
		for (CriticaProposta__c critica : criticasNew) {
			if (critica.Status__c == 'Pendente' 
				&& critica.Proposta__c != null 
				&& critica.Integracao__c == 'SAMPLE' 
				&& critica.MomentoAnalise__c == 'Subscrição'
				&& (criticasOldMap == null || critica.Status__c != criticasOldMap.get(critica.Id).Status__c)) {
					System.debug('Karin');
					System.debug(critica);
					criticasIds.add(critica.Id);
			}
		}

		if (criticasIds.size() > 0) { 
            //PLV-4644 INICIO
			//PLV 4879 Inicio
			// if(fullFileURL.substring(13, 19) != 'Sniper'){
				IntegracaoSampleMed.integrar(criticasIds, true);
			// }
			//PLV 4879 Fim			
            //PLV-4644 FIM
		}
	}
	//PLV-4365 FIM

    //PLV-4494 INICIO
    /*public void iniciaProcessoAprovacaoCriticaProposta(List<CriticaProposta__c> criticas){

    	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();

    	for (CriticaProposta__c critica : criticas){
    		if(critica.Tipo__c == 'Analise' || critica.Tipo__c == 'Pendencia'){
    			if(critica.Area__c == 'MED'){
    				//req1.setComments('Encaminhando requisição para aprovação');
    				req1.setObjectId(critica.id);
    				Approval.ProcessResult result = Approval.process(req1);
    				System.debug('ProcessResult: '+result);
				}else if(critica.Severidade__c == 1){
					req1.setComments('Encaminhando requisição para aprovação');
					req1.setObjectId(critica.id);
					Approval.ProcessResult result2 = Approval.process(req1);
					System.debug('ProcessResult: '+result2);
				}else if(critica.Severidade__c > 1){
					req1.setComments('Encaminhando requisição para aprovação');
					req1.setObjectId(critica.id);
					Approval.ProcessResult result3 = Approval.process(req1);
					System.debug('ProcessResult: '+result3);
				}
			}
		}
	}*/
    //PLV-4494 FIM
	
	//PLV-4449 - INÍCIO - PEDRO AUGUSTO BRAZ - SYS4B
	public void autorizarFormaDePagamento(Map<Id, CriticaProposta__c> mapCriticaNew, Map<Id, CriticaProposta__c> mapCriticaOld){
		//PLV-4790 FIX 12 - INÍCIO
		System.debug('MapCriticaOld: '+ mapCriticaOld);
		System.debug('MapCriticaNew: '+ mapCriticaNew);
		FormaPagamento__c formaPagamento;		

		if(!mapCriticaNew.isEmpty()){
			ContratanteProposta__c contratante;
			if(mapCriticaNew.values()[0].proposta__c != null){
				contratante = [SELECT Id, FormaPagamento__c, Proposta__r.Tipo__c, CartaoCredito__r.Mensagem__c, Proposta__r.PremioTotal__c FROM ContratanteProposta__c WHERE Proposta__c = :mapCriticaNew.values()[0].proposta__c LIMIT 1]; //PLV-5187 - INICIO/FIM    //PLV-5093 - INICIO/FIM
			}
			if(contratante != null && contratante.FormaPagamento__c != null){
				formaPagamento = [SELECT Id, Codigo__c FROM FormaPagamento__c WHERE Id = :contratante.FormaPagamento__c];				
			}
			System.debug('Contratante CriticaBO.... '+contratante);
			System.debug('Forma Pagto CriticaBO.... '+formaPagamento);

			//PLV-5187 - INICIO
			Boolean isEndossoCadBen = false;
			if(contratante.Proposta__r.Tipo__c == 'Endosso' && contratante.Proposta__r.PremioTotal__c == 0) 
				isEndossoCadBen = true;						
			
			if((formaPagamento != null && (formaPagamento.Codigo__c == '62' || formaPagamento.Codigo__c == '97' || formaPagamento.Codigo__c == '70' || formaPagamento.Codigo__c == '98')) && !isEndossoCadBen){//TKCL-358 INICIO-FIM //RVI-294
			//PLV-5187 - FIM														
			//PLV-4790 FIX 12 - FIM

				Map<String,List<CriticaProposta__c>> toAutorizar = new Map<String,List<CriticaProposta__c>>();
				Map<String,List<CriticaProposta__c>> toAutorizarFiltrado = new Map<String,List<CriticaProposta__c>>();
				Set<Id> setOK = new Set<Id>();
				//Primeiro filtro, verificar se existem criticas que querem autorizar cartao de credito

				System.debug('PEDRO >>> mapCriticaOld '+mapCriticaOld.values());
				System.debug('PEDRO >>> mapCriticaOld '+mapCriticaOld.values().size());
				for(CriticaProposta__c critica : mapCriticaOld.values()){
					System.debug('PEDRO >>> MomentoAnalise '+critica.MomentoAnalise__c);
                    System.debug('PEDRO >>> MomentoAnalise New '+mapCriticaNew.get(critica.Id).MomentoAnalise__c);
                    //PLV-4854-FIX1 - inicio	
					//if( (critica.MomentoAnalise__c =='Palavra Final' || mapCriticaNew.get(critica.Id).MomentoAnalise__c =='Palavra Final') && (critica.Status__c=='Pendente' || critica.Status__c=='Não iniciada' || critica.Status__c=='Falha na Integração') && mapCriticaNew.get(critica.Id).Status__c =='Liberado' ){				
                    if( (critica.MomentoAnalise__c =='Palavra Final' || mapCriticaNew.get(critica.Id).MomentoAnalise__c =='Palavra Final') && mapCriticaNew.get(critica.Id).Status__c =='Liberado' ){ //PLV-5240 Inicio/Fim
						System.debug('toAutorizar entrou'+ toAutorizar);
						if(!toAutorizar.containsKey(critica.Proposta__c)) toAutorizar.put(critica.Proposta__c,new List<CriticaProposta__c>());
						System.debug('toAutorizar teste ><>'+ toAutorizar);
						System.debug('PEDRO >>> critica.Proposta__c '+critica.Proposta__c);
                        toAutorizar.get(critica.Proposta__c).add(mapCriticaNew.get(critica.Id));						
						setOK.add(critica.id);
						mapCriticaNew.get(critica.Id).Status__c = critica.Status__c;
						CriticaProposta__c criticaNew = mapCriticaNew.get(critica.Id);

						
						//PLV-5093 - INICIO
						if(contratante.CartaoCredito__r.Mensagem__c == 'REJEITADO' && (critica.MomentoAnalise__c =='Palavra Final' || mapCriticaNew.get(critica.Id).MomentoAnalise__c =='Palavra Final')){
							criticaNew.addError('O cartão cadastrado é inválido.');
						}
						//PLV-5093 - FIM
						System.debug('Rogerio >>> criticaNew '+criticaNew);
					}					
                    //PLV-4854-FIX1 - fim
				}
				
				//Filtro 2 Somente pode-se mandar para autorização se a cotação possuir apenas
				Map<Id,List<CriticaProposta__c>> mapProposta2critica = new Map<Id,List<CriticaProposta__c>>();
				List<CriticaProposta__c> toFilter = [SELECT Id, Status__c, Proposta__c, MomentoAnalise__c FROM CriticaProposta__c WHERE ID NOT IN: setOK AND Proposta__c IN: toAutorizar.keyset() AND (Status__c='Pendente' OR Status__c='Em aprovação' OR Status__c='Falha na Integração')]; //PLV-4854-FIX8

				System.debug('PEDRO >>> toFilter '+toFilter);
				System.debug('PEDRO >>> toFilter '+toFilter.size());
				System.debug('PEDRO >>> toAutorizar 1 '+toAutorizar);
				
				for(CriticaProposta__c cp : toFilter){										
					
					if(toAutorizar.containsKey(cp.Proposta__c)) { 
						toAutorizar.remove(cp.Proposta__c);
						setOK.remove(cp.Id);
					}				
				}
				
				System.debug('PEDRO >>> toAutorizar '+toAutorizar);
				System.debug('PEDRO >>> toAutorizar '+toAutorizar.size());
				System.debug('PEDRO >>> setOK '+setOK);
				
				if(toAutorizar.values().size()>0){
					System.debug('PEDRO >>> entrou ');
					List<CriticaProposta__c> toSend = [SELECT Id
					, Name
					, Proposta__c
					, Proposta__r.Tipo__c
					FROM CriticaProposta__c
					WHERE Id IN:setOK]; 

					Map<Id,Quote> mapProposta = new Map<Id,Quote>([SELECT Id
					,NumeroPropostaUnico__c
					,Tipo__c
					//PLV-4992 FIX 1 - INÍCIO
					,Modalidade__c 
					,Modalidade__r.Codigo__c 
					,RamoSeguro__c 
					,RamoSeguro__r.Codigo__c 
					,Produto__r.CodigoPrecificaProduto__c //TKCL-358 INICIO-FIM
					//PLV-4992 FIX 1 -FIM	
					,Produto__r.Empresa__r.CodigoEmpresa__c	 //TKCL-473 INICIO-FIM			
					, ( SELECT Id
						, QuantidadeParcelas__c
						, PremioTotal__c
						, Valor_PrimeiraParcela__c //TKCL-473 INICIO-FIM
						, Valor_DemaisParcelas__c //TKCL-473 INICIO-FIM
						, Recorrencia__c //TKCL-473 INICIO-FIM
						, CartaoCredito__r.Ticket__c
						, CartaoCredito__r.VencimentoCriptografado__c
						, CartaoCredito__r.NomeTitular__c //PLV-4992 FIX 1 - INÍCIO/FIM
						, Conta__r.RecordTypeId
						, Conta__r.CPF__c
						, Conta__r.CNPJ__c 
						, FormaPagamento__r.Codigo__c //ANNVI-48 - INICIO/FIM
						FROM Contratantesproposta__r) 
					FROM Quote WHERE Id IN:toAutorizar.keySet()]);
					System.debug('mapProposta' + JSON.serialize(mapProposta)); 

					for(CriticaProposta__c c : toSend){
						if(mapProposta.containsKey(c.Proposta__c))
						c.Proposta__r = mapProposta.get(c.Proposta__c);
					}
					enviarAutorizacao(JSON.serialize(toSend));
					System.debug('PEDRO >>> JSON.serialize(toSend) '+JSON.serialize(toSend));
				}
            } //PLV-4790 FIX 12 - INÍCIO/FIM
            //FCVEP-33 INICIO
			else if (isFormaPagamentoValido(formaPagamento)) {
				System.debug('entrou else rogerio teste flow ');
				for (CriticaProposta__c critica : mapCriticaNew.values()) {			
					if (isCriticaValida(critica)) {
						gerarPix(critica.Proposta__c);
					}
				}
			}
            //FCVEP-33 FIM
		} //PLV-4790 FIX 12 - INÍCIO/FIM
	}
    
    //FCVEP-33 INICIO
	private static Boolean isFormaPagamentoValido(FormaPagamento__c formaPagamento) {
		return formaPagamento != null && (formaPagamento.Codigo__c == '52' || formaPagamento.Codigo__c == '21');
	}
	
	private static Boolean isCriticaValida(CriticaProposta__c critica) {
		return critica.MomentoAnalise__c == 'Palavra Final' 
				&& critica.Status__c == 'Pendente';
	}
	
	@Future(Callout=true)
	public static void gerarPix(Id propostaId) {

		Quote proposta = obterProposta(propostaId);
		if (proposta == null || proposta.Tipo__c != 'Novo') return;

		ContratanteProposta__c contratante = obterContratante(proposta);
		if (contratante == null) return;

		Decimal primeiraParcela = calcularPrimeiraParcela(contratante);
		String codigoModalidade = obterCodigoModalidade(proposta);
		Map<String, Object> jsonMap = criarJsonPix(proposta, contratante, primeiraParcela, codigoModalidade);
		String retorno;

		System.Debug('JSON ENVIADO--->'+jsonMap);
		try{
			retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.SOLICITACAO_PAGAMENTO_PIX, JSON.serialize(jsonMap));
			if(retorno != 'Erro na requisição'){
				System.Debug('RETORNO--->'+retorno);
				IntegracaoAS.inserirHistoricoAS(new Set<Id>{proposta.Id});
			}	
		} catch(Exception ex){
			System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage() + ' st=' +ex.getStackTraceString());
		}

	}
	
	private static Quote obterProposta(Id propostaId) {
		List<Quote> propostas = [SELECT Id, NumeroPropostaUnico__c, Empresa__r.CodigoEmpresa__c, RamoSeguro__r.Codigo__c, Origem__c, NumeroProposta__c, Tipo__c 
								 FROM Quote 
								 WHERE Id =: propostaId];
		return propostas.isEmpty() ? null : propostas[0];
	}
	
	private static ContratanteProposta__c obterContratante(Quote proposta) {
		List<ContratanteProposta__c> contratantes = [SELECT PremioTotal__c, QuantidadeParcelas__c, Conta__r.Cpf__c, Conta__r.Name, Conta__r.PersonEmail
													 FROM ContratanteProposta__c
													 WHERE Proposta__r.Origem__c =: proposta.Origem__c
													 AND Proposta__r.NumeroProposta__c =: proposta.NumeroProposta__c
													 LIMIT 1];
		return contratantes.isEmpty() ? null : contratantes[0];
	}
	
	private static Decimal calcularPrimeiraParcela(ContratanteProposta__c contratante) {
		Decimal valorParcela = (contratante.PremioTotal__c / contratante.QuantidadeParcelas__c).setScale(2, RoundingMode.FLOOR);
		return contratante.PremioTotal__c - ((contratante.QuantidadeParcelas__c - 1) * valorParcela);
	}
	
	private static String obterCodigoModalidade(Quote proposta) {
		Set<String> validRamos = new Set<String>{'1381', '1391'};
		if (proposta.Empresa__r.CodigoEmpresa__c == '1') {
			return proposta.RamoSeguro__r.Codigo__c == '1391' ? '20' : '24';
		} else if (proposta.Empresa__r.CodigoEmpresa__c == '14' && validRamos.contains(proposta.RamoSeguro__r.Codigo__c)) {
			return '14';
		}
		return null;
	}
	
	private static Map<String, Object> criarJsonPix(Quote proposta, ContratanteProposta__c contratante, Decimal primeiraParcela, String codigoModalidade) {
		return new Map<String, Object>{
			'codProduto' => 'b2337254-5eaf-4438-b814-396599736283',
			'idExterno'  => proposta.NumeroPropostaUnico__c,
			'metadados'  => new Map<String, Object>{
				'tipo_documento_comercial'    => '01',
				'endosso'                     => '',
				'codigo_empresa'              => proposta.Empresa__r.CodigoEmpresa__c,
				'composicao_valor_parcela'     => '01',
				'codigo_ramo'                 => proposta.RamoSeguro__r.Codigo__c,
				'parcela'                     => '',
				'contrato_comercial'          => '',
				'evento_emissao'              => '1',
				'flag_sinalizador_processo'    => 'O',
				'flag_produto_seguro'         => 'S',
				'codigo_agregador'            => '',
				'codigo_modalidade'           => codigoModalidade
			},
			'cobrancas' => new List<Map<String, Object>>{
				new Map<String, Object>{
					'meioPagamento' => 'PIX',
					'valor'         => primeiraParcela,
					'pix'           => new Map<String, Object>{
						'tipoTransacao' => 'VENCIMENTO_VARIAVEL',
						'cliente'       => new Map<String, Object>{
							'documento' => new Map<String, String>{ 'tipo' => 'CPF', 'numero' => contratante.Conta__r.Cpf__c },
							'nome'      => contratante.Conta__r.Name,
							'email'     => contratante.Conta__r.PersonEmail
						},
						'expiracao' => 604800
					}
				}
			}
		};
	}
    //FCVEP-33 FIM
	
    @Future(Callout=true)
    public static void enviarAutorizacao(String criticas){
		List<CriticaProposta__c> listCriticas = (List<CriticaProposta__c>) JSON.deserialize(criticas, List<CriticaProposta__c>.class);
		
		System.debug('PEDRO >>> criticas '+criticas);
		System.debug('PEDRO >>> criticas '+listCriticas.size());
        if(listCriticas.isEmpty() || listCriticas.size()>50){
			throw new AuraHandledException('Lista vazia ou possui mais que 50 registros para integração');
        }else{
			ServiceTO.CobrancaCartaoOfflineTO cobranca = new ServiceTO.CobrancaCartaoOfflineTO();
			List<CriticaProposta__c> toUpdate = new List<CriticaProposta__c>();
            for(CriticaProposta__c cr : listCriticas){
				System.debug('cobrança antes> ' + cobranca);

                cobranca.dtoCobranca(cr); 
				String validacao = cobranca.validar(); 
				System.debug('validacao> ' + validacao);
				System.debug('cobrança depois> ' + cobranca);
				if(String.isBlank(validacao)){
					System.debug('cob antes do civ > '+ cobranca );

					// MGRC-1254 - INICIO
					// CIVServices.getInstance().integracaoCartaoOffline(cobranca);
					try{//ANNVI-48 - INICIO
						SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, SensediaServices.COBRANCA_CARTAO_OFFLINE, JSON.serialize(cobranca, true));
					}catch(Exception e){
						CriticaProposta__c c = new CriticaProposta__c(Id=cr.Id);
						c.MensagemInterna__c = validacao;
						c.Status__c = 'Falha na Integração';
						DateTime now = System.now();
						c.ErrosRecalculo__c  =  now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + validacao + '\n'+(c.ErrosRecalculo__c == null ? '' : c.ErrosRecalculo__c);                      
						toUpdate.add(c);						
					}//ANNVI-48 - FIM
					// MGRC-1254 - FIM

					System.debug('Entrada civ' + cobranca);
				}else{					
					if(cr.Proposta__r.Tipo__c != 'Cancelamento'){															
						System.debug('cr.Proposta__r.Tipo__c');
						System.debug(cr.Proposta__r.Tipo__c);
						CriticaProposta__c c = new CriticaProposta__c(Id=cr.Id);
						c.MensagemInterna__c = validacao; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
						//PLV-4854-FIX6 - inicio
						c.Status__c = 'Falha na Integração';
						DateTime now = System.now();
						c.ErrosRecalculo__c  =  now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + validacao + '\n'+(c.ErrosRecalculo__c == null ? '' : c.ErrosRecalculo__c); //PLV-4854-FIX1 - inicio/fim                            
						//PLV-4854-FIX6 - fim
						toUpdate.add(c);
					} 					
				}
			}
			system.debug('toUpdate> ' + toUpdate);
			CriticaPropostaTriggerHandler.isFirstTime = false;
			update toUpdate;
			CriticaPropostaTriggerHandler.isFirstTime = true;
        }
        
    }
	
	
	
	//PLV-4619-VI - Inicio - Isabela Fin - Globant
	//PLV-4564-VI - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
	public void criarCriticaRecalculo(Map<Id, CriticaProposta__c> mapCriticaNew, Map<Id, CriticaProposta__c> mapCriticaOld){
		
		System.debug('PEDRO >>> mapCriticaOld '+mapCriticaOld.values());
		System.debug('PEDRO >>> mapCriticaOld '+mapCriticaOld.values().size());
		System.debug('PEDRO >>> mapCriticaNew '+mapCriticaNew.values());
		System.debug('PEDRO >>> mapCriticaNew '+mapCriticaNew.values().size());
		//PLV-5311-FIX INICIO
		//Lista de códigos de criticas de recalculo que na verdade não devem ser consideradas para validação
		//List<string> codigosRecalc = new List<string>{'3','4','17','18','19','20','21','22','30','31','34','36','37','60','61','62','63','64','66','67','68','97','99','103','104','105','106','108','110','121', '122'}; 
		//PLV-5311-FIX FIM
		//pegar todas as propostas que estão passando na trigger
		List<CriticaProposta__c> criticasCondicionadas = new List<CriticaProposta__c>();
		Map<Id,List<CriticaProposta__c>> mapPropostaxCritica = new Map<Id,List<CriticaProposta__c>>();
		
		for(CriticaProposta__c cr : mapCriticaNew.values()){
			if(cr.Proposta__c==null || cr.Status__c == mapCriticaOld.get(cr.Id).Status__c) continue;
			if(cr.Status__c == 'Condicionada'){
				if(!mapPropostaxCritica.containsKey(cr.Proposta__c)) mapPropostaxCritica.put(cr.Proposta__c, new List<CriticaProposta__c>());
				mapPropostaxCritica.get(cr.Proposta__c).add(cr);
			}
		}

		System.debug('GIOR >>> mapPropostaxCritica '+mapPropostaxCritica);

		List<CriticaProposta__c> criticasToDML = new List<CriticaProposta__c>();
		List<CriticaProposta__c> cpList = [SELECT Id, Proposta__c, Codigo__c, Setor__c, Status__c, MomentoAnalise__c, Tipo__c FROM CriticaProposta__c //PLV-5311 INICIO/FIM
										  WHERE Proposta__c IN :mapPropostaxCritica.keySet()];//PLV-5311-FIX INICIO/FIM

										  
		//List<Quote> lDocusign =  [SELECT Id FROM Quote WHERE RealizarEnvioDocusign__c = false AND Id =:mapPropostaxCritica.keySet()]; //PLV-5403 INICIO/FIM
		//II-42 INICIO FIX01
		List<Quote> lDocusign = new List<Quote>();
		if (!mapPropostaxCritica.isEmpty()) {
			lDocusign = [SELECT Id FROM Quote WHERE RealizarEnvioDocusign__c = false AND Id IN :mapPropostaxCritica.keySet()]; //PLV-5403 INICIO/FIM
		}
		//II-42 FIM FIX01

		System.debug('GIOR >>> lDocusign '+ lDocusign);
		System.debug('GIOR >>> cpList '+ cpList);
		// PLV-5311 INICIO FIX
		// for(CriticaProposta__c cp: cpList){
		// 	if(mapPropostaxCritica.containsKey(cp.Proposta__c)){				
		// 		//PLV-5311-FIX INICIO
		// 		/*if(!codigosRecalc.contains(cp.Codigo__c)){
		// 			System.debug('Entrou no if do contains '+ cp.Codigo__c);
		// 			mapPropostaxCritica.remove(cp.Proposta__c);
		// 		}*/
		// 		//PLV-5311-FIX FIM
		// 		if(cp.Setor__c == 'Emissão'){
		// 			cp.Setor__c = 'Aceitação';
		// 			criticasToDML.add(cp);
		// 		}
		// 	}
		// }
		// PLV-5311 FIM FIX

		// ********************* RVI 290 - INICIO ************************ //
		for(Id pId : mapPropostaxCritica.keyset()){
			CriticaProposta__c cp = new CriticaProposta__c();
			cp.Proposta__c = pId; 
			cp.Status__c = 'Pendente'; //PLV-5311 INICIO/FIM
			cp.Origem__c = 'Salesforce';
			cp.MomentoAnalise__c = 'Recalculo';
			cp.Setor__c = 'Emissão';
			cp.Tipo__c = 'Analise';
			cp.Codigo__c = '172'; //PLV-4790 FIX 9
			cp.integracao__c = ''; //PLV-5403 INICIO/FIM //PLV-5311 INICIO/FIM
			cp.Descricao__c = 'Código 0172 - Recálculo de proposta condicionada'; //PLV-4790 FIX 9 //PLV-5311 INICIO/FIM
			lDocusign[0].RealizarEnvioDocusign__c = true; //PLV-5403 INICIO/FIM
			criticasToDML.add(cp);	
		}
		// ********************* RVI 290 - FIM ************************ /
		System.debug('GIOR >>> criticasToDML'+criticasToDML);
		if(!criticasToDML.isEmpty()){
			CriticaPropostaTriggerHandler.isFirstTime = false;
			upsert criticasToDML;
			update lDocusign; //PLV-5403 INICIO/FIM
			CriticaPropostaTriggerHandler.isFirstTime = true;
			System.debug(' upsert - '+ criticasToDML);
		}
	}
	//PLV-4564-VI - FIM - PEDRO AUGUSTO BRAZ - SYS4B
	//PLV-4619-VI - Fim - Isabela Fin - Globant
	      
    //PLV-4591 - INICIO
    public void verificarStatusSLACritica(List<CriticaProposta__c> ltNovasCriticas, Map<id, CriticaProposta__c> mpAntigasCriticas){ 
		String METHOD_NAME = 'verificarStatusSLACritica';
		date 	diaExecucao						= system.today();
		integer diafimPendenteAceitacao 		= 2;
		integer diafimPendenteEmissao 			= 6;
		integer diafimPendenteSubscricaoAuto	= 4;
		integer diafimPendenteSubscricaoVideo	= 5;
		integer diafimPendenciadaEmissao 		= 2;

        for(CriticaProposta__c criticaLoop : ltNovasCriticas){
            CriticaProposta__c criticaAntiga = mpAntigasCriticas.get(criticaLoop.Id);
            //Caso 1
			//PLV-5111 - INICIO
			System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => criticaLoop.Status__c: ' + criticaLoop.Status__c);
			System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => criticaLoop.Setor__c: ' + criticaLoop.Setor__c);
			System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => criticaAntiga.Status__c: ' + criticaAntiga.Status__c);
			//PLV-5111 - FIM
            if(criticaLoop.Status__c == STATUS_PENDENTE  && criticaLoop.Setor__c == SETOR_ACEITACAO && criticaAntiga.Status__c != STATUS_PENDENTE){
                criticaLoop.DataInicioAnalise__c = retornarDiaUtil(diaExecucao.addDays(0));//PLV-4854-FIX3 inicio/fim
				criticaLoop.Data_Limite_fim_da_analise__c = (criticaLoop.DataInicioAnalise__c).addDays(diafimPendenteAceitacao);//PLV-4872 INICIO-FIM                
            //Caso 2    
            }else if(criticaLoop.Status__c == STATUS_PENDENTE  && criticaLoop.Setor__c == SETOR_EMISSAO && criticaAntiga.Status__c != STATUS_PENDENTE){
                criticaLoop.DataInicioAnalise__c = retornarDiaUtil(diaExecucao.addDays(0));//PLV-4854-FIX3 inicio/fim
				criticaLoop.Data_Limite_fim_da_analise__c = (criticaLoop.DataInicioAnalise__c).addDays(diafimPendenteEmissao);//PLV-4872 INICIO-FIM              
            //Caso 3
			}
			// INICIO | PLV-4647-VI-Guilherme Brito
			else if(criticaLoop.Status__c == STATUS_PENDENTE  && criticaLoop.MomentoAnalise__c == MOMENTOANALISE_SUBSCRICAO && criticaAntiga.MomentoAnalise__c != MOMENTOANALISE_SUBSCRICAO && (criticaLoop.Acao__c.containsIgnoreCase(ACAOCRITICA_AUTO) || criticaLoop.Acao__c.containsIgnoreCase(ACAOCRITICA_TELE))){
                criticaLoop.DataInicioAnalise__c = retornarDiaUtil((diaExecucao));
				criticaLoop.Data_Limite_fim_da_analise__c = (criticaLoop.DataInicioAnalise__c).addDays(diafimPendenteSubscricaoAuto);//PLV-4872 INICIO-FIM
            //Caso 4    
			}
			else if(criticaLoop.Status__c == STATUS_PENDENTE  && criticaLoop.MomentoAnalise__c == MOMENTOANALISE_SUBSCRICAO && criticaAntiga.MomentoAnalise__c != MOMENTOANALISE_SUBSCRICAO && criticaLoop.Acao__c.containsIgnoreCase(ACAOCRITICA_VIDEO)){
				criticaLoop.DataInicioAnalise__c = retornarDiaUtil((diaExecucao));
				criticaLoop.Data_Limite_fim_da_analise__c = (criticaLoop.DataInicioAnalise__c).addDays(diafimPendenteSubscricaoVideo);//PLV-4872 INICIO-FIM
				//Caso 5   
			}
			// FIM| PLV-4647-VI-Guilherme Brito
			else if(criticaLoop.Status__c == STATUS_PENDENCIADO && criticaLoop.Setor__c == SETOR_EMISSAO && criticaAntiga.Status__c != STATUS_PENDENCIADO){
                criticaLoop.DataInicioPendencia__c = retornarDiaUtil((diaExecucao).addDays(0));//PLV-4854-FIX3 inicio/fim
				criticaLoop.Data_Limite_fim_da_analise__c = (criticaLoop.DataInicioPendencia__c).addDays(diafimPendenciadaEmissao);//PLV-4872 INICIO-FIM
			} 
            
        }
		//this.processarOrcamentoPorCritica(ltNovasCriticas, mpAntigasCriticas); //PLV-4592 INICIO/FIM
    }

	//PLV-4872 INICIO
	public void gravaDataFimAnalise(List<CriticaProposta__c> ltNovasCriticas, Map<id, CriticaProposta__c> mpAntigasCriticas){
		for (CriticaProposta__c criticaTemp : ltNovasCriticas) {
			CriticaProposta__c	criticaAntiga 	= mpAntigasCriticas.get(criticaTemp.Id);
			if (criticaAntiga.Status__c != STATUS_LIBERADO && criticaAntiga.Status__c != STATUS_RECUSADO && criticaAntiga.Status__c != STATUS_CONDICIONADA && criticaAntiga.Status__c != STATUS_CANCELADA &&					
			(criticaTemp.Status__c 	== STATUS_LIBERADO || criticaTemp.Status__c == STATUS_RECUSADO || criticaTemp.Status__c == STATUS_CONDICIONADA|| criticaTemp.Status__c == STATUS_CANCELADA)) {
				criticaTemp.DataFimAnalise__c = retornarDiaUtil(system.today()); //PLV-4995-FIX4 - INICIO/FIM
			}
		}
	}

	public void gravaDataInicioResseguro(List<CriticaProposta__c> ltNovasCriticas, Map<id, CriticaProposta__c> mpAntigasCriticas){
		for (CriticaProposta__c criticaTemp : ltNovasCriticas) {
			CriticaProposta__c	criticaAntiga 	= mpAntigasCriticas.get(criticaTemp.Id);
			if (criticaAntiga.Status__c == STATUS_PENDENTE && criticaTemp.MomentoAnalise__c == MOMENTOANALISE_RESSEGURO && criticaTemp.Status__c == STATUS_EMAPROVACAO ) {
				criticaTemp.Data_inicio_resseguro__c = retornarDiaUtil(system.today()); //PLV-4995-FIX4 - INICIO/FIM
			}
		}
	}
	public void gravaDatafimResseguro(List<CriticaProposta__c> ltNovasCriticas, Map<id, CriticaProposta__c> mpAntigasCriticas){
		for (CriticaProposta__c criticaTemp : ltNovasCriticas) {
			CriticaProposta__c	criticaAntiga 	= mpAntigasCriticas.get(criticaTemp.Id);
			if (criticaAntiga.Status__c == STATUS_EMAPROVACAO && criticaTemp.MomentoAnalise__c == MOMENTOANALISE_RESSEGURO && 
			(criticaTemp.Status__c 	== STATUS_LIBERADO || criticaTemp.Status__c == STATUS_RECUSADO || criticaTemp.Status__c == STATUS_CONDICIONADA|| criticaTemp.Status__c == STATUS_CANCELADA)) {
				criticaTemp.Data_fim_resseguro__c = retornarDiaUtil(system.today()); //PLV-4995-FIX4 - INICIO/FIM
			}
		}
	}

	public void gravarDataRecusa(List<CriticaProposta__c> ltNovasCriticas){
		for (CriticaProposta__c criticaTemp : ltNovasCriticas) {
			if(criticaTemp.Status__c == STATUS_RECUSADO){
				criticaTemp.DataFimAnalise__c = system.today();
			}
		}
	}
	
	//PLV-4977 - INICIO	
	public void gravarSegmentoNaProposta(List<CriticaProposta__c> lsNewCriticas){
		System.debug('ENTROU NO METÓDO HENRIQUE');
		System.debug('HENRIQUE lsNewCriticas: ' +lsNewCriticas);
		Set<Id> setIdPropostas = new Set<Id>();
		Map<Id, Quote> mapQuote = new Map<Id, Quote>();
		for(CriticaProposta__c critica : lsNewCriticas){
			if(critica.MomentoAnalise__c == 'Análise interna' && !mapQuote.containsKey(critica.Proposta__c)){
				System.debug('ENTROU PRIMEIRO IF HENRIQUE');
				if(critica.Setor__c == 'Emissão'){
					setIdPropostas.add(critica.Proposta__c);
				}
				else{
					System.debug('ENTROU PRIMEIRO ELSE HENRIQUE');
					Quote proposta = new Quote (Id = critica.Proposta__c, isFullEmissao__c = false);
					mapQuote.put(proposta.Id, proposta);
					setIdPropostas.remove(proposta.Id);		
				}
			}
		}
		List<Quote> propostas = mapQuote.values();
		if(setIdPropostas.size() > 0){
			System.debug('ENTROU NO SEGUNDO IF');
			Map<Id, Quote> mapQuoteUpdate = new Map<Id, Quote>();

			for(CriticaProposta__c critica :[SELECT Id, Name, Setor__c, MomentoAnalise__c, Proposta__c 
									FROM CriticaProposta__c 
									WHERE Proposta__c in:setIdPropostas AND MomentoAnalise__c = 'Análise interna']){
				Quote proposta = null;
				if(critica.Setor__c == 'Emissão'){
					proposta = new Quote (Id = critica.Proposta__c, isFullEmissao__c = true);
					if(mapQuoteUpdate.containskey(critica.Proposta__c)){
						proposta = mapQuoteUpdate.get(critica.Proposta__c);
					}
					proposta.isFullEmissao__c = proposta.isFullEmissao__c;
				}
				else {
					proposta = new Quote (Id = critica.Proposta__c, isFullEmissao__c = false);
				}
				mapQuoteUpdate.put(proposta.Id, proposta);
			}
			propostas.add(mapQuoteUpdate.values());
		}
		update propostas;
	}
	//PLV-4977 - FIM

	//PLV-5077 - INICIO	
	public void distribuicaoCriticas(List<CriticaProposta__c> lsAttCriticas, Map<id, CriticaProposta__c> mpAntigasCriticas){
		Set<Id> setIdPropostas = new Set<Id>();
		Set<Id> setIdPropostasLiberada = new Set<Id>();
		Set<Id> SetIdQuoteAceitacaoLiberada = new Set<Id>();
		QueueSObject filaEmissao = [SELECT QueueID FROM QueueSObject WHERE SobjectType = 'CriticaProposta__c' AND Queue.developerName = 'Filaemissao'];
		for(CriticaProposta__c critica : lsAttCriticas){
			CriticaProposta__c criticaOld = mpAntigasCriticas.get(critica.Id);
			if(critica.MomentoAnalise__c == 'Análise interna'){
				if(critica.Status__c == 'Condicionada' && critica.Setor__c == 'Emissão' && (critica.Status__c != criticaOld.Status__c || critica.Setor__c != criticaOld.Setor__c)){
					setIdPropostas.add(critica.Proposta__c);
					critica.OwnerId = filaEmissao.QueueID;
				}
				else if (critica.Status__c == 'Liberado' && critica.Setor__c == 'Aceitação'){
					setIdPropostas.add(critica.Proposta__c);
					setIdPropostasLiberada.add(critica.Proposta__c);
					SetIdQuoteAceitacaoLiberada.add(critica.Proposta__c);
				}
			} 
		}
		Map<Id, Quote> mapQuoteUpdate = new Map<Id, Quote>();
		Set<Id> SetIdQuoteHaveEmissao = new Set<Id>();
		Set<Id> SetIdQuoteAceitacaoNaoLiberada = new Set<Id>();
		//II-42 INICIO FIX01
		List<CriticaProposta__c> selectCriticas = [SELECT Id, Name, Setor__c, MomentoAnalise__c, Proposta__c, Status__c
											FROM CriticaProposta__c WHERE Id NOT IN: mpAntigasCriticas.keyset() AND Proposta__c IN:setIdPropostas AND MomentoAnalise__c = 'Análise interna'];
		for(CriticaProposta__c critica : selectCriticas){//II-42 FIM FIX01
			if(critica.Setor__c == 'Emissão'){
				if(setIdPropostasLiberada.contains(critica.Proposta__c)){
					SetIdQuoteHaveEmissao.add(critica.Proposta__c);	
				}
				else{
					Quote proposta = new Quote (Id = critica.Proposta__c, isFullEmissao__c = true);
					if(!mapQuoteUpdate.containskey(critica.Proposta__c)){
						mapQuoteUpdate.put(proposta.Id, proposta);
					}
				}
			}
			else if(critica.Setor__c == 'Aceitação'){
				if(critica.Status__c == 'Liberado' && !SetIdQuoteAceitacaoNaoLiberada.contains(critica.Proposta__c)){
					SetIdQuoteAceitacaoLiberada.add(critica.Proposta__c);	
				}
				else{
					SetIdQuoteAceitacaoNaoLiberada.add(critica.Proposta__c);
					SetIdQuoteAceitacaoLiberada.remove(critica.Proposta__c);
					Quote proposta = new Quote (Id = critica.Proposta__c, isFullEmissao__c = false);
					mapQuoteUpdate.put(proposta.Id, proposta);	
				}
			}
		}
		for(Id idQuote : SetIdQuoteAceitacaoLiberada){
			if(!SetIdQuoteAceitacaoNaoLiberada.contains(idQuote) && SetIdQuoteHaveEmissao.contains(idQuote)){
				Quote proposta = new Quote (Id = idQuote, isFullEmissao__c = true);	
				mapQuoteUpdate.put(proposta.Id, proposta);
			}
		}
		update mapQuoteUpdate.values();

	}
	//PLV-5077 - FIM

    //PLV-4872 FIM
	private static Date retornarDiaUtil(Date data){
        DateTime diaAtual = DateTime.newInstance(data, Time.newInstance(0,0,0,0)); //PLV-4995-FIX4 - INICIO/FIM
        integer numeroDiaSemana = Integer.valueOf(diaAtual.format('u'));
        system.debug('Número dia da Semana = ' + numeroDiaSemana);
        if(numeroDiaSemana == 6 ){
            return data.addDays(2);
            
        }else if(numeroDiaSemana == 7){
            return data.addDays(1);
            
        }else{
            return data;
            
        }
    }
	//PLV-4591 - FIM
	
	//PLV-4592 - Inicio
	public void processarOrcamentoPorCritica(List<CriticaProposta__c> ltNovasCriticas, Map<id, CriticaProposta__c> mpAntigasCriticas){
		Date 								diaExecucao			= system.today();
		Set<Id> 							stPropostas			= new Set<Id>();
		//PLV-4495 - INICIO
		Map<Id, Quote>                      mapPropostaUpdate   = new Map<Id, Quote>(); 
		//PLV-4495 - FIM
		Map<Id,Quote> 						mpPropostas 		= new Map<Id,Quote>();
		Map<Id,Quote> 						mpPropostasOLD 		= new Map<Id,Quote>();//PLV-5022 - INICIO/FIM
		Map<Id,Quote> 						mpPropostashistorico	= new Map<Id,Quote>();//PLV-5022 - INICIO/FIM
		Map<Id,List<CriticaProposta__c>>	mpPropostaCritica 	= new Map<Id,List<CriticaProposta__c>>();

		for(CriticaProposta__c criticaLoop : ltNovasCriticas){
			if(criticaLoop.Proposta__c != null){
				stPropostas.add(criticaLoop.Proposta__c);
			}
		}
		//PLV-4872 INICIO
		List<Quote> quoteList = QuoteDAO.getInstance().buscarPropostasPorId(stPropostas);//PLV-5022 - INICIO/FIM
		Map<Id,Quote> mapQuote = new Map<Id,Quote>(quoteList);//PLV-5022 - INICIO/FIM

		for(Quote propostaLoop : quoteList){
			if(!(propostaLoop.CriticasProposta__r).isEmpty()){
				mpPropostas.put(propostaLoop.id, propostaLoop);
				mpPropostasOLD.put(propostaLoop.id, propostaLoop);//PLV-5022 - INICIO/FIM
				mpPropostaCritica.put(propostaLoop.id, propostaLoop.CriticasProposta__r);
			}			
		}
		//PLV-4872 FIM 
		for(CriticaProposta__c criticaLoop : ltNovasCriticas){
			CriticaProposta__c	criticaAntiga 	= mpAntigasCriticas.get(criticaLoop.Id);
			Quote 			   	propostaCritica = mpPropostas.get(criticaLoop.proposta__c);
			Quote propostaCriticaUpdate = new Quote(Id=criticaLoop.proposta__c);//PLV-4944 - INICIO/FIM - PEDRO AUGUSTO BRAZ
			Quote propostaCriticaHistorico = mapQuote.get(criticaLoop.proposta__c);//PLV-5022 - INICIO/FIM - PEDRO AUGUSTO BRAZ
			propostaCriticaUpdate.IntegrouNaoCLienteBCP__c = propostaCriticaHistorico.IntegrouNaoCLienteBCP__c;//PLV-5022 - INICIO/FIM - PEDRO AUGUSTO BRAZ
			//PLV-4592 - Caso 1
			if(	criticaLoop.Status__c 	== STATUS_PENDENCIADO && 
				criticaAntiga.Status__c != STATUS_PENDENCIADO && 
				propostaCritica.DataInicioPendencia__c == null){

					propostaCriticaUpdate.DataInicioPendencia__c = diaExecucao;//PLV-4944 - INICIO/FIM
					propostaCriticaHistorico.DataInicioPendencia__c = diaExecucao;//PLV-5022 - INICIO/FIM
					//PLV-4495 - INICIO
					mapPropostaUpdate.put(propostaCritica.Id, propostaCriticaUpdate);//PLV-4944 - INICIO/FIM
					//PLV-4495 - FIM


			//PLV-4592 - Caso 2
			//PLV-4872 INICIO 
			}else if(criticaAntiga.Status__c == STATUS_PENDENCIADO &&(
						criticaLoop.Status__c == STATUS_PENDENTE 
						|| criticaLoop.Status__c == STATUS_EMAPROVACAO 
						|| criticaLoop.Status__c == STATUS_LIBERADO 
						|| criticaLoop.Status__c == STATUS_RECUSADO 
						|| criticaLoop.Status__c == STATUS_CONDICIONADA 
						|| criticaLoop.Status__c == STATUS_CANCELADA
					) && criticaLoop.DataFimPendencia__c != null){
			//PLV-4872 FIM 
					
					Boolean temPendenciada 	= false;
					for(CriticaProposta__c criticaPropostaLoop : mpPropostaCritica.get(criticaLoop.Proposta__c)){
						if(criticaPropostaLoop.Status__c == STATUS_PENDENCIADO && criticaPropostaLoop.Id != criticaLoop.Id){
							temPendenciada = true;
						}
					}
					
					if(!temPendenciada){
						if(propostaCritica.DataInicioPendencia__c != null){
							
							System.debug('propostaCritica> ' + JSON.serialize(propostaCritica));
							System.debug('criticaLoop> ' + JSON.serialize(criticaLoop));
							System.debug('propostaCriticaUpdate> ' + JSON.serialize(propostaCriticaUpdate));

							propostaCriticaUpdate.DataFimPendencia__c     =  criticaLoop.DataFimPendencia__c;//PLV-4944 - INICIO/FIM
							Integer diasEmPendencia 				=  criticaLoop.DataInicioPendencia__c.daysBetween(criticaLoop.DataFimPendencia__c); //PLV-4991 - INICIO/FIM
							propostaCriticaUpdate.TotalDiasPausados__c 	=  propostaCritica.TotalDiasPausados__c == null ? diasEmPendencia : propostaCritica.TotalDiasPausados__c + diasEmPendencia;//PLV-4944 - INICIO/FIM
							propostaCriticaHistorico.DataFimPendencia__c = propostaCriticaUpdate.DataFimPendencia__c;//PLV-5022
							propostaCriticaHistorico.TotalDiasPausados__c = propostaCriticaUpdate.TotalDiasPausados__c;//PLV-5022
							//PLV-4495 - INICIO
							mapPropostaUpdate.put(propostaCritica.Id, propostaCriticaUpdate);//PLV-4944 - INICIO/FIM
							//PLV-4495 - FIM
						}
						
					}

			//PLV-4592 - Caso 3
			//PLV-4872 - INICIO
			}else if(criticaAntiga.Status__c == STATUS_PENDENTE && criticaLoop.Status__c == STATUS_EMAPROVACAO && criticaLoop.MomentoAnalise__c == MOMENTOANALISE_RESSEGURO){
				//PLV-4872 - FIM
				propostaCriticaUpdate.DataInicioResseguro__c = diaExecucao;//PLV-4944 - INICIO/FIM
				propostaCriticaHistorico.DataInicioResseguro__c = propostaCriticaUpdate.DataInicioResseguro__c;//PLV-5022

				//PLV-4495 - INICIO
				mapPropostaUpdate.put(propostaCritica.Id, propostaCriticaUpdate);//PLV-4944 - INICIO/FIM
				//PLV-4495 - FIM

			//PLV-4592 - Caso 4
			}else if(criticaAntiga.Status__c 	!= STATUS_LIBERADO &&
					criticaAntiga.Status__c 	!= STATUS_RECUSADO &&
					criticaAntiga.Status__c 	!= STATUS_CONDICIONADA &&
					(criticaLoop.Status__c 	== STATUS_LIBERADO ||
					criticaLoop.Status__c 	== STATUS_RECUSADO ||
					criticaLoop.Status__c 	== STATUS_CONDICIONADA)){

					//PLV-4872 - INICIO
					if (criticaLoop.Status__c == STATUS_RECUSADO) {
						propostaCriticaUpdate.Data_da_recusa__c = diaExecucao;//PLV-4944 - INICIO/FIM
						propostaCriticaHistorico.Data_da_recusa__c = propostaCriticaUpdate.Data_da_recusa__c;//PLV-5022
					}
					if (criticaLoop.MomentoAnalise__c == MOMENTOANALISE_RESSEGURO) {						
						propostaCriticaUpdate.DataFimResseguro__c 	=	diaExecucao;//PLV-4944 - INICIO/FIM	
						propostaCriticaHistorico.DataFimResseguro__c = propostaCriticaUpdate.DataFimResseguro__c;//PLV-5022
					}
					//PLV-4872 - FIM
					//PLV-4495 - INICIO
					mapPropostaUpdate.put(propostaCritica.Id, propostaCriticaUpdate);//PLV-4944 - INICIO/FIM
					//PLV-4495 - FIM
			//PLV-4872 - INICIO
            }else if(criticaLoop.MomentoAnalise__c == MOMENTOANALISE_RESSEGURO &&  criticaAntiga.Status__c == STATUS_EMAPROVACAO && 
			(criticaLoop.Status__c == STATUS_PENDENTE || criticaLoop.Status__c 	== STATUS_LIBERADO || criticaLoop.Status__c == STATUS_RECUSADO || 
			criticaLoop.Status__c == STATUS_CONDICIONADA || criticaLoop.Status__c == STATUS_CANCELADA)){
				propostaCriticaUpdate.DataFimResseguro__c = diaExecucao;//PLV-4944 - INICIO/FIM
				propostaCriticaHistorico.DataFimResseguro__c = propostaCriticaUpdate.DataFimResseguro__c;//PLV-5022

				mapPropostaUpdate.put(propostaCritica.Id, propostaCriticaUpdate);//PLV-4944 - INICIO/FIM
			}
			
			if (!mapPropostaUpdate.containsKey(criticaLoop.Proposta__c)) {
				if (criticaLoop.DataInicioPendencia__c != null && criticaLoop.DataFimPendencia__c != null) {
					
					if ((criticaLoop.DataInicioPendencia__c != criticaAntiga.DataInicioPendencia__c) ||(criticaLoop.DataFimPendencia__c != criticaAntiga.DataFimPendencia__c)) {
						mapPropostaUpdate.put(propostaCritica.Id, propostaCriticaUpdate);//PLV-4944 - INICIO/FIM
					}
				}
			}
			//PLV-4872 - FIM
			mpPropostashistorico.put(propostaCritica.Id, propostaCriticaHistorico);//PLV-5022
		}

		//PLV-4495 - INICIO
		if(mapPropostaUpdate.size() > 0){
			//PLV-4872 - INICIO
			for (quote propostaTemp : mapPropostaUpdate.values()) {
				propostaTemp.TotalDiasPausados__c 	=  calcularDiasPausados(mpPropostas.get(propostaTemp.Id).criticasProposta__r);//PLV-4944-INICIO/FIM
			}
			//PLV-4872 - FIM
		//PLV-4495 - FIM
			try{
				//PLV-4495 - INICIO
				//PLV-4944 - INICIO
				if(System.Test.isRunningTest()){
					update mapPropostaUpdate.values();
				}else{
					//PLV-5022 INICIO - DISPARAR INTEGRAÇÕES COMPLEMENTARES DA PROPOSTA ANTES DE ALTERA-LA
					for (quote propostaTemp : mapPropostaUpdate.values()){
						propostaTemp.isAPI__c = true;
					}
					for (String key : mpPropostasOLD.keyset()){
						if(!mapPropostaUpdate.containsKey(key)) mpPropostasOLD.remove(key);
					}

					//FNPVVEP-69 - INICIO
					//Util.sObjectActionCIVasync('update', JSON.serialize(mapPropostaUpdate.values()), true, true, null,false);//update mapPropostaUpdate.values();//PLV-4944 - INICIO/FIM
					if(System.isBatch()) {
						System.debug('XXX - AUTOMAÇÃO CRITICAS: BATCH' + JSON.serialize(mapPropostaUpdate.values()));

						List<SObject> lista = null;
						lista = (List<SObject>) JSON.deserialize(JSON.serialize(mapPropostaUpdate.values()),  List<SObject>.class);

						Util.sObjectActionCIV('update', lista, true, true, null,false);
					}else{
						Util.sObjectActionCIVasync('update', JSON.serialize(mapPropostaUpdate.values()), true, true, null,false);
					}
					//FNPVVEP-69 - FIM



					//QuoteBO.getInstance().integrarNaoClienteBCP(mpPropostashistorico.values());  MGRC-504 - INICIO-FIM
					if(System.isFuture()){
						IntegracaoAS.inserirHistoricoQuote(JSON.serialize(mpPropostashistorico.values()), JSON.serialize(mpPropostasOLD));
					}else{
						IntegracaoAS.inserirhistoricoquoteFuture(JSON.serialize(mpPropostashistorico.values()), JSON.serialize(mpPropostasOLD));
					}

					//PLV-5022 FIM - DISPARAR INTEGRAÇÕES COMPLEMENTARES DA PROPOSTA
				}
				//PLV-4944 - FIM
				//PLV-4495 - FIM
			}catch(DmlException e) {
				throw new dmlPropostaException('Não foi possível atualizar os registros de proposta, Erro: ' + e.getMessage());
			}
		}
        
    }
    
    public class dmlPropostaException extends Exception {}
    //PLV-4592 - Fim
	//PLV-4872 - INICIO
	public integer calcularDiasPausados(List<CriticaProposta__c> listaCriticas){
		if (listaCriticas == null) return 0;

		integer totalDiasPausados = 0;
		date inicioRangePend;
		date fimRangePend;
		date inicioRangeRes;
		date fimRangeRes;

		for (CriticaProposta__c criticaTemp : listaCriticas) {
			if (criticaTemp.DataInicioPendencia__c != null || criticaTemp.DataFimPendencia__c != null){
				if (inicioRangePend == null) inicioRangePend=criticaTemp.DataInicioPendencia__c;
				if (fimRangePend == null) fimRangePend = criticaTemp.DataFimPendencia__c;
				
				if (criticaTemp.DataInicioPendencia__c > fimRangePend) {
					//Criar novo range
					totalDiasPausados += inicioRangePend.daysBetween(fimRangePend) + 1;
					inicioRangePend = criticaTemp.DataInicioPendencia__c;
					fimRangePend = criticaTemp.DataFimPendencia__c;
				}else if(criticaTemp.DataFimPendencia__c > fimRangePend){
					fimRangePend = criticaTemp.DataFimPendencia__c;
				}
			}
			
			if (criticaTemp.Data_inicio_resseguro__c != null || criticaTemp.Data_fim_resseguro__c != null){
				if (inicioRangeRes == null) inicioRangeRes = criticaTemp.Data_inicio_resseguro__c;
				if (fimRangeRes == null) fimRangeRes = criticaTemp.Data_fim_resseguro__c;
				
				if (criticaTemp.Data_inicio_resseguro__c > fimRangeRes) {
					totalDiasPausados += inicioRangeRes.daysBetween(fimRangeRes) + 1;
					inicioRangeRes = criticaTemp.Data_inicio_resseguro__c;
					fimRangeRes = criticaTemp.Data_fim_resseguro__c;
				}else if(criticaTemp.Data_fim_resseguro__c > fimRangeRes){
					fimRangeRes = criticaTemp.Data_fim_resseguro__c;
				}
			}
		}
		if (inicioRangePend != null && fimRangePend != null) {
			totalDiasPausados += inicioRangePend.daysBetween(fimRangePend) + 1;
		}
		if (inicioRangeRes != null && fimRangeRes != null) {
			totalDiasPausados += inicioRangeRes.daysBetween(fimRangeRes) + 1;
		}
		return totalDiasPausados;
	}
	//PLV-4872 - FIM

	//PLV-4976 INICIO
	public void updateProprietarioText(List<CriticaProposta__c> ltNovasCriticas, Map<Id, CriticaProposta__c> mapCriticaOld){
		Set<ID> idProprietario = new Set<Id>();
		Boolean isNew = mapCriticaOld == null;
		Map<Id, String> mpProprietarios = new Map<id, String>();
		List<CriticaProposta__c> lstCriticas = new List<CriticaProposta__c>();

		if(isNew) mapCriticaOld = new Map<Id, CriticaProposta__c>();

		for(CriticaProposta__c ctr : ltNovasCriticas) {
			CriticaProposta__c criticaOld = isNew ? null : mapCriticaOld.get(ctr.id);	     								

			Boolean criticaIsUpdated = criticaOld != null && (ctr.ownerId != criticaOld.ownerId || ctr.ProprietarioList__c != criticaOld.ProprietarioList__c);

			if(isNew || criticaIsUpdated){
				lstCriticas.add(ctr);
				idProprietario.add(ctr.ownerId);
			}
		}

		Boolean executeQuery = !Test.isRunningTest() && !lstCriticas.isEmpty();

		List<User> lstUsers  = executeQuery ? [SELECT Name FROM User WHERE Id in :idProprietario] : new List<User>();
		List<Group> lstGroup = executeQuery ? [SELECT Name FROM Group WHERE Id in :idProprietario] : new List<Group>();

		for(User  u: lstUsers) mpProprietarios.put(u.id, u.name); 
		for(Group g: lstGroup) mpProprietarios.put(g.id, g.name);
	
		for(CriticaProposta__c ctr : lstCriticas) ctr.ProprietarioList__c = executeQuery ? mpProprietarios.get(ctr.ownerId) : 'Teste';
	}
	//PLV-4976 FIM
	//PLV-5058 INICIO
	public void atualizaSetorCritica(List<CriticaProposta__c> lstCriticasNew, Map<Id, CriticaProposta__c> criticasOldMap){

		Map<String,Id> mapFila = new Map<String,Id>();

		List<QueueSobject> listqueue = [
			SELECT QueueID, Queue.developerName
				FROM QueueSObject 
			WHERE SobjectType = 'CriticaProposta__c' AND Queue.developerName IN ('Filaaceitacao', 'Filaemissao')
		];
		
		for(QueueSobject fila : listqueue) mapFila.put(fila.Queue.developerName, fila.QueueID);
		
		for(CriticaProposta__c critica : lstCriticasNew){

			if(critica.OwnerId != criticasOldMap.get(critica.Id).OwnerId){

				if(critica.OwnerId == mapFila.get('Filaaceitacao')) critica.Setor__c = 	'Aceitação';
				else if(critica.OwnerId == mapFila.get('Filaemissao')) critica.Setor__c = 	'Emissão';
			}

			else if(critica.Setor__c != criticasOldMap.get(critica.Id).Setor__c){

				if(critica.Setor__c == 'Aceitação') critica.OwnerId = mapFila.get('Filaaceitacao');
				else if(critica.Setor__c == 'Emissão') critica.OwnerId = mapFila.get('Filaemissao');
			}
		}
	}
	//PLV-5058 FIM	
}

//PLV-2418 - Fim - Classe para atender as regras de negócio do objeto "Critica Proposta".