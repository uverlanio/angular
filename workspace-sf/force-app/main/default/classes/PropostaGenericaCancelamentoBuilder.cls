public with sharing class PropostaGenericaCancelamentoBuilder extends PropostaBuilder
{

	// instancias, metodos e construtores do padrao
	private static final PropostaGenericaCancelamentoBuilder instance = new PropostaGenericaCancelamentoBuilder();
	public static PropostaGenericaCancelamentoBuilder getInstance() { return instance; }
	private PropostaGenericaCancelamentoBuilder() { this.setInstancia(this); }

	private OpportunityDAO daoOrcamento = OpportunityDAO.getInstance();
	private QuoteDAO daoProposta = QuoteDAO.getInstance();
	private ContractDAO daoContract = ContractDAO.getInstance(); //PLV-3872 - INICIO/FIM - Instancia da classe que está sendo utilizada
	private GrupoOrcamentoDAO daoGrupoOrcamento = GrupoOrcamentoDAO.getInstance();
	private ContratanteOrcamentoDAO daoContratanteOrcamento = ContratanteOrcamentoDAO.getInstance();
	private static HerokuService herokuServ = HerokuService.getInstance();

	private Opportunity orcamento;
	private Quote propostaOriginal;
	private Contract contrato; //PLV-3872 - INICIO/FIM - Novo parametro
	private Map<Id, List<GrupoOrcamento__c>> mapGruposOrcamento = new Map<Id, List<GrupoOrcamento__c>>();
	private Map<Id, List<GarantiaSeguradoOrcamento__c>> mapGarantiaSeguradoOrcamento = new Map<Id, List<GarantiaSeguradoOrcamento__c>>();
	private Map<Id, List<GarantiaContratanteOrcamento__c>> mapGarantiaContratanteOrcamento = new Map<Id, List<GarantiaContratanteOrcamento__c>>();
	private Map<String, SeguradoProposta__c> mapSeguradoPropostaOriginal = new Map<String, SeguradoProposta__c>();

	private Map<String, String> mapConversaoTipoProposta = new Map<String, String>{'CAN' => 'CANCELAMENTO', 'Cancelamento' => 'Cancelamento', 'Endosso' => 'Endosso', 'Seguro novo' => 'Novo', 'Renovação' => 'Renovação'};
	private Map<String, String> mapConversaoTipoSeguro = new Map<String, String>{'Cancelamento' => 'CAN', 'CANCELAMENTO' => 'CAN'}; // PLV-4606


	/* ---------------------------------- INTERFACE --------------------------------------------------------------- */
	public override List<Proposta.ContratanteWrapper> gerarContratantes(EmissaoTO.PayloadTO payloadTO){ return null; }
	public override List<Proposta.GrupoWrapper> gerarGrupos(List<EmissaoTO.GrupoTO> gruposTO, String numeroContratante){ return null; }
	public override List<Proposta.SeguradoWrapper> gerarSegurados(List<EmissaoTO.SeguradoTO> seguradosTO, String numeroContratante, String numeroGrupo){ return null; }
	// INICIO | PLV-2355-Hackathon
	public override List<Proposta.BeneficiariosWrapper> gerarBeneficiarios(List<EmissaoTO.BeneficiarioTO> beneficiariosTO, Proposta.SeguradoWrapper seguradoWrapper) { return null; }
	public override void gerarContas(EmissaoTO.PayloadTO payloadTO, List<Proposta.PessoaWrapper> listPessoasWrapper){}
	// FIN | PLV-2355-Hackathon
	public override void popularPrecificacao(EmissaoTO.PrecificacaoTO precificacaoTO){}
	// INICIO | PLV-2402-30
	public override void gerarCriticas(EmissaoTO.PayloadTO payloadTO, List<Proposta.CriticaPropostaWrapper> listCriticasWrapper){}
	// INICIO | PLV-2402-30
	public override void validarPayload(EmissaoTO.PayloadTO payloadTO){}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: cria a proposta
    */
	public override void gerarProposta(EmissaoTO.PayloadTO payloadTO)
	{

		// Formata o numero do orcamento
		String numeroOrcamento = String.valueOf(payloadTO.proposta.numeroOrcamento).leftPad(8,'0');
		System.debug('payloadTO.proposta.numeroOrcamento ' + payloadTO.proposta.numeroOrcamento);
		System.debug('numeroOrcamento ' + numeroOrcamento);

		// Busca o orcamento da proposta
		orcamento = daoOrcamento.obterOportunidadesPorNumero(numeroOrcamento);
		system.debug('teste orcamento 123'+orcamento);
		//PLV-3872 - INICIO - Buscar os dados do contrato original
		List<Contract> lstContract = daoContract.buscarContratoOriginalPorId(orcamento.ContractId);
		
		if(lstContract.isEmpty()) throw new PropostaBuilderException('Não encontrado o contrato original no orçamento');
		
		contrato = lstContract.get(0);
		system.debug('contrato teste 123'+contrato);
		//PLV-3872 - FIM
		// valida se o numero do orcamento existe
		if(orcamento != null)
		{
			//obtem a prposta original
			propostaOriginal =  orcamento.Contract.Proposta__r;

			if(propostaOriginal != null)
			{
				// PLV-2372 INICIO
				// PLV-2567 INICIO
				// Recupera as propostas de cancelamento pendentes e apaga
				List<Opportunity> listOrcamentosAnteriores = new List<Opportunity>();
				List<Quote> listPropostasCancelamentoAnteriores = new List<Quote>();
				List<Quote> listPropostasCancelamento = QuoteDAO.getInstance().buscarPropostasCancelamentoPorContratoOriginal(new Set<Id>{orcamento.ContractId});
				system.debug('Proposta a serem excluidas'+listPropostasCancelamento); //PLV-4695-FIX8-INICIO/FIM
				for(Quote proposta : listPropostasCancelamento){
					if('Devolutiva'.equalsIgnoreCase(proposta.Status) || 'Em criação'.equalsIgnoreCase(proposta.Status)){ //PLV-4695-FIX8-INICIO/FIM
						listOrcamentosAnteriores.add(proposta.Opportunity);
						listPropostasCancelamentoAnteriores.add(proposta);
					}
					//PLV-4695 -FIX2 - INICIO
					/*else{
						// Gera a devolutiva abortiva de proposta já cancelada
						throw new PropostaBuilderException('Já existe uma proposta para cancelar esse contrato.');
					}*/
					//PLV-4695 - FIX2 - FIM
				}
				// PLV-2567 FIM

				if(!listPropostasCancelamentoAnteriores.isEmpty()) {
					delete listPropostasCancelamentoAnteriores;
				}
				if(!listOrcamentosAnteriores.isEmpty()){
					delete listOrcamentosAnteriores;
				}
				// PLV-2372 FIM

				system.debug('teste 1234');
				List<RemuneracaoProposta__c> remunecaoPropostaOriginal = daoProposta.buscarRemuneracaoProposta(new Set<Id>{propostaOriginal.Id});
				for(SeguradoProposta__c segurado :daoProposta.buscarListVidaProposta(new Set<Id>{propostaOriginal.Id})){
					mapSeguradoPropostaOriginal.put(String.valueOf(segurado.Numero__c), segurado);
				}

				//Popula a proposta baseado no orcamento
				this.popularProposta(orcamento, this.proposta.propostaWrapper.sfProposta);

				if(orcamento.Contract != null){
					this.proposta.propostaWrapper.retornoWrapper.numeroApolice = orcamento.Contract.NumeroApolice__c;
				}

				this.proposta.propostaWrapper.retornoWrapper.codigoEmpresa = orcamento.Contract.Empresa__c;
				this.proposta.propostaWrapper.retornoWrapper.codigoSucursal = orcamento.Contract.Sucursal__c;
				this.proposta.propostaWrapper.retornoWrapper.codigoRamo = orcamento.Contract.CodigoRamo__c;
				this.proposta.propostaWrapper.retornoWrapper.numeroOrcamento = orcamento.Numero__c;

				// monta os mapas dos grupos e garantias  a partir do 3° nivel da hierarquia
				this.buscarRegistrosDominios();

				// Gera as remuneracoes da proposta
				this.gerarRemuneracaoPropostaWrappersComFavorecidos(remunecaoPropostaOriginal, this.proposta.propostaWrapper.RemuneracaoPropostaWrapper);

				// Gera as garantias da proposta
				this.popularGarantiasWrapper(orcamento.CoberturasOrcamento__r, this.proposta.propostaWrapper.garantiasWrapper);

				// Gera os contratantes
				//PLV-3872 - INICIO - Inclusao do parametro
				this.gerarContratantes(orcamento.ContratantesOrcamento__r, this.proposta.propostaWrapper.contratantesWrapper, contrato.ContratantesContrato__r);
				//PLV-3872 - FIM

				
			}
		}
		else
			throw new PropostaBuilderException('Número de orçamento não ncontrado.');
	}

	/*
    * @author Everymind - Sprint 23
    * @Descrição: monta o retorno do processamento de proposta
    */
	public RetornoPropostaRestTO.ValidacaopropostaTO converterPropostaParaRetornoProposta(Proposta proposta)
	{
		if(proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.isEmpty())
		{
			if(proposta.propostaWrapper.sfProposta.Id != null)
			{

				RetornoPropostaRestTO.DevolutivasTO devolutivaTO = new RetornoPropostaRestTO.DevolutivasTO();
				devolutivaTO.tipoRegistro = 1;
				devolutivaTO.origem = 'INT';
				devolutivaTO.numeroCampo = 0;
				devolutivaTO.descricao = 'EMISSÃO: - registro inserido/atualizado com sucesso.';
				devolutivaTO.codigo = 0;

				proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.add(devolutivaTO);
			}
		}

		try
		{
			proposta.propostaWrapper.retornoWrapper.retorno.proposta = new RetornoPropostaRestTO.PropostaTO();

			proposta.propostaWrapper.retornoWrapper.retorno.proposta.apolice = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.numeroApolice);

			if(proposta.propostaWrapper.retornoWrapper.codigoEmpresa != null)
				proposta.propostaWrapper.retornoWrapper.retorno.proposta.empresa = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoEmpresa);

			if(proposta.propostaWrapper.retornoWrapper.codigoSucursal != null)
				proposta.propostaWrapper.retornoWrapper.retorno.proposta.sucursal = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoSucursal);

			proposta.propostaWrapper.retornoWrapper.retorno.proposta.ramo = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoRamo);
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.numeroOrcamento = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.numeroOrcamento);

			proposta.propostaWrapper.retornoWrapper.retorno.proposta.numero = proposta.propostaWrapper.sfProposta.NumeroProposta__c; //TKCL-246 INICIO-FIM
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.origem = Integer.valueOf(proposta.propostaWrapper.sfProposta.Origem__c);
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.status = proposta.propostaWrapper.sfProposta.Status;
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.meioComercializacao = proposta.propostaWrapper.sfProposta.MeioComercializacao__c;
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.dataCalculo = String.valueOf(proposta.propostaWrapper.sfProposta.DataCalculo__c);
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.tipoSeguro = mapConversaoTipoSeguro.get(proposta.propostaWrapper.sfProposta.Tipo__c);
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.vigenciaInicial = String.valueOf(proposta.propostaWrapper.sfProposta.VigenciaInicial__c);
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.vigenciaFinal = String.valueOf(proposta.propostaWrapper.sfProposta.VigenciaFinal__c);
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.tipoAdesao = 'INA';
			proposta.propostaWrapper.retornoWrapper.retorno.proposta.qtdDiasVigencia = proposta.propostaWrapper.sfProposta.VigenciaInicial__c.daysBetween(proposta.propostaWrapper.sfProposta.VigenciaFinal__c);

		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Erro ao gerar retorno da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		return proposta.propostaWrapper.retornoWrapper.retorno;
	}


	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: cria os contratantes da proposta
    */
	public void gerarContratantes(List<ContratanteOrcamento__c> contratantes, List<Proposta.ContratanteWrapper> listContratanteWrapper, List<ContratanteContrato__c> contratantesContrato) //PLV-3872 - INICIO/FIM - Inclusão do parametro
	{
		//PLV-3872 - INICIO - Criação de map dos contratante do contrato original
		Map<Id,ContratanteContrato__c> mapContratanteContrato = new Map<Id,ContratanteContrato__c>();
		if(!contratantesContrato.isEmpty()){
			for(ContratanteContrato__c contratanteContrato : contratantesContrato){
				mapContratanteContrato.put(contratanteContrato.Conta__c, contratanteContrato);
			}
		}
		//PLV-3872 - FIM
		// Gera os contrantantes, enderecos, dados de pagamentos, garantias e seus grupos
		for (ContratanteOrcamento__c contratante : contratantes)
		{
			// Instancias
			Proposta.ContratanteWrapper contratanteWrapper = new Proposta.ContratanteWrapper();
			contratanteWrapper.sfContratante  = new ContratanteProposta__c();
			//PLV-3872 - INICIO - Ajuste na classe para receber o contratante do contrato original
			ContratanteContrato__c contratanteContratoOriginal = new ContratanteContrato__c();

			if(!mapContratanteContrato.isEmpty()){
				if(mapContratanteContrato.containsKey(contratante.Conta__c)){
					contratanteContratoOriginal = mapContratanteContrato.get(contratante.Conta__c);
				}
			}

			// Gera o contratante da proposta
			this.popularContratante(contratante, contratanteWrapper.sfContratante, contratanteContratoOriginal);
			//PLV-3872 - FIM

			// gera as garantias do contratante da proposta
			contratanteWrapper.garantiasWrapper = new List<Proposta.GarantiaWrapper>();
			this.popularGarantiasContratanteWrapper(mapGarantiaContratanteOrcamento.get(contratante.Id), contratanteWrapper.garantiasWrapper);

			// gera os grupos deste contratante
			contratanteWrapper.gruposWrapper = new List<Proposta.GrupoWrapper>();
			this.gerarGrupos(mapGruposOrcamento.get(contratante.Id), contratanteWrapper.gruposWrapper);

			listContratanteWrapper.add(contratanteWrapper);
		}
	}

	/*
    * @author Everymind - Sprint 23
    * @Descrição: cria os grupos doscontratantes da proposta
    */
	public void gerarGrupos(List<GrupoOrcamento__c> grupos, List<Proposta.GrupoWrapper> listGrupoWrapper)
	{
		// Gera os grupos, garantias dos grupos e seus segurados
		for(GrupoOrcamento__c grupo : grupos)
		{
			// Instancias
			Proposta.GrupoWrapper grupoWrapper = new Proposta.GrupoWrapper();
			grupoWrapper.sfGrupo = new GrupoProposta__c();

			// Popular GrupoProposta__c
			this.popularGrupoProposta(grupo, grupoWrapper.sfGrupo);

			// gera as garantias do grupo da proposta
			grupoWrapper.garantiasWrapper = new List<Proposta.GarantiaWrapper>();
			this.popularGarantiasGrupoWrapper(grupo.GruposGarantiaOrcamento__r, grupoWrapper.garantiasWrapper);

			// gera os segurados desse grupo
			grupoWrapper.seguradosWrapper = new List<Proposta.SeguradoWrapper>();
			this.gerarSegurados(grupo.SeguradosOrcamento__r, grupoWrapper.seguradosWrapper);

			listGrupoWrapper.add(grupoWrapper);
		}
	}

	/*
    * @author Everymind - Sprint 23
    * @Descrição: cria os segurados dos grupos dos contratantes da proposta
    */
	public void gerarSegurados(List<SeguradoOrcamento__c> segurados, List<Proposta.SeguradoWrapper> listSeguradoWrapper)
	{
		for(SeguradoOrcamento__c segurado : segurados)
		{
			// Instancias
			Proposta.SeguradoWrapper seguradoWrapper = new Proposta.SeguradoWrapper();
			// Popular Segurado Proposta
			seguradoWrapper.sfSegurado = new SeguradoProposta__c();

			//PLV-4850 - Inicio
			if(orcamento.Contract.Proposta__r != null){
				this.popularEnderecoSegurado(orcamento.Contract.Proposta__r, seguradoWrapper.sfSegurado);

			}
			//PLV-4850 - Fim

			this.popularSeguradoProposta(segurado, seguradoWrapper.sfSegurado);

			// gera as garantias do contratante da proposta
			seguradoWrapper.garantiasWrapper = new List<Proposta.GarantiaWrapper>();
			this.popularGarantiasSeguradoWrapper(mapGarantiaSeguradoOrcamento.get(segurado.Id), seguradoWrapper.garantiasWrapper);

			// gera os beneficiarios do segurado da proposta
			SeguradoProposta__c seguradoPropostaOriginal = mapSeguradoPropostaOriginal.get(String.valueOf(segurado.Numero__c));
			seguradoWrapper.beneficiariosWrapper = new List<Proposta.BeneficiariosWrapper>();

			System.debug(seguradoPropostaOriginal.BeneficiariosSeguradosProposta__r);
			System.debug(seguradoWrapper.beneficiariosWrapper);

			this.popularBeneficiariosSeguradoWrapper(seguradoPropostaOriginal.BeneficiariosSeguradosProposta__r, seguradoWrapper.beneficiariosWrapper);

			listSeguradoWrapper.add(seguradoWrapper);
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: persiste a proposta
    */
	public override Proposta inserirRegistros(Proposta proposta)
	{
		// Instancias
		List<GarantiaProposta__c> listGarantiaProposta = new List<GarantiaProposta__c>();
		List<GarantiaContratanteProposta__c> listGarantiaContratanteProposta = new List<GarantiaContratanteProposta__c>();
		List<GarantiasGrupoProposta__c> listGarantiaGrupoProposta = new List<GarantiasGrupoProposta__c>();
		List<GarantiaSeguradoProposta__c> listGarantiaSeguradoProposta = new List<GarantiaSeguradoProposta__c>();
		List<RemuneracaoProposta__c> listRemuneracaoProposta = new List<RemuneracaoProposta__c>();
		List<FavorecidoRemuneracaoProposta__c> listFavorecidoRemuneracaoProposta = new List<FavorecidoRemuneracaoProposta__c>();
		//List<CriticaProposta__c> listCriticaProposta = new List<CriticaProposta__c>();
		List<ContratanteProposta__c> listContratanteProposta = new List<ContratanteProposta__c>();
		List<GrupoProposta__c> listGrupoProposta = new List<GrupoProposta__c>();
		List<SeguradoProposta__c> listSeguradoProposta = new List<SeguradoProposta__c>();
		List<BeneficiarioSeguradoProposta__c> listBeneficiarioSeguradoProposta = new List<BeneficiarioSeguradoProposta__c>();

		// Insere a proposta
		try{
			System.debug('Danilo this.proposta.propostaWrapper.sfProposta: ' + this.proposta.propostaWrapper.sfProposta);
			insert this.proposta.propostaWrapper.sfProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		//Atribui id da proposta nas Remuneracoes
		for(Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper : this.proposta.propostaWrapper.remuneracaoPropostaWrapper)
		{
			remuneracaoPropostaWrapper.sfRemuneracaoProposta.Id = null;
			remuneracaoPropostaWrapper.sfRemuneracaoProposta.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
			listRemuneracaoProposta.add(remuneracaoPropostaWrapper.sfRemuneracaoProposta);

		}
		// Atribui id da proposta nas garantias
		for(Proposta.GarantiaWrapper garantiaWrapper : this.proposta.propostaWrapper.garantiasWrapper)
		{
			garantiaWrapper.sfGarantiaProposta.Id = null;
			garantiaWrapper.sfGarantiaProposta.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
			listGarantiaProposta.add(garantiaWrapper.sfGarantiaProposta);
		}

		//Atribui id da proposta nos contratantes

		for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper )
		{
			contratanteWrapper.sfContratante.Id = null;
			contratanteWrapper.sfContratante.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
			listContratanteProposta.add(contratanteWrapper.sfContratante);
		}

		//// Atribui Id da proposta nas criticas da proposta
		//for(CriticaProposta__c criticaProposta : this.proposta.propostaWrapper.criticas){
		//    criticaProposta.Id = null;
		//    criticaProposta.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
		//    listCriticaProposta.add(criticaProposta);
		//}

		// Insere os contratantes da proposta
		try{
			insert listContratanteProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir contratantes da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Insere as remuneracoes da proposta
		try{
			insert listRemuneracaoProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir remuneracoes da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Insere as garantias da proposta
		try{
			insert listGarantiaProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir garantias da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Insere as criticas da proposta
		//try{
		//    insert listCriticaProposta;
		//}catch (Exception e){
		//    throw new PropostaBuilderException('Exception: Inserir criticas da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		//}

		// Atribui o id das remuneracoes da proposta nos favorecidos
		for(Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper : this.proposta.propostaWrapper.remuneracaoPropostaWrapper)
		{
			for(Proposta.FavorecidoRemuneracaoWrapper favorecidoRemuneracaoWrapper : remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper)
			{
				favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta.Id = null;
				favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta.RemuneracaoProposta__c = remuneracaoPropostaWrapper.sfRemuneracaoProposta.Id;
				listFavorecidoRemuneracaoProposta.add(favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta);
			}
		}

		// Atribui o id do contratante nas garantias e grupos
		for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper)
		{
			for(Proposta.GarantiaWrapper garantiaWrapper : contratanteWrapper.garantiasWrapper)
			{
				// Atribui o id do contratante para a garantiaWrapper
				garantiaWrapper.sfGarantiaContratanteProposta.Id = null;
				garantiaWrapper.sfGarantiaContratanteProposta.ContratanteProposta__c = contratanteWrapper.sfContratante.Id;
				listGarantiaContratanteProposta.add(garantiaWrapper.sfGarantiaContratanteProposta);

			}
			for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper)
			{
				// Atribui o id do contratante para a grupoWrapper
				grupoWrapper.sfGrupo.Id = null;
				grupoWrapper.sfGrupo.ContratanteProposta__c = contratanteWrapper.sfContratante.Id;
				listGrupoProposta.add(grupoWrapper.sfGrupo);
			}
		}

		// Insere os favorecidos da remuneracao da proposta
		try{
			insert listFavorecidoRemuneracaoProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir favorecidos da remuneracao da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Insere as garantias do contratante da proposta
		try{
			insert listGarantiaContratanteProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir garantias do contratante da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Insere os grupos do contratante da proposta
		try{
			insert listGrupoProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir grupos do contratante da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Atribui o id do grupo nas garantias e segurados
		for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper)
		{
			for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper)
			{
				for (Proposta.GarantiaWrapper garantiaWrapper : grupoWrapper.garantiasWrapper)
				{
					// Atribui o id do grupo para a garantiaWrapper
					garantiaWrapper.sfGarantiaGrupoProposta.Id = null;
					garantiaWrapper.sfGarantiaGrupoProposta.GrupoProposta__c = grupoWrapper.sfGrupo.Id;
					listGarantiaGrupoProposta.add(garantiaWrapper.sfGarantiaGrupoProposta);
				}
				for (Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper)
				{
					// Atribui o id do grupo para o seguradoWrapper
					seguradoWrapper.sfSegurado.Id = null;
					seguradoWrapper.sfSegurado.GrupoProposta__c = grupoWrapper.sfGrupo.Id;
					listSeguradoProposta.add(seguradoWrapper.sfSegurado);
				}
			}
		}

		// Insere as garantias do grupo da proposta
		try{
			insert listGarantiaGrupoProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir garantias dos grupos da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Insere os segurados dos grupos da proposta
		try{
			insert listSeguradoProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir segurados dos grupos da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Atribui o id do segurado nas garantias e beneficiarios
		for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper)
		{
			for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper)
			{
				for(Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper)
				{
					for (Proposta.GarantiaWrapper garantiaWrapper : seguradoWrapper.garantiasWrapper)
					{
						// Atribui o id do grupo para a garantiaWrapper
						garantiaWrapper.sfGarantiaSeguradoProposta.Id = null;
						garantiaWrapper.sfGarantiaSeguradoProposta.SeguradoProposta__c = seguradoWrapper.sfSegurado.Id;
						listGarantiaSeguradoProposta.add(garantiaWrapper.sfGarantiaSeguradoProposta);
					}
					for (Proposta.BeneficiariosWrapper beneficiariosWrapper : seguradoWrapper.beneficiariosWrapper)
					{
						// Atribui o id do grupo para o seguradoWrapper
						beneficiariosWrapper.sfBeneficiarioSeguradoProposta.Id = null;
						beneficiariosWrapper.sfBeneficiarioSeguradoProposta.SeguradoProposta__c =  seguradoWrapper.sfSegurado.Id;
						listBeneficiarioSeguradoProposta.add(beneficiariosWrapper.sfBeneficiarioSeguradoProposta);
					}
				}
			}
		}

		// Insere as garantias do segurado da proposta
		try{
			insert listGarantiaSeguradoProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir garantias dos segurados da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		// Insere os segurados dos grupos da proposta
		try{
			insert listBeneficiarioSeguradoProposta;
		}catch (Exception e){
			throw new PropostaBuilderException('Exception: Inserir beneficiarios dos segurados da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}

		return proposta;
	}

	/* ---------------------------------- FIM INTERFACE ----------------------------------------------------------- */


	/* ---------------------------------- WRAPPERS ---------------------------------------------------------------- */

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: inclui no wrapper
    */
	private void popularGarantiasWrapper(List<GarantiaOrcamento__c> garantias, List<Proposta.GarantiaWrapper> listGarantiasWrapper)
	{
		for(GarantiaOrcamento__c garantia : garantias)
		{
			Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
			garantiaWrapper.sfGarantiaProposta = new GarantiaProposta__c();
			this.popularGarantiaProposta(garantia, garantiaWrapper.sfGarantiaProposta);

			listGarantiasWrapper.add(garantiaWrapper);
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: inclui no wrapper
    */
	private void popularGarantiasContratanteWrapper(List<GarantiaContratanteOrcamento__c> garantias, List<Proposta.GarantiaWrapper> listGarantiasWrapper)
	{

		for(GarantiaContratanteOrcamento__c garantia : garantias)
		{
			Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
			garantiaWrapper.sfGarantiaContratanteProposta = new GarantiaContratanteProposta__c();
			this.popularGarantiaContratanteProposta(garantia, garantiaWrapper.sfGarantiaContratanteProposta);

			listGarantiasWrapper.add(garantiaWrapper);
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: inclui no wrapper
    */
	private void popularGarantiasGrupoWrapper(List<GarantiaGrupoOrcamento__c> garantias, List<Proposta.GarantiaWrapper> listGarantiasWrapper)
	{
		for(GarantiaGrupoOrcamento__c garantia : garantias)
		{
			Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
			garantiaWrapper.sfGarantiaGrupoProposta = new GarantiasGrupoProposta__c();
			this.popularGarantiaGrupoProposta(garantia, garantiaWrapper.sfGarantiaGrupoProposta);
			listGarantiasWrapper.add(garantiaWrapper);
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: inclui no wrapper
    */
	private void popularGarantiasSeguradoWrapper(List<GarantiaSeguradoOrcamento__c> garantias, List<Proposta.GarantiaWrapper> listGarantiasWrapper)
	{
		for(GarantiaSeguradoOrcamento__c garantia : garantias)
		{
			Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
			garantiaWrapper.sfGarantiaSeguradoProposta = new GarantiaSeguradoProposta__c();
			this.popularGarantiaSeguradoProposta(garantia, garantiaWrapper.sfGarantiaSeguradoProposta);
			listGarantiasWrapper .add(garantiaWrapper);
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: inclui no wrapper
    */
	private void popularBeneficiariosSeguradoWrapper(List<BeneficiarioSeguradoProposta__c> beneficiarios, List<Proposta.BeneficiariosWrapper> listBeneficiarioWrapper)
	{
		for(BeneficiarioSeguradoProposta__c beneficiario : beneficiarios)
		{
			Proposta.BeneficiariosWrapper beneficiarioWrapper = new Proposta.BeneficiariosWrapper();
			beneficiarioWrapper.sfBeneficiarioSeguradoProposta = new BeneficiarioSeguradoProposta__c();
			this.popularBeneficiarioProposta(beneficiario, beneficiarioWrapper.sfBeneficiarioSeguradoProposta);

			listBeneficiarioWrapper.add(beneficiarioWrapper);
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: inclui no wrapper
    */
	public void gerarRemuneracaoPropostaWrappersComFavorecidos(List<RemuneracaoProposta__c> remuneracoes, List<Proposta.RemuneracaoPropostaWrapper> listRemuneracaoPropostaWrappers)
	{
		// Gera as remuneracoes e seus favorecidos
		for(RemuneracaoProposta__c remuneracao : remuneracoes)
		{
			// Instancias
			Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper = new Proposta.RemuneracaoPropostaWrapper();
			remuneracaoPropostaWrapper.sfRemuneracaoProposta = new RemuneracaoProposta__c();
			// Popula a remuneracao da proposta
			this.popularRemuneracaoProposta(remuneracao, remuneracaoPropostaWrapper.sfRemuneracaoProposta);

			// gera os favorecidos da remuneracao
			remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper = new List<Proposta.FavorecidoRemuneracaoWrapper>();
			this.gerarFavorecidosRemuneracaoPropostaWrapper(remuneracao.FavorecidosRemuneracaodaProposta__r, remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper);

			listRemuneracaoPropostaWrappers.add(remuneracaoPropostaWrapper);
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: inclui no wrapper
    */
	private void gerarFavorecidosRemuneracaoPropostaWrapper (List<FavorecidoRemuneracaoProposta__c> favorecidos, List<Proposta.FavorecidoRemuneracaoWrapper> listFavorecidoRemuneracaoWrapper)
	{
		// Gera os favorecidos da remuneracao
		for(FavorecidoRemuneracaoProposta__c favorecido : favorecidos)
		{
			// Gera o favorecido da remuneracao
			Proposta.FavorecidoRemuneracaoWrapper favorecidoRemuneracaoPropostaWrapper = new Proposta.FavorecidoRemuneracaoWrapper();
			favorecidoRemuneracaoPropostaWrapper.sfFavorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c();
			this.popularFavorecidoRemuneracaoProposta(favorecido, favorecidoRemuneracaoPropostaWrapper.sfFavorecidoRemuneracaoProposta);
			listFavorecidoRemuneracaoWrapper.add(favorecidoRemuneracaoPropostaWrapper);
		}
	}

	/* ---------------------------------- MODELOS ----------------------------------------------------------------- */
	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularProposta(Opportunity orcamento, Quote proposta)
	{
		try
		{
			//for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Quote'))
			//    mapRecordType.put(tipo.DeveloperName, tipo);

			proposta.Status = 'Em criação';
			proposta.NumeroProposta__c =  orcamento.Numero__c.leftPad(8,'0'); //herokuServ.gerarNumeroProposta()  //TODO
			proposta.Name = this.gerarQuoteName(String.valueOf(orcamento.Origem__c), orcamento.Numero__c);
			proposta.NomeSocial__c = orcamento.Nome_Social__c;  // LECVPV-188(CANCELAMENTO) INICIO/FIM
			
			//PLV-2291 INICIO Criacao de campo unico
			proposta.NumeroPropostaUnico__c = this.gerarQuoteName(String.valueOf(orcamento.Origem__c), orcamento.Numero__c);
			//PLV-2291 FIM Criacao de campo unico
			proposta.RecordTypeId = propostaOriginal.RecordTypeId;// mapRecordType.get(orcamento.RecordType.Name);
			proposta.OpportunityId = orcamento.Id;
			// proposta.AccountId = orcamento.Conta__c;
			proposta.CanalDistribuicao__c = orcamento.CanalDistribuicao__c;
			proposta.CodigoCorretor__c = orcamento.CodigoCorretor__c;
			proposta.CustoApolice__c = orcamento.CustoApolice__c;
			proposta.DataCalculo__c = orcamento.DataCalculo__c;
			proposta.DataCriacaoPortal__c = orcamento.DataCriacaoPortal__c;
			proposta.Description = orcamento.Description;
			proposta.Encargos__c = orcamento.Encargos__c;
			proposta.FormaPagamento__c = orcamento.FormaPagamento__c;
			proposta.InformacoesEvento__c = orcamento.InformacoesEvento__c;
			proposta.Iof__c = orcamento.Iof__c;
			proposta.Juros__c = orcamento.Juros__c;
			proposta.MeioComercializacao__c = orcamento.MeioComercializacao__c;
			proposta.Origem__c = orcamento.Origem__c;
			proposta.Payload__c = orcamento.Payload__c;
			proposta.Produto__c = orcamento.Produto__c;
			proposta.TipoDescontoAgravo__c = orcamento.TipoDescontoAgravo__c;
			proposta.TipoEvento__c = orcamento.TipoEvento__c;
			proposta.TipoViagem__c = orcamento.TipoViagem__c;
			proposta.TipoVigencia__c = orcamento.TipoVigencia__c;
			proposta.VigenciaFinal__c = orcamento.VigenciaFinal__c;
			proposta.VigenciaInicial__c = orcamento.VigenciaInicial__c;
			proposta.ContractId = orcamento.ContractId;
			proposta.TipoEndosso__c = orcamento.TipoEndosso__c;
			//PLV-3989 - INICIO
			proposta.TaxaComercial__c = orcamento.TaxaComercial__c == null ? null : orcamento.TaxaComercial__c < 0 ? orcamento.TaxaComercial__c : 0;
			proposta.TaxaPura__c = orcamento.TaxaPura__c == null ? null : orcamento.TaxaPura__c < 0 ? orcamento.TaxaPura__c : 0;
			proposta.TaxaTotal__c = orcamento.TaxaTotal__c == null ? null : orcamento.TaxaTotal__c < 0 ? orcamento.TaxaTotal__c : 0;
			proposta.PremioComercial__c = orcamento.PremioComercial__c == null ? null : orcamento.PremioComercial__c < 0 ? orcamento.PremioComercial__c : 0;
			proposta.PremioInformado__c = orcamento.PremioInformado__c == null ? null : orcamento.PremioInformado__c < 0 ? orcamento.PremioInformado__c : 0;
			proposta.PremioPuro__c = orcamento.PremioPuro__c == null ? null : orcamento.PremioPuro__c < 0 ? orcamento.PremioPuro__c : 0;
			proposta.PremioTotal__c = orcamento.PremioTotal__c == null ? null : orcamento.PremioTotal__c < 0 ? orcamento.PremioTotal__c : 0;
			//PLV-3989 - FIM

			proposta.Tipo__c = mapConversaoTipoProposta.get(orcamento.Type);
			if(propostaOriginal != null)
			{
				proposta.Empresa__c = propostaOriginal.Empresa__c;
				proposta.RamoSeguro__c = propostaOriginal.RamoSeguro__c;
			}

			proposta.DescontoAgravoMonetarioComercial__c = orcamento.DescontoAgravoMonetarioComercial__c;
			proposta.DescontoAgravoMonetarioInformado__c = orcamento.DescontoAgravoMonetarioInformado__c;
			proposta.DescontoAgravoMonetarioTecnico__c = orcamento.DescontoAgravoMonetarioTecnico__c;
			proposta.DescontoAgravoPercentualComercial__c = orcamento.DescontoAgravoPercentualComercial__c;
			proposta.DescontoAgravoPercentualInformado__c = orcamento.DescontoAgravoPercentualInformado__c;
			proposta.DescontoAgravoPercentualTecnico__c = orcamento.DescontoAgravoPercentualTecnico__c;
		}
		catch(Exception e)
		{
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularContratante(ContratanteOrcamento__c contratante, ContratanteProposta__c contratanteProposta, ContratanteContrato__c contratanteContrato) //PLV-3872 - INICIO/FIM - Recebimento de parametro
	{
		try
		{
			contratanteProposta.Bairro__c = contratante.Bairro__c;
			contratanteProposta.CEP__c = contratante.CEP__c;
			contratanteProposta.Cidade__c = contratante.Cidade__c;
			contratanteProposta.Complemento__c = contratante.Complemento__c;
			contratanteProposta.Conta__c = contratante.Conta__c;
			contratanteProposta.DescontoAgravoMonetarioComercial__c = contratante.DescontoAgravoMonetarioComercial__c;
			contratanteProposta.DescontoAgravoMonetarioInformado__c = contratante.DescontoAgravoMonetarioInformado__c;
			contratanteProposta.DescontoAgravoMonetarioTecnico__c = contratante.DescontoAgravoMonetarioTecnico__c;
			contratanteProposta.DescontoAgravoPercentualComercial__c = contratante.DescontoAgravoPercentualComercial__c;
			contratanteProposta.DescontoAgravoPercentualInformado__c = contratante.DescontoAgravoPercentualInformado__c;
			contratanteProposta.DescontoAgravoPercentualTecnico__c = contratante.DescontoAgravoPercentualTecnico__c;
			contratanteProposta.Estado__c = contratante.Estado__c;
			contratanteProposta.IOF__c = contratante.IOF__c;
			contratanteProposta.Logradouro__c = contratante.Logradouro__c;
			contratanteProposta.NumeroEndereco__c = contratante.NumeroEndereco__c;
			contratanteProposta.Numero__c = contratante.Numero__c;
			contratanteProposta.Pais__c = contratante.Pais__c;
			//PLV-3989 Fix - INICIO
			contratanteProposta.PremioComercial__c = contratante.PremioComercial__c == null ? null : contratante.PremioComercial__c < 0 ? contratante.PremioComercial__c : 0;
			contratanteProposta.PremioPuro__c = contratante.PremioPuro__c == null ? null : contratante.PremioPuro__c < 0 ? contratante.PremioPuro__c : 0;
			contratanteProposta.PremioTotal__c = contratante.PremioTotal__c == null ? null : contratante.PremioTotal__c < 0 ? contratante.PremioTotal__c : 0;
			contratanteProposta.TaxaComercial__c = contratante.TaxaComercial__c == null ? null : contratante.TaxaComercial__c < 0 ? contratante.TaxaComercial__c : 0;
			contratanteProposta.TaxaPura__c = contratante.TaxaPura__c == null ? null : contratante.TaxaPura__c < 0 ? contratante.TaxaPura__c : 0;
			contratanteProposta.TaxaTotal__c = contratante.TaxaTotal__c == null ? null : contratante.TaxaTotal__c < 0 ? contratante.TaxaTotal__c : 0;
			//PLV-3989 Fix - FIM
			contratanteProposta.TipoDescontoAgravo__c = contratante.TipoDescontoAgravo__c;
			contratanteProposta.TipoEndereco__c = contratante.TipoEndereco__c;
			contratanteProposta.TipoLogradouro__c = contratante.TipoLogradouro__c;
			contratanteProposta.Tipo__c = contratante.Tipo__c;

			//PLV-3989 - INICIO - Parcelamento para cancelamento
			//PLV-3872 - INICIO - Inclusão dos campos
			if(contratanteContrato != null){
				if(contratante.Orcamento__r.PremioTotal__c < 0){
					contratanteProposta.VencimentoPrimeiraParcela__c = System.today().addDays(7); 
					System.debug('4588>>4 ');
					contratanteProposta.FormaPagamento__c = contratanteContrato.FormaPagamento__c;
					contratanteProposta.QuantidadeParcelas__c = 1;
				}
				else{
					contratanteProposta.QuantidadeParcelas__c = 0;
				}
				contratanteProposta.ResponsavelPagamento__c = contratanteContrato.ResponsavelPagamento__c;
				contratanteProposta.TipoResponsavelPagamento__c = contratanteContrato.TipoResponsavelPagamento__c;
				contratanteProposta.PlanoParcelamento__c = contratanteContrato.PlanoParcelamento__c;
				contratanteProposta.CartaoCredito__c = contratanteContrato.CartaoCredito__c;
			}
			//PLV-3872 - FIM
			//PLV-3989 - FIM

		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularGrupoProposta(GrupoOrcamento__c grupo, GrupoProposta__c grupoProposta)
	{

		try
		{
			grupoProposta.IOF__c = grupo.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
			grupoProposta.Descricao__c = grupo.Descricao__c;
			//grupoProposta.IOF__c = grupo.IOF__c;
			grupoProposta.Name = grupo.Name;
			grupoProposta.Numero__c = grupo.Numero__c;
			//grupoProposta.Percentual__c = grupo.Percentual__c;
			grupoProposta.TipoCalculo__c = grupo.TipoCalculo__c;
			grupoProposta.TipoDescontoAgravo__c = grupo.TipoDescontoAgravo__c;
			grupoProposta.QuantidadeVidas__c = grupo.QuantidadeVidas__c;

			//PLV-3989 Fix - INICIO
			grupoProposta.PremioComercial__c = grupo.PremioComercial__c == null ? null : grupo.PremioComercial__c < 0 ? grupo.PremioComercial__c : 0;
			grupoProposta.PremioPuro__c = grupo.PremioPuro__c == null ? null : grupo.PremioPuro__c < 0 ? grupo.PremioPuro__c : 0;
			grupoProposta.PremioTotal__c = grupo.PremioTotal__c == null ? null : grupo.PremioTotal__c < 0 ? grupo.PremioTotal__c : 0;
			grupoProposta.TaxaComercial__c = grupo.TaxaComercial__c == null ? null : grupo.TaxaComercial__c < 0 ? grupo.TaxaComercial__c : 0;
			grupoProposta.TaxaPura__c = grupo.TaxaPura__c == null ? null : grupo.TaxaPura__c < 0 ? grupo.TaxaPura__c : 0;
			grupoProposta.TaxaTotal__c = grupo.TaxaTotal__c == null ? null : grupo.TaxaTotal__c < 0 ? grupo.TaxaTotal__c : 0;
			//PLV-3989 Fix - FIM

			grupoProposta.DescontoAgravoMonetarioComercial__c = grupo.DescontoAgravoMonetarioComercial__c;
			grupoProposta.DescontoAgravoMonetarioInformado__c = grupo.DescontoAgravoMonetarioInformado__c;
			grupoProposta.DescontoAgravoMonetarioTecnico__c = grupo.DescontoAgravoMonetarioTecnico__c;
			grupoProposta.DescontoAgravoPercentualComercial__c = grupo.DescontoAgravoPercentualComercial__c;
			grupoProposta.DescontoAgravoPercentualInformado__c = grupo.DescontoAgravoPercentualInformado__c;
			grupoProposta.DescontoAgravoPercentualTecnico__c = grupo.DescontoAgravoPercentualTecnico__c;

		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: ipopula os ojetos da nova proposta baseados no orçamento
    */
	private void popularSeguradoProposta(SeguradoOrcamento__c segurado, SeguradoProposta__c seguradoProposta)
	{

		try
		{
			seguradoProposta.Conta__c = segurado.Conta__c;
			seguradoProposta.EnderecoBoleto__c = segurado.EnderecoBoleto__c;
			seguradoProposta.IOF__c = segurado.IOF__c;
			seguradoProposta.IPCA__c = segurado.IPCA__c;
			seguradoProposta.Numero__c = segurado.Numero__c;
			seguradoProposta.PorcentagemParticipacaoSegurado__c = segurado.PorcentagemParticipacaoSegurado__c;
			seguradoProposta.PorcentagemParticipacaoVida__c = segurado.PorcentagemParticipacaoVida__c;
			seguradoProposta.QuantidadeParcelas__c = segurado.QuantidadeParcelas__c;
			seguradoProposta.Reenquadramento__c = segurado.Reenquadramento__c;
			seguradoProposta.TipoCusteio__c = segurado.TipoCusteio__c;
			seguradoProposta.TipoDescontoAgravo__c = segurado.TipoDescontoAgravo__c;
			seguradoProposta.TipoResponsavelPagamento__c = segurado.TipoResponsavelPagamento__c;
			seguradoProposta.VencimentoPrimeiraParcela__c = segurado.VencimentoPrimeiraParcela__c;

			//PLV-3989 Fix - INICIO
			seguradoProposta.PremioComercial__c = segurado.PremioComercial__c == null ? null : segurado.PremioComercial__c < 0 ? segurado.PremioComercial__c : 0;
			seguradoProposta.PremioParcela__c = segurado.PremioParcela__c == null ? null : segurado.PremioParcela__c < 0 ? segurado.PremioParcela__c : 0;
			seguradoProposta.PremioPuro__c = segurado.PremioPuro__c == null ? null : segurado.PremioPuro__c < 0 ? segurado.PremioPuro__c : 0;
			seguradoProposta.PremioTotal__c = segurado.PremioTotal__c == null ? null : segurado.PremioTotal__c < 0 ? segurado.PremioTotal__c : 0;
			seguradoProposta.TaxaComercial__c = segurado.TaxaComercial__c == null ? null : segurado.TaxaComercial__c < 0 ? segurado.TaxaComercial__c : 0;
			seguradoProposta.TaxaPura__c = segurado.TaxaPura__c == null ? null : segurado.TaxaPura__c < 0 ? segurado.TaxaPura__c : 0;
			seguradoProposta.TaxaTotal__c = segurado.TaxaTotal__c == null ? null : segurado.TaxaTotal__c < 0 ? segurado.TaxaTotal__c : 0;
			//PLV-3989 Fix - FIM
			seguradoProposta.DescontoAgravoMonetarioComercial__c = segurado.DescontoAgravoMonetarioComercial__c;
			seguradoProposta.DescontoAgravoMonetarioInformado__c = segurado.DescontoAgravoMonetarioInformado__c;
			seguradoProposta.DescontoAgravoMonetarioTecnico__c = segurado.DescontoAgravoMonetarioTecnico__c;
			seguradoProposta.DescontoAgravoPercentualComercial__c = segurado.DescontoAgravoPercentualComercial__c;
			seguradoProposta.DescontoAgravoPercentualInformado__c = segurado.DescontoAgravoPercentualInformado__c;
			seguradoProposta.DescontoAgravoPercentualTecnico__c = segurado.DescontoAgravoPercentualTecnico__c;

		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularBeneficiarioProposta(BeneficiarioSeguradoProposta__c beneficiario, BeneficiarioSeguradoProposta__c beneficiarioProposta)
	{

		try
		{
			beneficiarioProposta.Conta__c = beneficiario.Conta__c;
			beneficiarioProposta.CpfCnpj__c = beneficiario.CpfCnpj__c;
			beneficiarioProposta.CpfPep__c = beneficiario.CpfPep__c;
			beneficiarioProposta.GrauParentesco__c = beneficiario.GrauParentesco__c;
			beneficiarioProposta.GrauParentescoPep__c = beneficiario.GrauParentescoPep__c;
			beneficiarioProposta.ImprimirCertificadoSeguro__c = beneficiario.ImprimirCertificadoSeguro__c;
			beneficiarioProposta.Nome__c = beneficiario.Nome__c;
			beneficiarioProposta.NomePessoaPep__c = beneficiario.NomePessoaPep__c;
			beneficiarioProposta.Participacao__c = beneficiario.Participacao__c;
			beneficiarioProposta.Pep__c = beneficiario.Pep__c;
			beneficiarioProposta.TipoBeneficiario__c = beneficiario.TipoBeneficiario__c;
            beneficiarioProposta.MotivoSemCpfCnpj__c = beneficiario.MotivoSemCpfCnpj__c;

		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularGarantiaProposta(GarantiaOrcamento__c garantia, GarantiaProposta__c garantiaProposta)
	{

		try
		{
			garantiaProposta.IOF__c = garantia.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
			garantiaProposta.Capital__c = garantia.Capital__c;
			garantiaProposta.GarantiaProduto__c = garantia.GarantiaProduto__c;
			garantiaProposta.Garantia__c = garantia.Garantia__c;
			garantiaProposta.LimiteCapital__c = garantia.LimiteCapital__c;
			garantiaProposta.NumeroSerie__c = garantia.NumeroSerie__c;
			garantiaProposta.NumeroSorte__c = garantia.NumeroSorte__c;
			garantiaProposta.Percentual__c = garantia.Percentual__c;
			garantiaProposta.TipoCapital__c = garantia.TipoCapital__c;
			garantiaProposta.TipoDescontoAgravo__c = garantia.TipoDescontoAgravo__c;
            garantiaProposta.CurrencyIsoCode = garantia.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do orcamento 
			garantiaProposta.PremioComercial__c = garantia.PremioComercial__c;
			garantiaProposta.PremioPuro__c = garantia.PremioPuro__c;
			garantiaProposta.PremioTotal__c = garantia.PremioTotal__c;
			garantiaProposta.TaxaComercial__c = garantia.TaxaComercial__c;
			garantiaProposta.TaxaPura__c = garantia.TaxaPura__c;
			garantiaProposta.TaxaTotal__c = garantia.TaxaTotal__c;
			garantiaProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
			garantiaProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
			garantiaProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
			garantiaProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
			garantiaProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
			garantiaProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;

		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularGarantiaContratanteProposta(GarantiaContratanteOrcamento__c garantia, GarantiaContratanteProposta__c garantiaContratanteProposta)
	{
		try
		{
			garantiaContratanteProposta.IOF__c = garantia.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
			garantiaContratanteProposta.Capital__c = garantia.Capital__c;
			garantiaContratanteProposta.GarantiaProduto__c = garantia.GarantiaProduto__c;
			garantiaContratanteProposta.Garantia__c = garantia.Garantia__c;
			garantiaContratanteProposta.NumeroSerie__c = garantia.NumeroSerie__c;
			garantiaContratanteProposta.NumeroSorte__c = garantia.NumeroSorte__c;
			garantiaContratanteProposta.Percentual__c = garantia.Percentual__c;
			garantiaContratanteProposta.TipoDescontoAgravo__c = garantia.TipoDescontoAgravo__c;
            garantiaContratanteProposta.CurrencyIsoCode = garantia.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do contratante do orcamento 
			garantiaContratanteProposta.ValorCotacao__c = garantia.ValorCotacao__c;
			garantiaContratanteProposta.Valor__c = garantia.Valor__c;
			garantiaContratanteProposta.PremioComercial__c = garantia.PremioComercial__c;
			garantiaContratanteProposta.PremioPuro__c = garantia.PremioPuro__c;
			garantiaContratanteProposta.PremioTotal__c = garantia.PremioTotal__c;
			garantiaContratanteProposta.TaxaComercial__c = garantia.TaxaComercial__c;
			garantiaContratanteProposta.TaxaPura__c = garantia.TaxaPura__c;
			garantiaContratanteProposta.TaxaTotal__c = garantia.TaxaTotal__c;
			garantiaContratanteProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
			garantiaContratanteProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
			garantiaContratanteProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
			garantiaContratanteProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
			garantiaContratanteProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
			garantiaContratanteProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;

		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularGarantiaGrupoProposta(GarantiaGrupoOrcamento__c garantia, GarantiasGrupoProposta__c garantiaGrupoProposta)
	{
		try
		{
			garantiaGrupoProposta.IOF__c = garantia.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
			garantiaGrupoProposta.Capital__c = garantia.Capital__c;
			garantiaGrupoProposta.GarantiaProduto__c = garantia.GarantiaProduto__c;
			garantiaGrupoProposta.Garantia__c = garantia.Garantia__c;
			garantiaGrupoProposta.NumeroSerie__c = garantia.NumeroSerie__c;
			garantiaGrupoProposta.NumeroSorte__c = garantia.NumeroSorte__c;
			garantiaGrupoProposta.Percentual__c = garantia.Percentual__c;
			garantiaGrupoProposta.TipoDescontoAgravo__c = garantia.TipoDescontoAgravo__c;
            garantiaGrupoProposta.CurrencyIsoCode = garantia.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do grupo do orcamento 
			garantiaGrupoProposta.ValorCotacao__c = garantia.ValorCotacao__c;
			garantiaGrupoProposta.Valor__c = garantia.Valor__c;
			garantiaGrupoProposta.PremioComercial__c = garantia.PremioComercial__c;
			garantiaGrupoProposta.PremioPuro__c = garantia.PremioPuro__c;
			garantiaGrupoProposta.PremioTotal__c = garantia.PremioTotal__c;
			garantiaGrupoProposta.TaxaComercial__c = garantia.TaxaComercial__c;
			garantiaGrupoProposta.TaxaPura__c = garantia.TaxaPura__c;
			garantiaGrupoProposta.TaxaTotal__c = garantia.TaxaTotal__c;
			garantiaGrupoProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
			garantiaGrupoProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
			garantiaGrupoProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
			garantiaGrupoProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
			garantiaGrupoProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
			garantiaGrupoProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;

		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularGarantiaSeguradoProposta(GarantiaSeguradoOrcamento__c garantia, GarantiaSeguradoProposta__c garantiaSeguradoProposta)
	{
		try
		{
			garantiaSeguradoProposta.IOF__c = garantia.IOF__c;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
			garantiaSeguradoProposta.Capital__c = garantia.Capital__c;
			garantiaSeguradoProposta.GarantiaProduto__c = garantia.GarantiaProduto__c;
			garantiaSeguradoProposta.Garantia__c = garantia.Garantia__c;
			garantiaSeguradoProposta.NumeroSerie__c = garantia.NumeroSerie__c;
			garantiaSeguradoProposta.NumeroSorte__c = garantia.NumeroSorte__c;
			garantiaSeguradoProposta.Percentual__c = garantia.Percentual__c;
			garantiaSeguradoProposta.TipoDescontoAgravo__c = garantia.TipoDescontoAgravo__c;
            garantiaSeguradoProposta.CurrencyIsoCode = garantia.CurrencyIsoCode; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do segurado do orcamento
			garantiaSeguradoProposta.ValorCotacao__c = garantia.ValorCotacao__c;
			garantiaSeguradoProposta.Valor__c = garantia.Valor__c;
			garantiaSeguradoProposta.PremioComercial__c = garantia.PremioComercial__c;
			garantiaSeguradoProposta.PremioPuro__c = garantia.PremioPuro__c;
			garantiaSeguradoProposta.PremioTotal__c = garantia.PremioTotal__c;
			garantiaSeguradoProposta.TaxaComercial__c = garantia.TaxaComercial__c;
			garantiaSeguradoProposta.TaxaPura__c = garantia.TaxaPura__c;
			garantiaSeguradoProposta.TaxaTotal__c = garantia.TaxaTotal__c;
			garantiaSeguradoProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
			garantiaSeguradoProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
			garantiaSeguradoProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
			garantiaSeguradoProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
			garantiaSeguradoProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
			garantiaSeguradoProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;
		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularRemuneracaoProposta(RemuneracaoProposta__c remuneracao, RemuneracaoProposta__c remuneracaoProposta)
	{
		try
		{
			remuneracaoProposta.TipoRemuneracao__c = remuneracao.TipoRemuneracao__c;
			remuneracaoProposta.Percentual__c = remuneracao.Percentual__c;

		}
		catch(Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: popula os ojetos da nova proposta baseados no orçamento
    */
	private void popularFavorecidoRemuneracaoProposta(FavorecidoRemuneracaoProposta__c favorecido, FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta)
	{
		try
		{
			favorecidoRemuneracaoProposta.Conta__c = favorecido.Conta__c;
			favorecidoRemuneracaoProposta.CorretorLider__c = favorecido.CorretorLider__c;
			favorecidoRemuneracaoProposta.Papel__c = favorecido.Papel__c;
			favorecidoRemuneracaoProposta.Participacao__c = favorecido.Participacao__c;
			favorecidoRemuneracaoProposta.Susep__c = favorecido.Susep__c;
			favorecidoRemuneracaoProposta.SusepEmissao__c = favorecido.SusepEmissao__c;
			favorecidoRemuneracaoProposta.SusepOficialCorretor__c = favorecido.SusepOficialCorretor__c;
			favorecidoRemuneracaoProposta.SusepOrcamento__c = favorecido.SusepOrcamento__c;
			favorecidoRemuneracaoProposta.DadosCorretor__c = favorecido.DadosCorretor__c;
		}
		catch (Exception e){
			throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
		}
	}

	/* ---------------------------------- MODELOS ----------------------------------------------------------------- */

	/* ---------------------------------- HELPERS ----------------------------------------------------------------- */

	/*
    *  @author Everymind - Sprint 23
    *  @Descrição: helper p/ carregas os registros complementares p/ criaçãoda nova proposta
    */
	private void buscarRegistrosDominios()
	{

		// Declara variveis
		Set<Id> setContratante = new Set<Id>();
		Set<Id> setSegurado = new Set<Id>();
		List<GrupoOrcamento__c> grupos = new List<GrupoOrcamento__c>();
		List<GrupoOrcamento__c> gruposTemp;
		List<GarantiaSeguradoOrcamento__c> garantias;
		List<GarantiaContratanteOrcamento__c> garantiasContratante;
		List<GarantiaContratanteOrcamento__c> garantiasContratanteTemp;

		// Varre os contratantes e monta a chave p/ contulta dos grupos filhos dele
		for(ContratanteOrcamento__c contratante : orcamento.ContratantesOrcamento__r)
			setContratante.add(contratante.Id);

		grupos = daoGrupoOrcamento.listarGrupoOrcamento(setContratante);
		garantiasContratante = daoContratanteOrcamento.listarGarantias(setContratante);

		// Varre os segurados dos grupos e monta a chave p/ contulta das garantias do segurado filhos dele
		for(GrupoOrcamento__c grupo : grupos)
		{
			for(SeguradoOrcamento__c segurado : grupo.SeguradosOrcamento__r)
				setSegurado.add(segurado.Id);
		}

		// Monta os mapas de grupo e garantias do segurado do orcamento
		for(ContratanteOrcamento__c contratante : orcamento.ContratantesOrcamento__r)
		{
			gruposTemp = new List<GrupoOrcamento__c>();
			garantiasContratanteTemp = new List<GarantiaContratanteOrcamento__c>();

			for(GrupoOrcamento__c grupo : grupos)
			{
				if(contratante.Id == grupo.ContratanteOrcamento__c)
					gruposTemp.add(grupo);
			}

			for(GarantiaContratanteOrcamento__c garantiaContatante : garantiasContratante)
			{
				if(contratante.Id == garantiaContatante.ContratanteOrcamento__c)
					garantiasContratanteTemp.add(garantiaContatante);
			}

			for(GrupoOrcamento__c grupo : gruposTemp)
			{
				for(SeguradoOrcamento__c segurado : grupo.SeguradosOrcamento__r)
				{
					garantias = new List<GarantiaSeguradoOrcamento__c>();
					for(GarantiaSeguradoOrcamento__c garantia : daoGrupoOrcamento.listarGarantiasSegurados(setSegurado))
					{
						if(segurado.Id == garantia.SeguradoOrcamento__c)
							garantias.add(garantia);
					}
					mapGarantiaSeguradoOrcamento.put(segurado.Id, garantias);
				}
			}

			mapGarantiaContratanteOrcamento.put(contratante.Id, garantiasContratanteTemp);
			mapGruposOrcamento.put(contratante.Id, gruposTemp);
		}
	}
	//PLV-4850 - Inicio
	private void popularEnderecoSegurado(Quote propostaOriginal, SeguradoProposta__c sfSegurado){
		seguradoProposta__c seguradoProposta = [SELECT 	UFResidencial__c, paisResidencial__c, numeroResidencial__c, logradouroResidencial__c, 
														ComplementoResidencial__c, CidadeResidencial__c, cepResidencial__c, bairroResidencial__c
												FROM	seguradoProposta__c 
												WHERE 	GrupoProposta__r.ContratanteProposta__r.Proposta__r.Id =: propostaOriginal.Id ];

		sfSegurado.logradouroResidencial__c    = seguradoProposta.logradouroResidencial__c;
		sfSegurado.numeroResidencial__c        = seguradoProposta.numeroResidencial__c;
		sfSegurado.ComplementoResidencial__c   = seguradoProposta.ComplementoResidencial__c;
		sfSegurado.bairroResidencial__c        = seguradoProposta.bairroResidencial__c;
		sfSegurado.CidadeResidencial__c        = seguradoProposta.CidadeResidencial__c;
		sfSegurado.UFResidencial__c            = seguradoProposta.UFResidencial__c;
		sfSegurado.paisResidencial__c          = seguradoProposta.paisResidencial__c;
		sfSegurado.cepResidencial__c           = seguradoProposta.cepResidencial__c;

    }
	//PLV-4850 - Fim
	/* ---------------------------------- FIM HELPERS ------------------------------------------------------------- */
}