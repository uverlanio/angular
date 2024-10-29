/**
* Proposta Façade
* @author Eric Tunú @ 14/06/2018
*
**/
public class PropostaFacade
{
  private final String                            ORIGEM                      = 'INT';
  private final String                            SIM                         = 'SIM';
  private final String                            PRINCIPAL                   = 'PRI';
  private final String                            PESSOA_FISICA               = 'FIS';
  private final String                            PESSOA_JURIDICA             = 'JUR';
  private final String                            ORIGEM_CRITICA_ODM          = 'ODM';
  private final String                            STATUS_CRITICA_PENDENTE     = 'Pendente';
  private final Map<String, RecordType>           mapRecordType               = new Map<String, RecordType>();
  private final Map<String, String>               mapTipoViagem               = new Map<String, String> { 'INT' => 'Internacional',   'NAC'  => 'Nacional' };
  private final Map<String, String>               mapTipoProposta             = new Map<String, String> { 'PRI' => 'Principal',       'DEP'  => 'Dependente'};
  private final Map<String, String>	              mapTipoLogradouro           = new Map<String, String> { 'AL'  => 'Alameda',         'AV'   => 'Avenida',            'R'   => 'Rua'};
  private final Map<String, String>               mapTipoVigencia             = new Map<String, String> { 'Anual' => 'Anual',           'Plurianual'  => 'Plurianual',         'Prazo curto' => 'Prazo curto', 'Periódico' => 'Periódico' };
  private final Map<String, String>               mapMeioComercializacao      = new Map<String, String> { 'PCL' => 'PCL', 'ARQ'  => 'ARQ' , 'OUT' => 'OUT', 'APP' => 'APP', 'CO2' => 'CO2', 'COL' => 'COL', 'CQT' => 'CQT', 'PMC' => 'PMC', 'PPW' => 'PPW', 'SFC' => 'SFC', 'VDO' => 'VDO', 'WBS' => 'WBS', 'PAR' => 'PAR'};//PLV-4550 INICIO/FIM
  private final Map<String, String>               mapStatus                   = new Map<String, String> { 'AAC' => 'Em criação',      'RNV'  => 'Aguardando análise', 'XXX' => 'Em análise', 'VVV' => 'Em aprovação', 'AAA' => 'Contratada', 'SQQ' => 'Devolvida' };
  private final Map<String, String>               mapTipoEvento               = new Map<String, String> { 'SHO' => 'Shows', '          CIN'  => 'Cinema',             'CUR' => 'Cursos por período determinado', 'ROD' => 'Eventos com rodeio', 'ESP' => 'Eventos esportivos', 'ESC' => 'Excursões e passeios turísticos', 'FEI' => 'Exposições e feiras', 'FOR' => 'Formaturas e festas', 'TEA' => 'Peças de teatro e filmagens', 'TEA' => 'Peças de teatro e filmagens' };
  //PLV 4736 FIX 4
  private final Map<String, Integer>              mapStatusConsultaProposta   = new Map<String, Integer> {'Contratada' => 7, 'Emis.restituição' => 3, 'Parc.restituição' =>  4, 'Cobrado' => 6, 'Cancelamento' => 20,  'Cancelamento por sinistro' => 22, 'Reativação' =>50};
  //PLV 4736 FIX 4
  private final Map<Integer, CriticaParceiro__c>  mapCriticas                 = new Map<Integer, CriticaParceiro__c>(); // Metadado não será mais utilizado (REF: #PLV-1506 e PLV-1507)  
  private static List<CriticaParceiro__c>         lstCriticasPropostaParceiro = new List<CriticaParceiro__c>();
  private static AccountBO                        contaBo                     = AccountBO.getInstance();

  

  private static String JsonAdesaoPayload;

  private static final PropostaFacade classInstance;
  static { classInstance = new PropostaFacade(); }
  private PropostaFacade() {}
  public static PropostaFacade getInstance() { return classInstance; }

  public RetornoPropostaRestTO.ValidacaopropostaTO processaPayload(String payload, RetornoPropostaRestTO.ValidacaopropostaTO retorno)
  {
    System.debug('payload123 ' +payload);
    JsonAdesaoPayload = payload;
    EmissaoTO.PayloadTO objPayload = new EmissaoTO.PayloadTO();

    try
    {
      objPayload = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);
      retorno = this.gerarProposta(objPayload);
	  retorno.proposta.indice = objPayload.proposta.indice;   //PLV-3285
    }
    catch(Exception e)
    {
      throw e; //new PropostaException('Origem: PropostaFacade/processaPayload \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }

    return retorno;
  }

  public RetornoPropostaRestTO.ValidacaopropostaTO gerarProposta(EmissaoTO.PayloadTO objPayload)
  {
    Savepoint sp = Database.setSavepoint();

    List<RemuneracaoProposta__c>                remuneracoesProposta            = new List<RemuneracaoProposta__c>();
    List<RemuneracaoOrcamento__c>               remuneracoesOrcamento           = new List<RemuneracaoOrcamento__c>();
    List<FavorecidoRemuneracaoProposta__c>      lstFavorecidos                  = new List<FavorecidoRemuneracaoProposta__c>();
    Map<String, RemuneracaoProposta__c>         mapRemuneracaoPropostas         = new Map<String, RemuneracaoProposta__c>();
    List<ContratanteProposta__c>                contratantesProposta            = new List<ContratanteProposta__c>();
    List<SeguradoProposta__c>                   seguradosProposta               = new List<SeguradoProposta__c>();
    List<GrupoProposta__c>                      gruposContratanteProposta       = new List<GrupoProposta__c>();
    List<CriticaProposta__c>                    pendenciasProposta              = new List<CriticaProposta__c>();
    List<CartaoCredito__c>                      cartoesSeguradosProposta        = new List<CartaoCredito__c>();
    List<InformacaoBancaria__c>                 infoBancariasSeguradosProposta  = new List<InformacaoBancaria__c>();
    Opportunity                                 orcamento                       = new Opportunity();
    Modalidade__c                               modalidade                      = new Modalidade__c();
    RamoSeguro__c                               ramoSeguro                      = new RamoSeguro__c();
    Set<string>                                 setContas                       = new Set<string>();
    Set<string>                                 setTipoRemuneracao              = new Set<string>();
    Set<string>                                 setFormasPGTO                   = new Set<string>();
    Set<string>                                 setPlanosParcelamento           = new Set<string>();
    Set<String>                                 setSuepsCorretores              = new Set<string>();
    Map<String, Account>                        mapContas                       = new Map<String, Account>();
      // PLV-2352-29 INICIO
    Map<String, Account>                        mapContasNaoAtualizar           = new Map<String, Account>();
      // PLV-2352-29 FIM
    Map<String, DadosCorretor__c> mapDadosCorretores = new Map<String, DadosCorretor__c>();
    Map<String,EmissaoTO.CoberturaTO> mapGarantiasPorNumeroContratanteGrupoSeguradoSigla = new Map<String, EmissaoTO.CoberturaTO>();

    //impelementações p/ receber o json massificados
    Quote                                       proposta;
    Product2                                    produto;
    Parceiro__c                                 parceiro;
    Account                                     contaParceiro;
    FormaPagamento__c                           formaPgtoParceiro;
    List<RemuneracaoProdutoParceiro__c>         listaRemuneracaoParceiro;
    RetornoPropostaRestTO.ValidacaopropostaTO   retorno = new RetornoPropostaRestTO.ValidacaopropostaTO();
    retorno.proposta 									          = new RetornoPropostaRestTO.PropostaTO();
    retorno.devolutivas 							        	= new List<RetornoPropostaRestTO.DevolutivasTO>();
    Quote                                       propostaExcluir;
    // INICIO | PLV-2356
    List<Quote>                                 propostaRefExcluir;
    // FIM | PLV-2356

    try
    {
		// Inicio VEP-393 
		// Numeração de Proposta Renne

    //VEP-1224 DEBUG INICIO
    System.debug('VEP-1224 objPayload >>>>>>>' + objPayload);
    //VEP-1224 DEBUG INICIO
		if (objPayload.proposta.numero != null) {
			retorno.proposta.numero = objPayload.proposta.numero; //TKCL-246 INICIO-FIM
		} else {
			retorno.proposta.numero = this.gerarNumeroProposta(1,18); //TKCL-246 INICIO-FIM
		}

			
		if (objPayload.proposta.origem != null ) {
			retorno.proposta.origem = objPayload.proposta.origem;
		} else {
			retorno.proposta.origem = 18;
		}
		// Fim VEP-393 - Numeração de Proposta BRB

        // inclui as datas p/ passar nas validações do payload e nao interferir no fluxo generico
        if(objPayLoad.proposta.segmento != 'Viagem')
        objPayload.proposta.dataCriacaoPortal   = String.ValueOf(Date.today());
        //objPayload.proposta.dataEmissao         = String.ValueOf(Date.today());

        //VIAG-232 INICIO
        if(objPayLoad.proposta.segmento != 'Viagem'){
          //Busca parceiro e valida se o parceiro é informado no json
          parceiro = ParceiroDAO.getInstance().obtemParceiro(objPayload.proposta.parceiro);
          //Recupera todas as criticas mapeadas de um parceiro 
          lstCriticasPropostaParceiro = CriticaParceiroDAO.getInstance().buscarCriticasParceiro(new Set<String>{objPayload.proposta.parceiro});
        }
		    system.debug('gfs lstCriticasPropostaParceiro ' + lstCriticasPropostaParceiro);	
        //VIAG-232 FIM

        if(parceiro != null){
            for(CriticaParceiro__c critica : lstCriticasPropostaParceiro){
                mapCriticas.put(Integer.ValueOf(critica.Name), critica);
            }
        }
        else{
            retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(null, ORIGEM, 'Parceiro não encontrado', null));
        }

        // Verifica se existem criticas cadastradas para esse parceiro
        if(mapCriticas.isEmpty()){
            retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(null, origem, 'Criticas do parceiro ' + objPayload.proposta.parceiro + ' não cadastradas', null));
        }

        // valida cpfs e cnpjs do payload 
        if(retorno.devolutivas.isEmpty()){
            RetornoPropostaRestTO.DevolutivasTO devolutiva = PropostaRegrasValidacao.getInstance().validaCpfsCnpjsPayload(objPayload, mapCriticas, origem);

            if(devolutiva != null){
                retorno.devolutivas.add(devolutiva);
            }
        }
		system.debug('gfs  retorno.devolutivas ' +  retorno.devolutivas);
        
        //Verifica se o produto existe e está OK
        if(retorno.devolutivas.isEmpty()){
          produto = ProductDAO.getInstance().obterPorCodigo(String.valueOf(objPayload.proposta.codigoProdutoVida));
		
          if(produto == null){
            retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(null, ORIGEM, 'Produto não encontrado', null));
          }
          else{
            //Verifica se o produto encontrado está ativo
            if(produto.Status__c != 'Ativo'){
                retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(null, origem, 'Proposta não pode ser criada, produto associado esta inativo.', null));
            }

            if(produto.VigenciaFinal__c != null){
                Date dataCriacaoPortal = Date.valueOf(objPayload.proposta.dataCriacaoPortal);

                //Valida vigencia do produto
                if(dataCriacaoPortal < produto.VigenciaInicial__c || dataCriacaoPortal > produto.VigenciaFinal__c){
                  retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(null, origem, 'O produto está fora da vigência.', null));
                }
            } 
          }    
        }
		
        //Valida as regras de proposta
        if(retorno.devolutivas.isEmpty()){
            PropostaRegrasValidacao.getInstance().validaProposta(retorno, objPayload, origem, mapCriticas);   
        }
        
        //Verifica se a proposta já existe e não pode mais ser alterada
        if(retorno.devolutivas.isEmpty()){
            List<Quote> propostaRef = QuoteDAO.getInstance().obterPropostaPorName(QuoteBO.getInstance().gerarNameProposta(String.valueOf(objPayload.proposta.origem),objPayload.proposta.numero));

                if(!propostaRef.isEmpty())
                {
                    // INICIO | PLV-2356
                    // PLV-2496 INICIO
                    if(propostaRef[0].Status != 'Devolvida' && propostaRef[0].Status != 'Em criação'){
                        // Verifica se a proposta anterior foi emitida pelo mesmo lote
                        if(objPayload.proposta.idlote == propostaRef[0].Lote__c) {
                            retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(mapCriticas.get(0), origem, null, null));
                        }else{
                            retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(mapCriticas.get(70), origem, null, null));
                        }
                    }else{
                        propostaRefExcluir = propostaRef;
                    }
                    // PLV-2496 FIM
                    // FIM | PLV-2356
                }
            }

        //Verifica se há remunerações para o produto e parceiro
        if(retorno.devolutivas.isEmpty()){
            listaRemuneracaoParceiro = ParceiroDAO.getInstance().buscarRemuneracaoProdutosPorParceiro(new Set<Id>{produto.Id}, parceiro.Id);

            if(listaRemuneracaoParceiro.isEmpty()){
              retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(null, origem, 'Remunerações do Parceiro não encontradas.', null));
            }
        }
        
        // VALIDA PREMIO PELO DESCONTO AGRAVO DO NO DE CALCUL
        if(retorno.devolutivas.isEmpty()){
            RetornoPropostaRestTO.DevolutivasTO devolutiva = PropostaRegrasValidacao.getInstance().validaPremioDescontoAgravoMassificados(origem, objPayload.calculo, produto, mapCriticas);

            if(devolutiva != null){
                retorno.devolutivas.add(devolutiva);
            }
        }

        //Se houver devolutivas abortivas, excucuta rollback e executa retorno
        if(retorno.devolutivas.size() > 0){
            Database.rollback(sp);
            return retorno;
        }

        // valida retorno aceitacao (ODM) - nao abortiva   
        retorno.devolutivas = PropostaRegrasValidacao.getInstance().validaRetornoAceitacaoProposta(objPayload, 'ODM', lstCriticasPropostaParceiro);
    
        setFormasPGTO.add(parceiro.FormaPagamento__r.Codigo__c);
        contaParceiro = AccountDAO.getInstance().buscarContasComFilhos(new Set<Id>{parceiro.Conta__c})[0];
        mapContas.put(contaParceiro.IdExterno__c, contaParceiro);
        // PLV-2352-29 INICIO
        mapContasNaoAtualizar.put(contaParceiro.IdExterno__c, contaParceiro);
        // PLV-2352-29 FIM
        
        //obtem os tipos de registro do objeto
         // PLV-4290 - COMPLEMENTO - INICIO
         for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Quote')){
          mapRecordType.put(tipo.DeveloperName, tipo);
          if(objPayLoad.proposta.segmento == 'VidaMassificados' && tipo.DeveloperName == 'VidaIndividual'){
            mapRecordType.put('VidaMassificados', tipo);
          }
        }
        // PLV-4290 - COMPLEMENTO - FIM
        //Varre a TO p/ obter todas as contas
        this.mapeiaSetIds(objPayload, setContas, setTipoRemuneracao, setFormasPGTO, setPlanosParcelamento, setSuepsCorretores);

        for(Account conta : AccountDAO.getInstance().buscarContasPorIdExterno(setContas))
            mapContas.put(conta.IdExterno__c, conta);

        for(DadosCorretor__c corretor : DadosCorretorDAO.getInstance().buscarCorretorPorSusep(setSuepsCorretores))
            mapDadosCorretores.put(corretor.Name, corretor);

        //REMUNERAÇÃO ------------------------------------
        Map<String, TipoRemuneracao__c> mapTiposRemuneracao = new Map<String, TipoRemuneracao__c>();

        Set<Id> setTipoRemuneracaoIds = new Set<Id>();
        for(TipoRemuneracao__c tipo : TipoRemuneracaoDAO.getInstance().listar(setTipoRemuneracao))
        {
            mapTiposRemuneracao.put(tipo.Codigo__c, tipo);
            setTipoRemuneracaoIds.add(tipo.Id);
        }
		system.debug('gfs  mapTiposRemuneracao ' +  mapTiposRemuneracao);
        
        Map<String, RemuneracaoProduto__c> mapRemuneracaoProduto = new Map<String, RemuneracaoProduto__c>();
        for(RemuneracaoProduto__c remProd : RemuneracaoProdutoDAO.getInstance().buscarRemuneracaoProdutoPorTiposRemuneracao(setTipoRemuneracaoIds))
            mapRemuneracaoProduto.put(remProd.Id, remProd);
        system.debug('gfs  mapRemuneracaoProduto ' +  mapRemuneracaoProduto);
        
        mapGarantiasPorNumeroContratanteGrupoSeguradoSigla = montarMapaGarantiasCalculo(objPayload, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
		system.debug('gfs mapGarantiasPorNumeroContratanteGrupoSeguradoSigla' + mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
        //Verifica se não tem Orçamento. Se não tiver, cria
        
        
        system.debug('gfs objPayload.proposta.numeroOrcamento' + objPayload.proposta.numeroOrcamento);
        system.debug('String.isBlank(objPayload.proposta.numeroOrcamento) ' + String.isBlank(objPayload.proposta.numeroOrcamento));
         
        if(String.isBlank(objPayload.proposta.numeroOrcamento)){
            system.debug('gfs orcamento 1 ' + orcamento);
            system.debug('gfs objPayload 1 ' + objPayload);
            system.debug('gfs produto 1 ' + produto);
            system.debug('gfs mapGarantiasPorNumeroContratanteGrupoSeguradoSigla 1 ' + mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
            orcamento = gerarOrcamento(objPayload, produto, parceiro, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
			system.debug('gfs orcamento 2' + orcamento);
            try
            {
              system.debug('gfs entrou try');  
              remuneracoesOrcamento = RemuneracaoFacade.getInstance().criaRemuneracaoOrcamento(
                      mapMeioComercializacao.get(objpayload.proposta.meioComercializacao),
                      objPayload.proposta.remuneracoes,
                      orcamento.Id,
                      listaRemuneracaoParceiro,
                      mapContas,
                      mapTiposRemuneracao 
                );
              system.debug('gfs remuneracoesOrcamento ' + remuneracoesOrcamento);
              insert remuneracoesOrcamento;
            }
            catch(Exception e)
            {
              system.debug('entrou exception remuneracoes');
              Database.rollback(sp);
              throw new PropostaException('Origem: PropostaFacade/remuneracoesOrcamento - Causa: ' + e.getCause() + ' - linha: ' +  e.getLineNumber() + ' - Mensagem: ' + e.getMessage());
            }
        }
        else{
            system.debug('gfs entrou else');
            orcamento = OpportunityDAO.getInstance().obterOportunidadesPorNumero(String.valueOf(objPayload.proposta.numeroOrcamento.leftPad(8,'0')));
        	system.debug('gfs orcamento '+ orcamento);
        }
        
        //obtem os objetos relacionados a proposta (LOOCKUP's)
        if(objPayload.proposta.modalidade != null)
            modalidade = ModalidadeDAO.getInstance().obter(String.valueOf(objPayload.proposta.modalidade));

        if(objPayload.proposta.ramoSeguro != null)
            ramoSeguro = RamoSeguroDAO.getInstance().obterRamoPorCodigo(String.valueOf(objPayload.proposta.ramoSeguro));

        //mapeia proposta
        proposta = mapeiaProposta(objPayload, orcamento, modalidade, ramoSeguro, produto);
		system.debug('gfs proposta' + proposta);
        
      if(propostaExcluir != null)
      {
        if(propostaExcluir.HistoricoStatus__c == null)
          proposta.HistoricoStatus__c = propostaExcluir.Status + '; ';
        else
          proposta.HistoricoStatus__c = proposta.HistoricoStatus__c + '; '+ propostaExcluir.Status;
      }

      CanalDistribuicao__c canalDistribuicao = CanalDistribuicaoDAO.getInstance().buscarCanalDistribuicaoOrcamentoPorSigla(objPayload.proposta.canalDistribuicao);
      if(canalDistribuicao != null)
        proposta.CanalDistribuicao__c = canalDistribuicao.Id;
     
      this.incluiDadosCalculo(objPayload.calculo, proposta, null, null, null, null, null, null, null);

      // INICIO | PLV-2356
      if (propostaRefExcluir != null){
        if (propostaRefExcluir.size() > 0){
            Opportunity orcamentoRefExcluir = OpportunityBO.getInstance().buscarOportunidade(propostaRefExcluir[0].OpportunityId);

            delete propostaRefExcluir;
            delete orcamentoRefExcluir;
        }
      }
      // FIM | PLV-2356

	  system.debug('gfs proposta' + proposta);
      insert proposta;
      Id chaveProposta = proposta.Id;
      
      //PLV-972///////////////////////////////////////////////////////////////////////////////////////////////////////
      //inclui no objeto criticas o retorno, caso NÒ != null
      System.debug('propostaFacade >> objPayload.retornoAceitacao: ' + objPayload.retornoAceitacao);
      if(objPayload.retornoAceitacao != null)
      {
        if(objPayload.retornoAceitacao.analises == null)
          objPayload.retornoAceitacao.analises = new List<EmissaoTO.analiseTO>();

        if(objPayload.retornoAceitacao.recusas == null)
          objPayload.retornoAceitacao.recusas = new List<EmissaoTO.RecusaTO>();

        if(objPayload.retornoAceitacao.pendencias == null)
          objPayload.retornoAceitacao.pendencias = new List<EmissaoTO.PendenciaTO>();

        if(objPayload.retornoAceitacao.avisos == null)
          objPayload.retornoAceitacao.avisos = new List<EmissaoTO.AvisoTO>();

        if( !objPayload.retornoAceitacao.analises.isEmpty() || 
            !objPayload.retornoAceitacao.recusas.isEmpty() || 
            !objPayload.retornoAceitacao.pendencias.isEmpty() || 
            !objPayload.retornoAceitacao.avisos.isEmpty())
        {
          try
          {
            List<CriticaProposta__c> lstCriticasProposta = CriticasFacade.getInstance().parseCriticasRetornoAceitacaoTO(objPayload.retornoAceitacao, chaveProposta, ORIGEM_CRITICA_ODM);
            
            insert lstCriticasProposta;

            proposta.Status = 'Devolvida';
            orcamento.StageName = 'Devolvida';
          }
          catch(Exception e)
          {
            throw new PropostaException('PropostaFacade/gerarProposta/CriticasRetornoAceitacao \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
          }

          try
          {
            system.debug('gfs orcamento ' + orcamento);
            system.debug('gfs proposta ' + proposta);
            update orcamento;
            update proposta;
          }
          catch(Exception e)
          {
            throw new PropostaException('PropostaFacade/gerarProposta/Alterar Satus Proposta p/ Devolvida \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
          }
        }
      }
      /////////////////////////////////////////////////////////////////////////////////////////////////////////
      // PLV-2312 INICIO
      // PLV-2312 FIM
      // GERAR CRITICAS DA PROPOSTA ------------------------------------
      if(objPayload.proposta.pendencias != null)
      {
        pendenciasProposta = CriticasFacade.getInstance().criaPendenciasProposta(objPayload.proposta.pendencias, chaveProposta);

        try { 
            system.debug('gfs pendenciasProposta ' + pendenciasProposta);
            insert pendenciasProposta; 
        }
        catch(Exception e){
          throw new PropostaException('Origem: PropostaFacade/gerarProposta/pendencia proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
      }
      // END -----------------------------------------------------------
      
      // gera as remunerações da proposta
      remuneracoesProposta = RemuneracaoFacade.getInstance().criaRemuneracaoProposta(objPayload.proposta.remuneracoes, proposta.Id, mapTiposRemuneracao);
      system.debug('gfs remuneracoesProposta' + remuneracoesProposta);
      insert remuneracoesProposta; 
     
        // PLV-2352-29 INICIO
      lstFavorecidos.addAll(RemuneracaoFacade.getInstance().criaFavorecidosRemuneracaoProposta(objPayload.proposta.remuneracoes, mapContas, mapDadosCorretores, mapContasNaoAtualizar));
        // PLV-2352-29 FIM
        // 
      system.debug('gfs lstFavorecidos' + lstFavorecidos);
      insert lstFavorecidos;

      // END --------------------------------------------------------------

      Map<String, FormaPagamento__c>      mapFormasPgto           = new Map<String, FormaPagamento__c>();
      Map<String, PlanoParcelamento__c>   mapPlanoParcelamento    = new Map<String, PlanoParcelamento__c>();

      for(FormaPagamento__c forma : FormaPagamentoDAO.getInstance().listar(setFormasPGTO))
        mapFormasPgto.put(forma.Codigo__c, forma);

      for(PlanoParcelamento__c plano : PlanoParcelamentoDAO.getInstance().listar())
        mapPlanoParcelamento.put(plano.DescricaoMeioRecebimento__c, plano);
      
      // GERAR SEGURADO DA PROPOSTA ---------------------------------------
      ContratantesProposta = criarContratantesProposta(objPayload, proposta, objPayload.proposta.contratantes, chaveProposta, mapContas, mapFormasPgto, mapPlanoParcelamento, objpayload.calculo, parceiro, contaParceiro, produto );

      // END -------------------------------------------------------------

      //inclui os dados bancarios do responsavel de pagamento
      Map<Id, ContratanteProposta__c> mapSeguradosProposta = new Map<Id, ContratanteProposta__c>();
      for(ContratanteProposta__c contratante : ContratantesProposta)
        mapSeguradosProposta.put(contratante.Id, contratante);


      // GERAR DADOS PAGAMENTO SEGURADO DA PROPOSTA -------------------------
      Map<String, CartaoCredito__c>       mapCartoes              = new Map<String, CartaoCredito__c>();
      Map<String, InformacaoBancaria__c>  mapInformacaoBancaria   = new Map<String, InformacaoBancaria__c>();

      for(EmissaoTO.ContratanteTO contratanteTO : objPayload.proposta.contratantes)
        gerarMapaDadosPagamentoSegurado(objPayload, contratanteTO, chaveProposta, mapContas, mapCartoes, mapInformacaoBancaria, cartoesSeguradosProposta, contaParceiro);


      // END -------------------------------------------------------------
      

      for(EmissaoTO.ContratanteTO contratante : objPayload.proposta.contratantes)
      {
        ContratanteProposta__c seguradoSF = mapSeguradosProposta.get(contratante.objSf.Id);

        if(contaParceiro.InformacoesBancarias__r.isEmpty())
          throw new PropostaException('informação bancaria do responsavel pagamento contratante (conta do parceiro) não encontrada. ');
        else
        {
          for(InformacaoBancaria__c informacaoBancaria : contaParceiro.InformacoesBancarias__r)
          {
            if(informacaoBancaria.Principal__c)
            {
              seguradoSF.InformacaoBancaria__c = informacaoBancaria.Id;
              continue;
            }
          }
        }

        // Valida se existe a informacao bancaria
        if(seguradoSF.InformacaoBancaria__c == null){
          throw new PropostaException('informação bancaria do responsavel pagamento contratante (conta do parceiro) não encontrada. ');
        }

      }
      

      try { 
        system.debug('gfs mapSeguradosProposta '+ mapSeguradosProposta);
        update mapSeguradosProposta.values(); 
      }
      catch(Exception e)
      {
        throw new PropostaException('Origem: PropostaFacade/gerarProposta/update contratante proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
      }
      
      // GERAR GRUPOS SEGURADO DA PROPOSTA -------------------------------
      for(EmissaoTO.ContratanteTO contratante : objPayload.proposta.contratantes)
      {
        for (EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          GrupoProposta__c grupoProposta = new GrupoProposta__c();

          grupoProposta.Name                = grupo.nome;
          grupoProposta.IOF__c              = grupo.iof!=null ? grupo.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
          grupoProposta.Quantidadevidas__c  = integer.valueOf(grupo.qtdeVidas); //PLV-2666 - INICIO/FIM - alterado nome da variável, pois foi alterado na classe EmissaoTO
          grupoProposta.TipoCalculo__c      = grupo.tipoCalculo;
          grupoProposta.ContratanteProposta__c = contratante.objSf.Id;
          grupoProposta.ContratanteProposta__c = contratante.objSf.Id;
          grupoProposta.Numero__c               = Integer.valueOf(grupo.numero);
          grupo.objSF                    = grupoProposta;

          this.incluiDadosCalculo(objPayload.calculo, null, null, grupoProposta, null, null, null, null, null);  
          gruposContratanteProposta.add(grupoProposta);
        }
      }

      try { 
        system.debug('gfs gruposContratanteProposta '+ gruposContratanteProposta);
        insert gruposContratanteProposta; 
      }
      catch(Exception e)
      {
        throw new PropostaException('Origem: PropostaFacade/gerarProposta/insert grupo contratante proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
      }

      // END -------------------------------------------------------------

      // GERAR segurados GRUPOS SEGURADO DA PROPOSTA --------------------------
      //valida se conta existe se não existe cria conta pra associar a segurado
      List<Account> lstContasSegurado = new List<Account>();

      for (EmissaoTO.ContratanteTO contratante : objPayload.proposta.contratantes)
      {
        Account responsavelPGTO = contaParceiro;
        for(EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          for (EmissaoTO.SeguradoTO segurado : grupo.segurados)
          {
            String idExterno = montarChavePessoa(segurado.pessoa);
            if(mapContas.get(idExterno) == null)
              lstContasSegurado.add(contaBo.gerarParseConta(segurado, responsavelPGTO.Id, false));
          }
        }
        
      }
      
      // INSERT
      
      try { 
        system.debug('lstContasSegurado' + lstContasSegurado);
        insert lstContasSegurado; 
      }
      catch(Exception e)
      {
        throw new PropostaException('Origem: PropostaFacade/gerarProposta/insert contas da segurado proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
      }

      // END -------------------------------------------------------------

      for (Account conta : lstContasSegurado){
        mapContas.put(conta.IdExterno__c, conta);
      }   

      // GERAR DADOS PAGAMENTO VIDA DA PROPOSTA -------------------------
      for(EmissaoTO.ContratanteTO contratanteTO : objPayload.proposta.contratantes)
      {
        // gerarMapaDadosPagamentoSegurado(objPayload, contratanteTO, chaveProposta, mapContas, mapCartoes, mapInformacaoBancaria, cartoesSeguradosProposta, contaParceiro);
        for(EmissaoTO.GrupoTO grupoTO : contratanteTO.grupos)
        {
          for(EmissaoTO.SeguradoTO SeguradoTO : grupoTO.segurados){
            gerarMapaDadosPagamentoSegurado(objPayload, SeguradoTO, chaveProposta, mapContas, mapCartoes, mapInformacaoBancaria, cartoesSeguradosProposta, contaParceiro);
          }  
        }
      }

      List<SeguradoProposta__c> seguradosPropostaParaInserir = new List<SeguradoProposta__c>();
      for (EmissaoTO.ContratanteTO contratante : objPayload.proposta.contratantes)
      {
        for (EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          for (EmissaoTO.SeguradoTO segurado : grupo.segurados)
          {
            SeguradoProposta__c seguradoProposta1 = new SeguradoProposta__c();
            String IdExterno = montarChavePessoa(segurado.pessoa);
            Account conta = mapContas.get(IdExterno);
            seguradoProposta1.Conta__c = conta.Id;
            conta.Email__c = segurado.pessoa.email;

            if(segurado.vigenciaInicial == null)
              seguradoProposta1.VigenciaInicial__c = Date.valueOf(objPayload.proposta.vigenciaInicial);
            else
              seguradoProposta1.VigenciaInicial__c = Date.valueOf(segurado.vigenciaInicial);

            if(segurado.vigenciaFinal == null)
              seguradoProposta1.VigenciaFinal__c = Date.valueOf(objPayload.proposta.vigenciaFinal);
            else
              seguradoProposta1.VigenciaFinal__c = Date.valueOf(segurado.vigenciaFinal);

            // recupera o Id do objeto inserido anteriormente
            seguradoProposta1.GrupoProposta__c = grupo.objSf.Id;

            // // retorna ao payload o objeto salesforce para ser usado como referência
            segurado.objSf = seguradoProposta1;

            InformacaoBancaria__c info;

            if(mapMeioComercializacao.get(objpayload.proposta.meioComercializacao) == 'ARQ' && segurado.dadosPagamento != null && segurado.dadosPagamento.tipoResponsavelPagamento == 'PAR')
            {
              seguradoProposta1.tipoResponsavelPagamento__c = segurado.dadosPagamento.tipoResponsavelPagamento;

              for(InformacaoBancaria__c infoB : contaParceiro.InformacoesBancarias__r)
              {
                if(infoB.Principal__c == true)
                {
                  info = infoB;
                  continue;
                }
              }
              seguradoProposta1.InformacaoBancaria__c = info.Id;
            }
            

            //inclui as informações de premio e taxas p/ contratante e segurado
            // contratanteProposta, seguradoProposta, seguradoOrcamentoProposta, vidaOrcamentoProposta
            seguradoProposta1.numero__c = Integer.valueOf(segurado.numero);

            seguradoProposta1.PremioTotal__c = proposta.ValorPremio__c;
            this.incluiDadosCalculo(objPayload.calculo, null, null, null, seguradoProposta1, null, null, null, null);

            if(mapMeioComercializacao.get(objpayload.proposta.meioComercializacao) == 'ARQ')
              DadosParcelamentoFacade.getInstance().parseDadosParcelamentoSeguradoProposta(objPayload.proposta, contratante, segurado, mapContas, mapFormasPgto, mapPlanoParcelamento, seguradoProposta1, parceiro, contaParceiro, 'Arq');

            segurado.objSF = seguradoProposta1;
            seguradosPropostaParaInserir.add(seguradoProposta1);
          }
        }
      }

      try { 
        system.debug('gfs seguradosPropostaParaInserir '+ seguradosPropostaParaInserir);
        insert seguradosPropostaParaInserir; 
      }
      catch(Exception e)
      {
        throw new PropostaException('Origem: PropostaFacade/gerarProposta/seguradosPropostaParaInserir \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
      }
      
      // GERAR GARANTIAS DE PROPOSTA
      List<GarantiaContratanteProposta__c> lstGarantiasContratante = new List<GarantiaContratanteProposta__c>();
      for (EmissaoTO.ContratanteTO contratante : objPayload.proposta.contratantes)
      {
        List<GarantiasGrupoProposta__c> lstGarantiasGrupo = new List<GarantiasGrupoProposta__c>();

        for (EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          List<GarantiaSeguradoProposta__c> lstGarantiasSegurado = new List<GarantiaSeguradoProposta__c>();

          for (EmissaoTO.SeguradoTO segurado : grupo.segurados)
          {
            // iclui garantias de segurados
            if(segurado.coberturas != null)
            {
              String prefixoChaveMapa = contratante.numero + '_' + grupo.numero + '_' + segurado.numero + '_';

              //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO PARA O SEGURADO ------------------------------------
              lstGarantiasSegurado = GarantiaFacade.getInstance().parceGarantiasSeguradoProposta(segurado.coberturas, produto, segurado.objSF.Id, prefixoChaveMapa, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
              system.debug('gfs lstGarantiasSegurado' + lstGarantiasSegurado);
                insert lstGarantiasSegurado;
            }
          }
          // inclui garantias de grupos
          if(!lstGarantiasSegurado.isEmpty())
          {
            String prefixoChaveMapa  = contratante.numero + '_' + grupo.numero + '_';

            //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO ------------------------------------
            lstGarantiasGrupo = GarantiaFacade.getInstance().parceGarantiasGrupoProposta(lstGarantiasSegurado, produto, grupo.objSF.Id, prefixoChaveMapa , mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
            system.debug('gfs lstGarantiasGrupo' + lstGarantiasGrupo);
            insert lstGarantiasGrupo;
          }
        }
          
        system.debug('gfs lstGarantiasGrupo ' + lstGarantiasGrupo);
        // inclui garantias de contratantes
        if(!lstGarantiasGrupo.isEmpty())
        {
          String prefixoChaveMapa = contratante.numero + '_';

          //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO ------------------------------------
          lstGarantiasContratante = GarantiaFacade.getInstance().parceGarantiasContratanteProposta(lstGarantiasGrupo, produto, contratante.objSF.Id, prefixoChaveMapa , mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
          system.debug('gfs lstGarantiasContratante' + lstGarantiasContratante);
          insert lstGarantiasContratante;
        }
      }

      // iclui garantias do Proposta
      if(!lstGarantiasContratante.isEmpty())
      {
        String PreFixoChaveMapa = '';

        //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO ------------------------------------
        List<GarantiaProposta__c> lstGarantiasProposta = GarantiaFacade.getInstance().parceGarantiasProposta(lstGarantiasContratante, produto, Proposta.Id, PreFixoChaveMapa, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
        system.debug('gfs lstGarantiasProposta' + lstGarantiasProposta);
        insert lstGarantiasProposta;
      }

      //GERAR BENEFICIARIOS DA PROPOSTA ------------------------------
      List<BeneficiarioSeguradoProposta__c> lstBenefinicariosSeguradoProp = new List<BeneficiarioSeguradoProposta__c>();
      for(EmissaoTO.ContratanteTO contratante : objPayload.proposta.contratantes)
      {
        for (EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          for (EmissaoTO.SeguradoTO segurado : grupo.segurados)
          {
            if(segurado.coberturas != null)
            {
              try
              {
                system.debug('gfs proposta' + proposta);
                update proposta;
              }
              catch(Exception e)
              {
                throw new PropostaException('Origem: PropostaFacade/gerarProposta/GarantiasGrupoProposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
              }
            }
       
            String tipoBenefiniario = 'Nome do beneficiário';
            lstBenefinicariosSeguradoProp.add(BeneficiarioSeguradoPropostaBO.getInstance().incluirBeneficiariosSeguradoProposta(contaParceiro, segurado.objSF.Id, tipoBenefiniario, false, 100));
          }
        }
      }
	  
      //INSERIR BENEFICIARIO segurados PROPOSTA
      try { 
        system.debug('gfs lstBenefinicariosSeguradoProp' + lstBenefinicariosSeguradoProp);
        insert lstBenefinicariosSeguradoProp; 
      }
      catch(Exception e)
      {
        throw new PropostaException('Origem: PropostaFacade/gerarProposta/BeneficiarioVidaProposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
      }

      //CRITICA DESNECESSARIA. SE A PROPOSTA FOI DEVOLVIDA, PRECISA RETORNAR PARA O HEROKU APENAS A CRITICA QUE CULMINOU NA DEVOLUÇÃO
      //if(proposta.status == 'Devolvida')
      //{
      //   CriticaParceiro__c criticaParceiro = new CriticaParceiro__c(
      //            Rotulo__c                        = 'Emissão',
      //            IdentificacaoCampo__c            = '-3',
      //            Mensagem__c                      = 'Proposta gerada com status devolvida, verifique as criticas.',
      //            Name                             = '-1'
      //    );

      //   retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(criticaParceiro, origem, '', -3));
      //}

      if(retorno.devolutivas.isEmpty()) {
          retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(mapCriticas.get(0), origem, '',null));
      }
    }
    catch(Exception e)
    {
      
      Database.rollback(sp);
      throw new PropostaException('Origem: PropostaFacade/gerarProposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }

    try
    {
      
      List<Account> lContaPF = new List<Account>();
      List<Account> lContaPJ = new List<Account>();
      for(Account contaAtualizar : mapContas.values())
      {
          // PLV-2352-29 INICIO
          if(mapContasNaoAtualizar.containsKey(contaAtualizar.IdExterno__c)){
              continue;
          }          //se o email for nulo tem que ser setado como nulo no massificados

          // PLV-2352-29 FIM
        
        if(String.isEmpty(contaAtualizar.Papel__c))
          contaAtualizar.Papel__c = 'Segurado';
        else
        {
          
          if(!contaAtualizar.Papel__c.contains('Segurado'))
            contaAtualizar.Papel__c += ';Segurado';
        }
        
          
        //Início Melhoria Email__c
        if(proposta.Massificados__c = true)
        { 
            if(contaAtualizar.Email__c != null)
            {
               if(contaAtualizar.Email__c.contains(',') || contaAtualizar.Email__c.countMatches('@') > 1 )
               {
                   contaAtualizar.Email__c = null;  
               }
           }
        }else
        {
            if(contaAtualizar.Email__c == null )
            {
                if(retorno.devolutivas.isEmpty())
                {
                   retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(mapCriticas.get(54), origem, '',null));
                }	
            }else
            {
                if(contaAtualizar.Email__c.contains(',') || contaAtualizar.Email__c.countMatches('@') > 1 )
                {
                   retorno.devolutivas.add(PropostaRegrasValidacao.getInstance().mapeiaDevolutiva(mapCriticas.get(54), origem, '',null));
                }
            }
        } 
      	//Fim Melhoria Email__c 
          
        if(contaAtualizar.CPF__c !=null)
          lContaPF.add(contaAtualizar);
        else if(contaAtualizar.Cnpj__c !=null)
          lContaPJ.add(contaAtualizar);

      }

      Update lContaPF;
      Update lContaPJ;
    }
    catch(Exception e)
    {
      Database.rollback(sp);
      throw new PropostaException('Origem: PropostaFacade/gerarProposta/ atualizar papeis da conta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }

    if(propostaExcluir != null)
    {
      Opportunity orcamentoExcluir = OpportunityBO.getInstance().buscarOportunidade(propostaExcluir.OpportunityId);

      try
      {
        delete orcamentoExcluir;
      }
      catch(Exception e)
      {
        Database.rollback(sp);
        
        throw new PropostaException('Origem: PropostaFacade/gerarProposta/Excluir Proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
      }
    }

	// PLV-2312 INICIO      
    if(proposta.Status != 'Devolvida'){
        proposta.Status = 'Disponível para contratação';
        update proposta;
    }
    // PLV-2312 FIM

    return retorno;
  }

  public Quote mapeiaProposta(EmissaoTO.PayloadTO objPayload, Opportunity orcamento, Modalidade__c modalidade, RamoSeguro__c ramoSeguro, Product2 produto)
  {
    Quote proposta = new Quote();
    try
    {
      // DEPARA de propostaTO p/ objeto SF
      proposta.RecordTypeId               = mapRecordType.get(String.valueOf(objPayload.proposta.segmento)).Id;
      proposta.TipoVigencia__c            = mapTipoVigencia.get(objPayload.proposta.tipoVigencia);
      proposta.Name                       = String.valueOf(objPayload.proposta.origem +'-'+ objPayload.proposta.numero.leftPad(8,'0'));
        //PLV-2291 INICIO Criacao de campo unico
      proposta.NumeroPropostaUnico__c     = QuoteBO.getInstance().gerarNameProposta(String.valueOf(orcamento.Origem__c), orcamento.Numero__c);
        //PLV-2291 FIM Criacao de campo unico
      proposta.NumeroProposta__c          = objPayload.proposta.numero.leftPad(8,'0');
      proposta.Tipo__c                    = objPayload.proposta.tipoSeguro;
      proposta.Origem__c                  = String.valueOf(objPayload.proposta.origem);
      proposta.MeioComercializacao__c     = mapMeioComercializacao.get(objPayload.proposta.meioComercializacao);
      proposta.ValorPremio__c             = objPayload.calculo.precificacao.premio.informado;
      proposta.PremioInformado__c         = objPayload.proposta.precificacao.premio.informado;
      proposta.IdContratoParceiro__c      = objPayload.proposta.idContratoParceiro;
      proposta.IdContratanteParceiro__c   = objPayload.proposta.idContratanteParceiro;
      proposta.Parceiro__c                = objPayload.proposta.parceiro;
      proposta.VigenciaInicial__c         = Date.valueOf(objPayload.proposta.vigenciaInicial);
      proposta.VigenciaFinal__c           = Date.valueOf(objPayload.proposta.vigenciaFinal);
      proposta.DataCalculo__c             = Date.valueOf(objPayload.proposta.dataCalculo);
      //-- informação incluída na PLV1793
      proposta.EntradaNegocio__c          = objpayload.proposta.entradaNegocio;
      // PLV-2496 INICIO
      proposta.Lote__c                    = objpayload.proposta.idlote;
      proposta.NomeArquivo__c             = objpayload.proposta.nomeArquivo;
      // PLV-2496 FIM
      
      if(String.isBlank(objPayload.proposta.dataProtocolo))
      	proposta.DataProtocolo__c = Date.valueOf(objPayload.proposta.dataCalculo);
      else
        proposta.DataProtocolo__c = Date.valueOf(objPayload.proposta.dataProtocolo);
      
      proposta.DataCriacaoPortal__c       = Date.valueOf(objPayload.proposta.dataCriacaoPortal);
      proposta.Description                = objPayload.proposta.observacoesGerais;
      proposta.RamoSeguro__c              = QuoteBO.getInstance().BuscarRamoSeguro(new set<Id>{produto.Id});
      proposta.Produto__c                 = produto.Id;
      proposta.OpportunityId              = orcamento.Id;
      proposta.Status                     = 'Em criação';
      proposta.ValorPremio__c = objPayload.calculo.precificacao.premio.informado;

      if(modalidade != null)
        proposta.Modalidade__c = modalidade.Id;

      if(objPayload.proposta.evento != null)
      {
        proposta.TipoEvento__c = mapTipoEvento.get(objPayload.proposta.evento.tipoEvento);
        proposta.InformacoesEvento__c = objPayload.proposta.evento.informacoesEvento;
      }

      if(objPayload.proposta.viagem != null)
        proposta.TipoViagem__c = mapTipoViagem.get(objPayload.proposta.viagem.tipoViagem);

      proposta.Payload__c = JsonAdesaoPayload;
      // PLV-2378-29 - INICIO
      proposta.Massificados__c = true;
      // PLV-2378-29 - FINAL
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade >> mapeiaProposta >> DEPARA de propostaTO p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }
    
    return proposta;
  }
  
  public List<ContratanteProposta__c> criarContratantesProposta(EmissaoTO.PayloadTO objPayload, Quote proposta, List<EmissaoTO.ContratanteTO> contratantes, Id chaveProposta,Map<String, Account> mapContas, Map<String, FormaPagamento__c> mapFormasPgto, Map<String, PlanoParcelamento__c> mapPlanoParcelamento, EmissaoTO.calculoTO noCalculo, Parceiro__c parceiro, Account contaParceiro, Product2 produto)
  {
    List<ContratanteProposta__c> contratantesProposta = new  List<ContratanteProposta__c>();
    List<Endereco__c>         lstEnderecos      = new List<Endereco__c>();

    Set<String> setContas = new Set<String>();
    for (EmissaoTO.ContratanteTO contratante : contratantes)
      setContas.add(montarChavePessoa(contratante.pessoa));
    
    for(Account conta : AccountDAO.getInstance().buscarContasPorIdExterno(setContas))
      mapContas.put(conta.IdExterno__c, conta);
    
    List<Account> lstContasAtualizarTelefones = new List<Account>();
    for (EmissaoTO.ContratanteTO contratante : contratantes)
    {
      ContratanteProposta__c contratanteProposta = new ContratanteProposta__c();
      Account conta = mapContas.get( montarChavePessoa(contratante.pessoa) );

      if(conta == null)
      {
        try
        {
            conta = contaBo.geraResponsavelPagamento(contratante, null);
          if (contratante.pessoa.email != null) {
            conta.Email__c = contratante.pessoa.email;
          }
          
          Database.upsert(conta, Account.IdExterno__c, true);
          mapContas.put(conta.IdExterno__c, conta);
        }
        catch(Exception e)
        {
          throw new PropostaException('Origem: PropostaFacade >> criaSeguradosProposta >> erro ao criar conta \r - Causa: ' + e.getCause() + '\r - linha: ' +  e.getLineNumber() + '\r - Mensagem: ' + e.getMessage());
        }
      }
      else
        conta.Email__c = contratante.pessoa.email;

      if(string.isEmpty(contratante.numero))
        contratanteProposta.Numero__c = 1;
      else
        contratanteProposta.Numero__c = Integer.valueOf(contratante.numero);

      contratanteProposta.Proposta__c  = chaveProposta;
      contratanteProposta.Conta__c     = conta.Id;
      contratanteProposta.Tipo__c      = mapTipoProposta.get(contratante.tipo);

      // retorna ao payload o objeto salesforce para ser usado como referência
      contratante.objSf = contratanteProposta;
      contratantesProposta.add(contratanteProposta);
      
      Map<String, Endereco__c> mapEnderecosConta = new Map<String, Endereco__c>();
      for(Endereco__c endereco : conta.Enderecos__r)
      {
        String chave = endereco.Logradouro__c + endereco.numero__c + endereco.Cidade__c + endereco.Estado__c;
        mapEnderecosConta.put(chave, endereco);
      }
      
      //verifica e  inclui a lista de endereços dos contratantes da proposta
      lstEnderecos.addAll(EnderecoFacade.getInstance().parseEndereco(conta.Id, contratante.pessoa.enderecos, mapEnderecosConta, contratante.pessoa.tipo));

      if(!lstEnderecos.isEmpty())
      {
        contratanteProposta.TipoEndereco__c    = lstEnderecos[0].TipoEndereco__c;
        contratanteProposta.TipoLogradouro__c  = lstEnderecos[0].TipoLogradouro__c;
        contratanteProposta.Logradouro__c      = lstEnderecos[0].Logradouro__c;
        contratanteProposta.NumeroEndereco__c  = lstEnderecos[0].Numero__c;
        contratanteProposta.Complemento__c     = lstEnderecos[0].Complemento__c;
        contratanteProposta.Bairro__c          = lstEnderecos[0].Bairro__c;
        contratanteProposta.Cep__c             = lstEnderecos[0].Cep__c;
        contratanteProposta.Cidade__c          = lstEnderecos[0].Cidade__c;
        contratanteProposta.Estado__c          = lstEnderecos[0].Estado__c;
        contratanteProposta.Pais__c            = lstEnderecos[0].Pais__c;
      }

      
      // Inicio VEP-393
      Account updateTelefone = new Account();
      if (contratante.pessoa.telefones != null) {
        for (EmissaoTO.TelefoneTO telefone : contratante.pessoa.telefones)
                {
                    //INICIO | PLV-2534
                    String numeroTelefone = telefone.numeroTelefone.replace('-','').replace('(','').replace(')','').replace('|','');
                    if(numeroTelefone.length() >= 8 && telefone.dddTelefone.length() == 2)
                    {
                        if(telefone.tipoTelefone == 'RES')
                            updateTelefone.PersonHomePhone = telefone.dddTelefone + telefone.numeroTelefone;
                        else if(telefone.tipoTelefone == 'COM')
                            updateTelefone.Phone = telefone.dddTelefone + telefone.numeroTelefone;
                        else if(telefone.tipoTelefone == 'CEL')
                            updateTelefone.PersonOtherPhone = telefone.dddTelefone + telefone.numeroTelefone;
                        else if(telefone.tipoTelefone == 'FAX')
                            updateTelefone.Fax = telefone.dddTelefone + telefone.numeroTelefone;
                    }
                    //FIM | PLV-2534
                }
      }
    
     if (contratante.pessoa.email !=null ) {
         updateTelefone.Email__c = contratante.pessoa.email;
     }

    if(contratante.pessoa.telefones != null && !contratante.pessoa.telefones.isEmpty())
      {
        // Fim VEP-393
        updateTelefone.Id = conta.Id;
        updateTelefone.IdExterno__c = conta.IdExterno__c;
        updateTelefone.CPF__c = conta.CPF__c;
        updateTelefone.Cnpj__c = conta.Cnpj__c;

        lstContasAtualizarTelefones.add(updateTelefone);
      }

      if(String.isEmpty(contratante.numero))
        contratanteProposta.Numero__c = 1;
      else
        contratanteProposta.Numero__c = Integer.valueOf(contratante.numero);

      this.incluiDadosCalculo(noCalculo, null, contratanteProposta, null, null, null, null, null, null);

      DadosParcelamentoFacade.getInstance().parseDadosParcelamentocontratanteProposta(objPayload.proposta, contratante, mapContas, mapFormasPgto, mapPlanoParcelamento, contratanteProposta, parceiro, contaParceiro, objPayload.proposta.meioComercializacao);
    }

    try
    {
      update lstContasAtualizarTelefones;
      insert contratantesProposta;
    }
    catch(Exception e)
    {
      
      throw new PropostaException('Origem: PropostaFacade >> criaSeguradosProposta >> erro ao inserir contratantes da proposta \r - Causa: ' + e.getCause() + '\r - linha: ' +  e.getLineNumber() + '\r - Mensagem: ' + e.getMessage());
    }

    try { upsert lstEnderecos; }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade >> criaSeguradosProposta >> erro ao inserir endereços contratantes da proposta \r - Causa: ' + e.getCause() + '\r - linha: ' +  e.getLineNumber() + '\r - Mensagem: ' + e.getMessage());
    }

    return contratantesProposta;
  }

  public Opportunity gerarOrcamento(EmissaoTO.PayloadTO objPayload, Product2 produto, Parceiro__c parceiro, Map<String,EmissaoTO.CoberturaTO> mapGarantiasPorNumeroContratanteGrupoSeguradoSigla)
  {
    system.debug('Entrou Gerar Orçamento');
    Map<String, Account>    mapSeguradosContas              = new Map<String, Account>();
    Map<String, Account>    mapOrcamentoSeguradosPrincipais = new Map<String, Account>();

    Opportunity orcamento = mapeiaOrcamento(objPayload, produto, parceiro);
 	system.debug('orcamento ' + orcamento);
    CanalDistribuicao__c canalDistribuicao = CanalDistribuicaoDAO.getInstance().buscarCanalDistribuicaoOrcamentoPorSigla(objPayload.proposta.canalDistribuicao);
    system.debug('canalDistribuicao ' + canalDistribuicao);
    if(canalDistribuicao != null)
      orcamento.CanalDistribuicao__c = canalDistribuicao.Id;

    try
    {
      insert orcamento;

      if(objPayload.proposta.meioComercializacao == 'ARQ')
        orcamento.StageName = 'Disponível para contratação';

      this.incluiDadosCalculo(objPayload.calculo, null, null, null, null, orcamento, null, null, null);

      update orcamento;
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/gerarOrcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }

    
    String chaveOrcamento = orcamento.Numero__c;
    EmissaoTO proposta = objPayload.proposta;

    // GERAR Contas dos Segurados do Orçamneto -------------------------
    
    try
    {
      Map<String, String> mapSegurados = new Map<String, String>();
      Map<String, List<EmissaoTO.EnderecoTO>> mapEnderecosSegurado = new Map<String, List<EmissaoTO.EnderecoTO>>();
      Account contaResponsavelOferta;

      for (EmissaoTO.ContratanteTO contratante : proposta.contratantes)
      {
        String cpfCnpj = '';

        //Identifica qual é a pessoa principal da Oferta, na qual a oportunidade ficará vinculada
        if (contratante.tipo == PRINCIPAL)
        {
          contaResponsavelOferta = contaBo.gerarParseContaContratante(contratante, null, true);
          contratante.contaSf = contaResponsavelOferta;

          mapOrcamentoSeguradosPrincipais.put(chaveOrcamento, contaResponsavelOferta);
          mapSeguradosContas.put(contratante.numero, contaResponsavelOferta);
        }
        
        //Separa os contratantes PF e suas profissões
        if(contratante.pessoa.tipo == PESSOA_FISICA)
        {
            // Inicio VEP-393
            if (contratante.pessoa.dadosPessoaFisica.profissao != null) {
                mapSegurados.put(contratante.numero, contratante.pessoa.dadosPessoaFisica.profissao);
            }
            // fim VEP-393
          cpfCnpj = contratante.pessoa.dadosPessoaFisica.numeroCpf + contratante.pessoa.dadosPessoaFisica.digitoCpf;
        }
        else
          cpfCnpj = contratante.pessoa.dadosPessoaJuridica.cnpj;

        //Separa os endereços de cada contratante
        mapEnderecosSegurado.put(cpfCnpj, contratante.pessoa.enderecos);

        //Processa e salva as contas e o seus endereços
        mapSeguradosContas = contaBo.gerarContasOferta(proposta, contaResponsavelOferta, mapEnderecosSegurado);
      }

      orcamento.AccountId = contaResponsavelOferta.Id;

      update orcamento;
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/gerarOrcamento/ Erro ao gerar os contratantes do orçamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }
    

    // GERAR SEGURADO DO ORÇAMENTO ------------------------------------
    
    try
    {
      List<ContratanteOrcamento__c> contratantes = new List<ContratanteOrcamento__c>();
      for (EmissaoTO.ContratanteTO contratante : proposta.contratantes)
      {
        ContratanteOrcamento__c contratanteOrcamento  = new ContratanteOrcamento__c();
        contratanteOrcamento.Orcamento__c          = orcamento.Id;

        if(contratante.pessoa != null)
        {
         // Inicio VEP-393
          if(contratante.pessoa.enderecos != null && !contratante.pessoa.enderecos.isEmpty())
          {
            String tipoEndereco                     = contratante.pessoa.enderecos[0].tipoEndereco == 'RES' ? 'Residencial' : 'Comercial';
            contratanteOrcamento.TipoEndereco__c       = tipoEndereco;
            contratanteOrcamento.Bairro__c             = contratante.pessoa.enderecos[0].bairro;
            contratanteOrcamento.CEP__c                = contratante.pessoa.enderecos[0].cep + '' + contratante.pessoa.enderecos[0].complementoCep;
            contratanteOrcamento.Cidade__c             = contratante.pessoa.enderecos[0].cidade;
            contratanteOrcamento.Complemento__c        = contratante.pessoa.enderecos[0].complemento;
            contratanteOrcamento.Estado__c             = contratante.pessoa.enderecos[0].uf;
            contratanteOrcamento.Logradouro__c         = contratante.pessoa.enderecos[0].logradouro;
            contratanteOrcamento.NumeroEndereco__c     = contratante.pessoa.enderecos[0].numeroLogradouro;

            contratanteOrcamento.TipoLogradouro__c     = mapTipoLogradouro.get(contratante.pessoa.enderecos[0].tipoLogradouro);
          }
        }
        // Fim VEP-393

        if (contratante.contaSf != null)
        {
          contratanteOrcamento.Conta__c = contratante.contaSf.Id;
          if (contratante.tipo == PRINCIPAL)
            contratanteOrcamento.Tipo__c = 'Principal';
        }

        if(String.isEmpty(contratante.numero))
          contratanteOrcamento.Numero__c = 1; //throw new PropostaException('Numero do contratante não poder ser null: ' + contratante.numero);
        else
            contratanteOrcamento.Numero__c = Integer.valueOf(contratante.numero);

        this.incluiDadosCalculo(objPayload.calculo, null, null, null, null, null, contratanteOrcamento, null, null);
        // retorna ao payload o objeto salesforce para ser usado como referência
        contratante.objSfO = contratanteOrcamento;
        contratantes.add(contratanteOrcamento);
      }

      insert contratantes;
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/gerarOrcamento/ Erro ao gerar os contratantes do orçamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }
    

    // GERAR GRUPO DO ORÇAMENTO ------------------------------------
    
    try
    {
      List<GrupoOrcamento__c> gruposOrcamentoParaInserir = new List<GrupoOrcamento__c>();
      for (EmissaoTO.ContratanteTO contratante : proposta.contratantes)
      {
        for (EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          GrupoOrcamento__c grupoOrcamento1       = new GrupoOrcamento__c();
          grupoOrcamento1.Name                    = grupo.nome;
          grupoOrcamento1.QuantidadeVidas__c      = Integer.valueOf(grupo.qtdeVidas); //PLV-2666 - INICIO/FIM - alterado nome da variável, pois foi alterado na classe EmissaoTO
          grupoOrcamento1.TipoCalculo__c          = grupo.tipoCalculo;
          grupoOrcamento1.CodigoArquivo__c        = grupo.idArquivoVidas;
          grupoOrcamento1.ContratanteOrcamento__c    = contratante.objSfO.Id;
          grupoOrcamento1.Numero__c               = Integer.valueOf(grupo.numero);
          grupo.objSFO                             = grupoOrcamento1;

          // acumular para inserir
          gruposOrcamentoParaInserir.add(grupoOrcamento1);

          this.incluiDadosCalculo(objPayload.calculo, null, null, null, null, null, null, grupoOrcamento1, null);
        }
      }

      insert gruposOrcamentoParaInserir;
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/gerarOrcamento/ Erro ao gerar os grupos do orçamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }

    // GERAR VIDA DO ORÇAMENTO ------------------------------------
    try
    {
      List<SeguradoOrcamento__c> seguradosOrcamentoParaInserir = new List<SeguradoOrcamento__c>();
      for (EmissaoTO.ContratanteTO contratante : proposta.contratantes)
      {
        for (EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          for (EmissaoTO.SeguradoTO segurado : grupo.segurados)
          {
            SeguradoOrcamento__c seguradoOrcamento1 = new SeguradoOrcamento__c();

            if (segurado.numeroCpf != null && segurado.digitoCpf != null)
              seguradoOrcamento1.CPF__c = segurado.numeroCpf + segurado.digitoCpf;

            seguradoOrcamento1.Conta__c             = contratante.contaSf.Id;
            seguradoOrcamento1.CID__c               = String.valueOf(segurado.cid);
            seguradoOrcamento1.Afastado__c          = segurado.afastado == SIM ? true : false;
            seguradoOrcamento1.DataNascimento__c    = segurado.dataNascimento;
            seguradoOrcamento1.GrupoOrcamento__c    = grupo.objSfO.Id;
            seguradoOrcamento1.Numero__c            = Integer.valueOf(segurado.numero);

            this.incluiDadosCalculo(objPayload.calculo, null, null, null, null, null, null, null, seguradoOrcamento1);
            segurado.objSfO                             = seguradoOrcamento1;
            // acumular para inserir
            seguradosOrcamentoParaInserir.add(seguradoOrcamento1);
          }
        }
      }

      insert seguradosOrcamentoParaInserir;

      List<GarantiaContratanteOrcamento__c> lstGarantiasContratante;
      for (EmissaoTO.ContratanteTO contratante : proposta.contratantes)
      {
        List<GarantiaGrupoOrcamento__c> lstGarantiasGrupo;

        for (EmissaoTO.GrupoTO grupo : contratante.grupos)
        {
          List<GarantiaSeguradoOrcamento__c> lstGarantiasSegurado;

          for (EmissaoTO.SeguradoTO segurado : grupo.segurados)
          {
            // iclui garantias de segurados
            if(segurado.coberturas != null)
            {
              String PreFixoChaveMapa = contratante.numero + '_' + grupo.numero + '_' + segurado.numero + '_';

              //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO PARA A VIDA ------------------------------------
              lstGarantiasSegurado = GarantiaFacade.getInstance().parceGarantiasSeguradoOrcamento(segurado.coberturas, produto, segurado.objSfO.Id, PreFixoChaveMapa, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
              insert lstGarantiasSegurado;
            }
          }
          // iclui garantias de grupos
          if(!lstGarantiasSegurado.isEmpty())
          {
            String PreFixoChaveMapa = contratante.numero + '_' + grupo.numero + '_';

            //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO ------------------------------------
            lstGarantiasGrupo = GarantiaFacade.getInstance().parceGarantiasGrupoOrcamento(lstGarantiasSegurado, produto, grupo.objSFO.Id, PreFixoChaveMapa, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
            insert lstGarantiasGrupo;
          }
        }
        // iclui garantias de contratantes
        if(!lstGarantiasGrupo.isEmpty())
        {
          String PreFixoChaveMapa = contratante.numero + '_';

          //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO ------------------------------------
          lstGarantiasContratante = GarantiaFacade.getInstance().parceGarantiasContratanteOrcamento(lstGarantiasGrupo, produto, contratante.objSFO.Id, PreFixoChaveMapa, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
          insert lstGarantiasContratante;
        }
      }
      // iclui garantias do orcamento
      if(!lstGarantiasContratante.isEmpty())
      {
        String PreFixoChaveMapa = '';

        //GERAR GARANTIAS DO GRUPO DO ORÇAMENTO ------------------------------------
        List<GarantiaOrcamento__c> lstGarantiasOrcamento = GarantiaFacade.getInstance().parceGarantiasOrcamento(lstGarantiasContratante, produto, orcamento.Id, PreFixoChaveMapa, mapGarantiasPorNumeroContratanteGrupoSeguradoSigla);
        insert lstGarantiasOrcamento;
      }

      //fim
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/gerarOrcamento/ Erro ao gerar os segurado do orçamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }

    return orcamento;
  }

  public Opportunity mapeiaOrcamento(EmissaoTO.PayloadTO objPayload, Product2 produto, Parceiro__c parceiro)
  {
    
    Opportunity orcamento = new Opportunity();

    Map<String, RecordType> mapRecordTypeOpp = new Map<String, RecordType>();
    // PLV-4290 COMPLEMENTO - INICIO
    for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Opportunity')){
      mapRecordTypeOpp.put(tipo.DeveloperName, tipo);
      if(objPayLoad.proposta.segmento == 'VidaMassificados' && tipo.DeveloperName == 'VidaIndividual'){
        mapRecordTypeOpp.put('VidaMassificados' , tipo);
      }
    }
    // PLV-4290 COMPLEMENTO - FIM
    
    

    try
    {
      orcamento.RecordTypeId               = mapRecordTypeOpp.get(objPayload.proposta.segmento).Id;
      orcamento.TipoVigencia__c            = mapTipoVigencia.get(objPayload.proposta.tipoVigencia);
      orcamento.Numero__c                  = String.valueOf(objPayload.proposta.numero.leftPad(8,'0'));
      orcamento.Origem__c                  = String.valueOf(objPayload.proposta.origem);
      orcamento.MeioComercializacao__c     = mapMeioComercializacao.get(objPayload.proposta.meioComercializacao);
      orcamento.VigenciaInicial__c         = Date.valueOf(objPayload.proposta.vigenciaInicial);
      orcamento.VigenciaFinal__c           = Date.valueOf(objPayload.proposta.vigenciaFinal);
      orcamento.DataCalculo__c             = Date.valueOf(objPayload.proposta.dataCalculo);
      //-- informação incluída na PLV1793
      orcamento.EntradaNegocio__c          = objpayload.proposta.entradaNegocio;

      if(objPayload.proposta.dataCriacaoPortal != null)
        orcamento.DataCriacaoPortal__c = Date.valueOf(objPayload.proposta.dataCriacaoPortal);
      else
        orcamento.DataCriacaoPortal__c = Date.today();

      orcamento.PremioInformado__c         = objPayload.proposta.precificacao.premio.informado;
      orcamento.Produto__c                 = produto.Id;

      if(objPayload.proposta.observacoesGerais != null)
        orcamento.Description                = objPayload.proposta.observacoesGerais;

      if(objPayload.proposta.evento != null)
      {
        orcamento.InformacoesEvento__c       = objPayload.proposta.evento.informacoesEvento;
        orcamento.TipoEvento__c              = mapTipoEvento.get(objPayload.proposta.evento.tipoEvento);
      }
      if(objPayload.proposta.viagem != null)
        orcamento.TipoViagem__c              = mapTipoViagem.get(objPayload.proposta.viagem.tipoViagem);

      if(objPayload.calculo != null)
      {
        orcamento.PremioTotal__c = objPayload.calculo.precificacao.premio.total;
        orcamento.Amount = objPayload.calculo.precificacao.premio.total;
      }

      orcamento.Name = objPayload.proposta.meioComercializacao + '-' + objPayload.proposta.numero.leftPad(8,'0');

      orcamento.Type = objPayload.proposta.tipoSeguro; 
      orcamento.MeioComercializacao__c = objPayload.proposta.meioComercializacao;
      orcamento.StageName = 'Em criação';
      orcamento.CloseDate = System.today();

    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/mapeiaOrcamento/ Erro ao mapear orçamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }

    return orcamento;
  }

  public Map<String, EmissaoTO.CoberturaTO> montarMapaGarantiasCalculo(EmissaoTO.PayloadTO objPayload, Map<String,EmissaoTO.CoberturaTO> mapGarantiasPorNumeroContratanteGrupoSeguradoSigla)
  {
    EmissaoTO.calculoTO noCalculo = objPayload.calculo;
    EmissaoTO.CoberturaTO garantiaCAP;
    
    //Encontra a cobertura do tipo CAP para recuperar informações de capitalização
    for(EmissaoTO.CoberturaTO garantia : objPayload.proposta.contratantes[0].grupos[0].segurados[0].coberturas){
      if(garantia.sigla == 'CAP'){
        garantiaCAP = garantia;
        break;
      }
    }

    // Chave do mapa eh numeroSegurado_numeroGrupo_numeroVida_siglaGarantia
    // Para os niveis superiores, eliminar os niveis abaixo e manter a sigla
    for(EmissaoTO.CoberturaTO garantiaOrcamento : noCalculo.precificacao.coberturas)
    {
      if(garantiaOrcamento.sigla == 'CAP'){
        garantiaOrcamento.dataSorteio = garantiaCAP.dataSorteio;
        garantiaOrcamento.loteCapitalizacao = garantiaCAP.loteCapitalizacao;
        garantiaOrcamento.versaoCapitalizacao = garantiaCAP.versaoCapitalizacao;
        garantiaOrcamento.dataSolicitacao = garantiaCAP.dataSolicitacao;
        garantiaOrcamento.statusCapitalizacao = garantiaCAP.statusCapitalizacao;
        garantiaOrcamento.tituloCapitalizacao = garantiaCAP.tituloCapitalizacao;
        garantiaOrcamento.numeroSerie = garantiaCAP.numeroSerie;
        garantiaOrcamento.numeroSorte = garantiaCAP.numeroSorte;
      }

      mapGarantiasPorNumeroContratanteGrupoSeguradoSigla.put(garantiaOrcamento.sigla, garantiaOrcamento);

      for(EmissaoTO.ContratanteTO contratanteCalculo : noCalculo.precificacao.contratantes)
      {
        String numeroContratante;
        if(contratanteCalculo.numero == null)
          numeroContratante = '1';
        else
          numeroContratante = contratanteCalculo.numero;
        // Adiciona no mapa as garantias do contratante com a chave numeroSegurado_siglaGarantia (1_BAS)
        for(EmissaoTO.CoberturaTO garantiaSegurado : contratanteCalculo.coberturas)
          mapGarantiasPorNumeroContratanteGrupoSeguradoSigla.put(numeroContratante + '_' + garantiaSegurado.sigla, garantiaSegurado);

        for(EmissaoTO.GrupoTO grupoCalculo : contratanteCalculo.grupos)
        {
          String numeroGrupo;
          if(grupoCalculo.numero == null)
            numeroGrupo = '1';
          else
            numeroGrupo = grupoCalculo.numero;

          // Adiciona no mapa as garantias do grupo com a chave numeroSegurado_numeroGrupo_siglaGarantia (1_1_BAS)
          for(EmissaoTO.CoberturaTO garantiaGrupo : grupoCalculo.coberturas)
            mapGarantiasPorNumeroContratanteGrupoSeguradoSigla.put(numeroContratante + '_' + numeroGrupo + '_' +  garantiaGrupo.sigla, garantiaGrupo);
          for(EmissaoTO.SeguradoTO vidaCalculo : grupoCalculo.segurados)
          {
            String numeroSegurado;
            if(vidaCalculo.numero == null)
              numeroSegurado = '1';
            else
              numeroSegurado = vidaCalculo.numero;

            // Adiciona no mapa as garantias da segurado com a chave numeroSegurado_numeroGrupo_numeroVida_siglaGarantia (1_1_1_BAS)
            for(EmissaoTO.CoberturaTO garantiaVida : vidaCalculo.coberturas)
              mapGarantiasPorNumeroContratanteGrupoSeguradoSigla.put(numeroContratante + '_' + numeroGrupo + '_' + numeroSegurado + '_' + garantiaVida.sigla, garantiaVida);
          }
        }
      }
    }

    return mapGarantiasPorNumeroContratanteGrupoSeguradoSigla;
  }

  public void incluiDadosCalculo(EmissaoTO.calculoTO noCalculo, Quote proposta, ContratanteProposta__c contratanteProposta, GrupoProposta__c grupoProposta, SeguradoProposta__c seguradoProposta, Opportunity orcamento, ContratanteOrcamento__c contratanteOrcamentoProposta, GrupoOrcamento__c grupoOrcamento, SeguradoOrcamento__c seguradoOrcamentoProposta)
  {
    if(noCalculo != null)
    {
      // preenche os dados de precificação da proposta
      if(proposta != null)
      {
        proposta.Juros__c           = noCalculo.precificacao.juros;
        proposta.IOF__c             = noCalculo.precificacao.iof;
        proposta.Encargos__c        = noCalculo.precificacao.encargos;
        proposta.CustoApolice__c    = noCalculo.precificacao.custoApolice;

        proposta.PremioComercial__c = noCalculo.precificacao.premio.comercial;
        proposta.PremioPuro__c      = noCalculo.precificacao.premio.puro;

        proposta.TaxaComercial__c   = noCalculo.precificacao.taxa.comercial;
        proposta.TaxaPura__c        = noCalculo.precificacao.taxa.pura;

        proposta.PremioTotal__c     = noCalculo.precificacao.premio.total;
        proposta.TaxaTotal__c       = noCalculo.precificacao.taxa.total;

        proposta.IOF__c              = noCalculo.precificacao.iof!=null ? noCalculo.precificacao.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

        if(noCalculo.precificacao.descontoAgravo != null)
        {
          if(noCalculo.precificacao.descontoAgravo[0].tipo == 'TEC')
          {
            proposta.DescontoAgravoPercentualTecnico__c = noCalculo.precificacao.descontoAgravo[0].percentual;
            proposta.DescontoAgravoMonetarioTecnico__c  = noCalculo.precificacao.descontoAgravo[0].monetario;
          }
          else if(noCalculo.precificacao.descontoAgravo[0].tipo == 'COM')
          {
            proposta.DescontoAgravoPercentualComercial__c = noCalculo.precificacao.descontoAgravo[0].percentual;
            proposta.DescontoAgravoMonetarioComercial__c  = noCalculo.precificacao.descontoAgravo[0].monetario;
          }
          else if(noCalculo.precificacao.descontoAgravo[0].tipo == 'BAT')
          {
            proposta.DescontoAgravoPercentualInformado__c = noCalculo.precificacao.descontoAgravo[0].percentual;
            proposta.DescontoAgravoMonetarioInformado__c  = noCalculo.precificacao.descontoAgravo[0].monetario;
          }

          // calculo de desconto agravo premio e taxa total
          if(noCalculo.precificacao.descontoAgravo[0].monetario != null)
            proposta.PremioTotal__c = proposta.PremioTotal__c + noCalculo.precificacao.descontoAgravo[0].monetario;
          if(noCalculo.precificacao.descontoAgravo[0].percentual != null)
            proposta.TaxaTotal__c   = proposta.TaxaTotal__c * (1 + noCalculo.precificacao.descontoAgravo[0].percentual / 100);
        }
      }

      if(contratanteProposta != null)
      {
        
        for(EmissaoTO.ContratanteTO contratanteCalculoPremio : noCalculo.precificacao.contratantes)
        {
          if(contratanteCalculoPremio.numero == null)
            contratanteCalculoPremio.numero = '1';

          if(contratanteProposta.Numero__c == Integer.valueOf(contratanteCalculoPremio.numero))
          {
            if(contratanteCalculoPremio.iof == null)
              contratanteProposta.IOF__c = noCalculo.precificacao.iof;
            else
              contratanteProposta.IOF__c = contratanteCalculoPremio.iof;

            contratanteProposta.PremioComercial__c     = contratanteCalculoPremio.premio.comercial;
            contratanteProposta.PremioPuro__c          = contratanteCalculoPremio.premio.puro;
            contratanteProposta.PremioTotal__c         = contratanteCalculoPremio.premio.total;
            
            contratanteProposta.TaxaComercial__c       = contratanteCalculoPremio.taxa.comercial;
            contratanteProposta.TaxaPura__c            = contratanteCalculoPremio.taxa.pura;
            contratanteProposta.TaxaTotal__c           = contratanteCalculoPremio.taxa.total;

            if(contratanteCalculoPremio.descontoAgravo != null)
            {
              if(contratanteCalculoPremio.descontoAgravo[0].tipo == 'TEC')
              {
                contratanteProposta.DescontoAgravoPercentualTecnico__c = contratanteCalculoPremio.descontoAgravo[0].percentual;
                contratanteProposta.DescontoAgravoMonetarioTecnico__c  = contratanteCalculoPremio.descontoAgravo[0].monetario;
              }
              else if(contratanteCalculoPremio.descontoAgravo[0].tipo == 'COM')
              {
                contratanteProposta.DescontoAgravoPercentualComercial__c = contratanteCalculoPremio.descontoAgravo[0].percentual;
                contratanteProposta.DescontoAgravoMonetarioComercial__c  = contratanteCalculoPremio.descontoAgravo[0].monetario;
              }
              else if(contratanteCalculoPremio.descontoAgravo[0].tipo == 'BAT')
              {
                contratanteProposta.DescontoAgravoPercentualInformado__c = contratanteCalculoPremio.descontoAgravo[0].percentual;
                contratanteProposta.DescontoAgravoMonetarioInformado__c  = contratanteCalculoPremio.descontoAgravo[0].monetario;
              }

              // calculo de desconto agravo premio e taxa total
              if(contratanteCalculoPremio.descontoAgravo[0].monetario != null)
                contratanteProposta.PremioTotal__c = contratanteProposta.PremioTotal__c + contratanteCalculoPremio.descontoAgravo[0].monetario;
              if(contratanteCalculoPremio.descontoAgravo[0].percentual != null)
                contratanteProposta.TaxaTotal__c   = contratanteProposta.TaxaTotal__c * (1 + contratanteCalculoPremio.descontoAgravo[0].percentual / 100);
            }
          }
        }
      }

      if(grupoProposta != null)
      {
        
        for(EmissaoTO.ContratanteTO contratanteCalculoPremio : noCalculo.precificacao.contratantes)
        {
          for(EmissaoTO.GrupoTO grupoCalculoPremio : contratanteCalculoPremio.grupos)
          {
            
            if(grupoCalculoPremio.numero == null)
              grupoCalculoPremio.numero = '1';

            if(grupoProposta.Numero__c ==  Integer.valueOf(grupoCalculoPremio.numero))
            {
              grupoProposta.PremioComercial__c     = grupoCalculoPremio.premio.comercial;
              grupoProposta.PremioPuro__c          = grupoCalculoPremio.premio.puro;
              grupoProposta.PremioTotal__c         = grupoCalculoPremio.premio.total;
             
              grupoProposta.TaxaComercial__c       = grupoCalculoPremio.taxa.comercial;
              grupoProposta.TaxaPura__c            = grupoCalculoPremio.taxa.pura;
              grupoProposta.TaxaTotal__c           = grupoCalculoPremio.taxa.total;
              grupoProposta.IOF__c                = grupoCalculoPremio.iof!=null ? grupoCalculoPremio.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
              if(grupoCalculoPremio.descontoAgravo != null)
              {
                if(grupoCalculoPremio.descontoAgravo[0].tipo == 'TEC')
                {
                  grupoProposta.DescontoAgravoPercentualTecnico__c = grupoCalculoPremio.descontoAgravo[0].percentual;
                  grupoProposta.DescontoAgravoMonetarioTecnico__c  = grupoCalculoPremio.descontoAgravo[0].monetario;
                }
                else if(grupoCalculoPremio.descontoAgravo[0].tipo == 'COM')
                {
                  grupoProposta.DescontoAgravoPercentualComercial__c = grupoCalculoPremio.descontoAgravo[0].percentual;
                  grupoProposta.DescontoAgravoMonetarioComercial__c  = grupoCalculoPremio.descontoAgravo[0].monetario;
                }
                else if(grupoCalculoPremio.descontoAgravo[0].tipo == 'BAT')
                {
                  grupoProposta.DescontoAgravoPercentualInformado__c = grupoCalculoPremio.descontoAgravo[0].percentual;
                  grupoProposta.DescontoAgravoMonetarioInformado__c  = grupoCalculoPremio.descontoAgravo[0].monetario;
                }

                // calculo de desconto agravo premio e taxa total
                if(grupoCalculoPremio.descontoAgravo[0].monetario != null)
                  grupoProposta.PremioTotal__c = grupoProposta.PremioTotal__c + grupoCalculoPremio.descontoAgravo[0].monetario;
                if(grupoCalculoPremio.descontoAgravo[0].percentual != null)
                  grupoProposta.TaxaTotal__c   = grupoProposta.TaxaTotal__c * (1 + grupoCalculoPremio.descontoAgravo[0].percentual / 100);
              }
            }
          }
        }
      }

      if(seguradoProposta != null)
      {
        
        for(EmissaoTO.ContratanteTO contratanteCalculoPremio : noCalculo.precificacao.contratantes)
        {
          for(EmissaoTO.GrupoTO grupoCalculoPremio : contratanteCalculoPremio.grupos)
          {
            for(EmissaoTO.SeguradoTO seguradoCalculoPremio : grupoCalculoPremio.segurados)
            {
              if(seguradoCalculoPremio.numero == null)
                seguradoCalculoPremio.numero = '1';

              if(seguradoProposta.Numero__c ==  Integer.valueOf(seguradoCalculoPremio.numero))
              {
                if(seguradoCalculoPremio.iof == null)
                  seguradoProposta.IOF__c = noCalculo.precificacao.iof;
                else
                  seguradoProposta.IOF__c = seguradoCalculoPremio.iof;

                seguradoProposta.PremioComercial__c     = seguradoCalculoPremio.premio.comercial;
                seguradoProposta.PremioPuro__c          = seguradoCalculoPremio.premio.puro;
                seguradoProposta.PremioTotal__c         = seguradoCalculoPremio.premio.total;
                seguradoProposta.TaxaComercial__c       = seguradoCalculoPremio.taxa.comercial;
                seguradoProposta.TaxaPura__c            = seguradoCalculoPremio.taxa.pura;
                seguradoProposta.TaxaTotal__c           = seguradoCalculoPremio.taxa.total;

                if(seguradoCalculoPremio.descontoAgravo != null)
                {
                  if(seguradoCalculoPremio.descontoAgravo[0].tipo == 'TEC')
                  {
                    seguradoProposta.DescontoAgravoPercentualTecnico__c = seguradoCalculoPremio.descontoAgravo[0].percentual;
                    seguradoProposta.DescontoAgravoMonetarioTecnico__c  = seguradoCalculoPremio.descontoAgravo[0].monetario;
                  }
                  else if(seguradoCalculoPremio.descontoAgravo[0].tipo == 'COM')
                  {
                    seguradoProposta.DescontoAgravoPercentualComercial__c = seguradoCalculoPremio.descontoAgravo[0].percentual;
                    seguradoProposta.DescontoAgravoMonetarioComercial__c  = seguradoCalculoPremio.descontoAgravo[0].monetario;
                  }
                  else if(seguradoCalculoPremio.descontoAgravo[0].tipo == 'BAT')
                  {
                    seguradoProposta.DescontoAgravoPercentualInformado__c = seguradoCalculoPremio.descontoAgravo[0].percentual;
                    seguradoProposta.DescontoAgravoMonetarioInformado__c  = seguradoCalculoPremio.descontoAgravo[0].monetario;
                  }

                  // calculo de desconto agravo premio e taxa total
                  if(seguradoCalculoPremio.descontoAgravo[0].monetario != null)
                    seguradoProposta.PremioTotal__c = seguradoProposta.PremioTotal__c + seguradoCalculoPremio.descontoAgravo[0].monetario;
                  if(seguradoCalculoPremio.descontoAgravo[0].percentual != null)
                    seguradoProposta.TaxaTotal__c   = seguradoProposta.TaxaTotal__c * (1 + seguradoCalculoPremio.descontoAgravo[0].percentual / 100);
                }
              }
            }
          }
        }
      }

      // preenche os dados de precificação do orcamento
      if(orcamento != null)
      {
        orcamento.Juros__c           = noCalculo.precificacao.juros;
        orcamento.Iof__c             = noCalculo.precificacao.iof;
        orcamento.Encargos__c        = noCalculo.precificacao.encargos;
        orcamento.CustoApolice__c    = noCalculo.precificacao.custoApolice;
        orcamento.PremioComercial__c = noCalculo.precificacao.premio.comercial;
        orcamento.PremioPuro__c      = noCalculo.precificacao.premio.puro;
        orcamento.PremioTotal__c     = noCalculo.precificacao.premio.total;
        orcamento.TaxaComercial__c   = noCalculo.precificacao.taxa.comercial;
        orcamento.TaxaPura__c        = noCalculo.precificacao.taxa.pura;
        orcamento.TaxaTotal__c       = noCalculo.precificacao.taxa.total;

        if(noCalculo.precificacao.descontoAgravo != null)
        {
          if(noCalculo.precificacao.descontoAgravo[0].tipo == 'TEC')
          {
            orcamento.DescontoAgravoPercentualTecnico__c = noCalculo.precificacao.descontoAgravo[0].percentual;
            orcamento.DescontoAgravoMonetarioTecnico__c  = noCalculo.precificacao.descontoAgravo[0].monetario;
          }
          else if(noCalculo.precificacao.descontoAgravo[0].tipo == 'COM')
          {
            orcamento.DescontoAgravoPercentualComercial__c = noCalculo.precificacao.descontoAgravo[0].percentual;
            orcamento.DescontoAgravoMonetarioComercial__c  = noCalculo.precificacao.descontoAgravo[0].monetario;
          }
          else if(noCalculo.precificacao.descontoAgravo[0].tipo == 'BAT')
          {
            orcamento.DescontoAgravoPercentualInformado__c = noCalculo.precificacao.descontoAgravo[0].percentual;
            orcamento.DescontoAgravoMonetarioInformado__c  = noCalculo.precificacao.descontoAgravo[0].monetario;
          }

          // calculo de desconto agravo premio e taxa total
          if(noCalculo.precificacao.descontoAgravo[0].monetario != null)
            orcamento.PremioTotal__c = orcamento.PremioTotal__c + noCalculo.precificacao.descontoAgravo[0].monetario;
          if(noCalculo.precificacao.descontoAgravo[0].percentual != null)
            orcamento.TaxaTotal__c   = orcamento.TaxaTotal__c * (1 + noCalculo.precificacao.descontoAgravo[0].percentual / 100);
        }
      }

      if(contratanteOrcamentoProposta != null)
      {
        
        for(EmissaoTO.ContratanteTO contratanteCalculoPremio : noCalculo.precificacao.contratantes)
        {
          if(contratanteCalculoPremio.numero == null)
            contratanteCalculoPremio.numero = '1';

          if(contratanteOrcamentoProposta.Numero__c == Integer.valueOf(contratanteCalculoPremio.numero))
          {
            if(contratanteCalculoPremio.iof == null)
              contratanteOrcamentoProposta.IOF__c = noCalculo.precificacao.iof;
            else
              contratanteOrcamentoProposta.IOF__c = contratanteCalculoPremio.iof;

            contratanteOrcamentoProposta.PremioComercial__c  = contratanteCalculoPremio.premio.comercial;
            contratanteOrcamentoProposta.PremioPuro__c       = contratanteCalculoPremio.premio.puro;
            contratanteOrcamentoProposta.PremioTotal__c      = contratanteCalculoPremio.premio.total;
            
            contratanteOrcamentoProposta.TaxaComercial__c    = contratanteCalculoPremio.taxa.comercial;
            contratanteOrcamentoProposta.TaxaPura__c         = contratanteCalculoPremio.taxa.pura;
            contratanteOrcamentoProposta.TaxaTotal__c        = contratanteCalculoPremio.taxa.total;

            if(contratanteCalculoPremio.descontoAgravo != null)
            {
              if(contratanteCalculoPremio.descontoAgravo[0].tipo == 'TEC')
              {
                contratanteOrcamentoProposta.DescontoAgravoPercentualTecnico__c = contratanteCalculoPremio.descontoAgravo[0].percentual;
                contratanteOrcamentoProposta.DescontoAgravoMonetarioTecnico__c  = contratanteCalculoPremio.descontoAgravo[0].monetario;
              }
              else if(contratanteCalculoPremio.descontoAgravo[0].tipo == 'COM')
              {
                contratanteOrcamentoProposta.DescontoAgravoPercentualComercial__c = contratanteCalculoPremio.descontoAgravo[0].percentual;
                contratanteOrcamentoProposta.DescontoAgravoMonetarioComercial__c  = contratanteCalculoPremio.descontoAgravo[0].monetario;
              }
              else if(contratanteCalculoPremio.descontoAgravo[0].tipo == 'BAT')
              {
                contratanteOrcamentoProposta.DescontoAgravoPercentualInformado__c = contratanteCalculoPremio.descontoAgravo[0].percentual;
                contratanteOrcamentoProposta.DescontoAgravoMonetarioInformado__c  = contratanteCalculoPremio.descontoAgravo[0].monetario;
              }

              // calculo de desconto agravo premio e taxa total
              if(contratanteCalculoPremio.descontoAgravo[0].monetario != null)
                contratanteOrcamentoProposta.PremioTotal__c = contratanteOrcamentoProposta.PremioTotal__c + contratanteCalculoPremio.descontoAgravo[0].monetario;
              if(contratanteCalculoPremio.descontoAgravo[0].percentual != null)
                contratanteOrcamentoProposta.TaxaTotal__c   = contratanteOrcamentoProposta.TaxaTotal__c * (1 + contratanteCalculoPremio.descontoAgravo[0].percentual / 100);
            }
          }
        }
      }

      if(grupoOrcamento != null)
      {
        
        for(EmissaoTO.ContratanteTO contratanteCalculoPremio : noCalculo.precificacao.contratantes)
        {
          for(EmissaoTO.GrupoTO grupoCalculoPremio : contratanteCalculoPremio.grupos)
          {
            if(grupoCalculoPremio.numero == null)
              grupoCalculoPremio.numero = '1';

            if(grupoOrcamento.Numero__c == Integer.valueOf(grupoCalculoPremio.numero))
            {
              grupoOrcamento.IOF__c              = grupoCalculoPremio.iof;

              grupoOrcamento.PremioComercial__c  = grupoCalculoPremio.premio.comercial;
              grupoOrcamento.PremioPuro__c       = grupoCalculoPremio.premio.puro;
              grupoOrcamento.PremioTotal__c      = grupoCalculoPremio.premio.total;

              grupoOrcamento.TaxaComercial__c    = grupoCalculoPremio.taxa.comercial;
              grupoOrcamento.TaxaPura__c         = grupoCalculoPremio.taxa.pura;
              grupoOrcamento.TaxaTotal__c        = grupoCalculoPremio.taxa.total;

              if(grupoCalculoPremio.descontoAgravo != null)
              {
                if(grupoCalculoPremio.descontoAgravo[0].tipo == 'TEC')
                {
                  grupoOrcamento.DescontoAgravoPercentualTecnico__c = grupoCalculoPremio.descontoAgravo[0].percentual;
                  grupoOrcamento.DescontoAgravoMonetarioTecnico__c  = grupoCalculoPremio.descontoAgravo[0].monetario;
                }
                else if(grupoCalculoPremio.descontoAgravo[0].tipo == 'COM')
                {
                  grupoOrcamento.DescontoAgravoPercentualComercial__c = grupoCalculoPremio.descontoAgravo[0].percentual;
                  grupoOrcamento.DescontoAgravoMonetarioComercial__c  = grupoCalculoPremio.descontoAgravo[0].monetario;
                }
                else if(grupoCalculoPremio.descontoAgravo[0].tipo == 'BAT')
                {
                  grupoOrcamento.DescontoAgravoPercentualInformado__c = grupoCalculoPremio.descontoAgravo[0].percentual;
                  grupoOrcamento.DescontoAgravoMonetarioInformado__c  = grupoCalculoPremio.descontoAgravo[0].monetario;
                }

                 // calculo de desconto agravo premio e taxa total
                 if(grupoCalculoPremio.descontoAgravo[0].monetario != null)
                  grupoOrcamento.PremioTotal__c = grupoOrcamento.PremioTotal__c + grupoCalculoPremio.descontoAgravo[0].monetario;
                 if(grupoCalculoPremio.descontoAgravo[0].percentual != null)
                  grupoOrcamento.TaxaTotal__c   = grupoOrcamento.TaxaTotal__c * (1 + grupoCalculoPremio.descontoAgravo[0].percentual / 100);
              }
            }
          }
        }
      }

      if(seguradoOrcamentoProposta != null)
      {
        
        for(EmissaoTO.ContratanteTO contratanteCalculoPremio : noCalculo.precificacao.contratantes)
        {
          for(EmissaoTO.GrupoTO grupoCalculoPremio : contratanteCalculoPremio.grupos)
          {
            for(EmissaoTO.SeguradoTO seguradoCalculoPremio : grupoCalculoPremio.segurados)
            {
              if(seguradoCalculoPremio.numero == null)
                seguradoCalculoPremio.numero = '1';

              if(seguradoOrcamentoProposta.Numero__c == Integer.valueOf(seguradoCalculoPremio.numero))
              {
                if(contratanteCalculoPremio.iof == null)
                  seguradoOrcamentoProposta.IOF__c = noCalculo.precificacao.iof;
                else
                  seguradoOrcamentoProposta.IOF__c = contratanteCalculoPremio.iof;

                seguradoOrcamentoProposta.PremioComercial__c  = seguradoCalculoPremio.premio.comercial;
                seguradoOrcamentoProposta.PremioPuro__c       = seguradoCalculoPremio.premio.puro;
                seguradoOrcamentoProposta.PremioTotal__c      = seguradoCalculoPremio.premio.total;

                seguradoOrcamentoProposta.TaxaComercial__c    = seguradoCalculoPremio.taxa.comercial;
                seguradoOrcamentoProposta.TaxaPura__c         = seguradoCalculoPremio.taxa.pura;
                seguradoOrcamentoProposta.TaxaTotal__c        = seguradoCalculoPremio.taxa.total;

                if(seguradoCalculoPremio.descontoAgravo != null)
                {
                  if(seguradoCalculoPremio.descontoAgravo[0].tipo == 'TEC')
                  {
                    seguradoOrcamentoProposta.DescontoAgravoPercentualTecnico__c = seguradoCalculoPremio.descontoAgravo[0].percentual;
                    seguradoOrcamentoProposta.DescontoAgravoMonetarioTecnico__c  = seguradoCalculoPremio.descontoAgravo[0].monetario;
                  }
                  else if(seguradoCalculoPremio.descontoAgravo[0].tipo == 'COM')
                  {
                    seguradoOrcamentoProposta.DescontoAgravoPercentualComercial__c = seguradoCalculoPremio.descontoAgravo[0].percentual;
                    seguradoOrcamentoProposta.DescontoAgravoMonetarioComercial__c  = seguradoCalculoPremio.descontoAgravo[0].monetario;
                  }
                  else if(seguradoCalculoPremio.descontoAgravo[0].tipo == 'BAT')
                  {
                    seguradoOrcamentoProposta.DescontoAgravoPercentualInformado__c = seguradoCalculoPremio.descontoAgravo[0].percentual;
                    seguradoOrcamentoProposta.DescontoAgravoMonetarioInformado__c  = seguradoCalculoPremio.descontoAgravo[0].monetario;
                  }

                  // calculo de desconto agravo premio e taxa total
                  if(seguradoCalculoPremio.descontoAgravo[0].monetario != null)
                    seguradoOrcamentoProposta.PremioTotal__c = seguradoOrcamentoProposta.PremioTotal__c + seguradoCalculoPremio.descontoAgravo[0].monetario;
                  if(seguradoCalculoPremio.descontoAgravo[0].percentual != null)
                    seguradoOrcamentoProposta.TaxaTotal__c   = seguradoOrcamentoProposta.TaxaTotal__c * (1 + seguradoCalculoPremio.descontoAgravo[0].percentual / 100);
                }
              }
            }
          }
        }
      }
    }
  }  
  public PropostaRetornoTO.PayloadTO consultaPropostas(ServiceTO.ParametroConsultarPropostaTO parametrosTO)
  {
    PropostaRetornoTO.PayloadTO retorno = new PropostaRetornoTO.PayloadTO();
    retorno.proposta                    = new PropostaRetornoTO.PropostaTO();
    String modalidade;
    Decimal corretagem;
    String dataFormatada;
    String sucursal;
    Datetime data;
    Contract contrato;
	  //PLV 4736 Inicio
	  Datetime dataC;
	  Datetime dataE;
	  //PLV 4736 Fim
	  //PLV 4736 Inicio Fix3
	  Date dataStartDate;
	  Date dataFinalDate;
	  //PLV 4736 Fim Fix3

    Quote proposta = new QuoteBO().obterProposta(parametrosTO.proposta);//PLV-4539

    if(proposta <> null)
    {
      List<Contract> lstcontrato = ContractDAO.getInstance().buscarContratoPorProposta(new Set<Id>{proposta.Id});
      if(lstcontrato.size()>0)
        contrato = lstcontrato[0];
    }

    if(proposta == null)
    {
      retorno.proposta.Status = 100;                                                    //  Resultado do processo
      retorno.proposta.Mensagem = 'Proposta não encontrada.' + parametrosTO.proposta;  //  Descrição do erro
    }
    else
    {
      List<ContratanteProposta__c> contratantes = QuoteDAO.getInstance().buscarContratantesPropostaPorIdProposta(new Set<Id>{proposta.Id});
      
      try
      {
        retorno.proposta.prporg       = Integer.ValueOf(proposta.Origem__c);                    //  Origem Proposta
        //PLV 4736 Inicio
		//retorno.proposta.prpnumdig    = proposta.Name;                                          //  Número Proposta
		retorno.proposta.prpnumdig    = proposta.NumeroProposta__c; 
		//PLV 4736 Fim

        if(proposta.vigenciaInicial__c <> null)
        {
          data = proposta.vigenciaInicial__c;
          dataFormatada = data.format('dd/MM/yyyy');
        }
        //PLV-4736 Fix3 Inicio 
		if(contrato.StartDate <> null)
        {
		System.debug('contrato.StartDate = ' + contrato.StartDate);
		dataStartDate = contrato.StartDate;
		retorno.proposta.viginc       = dataStartDate.format();         //  Data de Início de Vigência		
		System.debug('retorno.proposta.viginc = ' + retorno.proposta.viginc);
		}
		//PLV-4736 Fix3 Fim 
        if(proposta.VigenciaFinal__c <> null)
        {
          data = proposta.VigenciaFinal__c;
          dataFormatada = data.format('dd/MM/yyyy');
        }
        
		//PLV-4736 Fix3 Inicio 
		if(contrato.VigenciaFinal__c <> null)
        {
		System.debug('contrato.VigenciaFinal__c = ' + contrato.VigenciaFinal__c);
		dataFinalDate = contrato.VigenciaFinal__c;
		retorno.proposta.vignfl       = dataFinalDate.format();         //  Data de Final de Vigência
		}
		//PLV-4736 Fix3 Fim 
		                                   

        if(proposta.DataEmissao__c <> null)
        {
          data = proposta.DataEmissao__c;
          dataFormatada = data.format('dd/MM/yyyy');
        }
        //PLV 4736 Inicio
		//retorno.proposta.aplemsdat    = dataFormatada;
        dataE = contrato.DataEmissao__c;
		retorno.proposta.aplemsdat    = dataE.format('dd/MM/yyyy');
		//PLV 4736 Fim
		retorno.proposta.emsdat       = dataFormatada;                                //  Data emissão do Documento

        if(proposta.dataCalculo__c <> null)
        {
          data = proposta.dataCalculo__c;
          dataFormatada = data.format('dd/MM/yyyy');
        }
        //PLV 4736 Inicio
		//retorno.proposta.basclcdat    = dataFormatada;											//  Data Base para cálculo
		dataC = contratantes[0].VencimentoPrimeiraParcela__c;
		retorno.proposta.basclcdat    =  dataC.format('dd/MM/yyyy');
        //PLV 4736 Fim
		retorno.proposta.ramcod       = proposta.RamoSeguro__r.Codigo__c;                       //  Código do ramo de seguro
        retorno.proposta.subcod       = 0;                                                      //  Código do Sub-ramo
        retorno.proposta.prmmda       = 'R$';                                                   //  Código da Forma de Pagamento
        retorno.proposta.adcfrcvlr    = 0;                                                      //  Valor do Adicional de Fracionamento
        //PLV 4736 Inicio
		retorno.proposta.prmbruvlr    = contrato.PremioTotal__c;
		//PLV 4736 Fim
        retorno.proposta.parnum       = Integer.ValueOf(contratantes[0].QuantidadeParcelas__c);                          //  Prêmio Bruto
        retorno.proposta.parqtd       = Integer.ValueOf(contratantes[0].QuantidadeParcelas__c);    //  Quantidade de Parcelas
        retorno.proposta.prpstt       = mapStatusConsultaProposta.get(proposta.Status);         //  Status da Proposta
        retorno.proposta.segnom       = contratantes[0].Conta__r.Name;                             //  Nome contratante
        retorno.proposta.segsclnom    = contratantes[0].Conta__r.NomeSocial__c;     //Nome Social Contratante   LECVPV-177 - INICIO/FIM
        retorno.proposta.corsus       = proposta.CodigoCorretor__r.Name;           //  Corretor Principal - Código derivado do SUSEP
        retorno.proposta.Status       = 0;                                                      //  Resultado do processo
        retorno.proposta.Mensagem     = '';                                                     //  Descrição do erro
        retorno.proposta.ciaperptc    = 100;
        retorno.proposta.notcmpflg    = 0;

		//PLV-4709-Fix2
        ConsultarDadosContratoTO.DadosParcelasTO lstParcelasTO;
        if (!Test.isRunningTest()) {
            lstParcelasTO = HerokuService.getInstance().buscarParcelasContratoPorApolice(String.valueOf(contrato.NumeroApolice__c).leftPad(9, '0'));
            
            for(ConsultarDadosContratoTO.ParcelasTO parcela : lstParcelasTO.data){
                retorno.proposta.comflgngc =  parcela.antecipacaocomissao;
            }
        }	 	

		//PLV-4709-Fix2

        if(proposta.Status == 'Contratada')
        {
          if(contrato <> null && contrato.Status == 'Emitido')
          {

            retorno.proposta.edsnumref    = contrato.Endosso__c;                           //  Número do Endosso
            
			//PLV 4736 Inicio
			//retorno.proposta.aplnumdig    = contrato.Name;                                 //  Número da Apólice
			retorno.proposta.aplnumdig    = contrato.NumeroApolice__c;
			//PLV 4736 Fim
            retorno.proposta.edsnumdig    = contrato.Endosso__c;
            //PLV 4736 Inicio			
			//retorno.proposta.succod       = contrato.CodigoCorretor__r.CodigoSucursalVinculo__c;                      //  Sucursal de Emissão do Seguro
			retorno.proposta.succod       = contrato.Sucursal__c; 
			retorno.proposta.comtaxcod = 1;
			retorno.proposta.codope	   = 0;
			//PLV 4736 Fim
            for(GarantiaContrato__c garantiaContrato : ContractDAO.getInstance().buscarGarantiaContratoPorId(new Set<Id>{contrato.Id}))
            {
              if(garantiaContrato.GarantiaProduto__r.OrdemPrioridade__c == 1)
                modalidade = garantiaContrato.GarantiaProduto__r.Modalidade__r.Codigo__c;
            }
            //PLV 4736 Inicio
			//retorno.proposta.rmemdlcod = modalidade;                       //  Modalidade de seguro
			retorno.proposta.rmemdlcod = proposta.Modalidade__r.Codigo__c;
			//PLV 4736 Fim

            List<RemuneracaoContrato__c> remuneracao = ContractDAO.getInstance().buscarRemuneracaoContratoPorId(new Set<Id>{contrato.Id});
            
			//PLV 4736 Inicio
            //retorno.proposta.rmecmlniv    = corretagem;                                           //  Taxa oficial de Comissão
            for(RemuneracaoProposta__c remCont : proposta.RemuneracoesProposta__r){
				retorno.proposta.rmecmlniv    = remCont.Percentual__c;
			}						
			//retorno.proposta.succod       = sucursal;                      //  Sucursal de Emissão do Seguro            
			
			if(proposta.Opportunity.PremioPuro__c != null)
            retorno.proposta.prmliqvlr = proposta.PremioComercial__c;   //PLV-4709-Fix2 Inicio/Fim  //  Prêmio Líquido
            //PLV 4736 Fim
			
			retorno.proposta.pgtfrm       = contrato.FormaPagamento__r.Codigo__c;
            if(contrato.Empresa__c <> null)
              retorno.proposta.empcod       = Integer.ValueOf(contrato.Empresa__c);  //  Empresa
          }
        }

           //PLV-4464 - INICIO
		 if(retorno.proposta.codigoPessoaBCP != null || retorno.proposta.codigoPessoaBCP != ''){
			retorno.proposta.codigoPessoaBCP =  proposta.Account.Pescod__c;
		 }else{
			retorno.proposta.codigoPessoaBCP =  ' ';
		 }		 
      //PLV-4464 - INICIO
      
      }
      catch(Exception e)
      {
        retorno.proposta.Status = 100;                                                                  //  Resultado do processo
        retorno.proposta.Mensagem = e.getCause() + ' - ' +  e.getLineNumber() + ': ' + e.getMessage();  //  Descrição do erro
        System.debug('PropostaFacade Exception : ' + e.getStackTraceString() + ', '  + e.getMessage());
      }
    }

    return retorno;
  }

  public void gerarMapaDadosPagamentoSegurado(EmissaoTO.PayloadTO objPayload, EmissaoTO.ContratanteTO contratante, Id chaveProposta, Map<String, Account> mapContas, Map<String, CartaoCredito__c> mapCartoes, Map<String, InformacaoBancaria__c>  mapInformacaoBancaria, List<CartaoCredito__c> cartoesSeguradosProposta, Account contaParceiro)
  {
    Set<String> setChavesInfoBancarias = new Set<String>();
    List<InformacaoBancaria__c> infoBancariasSeguradosProposta  = new List<InformacaoBancaria__c>();
    List<CartaoCredito__c> listCartaoCreditosInserir = new List<CartaoCredito__c>();
    Account responsavelPGTO;

    responsavelPGTO = contaParceiro;


    for(InformacaoBancaria__c info : InformacaoBancariaDAO.getInstance().buscarInformacoesBancariasPorIdExterno(setChavesInfoBancarias)) {
      mapInformacaoBancaria.put(info.IdExterno__c, info);
    }

    try
    {
      if(!listCartaoCreditosInserir.isEmpty()) {

        insert listCartaoCreditosInserir;
        cartoesSeguradosProposta.addAll(listCartaoCreditosInserir);
      }

      if(!infoBancariasSeguradosProposta.isEmpty())
      {
        insert infoBancariasSeguradosProposta;

        for(InformacaoBancaria__c info : infoBancariasSeguradosProposta)
          mapInformacaoBancaria.put(info.IdExterno__c, info);
      }
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/gerarProposta/Erro ao criar informação bancaria contratante proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }
  }

  public void gerarMapaDadosPagamentoSegurado(EmissaoTO.PayloadTO objPayload, EmissaoTO.SeguradoTO contratante, Id chaveProposta, Map<String, Account> mapContas, Map<String, CartaoCredito__c> mapCartoes, Map<String, InformacaoBancaria__c>  mapInformacaoBancaria, List<CartaoCredito__c> cartoesSeguradosProposta, Account contaParceiro)
  {

    Set<String> setChavesInfoBancarias = new Set<String>();
    List<InformacaoBancaria__c> infoBancariasSeguradosProposta  = new List<InformacaoBancaria__c>();
    List<CartaoCredito__c> listCartaoCreditosInserir = new List<CartaoCredito__c>();

    Account responsavelPGTO = contaParceiro;

    for(InformacaoBancaria__c info : InformacaoBancariaDAO.getInstance().buscarInformacoesBancariasPorIdExterno(setChavesInfoBancarias)) {
      mapInformacaoBancaria.put(info.IdExterno__c, info);
    }

    try
    {
      if(!listCartaoCreditosInserir.isEmpty()) {
        insert listCartaoCreditosInserir;
        cartoesSeguradosProposta.addAll(listCartaoCreditosInserir);
      }

      if(!infoBancariasSeguradosProposta.isEmpty())
      {
        insert infoBancariasSeguradosProposta;

        //List<Database.UpsertResult> upsertSave = Database.upsert(infoBancariasSeguradosProposta, InformacaoBancaria__c.IdExterno__c, true);
        for(InformacaoBancaria__c info : infoBancariasSeguradosProposta)
          mapInformacaoBancaria.put(info.IdExterno__c, info);
      }
    }
    catch(Exception e)
    {
      throw new PropostaException('Origem: PropostaFacade/gerarProposta/Erro ao criar informação bancaria contratante proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
    }
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
    
  //Código removido por conta da história PLV-3367
  /*public String montarChaveInformacaoBancarias(Id chaveProposta, String IdExterno, EmissaoTO.DadosPagamentoTO dadosPagamento)
  {
    return chaveProposta + IdExterno + dadosPagamento.dadosBancarios.banco +
            dadosPagamento.dadosBancarios.agencia  + dadosPagamento.dadosBancarios.conta + dadosPagamento.dadosBancarios.digitoConta;
  }

  public Id recuperarInformacoesBancarias"(EmissaoTO.DadosPagamentoTO dadosPagamento, Map<String, InformacaoBancaria__c>  mapInformacaoBancaria, Id chaveProposta)
  {

    String IdExterno;
    if(dadosPagamento.responsavelPagamento.tipo == PESSOA_JURIDICA)
      IdExterno = dadosPagamento.responsavelPagamento.dadosPessoaJuridica.numeroCnpj
              + dadosPagamento.responsavelPagamento.dadosPessoaJuridica.ordemCnpj + dadosPagamento.responsavelPagamento.dadosPessoaJuridica.digitoCnpj;
    else if(dadosPagamento.responsavelPagamento.tipo == PESSOA_FISICA)
      IdExterno = dadosPagamento.responsavelPagamento.dadosPessoaFisica.numeroCpf + dadosPagamento.responsavelPagamento.dadosPessoaFisica.digitoCpf;

    String chave = montarChaveInformacaoBancarias(chaveProposta,IdExterno,dadosPagamento);

    InformacaoBancaria__c info = mapInformacaoBancaria.get(chave);

    if(info == null)
      throw new PropostaException('informação bancaria do responsavel pagamento contratante não encontrada.' + chave);

    return info.Id;
  }*/

  public void mapeiaSetIds(EmissaoTO.PayloadTO objPayload, Set<string> setContas, Set<string> setTipoRemuneracao, Set<string> setFormasPGTO, Set<String> setPlanosParcelamento,Set<String> setSuepsCorretores)
  {
    if(objPayload.proposta.remuneracoes != null)
    {
      if(objPayload.proposta.remuneracoes != null)
      {
        for(EmissaoTO.RemuneracaoTO remuneracaoTO : objPayload.proposta.remuneracoes)
        {
          setTipoRemuneracao.add(remuneracaoTO.tipoRemuneracao);
          for(EmissaoTO.FavorecidoTO favorecido : remuneracaoTO.favorecidos)
          { 
            setContas.add( montarChavePessoa( favorecido.pessoa ) );
            setSuepsCorretores.add(favorecido.susep);
          }
        }
      }
    }

    if(objPayload.proposta.contratantes != null)
    {
      for(EmissaoTO.ContratanteTO contratanteTO : objPayload.proposta.contratantes)
      {
        string IdExternoConta = montarChavePessoa( contratanteTO.pessoa);

        setContas.add(IdExternoConta);
        for(EmissaoTO.GrupoTO gp : contratanteTO.grupos)
        {
          for(EmissaoTO.SeguradoTO seg : gp.segurados)
          {
            setContas.add(montarChavePessoa( seg.pessoa ));
          }
        }

        if(contratanteTO.dadosPagamento != null){
          if(contratanteTO.dadosPagamento.responsavelPagamento != null)
          {
            string IdExternoDadosPGTO;

            if(contratanteTO.dadosPagamento.responsavelPagamento.tipo == PESSOA_FISICA)
              IdExternoDadosPGTO = contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaFisica.numeroCpf + contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaFisica.digitoCpf;
            else if(contratanteTO.dadosPagamento.responsavelPagamento.tipo == PESSOA_FISICA)
              IdExternoDadosPGTO = contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaJuridica.numeroCnpj + contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaJuridica.ordemCnpj + contratanteTO.dadosPagamento.responsavelPagamento.dadosPessoaJuridica.digitoCnpj;

            setContas.add(IdExternoDadosPGTO);
          }
          // 2610 - INICIO
          if (contratanteTO.dadosPagamento != null && contratanteTO.dadosPagamento.formaPagamento != null)
            setFormasPGTO.add(String.valueOf(contratanteTO.dadosPagamento.formaPagamento.codigo));
          //setPlanosParcelamento.add(String.valueOf(contratanteTO.dadosPagamento.descricaoPlanoParcelamento));
          // 2610 - FIM
        }
      }
    }
  }

  private String gerarNumeroProposta(Integer quantidade, Integer origemProposta) {
    ContratoTO.SolicitarTituloTO solicitarTituloTO = new ContratoTO.SolicitarTituloTO();
    solicitarTituloTO.quantidade = quantidade;
    solicitarTituloTO.origemproposta = origemProposta;
    // gera um numero de proposta
    HerokuResponseTO.TituloTO retorno = HerokuService.getInstance().gerarNumeroProposta(solicitarTituloTO);
    return String.valueOf(retorno.data.numeros[0]);
  }

  public class PropostaException extends Exception {}
}