// INICIO | PLV-2355-Hackathon
// /**************************************************************************************************************************************************************************
//  *  Classe responsável por montar uma proposta genérica baseada em um numero de orçamento
//  *
//  *  @author Everymind - Sprint 29 - (hackathon)
//  **************************************************************************************************************************************************************************/
////PLV-3285 - INICIO - MVP A Transmissão da proposta
//Toda a classe será implantada em TST e em Homologação para essa atender a história PLV-3285
public without sharing class PropostaGenericaBuilder extends PropostaBuilder
{
     
    // instancias, metodos e construtores do padrao 
    public static final PropostaGenericaBuilder instance = new PropostaGenericaBuilder();
    public static PropostaGenericaBuilder getInstance() { return instance; }
    public PropostaGenericaBuilder() {
        this.contemViagem = false;//ANNVI-48 - INICIO/FIM 
        this.setInstancia(this); 
    }
    
    private String PESSOA_FISICA = 'FIS';
    private String PESSOA_JURIDICA = 'JUR';
    // INICIO | PLV-2402-30
    private String ORIGEM = 'ODM';
    private final String TIPO_CRITICA_AVISOS = 'Aviso';
    private final String TIPO_CRITICA_PENDENCIAS = 'Pendencia';
    private final String TIPO_CRITICA_ANALISES = 'Analise';
    private final String TIPO_CRITICA_RECUSAS = 'Recusa';	
    // FIM | PLV-2402-30

    String portopagRecusa = ''; // TKCL 458-FIX02 INICIO/FIM
    
    //PLV-3285 - INICIO - MVP A Transmissão da proposta
    private final List<Constante__mdt> origemProposta = MetadataDAO.getInstance().buscarConstante('OrigemPorto');
    private Integer codigoFormaPagamento = 0;
    private Integer codigoEmpresa = 0;
    private String planoParcelamento;
    private Account ContaResponsavelPagto;
    @TestVisible private EmissaoTO.payloadTO payloadOrcamentoPrecificacao; //ANNVI-48 - INICIO/FIM
    //PLV-3455 - INICIO - Criacao da variavel
    private ServiceTO.OfertaTO payloadParcelamentos;
   
    private RetornoPropostaRestTO.DadosPagamentoTO dadosPagamentoRecorrencia;  // TKCL 473 INICIO/FIM
    public RetornoPropostaRestTO.contratanteTO contratante = new RetornoPropostaRestTO.contratanteTO();
    RetornoPropostaRestTO.DadosPagamentoTO dadosPagamento = new RetornoPropostaRestTO.dadosPagamentoTO();
    EmissaoTO.ContratanteTO contratanteTORecorrente = new EmissaoTO.ContratanteTO(); //TKCL-460 INCIO/FIM
    
    private Map<Integer, Map<Integer,ServiceTO.ParcelamentoTO>> mapParcelamentos = new Map<Integer, Map<Integer,ServiceTO.ParcelamentoTO>>();
    //PLV-3455 - FIM
    //PLV-3285 - FIM - MVP A Transmissão da proposta
    
    private Map<String, Endereco__c> mapEndrecosToInsert = new Map<String, Endereco__c>();//PLV-4894 - INICIO/FIM
    //PLV-4340 - INICIO
    private Boolean Contem2Grupos = false;
    @TestVisible private Boolean contemViagem = false; //ANNVI-48 - INICIO/FIM
    String nomeGrupo = '';
    //PLV-4340 - FIM
    private Set<String> setContas = new Set<String>();
    private Opportunity orcamento;
    @TestVisible private EmissaoTO.PayloadTO payload; //II-167 INICIO/FIM //ANNVI-48 - INICIO/FIM
    private Map<String, DadosCorretor__c> mapDadosCorretor = new Map<String, DadosCorretor__c>();
    private Map<String, Account> mapContas = new Map<String, Account>();
    private OpportunityDAO daoOrcamento = OpportunityDAO.getInstance();
    private AccountBO boConta = AccountBO.getInstance();
    //PLV-2728 - Inicio
    private EnderecoBO endereco2BO = EnderecoBO.getInstance();
    //PLV-2728 - Fim
    private GrupoOrcamentoDAO daoGrupoOrcamento = GrupoOrcamentoDAO.getInstance();
    private DadosCorretorDAO daoDadosCorretor = DadosCorretorDAO.getInstance();
    private ContratanteOrcamentoDAO daoContratanteOrcamento = ContratanteOrcamentoDAO.getInstance();
    private final Map<String, RecordType> mapRecordType = new Map<String, RecordType>();
    private Map<String, TipoRemuneracao__c> mapTiposRemuneracao = new Map<String, TipoRemuneracao__c>();
    private Map<Id, List<GrupoOrcamento__c>> mapGruposOrcamento = new Map<Id, List<GrupoOrcamento__c>>();
    private Map<Id, List<GarantiaSeguradoOrcamento__c>> mapGarantiaSeguradoOrcamento = new Map<Id, List<GarantiaSeguradoOrcamento__c>>();
    private Map<Id, List<GarantiaContratanteOrcamento__c>> mapGarantiaContratanteOrcamento = new Map<Id, List<GarantiaContratanteOrcamento__c>>();
    private Map<String, String> mapConversaoTipoProposta = new Map<String, String>{'CAN' => 'CANCELAMENTO', 'Cancelamento' => 'Cancelamento', 'Endosso' => 'Endosso', 'Novo' => 'Novo', 'Seguro novo' => 'Novo', 'Renovação' => 'Renovacao', 'Renovacao' => 'Renovacao'}; //RVI-104/RVI-138-FIX01-INÍCIO/FIM
        private Map<String, String> mapConversaoTipoSeguro = new Map<String, String>{'Cancelamento' => 'CAN'};
            private final Map<String, String> mapPapeis = new Map<String, String> { 'REP' => 'RepresentanteSeguros', 'COR' => 'Corretor', 'PRE'  => 'Prestador', 'AGE'  => 'Agenciador', 'PAR'  => 'Parceiro' };
                //INICIO | PLV-2610-SNIPER
                public static Constante__mdt constante = [SELECT Id, Valor__c
                                                          FROM Constante__mdt
                                                          WHERE DeveloperName = 'DIAS_VIGENCIA_PROPOSTA'];
    //FIM | PLV-2610-SNIPER
    /* ---------------------------------- INTERFACE --------------------------------------------------------------- */
    //INICIO | PLV-2402-30
    public override List<Proposta.ContratanteWrapper> gerarContratantes(EmissaoTO.PayloadTO payloadTO){ return null; }
    public override List<Proposta.GrupoWrapper> gerarGrupos(List<EmissaoTO.GrupoTO> gruposTO, String numeroContratante){ return null; }
    public override List<Proposta.SeguradoWrapper> gerarSegurados(List<EmissaoTO.SeguradoTO> seguradosTO, String numeroContratante, String numeroGrupo){ return null; }

    //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ

    public Integer opcaoPagamentoCliente = 0;
    public String segmento;
    
    public Decimal retencaoComissao = 0; //AV-614 - INICIO/FIM
        

    public Map<Integer, Map<Integer,Map<String,EmissaoTO.CoberturaTO>>> mapOpcaoDesconto = new Map<Integer, Map<Integer,Map<String,EmissaoTO.CoberturaTO>>>();
    public Map<Integer, Map<Integer,EmissaoTO.GrupoTO>> mapOpcaoDescontoGrupos = new Map<Integer, Map<Integer,EmissaoTO.GrupoTO>>();

    public void preencherMapCalculosCoberturas(){
        if(String.isBlank(this.segmento)){
            throw new PropostaBuilderException('Segmento da proposta está vazio');
        }

        Map<String,String> mapGrupoNome = new Map<String,String>();
        if('Viagem'.equalsIgnoreCase(this.segmento)){
            for(EmissaoTO.GrupoTO grupo : this.payloadOrcamentoPrecificacao.orcamento.contratantes[0].grupos){
                mapGrupoNome.put(grupo.numero,grupo.nome);
            }
        }
        
        Integer indiceGrupo = 0;
        System.debug(Logginglevel.Error,'preencherMapCalculosCoberturas inicio');
        if(this.payloadOrcamentoPrecificacao.retornosCalculo != null){
            for(EmissaoTO.RetornoCalculoTO retornoC : this.payloadOrcamentoPrecificacao.retornosCalculo){

                this.mapOpcaoDesconto.put(retornoC.opcao,new Map<Integer,Map<String,EmissaoTO.CoberturaTO>>());
                this.mapOpcaoDescontoGrupos.put(retornoC.opcao,new Map<Integer,EmissaoTO.GrupoTO>());

                if(retornoC.precificacao.contratantes[0].grupos!=null){
                    for(EmissaoTO.GrupoTO grupo : retornoC.precificacao.contratantes[0].grupos){
                        //Se for viagem deve seguir essa lógica de formação de grupos quando tiver mais de um grupo
                        if('Viagem'.equalsIgnoreCase(this.segmento)) {
                            String nomeDoGrupo = mapGrupoNome.containsKey(grupo.numero) ?  mapGrupoNome.get(grupo.numero) : '';
                            indiceGrupo = (String.isNotBlank(nomeDoGrupo) && nomeDoGrupo == 'Passageiros até 70 anos') ? 0 : 1;
                        }

                        this.mapOpcaoDesconto.get(retornoC.opcao).put(indiceGrupo,new Map<String,EmissaoTO.CoberturaTO>());
                        this.mapOpcaoDescontoGrupos.get(retornoC.opcao).put(indiceGrupo,grupo);
                        //PLV-5358 INICIO
                        /*for(EmissaoTO.CoberturaTO cobertura :  grupo.coberturas){
                            this.mapOpcaoDesconto.get(retornoC.opcao).get(indiceGrupo).put(cobertura.sigla,cobertura);
                        }*/
                        for(EmissaoTO.CoberturaTO cobertura :  grupo.segurados[0].coberturas){
                            this.mapOpcaoDesconto.get(retornoC.opcao).get(indiceGrupo).put(cobertura.sigla,cobertura);
                        }
                        //PLV-5358 FIM
                    }
                }
            }
        }
        
        System.debug(Logginglevel.Error,'preencherMapCalculosCoberturas FIM');
    }
                        
    //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ

    public override void popularPrecificacao(EmissaoTO.PrecificacaoTO precificacaoTO){}	
    
    public override void validarPayload(EmissaoTO.PayloadTO payloadTO){
        
    }
    //FIM | PLV-2402-30
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: Atualiza Status Proposta
*/
    public Proposta atualizarStatusProposta(EmissaoTO.PayloadTO payloadTO)
    {
        //INICIO | PLV-2402-30
        Proposta proposta = new Proposta();
        List<CriticaProposta__c> listCriticaProposta = new List<CriticaProposta__c>();
        proposta.propostaWrapper = new Proposta.PropostaWrapper();
        
        String numeroProposta = payloadTO.proposta.numero.leftPad(8,'0');
        String nameProposta = QuoteBO.getInstance().gerarNameProposta(String.valueOf(payloadTO.proposta.origem),numeroProposta);
        List<Quote> propostaConsulta = QuoteDAO.getInstance().obterPropostaPorName(nameProposta);
        //II-165 INICIO
        //II-165 FIX03 INICIO 
        //Boolean hasCtrAnalise = gerarCriticaAnalise(propostaConsulta);
        //II-165 FIX03 FIM
        //II-165 FIM
       
        
        System.debug('PLV_2826 - propostaConsulta: '+ propostaConsulta);
        
        
        if(!propostaConsulta.isEmpty())
        {
            proposta.propostaWrapper.sfProposta = propostaConsulta[0];
            System.debug('proposta.propostaWrapper.sfProposta: '+ proposta.propostaWrapper.sfProposta);
            
            System.debug('PLV_2826 - proposta.propostaWrapper.sfProposta: ' + proposta.propostaWrapper.sfProposta.AccountId);
            
            if(payloadTO.retornoAceitacao != null){
                //PLV-4993 - INICIO
                //PLV-4440 - INICIO
                //PLV-3888 -FIX1 - Inicio - Incluir campo Chave_de_Agrupamento__c
                if(payloadTO.retornoFinanceiro != null){
                    proposta.propostaWrapper.sfProposta.Chave_de_Agrupamento__c = payloadTO.retornoFinanceiro.autorizacaoCartao.stargate.codigoAgrupamento;
                }
                if(payloadTO.recusada==true){
                    proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; //II-48 FIX01 INICIO-FIM 
                    proposta.propostaWrapper.sfProposta.Status = 'Recusada';
                    payloadTO.retornoAceitacao.recusas.add(gerarCritica666(payloadTO.origemRecusa));
                }
                // faz a leitura do payload e insere as criticas da proposta
                gerarCriticas(payloadTO, proposta.propostaWrapper.criticasWrapper);
                //PLV-4993 - FIM
                //PLV-3888 - Fim
                //PLV-4440 - FIM
                // PLV-4481 INICIO
                // PLV-4606 - INICIO
                System.debug('payloadto karin');
                System.debug(payloadTO);
                if(payloadTO.orcamento != null){
                    System.debug('empresa> '+ payloadTO.orcamento.contratoOriginal.empresa + ' Sucursal> ' + payloadTO.orcamento.contratoOriginal.sucursal);
                    System.debug('ramo> ' + payloadTO.orcamento.contratoOriginal.ramo + ' apolice> ' + payloadTO.orcamento.contratoOriginal.apolice);
                
                    String IdContratoOriginal = ContractBO.getInstance().gerarNameContrato(payloadTO.orcamento.contratoOriginal.empresa, String.valueOf(payloadTO.orcamento.contratoOriginal.sucursal), String.valueOf(payloadTO.orcamento.contratoOriginal.ramo), Integer.valueOf(payloadTO.orcamento.contratoOriginal.apolice), '0');

                    //String IdContratoOriginal = payloadTO.orcamento.contratoOriginal.empresa + payloadTO.orcamento.contratoOriginal.sucursal + payloadTO.orcamento.contratoOriginal.ramo + payloadTO.orcamento.contratoOriginal.apolice + '-0';
                    List<Contract> propostaOriginal = [SELECT Id, Proposta__c FROM Contract WHERE IdExterno__c =: IdContratoOriginal];
                    
                    List<CriticaProposta__c> criticaPropostaOriginal = [SELECT Id, Acao__c, Status__c FROM CriticaProposta__c WHERE Proposta__c =: propostaOriginal[0].Proposta__c AND Integracao__c = 'SAMPLE'];
                    // Atribui Id da proposta nas criticas da proposta
                    for(Proposta.CriticaPropostaWrapper criticaProposta : proposta.propostaWrapper.criticasWrapper ){
                        criticaProposta.sfCriticaProposta.Id = null;
                        criticaProposta.sfCriticaProposta.Proposta__c = proposta.propostaWrapper.sfProposta.Id;
                        for(CriticaProposta__c criticaOld : criticaPropostaOriginal){
                            if(criticaProposta.sfCriticaProposta.Integracao__c == 'SAMPLE'){
                                if(criticaOld.Acao__c == 'auto' && criticaProposta.sfCriticaProposta.Acao__c == 'tele'){
                                    criticaProposta.sfCriticaProposta.Status__c = 'Pendente';
                                }else if(criticaOld.Acao__c == 'auto' && criticaProposta.sfCriticaProposta.Acao__c == 'video'){
                                    criticaProposta.sfCriticaProposta.Status__c = 'Pendente';
                                }else if(criticaOld.Acao__c == 'tele' && criticaProposta.sfCriticaProposta.Acao__c == 'video'){
                                    criticaProposta.sfCriticaProposta.Status__c= 'Pendente';
                                }else{
                                    criticaProposta.sfCriticaProposta.Status__c= 'Não iniciada';
                                }
                            }
                        }
                        listCriticaProposta.add(criticaProposta.sfCriticaProposta);
                    }
                    // PLV-4481 FIM

                    try{
                        insert listCriticaProposta;
                    }catch (Exception e){
                        throw new PropostaBuilderException('Exception: Inserir criticas da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
                    }
                }else{
                    try{
                        for(Proposta.CriticaPropostaWrapper criticaProposta : proposta.propostaWrapper.criticasWrapper ){
                            criticaProposta.sfCriticaProposta.Id = null;
                            criticaProposta.sfCriticaProposta.Proposta__c = proposta.propostaWrapper.sfProposta.Id;
                            criticaProposta.sfCriticaProposta.Status__c= 'Pendente';
                            listCriticaProposta.add(criticaProposta.sfCriticaProposta);
                        }
                        insert listCriticaProposta;
                    }catch (Exception e){
                        throw new PropostaBuilderException('Exception: Inserir criticas da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
                    }
                }
                // PLV-4606 - FIM
                
                // valida status da proposta de acordo com o nó de retorno
				//PLV-4980 INICIO 
                if(payloadTO.retornoAceitacao.recusas != null && payloadTO.retornoAceitacao.recusas.size() > 0){ //PLV-3285
                    proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; //II-48 FIX01 INICIO-FIM 
                    proposta.propostaWrapper.sfProposta.Status = 'Recusada';
                    proposta.propostaWrapper.sfProposta.isRecusadaSumariamente__c = true;
                //PLV-2722 - Inicio - Alteração de lógica no if
                //PLV-3285 - INICIO
				}//PLV-4980 FIM 
                else if((	payloadTO.retornoAceitacao.pendencias != null && payloadTO.retornoAceitacao.pendencias.size() > 0)||
                (payloadTO.retornoAceitacao.analises != null && payloadTO.retornoAceitacao.analises.size() > 0)) //PLV-2675 - Inicio/Fim - Validação alterada pois o ODM retorna null a tag pendencias
                //PLV-3285 - FIM
                //PLV-4481 INICIO
                for(EmissaoTO.AnaliseTO analise : payloadTO.retornoAceitacao.analises)
                        // PLV-4606-INICIO
                        if(payloadTO.proposta.tipoSeguro == 'CAN'){
                            proposta.propostaWrapper.sfProposta.Status = 'Em análise';
                            proposta.propostaWrapper.sfProposta.FaseStatus__c = 'Análise interna'; // PLV-4606-FIX
                        }else if(analise.integracao != 'DOCUSIGN' && payloadTO.proposta.tipoSeguro != 'EDS'){
                            proposta.propostaWrapper.sfProposta.Status = 'Em análise';
                        }
                        else{
                            proposta.propostaWrapper.sfProposta.Status = 'Disponível para contratação';
                        }
                        // PLV-4606-FIM
                //PLV-4481 FIM
                //PLV-2722 - Fim - Alteração de lógica no if	
                else
                    proposta.propostaWrapper.sfProposta.Status = 'Disponível para contratação';
            }
            else{
                if(payloadTO.recusada==true){
                    proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; //II-48 FIX01 INICIO-FIM 
                    proposta.propostaWrapper.sfProposta.Status = 'Recusada';
                    payloadTO.retornoAceitacao.recusas.add(gerarCritica666(payloadTO.origemRecusa));
                }
                for(Proposta.CriticaPropostaWrapper criticaProposta : proposta.propostaWrapper.criticasWrapper ){
                    criticaProposta.sfCriticaProposta.Id = null;
                    criticaProposta.sfCriticaProposta.Proposta__c = proposta.propostaWrapper.sfProposta.Id;
                    listCriticaProposta.add(criticaProposta.sfCriticaProposta);
                }
                // PLV-4481 FIM

                try{
                    insert listCriticaProposta;
                }catch (Exception e){
                    throw new PropostaBuilderException('Exception: Inserir criticas da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
                }
                //PLV-4993 - INICIO
                proposta.propostaWrapper.sfProposta.Status = payloadTO.recusada==null || payloadTO.recusada==false ? 'Disponível para contratação' : payloadTO.recusada!=null && payloadTO.recusada==true ? 'Recusada' : 'Disponível para contratação';
                /*if(payloadTO.recusada==null || payloadTO.recusada==false){
                    proposta.propostaWrapper.sfProposta.Status = 'Disponível para contratação';
                }else if(payloadTO.recusada!=null || payloadTO.recusada==true){
                    proposta.propostaWrapper.sfProposta.Status = 'Recusada';
                }*/
                //PLV-4993 - FIM
               
            }
          
            //II-165 INICIO
            //II-165 FIX03 INICIO
            // if(hasCtrAnalise && proposta.propostaWrapper.sfProposta.Status == 'Disponível para contratação'){
            //     proposta.propostaWrapper.sfProposta.Status = 'Em análise';
            // }
            //II-165 FIX03 FIM
            //II-165 FIM

            try{
                // Atualiza proposta
                update proposta.propostaWrapper.sfProposta;
            }
            catch (Exception e){
                throw new PropostaBuilderException('Exception: Atualizar proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
            }
            
            
            // Verifica se eh uma proposta de endosso ou cancelamento
            System.debug('$$$$ propostaConsulta[0].Contract :> ' + propostaConsulta[0].Contract);
            System.debug('$$$$ propostaConsulta[0].Opportunity :> ' + propostaConsulta[0].Opportunity);
            if(propostaConsulta[0].Contract != null){
                proposta.propostaWrapper.retornoWrapper.numeroApolice = propostaConsulta[0].Contract.NumeroApolice__c;
                proposta.propostaWrapper.retornoWrapper.codigoEmpresa = propostaConsulta[0].Contract.Empresa__c;
                proposta.propostaWrapper.retornoWrapper.codigoSucursal = propostaConsulta[0].Contract.Sucursal__c;
                proposta.propostaWrapper.retornoWrapper.codigoRamo = propostaConsulta[0].Contract.CodigoRamo__c;
            }
            
            proposta.propostaWrapper.retornoWrapper.numeroOrcamento = propostaConsulta[0].Opportunity.Numero__c;
            if(propostaConsulta[0].CodigoCorretor__r != null) proposta.propostaWrapper.retornoWrapper.codigoSucursal = propostaConsulta[0].CodigoCorretor__r.CodigoSucursalVinculo__c;//PLV-4515 - INICIO/FIM
            if(propostaConsulta[0].RamoSeguro__r != null) proposta.propostaWrapper.retornoWrapper.codigoRamo = propostaConsulta[0].RamoSeguro__r.Codigo__c;
            //PLV_3196 - INICIO - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
            if(propostaConsulta[0].Modalidade__r != null) proposta.propostaWrapper.retornoWrapper.modalidade = propostaConsulta[0].Modalidade__r.Codigo__c;
            //PLV_3196 - FIM - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
            
        }
        
        return proposta;
        //FIM | PLV-2402-30
    }
    //PLV-4993 - INICIO
    public EmissaoTO.RecusaTO gerarCritica666(String sistema){
        EmissaoTO.RecusaTO recusa = new EmissaoTO.RecusaTO();
        recusa.codigo = 666;
        recusa.descricao = 'Erro de Infraestrutura na chamada do '+sistema;
        return recusa;
    }
    //PLV-4993 - FIM
    //PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
    public List<Proposta> atualizarStatusListaPropostas(EmissaoTO.PayloadTO payloadTO)
    {
        
        Set<String> 			 setPropostas 				   = new Set<String>();
        Set<String> 			 setPropostasParaEnviarVoucher = new Set<String>();
        Map<String, Quote> 		 mapPropostas 				   = new Map<String, Quote>();
        Map<String, String>		 mapPropostasVoucherEnviado	   = new Map<String, String>();
        List<CriticaProposta__c> listCriticaProposta 		   = new List<CriticaProposta__c>();
        List<Quote> 			 listaPropostas 	           = new List<Quote>(); //II-48 INICIO-FIM
        List<Proposta> 			 listaPropostasDevolutiva 	   = new List<Proposta>();
        Boolean					 existeCriticaFinanceiro	   = false;  // TKCL-458 FIX02 INICIO/FIM
        Boolean					 existeCriticaAceitacao        = false;
        String 					 namePropostaPrincipal;
        String					 idPropostaPrincipal;       
        final List<String> portopagStatusNaoAprovado = new List<String>{'REJEITADA','CANCELADA','ERRO','IGNORADA','EXPIRADA','DESCONHECIDO'}; // TKCL-458 FIX02 INICIO/FIM      
        
        //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
        QuoteBO.atualizarOrcamento = (payloadTO.atualizarOrcamento != null) ? payloadTO.atualizarOrcamento : false;        
        //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros

        //Cria um set para ser usado no select das propostas
        for(EmissaoTO devolutiva : payloadTO.devolutivas){
            system.debug('devolutiva.proposta.numero: '+devolutiva.proposta.numero);
            system.debug('entrou devolutiva');
            String numeroProposta = devolutiva.proposta.numero.leftPad(8,'0');
            system.debug('numeroProposta: ' +numeroProposta);
            String nameProposta = QuoteBO.getInstance().gerarNameProposta(String.valueOf(devolutiva.proposta.origem),numeroProposta);
            setPropostas.add(nameProposta);
            //if(devolutiva.proposta.indice != null){
                if(devolutiva.proposta.indice == 1) namePropostaPrincipal = nameProposta;
            //}	
        }
        
        String oportunidadeID; //PLV-4398 - INICIO/FIM
        //Consulta as propostas e monta um mapa usando o name como chave
        //VIAG-165 FIX02 INICIO

        //VIAG-232 INICIO
        //Set<Id> opportunityIds = new Set<Id>();
        List<Quote> travelListQuotes = new List<Quote>();
        //II-165 INICIO
        //II-165 FIX03 INICIO
        // List<Quote> propConsulta = QuoteDAO.getInstance().obterListaPropostasPorName(setPropostas);
        // System.debug('propConsulta _><' + propConsulta);
        // Boolean hasCtrAnalise = gerarCriticaAnalise(propConsulta);
        // for(Quote sfProposta : propConsulta){
        //II-165 FIM
        for(Quote sfProposta : QuoteDAO.getInstance().obterListaPropostasPorName(setPropostas)){
        //II-165 FIX03 FIM
            mapPropostas.put(sfProposta.name, sfProposta);					
            oportunidadeID = sfProposta.OpportunityId; //PLV-4398 - INICIO/FIM
            //PLV-5857 INICIO
            if(sfProposta.segmento__c == 'Viagem'){
                // sfProposta.CupomDesconto__c = sfProposta.Opportunity.CupomDesconto__c; //VIAG-274 INICIO-FIM
                travelListQuotes.add(sfProposta);
                //opportunityIds.add(oportunidadeID);
            }
        }

        if(!travelListQuotes.isEmpty()){
            update travelListQuotes;
            //getAtualizaCupom(travelListQuotes);
        }
        //VIAG-232 FIM

        //PLV-5857 FIM
        //VIAG-165 FIX02 FIM

        //PLV-4440 - INICIO
        if(payloadTO.retornoFinanceiro != null){
            //TKCL 458 - INICIO
            if(payloadTO.retornoFinanceiro.autorizacaoCartao.stargate != null){
                existeCriticaFinanceiro = payloadTO.retornoFinanceiro.autorizacaoCartao.stargate.codigo != 2 ? true : existeCriticaFinanceiro; // TKCL-458 FIX02 INICIO/FIM
            }
            if(payloadTO.retornoFinanceiro.autorizacaoCartao.portoPag != null){
                System.debug('PORTO PAG: ' + payloadTO.retornoFinanceiro.autorizacaoCartao.portoPag);
                //TKCL 460 - INICIO
                contratanteTORecorrente.recorrencia = true;
                //TKCL 460 - FIM
                // TKCL-458 FIX02 INICIO
                if (payloadTO.retornoFinanceiro.autorizacaoCartao.portoPag.cobrancas == null || payloadTO.retornoFinanceiro.autorizacaoCartao.portoPag.cobrancas.isEmpty()) {
                    existeCriticaFinanceiro = true;
                } else {
                    for(EmissaoTO.CobrancaTO cobranca : payloadTO.retornoFinanceiro.autorizacaoCartao.portoPag.cobrancas){
                        //II-48 FIX03 INICIO
                        if(cobranca.detalhes != null && (!cobranca.detalhes.equals('APPROVED') && !cobranca.detalhes.equals('Success.')) && cobranca.estado != 'PAGA'){
                            existeCriticaFinanceiro = true;
                        }
                        //II-48 FIX03 FIM
                    }
                }
                // TKCL-458 FIX02 FIM
                //TKCL 460 - INICIO
                ContratanteProposta__c contratanteSf = new ContratanteProposta__c();
                if(contratanteTORecorrente.recorrencia != null && contratanteTORecorrente.recorrencia){
                    contratanteSf.Recorrencia__c = contratanteTORecorrente.recorrencia;
                    insert contratanteSf;
                }
                //TKCL 460 - FIM
            }
            //TKCL 458 - FIM
        }
        //PLV-4440 - FIM
        
        //PLV-3888 - Inicio
        List<Id> listaIdProposta = new List<Id>();
        //PLV-3888 - Fim
        System.debug('payloadTO.devolutivas = '+ payloadTO.devolutivas);
        System.debug('payloadTO.'+ JSON.serialize(payloadTO));

        payloadTO.proposta2 = new EmissaoTO.PessoaTO();//OKR 146 INICIO-FIN       
        
        for(EmissaoTO devolutiva : payloadTO.devolutivas){            
            Proposta proposta = new Proposta(); //OKR 146 INICIO-FIN
            proposta.propostaWrapper = new Proposta.PropostaWrapper();
            
            proposta.propostaWrapper.retornoWrapper.indice = devolutiva.proposta.indice;
            //Monta o name da proposta novamente para comparar com a chave do mapa criado acima
            String numeroProposta = devolutiva.proposta.numero.leftPad(8,'0');
            String namePropostaPayload = QuoteBO.getInstance().gerarNameProposta(String.valueOf(devolutiva.proposta.origem),numeroProposta);
            
            system.debug('mapPropostas: '+mapPropostas);
            system.debug('namePropostaPayload: '+namePropostaPayload);
            if(!mapPropostas.containsKey(namePropostaPayload)) continue;
            
            proposta.propostaWrapper.sfProposta = mapPropostas.get(namePropostaPayload);
            //Remove a proposta do mapa para que seja inserida novamente após a atualização do status
            //mapPropostas.remove(namePropostaPayload);
            System.debug('proposta.propostaWrapper.sfProposta: '+ proposta.propostaWrapper.sfProposta);
            //PLV-4993 - INICIO
            if(payloadTO.recusada==true){
                proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; //II-48 FIX01 INICIO-FIM 
                proposta.propostaWrapper.sfProposta.Status = 'Recusada';
                listaPropostas.add(proposta.propostaWrapper.sfProposta); //II-48 FIX01 INICIO-FIM 
                if(devolutiva.retornoAceitacao==null) devolutiva.retornoAceitacao = new EmissaoTO.RetornoAceitacaoTO();
                if(devolutiva.retornoAceitacao.recusas==null) devolutiva.retornoAceitacao.recusas = new List<EmissaoTO.RecusaTO>();
                devolutiva.retornoAceitacao.recusas.add(gerarCritica666(payloadTO.origemRecusa));
            }
            //PLV-4993 - FIM
            
            //PLV-4440 - INICIO
            //PLV-3888 - Inicio - Incluir campo Chave_de_Agrupamento__c
            listaIdProposta.add(proposta.propostaWrapper.sfProposta.Id);
            if(payloadTO.retornoFinanceiro != null){
                //TKCL 458 - INICIO
                if(payloadTO.retornoFinanceiro.autorizacaoCartao.stargate != null){
                    proposta.propostaWrapper.sfProposta.Chave_de_Agrupamento__c = payloadTO.retornoFinanceiro.autorizacaoCartao.stargate.codigoAgrupamento;			
                    //II-48 INICIO
                    if(payloadTO.retornoFinanceiro.autorizacaoCartao.stargate.codigo != 2){
                        proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; //II-48 INICIO-FIM
                        //II-165 INICIO
                        //II-165 FIX03 INICIO
                        if(!listaPropostas.contains(proposta.propostaWrapper.sfProposta)){ 
                            listaPropostas.add(proposta.propostaWrapper.sfProposta); 
                        }
                        //II-165 FIX03 FIM
                        //II-165 FIM
                    }	
                    //II-48 FIM	
                }
                if(payloadTO.retornoFinanceiro.autorizacaoCartao.portoPag != null){                 
                    proposta.propostaWrapper.sfProposta.Chave_de_Agrupamento__c = '';
                    //II-48 FIX03 INICIO
                    if(payloadTO.retornoFinanceiro.autorizacaoCartao.portoPag.erros != null){
                        proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; 
                        //II-165 INICIO
                        //II-165 FIX03 INICIO 
                        if(!listaPropostas.contains(proposta.propostaWrapper.sfProposta)){ 
                            listaPropostas.add(proposta.propostaWrapper.sfProposta); 
                        }
                        //II-165 FIX03 FIM 
                        //II-165 FIM
                    }
                    //II-48 FIX03 FIM
                }
                //TKCL 458 - FIM
             //PLV-3888 - Fim
                System.debug('existeCriticaFinanceiro.'+ JSON.serialize(existeCriticaFinanceiro));

                // faz a leitura dos nós de crítica do payload e insere as criticas da proposta
                //II-48 FIX03 INICIO
                if(existeCriticaFinanceiro){
                    proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; 
                    //II-48 FIX04 INICIO
                    if(!listaPropostas.contains(proposta.propostaWrapper.sfProposta)){
                    listaPropostas.add(proposta.propostaWrapper.sfProposta); 
                    }
                    //II-48 FIX04 INICIO
                    gerarCriticasRetornoFinanceiro(payloadTO.retornoFinanceiro, proposta.propostaWrapper.criticasWrapper);
            }
                //II-48 FIX03 FIM
            }
            //PLV-4440 - FIM
            
            if(devolutiva.retornoAceitacao != null){
                gerarCriticasRetornoAceitacao(devolutiva.retornoAceitacao, proposta.propostaWrapper.criticasWrapper, devolutiva.proposta);//PLV-5643 INICIO/FIM
                
                //VIDA-131 - INICIO
                for(Proposta.CriticaPropostaWrapper critica: proposta.propostaWrapper.criticasWrapper){
                    if(critica.sfCriticaProposta.Tipo__c.equals('Recusa')){
                        proposta.propostaWrapper.sfProposta.CodigoMotivoDevolucao__c = '10'; 
                        proposta.propostaWrapper.sfProposta.Status = 'Recusada';

                        if(!listaPropostas.contains(proposta.propostaWrapper.sfProposta)){
                            listaPropostas.add(proposta.propostaWrapper.sfProposta); 
                        }
                    }
                }
                //VIDA-131 - INICIO
            }   
            
            if(!proposta.propostaWrapper.criticasWrapper.isEmpty()){
                
                 // PLV-4953 - INICIO - Atribuir TipoSubscricao (se crítica Samplemed)
                 for(Proposta.CriticaPropostaWrapper critica : proposta.propostaWrapper.criticasWrapper ){
                    if (critica.sfCriticaProposta != null && critica.sfCriticaProposta.Integracao__c == 'SAMPLE' &&
                    (critica.sfCriticaProposta.Acao__c == 'auto' || critica.sfCriticaProposta.Acao__c == 'tele' ||
                    critica.sfCriticaProposta.Acao__c == 'video')) {
                        proposta.propostaWrapper.sfProposta.TipoSubscricao__c = critica.sfCriticaProposta.Acao__c;
                    }
                }
                // PLV-4953 - FIM

                // Atribui Id da proposta nas criticas da proposta
                for(Proposta.CriticaPropostaWrapper criticaProposta : proposta.propostaWrapper.criticasWrapper ){
                    criticaProposta.sfCriticaProposta.Id = null;
                    criticaProposta.sfCriticaProposta.Proposta__c = proposta.propostaWrapper.sfProposta.Id;
                    listCriticaProposta.add(criticaProposta.sfCriticaProposta);
                }
                
                System.debug('XXX - Proposta2: ' + JSON.serialize(payloadTO.proposta2));

                // valida status da proposta de acordo com o nó de retorno
                if(devolutiva.retornoAceitacao.recusas != null && devolutiva.retornoAceitacao.recusas.size() > 0 || existeCriticaFinanceiro == true){
                    //OKR-146 INICIO
                    if(payloadTO.proposta2.nivelRelacionamento != '5' && payloadTO.proposta2.nivelRelacionamento != '6'){
                        proposta.propostaWrapper.sfProposta.Status = 'Recusada';
                        mapPropostas.get(namePropostaPayload).status = 'Recusada';					
                        proposta.propostaWrapper.sfProposta.isRecusadaSumariamente__c = true; //PLV-4980 INICIO/FIM					
                        }else{
                            proposta.propostaWrapper.sfProposta.Status = 'Em análise';
                            mapPropostas.get(namePropostaPayload).status = 'Em análise';					
                        }
                    //OKR-146 FIN
                }else if((devolutiva.retornoAceitacao.pendencias != null && devolutiva.retornoAceitacao.pendencias.size() > 0)||
                         (devolutiva.retornoAceitacao.analises != null && devolutiva.retornoAceitacao.analises.size() > 0)){
                             proposta.propostaWrapper.sfProposta.Status = 'Em análise';
                             mapPropostas.get(namePropostaPayload).status = 'Em análise';					
                         }else{
                             proposta.propostaWrapper.sfProposta.Status = 'Disponível para contratação';
                             mapPropostas.get(namePropostaPayload).status = 'Disponível para contratação';
                             if(mapPropostas.get(namePropostaPayload).name == namePropostaPrincipal) idPropostaPrincipal = mapPropostas.get(namePropostaPayload).id;
                             setPropostasParaEnviarVoucher.add(mapPropostas.get(namePropostaPayload).id);
                         }	
            }
            else{
                proposta.propostaWrapper.sfProposta.Status = 'Disponível para contratação';
                mapPropostas.get(namePropostaPayload).status = 'Disponível para contratação';
                if(mapPropostas.get(namePropostaPayload).name == namePropostaPrincipal) idPropostaPrincipal = mapPropostas.get(namePropostaPayload).id;
              //  setPropostasParaEnviarVoucher.add(mapPropostas.get(namePropostaPayload).id);
                   
            }

            //II-165 INICIO
            //II-165 FIX03 INICIO 
            // if(hasCtrAnalise && proposta.propostaWrapper.sfProposta.Status == 'Disponível para contratação'){
            //     System.debug('Entrou aqui');
            //     proposta.propostaWrapper.sfProposta.Status = 'Em análise';
            // }
            //II-165 FIX03 FIM 
            //II-165 FIM
              
           
            
            
            // Verifica se eh uma proposta de endosso ou cancelamento
            System.debug('$$$$ mapPropostas.get(namePropostaPayload).Contract :> ' + mapPropostas.get(namePropostaPayload).Contract);
            System.debug('$$$$ mapPropostas.get(namePropostaPayload);.Opportunity :> ' + mapPropostas.get(namePropostaPayload).Opportunity);
            if(mapPropostas.get(namePropostaPayload).Contract != null){
                proposta.propostaWrapper.retornoWrapper.numeroApolice = mapPropostas.get(namePropostaPayload).Contract.NumeroApolice__c;
                proposta.propostaWrapper.retornoWrapper.codigoEmpresa = mapPropostas.get(namePropostaPayload).Contract.Empresa__c;
                proposta.propostaWrapper.retornoWrapper.codigoSucursal = mapPropostas.get(namePropostaPayload).Contract.Sucursal__c;
                proposta.propostaWrapper.retornoWrapper.codigoRamo = mapPropostas.get(namePropostaPayload).Contract.CodigoRamo__c;
            }
            
            proposta.propostaWrapper.retornoWrapper.numeroOrcamento = mapPropostas.get(namePropostaPayload).Opportunity.Numero__c;
            if(mapPropostas.get(namePropostaPayload).CodigoCorretor__r != null) proposta.propostaWrapper.retornoWrapper.codigoSucursal = mapPropostas.get(namePropostaPayload).CodigoCorretor__r.CodigoSucursalVinculo__c; //PLV-4515 - INICIO/FIM
            if(mapPropostas.get(namePropostaPayload).RamoSeguro__r != null) proposta.propostaWrapper.retornoWrapper.codigoRamo = mapPropostas.get(namePropostaPayload).RamoSeguro__r.Codigo__c;
            if(mapPropostas.get(namePropostaPayload).Modalidade__r != null) proposta.propostaWrapper.retornoWrapper.modalidade = mapPropostas.get(namePropostaPayload).Modalidade__r.Codigo__c;
            
            // VIAG-141 INICIO

            Datetime validade;
            validade = Datetime.valueOf(mapPropostas.get(namePropostaPayload).DataLimitePagamento__c);
            Datetime newDate;
            newDate  = validade.addHours(3);
            System.debug('adicionou mais 3 horas' + newDate + 'validade'+ validade);
            proposta.propostaWrapper.retornoWrapper.validadePagamento = String.valueOf(newDate);
            System.debug('proposta.propostaWrapper.retornoWrapper.validadePagamento>>>' +  proposta.propostaWrapper.retornoWrapper.validadePagamento );
            // VIAG-141 INICIO
            
            listaPropostasDevolutiva.add(proposta);
        }

        //PLV-3888 - Inicio
		List<Contract> contratoList = [select Id, Chave_de_agrupamento__c from Contract where Proposta__c =: listaIdProposta];
        
        //PLV-4440 - INICIO
        if(payloadTO.retornoFinanceiro != null){
            //TKCL 458 - INICIO FIX01
            String chaveAgrupamento = payloadTO.retornoFinanceiro.autorizacaoCartao.stargate != null ? payloadTO.retornoFinanceiro.autorizacaoCartao.stargate.codigoAgrupamento : '';
            for(Contract contrato : contratoList){                
                contrato.Chave_de_agrupamento__c = chaveAgrupamento;
                //TKCL 458 - FIX01 FIM 
            }
        }
        //PLV-4440 - FIM
		
		update contratoList;
        //PLV-3888 - Fim

        //Insere os objetos de critica
        System.debug('Alexandre>>>>>>> ' + listCriticaProposta);
        update listaPropostas; //II-48 INICIO-FIM
        insert listCriticaProposta;
        //Atualiza as propostas do SF retornada no select
        update mapPropostas.values();
        
        //PLV-3755 - INICIO - Mudança na forma de envio do Voucher
        //Chama a classe responsável pelo envio do voucher para os segurados.
        // O mapa de retorno contem o link de cada voucher enviado, identificado pelo id da Proposta correspondente.
        if(existeCriticaFinanceiro == false){
            VoucherEmailController voucherEmail = new VoucherEmailController();
            //PLV-4398 - INICIO
            system.debug('idPropostaPrincipal:'+idPropostaPrincipal);
            if(idPropostaPrincipal == null && oportunidadeID != null){
                
                system.debug('busca proposta principal, oportunidadeID: '+oportunidadeID);
                idPropostaPrincipal = [select Id from Quote where OpportunityId =: oportunidadeID  ORDER BY NumeroProposta__c  ASC LIMIT 1].Id;
                setPropostasParaEnviarVoucher.add(idPropostaPrincipal);
            }
            system.debug('setPropostasParaEnviarVoucher'+setPropostasParaEnviarVoucher);
            system.debug('idPropostaPrincipal novo'+idPropostaPrincipal);
            
            //PLV-5200 - INICIO
            //PLV-4398 - FIM
            System.debug('atualizarStatusListaPropostas mapPropostasVoucherEnviado>>>>');  
            System.debug(mapPropostasVoucherEnviado);
            System.debug('atualizarStatusListaPropostas payloadTO.recusada>>>>');
            System.debug(payloadTO);
            if(payloadTO.recusada != true){ 
        
               // MGRC-505 INICIO
              //  mapPropostasVoucherEnviado = VoucherEmailController.SendEmails(setPropostasParaEnviarVoucher, idPropostaPrincipal);
                //Percorre a lista criada anteriormente preenchendo o campo do link em cada Proposta (PropostaWrapper)
             //   if(!mapPropostasVoucherEnviado.isEmpty() && mapPropostasVoucherEnviado.get('Sucesso') == 'true'){
             //       for(Proposta proposta : listaPropostasDevolutiva){
             //           proposta.propostaWrapper.retornoWrapper.LinkVoucher = mapPropostasVoucherEnviado.get(proposta.propostaWrapper.sfProposta.id);
             //       }
             //   }
             // MGRC-505 FIM
            }               
            System.debug('atualizarStatusListaPropostas mapPropostasVoucherEnviado>>>>');   
            System.debug(mapPropostasVoucherEnviado);
            //PLV-5200 - FIM
        }
        //PLV-3755 - FIM - Mudança na forma de envio do Voucher
        
        //Retona a lista com todos os objetos wrapper das Propostas
        return listaPropostasDevolutiva;		
    }
    //PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
    
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: cria a proposta
*/
    public override void gerarProposta(EmissaoTO.PayloadTO payloadTO)
    {
        List<EmissaoTO.RemuneracaoTO> remuneracoesPropostaTO = payloadTO.proposta.remuneracoes; //II-167 INICIO/FIM
        payload = payloadTO;
        segmento = String.isNotBlank(segmento) ? segmento : payload.proposta.segmento;//PLV-4701 - INICIO/FIM
        system.debug('GERAR PROPOSTA!!');
        system.debug('PAYLOAD: ' + JSON.serialize( payload ) );
        
        //PLV-3285 - INICIO - MVP A Transmissão da proposta
        system.debug('payload.codigoEmpresa: ' + payload.proposta.codigoEmpresa);
        this.codigoEmpresa = payload.proposta.codigoEmpresa;
        //PLV-3285 - FIM - MVP A Transmissão da proposta
        
        //INICIO | PLV-2355-SNIPER
        
        // Formata o numero do orcamento
        //String numeroOrcamento = String.valueOf(payloadTO.proposta.numeroOrcamento).leftPad(8,'0');
        //system.debug('numero orcamento '+ numeroOrcamento);
        
        // Busca o orcamento da proposta
        orcamento = daoOrcamento.obterOportunidadesPorNumeroComPrefixo(payloadTO.proposta.numeroOrcamento);
        
        system.debug('Orcamento: ' + orcamento);        	
        
        //FIM | PLV-2355-SNIPER
        
        // valida se o numero do orcamento existe
        if(orcamento != null){
            
            system.debug('Dentro do IF orcamento != null');            
            
            //obtem os tipos de registro do objeto
            for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Quote'))
                mapRecordType.put(tipo.DeveloperName, tipo);
            
            //INICIO | PLV-2610-SNIPER
            //Popula a proposta baseado no orcamento
            System.debug('proposta nao populada: '+ this.proposta.propostaWrapper.sfProposta);
            
            this.popularProposta(orcamento, this.proposta.propostaWrapper.sfProposta, payloadTO);
            system.debug('PropostaGenericaBuilder - AccountId da Proposta: ' + JSON.serialize(this.proposta.propostaWrapper.sfProposta)); //PLV-3285
            //FIM | PLV-2610-SNIPER
            this.proposta.propostaWrapper.retornoWrapper.numeroOrcamento = orcamento.Numero__c;
            
            // insere as contas necessarias 
            List<Proposta.PessoaWrapper> listPessoasWrapper = new List<Proposta.PessoaWrapper>();
            this.gerarContas(payload, listPessoasWrapper);
                       
            system.debug('listPessoasWrapper'+listPessoasWrapper);
            system.debug('payload'+payload);
            List<Account> listContas = new List<Account>();
            
            for(Proposta.PessoaWrapper pessoaWrapper : listPessoasWrapper){	
                // incrementa o map de contas
                mapContas.put(pessoaWrapper.sfConta.IdExterno__c, pessoaWrapper.sfConta);
                system.debug('mapContas: ' + mapContas);
                system.debug('id externo'+pessoaWrapper.sfConta.IdExterno__c);
                listContas.add(pessoaWrapper.sfConta);     
                
            }       
            system.debug('PLV_2826 - Upsert listContas IdExterno__c' + listContas);
            
            try{
                if(listContas.size() > 0){//PLV-4440 - INICIO
                    //PLV_2826 - INICIO - Criar oportunidade sem conta
                    //PLV-3285 - Inicio	
                    List<Account> listContas2 = new List<Account>();
                    system.debug('listContas'+listContas);                
                    listContas2.addAll((List<Account>) Util.getLockListSObject(listContas, 'IdExterno__c'));
                    //PLV-3285 - FIM
                    system.debug('listContas2: ' + JSON.serialize(listContas2));
                                      
                    Upsert listContas2 IdExterno__c;  
                    
                }//PLV-4440 - FIM
                                
                //PLV_2826 - FIM - Criar oportunidade sem conta
            }catch (Exception e){
                throw new PropostaBuilderException('Exception: Inserir contas \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
            }
            
            //PLV_2826 - INICIO - Criar oportunidade sem conta
            //Metodo: atualizaOrcamento - Atualiza a estrutura Segurados/Contratantes/Orcamento quando o orçamento 
            //que originou a proposta estiver sem conta associada 
            
            orcamento = this.atualizaOrcamento(payload, orcamento);
            	
            //PLV_2826 - FIM - Criar oportunidade sem conta
            
            // monta os mapas dos grupos e garantias  a partir do 3° nivel da hierarquia
            this.buscarRegistrosDominios();
            
            // 2666 - INICIO
            // Gera os contratantes
            this.gerarContratantes(orcamento.ContratantesOrcamento__r, this.proposta.propostaWrapper.contratantesWrapper, payload);
            // 2666 - FIM
            System.debug( ' @@@4894:> ' + JSON.serialize(this.mapEndrecosToInsert.values()));
            // upsert this.mapEndrecosToInsert.values() IdExterno__c; // PLV-4900 - INICIO/FIM
            // Gera as garantias da proposta
            this.popularGarantiasWrapper(orcamento.CoberturasOrcamento__r, this.proposta.propostaWrapper.garantiasWrapper, nomeGrupo); //PLV-4340 - INICIO/FIM
            
            // Gera as remuneracoes da proposta
            System.debug( ' @@@3285 orcamentop:> ' + orcamento);
            System.debug( ' @@@3285 orcamento.RemuneracoesOrcamento__r:> ' + orcamento.RemuneracoesOrcamento__r);
            
            //AV-614 - INICIO
            map<String, String> mapRetencaoComissao = new map<String, String>();
            mapRetencaoComissao.put('produto', payload.proposta.codigoProdutoVida);
            mapRetencaoComissao.put('meioComercializacao', payload.proposta.meioComercializacao);
            mapRetencaoComissao.put('susep', payload.proposta.remuneracoes[0].favorecidos[0].susep);
            System.debug( 'mapRetencaoComissao:  ' + mapRetencaoComissao);
            this.gerarRemuneracaoPropostaWrappersComFavorecidos(orcamento.RemuneracoesOrcamento__r, this.proposta.propostaWrapper.RemuneracaoPropostaWrapper, payloadTO.proposta.tipoSeguro, mapRetencaoComissao, remuneracoesPropostaTO); //RVI-49 - INICIO/FIM //II-167 INICIO/FIM
            //AV-614 - FIM
            
            //PLV_3196 - INICIO - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
            //proposta.propostaWrapper.retornoWrapper.codigoRamo = this.proposta.propostaWrapper.sfProposta.RamoSeguro__r.Codigo__c;//PLV-4785-INICIO/FIM
            //proposta.propostaWrapper.retornoWrapper.modalidade = this.proposta.propostaWrapper.sfProposta.modalidade__r.Codigo__c;//PLV-4785-INICIO/FIM
            //PLV_3196 - FIM - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
        }
        else
            throw new PropostaBuilderException('Número de orçamento não ncontrado.');
    }

   // ---- ANNVI-229-Inicio --- //
    public void  validarQuestionario(EmissaoTO.QuestionarioTO questionario) {
   
     // --- Consulta para obter todas as perguntas do questionário obrigatórias e não obrigatórias    
    List<PerguntaQuestionario__c> todasPerguntasList = [
        SELECT Numero__c, Obrigatorio__c
        FROM PerguntaQuestionario__c
        WHERE Questionario__r.Codigo__c = :questionario.idquestionario
        ORDER BY Numero__c
    ];
    // --- Mapear as respostas do questionário para facilitar a verificação
    Map<String, String> respostasMap = new Map<String, String>();
    for (EmissaoTO.RespostaTO resposta : questionario.respostas) {
        respostasMap.put(resposta.questao, resposta.resposta);
    }

    // --- Validar se o número de respostas é maior que o número total de perguntas    
    if (respostasMap.size() > todasPerguntasList.size()) {
         throw new PropostaBuilderException('Erro na validação do questionário');
    }
 
    // --- Lista para armazenar as perguntas obrigatórias que estão sem resposta    
    List<String> perguntasSemResposta = new List<String>();

    // --- Separar e validar as perguntas obrigatórias    
    for (PerguntaQuestionario__c pergunta : todasPerguntasList) {
        if (pergunta.Obrigatorio__c) { // Verifica se a pergunta é obrigatória
            String numeroQuestao = String.valueOf(pergunta.Numero__c);
            // -- Verificar se a resposta existe e não está vazia
            if (!respostasMap.containsKey(numeroQuestao) || String.isBlank(respostasMap.get(numeroQuestao))) {
                perguntasSemResposta.add(numeroQuestao);
            }
        }
    }
      // --- Se houver perguntas obrigatórias sem resposta, lançar exceção
    if (!perguntasSemResposta.isEmpty()) {
        throw new PropostaBuilderException('Erro na validação do questionário');
      }
    }
    // ------- ANNVI-229-Fim ----------//
    
    //PLV-2663 - INICIO -AVX
    public void criarRespostaDeclaracaoSaude(EmissaoTO.PayloadTO payload, Id propostaId)
    {	
        //PLV-4257 - inicio
        system.debug('payload: '+payload);
        //PLV-3285 - INICIO - MVP A Transmissão da proposta
        if (payload.proposta.contratantes[0].grupos[0].segurados[0].questionario == null) return;
     
        // ------- ANNVI-229-Inicio -------//
         EmissaoTO.QuestionarioTO questionario = payload.proposta.contratantes[0].grupos[0].segurados[0].questionario;
         validarQuestionario(questionario);
       
        // --- ANNVI-229-Fim ------//

        //PLV-3285 - FIM - MVP A Transmissão da proposta
        Map<String, DeclaracaoSaude__c> mDeclaracaoSaude = new Map<String,DeclaracaoSaude__c>();
        Map<String, List<RespostaDeclaracaoSaude__c>> mRespDeclaracaoSaude = new Map<String, List<RespostaDeclaracaoSaude__c>>();
        Map<String, Map<String, Id>> mapQuestionarioPerguntas = getMapQuestionarioPerguntas(); //PLV-4790 FIX 1 INICIO/FIM
        
        for(EmissaoTO.ContratanteTO contratante  : payload.proposta.contratantes){
            for(EmissaoTO.GrupoTO grupo : contratante.grupos){
                for(EmissaoTO.SeguradoTO segurado : grupo.segurados){
                    
                    String idExterno = montarChavePessoa(segurado.pessoa);
                    //String getQuestionarioId = payload.proposta.contratantes[0].grupos[0].segurados[0].questionario.IdQuestionario; //PLV-4257-FIX-2-VI inicio/fim
                    String getQuestionarioId = payload.proposta.contratantes[0].grupos[0].segurados[0].questionario.idquestionario; //RVI-138 INICIO-FIM FIX01
                    Map<String, Id> mapNumeroPergunta; //PLV-4790 FIX 1 INICIO/FIM

                    DeclaracaoSaude__c dSaude = new DeclaracaoSaude__c(
                        
                        //Conta que tras o ID conta via id externo
                        Conta__r = new Account(IdExterno__c = idExterno),				 
                        Proposta__c = propostaId,
                        //QuestionarioRisco__c = getQuestionarioId, //PLV-4257-FIX-2-VI inicio/fim //PLV-4790 INICIO/FIM
                        DataResposta__c = System.today()
                    );
                    //PLV-4790 INICIO
                    if (!String.isBlank(getQuestionarioId)) {
                        dSaude.QuestionarioRisco__r = new Questionario__c(Codigo__c = getQuestionarioId);
                        //PLV-4790 FIX 1 INICIO
                        if (mapQuestionarioPerguntas.containsKey(getQuestionarioId)) {
                            mapNumeroPergunta = mapQuestionarioPerguntas.get(getQuestionarioId);
                        }
                        //PLV-4790 FIX 1 FIM
                    }
                    //PLV-4790 FIM

                    mDeclaracaoSaude.put(idExterno, dSaude);
                    
                    //percorrer questionario 
                    for(EmissaoTO.RespostaTO resposta : segurado.questionario.respostas ){
                        
                        List<RespostaDeclaracaoSaude__c> lRespostaDeclaracao;
                        
                        if (mRespDeclaracaoSaude.containsKey(idExterno))
                            lRespostaDeclaracao = mRespDeclaracaoSaude.get(idExterno);
                        else lRespostaDeclaracao = new List<RespostaDeclaracaoSaude__c>();
                        //PLV-4440 - INICIO
                        try { // se nao vier um Id como reposta.resposta  vai abortar                         
                            RespostaDeclaracaoSaude__c respostaDeclaracao = new RespostaDeclaracaoSaude__c();
                            //PLV-4790 FIX 1 INICIO
                            if (mapNumeroPergunta != null && mapNumeroPergunta.containsKey(resposta.questao)) {
                                respostaDeclaracao.PerguntaQuestionarioRisco__c = mapNumeroPergunta.get(resposta.questao);
                                respostaDeclaracao.Resposta__c = resposta.resposta;
                                
                                lRespostaDeclaracao.add(respostaDeclaracao);
                                mRespDeclaracaoSaude.put(idExterno, lRespostaDeclaracao);
                            }
                            //PLV-4790 FIX 1 FIM
                        } catch ( Exception e ) {
                            System.debug('Erro preenchendo reposta da declaracao de saude Id externo='+idExterno+ ' '+
                                         e.getMessage() + e.getStackTraceString());
                            // Throw e;
                        }
                        //PLV-4440 - FIM
                    }
                }
            }
        }
        //PLV-4257 - fim
        
        insert mDeclaracaoSaude.values(); //PLV4398
        List<RespostaDeclaracaoSaude__c> lRespostaDeclaracaoInsert = new List<RespostaDeclaracaoSaude__c>();
        
        system.debug('mRespDeclaracaoSaude: '+mRespDeclaracaoSaude);
        for (String idExterno : mRespDeclaracaoSaude.keyset()){
            List<RespostaDeclaracaoSaude__c> lRespostaDeclaracao = mRespDeclaracaoSaude.get(idExterno);
            
            for (RespostaDeclaracaoSaude__c respostaDeclaracao : lRespostaDeclaracao)
                respostaDeclaracao.DeclaraoSaude__c = mDeclaracaoSaude.get(idExterno).Id;
            	//respostaDeclaracao.Pergunta__c =
            
            lRespostaDeclaracaoInsert.addAll(lRespostaDeclaracao);
        }
        system.debug('lRespostaDeclaracaoInsert: '+lRespostaDeclaracaoInsert);
        
        insert lRespostaDeclaracaoInsert;
    }
    //PLV-2663 - FIM -AVX

    //PLV-4790 FIX 1 INICIO
    private Map<String, Map<String, Id>> getMapQuestionarioPerguntas() {
        Map<String, Map<String, Id>> result = new Map<String, Map<String, Id>>();

        List<Questionario__c> questionarios = [
            SELECT Id
                ,Codigo__c
                ,(
                    SELECT ID
                        ,Numero__c
                    FROM PerguntasQuestionario__r
                )
                FROM Questionario__c
                ORDER BY CREATEDDATE DESC LIMIT 2000
        ];

        for (Questionario__c questionario : questionarios) {
            Map<String, Id> mapPerguntas = new Map<String, Id>();

            for (PerguntaQuestionario__c pergunta : questionario.PerguntasQuestionario__r) {
                if (pergunta.Numero__c != null && !mapPerguntas.containsKey(String.valueOf(pergunta.Numero__c))) {
                    mapPerguntas.put(String.valueOf(pergunta.Numero__c), pergunta.Id);
                }
            }

            if (!result.containsKey(questionario.Codigo__c)) {
                result.put(questionario.Codigo__c, mapPerguntas);
            }
        }

        System.debug('getMapQuestionarioPerguntas => ' + result);

        return result;
    }
    //PLV-4790 FIX 1 FIM

    /*
* @author Everymind - Sprint 29 - (hackathon)
* @Descrição: monta o retorno do processamento de proposta
*/
    public RetornoPropostaRestTO.ValidacaopropostaTO converterPropostaParaRetornoProposta(Proposta proposta)
    {
        String numeroProposta; //TKCL-246 INICIO-FIM
        system.debug('ACESSOU CONVERTER');
        system.debug('Proposta proposta: ' + proposta);
        if(proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.isEmpty())
        {
            system.debug('ACESSOU o IF 1');
            if(proposta.propostaWrapper.sfProposta.Id != null)
            {
                system.debug('ACESSOU o IF 2');
                RetornoPropostaRestTO.DevolutivasTO devolutivaTO = new RetornoPropostaRestTO.DevolutivasTO();
                devolutivaTO.tipoRegistro = 1;
                devolutivaTO.origem = 'INT';
                devolutivaTO.numeroCampo = 0;
                devolutivaTO.descricao = 'EMISSÃO: - registro inserido/atualizado com sucesso.';
                devolutivaTO.codigo = 0;
                
                system.debug('DEVOLUTIVA TO: ' + devolutivaTO);
                
                
                proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.add(devolutivaTO);
                
                system.debug('Apos devolutiva: ' + proposta.propostaWrapper.retornoWrapper.retorno.devolutivas[0]);
            }
        }
        //PLV-2675 - Inicio - Validação criada pois alguns campos podem estar nulos por conta das diversas entradas
        try
        {
            system.debug('ENTROU no TRY');
            system.debug('proposta.propostaWrapper.retornoWrapper: ' + proposta.propostaWrapper.retornoWrapper);
            system.debug('proposta.propostaWrapper.retornoWrapper.codigoRamo: ' + proposta.propostaWrapper.retornoWrapper.codigoRamo);
            system.debug('proposta.propostaWrapper.retornoWrapper.modalidade: ' + proposta.propostaWrapper.retornoWrapper.modalidade);
            
            
            proposta.propostaWrapper.retornoWrapper.retorno.proposta = new RetornoPropostaRestTO.PropostaTO();
            if(proposta.propostaWrapper.retornoWrapper.numeroApolice != null)
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.apolice = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.numeroApolice);
            
            if(proposta.propostaWrapper.retornoWrapper.codigoEmpresa != null)				
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.empresa = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoEmpresa);
            
            if(proposta.propostaWrapper.retornoWrapper.codigoSucursal != null)
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.sucursal = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoSucursal);
            
            if(proposta.propostaWrapper.retornoWrapper.codigoRamo != null)
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.ramoSeguro = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoRamo);
            
            //PLV_3196 - INICIO - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
            if(proposta.propostaWrapper.retornoWrapper.modalidade != null)
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.modalidade = proposta.propostaWrapper.retornoWrapper.modalidade;
            //PLV_3196 - FIM - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
            
            if(proposta.propostaWrapper.retornoWrapper.numeroOrcamento != null)
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.numeroOrcamento = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.numeroOrcamento);
            
            if(proposta.propostaWrapper.sfProposta.NumeroProposta__c != null)
                //TKCL-246 INICIO
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.numero = proposta.propostaWrapper.sfProposta.NumeroProposta__c; //TKCL-246 INICIO-FIM
                //TKCL-246 FIM
            
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            //proposta.propostaWrapper.retornoWrapper.retorno.proposta.origem = Integer.valueOf(proposta.propostaWrapper.sfProposta.Origem__c);
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.origem = Integer.valueOf(origemProposta[0].valor__c);
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.status = proposta.propostaWrapper.sfProposta.Status;
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.meioComercializacao = proposta.propostaWrapper.sfProposta.MeioComercializacao__c;
            
            if(proposta.propostaWrapper.sfProposta.CanalDistribuicao__c != null){
                
                String idCanalDistribuicao = proposta.propostaWrapper.sfProposta.CanalDistribuicao__c;
                
                CanalDistribuicao__c canalDistribuicao = [SELECT sigla__c 
                                                          FROM CanalDistribuicao__c 
                                                          WHERE id = : idCanalDistribuicao
                                                          LIMIT 1];
                
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.canalDistribuicao = canalDistribuicao.Sigla__c;				
            }
            // VIAG-141 INICIO
         
            String idPropostaPrincipal = proposta.propostaWrapper.sfProposta.Id;
            List<Quote> DataLimite = new List<Quote>();
             DataLimite =  [SELECT DataLimitePagamento__c 
                                    FROM Quote
                                    WHERE id = : idPropostaPrincipal 
                                    LIMIT 1];
                                    Datetime validade;

                validade = Datetime.valueOf(DataLimite[0].DataLimitePagamento__c);
                Datetime newDate;
                newDate  = validade.addHours(3);

              proposta.propostaWrapper.retornoWrapper.retorno.proposta.validadePagamento = String.valueOf(newDate);			
              System.Debug(' proposta.propostaWrapper.retornoWrapper.retorno.proposta.validadePagamento >>>>'+ proposta.propostaWrapper.retornoWrapper.retorno.proposta.validadePagamento); 
            
            // VIAG-141 FIM



            proposta.propostaWrapper.retornoWrapper.retorno.proposta.codigoEmpresa = this.codigoEmpresa;
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.dataCalculo = String.valueOf(proposta.propostaWrapper.sfProposta.DataCalculo__c);
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.tipoSeguro = mapConversaoTipoSeguro.get(proposta.propostaWrapper.sfProposta.Tipo__c);
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.vigenciaInicial = String.valueOf(proposta.propostaWrapper.sfProposta.VigenciaInicial__c);
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.vigenciaFinal = String.valueOf(proposta.propostaWrapper.sfProposta.VigenciaFinal__c);
            //proposta.propostaWrapper.retornoWrapper.retorno.proposta.tipoAdesao = proposta.propostaWrapper.sfProposta.Tipo__c == 'Novo' ?'APL' : 'INA';
            
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.contratantes = new List<RetornoPropostaRestTO.contratanteTO>();
            
            for(Proposta.ContratanteWrapper contratantesSfProposta : proposta.propostaWrapper.contratantesWrapper){					
                
                //RetornoPropostaRestTO.contratanteTO contratante = new RetornoPropostaRestTO.contratanteTO();					
                system.debug('contratantesSfProposta.sfContratante.Numero__c: ' + contratantesSfProposta.sfContratante.Numero__c);
                system.debug('contratantesSfProposta.sfContratante.id:' + contratantesSfProposta.sfContratante.id);
                system.debug('contratantesSfProposta.sfContratante.FormaPagamento__c:' + contratantesSfProposta.sfContratante.FormaPagamento__c);
                system.debug('contratantesSfProposta.sfContratante.FormaPagamento__r:' + contratantesSfProposta.sfContratante.FormaPagamento__r);
                system.debug('contratantesSfProposta.sfContratante.FormaPagamento__r.Codigo__c:' + contratantesSfProposta.sfContratante.FormaPagamento__r.Codigo__c);
                
                Integer numeroContrante = 1;
                //if(contratantesSfProposta.sfContratante.Numero__c != null ) contratante.numero = String.ValueOf(contratantesSfProposta.sfContratante.Numero__c);
                contratante.numero = String.ValueOf(numeroContrante);
                contratante.dadosPagamento = this.dadosPagamento; //TKCL-441 INCIO/FIM FIX01
                contratante.dadosPagamento.quantidadeParcelas = Integer.ValueOf(contratantesSfProposta.sfContratante.QuantidadeParcelas__c);
                system.debug('Antes de atribuir o codigoFormaPagamento: ' + codigoFormaPagamento);
                contratante.dadosPagamento.codigoFormaPagamento = this.codigoFormaPagamento;
                contratante.dadosPagamento.premioTotal = String.ValueOf(contratantesSfProposta.sfContratante.PremioTotal__c);
                // TKCL 473 - INICIO
                contratante.dadosPagamento.recorrencia = contratantesSfProposta.sfContratante.Recorrencia__c;
                contratante.dadosPagamento.valorPrimeiraParcela = String.valueOf(contratantesSfProposta.sfContratante.Valor_PrimeiraParcela__c);
                contratante.dadosPagamento.valorDemaisParcelas = String.valueOf(contratantesSfProposta.sfContratante.Valor_DemaisParcelas__c);
                 // TKCL 473 - FIM
                //PLV-3285 - Os valores abaixo serão mocados pois a logica para calculo será criada em uma nova história 
                //PLV-3455 - INICIO - Preencher os valores de parcelas
                //TCKL 441 - INICIO
                /*contratante.dadosPagamento.valorPrimeiraParcela = mapParcelamentos.containsKey(contratante.dadosPagamento.codigoFormaPagamento) && mapParcelamentos.get(contratante.dadosPagamento.codigoFormaPagamento).containsKey(contratante.dadosPagamento.quantidadeParcelas) ?
                 mapParcelamentos.get(contratante.dadosPagamento.codigoFormaPagamento).get(contratante.dadosPagamento.quantidadeParcelas).valorPrimeiraParcela : null;
                contratante.dadosPagamento.valorDemaisParcelas = mapParcelamentos.containsKey(contratante.dadosPagamento.codigoFormaPagamento) && mapParcelamentos.get(contratante.dadosPagamento.codigoFormaPagamento).containsKey(contratante.dadosPagamento.quantidadeParcelas) ?
                 mapParcelamentos.get(contratante.dadosPagamento.codigoFormaPagamento).get(contratante.dadosPagamento.quantidadeParcelas).valorDemaisParcelas : null;*/
                 //TCKL 441 - FIM
                 //PLV-3455 - FIM
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.contratantes.add(contratante);
                numeroContrante ++;                
            }

	    //PLV-4790 FIX 8 INICIO
            if(proposta.propostaWrapper.contratantesWrapper.size() >0){
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.limiteProfissao = getLimiteCapitalProfissao(proposta.propostaWrapper.contratantesWrapper[0].sfContratante.Conta__c);		 			 
            }else{
                proposta.propostaWrapper.retornoWrapper.retorno.proposta.limiteProfissao = 0 ;
            }
	    //PLV-4790 FIX 8 FIM
            
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            System.debug(' @@@@@ proposta.propostaWrapper.sfProposta :> ' + proposta.propostaWrapper.sfProposta);
            proposta.propostaWrapper.retornoWrapper.retorno.proposta.qtdDiasVigencia = proposta.propostaWrapper.sfProposta.VigenciaInicial__c.daysBetween(proposta.propostaWrapper.sfProposta.VigenciaFinal__c);
            system.debug('PropostaTO depois: ' + proposta.propostaWrapper.retornoWrapper.retorno.proposta);
            
        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao gerar retorno da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        System.debug('!@!@!@ proposta.propostaWrapper.retornoWrapper:> ' + proposta.propostaWrapper.retornoWrapper);
        return proposta.propostaWrapper.retornoWrapper.retorno;
    }
    //PLV-2675 - Fim
    
    //PLV-4790 FIX 5 INICIO
    private Decimal getLimiteCapitalProfissao(Id accountId) {
        Decimal result = 0;

        List<Account> contas = [
            SELECT Id
                ,Profissao__r.Limite_de_Capital_Maximo__c
            FROM Account
            WHERE Id =: accountId
            AND Profissao__r.Limite_de_Capital_Maximo__c <> NULL
            LIMIT 1
        ];

        if (contas != null && contas.size() > 0) {
            result = contas.get(0).Profissao__r.Limite_de_Capital_Maximo__c;
        }

        return result;
    }
    //PLV-4790 FIX 5 FIM

    //PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
    public RetornoPropostaRestTO.ValidacaopropostaTO converterListaPropostasParaRetorno(List<Proposta> listaPropostas)
    {
        system.debug('ACESSOU converterListaPropostasParaRetorno');
        Set<String> setIdCanalDistribuicao = new Set<String>();
        
        Proposta propostaWP = new proposta();
        propostaWP.propostaWrapper = new Proposta.PropostaWrapper();
        propostaWP.propostaWrapper.retornoWrapper.retorno.resultados = new List<RetornoPropostaRestTO>();
        
        
        for(Proposta proposta : listaPropostas){
            if(proposta.propostaWrapper.sfProposta.CanalDistribuicao__c == null) continue; 
            
            setIdCanalDistribuicao.add(proposta.propostaWrapper.sfProposta.CanalDistribuicao__c);
        }	
        
        Map<String,CanalDistribuicao__c> mapCanalDistribuicao = new Map<String, CanalDistribuicao__c>(
            [SELECT id, sigla__c 
             FROM CanalDistribuicao__c 
             WHERE id IN :setIdCanalDistribuicao]);		

    // MGRC-624 INICIO
        String  identificador ='';     
        String  redirecionaURL = '';   
        String   nomeVoucher ='';    
        String baseURL = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = 'SFECM' LIMIT 1].Endpoint;
        baseURL += [SELECT NomeCredencial__c,NomeToken__c,Endpoint__c,DeveloperName FROM Servico__mdt WHERE DeveloperName='Consultar_ArquivoSF' LIMIT 1].Endpoint__c;
      // MGRC-624 FIM
        for(Proposta proposta :  listaPropostas){
            system.debug('Proposta: ' + proposta);
            
            RetornoPropostaRestTO resultadoProposta = new RetornoPropostaRestTO();
            resultadoProposta.proposta = new RetornoPropostaRestTO.PropostaTO();
            resultadoProposta.proposta.arquivos = new List<RetornoPropostaRestTO.ArquivoTO>();
            
            //if(!proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.isEmpty()) continue;
            
            if(proposta.propostaWrapper.sfProposta.Id != null)
            {
                system.debug('ACESSOU o IF sfProposta.Id');
                RetornoPropostaRestTO.DevolutivasTO devolutivaTO = new RetornoPropostaRestTO.DevolutivasTO();
                devolutivaTO.tipoRegistro = 1;
                devolutivaTO.origem = 'INT';
                devolutivaTO.numeroCampo = 0;
                devolutivaTO.descricao = 'EMISSÃO: - registro inserido/atualizado com sucesso.';
                devolutivaTO.codigo = 0;
                
                system.debug('DEVOLUTIVA TO: ' + devolutivaTO);
                
                resultadoProposta.devolutivas = new List<RetornoPropostaRestTO.DevolutivasTO>(); 
                resultadoProposta.devolutivas.add(devolutivaTO);
                
                system.debug('Apos devolutiva: ' + resultadoProposta.devolutivas[0]);
            }	
            
            if(proposta.propostaWrapper.retornoWrapper.numeroApolice != null)
                resultadoProposta.proposta.apolice = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.numeroApolice);
            
            if(proposta.propostaWrapper.retornoWrapper.codigoEmpresa != null)				
                resultadoProposta.proposta.empresa = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoEmpresa);
            
            if(proposta.propostaWrapper.retornoWrapper.codigoSucursal != null)
                resultadoProposta.proposta.sucursal = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoSucursal);
            
            if(proposta.propostaWrapper.retornoWrapper.codigoRamo != null)
                resultadoProposta.proposta.ramoSeguro = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.codigoRamo);
            
            if(proposta.propostaWrapper.retornoWrapper.modalidade != null)
                resultadoProposta.proposta.modalidade = proposta.propostaWrapper.retornoWrapper.modalidade;
            
            if(proposta.propostaWrapper.retornoWrapper.numeroOrcamento != null)
                resultadoProposta.proposta.numeroOrcamento = Integer.valueOf(proposta.propostaWrapper.retornoWrapper.numeroOrcamento);
            
            if(proposta.propostaWrapper.sfProposta.NumeroProposta__c != null)
                resultadoProposta.proposta.numero = proposta.propostaWrapper.sfProposta.NumeroProposta__c; //TKCL-246 INICIO-FIM
            
            if(proposta.propostaWrapper.retornoWrapper.indice != null)
                resultadoProposta.proposta.indice = proposta.propostaWrapper.retornoWrapper.indice;
            
            resultadoProposta.proposta.origem = Integer.valueOf(this.origemProposta[0].valor__c);
            resultadoProposta.proposta.status = proposta.propostaWrapper.sfProposta.Status;
            resultadoProposta.proposta.meioComercializacao = proposta.propostaWrapper.sfProposta.MeioComercializacao__c;
            
            if(mapCanalDistribuicao.containsKey(proposta.propostaWrapper.sfProposta.CanalDistribuicao__c))
                resultadoProposta.proposta.canalDistribuicao = mapCanalDistribuicao.get(proposta.propostaWrapper.sfProposta.CanalDistribuicao__c).Sigla__c;				
            
            // VIAG-141 INICIO
           
            if(proposta.propostaWrapper.retornoWrapper.validadePagamento != null) {
            resultadoProposta.proposta.validadePagamento = proposta.propostaWrapper.retornoWrapper.validadePagamento;    
            System.debug('resultadoProposta.proposta.validadePagamento>>>'+ resultadoProposta.proposta.validadePagamento);
            }
           
            // VIAG-141 FIM
            
            resultadoProposta.proposta.codigoEmpresa = this.codigoEmpresa;
            resultadoProposta.proposta.dataCalculo = String.valueOf(proposta.propostaWrapper.sfProposta.DataCalculo__c);
            resultadoProposta.proposta.tipoSeguro = mapConversaoTipoSeguro.get(proposta.propostaWrapper.sfProposta.Tipo__c);
            resultadoProposta.proposta.vigenciaInicial = String.valueOf(proposta.propostaWrapper.sfProposta.VigenciaInicial__c);
            resultadoProposta.proposta.vigenciaFinal = String.valueOf(proposta.propostaWrapper.sfProposta.VigenciaFinal__c);
            resultadoProposta.proposta.qtdDiasVigencia = proposta.propostaWrapper.sfProposta.VigenciaInicial__c.daysBetween(proposta.propostaWrapper.sfProposta.VigenciaFinal__c);
            system.debug('PropostaTO depois: ' + resultadoProposta.proposta);	
           // MGRC-624 INICIO
            nomeVoucher = 'Voucher_'+proposta.propostaWrapper.sfProposta.Origem__c+'_'+proposta.propostaWrapper.sfProposta.NumeroProposta__c+'.pdf';
            identificador  = baseURL+Util.encryptDocPublicURL(proposta.propostaWrapper.sfProposta.Id, nomeVoucher);
            if((proposta.propostaWrapper.sfProposta.Segmento__c =='Viagem')&&(identificador !='')){
              // System.debug('LinkVoucher1:' +  proposta.propostaWrapper.sfProposta.voucherPdfDownloadUrl__c);
              //  system.debug('LinkVoucher1:' + proposta.propostaWrapper.retornoWrapper.LinkVoucher);
                 identificador = (identificador).subStringAfter('doGet/');
              
                 RetornoPropostaRestTO.ArquivoTO arquivo = new RetornoPropostaRestTO.ArquivoTO();
                arquivo.nome = 'Voucher';
                arquivo.link =  System.Label.hostSensediaAWS + '/vida/crm/acessorios/v1/documentos/' + identificador;
                
                resultadoProposta.proposta.arquivos.add(arquivo);
            }else
                resultadoProposta.proposta.arquivos = null;
            
            propostaWP.propostaWrapper.retornoWrapper.retorno.resultados.add(resultadoProposta);
            propostaWP.propostaWrapper.retornoWrapper.retorno.devolutivas = null;
        }
        // MGRC-624 FIM
        System.debug('!@!@!@ proposta.propostaWrapper.retornoWrapper:> ' + propostaWP.propostaWrapper.retornoWrapper);
        return propostaWP.propostaWrapper.retornoWrapper.retorno;
    }
    //PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
    
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: cria os contratantes da proposta
*/
    // 2666 - INICIO
    public void gerarContratantes(List<ContratanteOrcamento__c> contratantes, List<Proposta.ContratanteWrapper> listContratanteWrapper, EmissaoTO.PayloadTO payload)
    {
        System.debug('IF payload gerarContratantes '+ JSON.serialize(payload));
        System.debug('CONTRATANTES: '+ contratantes);
        Map<String, EmissaoTO.ContratanteTO> mContratanteIdExterno = new Map<String, EmissaoTO.ContratanteTO>();
        //PLV-3285 - INICIO - MVP A Transmissão da proposta
        List<EmissaoTO.GrupoTO> gruposPayloadProposta = new List<EmissaoTO.GrupoTO>();
        EmissaoTO.GrupoTO grupoPayloadProposta;
        Integer opcaoPagamentoProposta;
        // Boolean contemViagem = false; //PLV-4340 - INICIO/FIM
        // if(payload.proposta.viagem != null) contemViagem = true; //PLV-4340 - INICIO/FIM
        // system.debug('Flag contemViagem: ' + contemViagem); //PLV-4340 - INICIO/FIM
        //PLV-3285 - FIM - MVP A Transmissão da proposta
        //PLV-2728 - Inicio
        Map<String, List<EmissaoTO.EnderecoTO>> mEnderecos = new Map<String, List<EmissaoTO.EnderecoTO>>();
        //PLV-4813 INICIO
        List<EmissaoTO.ContratanteTO> contratantesProposta = payload.proposta.contratantes;

        if('Viagem'.equalsIgnoreCase(payload.proposta.segmento) && 'eds'.equalsIgnoreCase(payload.proposta.tipoSeguro)) {
            contratantesProposta = payload.proposta.contratoOriginal.contratantes;
            //PLV-4588 FIX 1 - INÍCIO
            if(contratantesProposta.size() > 0 ){
                contratantesProposta[0].dadosPagamento = payload.proposta.contratantes[0].dadosPagamento;
            }
            //PLV-4588 FIX 1 - FIM
        }
        for(EmissaoTO.ContratanteTO contratanteProposta  : contratantesProposta){
        //PLV-4813 FIM
	    //PLV-4488 INICIO
            if(payload.proposta.contratantes[0].dadosPagamento.premioTotal < 0){
                contratanteProposta.dadosPagamento = payload.proposta.contratantes[0].dadosPagamento;
            }
            //PLV-4488 FIM
            system.debug('PLV_2826 metodo gerarContratantes -> contratante.pessoa: ' + contratanteProposta.pessoa);
            system.debug('PLV_2826 metodo gerarContratantes -> contratante.pessoa.dadosPessoaFisica.numeroCpf: ' + contratanteProposta.pessoa.dadosPessoaFisica.numeroCpf);
            
            String idExterno = montarChavePessoa(contratanteProposta.pessoa);
            
            system.debug('PLV_2826 metodo gerarContratantes -> idExterno: ' + idExterno);
            
            mContratanteIdExterno.put(idExterno, contratanteProposta);
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            if(contratanteProposta.pessoa.enderecos != null && contratanteProposta.pessoa.enderecos.size() > 0)
                mEnderecos.put(idExterno, contratanteProposta.pessoa.enderecos);
            
            if(this.contemViagem == true){ //PLV-4340 - INICIO/FIM
                grupoPayloadProposta = contratanteProposta.grupos[0];
                
                // this.Contem2Grupos = (this.payloadOrcamentoPrecificacao.retornosCalculo[0].precificacao.contratantes[0].grupos.size() > 1) ? true : false; //PLV-4340 - INICIO/FIM
                
                // system.debug('gerarContratantes - Grupo Size' + (this.payloadOrcamentoPrecificacao.retornosCalculo[0].precificacao.contratantes[0].grupos.size()));
                // system.debug('gerarContratantes - Grupo[0]' + (this.payloadOrcamentoPrecificacao.retornosCalculo[0].precificacao.contratantes[0].grupos[0]));
                // system.debug('gerarContratantes - Contem2Grupos: ' + Contem2Grupos);
                
                //this.Contem2Grupos = (contratanteProposta.grupos.size() > 1) ? true : false; //PLV-4340 - INICIO/FIM
                
                // for(EmissaoTO.GrupoTO grupoPayloadProposta : contratanteProposta.grupos){
                // 	gruposPayloadProposta.add(grupoPayloadProposta);
                // }
            }
            opcaoPagamentoProposta = contratanteProposta.dadosPagamento.opcao;
            system.debug(opcaoPagamentoProposta);
            
            //PLV-3285 - FIM - MVP A Transmissão da proposta
        }
        
        if(mEnderecos != null || mEnderecos.size() > 0){
            List<Account> lContasEnderecos = [SELECT id, IdExterno__c FROM Account WHERE IdExterno__c IN :mEnderecos.keySet()];
            
            //List<Endereco__c> lEndereco2Insert = new List<Endereco__c>();//PLV-4894 - INICIO/FIM
            
            for (Account conta : lContasEnderecos) {
                if(mEnderecos.containsKey(conta.IdExterno__c)){
                    List<EmissaoTO.EnderecoTO> lEnderecos = mEnderecos.get(conta.IdExterno__c);
                    
                    for (EmissaoTO.EnderecoTO endereco : lEnderecos) {
                        // PLV-4816-COMPLEMENTO - INICIO
                        if(endereco.cep != null && endereco.cep != ''){
                            System.debug('endereco1> : ' + endereco);
                            Endereco__c endereco2Insert = new Endereco__c();
                            endereco2Insert.Conta__c = conta.Id;
                            //VIAG-205 INÍCIO
                            String enderecoCep = (endereco.cep + endereco.complementoCep) != null ? (endereco.cep + endereco.complementoCep) : '';
                            if(enderecoCep != ''){
                                endereco2Insert.CEP__c = enderecoCep.replaceAll('\\.', '');
                            }
                            //VIAG-205 FIM
                            endereco2Insert.Logradouro__c = endereco.logradouro;
                            endereco2Insert.TipoEndereco__c = endereco.tipoEndereco;
                            endereco2Insert.TipoLogradouro__c = endereco.tipoLogradouro;
                            endereco2Insert.Numero__c = endereco.numeroLogradouro;
                            endereco2Insert.Complemento__c = endereco.complemento;
                            endereco2Insert.Bairro__c = endereco.bairro;
                            endereco2Insert.Cidade__c = endereco.cidade;
                            endereco2Insert.Estado__c = endereco.uf;
                            endereco2Insert.Pais__c = endereco.paisResidencia;
                            endereco2Insert.MaisAtual__c = true;
                            endereco2Insert.IdExterno__c = endereco2BO.montarIdExterno(endereco2Insert);
                            this.mapEndrecosToInsert.put(endereco2Insert.IdExterno__c,endereco2Insert);//PLV-4894 - INICIO/FIM
                        }
                        // PLV-4816-COMPLEMENTO - FIM
                    }
                }
            }
            // PLV-4900 - INICIO
            if(!mapEndrecosToInsert.values().isEmpty())
            upsert this.mapEndrecosToInsert.values() IdExterno__c;
            // PLV-4900 - FIM
            //if(lEndereco2Insert.size() > 0) upsert lEndereco2Insert IdExterno__c;//PLV-4894 - INICIO/FIM
        }
        
        //PLV-2728 - Fim
        // Gera os contrantantes, enderecos, dados de pagamentos, garantias e seus grupos
        for (ContratanteOrcamento__c contratante : contratantes)
        {
            // Instancias
            Proposta.ContratanteWrapper contratanteWrapper = new Proposta.ContratanteWrapper();
            contratanteWrapper.sfContratante  = new ContratanteProposta__c();
            contratanteWrapper.sfInformacaoBancaria = new InformacaoBancaria__c();
            contratanteWrapper.sfCartaoCredito = new CartaoCredito__c();
            EmissaoTO.PessoaTO responsavelFinanceiro = new EmissaoTO.PessoaTO(); //PLV-4911 - INICIO / FIM - PEDRO AUGUSTO BRAZ
            Boolean responsavelFinanceiroBoolean = false; //PLV-5067
            // Gera o contratante da proposta
            System.debug('PLV_2826 - Chamada do Método popularContratante');
            system.debug('PLV_2826 - contratante: ' + contratante);
            system.debug('PLV_2826 - contratante.Conta__r -> ' + contratante.Conta__r);
            system.debug('PLV_2826 - mContratanteIdExterno.get(contratante.Conta__r.IdExterno__c)' + mContratanteIdExterno.get(contratante.Conta__r.IdExterno__c)); 
            //PLV-4563 - Vinícius Caetano Globant - INICIO
            //PLV-5067 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            responsavelFinanceiro = payload.proposta.contratantes[0].grupos[0].segurados[0].responsavelFinanceiroSeguro;
            responsavelFinanceiroBoolean = payload.proposta.contratantes[0].grupos[0].segurados[0].responsavelFinanceiro;
            if(responsavelFinanceiro == null){
                //PLV-5175 - INICIO
                if(payload.proposta.contratantes[0].dadosPagamento.responsavelFinanceiroSeguro != null){
                	responsavelFinanceiro = payload.proposta.contratantes[0].dadosPagamento.responsavelFinanceiroSeguro;
                	responsavelFinanceiroBoolean = payload.proposta.contratantes[0].dadosPagamento.responsavelFinanceiro;
                }else{
                    responsavelFinanceiroBoolean = true;
                } 
                //PLV-5175 - FIM
            }
            //PLV-5067 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            //PLV-4563 - Vinícius Caetano Globant - FIM
            System.debug('contratanteWrapper> ' + JSON.serialize(contratanteWrapper));
            this.popularContratante(contratante, contratanteWrapper.sfContratante, mContratanteIdExterno.get(contratante.Conta__r.IdExterno__c), contratanteWrapper.sfInformacaoBancaria, contratanteWrapper.sfCartaoCredito, contemViagem, responsavelFinanceiro,responsavelFinanceiroBoolean, payload.proposta.tipoSeguro); //PLV-5067 - INICIO/FIM //PLV-4340 - INICIO/FIM - //PLV-3285 - MVP A Transmissão da proposta //PLV-4563 - Vinícius Caetano Globant -INICIO/FIM // RVI-193 - INICIO/FIM
            
            // gera as garantias do contratante da proposta
            contratanteWrapper.garantiasWrapper = new List<Proposta.GarantiaWrapper>();
            this.popularGarantiasContratanteWrapper(mapGarantiaContratanteOrcamento.get(contratante.Id), contratanteWrapper.garantiasWrapper);
            
            // gera os grupos deste contratante
            contratanteWrapper.gruposWrapper = new List<Proposta.GrupoWrapper>();
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            this.gerarGrupos(mapGruposOrcamento.get(contratante.Id), contratanteWrapper.gruposWrapper, grupoPayloadProposta, contemViagem, opcaoPagamentoProposta);
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            
            listContratanteWrapper.add(contratanteWrapper);
        }
    }
    // 2666 - FIM
    
    //PLV-4340 - INICIO
    public String retornarNomeGrupoPassageiro(EmissaoTO.GrupoTO grupoPayloadProposta){
        String dataNascimentoSegurado;
        String nomeDoGrupo = '';
        Integer idadeSegurado;
        
        dataNascimentoSegurado = grupoPayloadProposta.segurados[0].pessoa.dadosPessoaFisica.dataNascimento;
        idadeSegurado = ValidaRegrasGarantiaSniper.converterDataComtracosParaIdade(dataNascimentoSegurado);
        
        system.debug('idadeSegurado: ' + idadeSegurado);
        
        Map<String, ParametrosConstante__c> mapParametros = new Map<String, ParametrosConstante__c>();
        List<ParametrosConstante__c> listaParametros = new List<ParametrosConstante__c>(
            [SELECT name, valor__c
             FROM ParametrosConstante__c 
             WHERE name in ('GRUPO_JOVENS_NOME', 'GRUPO_JOVENS_IDADE_MIN', 'GRUPO_JOVENS_IDADE_MAX', 'GRUPO_IDOSOS_NOME')]);
        
        if(!listaParametros.IsEmpty()){
            for(ParametrosConstante__c parametro : listaParametros){
                mapParametros.put(parametro.name, parametro);
            }
        }	
        
        system.debug('mapParametros: ' + mapParametros);
        
        if(mapParametros.isEmpty()) return '';
        
        system.debug('mapParametros.get(GRUPO_JOVENS_IDADE_MAX).valor__c: ' + mapParametros.get('GRUPO_JOVENS_IDADE_MAX').valor__c);
        system.debug('Integer.Valueof - mapParametros.get(GRUPO_JOVENS_IDADE_MAX).valor__c: ' + Integer.Valueof(mapParametros.get('GRUPO_JOVENS_IDADE_MAX').valor__c));
        
        //PLV-5252 INICIO
        if(idadeSegurado <= Integer.Valueof(mapParametros.get('GRUPO_JOVENS_IDADE_MAX').valor__c)){
            if(idadeSegurado >= Integer.Valueof(mapParametros.get('GRUPO_JOVENS_IDADE_MIN').valor__c)){
                nomeDoGrupo = mapParametros.get('GRUPO_JOVENS_NOME').valor__c;
            }
        }else{
            nomeDoGrupo = mapParametros.get('GRUPO_IDOSOS_NOME').valor__c;
        }
        //PLV-5252 FIM
        
        system.debug('retornarNomeGrupoProposta - nomeDoGrupo: ' + nomeDoGrupo);
        
        return nomeDoGrupo;
    }
    //PLV-4340 - FIM
    
    /*
* @author Everymind - Sprint 29 - (hackathon)
* @Descrição: cria os grupos doscontratantes da proposta
*/
    public void gerarGrupos(List<GrupoOrcamento__c> grupos, List<Proposta.GrupoWrapper> listGrupoWrapper, EmissaoTO.GrupoTO grupoPayloadProposta, Boolean contemViagem, Integer opcaoPagamentoProposta)
    {
        //======>>>>>>>> O código comentado abaixo foi movido para o método retornarNomeGrupoPassageiro.
        //PLV-4340 - INICIO
        //PLV-3285 - INICIO - MVP A Transmissão da proposta
        // String dataNascimentoSegurado;
        // String nomeGrupo = '';
        
        if(this.contemViagem == true){
            
            // 	dataNascimentoSegurado = grupoPayloadProposta.segurados[0].pessoa.dadosPessoaFisica.dataNascimento;
            // 	Integer idadeSegurado = ValidaRegrasGarantiaSniper.converterDataComtracosParaIdade(dataNascimentoSegurado);
            
            // 	system.debug('idadeSegurado: ' + idadeSegurado);
            
            // 	Map<String, ParametrosConstante__c> mapParametros = new Map<String, ParametrosConstante__c>();
            // 	List<ParametrosConstante__c> listaParametros = new List<ParametrosConstante__c>(
            // 										[SELECT name, valor__c
            // 										FROM ParametrosConstante__c 
            // 										WHERE name in ('GRUPO_JOVENS_NOME', 'GRUPO_JOVENS_IDADE_MIN', 'GRUPO_JOVENS_IDADE_MAX', 'GRUPO_IDOSOS_NOME')]);
            
            // 	if(!listaParametros.IsEmpty()){
            // 		for(ParametrosConstante__c parametro : listaParametros){
            // 			mapParametros.put(parametro.name, parametro);
            // 		}
            // 	}	
            
            // 	system.debug('mapParametros: ' + mapParametros);
            
            // 	if(mapParametros.isEmpty()) return;
            
            // 	system.debug('mapParametros.get(GRUPO_JOVENS_IDADE_MAX).valor__c: ' + mapParametros.get('GRUPO_JOVENS_IDADE_MAX').valor__c);
            // 	system.debug('Integer.Valueof - mapParametros.get(GRUPO_JOVENS_IDADE_MAX).valor__c: ' + Integer.Valueof(mapParametros.get('GRUPO_JOVENS_IDADE_MAX').valor__c));
            
            // 	if(idadeSegurado < Integer.Valueof(mapParametros.get('GRUPO_JOVENS_IDADE_MAX').valor__c)){
            // 		if(idadeSegurado > Integer.Valueof(mapParametros.get('GRUPO_JOVENS_IDADE_MIN').valor__c)){
            // 			nomeGrupo = mapParametros.get('GRUPO_JOVENS_NOME').valor__c;
            // 		}
            // 	}else{
            // 		nomeGrupo = mapParametros.get('GRUPO_IDOSOS_NOME').valor__c;
            // 	}
            //PLV-4340 - FIM
            
            // Instancias
            Proposta.GrupoWrapper grupoWrapper = new Proposta.GrupoWrapper();
            grupoWrapper.sfGrupo = new GrupoProposta__c();
            
            // Popular GrupoProposta__c
            this.popularGrupoPropostaViagem(grupoPayloadProposta, grupoWrapper.sfGrupo, opcaoPagamentoProposta); //PLV-4340 - INICIO/FIM
            
            // gera as garantias do grupo da proposta
            grupoWrapper.garantiasWrapper = new List<Proposta.GarantiaWrapper>();
            this.popularGarantiasGrupoWrapper(grupos[0].GruposGarantiaOrcamento__r, grupoWrapper.garantiasWrapper); //PLV-4340 - INICIO/FIM
            
            // gera os segurados desse grupo
            grupoWrapper.seguradosWrapper = new List<Proposta.SeguradoWrapper>();
            this.gerarSegurados(grupos[0].SeguradosOrcamento__r, grupoWrapper.seguradosWrapper, contemViagem, grupos[0].GruposGarantiaOrcamento__r); //PLV-4340 - INICIO/FIM
            
            listGrupoWrapper.add(grupoWrapper);
            
        }else{
            
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
                this.popularGarantiasGrupoWrapper(grupo.GruposGarantiaOrcamento__r, grupoWrapper.garantiasWrapper); //PLV-4340 - INICIO/FIM
                
                // gera os segurados desse grupo
                grupoWrapper.seguradosWrapper = new List<Proposta.SeguradoWrapper>();
                // O parâmetro grupoWrapper.garantiasWrapper passado no método abaixo só será usado no seguro Viagem
                this.gerarSegurados(grupo.SeguradosOrcamento__r, grupoWrapper.seguradosWrapper, false, grupo.GruposGarantiaOrcamento__r); //PLV-4340 - INICIO/FIM
                
                listGrupoWrapper.add(grupoWrapper);
            }
        }
        //PLV-3285 - FIM - MVP A Transmissão da proposta
    }
    
    //PLV-4340 - INICIO
    public void popularGrupoPropostaViagem(EmissaoTO.GrupoTO grupoPayload, GrupoProposta__c grupoProposta, Integer opcaoPagamentoProposta){ //PLV-4340 - INICIO/FIM
        
        Integer indice = 0; //PLV-4340 - INICIO/FIM
        
        try{
            system.debug('popularGrupoPropostaViagem - opcaoPagamentoProposta: ' + opcaoPagamentoProposta);
            system.debug('payloadOrcamentoPrecificacao.retornosCalculo'+payloadOrcamentoPrecificacao.retornosCalculo);
            //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            //PLV-4798 - INICIO - GUSTAVO
            if('Viagem'.equalsIgnoreCase(this.segmento)) {
                indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
            }
            //PLV-4798 - FIM - GUSTAVO
            EmissaoTO.DescontoagravoTO descontoAgravo = null;
            //PLV-4800 - INÍCIO
            EmissaoTO.PremioTO premio = null; 
            EmissaoTO.TaxaTO taxa = null;
            //PLV-4800 - FIM

            if(this.mapOpcaoDescontoGrupos !=null && !this.mapOpcaoDescontoGrupos.isEmpty() && this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice)!=null){
                grupoPayload = this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice);
                descontoAgravo = grupoPayload.segurados[0].descontoAgravo != null ? grupoPayload.segurados[0].descontoAgravo[0] : null;
                //PLV-4800 - INÍCIO
                premio = grupoPayload.segurados[0].premio != null ? grupoPayload.segurados[0].premio : null;
                taxa = grupoPayload.segurados[0].taxa != null ? grupoPayload.segurados[0].taxa : null;
                //PLV-4800 - FIM
            }

            if(descontoAgravo!=null){
                if(descontoAgravo.tipo=='FPG'){
                    grupoProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                    grupoProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
                }else if(descontoAgravo.tipo == 'TPR'){
                    grupoProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                    grupoProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
                }
                //PLV-4800 - INÍCIO
                if(premio != null){
                    grupoProposta.PremioIntegral__c = premio.integral; //PLV-5351 INICIO/FIM
                    grupoProposta.PremioComercial__c = premio.comercial;
                    grupoProposta.PremioPuro__c = premio.puro;
                    grupoProposta.PremioTotal__c = premio.total;
                }
                
                if(taxa != null){
                    grupoProposta.TaxaComercial__c = taxa.comercial;
                    grupoProposta.TaxaPura__c = taxa.pura;
                    grupoProposta.TaxaTotal__c = taxa.total;
                }
                //PLV-4800 - FIM
                
            }
            //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
            grupoProposta.Name = this.nomeGrupo;
            system.debug('popularGrupoPropostaViagem - nomeGrupo 2: ' + this.nomeGrupo);
            grupoProposta.QuantidadeVidas__c = grupoPayload.qtdeVidas==null ? 1 : grupoPayload.qtdeVidas; //PLV-4788 INICIO/FIM - PEDRO AUGUSTO BRAZ
            //PLV-4587 INICIO FIX 1
            grupoProposta.Numero__c = grupoPayload.numero != null ? Integer.valueOf(grupoPayload.numero) : null;
            //PLV-4587 FIM FIX 1
            
            //************** PLV-3285 - verificar por que as linhas abaixo estão comentadas **************
            
            
            // grupoProposta.Descricao__c = grupo.Descricao__c;
            // //grupoProposta.IOF__c = grupo.IOF__c;
            
            // grupoProposta.Numero__c = grupo.Numero__c;
            // //grupoProposta.Percentual__c = grupo.Percentual__c;
            // grupoProposta.TipoCalculo__c = grupo.TipoCalculo__c;
            // grupoProposta.TipoDescontoAgravo__c = grupo.TipoDescontoAgravo__c;
            
            
            // grupoProposta.PremioComercial__c = grupo.PremioComercial__c;
            // grupoProposta.PremioPuro__c = grupo.PremioPuro__c;
            // grupoProposta.PremioTotal__c = grupo.PremioTotal__c;
            
            // grupoProposta.TaxaComercial__c = grupo.TaxaComercial__c;
            // grupoProposta.TaxaPura__c = grupo.TaxaPura__c;
            // grupoProposta.TaxaTotal__c = grupo.TaxaTotal__c;
            
            // grupoProposta.DescontoAgravoMonetarioComercial__c = grupo.DescontoAgravoMonetarioComercial__c;
            // grupoProposta.DescontoAgravoMonetarioInformado__c = grupo.DescontoAgravoMonetarioInformado__c;
            // grupoProposta.DescontoAgravoMonetarioTecnico__c = grupo.DescontoAgravoMonetarioTecnico__c;
            // grupoProposta.DescontoAgravoPercentualComercial__c = grupo.DescontoAgravoPercentualComercial__c;
            // grupoProposta.DescontoAgravoPercentualInformado__c = grupo.DescontoAgravoPercentualInformado__c;
            // grupoProposta.DescontoAgravoPercentualTecnico__c = grupo.DescontoAgravoPercentualTecnico__c;
        }catch (Exception e){
            throw new PropostaBuilderException('Exception: popularGrupoPropostaViagem \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }	
    }
    //PLV-4340 - FIM
    
    /*
* @author Everymind - Sprint 29 - (hackathon)
* @Descrição: cria os segurados dos grupos dos contratantes da proposta
*/
    public void gerarSegurados(List<SeguradoOrcamento__c> segurados, List<Proposta.SeguradoWrapper> listSeguradoWrapper, Boolean contemViagem, List<GarantiaGrupoOrcamento__c> garantiasGrupoOrcamento) //PLV-4340 - INICIO/FIM - //PLV-3285
    {
        Map<String, String> mpEnderecoSegurado = new Map<String, String>(); // PLV-4844 INICIO/FIM
        // monta o mapa com os beneficiarios do segurados no payload recebido
        Map<String, List<EmissaoTO.BeneficiarioTO>> mapBeneficiariosTO = new Map<String, List<EmissaoTO.BeneficiarioTO>>();
        //PLV-2728 - Inicio
        Map<String, List<EmissaoTO.EnderecoTO>> mEnderecos = new Map<String, List<EmissaoTO.EnderecoTO>>();
        for(EmissaoTO.ContratanteTO contratante  : payload.proposta.contratantes){
            for(EmissaoTO.GrupoTO grupo : contratante.grupos){
                for(EmissaoTO.SeguradoTO segurado : grupo.segurados){
                    //PLV-3285 - INICIO - MVP A Transmissão da proposta
                    if(segurado.beneficiarios == null){
                        segurado.beneficiarios = new List<EmissaoTO.BeneficiarioTO>();
                        EmissaoTO.BeneficiarioTO beneficiarioTO = new EmissaoTO.BeneficiarioTO();
                        beneficiarioTO.tipoBeneficiario = 'Herdeiros legais, conforme artigo 792 do código civil.'; // PLV-4524-FIX INICIO/FIM
                        beneficiarioTO.participacao = 100;
                        
                        segurado.beneficiarios.add(beneficiarioTO);
                    }					
                    //PLV-3285 - FIM - MVP A Transmissão da proposta
                    mapBeneficiariosTO.put(segurado.numero, segurado.beneficiarios);
                    String idExterno = montarChavePessoa(segurado.pessoa);
                    // PLV-4844 INICIO
                    // if(segurado.pessoa.enderecos.size() > 0) mEnderecos.put(idExterno, segurado.pessoa.enderecos);
                    
                   // INICIO - VIAG-144
                   if(segurado.pessoa.enderecos.size() > 0 || segurado.pessoa.enderecos != null ){
                        mEnderecos.put(idExterno, segurado.pessoa.enderecos);
                    }
                   // FIM - VIAG-144 
                    for(EmissaoTO.EnderecoTO endereco : segurado.pessoa.enderecos){
                        mpEnderecoSegurado.put('logradouro', endereco.logradouro);
                        mpEnderecoSegurado.put('numeroLogradouro', endereco.numeroLogradouro);
                        mpEnderecoSegurado.put('complemento', endereco.complemento);
                        mpEnderecoSegurado.put('bairro', endereco.bairro);
                        mpEnderecoSegurado.put('cidade', endereco.cidade);
                        mpEnderecoSegurado.put('uf', endereco.uf);
                        mpEnderecoSegurado.put('paisResidencia', endereco.paisResidencia);
                        //VIAG-205 INÍCIO
                        String enderecoCep = endereco.cep + '-' + endereco.complementoCep;
                        if(enderecoCep != '-' && enderecoCep != null){
                             mpEnderecoSegurado.put('cep', enderecoCep.replaceAll('\\.', ''));
                        }
                        //VIAG-205 FIM

                        break;
                    }

                    // PLV-4844 FIM
                }
            }
        }
      
        if(mEnderecos != null || mEnderecos.size() > 0){
            List<Account> lContasEnderecos = [SELECT id, IdExterno__c FROM Account WHERE IdExterno__c IN :mEnderecos.keySet()];
            
            //List<Endereco__c> lEndereco2Insert = new List<Endereco__c>();//PLV-4894 - INICIO/FIM
            
            for (Account conta : lContasEnderecos) {
                if(mEnderecos.containsKey(conta.IdExterno__c)){
                    List<EmissaoTO.EnderecoTO> lEnderecos = mEnderecos.get(conta.IdExterno__c);
                    
                    for (EmissaoTO.EnderecoTO endereco : lEnderecos) {
                        if(endereco.cep != null && endereco.cep != ''){  //PLV-4670 - INÍCIO/FIM // PLV-4816-COMPLEMENTO-FIX2
                            Endereco__c endereco2Insert = new Endereco__c();
                            endereco2Insert.Conta__c = conta.Id;
                            //VIAG-205 INÍCIO
                            String enderecoCep = (endereco.cep + endereco.complementoCep) != null ? (endereco.cep + endereco.complementoCep) : '';
                            if(enderecoCep != ''){
                                endereco2Insert.CEP__c = enderecoCep.replaceAll('\\.', '');
                            }
                            //VIAG-205 FIM
                            endereco2Insert.Logradouro__c = endereco.logradouro;
                            endereco2Insert.TipoEndereco__c = endereco.tipoEndereco;
                            endereco2Insert.TipoLogradouro__c = endereco.tipoLogradouro;
                            endereco2Insert.Numero__c = endereco.numeroLogradouro;
                            endereco2Insert.Complemento__c = endereco.complemento;
                            endereco2Insert.Bairro__c = endereco.bairro;
                            endereco2Insert.Cidade__c = endereco.cidade;
                            endereco2Insert.Estado__c = endereco.uf;
                            endereco2Insert.Pais__c = endereco.paisResidencia;
                            endereco2Insert.MaisAtual__c = true;
                            endereco2Insert.IdExterno__c = endereco2BO.montarIdExterno(endereco2Insert);
                             System.debug('IdExterno>>>>'+ endereco2BO.montarIdExterno(endereco2Insert) );
                            this.mapEndrecosToInsert.put(endereco2Insert.IdExterno__c,endereco2Insert);//PLV-4894 - INICIO/FIM
                        } //PLV-4670 - INÍCIO/FIM
                    }
                }
            }
            // PLV-4900 - INICIO
            
            System.debug('mapEndrecosToInsert HENRIQUE: ' + mapEndrecosToInsert); 
            
            if(!mapEndrecosToInsert.values().isEmpty())
            upsert this.mapEndrecosToInsert.values() IdExterno__c;
           
            // PLV-4900 - FIM

            //if(lEndereco2Insert.size() > 0) upsert lEndereco2Insert IdExterno__c;//PLV-4894 - INICIO/FIM
        }
       
        
        //PLV-3285 - INICIO - MVP A Transmissão da proposta
        //Haverá apenas um segurado no json de entrada para o produto Viagem, por isso apenas a primeira posição
        //da lista será considerada.		
        if(this.contemViagem == true){ //PLV-4340 - INICIO/FIM
            
            system.debug('payload.proposta.contratantes[0].grupos[0].segurados[0]:' + payload.proposta.contratantes[0].grupos[0].segurados[0]);
            
            EmissaoTO.SeguradoTO seguradoPayloadProposta = payload.proposta.contratantes[0].grupos[0].segurados[0];
            EmissaoTO.PessoaTO responsavelFinanceiro = payload.proposta.contratantes[0].dadosPagamento.responsavelFinanceiroSeguro; //PLV-4911 - INICIO/FIM - PEDRO AUGUSTO BRAZ

            // Instancias
            Proposta.SeguradoWrapper seguradoWrapper = new Proposta.SeguradoWrapper();
            // Popular Segurado Proposta
            seguradoWrapper.sfSegurado = new SeguradoProposta__c();

            // PLV-4844 INICIO
            seguradoWrapper.sfSegurado.logradouroResidencial__c    = mpEnderecoSegurado.get('logradouro');
            seguradoWrapper.sfSegurado.numeroResidencial__c        = mpEnderecoSegurado.get('numeroLogradouro');
            seguradoWrapper.sfSegurado.ComplementoResidencial__c   = mpEnderecoSegurado.get('complemento');
            seguradoWrapper.sfSegurado.bairroResidencial__c        = mpEnderecoSegurado.get('bairro');
            seguradoWrapper.sfSegurado.CidadeResidencial__c        = mpEnderecoSegurado.get('cidade');
            seguradoWrapper.sfSegurado.UFResidencial__c            = mpEnderecoSegurado.get('uf');
            seguradoWrapper.sfSegurado.paisResidencial__c          = mpEnderecoSegurado.get('paisResidencia');
            seguradoWrapper.sfSegurado.cepResidencial__c           = mpEnderecoSegurado.get('cep');
            // PLV-4844 FIM
            
            this.popularSeguradoPropostaViagem(seguradoPayloadProposta, seguradoWrapper.sfSegurado, responsavelFinanceiro); //PLV-4340 - INICIO/FIM //PLV-4563 -INICIO/FIM - Vinícius Caetano
            
            // gera as garantias do contratante da proposta
            seguradoWrapper.garantiasWrapper = new List<Proposta.GarantiaWrapper>();
            //As garantias do grupo serão copiadas para preencher as garantias do segurado pois serão sempre iguais
            this.popularGarantiasSeguradoViagemWrapper(garantiasGrupoOrcamento, seguradoWrapper.garantiasWrapper); //PLV-4340 - INICIO/FIM
            
            //**********************************
            seguradoWrapper.beneficiariosWrapper = new List<Proposta.BeneficiariosWrapper>();
            
            //PLV-2713-Mochila - INICIO - Ajuste para passar participacao 100 por cento ao beneficiário
            Proposta.BeneficiariosWrapper beneficiarioWrapper = new Proposta.BeneficiariosWrapper();
            beneficiarioWrapper.sfBeneficiarioSeguradoProposta = new BeneficiarioSeguradoProposta__c(
                tipoBeneficiario__c = 'Herdeiros legais, conforme artigo 792 do código civil.', Participacao__c = 100);// PLV-4524-FIX INICIO/FIM
            //PLV-2713-Mochila - FIM
            system.debug('beneficiarioWrapper: ' + beneficiarioWrapper);
            
            seguradoWrapper.beneficiariosWrapper.add(beneficiarioWrapper);		
            
            //*********************************
            listSeguradoWrapper.add(seguradoWrapper);
            
        }else{
            //PLV-2728 - Inicio
            for(SeguradoOrcamento__c segurado : segurados)
            {
                // Instancias
                Proposta.SeguradoWrapper seguradoWrapper = new Proposta.SeguradoWrapper();
                // Popular Segurado Proposta
                seguradoWrapper.sfSegurado = new SeguradoProposta__c();
                //this.popularSeguradoProposta(segurado, seguradoWrapper.sfSegurado);
                EmissaoTO.SeguradoTO seguradoPayloadProposta = payload.proposta.contratantes[0].grupos[0].segurados[0]; //PLV-4440 - INICIO/FIM
                
                this.popularSeguradoProposta(segurado, seguradoWrapper.sfSegurado, seguradoPayloadProposta); //PLV-4440 - INICIO/FIM

             // PLV-4594 INICIO SYS4B ODEMIR  Esta usando os dados do contratante, pois no json do segurado nao vem estas informacoes
              seguradoWrapper.sfSegurado.IntegracaoPEP__c =  payload.proposta.contratantes[0].pessoa?.pessoaPEP?.retornoIntegracaoPEP?.pep;
              seguradoWrapper.sfSegurado.CargoPEP__c =  payload.proposta.contratantes[0].pessoa?.pessoaPEP?.retornoIntegracaoPEP?.cargo;
              seguradoWrapper.sfSegurado.UltimaConsultaPEP__c = System.today();
              try {
                if ( payload.proposta.contratantes[0].pessoa?.pessoaPEP?.retornoIntegracaoPEP?.dataAtualizacao != null
                    && payload.proposta.contratantes[0].pessoa?.pessoaPEP?.retornoIntegracaoPEP?.dataAtualizacao.trim().length() > 0 )
                    seguradoWrapper.sfSegurado.DataAtualizacaoPEP__c = Date.valueOf(payload.proposta.contratantes[0].pessoa?.pessoaPEP?.retornoIntegracaoPEP?.dataAtualizacao);
                else
                    seguradoWrapper.sfSegurado.DataAtualizacaoPEP__c=null;
              } catch ( Exception e ) {
                   System.debug('Erro convertendo data de atualizacao '+ e.getStackTraceString());
                   seguradoWrapper.sfSegurado.DataAtualizacaoPEP__c=null;
              }
                 // PLV-4594 FIM SYS4B ODEMIR
                
                // gera as garantias do contratante da proposta
                seguradoWrapper.garantiasWrapper = new List<Proposta.GarantiaWrapper>();
                this.popularGarantiasSeguradoWrapper(mapGarantiaSeguradoOrcamento.get(segurado.Id), seguradoWrapper.garantiasWrapper);
                
                // gera os beneficiarios do segurado do grupo do contraante da proposta
                seguradoWrapper.beneficiariosWrapper = new List<Proposta.BeneficiariosWrapper>();
                seguradoWrapper.beneficiariosWrapper = this.gerarBeneficiarios(mapBeneficiariosTO.get(String.valueOf(segurado.Numero__c)), seguradoWrapper);
                
                listSeguradoWrapper.add(seguradoWrapper);
            }
        }
        //PLV-3285 - FIM - MVP A Transmissão da proposta
    }
    
    // INICIO | PLV-2402-30
    /*
* @author Everymind - Sprint 30 - (hackathon)
* @Descrição: cria as critícas da proposta
*/
    public override void gerarCriticas(EmissaoTO.PayloadTO payloadTO, List<Proposta.CriticaPropostaWrapper> listCriticasWrapper)
    {
        //PLV - 4257 inicio
        if(payloadTO.retornoAceitacao != null ){
            if(payloadTO.retornoAceitacao.analises != null || payloadTO.retornoAceitacao.avisos != null || 
               payloadTO.retornoAceitacao.recusas != null || payloadTO.retornoAceitacao.pendencias != null){
                   if(payloadTO.retornoAceitacao.recusas != null){
                       for(EmissaoTO.RecusaTO recusa : payloadTO.retornoAceitacao.recusas){
                           
                           Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                           criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                           popularCriticaRecusaWrapper(recusa, criticaWrapper.sfCriticaProposta);
                           
                           listCriticasWrapper.add(criticaWrapper);
                       }                      
                   } //PLV-3285           
                   
                   if(payloadTO.retornoAceitacao.avisos != null){
                       for(EmissaoTO.AvisoTO aviso : payloadTO.retornoAceitacao.avisos){
                           
                           Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                           criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                           popularCriticaAvisoWrapper(aviso, criticaWrapper.sfCriticaProposta);
                           
                           listCriticasWrapper.add(criticaWrapper);
                       }
                   } //PLV-3285
                   
                   if(payloadTO.retornoAceitacao.analises != null){
                       for(EmissaoTO.AnaliseTO analise : payloadTO.retornoAceitacao.analises){
                           
                           Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                           criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                           popularCriticaAnaliseWrapper(analise, criticaWrapper.sfCriticaProposta);
                           
                           listCriticasWrapper.add(criticaWrapper);
                       }
                   } //PLV-3285            
                                     
                   //PLV-2675 - Inicio - Validação criada pois o ODM retorna null a tag pendencias
                   if(payloadTO.retornoAceitacao.pendencias != null){
                       for(EmissaoTO.PendenciaTO pendencia : payloadTO.retornoAceitacao.pendencias){
                           
                           Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                           criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                           popularCriticaPendenciaWrapper(pendencia, criticaWrapper.sfCriticaProposta);
                           
                           listCriticasWrapper.add(criticaWrapper);
                       }
                   }
                   //PLV-2675 - Fim
               }

                //PLV-4790 FIX 3 INICIO
                if (listCriticasWrapper != null && listCriticasWrapper.size() > 0) {
                    Boolean hasRecusa = false;

                    for (Proposta.CriticaPropostaWrapper critica : listCriticasWrapper) {
                        if (critica.sfCriticaProposta != null && critica.sfCriticaProposta.Tipo__c == 'Recusa') {
                            hasRecusa = true;
                            critica.sfCriticaProposta.Status__c = 'Recusado';
                        }
                    }

                    if (hasRecusa) {
                        for (Proposta.CriticaPropostaWrapper critica : listCriticasWrapper) {
                            if (critica.sfCriticaProposta != null && critica.sfCriticaProposta.Tipo__c != 'Recusa') {
                                critica.sfCriticaProposta.Status__c = 'Cancelada';
                            }
                        }
                    }
                }
                //PLV-4790 FIX 3 FIM
        }
        //PLV - 4257 fim
    }
    // FIM | PLV-2402-30
    
    //PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
    //Parametro de entrada do método alterado de EmissaoTO.PayloadTO para EmissaoTO.RetornoAceitacaoTO    
    public void gerarCriticasRetornoAceitacao(EmissaoTO.RetornoAceitacaoTO retornoAceitacao, List<Proposta.CriticaPropostaWrapper> listCriticasWrapper, EmissaoTO proposta)//PLV-5643 INICIO/FIM
    {
        system.debug('gerarCriticasRetornoAceitacao>> '+ listCriticasWrapper);
        //popula wrapper de criticas da proposta de acorso com o payload 
        //mapeira Retornos -Analise
        system.debug( ' @@@! analise:> ' + retornoAceitacao ) ;
        if(retornoAceitacao.analises != null)
            for(EmissaoTO.AnaliseTO analise : retornoAceitacao.analises){
                
                Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                popularCriticaPropostaAnalise(analise, criticaWrapper.sfCriticaProposta);
                
                listCriticasWrapper.add(criticaWrapper);
            }
        
        //mapeira Retornos -aviso		
        if(retornoAceitacao.avisos != null)
            for(EmissaoTO.AvisoTO aviso : retornoAceitacao.avisos){
                
                Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                popularCriticaPropostaAviso(aviso, criticaWrapper.sfCriticaProposta);
                
                listCriticasWrapper.add(criticaWrapper);
            }
        
        //mapeira Retornos -recusa
        if(retornoAceitacao.recusas != null)
            for(EmissaoTO.RecusaTO recusa : retornoAceitacao.recusas){
                
                Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                popularCriticaPropostaRecusa(recusa, criticaWrapper.sfCriticaProposta);
                
                listCriticasWrapper.add(criticaWrapper);
            }
        
        //mapeira Retornos -pendencia		
        if(retornoAceitacao.pendencias != null){
            for(EmissaoTO.PendenciaTO pendencia : retornoAceitacao.pendencias){
                
                Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
                criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
                popularCriticaPropostaPendecia(pendencia, criticaWrapper.sfCriticaProposta);
                
                listCriticasWrapper.add(criticaWrapper);
            }
        }

        System.debug('listCriticasWrapper: ' + JSON.serialize(listCriticasWrapper));
        System.debug('1954 - PROPOSTA: ' + JSON.serialize(proposta));


        //PLV-4953 - INICIO
        if (listCriticasWrapper != null && listCriticasWrapper.size() > 0) {
            //PLV-5643 INICIO
            Boolean hasCriticaSamplemed = false;
            Boolean hasReaproveitarAssinatura = false;            

            for (Proposta.CriticaPropostaWrapper critica : listCriticasWrapper) {
                if (critica.sfCriticaProposta != null && critica.sfCriticaProposta.Integracao__c == 'SAMPLE' &&
                (critica.sfCriticaProposta.Acao__c == 'auto' || critica.sfCriticaProposta.Acao__c == 'tele' ||
                critica.sfCriticaProposta.Acao__c == 'video')) {
                    hasCriticaSamplemed = true;
                }
            }
            
            if(proposta != null){
                String numeroProposta = proposta.numero.leftPad(8,'0');
                String nameProposta = QuoteBO.getInstance().gerarNameProposta(String.valueOf(proposta.origem),numeroProposta);
                Quote propostaR = [SELECT Id,ReaproveitarAssinatura__c FROM Quote WHERE Name =:nameProposta];
                if(propostaR.ReaproveitarAssinatura__c == true){                    
                    hasReaproveitarAssinatura = true;
                }
            }

            System.debug('hasCriticaSamplemed => ' + hasCriticaSamplemed);
            System.debug('hasReaproveitarAssinatura => ' + hasReaproveitarAssinatura);
            if (hasCriticaSamplemed || hasReaproveitarAssinatura) {
                for (Proposta.CriticaPropostaWrapper critica : listCriticasWrapper) {
                    if (critica.sfCriticaProposta != null && critica.sfCriticaProposta.Integracao__c == 'DOCUSIGN') {
                        critica.sfCriticaProposta.Status__c = 'Liberado';
                        System.debug('CRITICA DOCUSIGN LIBERADA');
                    }
                }
            }
            //PLV-5643 FIM
        }
        //PLV-4953 - FIM

        //PLV-4790 FIX 3 INICIO
        if (listCriticasWrapper != null && listCriticasWrapper.size() > 0) {
            Boolean hasRecusa = false;

            for (Proposta.CriticaPropostaWrapper critica : listCriticasWrapper) {
                if (critica.sfCriticaProposta != null && critica.sfCriticaProposta.Tipo__c == 'Recusa') {
                    hasRecusa = true;
                    critica.sfCriticaProposta.Status__c = 'Recusado';
                }
            }

            if (hasRecusa) {
                for (Proposta.CriticaPropostaWrapper critica : listCriticasWrapper) {
                    if (critica.sfCriticaProposta != null && critica.sfCriticaProposta.Tipo__c != 'Recusa') {
                        critica.sfCriticaProposta.Status__c = 'Cancelada';
                    }
                }
            }
        }
        //PLV-4790 FIX 3 FIM
    }
    
    public void gerarCriticasRetornoFinanceiro(EmissaoTO.RetornoFinanceiroTO retornoFinanceiro, List<Proposta.CriticaPropostaWrapper> listCriticasWrapper)
    {
        
        Proposta.CriticaPropostaWrapper criticaWrapper = new Proposta.CriticaPropostaWrapper();
        criticaWrapper.sfCriticaProposta = new CriticaProposta__c();
        
        // confirmar o valor do tipo no caso da recusa do cartão e criar esse valor non picklist
        criticaWrapper.sfCriticaProposta.Tipo__c                  = TIPO_CRITICA_RECUSAS;
        criticaWrapper.sfCriticaProposta.Status__c                = 'Recusado';
        criticaWrapper.sfCriticaProposta.Origem__c                = retornoFinanceiro.autorizacaoCartao.stargate != null ? 'Stargate': 
                                                                    retornoFinanceiro.autorizacaoCartao.portoPag != null ? 'PortoPag' : null; //TKCL 458 - FIM    
        criticaWrapper.sfCriticaProposta.Codigo__c                = retornoFinanceiro.autorizacaoCartao.stargate != null ? String.valueOf(retornoFinanceiro.autorizacaoCartao.stargate.codigo) :  
                                                                    retornoFinanceiro.autorizacaoCartao.portoPag.codigo != null ? retornoFinanceiro.autorizacaoCartao.portoPag.codigo : '999'; //TKCL 458 - FIM    
        criticaWrapper.sfCriticaProposta.Descricao__c             = 'Crítica na validação do cartão de crédito';
        
        //PLV-4854-FIX1 - inicio
        if(retornoFinanceiro!=null && retornoFinanceiro.autorizacaoCartao!=null && retornoFinanceiro.autorizacaoCartao.stargate!=null && retornoFinanceiro.autorizacaoCartao.stargate.mensagem != null){ //TKCL 458 - INICIO/FIM 
			criticaWrapper.sfCriticaProposta.MensagemInterna__c = 'Autorização Cartão: Código ' + retornoFinanceiro.autorizacaoCartao.stargate.codigo + ' - ' + retornoFinanceiro.autorizacaoCartao.stargate.mensagem; //INICIO/FIM | PLV-4647-VI-Guilherme Brito            
            DateTime now = System.now();
            criticaWrapper.sfCriticaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + 'Autorização Cartão: Código ' + retornoFinanceiro.autorizacaoCartao.stargate.codigo + ' - ' + retornoFinanceiro.autorizacaoCartao.stargate.mensagem; //INICIO/FIM | PLV-4647-VI-Guilherme Brito                    
        }
        //PLV-4854-FIX1 - fim
        //TKCL 458 - INICIO
        if(retornoFinanceiro!=null && retornoFinanceiro.autorizacaoCartao!=null && retornoFinanceiro.autorizacaoCartao.portoPag!=null){ 
            Boolean cartaorecusadoportopag = false;
            if (retornoFinanceiro.autorizacaoCartao.portoPag.cobrancas!=null && !retornoFinanceiro.autorizacaoCartao.portoPag.cobrancas.isEmpty()) {
                for(EmissaoTO.CobrancaTO cobranca : retornoFinanceiro.autorizacaoCartao.portoPag.cobrancas) {
                    if(cobranca.detalhes != null && cobranca.detalhes.equals('DECLINED')){
                        cartaorecusadoportopag = true;
                    } 
                }
            }
            String codigo = retornoFinanceiro.autorizacaoCartao.portoPag.codigo != null ? retornoFinanceiro.autorizacaoCartao.portoPag.codigo : '';
            String mensagem = retornoFinanceiro.autorizacaoCartao.portoPag.mensagem != null ? retornoFinanceiro.autorizacaoCartao.portoPag.mensagem : '';
            criticaWrapper.sfCriticaProposta.MensagemInterna__c =  portopagRecusa != '' ? portopagRecusa : 'Autorização Cartão: Código ' + codigo + ' - ' + mensagem; //INICIO/FIM | PLV-4647-VI-Guilherme Brito - TKCL 458-FIX02 INICIO/FIM           
            DateTime now = System.now();
            criticaWrapper.sfCriticaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + 'Autorização Cartão: Código ' + codigo + ' - ' + mensagem;                  
        }
        System.debug('LOG CriticaWrapper => '+JSON.serializePretty(criticaWrapper));
        //TKCL 458 - FIM    
        
        listCriticasWrapper.add(criticaWrapper);		
    }
    //PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
    
    
    /*
* @author Everymind - Sprint 29 - (hackathon)
* @Descrição: cria os beneficiarios dos segurados dos grupos dos contratantes da proposta
*/
    public override List<Proposta.BeneficiariosWrapper> gerarBeneficiarios(List<EmissaoTO.BeneficiarioTO> beneficiariosTO, Proposta.SeguradoWrapper seguradoWrapper)
    { 
        seguradoWrapper.beneficiariosWrapper = new List<Proposta.BeneficiariosWrapper>();
        
        for(EmissaoTO.BeneficiarioTO beneficiario : beneficiariosTO)
        {
            Proposta.BeneficiariosWrapper beneficiarioWrapper = new Proposta.BeneficiariosWrapper();
            beneficiarioWrapper.sfBeneficiarioSeguradoProposta = new BeneficiarioSeguradoProposta__c();
            
            this.popularBeneficiarioProposta(beneficiario, beneficiarioWrapper.sfBeneficiarioSeguradoProposta);
            
            seguradoWrapper.beneficiariosWrapper.add(beneficiarioWrapper);
        }
        
        return seguradoWrapper.beneficiariosWrapper; 
    }
    
    /*
* @author Everymind - Sprint 29 - (hackathon)
* @Descrição: cria as contas da emissão
*/
    public override void gerarContas(EmissaoTO.PayloadTO payloadTO, List<Proposta.PessoaWrapper> listPessoasWrapper) 
    { 
        System.debug(' %$%$%$ payloadTO :> ' + payloadTO) ;
        // monta o mapa com os favorecidos das remunerações obtidas no payload recebido
        Map<String, EmissaoTO.PessoaTO> mapPessoaTO = new Map<String, EmissaoTO.PessoaTO>();
        List<Account> lstContasNovas = new List<Account>();
        
        // monta os sets p/ obter as contas dos favorecidos da remuneracao
        // deles já estão na base do salesforce através de cargas!
        if(payload.proposta.remuneracoes != null){
            for(EmissaoTO.RemuneracaoTO remuneracaoTO : payload.proposta.remuneracoes){
                for(EmissaoTO.FavorecidoTO favorecido : remuneracaoTO.favorecidos){ 
                    if(favorecido.pessoa != null){
                        String idExterno = montarChavePessoa(favorecido.pessoa);
                        setContas.add(idExterno);
                        // PLV-3285 - INICIO - Removido porque não precisa atualizar dados de corretores e agencionadores a partir do payload, pois o registro
                        //mapPessoaTO.put(idExterno, favorecido.pessoa);
                        // PLV-3285 - FIM
                    }
                }
            }
        }
        
        // INICIO - PLV2610
        // inclui no mapa de contas os beneficiarios com cf/ cnpj
        for(EmissaoTO.ContratanteTO contratante  : payload.proposta.contratantes){
            
            //PLV-2826 - INICIO - Criar oportunidade sem conta
            String idExternoContratante = montarChavePessoa(contratante.pessoa);
            mapPessoaTO.put(idExternoContratante, contratante.pessoa);
            //PLV-2826 - FIM - Criar oportunidade sem conta
            for(EmissaoTO.GrupoTO grupo : contratante.grupos){
                for(EmissaoTO.SeguradoTO segurado : grupo.segurados){
                    
                    String idExterno = montarChavePessoa(segurado.pessoa);
                    setContas.add(idExterno);
                    mapPessoaTO.put(idExterno, segurado.pessoa);
                    
                    system.debug('idExterno do setcontas: ' + idExterno);
                    system.debug('segurado.pessoa: ' + segurado.pessoa);
                    
                    if(segurado.beneficiarios == null) continue;
                    
                    for(EmissaoTO.BeneficiarioTO beneficiario : segurado.beneficiarios){
                        
                        if (beneficiario.tipoBeneficiario == 'Herdeiros legais, conforme artigo 792 do código civil.' || // PLV-4524-FIX INICIO/FIM
                            String.isNotEmpty(beneficiario.motivoSemCpfCnpj)) continue;
                        if(beneficiario.pessoa == null) continue; //PLV-4440 - INICIO/FIM
                        String idExterno2 = montarChavePessoa(beneficiario.pessoa);
                        setContas.add(idExterno2);
                        mapPessoaTO.put(idExterno2, beneficiario.pessoa);
                    }									
                }
            }
        }
        // FIM - PLV2610
        
        // obtem as contas e adiciona no mapa
        for(Account conta : AccountDAO.getInstance().buscarContasPorIdExterno(setContas))
            mapContas.put(conta.IdExterno__c, conta);
        
        system.debug('Contas mapa: '+ mapContas);
        system.debug('mapPessoaTO.values'+mapPessoaTO.values());
        this.popularPessoaWrapper(mapPessoaTO.values(), listPessoasWrapper);
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: persiste a proposta
*/
    // 2666 - INICIO
    public override Proposta inserirRegistros(Proposta proposta)
    {
        system.debug('ACESSOU O INSERIR!!');
        // Instancias
        List<GarantiaProposta__c> listGarantiaProposta = new List<GarantiaProposta__c>();
        List<GarantiaContratanteProposta__c> listGarantiaContratanteProposta = new List<GarantiaContratanteProposta__c>();
        List<GarantiasGrupoProposta__c> listGarantiaGrupoProposta = new List<GarantiasGrupoProposta__c>();
        List<GarantiaSeguradoProposta__c> listGarantiaSeguradoProposta = new List<GarantiaSeguradoProposta__c>();
        List<RemuneracaoProposta__c> listRemuneracaoProposta = new List<RemuneracaoProposta__c>();
        List<FavorecidoRemuneracaoProposta__c> listFavorecidoRemuneracaoProposta = new List<FavorecidoRemuneracaoProposta__c>();
        List<ContratanteProposta__c> listContratanteProposta = new List<ContratanteProposta__c>();
        Map<String,InformacaoBancaria__c> mapInformacaoBancaria = new Map<String,InformacaoBancaria__c>();//PLV-4440 - INICIO/FIM
        List<CartaoCredito__c> listCartaoCredito = new List<CartaoCredito__c>();
        List<GrupoProposta__c> listGrupoProposta = new List<GrupoProposta__c>();
        List<SeguradoProposta__c> listSeguradoProposta = new List<SeguradoProposta__c>();
        List<BeneficiarioSeguradoProposta__c> listBeneficiarioSeguradoProposta = new List<BeneficiarioSeguradoProposta__c>();
        
        // Insere a proposta
        
        try{
            system.debug('PropostaGenerica - this.proposta.propostaWrapper.sfProposta: ' + JSON.serialize(this.proposta.propostaWrapper.sfProposta)); //PLV-3285
            
            insert this.proposta.propostaWrapper.sfProposta;
        	    
            
            criarRespostaDeclaracaoSaude(payload, this.proposta.propostaWrapper.sfProposta.id);
            
            system.debug('PASSOU AQUII PARA criarRespostaDeclaracaoSaude' + payload + ' >>>  ' + this.proposta.propostaWrapper.sfProposta.id );
        }catch (Exception e){
        	
            system.debug(LoggingLevel.ERROR, 'ttttt'+e);
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
        
        // 2666 - INICIO
        //PLV-2710 - INICIO

        //PLV-4440 INICIO
        Map<Id, Banco__c> mBancos = InformacaoBancariaBO.getMapBancos();
        //PLV-4440 FIM

        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper)
        {
            //   System.debug('mapConta = '+JSON.serialize(mapContas));
            //   System.debug('contratanteWrapper.sfInformacaoBancaria = '+JSON.serialize(contratanteWrapper.sfInformacaoBancaria));
            System.debug('mapConta = '+ mapContas);
            System.debug('contratanteWrapper.sfInformacaoBancaria = '+ contratanteWrapper.sfInformacaoBancaria);
            system.debug('contratanteWrapper.sfCartaoCredito = '+contratanteWrapper.sfCartaoCredito);
            
            if (contratanteWrapper.sfInformacaoBancaria.NumeroConta__c != null) {
                contratanteWrapper.sfInformacaoBancaria.Conta__c = mapContas.get(contratanteWrapper.sfInformacaoBancaria.Conta__r.IdExterno__c).Id;
                contratanteWrapper.sfInformacaoBancaria.Conta__r = null;
                //PLV-4440 - INICIO
                contratanteWrapper.sfInformacaoBancaria.IdExterno__c = InformacaoBancariaBO.getIdExterno(contratanteWrapper.sfInformacaoBancaria, mBancos);
                if(String.isNotBlank(contratanteWrapper.sfInformacaoBancaria.IdExterno__c))
                mapInformacaoBancaria.put(contratanteWrapper.sfInformacaoBancaria.IdExterno__c,contratanteWrapper.sfInformacaoBancaria);
                //PLV-4440 - FIM
            }
            
            //PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
            
            // RVI-288 - INICIO Ajuste para validar se não há informações de cartão
            if (!String.isEmpty(contratanteWrapper.sfCartaoCredito.NumeroCartao__c) || !String.isEmpty(contratanteWrapper.sfCartaoCredito.Ticket__c)) {//RVI-289
            // RVI-288 - FIM
                
                //PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF	
                //PLV-4588 FIX 1 - INÍCIO
                Account conta = mapContas.get(contratanteWrapper.sfCartaoCredito.Conta__r.IdExterno__c);
                if(conta == null){
                    conta = [SELECT Id FROM Account WHERE IdExterno__c = :contratanteWrapper.sfCartaoCredito.Conta__r.IdExterno__c];
                }
                
                contratanteWrapper.sfCartaoCredito.Conta__c = conta.Id;
                //contratanteWrapper.sfCartaoCredito.Conta__c = mapContas.get(contratanteWrapper.sfCartaoCredito.Conta__r.IdExterno__c).Id;
                //PLV-4588 FIX 1 - FIM
                contratanteWrapper.sfCartaoCredito.Conta__r = null;
                contratanteWrapper.sfCartaoCredito.IdExterno__c = CartaoCreditoTriggerHandler.getIdExterno(contratanteWrapper.sfCartaoCredito);
                listCartaoCredito.add(contratanteWrapper.sfCartaoCredito);
            }
        }
        //PLV-2710 - FIM
        
        //// Atribui Id da proposta nas criticas da proposta
        //for(CriticaProposta__c criticaProposta : this.proposta.propostaWrapper.criticas){
        //    criticaProposta.Id = null;
        //    criticaProposta.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
        //    listCriticaProposta.add(criticaProposta);
        //}
        
        // Insere os contratantes da proposta
        try{
            //PLV-4440 - INICIO
            if(!mapInformacaoBancaria.isEmpty() && mapInformacaoBancaria.values().size()>0)
            upsert mapInformacaoBancaria.values() IdExterno__c;
            if(listCartaoCredito!=null && listCartaoCredito.size()>0)
            upsert listCartaoCredito IdExterno__c;
            //PLV-4440 - FIM
            
            
            // 2666 - FIM
        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Inserir Informações Bancarias / Cartão de Crédito da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        //Atribui id da proposta nos contratantes e os Id de Cartão e Informações bancarias
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper )
        {
            contratanteWrapper.sfContratante.Id = null;
            contratanteWrapper.sfContratante.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
            // PLV-4675 INICIO
            contratanteWrapper.sfContratante.Forma_de_receber_apolice__c = this.proposta.propostaWrapper.sfProposta.FormaReceberApolice__c;
            // PLV-4675 FIM
            listContratanteProposta.add(contratanteWrapper.sfContratante);
            
            contratanteWrapper.sfContratante.InformacaoBancaria__c = contratanteWrapper.sfInformacaoBancaria.Id;
            contratanteWrapper.sfContratante.CartaoCredito__c = contratanteWrapper.sfCartaoCredito.Id;
        }
        
        // Insere as remuneracoes da proposta
        try{
           
            insert listContratanteProposta;
            insert listRemuneracaoProposta;
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
                // 2666 - INICIO
                //favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta.CorretorLider__c = false;
                // 2666 - FIM
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
        system.debug('PropostaGenerica - InserirRegistros - Proposta: ' + JSON.serialize(proposta)); //PLV-3285
      
        return proposta;
    }
    
    //PLV-2826 - INICIO - Criar oportunidade sem conta
    //O método abaixo está preparado para atender o produto Vida Individual onde teremos apenas uma pessoa como
    //Contratante e Segurado. Será necessário definir uma chave de comparação para identificar
    //os objetos do Orçamento que devem ser atualizados a partir das informações da Proposta para atender ao Vida em Grupo. 
    @TestVisible
    private Opportunity atualizaOrcamento(EmissaoTO.PayloadTO payloadProposta, Opportunity orcamentoObj){
        
        if(orcamentoObj.RecordTypeId != RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id)  return orcamentoObj;
        
        Set<Id> setOrcamento = new Set<Id>();
        setOrcamento.add(orcamentoObj.Id);
        //setOrcamento.add(this.proposta.propostaWrapper.sfProposta.OpportunityId);
        List<SeguradoOrcamento__c> listaSeguradosQuery = new List<SeguradoOrcamento__c>();
        List<SeguradoOrcamento__c> listaSeguradosAtualizados = new List<SeguradoOrcamento__c>();
        Map<Id, ContratanteOrcamento__c> mapContratantesAtualizados = new Map<Id, ContratanteOrcamento__c>();
        Map<Id, Opportunity> mapOrcamentoAtualizados = new Map<Id, Opportunity>();
        
        // PLV-3285 Inicio - Não precisa criar a conta, porque o metodo gerarConta já o faz!
        /*List<Account> listaContasProposta = new List<Account>();

//for(EmissaoTO.ContratanteTO contratanteProp  : payloadProposta.proposta.contratantes){

system.debug('PLV_2826 - payloadProposta.proposta.contratantes: ' + payloadProposta.proposta.contratantes);
system.debug('PLV_2826 - contratanteProp.pessoa: ' + contratanteProp.pessoa);
system.debug('PLV_2826 - contratanteProp.pessoa.dadosPessoaFisica: ' + contratanteProp.pessoa.dadosPessoaFisica);
system.debug('PLV_2826 - contratanteProp.pessoa.dadosPessoaFisica.numeroCpf: ' + contratanteProp.pessoa.dadosPessoaFisica.numeroCpf);
system.debug('PLV_2826 - contratanteProp.pessoa.dadosPessoaFisica.digitoCpf: ' + contratanteProp.pessoa.dadosPessoaFisica.digitoCpf);

Account contaOrcamento =  preencherDadosContaPessoaFisica(contratanteProp.pessoa);
listaContasProposta.add(contaOrcamento);                                  
}

System.debug('listaContasProposta: ' + JSON.serialize(listaContasProposta));

upsert listaContasProposta IdExterno__c;*/
        
        // Vida Individual é apenas um contratante então usa o primeiro contrante como referência
        //PLV-4440 - INICIO
        //Account contaFisica = preencherDadosContaPessoaFisica(payloadProposta.proposta.contratantes[0].pessoa);
        //PLV-4449 - INICIO - PEDRO AUGSUTO BRAZ - SYS4B
        //PLV-4449 - INICIO - FIX
        // Account contaFisica = new Account();
        // if('Individual'.equalsIgnoreCase(payLoadProposta.proposta.segmento)){
        //     contaFisica = preencherDadosContaPessoaFisica(payloadProposta.proposta.contratantes[0].pessoa,payloadProposta);
        // }else if('Viagem'.equalsIgnoreCase(payLoadProposta.proposta.segmento)){
        //     EmissaoTO.GrupoTO grupo = new EmissaoTO.GrupoTO();
        //     EmissaoTO.PessoaTO pessoa = new EmissaoTO.PessoaTO();
        //     for(EmissaoTO.GrupoTO gr: payloadProposta.proposta.contratantes[0].grupos){
        //         if(gr.numero=='1'){grupo = gr; break;}
        //     }
        //     for(EmissaoTO.SeguradoTO seg : grupo.segurados){
        //         if(seg.numero=='1'){pessoa = seg.pessoa; break;}
        //     }
        //     if(pessoa != null) contaFisica = preencherDadosContaPessoaFisica(pessoa,payloadProposta);
        // }
        Account contaFisica = preencherDadosContaPessoaFisica(payloadProposta.proposta.contratantes[0].pessoa,payloadProposta);
        //PLV-4449 - FIM - FIX
        //PLV-4449 - FIM - PEDRO AUGSUTO BRAZ - SYS4B

        if(String.isBlank(contaFisica.IdExterno__c)) throw new PropostaBuilderException('Origem: atualizaOrcamento >> IdExterno__c da conta NULO');
        
        upsert contaFisica  IdExterno__c;
        //PLV-4440 - FIM
        contaFisica = [SELECT Id FROM Account WHERE IdExterno__c = :contaFisica.IdExterno__c];
        
        listaSeguradosQuery = daoOrcamento.buscarVidasOrcamentoPorOrcamento(setOrcamento);
        
        if(listaSeguradosQuery.IsEmpty()){
            system.debug('orcamentoObj.ContratantesOrcamento__r: ' + orcamentoObj.ContratantesOrcamento__r);
            for(contratanteOrcamento__c contratante : orcamentoObj.ContratantesOrcamento__r){
                contratante.Conta__c = contaFisica.Id;
                mapContratantesAtualizados.put(contratante.id, contratante);
            }
            
            orcamentoObj.AccountId = contaFisica.Id;
            
            mapOrcamentoAtualizados.put(orcamentoObj.id, orcamentoObj);
            
        }else{
            
            for(SeguradoOrcamento__c seguradoOrcamento : listaSeguradosQuery){
                
                if(seguradoOrcamento.Conta__c == null){
                    seguradoOrcamento.Conta__c = contaFisica.Id;
                    system.debug('PLV_2826 - depois de atualizar o segurado - seguradoOrcamento.Conta__c: ' + seguradoOrcamento.Conta__c); 
                    
                    listaSeguradosAtualizados.add(seguradoOrcamento);
                }
                
                if(seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Conta__c == null){	
                    seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Conta__c = contaFisica.Id; 
                    system.debug('PLV_2826 - depois de atualizar o contratante - ContratanteOrcamento__r.Conta__c: ' + seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Conta__c);
                    
                    mapContratantesAtualizados.put(seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__c, 
                                                   seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r);
                }
                
                if(seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.AccountId == null){
                    seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.AccountId = contaFisica.Id;
                    
                    system.debug('PLV_2826 - depois de atualizar - Orcamento__r.AccountId: ' + seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r.AccountId);
                    
                    mapOrcamentoAtualizados.put(
                        seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c,
                        seguradoOrcamento.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__r
                    );
                }
            }
        }
        
        if(!listaSeguradosAtualizados.IsEmpty()) {
            upsert listaSeguradosAtualizados; 
        	system.debug('listaSeguradosAtualizados depois'+listaSeguradosAtualizados);
            System.debug('Renato = '+JSON.serialize(mapContratantesAtualizados));
        }
        if(!mapContratantesAtualizados.IsEmpty()) {
            upsert mapContratantesAtualizados.values(); 
            system.debug('mapContratantesAtualizados'+mapContratantesAtualizados.values());
        }
        if(!mapOrcamentoAtualizados.IsEmpty()){ 
            upsert mapOrcamentoAtualizados.values();
            system.debug('mapOrcamentoAtualizados'+mapOrcamentoAtualizados.values());
        }
        
        //PLV-3285 - FIM - MVP A Transmissão da proposta
        
        orcamentoObj = daoOrcamento.obterOportunidadesPorNumeroComPrefixo(payloadProposta.proposta.numeroOrcamento);
        
        return orcamentoObj;
        
    }    
    //PLV-2826 - FIM - Criar oportunidade sem conta
    
    /* ---------------------------------- FIM INTERFACE ----------------------------------------------------------- */
    
    
    /* ---------------------------------- WRAPPERS ---------------------------------------------------------------- */
    
    // INICIO | PLV-2402-30
    /*
* @author Everymind - Sprint 30 - (hackathon)
* @Descrição: cria o wrapper de critícas da proposta de anaise
*/
    private void popularCriticaAnaliseWrapper(EmissaoTO.AnaliseTO analise, CriticaProposta__c criticaWrapper)
    {
        //mapeira Retornos - Analise
        popularCriticaPropostaAnalise(analise, criticaWrapper);
    }
    
    /*
* @author Everymind - Sprint 30 - (hackathon)
* @Descrição: cria o wrapper de critícas da proposta de aviso
*/
    private void popularCriticaAvisoWrapper(EmissaoTO.AvisoTO aviso, CriticaProposta__c criticaWrapper)
    {
        //mapeira Retornos -aviso
        popularCriticaPropostaAviso(aviso, criticaWrapper);
    }
    
    /*
* @author Everymind - Sprint 30 - (hackathon)
* @Descrição: cria o wrapper de critícas da proposta de recusa
*/
    private void popularCriticaRecusaWrapper(EmissaoTO.RecusaTO recusa, CriticaProposta__c criticaWrapper)
    {
        //mapeira Retornos -recusa
        popularCriticaPropostaRecusa(recusa, criticaWrapper);
    }
    
    /*
* @author Everymind - Sprint 30 - (hackathon)
* @Descrição: cria o wrapper de critícas da proposta de pendencia
*/
    private void popularCriticaPendenciaWrapper(EmissaoTO.PendenciaTO pendencia, CriticaProposta__c criticaWrapper)
    {
        //mapeira Retornos -pendencia
        popularCriticaPropostaPendecia(pendencia, criticaWrapper);
    }
    // FIM | PLV-2402-30
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: inclui no wrapper
*/
    private void popularPessoaWrapper(List<EmissaoTO.PessoaTO> pessoas, List<Proposta.PessoaWrapper> listPessoasWrapper)
    {
        // 2610 - INICIO
        for(EmissaoTO.PessoaTO pessoa : pessoas)
        {
            system.debug('pessoa: ' + pessoa);
            
            String idExterno = montarChavePessoa(pessoa);
            
            system.debug('idExterno: ' + idExterno);
            
            // verifica se as contas do mapa estão no payload 
            //if(mapContas.get(idExterno) == null){
            
            system.debug('Dentro do If mapContas.get >> mapContas.get == null:');
            
            // cria a conta 
            Proposta.PessoaWrapper pessoaWrapper = new Proposta.PessoaWrapper();
            pessoaWrapper.sfConta = new Account();
            
            if(idExterno.length() == 11){
                system.debug('Dentro do IF idExterno.length() == 11');
                
                pessoaWrapper.sfConta = preencherDadosContaPessoaFisica(pessoa,null); //PLV-4440 - INICIO/FIM
                
                system.debug('pessoaWrapper.sfConta:' + pessoaWrapper.sfConta);
                
            }else if(idExterno.length() == 14)
            {    
                system.debug('Dentro do IF idExterno.length() == 14');
                pessoaWrapper.sfConta = boConta.preencherDadosContaPessoaJuridica(null, pessoa.nome, idExterno);
                system.debug('pessoaWrapper.sfConta:' + pessoaWrapper.sfConta);
            }
            
            listPessoasWrapper.add(pessoaWrapper);
            
            system.debug('listPessoasWrapper:' + listPessoasWrapper);
            //}
        }
        // 2610 - FIM
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: inclui no wrapper
*/
    private void popularGarantiasWrapper(List<GarantiaOrcamento__c> garantias, List<Proposta.GarantiaWrapper> listGarantiasWrapper, String nomeGrupo) //PLV-4340 - INICIO/FIM
    {
        for(GarantiaOrcamento__c garantia : garantias)
        {
            Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
            garantiaWrapper.sfGarantiaProposta = new GarantiaProposta__c();
            this.popularGarantiaProposta(garantia, garantiaWrapper.sfGarantiaProposta, nomeGrupo); //PLV-4340 - INICIO/FIM
            
            listGarantiasWrapper.add(garantiaWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
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
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: inclui no wrapper
*/
    private void popularGarantiasGrupoWrapper(List<GarantiaGrupoOrcamento__c> garantias, List<Proposta.GarantiaWrapper> listGarantiasWrapper) //PLV-4340 - INICIO/FIM
    {
        for(GarantiaGrupoOrcamento__c garantia : garantias)
        {
            Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
            garantiaWrapper.sfGarantiaGrupoProposta = new GarantiasGrupoProposta__c();
            this.popularGarantiaGrupoProposta(garantia, garantiaWrapper.sfGarantiaGrupoProposta); //PLV-4340 - INICIO/FIM
            listGarantiasWrapper.add(garantiaWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: inclui no wrapper
*/
    private void popularGarantiasSeguradoWrapper(List<GarantiaSeguradoOrcamento__c> garantias, List<Proposta.GarantiaWrapper> listGarantiasWrapper)
    {
        for(GarantiaSeguradoOrcamento__c garantia : garantias)
        {
            Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
            garantiaWrapper.sfGarantiaSeguradoProposta = new GarantiaSeguradoProposta__c();
            this.popularGarantiaSeguradoProposta(garantia, garantiaWrapper.sfGarantiaSeguradoProposta);
            listGarantiasWrapper.add(garantiaWrapper);
        }
    }
    
    private void popularGarantiasSeguradoViagemWrapper(List<GarantiaGrupoOrcamento__c> garantiasGrupoOrcamento, List<Proposta.GarantiaWrapper> listGarantiasWrapper) //PLV-4340 - INICIO/FIM
    {
        
        system.debug('Dentro do popularGarantiasSeguradoViagemWrapper');
        
        for(GarantiaGrupoOrcamento__c garantia : garantiasGrupoOrcamento)
        {
            Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
            garantiaWrapper.sfGarantiaSeguradoProposta = new GarantiaSeguradoProposta__c();
            
            system.debug('popularGarantiasSeguradoViagemWrapper - garantia: ' + garantia);
            
            this.popularGarantiaSeguradoPropostaViagem(garantia, garantiaWrapper.sfGarantiaSeguradoProposta); //PLV-4340 - INICIO/FIM
            
            system.debug('popularGarantiasSeguradoViagemWrapper - garantiaWrapper:' + garantiaWrapper);
            
            listGarantiasWrapper.add(garantiaWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: inclui no wrapper
*/
    public void gerarRemuneracaoPropostaWrappersComFavorecidos(List<RemuneracaoOrcamento__c> remuneracoes, List<Proposta.RemuneracaoPropostaWrapper> listRemuneracaoPropostaWrappers, String tipoProposta, map<String, String> mapRetencaoComissao, List<EmissaoTO.RemuneracaoTO> remuneracoesPropostaTO) //RVI-49 - INICIO/FIM ----- AV-614 - INICIO/FIM //II-167 INICIO/FIM
    {
        // monta o mapa com os favorecidos das remunerações obtidas no payload recebido
        Map<String, List<EmissaoTO.FavorecidoTO>> mapFavorecidosRemuneracoesTO = new Map<String, List<EmissaoTO.FavorecidoTO>>();
        //AV-614 - INICIO FOI NECESSÁRIO COMENTAR ESSE BLOCO PARA QUE A NOVA LOGICA FUNCIONE
        //Map<String, Decimal> mapRetencao = new Map<String, Decimal>(); // PLV-4470 INICIO/FIM
        for(EmissaoTO.RemuneracaoTO remTO : payload.proposta.remuneracoes){
            if(remTO.favorecidos.size() > 0){
                mapFavorecidosRemuneracoesTO.put(remTO.tipoRemuneracao, remTO.favorecidos);
                //mapRetencao.put(remTO.tipoRemuneracao,(remTO.retencao==null || remTO.retencao < 0 || remTO.retencao > 100 ?0:remTO.retencao)); // PLV-4470 INICIO/FIM
            }
        }
        //AV-614 - FIM
        
        // Gera as remuneracoes e seus favorecidos
        System.debug( ' @@@3285 remuneracoex:> ' + remuneracoes);
        //AV-614 - INICIO
        String produtoCanal = mapRetencaoComissao.get('produto');
        System.debug('Alexandre produtoCanal: ' + produtoCanal);
        List<RetencaoComissaoProduto__c> listRetencao = [SELECT Id, ProdutoCanal__r.Produto__r.ProductCode, MeioComercializacao__c, SusepCorretor__r.Name, PercentualRetencao__c, AplicarParaRenovacao__c 
        FROM RetencaoComissaoProduto__c
        WHERE ProdutoCanal__r.Produto__r.ProductCode =: produtoCanal];
        System.debug('listRetencao: ' + listRetencao);
        if(listRetencao.size() > 0){
            for(RetencaoComissaoProduto__c retencao : listRetencao){
                if(retencao.SusepCorretor__r.Name == mapRetencaoComissao.get('susep')){
                    if(tipoProposta == 'Renovacao'){
                        this.retencaoComissao = retencao.AplicarParaRenovacao__c == true ? retencao.PercentualRetencao__c : 0;
                        break;
                    }else{
                        this.retencaoComissao = retencao.PercentualRetencao__c;
                        System.debug('entrou no if de susep: ' + retencaoComissao);
                        break;
                    }
                }else{
                    this.retencaoComissao = 0;
                }
            }
            for(RetencaoComissaoProduto__c retencao : listRetencao){
                if(retencaoComissao == 0){
                    if(retencao.MeioComercializacao__c == mapRetencaoComissao.get('meioComercializacao') && (retencao.SusepCorretor__r.Name == '' || retencao.SusepCorretor__r.Name == null)){ //AV-614 FIX 01 INICIO/FIM
                        if(tipoProposta == 'Renovacao'){
                            this.retencaoComissao = retencao.AplicarParaRenovacao__c == true ? retencao.PercentualRetencao__c : 0;
                            break;
                        }else{
                            this.retencaoComissao = retencao.PercentualRetencao__c;
                            System.debug('entrou no if de meio: ' + retencaoComissao);
                            break;
                        }
                    }else{
                        this.retencaoComissao = 0;
                    }
                }
            }
            for(RetencaoComissaoProduto__c retencao : listRetencao){
                if(retencaoComissao == 0){
                    if(retencao.ProdutoCanal__r.Produto__r.ProductCode == mapRetencaoComissao.get('produto') && (retencao.MeioComercializacao__c == '' || retencao.MeioComercializacao__c == null) && (retencao.SusepCorretor__r.Name == '' || retencao.SusepCorretor__r.Name == null)){ //AV-614 FIX 01 INICIO/FIM
                        if(tipoProposta == 'Renovacao'){
                            this.retencaoComissao = retencao.AplicarParaRenovacao__c == true ? retencao.PercentualRetencao__c : 0;
                            break;
                        }else{
                            this.retencaoComissao = retencao.PercentualRetencao__c;
                            System.debug('entrou no if de produto: ' + retencaoComissao);
                            break;
                        }
                    }else{
                        this.retencaoComissao = 0;
                    }
                }
            }
        }
        System.debug('retencaoComissao: ' + retencaoComissao);
        //AV-614 - FIM
        //II-167 INICIO
        Double bonusCampanha;
        for(RemuneracaoOrcamento__c remuneracao : remuneracoes)
        {
            for(EmissaoTO.RemuneracaoTO remProp : remuneracoesPropostaTO){
                if(remuneracao.TipoRemuneracao__r.Codigo__c == remProp.tipoRemuneracao){
                    bonusCampanha = remProp.bonusCampanha;
                }
            }
            // Instancias
            Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper = new Proposta.RemuneracaoPropostaWrapper();
            remuneracaoPropostaWrapper.sfRemuneracaoProposta = new RemuneracaoProposta__c();
            
            // Popula a remuneracao da proposta
            this.popularRemuneracaoProposta(remuneracao, remuneracaoPropostaWrapper.sfRemuneracaoProposta, tipoProposta, retencaoComissao, bonusCampanha); //RVI-49 - INICIO/FIM -------- AV-614 - INICIO/FIM
        //II-167 FIM
             // PLV-4470 INICIO
        try {
             System.debug('PLV-4470 '+remuneracaoPropostaWrapper.sfRemuneracaoProposta.TipoRemuneracao__c);
            
             if ( remuneracaoPropostaWrapper.sfRemuneracaoProposta.TipoRemuneracao__c != null ) {
                List <TipoRemuneracao__c>  tipoRemuneracaoList = [ select Codigo__c from TipoRemuneracao__c  where id = :remuneracaoPropostaWrapper.sfRemuneracaoProposta.TipoRemuneracao__c];
                System.debug('PLV-4470 '+tipoRemuneracaoList[0].Codigo__c);
                //AV-614 - INICIO FOI NECESSÁRIO COMENTAR ESSE BLOCO PARA QUE A NOVA LOGICA FUNCIONE
                //System.debug('PLV-4470 '+ mapRetencao);               
                // if ( !tipoRemuneracaoList.isEmpty() &&
                //       tipoRemuneracaoList[0].Codigo__c == 'COR' &&
                //       mapRetencao.containsKey(tipoRemuneracaoList[0].Codigo__c )) {
                //          remuneracaoPropostaWrapper.sfRemuneracaoProposta.Porcentagem_de_Retencao__c = mapRetencao.get(tipoRemuneracaoList[0].Codigo__c);
                //          System.debug('PLV-4470 '+remuneracaoPropostaWrapper.sfRemuneracaoProposta.Porcentagem_de_Retencao__c);
                //         }
                if(!tipoRemuneracaoList.isEmpty() && tipoRemuneracaoList[0].Codigo__c == 'COR') {
                    remuneracaoPropostaWrapper.sfRemuneracaoProposta.Porcentagem_de_Retencao__c = retencaoComissao;
                    System.debug('retencaoComissao AV-614: ' + retencaoComissao);
                        }
                //AV-614 - FIM
                //RVI-49 - FIX01 - INICIO        
                //if ( !tipoRemuneracaoList.isEmpty() && tipoRemuneracaoList[0].Codigo__c == 'AGE' && tipoProposta == 'Renovacao') {
                //    remuneracaoPropostaWrapper.sfRemuneracaoProposta.Percentual__c = 0;
                //    System.debug('RVI-49 '+remuneracaoPropostaWrapper.sfRemuneracaoProposta.Percentual__c);
                //}        
                //RVI-49 - FIX01 - FIM
                //RVI-168 FIM
             }
            } catch ( Exception e ) {
                 System.debug('ERRO PLV-4470 ' + e.getMessage() + e.getStackTraceString());
            }
            // PLV-4470 FIM
            TipoRemuneracao__c tipo = mapTiposRemuneracao.get(remuneracao.TipoRemuneracao__c);
            
            if(tipo != null && !(tipo.Name.toUpperCase() == 'AGENCIAMENTO' && remuneracao.Percentual__c == 0)){ //PLV-5101
                
                List<EmissaoTO.FavorecidoTO> favorecidos = mapFavorecidosRemuneracoesTO.get(tipo.Codigo__c);
                // gera os favorecidos da remuneracao
                remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper = new List<Proposta.FavorecidoRemuneracaoWrapper>();
                this.gerarFavorecidosRemuneracaoPropostaWrapper(favorecidos, remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper);
            }
            
            
            listRemuneracaoPropostaWrappers.add(remuneracaoPropostaWrapper);
        }
        System.debug('carlos remuneracao');
        System.debug(listRemuneracaoPropostaWrappers);
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: inclui no wrapper
*/
    private void gerarFavorecidosRemuneracaoPropostaWrapper(List<EmissaoTO.FavorecidoTO> favorecidos, List<Proposta.FavorecidoRemuneracaoWrapper> listFavorecidoRemuneracaoWrapper)
    {
        // Gera os favorecidos da remuneracao
        System.debug( ' @@@3285 Favorecidox:> ' + favorecidos);
        for(EmissaoTO.FavorecidoTO favorecido : favorecidos)
        {
            // Gera o favorecido da remuneracao
            Proposta.FavorecidoRemuneracaoWrapper favorecidoRemuneracaoPropostaWrapper = new Proposta.FavorecidoRemuneracaoWrapper();
            favorecidoRemuneracaoPropostaWrapper.sfFavorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c();
            
            this.popularFavorecidoRemuneracaoProposta(favorecido, favorecidoRemuneracaoPropostaWrapper.sfFavorecidoRemuneracaoProposta);
            listFavorecidoRemuneracaoWrapper.add(favorecidoRemuneracaoPropostaWrapper);
        }
    }
    
    /* ---------------------------------- MODELOS ----------------------------------------------------------------- */
    
    // INICIO | PLV-2402-30
    /*
*  @author Everymind - Sprint 30
*  @Descrição: popula os criticas (analise) da nova proposta baseados no payload
*/
    private void popularCriticaPropostaAnalise(EmissaoTO.AnaliseTO analise, CriticaProposta__c criticaProposta)
    {
        try
        {
            //criticaProposta.Proposta__c              = Id.valueOf(propostaId);
            criticaProposta.Tipo__c                  = TIPO_CRITICA_ANALISES;
            criticaProposta.Status__c                = 'Não iniciada'; //PLV-4790 FIX 5 INICIO/FIM
            criticaProposta.Origem__c                = ORIGEM;
            criticaProposta.Codigo__c                = String.valueOf(analise.codigo);
            criticaProposta.Area__c                  = analise.area;
            criticaProposta.Procedimento__c          = analise.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            criticaProposta.Descricao__c             = analise.descricao;
            criticaProposta.Severidade__c            = analise.severidade;
            // PLV-4471 
            criticaProposta.Integracao__c            = analise.integracao;
            //PLV-4350 INICIO
            criticaProposta.MomentoAnalise__c        = analise.momentoAnalise;
            //PLV-4350 FIM

            //PLV-4365 INICIO
            criticaProposta.Acao__c                  = analise.acao; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            //PLV-4365 FIM
            criticaProposta.Setor__c                 = analise.setor; //PLV-4790 INICIO/FIM
            
            if(analise.mensagens != null)
            {
                // INICIO | PLV-4647-VI-Guilherme Brito
                criticaProposta.MensagemRepresentante__c = analise.mensagens.representante;
                criticaProposta.MensagemInterna__c       = analise.mensagens.interna;
                criticaProposta.MensagemCliente__c       = analise.mensagens.cliente;
                //FIM| PLV-4647-VI-Guilherme Brito
                DateTime now = System.now();//PLV-4854-FIX1 - inicio/fim
                criticaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + analise.mensagens.interna + '\n'+string.valueOf( criticaProposta.ErrosRecalculo__c); //PLV-4854-FIX1 - inicio/fim                 

            }
        }
        catch(Exception e){
            throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de critica proposta - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 30
*  @Descrição: popula os criticas (Aviso) da nova proposta baseados no payload
*/
    private void popularCriticaPropostaAviso(EmissaoTO.AvisoTO aviso, CriticaProposta__c criticaProposta)
    {
        try
        {
            //criticaProposta.Proposta__c              = Id.valueOf(propostaId);
            criticaProposta.Tipo__c                  = TIPO_CRITICA_AVISOS;
            criticaProposta.Status__c                = 'Cancelada'; //PLV-4790 FIX 2 INICIO/FIM
            criticaProposta.Origem__c                = ORIGEM;
            criticaProposta.Codigo__c                = String.valueOf(aviso.codigo);
            criticaProposta.Area__c                  = aviso.area;
            criticaProposta.Procedimento__c          = aviso.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            criticaProposta.Descricao__c             = aviso.descricao;
            criticaProposta.Severidade__c            = aviso.severidade;
            
            if(aviso.mensagens != null)
            {
                //INICIO | PLV-4647-VI-Guilherme Brito
                criticaProposta.MensagemRepresentante__c = aviso.mensagens.representante;
                criticaProposta.MensagemInterna__c       = aviso.mensagens.interna;
                criticaProposta.MensagemCliente__c       = aviso.mensagens.cliente;
                //FIM| PLV-4647-VI-Guilherme Brito
                DateTime now = System.now();//PLV-4854-FIX1 - inicio/fim
                criticaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + aviso.mensagens.interna + '\n'+string.valueOf( criticaProposta.ErrosRecalculo__c); //PLV-4854-FIX1 - inicio/fim                 
            
            }
        }
        catch(Exception e){
            throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de critica proposta - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 30
*  @Descrição: popula os criticas (Recusa) da nova proposta baseados no payload
*/
    private void popularCriticaPropostaRecusa(EmissaoTO.RecusaTO recusa, CriticaProposta__c criticaProposta)
    {
        try
        {
            //criticaProposta.Proposta__c              = Id.valueOf(propostaId);
            criticaProposta.Tipo__c                  = TIPO_CRITICA_RECUSAS;
            criticaProposta.Status__c                = 'Pendente';
            criticaProposta.Origem__c                = ORIGEM;
            criticaProposta.Codigo__c                = String.valueOf(recusa.codigo);
            criticaProposta.Area__c                  = recusa.area;
            criticaProposta.Procedimento__c          = recusa.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            criticaProposta.Descricao__c             = recusa.descricao;
            criticaProposta.Severidade__c            = recusa.severidade;
            
            if(recusa.mensagens != null)
            {
                //INICIO | PLV-4647-VI-Guilherme Brito
                criticaProposta.MensagemRepresentante__c = recusa.mensagens.representante;
                criticaProposta.MensagemInterna__c       = recusa.mensagens.interna;
                criticaProposta.MensagemCliente__c       = recusa.mensagens.cliente;
                //FIM| PLV-4647-VI-Guilherme Brito
                DateTime now = System.now();//PLV-4854-FIX1 - inicio/fim
                criticaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + recusa.mensagens.interna + '\n'+string.valueOf( criticaProposta.ErrosRecalculo__c); //PLV-4854-FIX1 - inicio/fim                 
            }
        }
        catch(Exception e){
            throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de critica proposta - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 30
*  @Descrição: popula os criticas (Pendecia) da nova proposta baseados no payload
*/
    private void popularCriticaPropostaPendecia(EmissaoTO.PendenciaTO pendecia, CriticaProposta__c criticaProposta)
    {
        try
        {
            //criticaProposta.Proposta__c              = Id.valueOf(propostaId);
            criticaProposta.Tipo__c                  = TIPO_CRITICA_PENDENCIAS;  //PLV-4790 FIX 11
            criticaProposta.MomentoAnalise__c        = pendecia.momentoAnalise; //PLV-4790 FIX 11
            criticaProposta.Status__c                = 'Não iniciada'; //PLV-4790 FIX 5 INICIO/FIM
            criticaProposta.Origem__c                = ORIGEM;
            criticaProposta.Codigo__c                = String.valueOf(pendecia.codigo);
            criticaProposta.Area__c                  = pendecia.area;
            criticaProposta.Procedimento__c          = pendecia.procedimento; //INICIO/FIM | PLV-4647-VI-Guilherme Brito
            criticaProposta.Descricao__c             = pendecia.descricao;
            criticaProposta.Severidade__c            = pendecia.severidade;
            criticaProposta.Setor__c                 = pendecia.setor; //PLV-4790 INICIO/FIM
            
            if(pendecia.mensagens != null)
            {
                // INICIO | PLV-4647-VI-Guilherme Brito
                criticaProposta.MensagemRepresentante__c = pendecia.mensagens.representante;
                criticaProposta.MensagemInterna__c       = pendecia.mensagens.interna;
                criticaProposta.MensagemCliente__c       = pendecia.mensagens.cliente;
                // FIM| PLV-4647-VI-Guilherme Brito
                DateTime now = System.now();//PLV-4854-FIX1 - inicio/fim
                criticaProposta.ErrosRecalculo__c = now.format( 'dd/MM/yyyy HH:mm:ss' ) + ': ' + pendecia.mensagens.interna + '\n'+string.valueOf( criticaProposta.ErrosRecalculo__c); //PLV-4854-FIX1 - inicio/fim                 
            }
        }
        catch(Exception e){
            throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de critica proposta - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    // FIM | PLV-2402-30
    //INICIO | PLV-2610-SNIPER
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularProposta(Opportunity orcamento, Quote proposta, EmissaoTO.PayloadTO payloadTO)
    {

        System.debug('***payloadTO***' + payloadTO);
        System.debug('***jsonpayloadTO***' + JSON.serialize(payloadTO));
        //PLV-4612-FIX INICIO
        //RVI-312 INICIO
        if(payloadTO.proposta.tipoSeguro == 'Renovacao'){
            // RVI-312-FIX01 - INICIO
            List<Decimal> agravosOrcamento = propostaDescontoAgravo(payloadTO.proposta.numeroOrcamento);
            if (agravosOrcamento != null && agravosOrcamento.get(0) != null)
                proposta.DescontoAgravoPercentualFormaPagto__c = agravosOrcamento.get(0);
            if (agravosOrcamento != null && agravosOrcamento.get(1) != null)
                proposta.DescontoAgravoMonetarioFormaPagto__c = agravosOrcamento.get(1);
            // RVI-312-FIX01 - FIM
        }
        //RVI-312 FIM
        //PLV-4612-FIX FIM
        
        try
        {
            // PLV-4488 INICIO - PREENCHER CAMPO CONTRATO ORIGINAL
            System.debug('INICIANDO PREENCHIMENTO DO CONTRATO ORIGINAL');
            // PLV-4488 FIX
            List<Contract> listOldContract = null;
            if(payloadTO != null && payloadTO.proposta != null && payloadTO.proposta.contratoOriginal != null){
                segmento = String.isNotBlank(segmento) ? segmento : payloadTO.proposta.segmento;//PLV-4701 - INICIO/FIM
                System.debug('Payload valido');
                EmissaoTO contratoOriginal =  payloadTO.proposta.contratoOriginal;
                if( contratoOriginal.empresa != null &&
                contratoOriginal.sucursal != null &&
                contratoOriginal.ramo != null &&
                contratoOriginal.apolice != null &&
                contratoOriginal.endosso != null){
                    
                    System.debug('Campos de contrato original validos');
                    String nomeContratoOriginal = contratoOriginal.empresa.trim() + '-' + contratoOriginal.sucursal + '-' + contratoOriginal.ramo + '-' + contratoOriginal.apolice.trim().leftPad(9,'0') + '-' + contratoOriginal.endosso.trim();
                    System.debug('nomeContratoOriginal ' + nomeContratoOriginal);
                    // PLV-4488 FIX - Ajuste na SOQL
                    listOldContract = [SELECT Id, TipoContrato__c, PorQuantoTempoQuerGarantirRenda__c, VigenciaFinal__c FROM Contract WHERE Name =: nomeContratoOriginal];
                    proposta.ContractId = listOldContract != null && listOldContract.size() > 0 ? listOldContract.get(0).Id : null;
                    // MOCK PARA SER RETIRADO QUANDO O CAMPO SiglaTipoEndosso__c FOR PREENCHIDO PELO PORTAL
                    //proposta.TipoContrato__c = listOldContract[0].TipoContrato__c; //PLV4725
                    // if(listOldContract != null && listOldContract.size() > 0 && listOldContract.get(0).PorQuantoTempoQuerGarantirRenda__c == '24'){
                    //     proposta.SiglaTipoEndosso__c = 'CAD';
                    // }else{
                    //     proposta.SiglaTipoEndosso__c = 'PRM';
                    // }
                    // PLV-4488 FIX
                    if(listOldContract != null && listOldContract.size() > 0){
                        // PLV-4488 FIX INICIO
                        proposta.VigenciaInicial__c = System.today();
                        proposta.VigenciaFinal__c = listOldContract[0].VigenciaFinal__c;
                        // PLV-4488 FIX FIM
                        proposta.PorQuantoTempoQuerGarantirRenda__c = listOldContract[0].PorQuantoTempoQuerGarantirRenda__c;
                    }
                    // PLV-4488 FIX
                    System.debug('Tentando preencher');
                    System.debug(proposta.ContractId);
                    try{
                        proposta.email__c = payloadTO.proposta.contratantes[0].pessoa.email;
                    }catch(Exception ee){
                        System.debug('FALHA AO PEGAR EMAIL DO PAYLOAD');
                    }
                }

            }
            
            // PLV-4488 FIM - 
            system.debug('Diego ProductCode: ' + payloadTO.proposta.codigoProdutoVida);
            //PLV_3196 - INICIO - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
            List<GarantiaProduto__c> lGarantiaProduto = [SELECT Id, RamoSeguro__c, RamoSeguro__r.Codigo__c, Modalidade__c, Modalidade__r.Codigo__c, Produto__r.Empresa__c
                                                         FROM GarantiaProduto__c
                                                         WHERE Produto__r.ProductCode = :orcamento.Produto__r.ProductCode
                                                         AND RamoSeguro__r.Codigo__c = :orcamento.RamoOrcamento__c //PLV-4693 INICIO/FIM
                                                         ORDER BY OrdemPrioridade__c ASC];
            //PLV_3196 - FIM - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
            
            GarantiaProduto__c garantiaProduto = lGarantiaProduto.size() > 0 ? lGarantiaProduto[0] : null; 
            system.debug('DIEGO Garantia Produto: ' + garantiaProduto);
            ContratoTO.SolicitarTituloTO solicitarTituloTO = new ContratoTO.SolicitarTituloTO();
            solicitarTituloTO.quantidade = 1;
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            system.debug('PLV-3285 - Valor CONSTANTE_ORIGEM_PROPOSTA: ' + origemProposta[0].valor__c);
            solicitarTituloTO.origemproposta = Integer.ValueOf(origemProposta[0].valor__c); //payloadTO.proposta.origem;
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            
            // gera um numero de proposta
            HerokuResponseTO.TituloTO retorno = HerokuService.getInstance().gerarNumeroProposta(solicitarTituloTO);
            // INICIO | PLV-2355-SNIPER
            String numeroProposta = retorno.data.numeros[0];
            proposta.Status = 'Em criação';
            proposta.NR__c = payloadTO.proposta.contratantes[0].pessoa.nivelRelacionamento == null ? '': payloadTO.proposta.contratantes[0].pessoa.nivelRelacionamento;//OKR-134 - INÍCIO/FIM 
            proposta.NumeroProposta__c = numeroProposta;
            system.debug('proposta.NumeroProposta__c: '+ proposta.NumeroProposta__c);
            proposta.NomeSocial__c = payloadTO.proposta.contratantes[0].pessoa.nomeSocial; // LECVPV-184 INICIO/FIM
            proposta.MeioComercializacao__c = payloadTO.proposta.meioComercializacao;
            //PLV-4440 - INICIO
            if('Individual'.equalsIgnoreCase(this.segmento)){//PLV-4701 INICIO/FIM
                system.debug('payloadTO:: '+payloadTO);
                // PLV-4488 FIX
                if(listOldContract == null)
                    proposta.PorQuantoTempoQuerGarantirRenda__c = payloadTO.proposta.tempoRendaProtegida;
                proposta.DependentesFinanceiros__c = payloadTO.proposta.dependentesFinanceiros == null ? false : payloadTO.proposta.dependentesFinanceiros ;
                //proposta.TipoContrato__c = payloadTO.proposta.tipoContrato;
                proposta.FormaReceberApolice__c = payloadTO.proposta.formaReceberApolice;
                proposta.TermoGuarda__c = payloadTO.proposta.termoGuarda== null ? false : payloadTO.proposta.termoGuarda;
                proposta.TermoResponsabilidade__c = payloadTO.proposta.termoResponsabilidade== null ? false : payloadTO.proposta.termoResponsabilidade;
                proposta.AssinaturaEletronica__c = payloadTO.proposta.assinaturaEletronica== null ? false : payloadTO.proposta.assinaturaEletronica;                
                proposta.ReaproveitarAssinatura__c = payloadTO.proposta.reaproveitarAssinatura== null ? false : payloadTO.proposta.reaproveitarAssinatura;//PLV-5643 INICIO/FIM
        		//PLV-4386 - INÍCIO
        		proposta.MelhorPeriodoContato__c = payloadTO.proposta.melhorPeriodo== null ? 'I' : payloadTO.proposta.melhorPeriodo;
        		//PLV-4386 - FIM
                //PLV-4953 - INICIO
                if(payloadTO.proposta.contratantes[0].pessoa.email != null)
                    proposta.email__c = payloadTO.proposta.contratantes[0].pessoa.email;
                //PLV-4953 - FIM
            }

            // VIAG-139 INICIO
            ParceiroDAO daoParceiroDAO = ParceiroDAO.getInstance();
            proposta.Parceiro__c = daoParceiroDAO.buscarParceiroPorProductId(orcamento.Produto__c); 
            System.debug('Parceiro>>>>'+ proposta.Parceiro__c+ 'Produto c>>>>>>'+ orcamento.Produto__c);
            // VIAG-139 FIM

            proposta.ScoreFraude__c =  payloadTO.proposta.scoreFraude; // PLV-4416 - INICIO - FIM 
            proposta.ScoreSerasa__c = payloadTO.proposta.scoreSerasa; //PLV - 4388 - INICIO/FIM - Gustavo Pereira SYS4b
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            proposta.Origem__c = origemProposta[0].valor__c; //String.valueOf(payloadTO.proposta.origem);
            proposta.Name = this.gerarQuoteName(String.valueOf(solicitarTituloTO.origemproposta), numeroProposta);
            //PLV-2291 INICIO Criacao de campo unico
            proposta.NumeroPropostaUnico__c = this.gerarQuoteName(String.valueOf(solicitarTituloTO.origemproposta), numeroProposta);
            proposta.EntradaNegocio__c = orcamento.EntradaNegocio__c;
            //PLV-2291 FIM Criacao de campo unico
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            // FIM | PLV-2355-SNIPER
            // PLV-4248 - INICIO
            System.debug(' PLV-4248 RecordType.Name :> ' + orcamento.RecordType.Name );
            proposta.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(orcamento.RecordType.Name).getRecordTypeId();
            // proposta.RecordType = mapRecordType.get(orcamento.RecordType.Name);
            System.debug(' PLV-4248 proposta.RecordType :> ' + proposta.RecordType );
            // PLV-4248 - INICIO
            proposta.OpportunityId = orcamento.Id;
            
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            proposta.CanalDistribuicao__c = orcamento.CanalDistribuicao__c;
            proposta.MeioComercializacao__c = orcamento.MeioComercializacao__c;
            //PLV-3879 - INICIO
			proposta.PaisesDestino__c = orcamento.PaisesDestino__c;
			//PLV-3879 - FIM
            proposta.QuantidadePassageiros070Anos__c = orcamento.QuantidadePassageiros070Anos__c;
            proposta.VidasEntre7190Anos__c = orcamento.VidasEntre7190Anos__c;
            proposta.ViagemAventura__c = orcamento.ViagemAventura__c;
            proposta.IncluiPaisEuropeu__c = orcamento.IncluiPaisEuropeu__c;
            proposta.UtilizaMoto__c = orcamento.UtilizaMoto__c;
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            // PLV-4666 - INICIO
            proposta.Tarifa__c = orcamento.Tarifa__c;
            proposta.DLL__c = orcamento.DLL__c;
            // PLV-4666 - FIM
            proposta.CodigoCorretor__c = orcamento.CodigoCorretor__c;
            proposta.CustoApolice__c = orcamento.CustoApolice__c;
            proposta.DataCalculo__c = orcamento.DataCalculo__c;
            proposta.DataCriacaoPortal__c = orcamento.DataCriacaoPortal__c;
            proposta.Description = orcamento.Description;
            proposta.Encargos__c = orcamento.Encargos__c;
            
            System.debug('TESTE ISA ' + JSON.serialize(payloadTO));
            
            String codFP = '' + payloadTO.proposta.contratantes[0].dadosPagamento.codigoFormaPagamento;
            string prodId = '' + orcamento.Produto__c;
            String qtdparcel = '' + payloadTO.proposta.contratantes[0].dadosPagamento.quantidadeParcelas ;
            System.debug(' @#$@#$ orcamento.Produto__c :> ' + orcamento.Produto__c );
            System.debug(' @#$@#$ codigoFormaPagamento :> ' + codFP );
            System.debug(' @#$@#$ payloadTO.proposta.contratantes[0].dadosPagamento.quantidadeParcelas :> ' + qtdparcel );
            //PLV-3285 - INICIO
            if(qtdparcel != null){
                List<CondicaoCobranca__c> conCobrancaLst = [ 	
                    SELECT 	Id, Name, FormaPagamento__c, FormaPagamento__r.Codigo__c, Produto__c, QuantidadeParcelas__c
                    FROM 	CondicaoCobranca__c 
                    WHERE 	Produto__c = :prodId
                    AND 	FormaPagamento__r.Codigo__c = :codFP
                    AND		QuantidadeParcelas__c INCLUDES (:qtdparcel)
                ];
                //Integer qtdPar = Integer.ValueOf(qtdparcel);
                //List<PlanoParcelamento__c> lstPlanoParc = [SELECT Id 
                //											FROM PlanoParcelamento__c 
                //											WHERE FormaPagamento__c = :conCobrancaLst[0].Id 
                //											AND NumeroParcela__c = :qtdPar];
                System.debug(' @#$@#$ conCobranca :> ' + conCobrancaLst );
                //System.debug(' @#$@#$ lstPlanoParc :> ' + lstPlanoParc );
                if ( !conCobrancaLst.isEmpty() )	proposta.FormaPagamento__c = conCobrancaLst[0].FormaPagamento__c;
                
            }
            System.debug(' @#$@#$ proposta.FormaPagamento__c :> ' + proposta.FormaPagamento__c );
            //PLV-3285 - FIM
            
            proposta.InformacoesEvento__c = orcamento.InformacoesEvento__c;
            proposta.Iof__c = orcamento.Iof__c;
            proposta.Juros__c = orcamento.Juros__c;
            proposta.Payload__c = orcamento.Payload__c;
            proposta.Produto__c = orcamento.Produto__c;
            proposta.TipoDescontoAgravo__c = orcamento.TipoDescontoAgravo__c;
            proposta.TipoEvento__c = orcamento.TipoEvento__c;
            proposta.TipoViagem__c = orcamento.TipoViagem__c;
            proposta.TipoVigencia__c = orcamento.TipoVigencia__c;
            proposta.VigenciaFinal__c = orcamento.VigenciaFinal__c;
            proposta.VigenciaFinalAlterada__c = orcamento.VigenciaFinalAlterada__c; //PLV-4684 INICIO/FIM
            proposta.VigenciaInicial__c = orcamento.VigenciaInicial__c;
            //II-143 - INICIO            
            if(this.segmento == 'Individual' && orcamento.VigenciaInicial__c < System.today()){
                proposta.VigenciaInicial__c = System.today();
                proposta.VigenciaFinal__c = System.today().addDays(-1).addYears(1);
            }
            //II-143 - FIM
            proposta.TipoEndosso__c = orcamento.TipoEndosso__c;
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            // proposta.TaxaComercial__c = orcamento.TaxaComercial__c;
            // proposta.TaxaPura__c = orcamento.TaxaPura__c;
            // proposta.TaxaTotal__c = orcamento.TaxaTotal__c;
            // proposta.PremioComercial__c = orcamento.PremioComercial__c;
            proposta.PremioInformado__c = orcamento.PremioInformado__c;
            // proposta.PremioPuro__c = orcamento.PremioPuro__c;
            // proposta.PremioTotal__c = orcamento.PremioTotal__c;
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            proposta.Tipo__c = mapConversaoTipoProposta.get(orcamento.Type);
            proposta.DescontoAgravoMonetarioComercial__c = orcamento.DescontoAgravoMonetarioComercial__c;
            proposta.DescontoAgravoMonetarioInformado__c = orcamento.DescontoAgravoMonetarioInformado__c;
            proposta.DescontoAgravoMonetarioTecnico__c = orcamento.DescontoAgravoMonetarioTecnico__c;
            proposta.DescontoAgravoPercentualComercial__c = orcamento.DescontoAgravoPercentualComercial__c;
            proposta.DescontoAgravoPercentualInformado__c = orcamento.DescontoAgravoPercentualInformado__c;
            proposta.DescontoAgravoPercentualTecnico__c = orcamento.DescontoAgravoPercentualTecnico__c;
            proposta.DataProtocolo__c = Date.today();
            proposta.DataEndosso__c = payloadTO.orcamento != null ? payloadTO.orcamento.dataEndosso : null;  //INICIO/FIM - PLV-4686 - Guilherme Brito
            //PLV-2932 - Inicio/Fim - Codigo removido. Data Emissão deve ser inserida quando a proposta é contrada
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            //proposta.ImprimirCertificadoSeguro__c = payloadTO.proposta.imprimirCertificadoSeguro;
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            
            //PLV-2146 - INÍCIO
            //Pega último link de documento criado no orcamento
            List<ContentDocumentLink> listCdl = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: orcamento.Id ORDER BY Id DESC];
            if(listCdl.size() > 0) {
                //PLV-3455 - INICIO - Ajuste na busca do arquivo
                //ContentDocumentLink cdl = listCdl[0];
                //Pega última versão de arquivo criado no orcamento
                //List<ContentVersion> listCV = [SELECT Id, ContentDocumentId, VersionData FROM Contentversion WHERE ContentDocumentId =: cdl.ContentDocumentId ORDER BY CreatedDate DESC];
                List<ContentVersion> listCV = new List<ContentVersion>();
                List<ContentVersion> listCV2 = new List<ContentVersion>();

                //VIAG-165 FIX01 INICIO
                Set<Id> contentDocumentIds = new Set<Id>();
                for(ContentDocumentLink cdl : listCdl){
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, VersionData, Title 
                                       FROM ContentVersion 
                                       WHERE ContentDocumentId IN :contentDocumentIds 
                                       AND (NOT Title LIKE '%_localStorage') 
                                       ORDER BY ContentDocumentId, CreatedDate DESC];

                for (ContentVersion cvTemp : contentVersions) {
                        system.debug('cv ' + cvTemp);
                        if(!cvTemp.Title.contains('retornoServico') ){
                            listCV.add(cvTemp);
                        } else {
                            listCV2.add(cvTemp);
                        }
                    }
                //VIAG-165 FIX01 FIM
                                       
                system.debug('List cv ' + JSON.serialize(listCV));
                system.debug('List cv2 ' + JSON.serialize(listCV2));
                //PLV-3455 - FIM
                if(listCV.size() > 0) {
                    ContentVersion cv = listCV[0];
                    //Pega corpo do arquivo (Payload) e transforma em String
                    Blob cvFileBody = cv.VersionData;
                    String cvAsString = cvFileBody.toString();
                    System.debug('cvAsString: ====>>>' + cvAsString);
                    if(cvAsString != null && cvAsString != ''){
                        //PLV-3285 - INICIO - MVP A Transmissão da proposta
                        //EmissaoTO.PayloadTO payloadOrc = (EmissaoTO.PayloadTO) JSON.deserialize(cvAsString, EmissaoTO.PayloadTO.class);
                        System.debug('EmissaoTO.PayloadTO.class: ====>>>' + EmissaoTO.PayloadTO.class);
                        this.payloadOrcamentoPrecificacao = (EmissaoTO.PayloadTO) JSON.deserialize(cvAsString, EmissaoTO.PayloadTO.class);//PLV-4701
                        System.debug('payloadOrcamentoPrecificacao>1: ' + JSON.serialize(payloadOrcamentoPrecificacao));
                        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
                         if('Viagem'.equalsIgnoreCase(this.segmento))
                            nomeGrupo = this.retornarNomeGrupoPassageiro(payloadTO.proposta.contratantes[0].grupos[0]);
                        preencherMapCalculosCoberturas();
                        System.debug('PEDRO --> this.mapOpcaoDesconto '+JSON.serialize(this.mapOpcaoDesconto) );
                        System.debug('PEDRO --> this.mapOpcaoDescontoGrupos '+JSON.serialize(this.mapOpcaoDescontoGrupos) );
                        this.opcaoPagamentoCliente = payloadTO.proposta.contratantes[0].dadosPagamento.opcao!=null ? payloadTO.proposta.contratantes[0].dadosPagamento.opcao : 0;
                        proposta.opcao__c = String.valueOf(this.opcaoPagamentoCliente);
                        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

                        if(payloadTO.proposta.contratantes != null) {
                            System.debug('ENTROU NO IF DO CONTRATANTE');
                            EmissaoTO.DadosPagamentoTO dadosPagamentoTO = payloadTO.proposta.contratantes[0].dadosPagamento;
                            if(dadosPagamentoTO.opcao != null && this.payloadOrcamentoPrecificacao.retornosCalculo != null) {//PLV-4701
                                System.debug('ENTROU NO IF DOS DADOS PAGAMENTOS E RETORNO CALCULO');
                                for(EmissaoTo.RetornoCalculoTO rC : this.payloadOrcamentoPrecificacao.retornosCalculo) {//PLV-4701
                                    System.debug('RC HENRIQUE: ' + rc);
                                    //PLV-3285 - FIM - MVP A Transmissão da proposta
                                    if(dadosPagamentoTO.opcao == Integer.valueOf(rc.opcao) && rC.precificacao.descontoAgravo != null){
                                        for(EmissaoTO.DescontoAgravoTO descontoAgravo : rC.precificacao.descontoAgravo) {
                                            if(descontoAgravo.tipo == 'FPG') {
                                                proposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                                                proposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
                                            }
                                            else if(descontoAgravo.tipo == 'TPR') {
                                                proposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                                                proposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
                                            }
                                        }
                                    }
                                    //II-102 INICIO
                                    // else{ //PLV-5800 FIX03 INICIO
                                    //     System.debug('ENTROU NESSE ELSE PARTE 1');
                                    //     proposta.DescontoAgravoPercentualFormaPagto__c = orcamento.DescontoAgravoPercentualFormaPagto__c;
                                    //     proposta.DescontoAgravoMonetarioFormaPagto__c = orcamento.DescontoAgravoMonetarioFormaPagto__c;
                                    // }     //PLV-5800 FIX03 FIM
                                    //II-102 FIM
                                }
                            }
                            else{ //PLV-5800 FIX01 INICIO
                                System.debug('ENTROU NO ELSE DAS CONDIÇÕES');
                                proposta.DescontoAgravoPercentualFormaPagto__c = orcamento.DescontoAgravoPercentualFormaPagto__c;
                                proposta.DescontoAgravoMonetarioFormaPagto__c = orcamento.DescontoAgravoMonetarioFormaPagto__c;
                            }     //PLV-5800 FIX01 FIM
                        }
                    }
                }
                //PLV-3455 - INICIO - Preecher a variavel global
                if(listCV2.size() > 0){
                    ContentVersion cv2 = listCV2[0];
                    //Pega corpo do arquivo (Payload) e transforma em String
                    Blob cvFileBody2 = cv2.VersionData;
                    String cvAsString2 = cvFileBody2.toString();
                    if(cvAsString2 != null && cvAsString2 != ''){
                        payloadParcelamentos = (ServiceTO.OfertaTO) JSON.deserialize(cvAsString2, ServiceTO.OfertaTO.class);
                    }
                }
                if(payloadParcelamentos != null){
                    if(!payloadParcelamentos.parcelamentos.isEmpty()){
                        // TKCL 441 - INICIO - FIX01
                        System.debug('henrique payloadParcelamentos: ' + JSON.serialize(payloadParcelamentos));
                        System.debug('henrique payloadTO: ' + JSON.serialize(payloadTO));
                        atribuirParcelasRecorrencia(payloadParcelamentos, payloadTO);  // TKCL 473 INICIO/FIM //TKCL-246 INICIO/FIM
                        // TKCL 441 - FIM - FIX01
                    }
                }
                //PLV-3455 - FIM
            }
            //PLV-2146 - FIM
            
            if (garantiaProduto != null) {
                //PLV_3196 - INICIO - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta	
                //PLV-3285 - INICIO - Não pode referenciar objeto sem popular o Id Externo, se ja tem o Id, vai direto por ele	
                proposta.RamoSeguro__c = garantiaProduto.RamoSeguro__c;
                proposta.Modalidade__c = garantiaProduto.Modalidade__c;
                //PLV-3285 - FIM
                //PLV_3196 - FIM - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
                proposta.Empresa__c = garantiaProduto.Produto__r.Empresa__c;				
            }
            //FIM | PLV-2610-SNIPER
            
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            System.debug('ISA payloadOrcamentoPrecificacao ' + JSON.serialize(this.payloadOrcamentoPrecificacao));//PLV-4701
            if('Viagem'.equalsIgnoreCase(this.segmento)){//PLV-4701
                
                //PLV-4340 - INICIO
                this.contemViagem = true;
                system.debug('Flag contemViagem: ' + contemViagem);
                
                this.nomeGrupo = this.retornarNomeGrupoPassageiro(payloadTO.proposta.contratantes[0].grupos[0]);
                system.debug('popularProposta - nomeGrupo: ' + this.nomeGrupo);
                
                this.Contem2Grupos = (this.payloadOrcamentoPrecificacao.retornosCalculo[0].precificacao.contratantes[0].grupos.size() > 1) ? true : false;
                
                system.debug('popularProposta - Grupo Size ' + (this.payloadOrcamentoPrecificacao.retornosCalculo[0].precificacao.contratantes[0].grupos.size()));
                system.debug('popularProposta - Grupo[0] ' + (this.payloadOrcamentoPrecificacao.retornosCalculo[0].precificacao.contratantes[0].grupos[0]));
                system.debug('popularProposta - Contem2Grupos: ' + this.Contem2Grupos);
                
                Integer indice = 0;
                
                
                proposta.CupomDesconto__c = orcamento.CupomDesconto__c; //VIAG-274 INICIO/FIM


                if(this.Contem2Grupos)
                    indice = (String.isNotBlank(this.nomeGrupo) && this.nomeGrupo == 'Passageiros até 70 anos') ? 0 : 1;
                
                system.debug('popularProposta - indice: ' + indice);
                //PLV-4340 - FIM
                // PLV-5800 INICIO
                if(this.payloadOrcamentoPrecificacao.retornosCalculo != null){
                    Integer opcaoPagamento = payloadTO.proposta.contratantes[0].dadosPagamento.opcao;				
                    for(EmissaoTO.RetornoCalculoTO retornoCalculo : this.payloadOrcamentoPrecificacao.retornosCalculo){//PLV-4701
                        if(retornoCalculo.opcao == opcaoPagamento){
                            if(retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa != null){
                                proposta.TaxaComercial__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa.comercial;
                                proposta.TaxaPura__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa.pura;
                                proposta.TaxaTotal__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa.total;
                            }	
                            
                            if(retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio != null){
                                proposta.PremioIntegral__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio.integral; //PLV-5351 INICIO/FIM
                                proposta.PremioComercial__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio.comercial;
                                proposta.PremioPuro__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio.puro;
                                proposta.PremioTotal__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio.total;
                            }
                            //AV-658 - INICIO
                            //proposta.IOF__c = retornoCalculo.precificacao!=null && retornoCalculo.precificacao.iof!=null ? retornoCalculo.precificacao.iof : orcamento.IOF__c!=null? orcamento.IOF__c : 0; //PLV-4701 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B	
                            proposta.IOF__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].iof !=null ? retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].iof : 0;
                            //AV-658 - FIM
                        }
                    }
                }
                else{
                    proposta.PremioPuro__c = orcamento.PremioPuro__c;
                    proposta.PremioTotal__c = orcamento.PremioTotal__c;
                    proposta.PremioComercial__c = orcamento.PremioComercial__c;
                    proposta.PremioIntegral__c = orcamento.PremioIntegral__c;
                } 
                // PLV-5800 FIM
                //PLV-4340 - FIM				
            }else{
                //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
                
                // RVI-195 - INICIO
                System.debug('Entrou no Else - PropostaGenericaBuilder:' + JSON.serialize(payloadOrcamentoPrecificacao));
                
                if(this.payloadOrcamentoPrecificacao.orcamento.tipoSeguro == 'Renovacao'){
                    this.opcaoPagamentoCliente = 0;
                }
                // RVI-195 - FIM
                // PLV-5800 INICIO
                if(this.payloadOrcamentoPrecificacao.retornosCalculo != null){
                    for(EmissaoTO.RetornoCalculoTO retornoCalculo : this.payloadOrcamentoPrecificacao.retornosCalculo){//PLV-4701
                        if(retornoCalculo.opcao == this.opcaoPagamentoCliente){
                            if(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].taxa != null){
                                proposta.TaxaComercial__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].taxa.comercial;
                                proposta.TaxaPura__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].taxa.pura;
                                proposta.TaxaTotal__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].taxa.total;
                            }	
                            
                            if(retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].premio != null){
                                proposta.PremioIntegral__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].premio.integral; //PLV-5351 INICIO/FIM
                                proposta.PremioComercial__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].premio.comercial;
                                proposta.PremioPuro__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].premio.puro;
                                proposta.PremioTotal__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].premio.total;
                            }
                            //AV-658 - INICIO
                            //proposta.IOF__c = retornoCalculo.precificacao!=null && retornoCalculo.precificacao.iof!=null ? retornoCalculo.precificacao.iof : orcamento.IOF__c!=null? orcamento.IOF__c : 0; //PLV-4701 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B		
                            proposta.IOF__c = retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].iof !=null ? retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].iof : 0;
                            //AV-658 - FIM	
                        }
                    }
                }else{ 
                    proposta.PremioPuro__c = orcamento.PremioPuro__c;
                    proposta.PremioTotal__c = orcamento.PremioTotal__c;
                    proposta.PremioComercial__c = orcamento.PremioComercial__c;
                    proposta.PremioIntegral__c = orcamento.PremioIntegral__c;
                }
                // PLV-5800 FIM
                //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            }
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            //PLV-4785 - INICIO - PEDRO AUGUSTO BRAZ
            if (garantiaProduto != null) {             
                this.proposta.propostaWrapper.retornoWrapper.codigoRamo = garantiaProduto.RamoSeguro__r.Codigo__c;
                this.proposta.propostaWrapper.retornoWrapper.modalidade = garantiaProduto.Modalidade__r.Codigo__c;
            }
            //PLV-4785 - FIM - PEDRO AUGUSTO BRAZ

            //PLV-4612-FIX INICIO
            // PLV-4621-FIX - INICIO
            System.debug('DEBUG TIPO DE ENDOSSO');
            try {
                proposta.SiglaTipoEndosso__c = QuoteBO.getInstance().checkTipoEndosso(payloadTO);
                if(payloadTO.proposta.segmento == 'Viagem'){
                    proposta.SiglaTipoEndosso__c += ';' + QuoteBO.getInstance().EndossoHasPRMVIAGEM(payloadTO, proposta);
                }
                System.debug('Tipos de endosso: '+proposta.SiglaTipoEndosso__c);
            } catch (Exception e) {
                System.debug('popularProposta Exception: ' + e.getMessage() + ', ' + e.getStackTraceString());
            }
            // PLV-4621-FIX - INICIO
            //PLV-4612-FIX FIM
        }
        catch(Exception e)
        {
            throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() +' TrackTrace: '+e.getStackTraceString()+ ' \r - Mensagem: ' + e.getMessage());
        }
    }
	//TKCL-246 FIX-05 INICIO
    // TKCL 441 - INICIO FIX01
    // TKCL 473 - INICIO
    public void atribuirParcelasRecorrencia(ServiceTO.OfertaTO payloadParcelamentos, EmissaoTO.PayloadTO payloadTO){
            if(payloadTO != null && payloadTO.proposta != null &&
                payloadTO.proposta.contratantes[0] != null && 
                payloadTO.proposta.contratantes[0].dadosPagamento != null ){ //ANNVI-48 - INICIO/FIM ANNVI-151-INICIO/FIM 
                for(ServiceTO.ParcelamentoTO parcela : payloadParcelamentos.parcelamentos){
                //RVI-240-INICIO
                if(MetadataDAO.getInstance().existsInMetadata(payloadTO.proposta.segmento, payloadTO.proposta.codigoProdutoVida, payloadTO.proposta.codigoEmpresa) &&  //RVI-240-FIM
                   payloadTO.proposta.contratantes[0].dadosPagamento.quantidadeParcelas == parcela.qtdParcelas &&
                  (parcela.codigo == 70 || parcela.codigo == 98) && payloadTO.proposta.contratantes[0].dadosPagamento.codigoFormaPagamento == parcela.codigo) { //TKCL-441 FIX02 INICIO/FIM PLV-5860-INICIO/FIM //ANNVI-48 - INICIO/FIM ANNVI-151-INICIO/FIM 
                    if(parcela.qtdParcelas > 1){
                        this.dadosPagamentoRecorrencia = this.dadosPagamento;
                        System.debug('CODIGO PAGAMENTO: '+ parcela.codigo);
						System.debug('HENRIQUE AQUI: '+ parcela.valorPrimeiraParcela);
                        this.dadosPagamentoRecorrencia.valorPrimeiraParcela = parcela.valorPrimeiraParcela;
                        System.debug('Gior => valorPrimeiraParcela: ' + parcela.valorPrimeiraParcela);
                        this.dadosPagamentoRecorrencia.valorDemaisParcelas = parcela.valorDemaisParcelas;
                        System.debug('Gior => valorDemaisParcelas: ' + parcela.valorDemaisParcelas);
                    //     contratante.dadosPagamento.valorPrimeiraParcela = parcela.valorPrimeiraParcela;
                    //     contratante.dadosPagamento.valorDemaisParcelas = parcela.valorDemaisParcelas;

                        //TKCL 441 FIX03  INICIO
                        // if(valor1aParcela < valorDMaisParcelas) {
                        //     contratante.dadosPagamento.valorPrimeiraParcela = parcela.valorDemaisParcelas;
                        //     contratante.dadosPagamento.valorDemaisParcelas = parcela.valorPrimeiraParcela;   
                        //     System.debug('Rogerio ValorPrimeiraParcela: ' + parcela.valorPrimeiraParcela); 
                        //     System.debug('Rogerio DemaisPrimeiraParcela: ' + parcela.valorDemaisParcelas);
                        // }
                        //TKCL 441 FIX03 FIM

                        // if(contratante.dadosPagamento != null){
                        //     System.debug('henrique parcela.valorPrimeiraParcela: ' + parcela.valorPrimeiraParcela);
                        //     System.debug('henrique parcela.valorDemaisParcelas: ' + parcela.valorDemaisParcelas);
                        // }
                    }
                    //TKCL-441 FIX02 INICIO
                    if(parcela.qtdParcelas == 1){
                        this.dadosPagamentoRecorrencia = this.dadosPagamento;
                        this.dadosPagamentoRecorrencia.valorPrimeiraParcela = parcela.valorPrimeiraParcela;
                        System.debug('Gior => valorPrimeiraParcela: ' + parcela.valorPrimeiraParcela);
                        this.dadosPagamentoRecorrencia.valorDemaisParcelas = parcela.valorPrimeiraParcela;
                        System.debug('parcela.qtdParcelas: ' + parcela.qtdParcelas);
                    }  
                    //TKCL-441 FIX02 FIM                      
                        // TKCL-441 - FIM FIX01
                        /*if(!mapParcelamentos.containsKey(parcela.codigo)){                                    
                            mapParcelamentos.put(parcela.codigo, new Map<Integer,ServiceTO.ParcelamentoTO>{parcela.qtdParcelas => parcela});
                        } else {                                  
                            mapParcelamentos.get(parcela.codigo).put(parcela.qtdParcelas, parcela);
                        }*/
                    }
                
            }
        }
    }
    // TKCL 441 - FIM
    // TKCL 473 - FIM
    //TKCL-246 FIX-05 FIM
    // 2666 - INICIO
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularContratante(ContratanteOrcamento__c contratante, ContratanteProposta__c contratanteProposta, EmissaoTO.ContratanteTO contratanteJSON, InformacaoBancaria__c pInformacaoBancaria, CartaoCredito__c pCartaoCredito, Boolean contemViagem, EmissaoTO.PessoaTO responsavelFinanceiro,Boolean responsavelFinanceiroBoolean, String tpSeg)//PLV-5067 INICIO/FIM  //PLV-4911 - INICIO/FIM PEDRO AUGUSTO BRAZ //RVI-193 - INICIO/FIM
    {
        try
        {	
            system.debug('popularContratante contemViagem: ' + this.contemViagem);
            
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            //Preenche informações de precificação a partir do json de retorno do Sinapse, anexado ao Orçamento, quando
            //for uma proposta do seguro Viagem.
            if(this.contemViagem == true){ //PLV-4340 - INICIO/FIM
             //PLV-4701-REMOVER TRECHO INICIO
                /*
                for(EmissaoTO.RetornoCalculoTO retornoCalculo : payloadOrcamentoPrecificacao.retornosCalculo){
                    System.debug('ISA retornoCalculo ' + JSON.serialize(retornoCalculo));
                    System.debug('ISA contratanteJSON ' + JSON.serialize(contratanteJSON));
                    if(retornoCalculo.opcao == contratanteJSON.dadosPagamento.opcao) {
                        
                        //PLV-4340 - INICIO
                        Integer indice = 0;
                        if(this.Contem2Grupos)
                            indice = (String.isNotBlank(this.nomeGrupo) && this.nomeGrupo == 'Passageiros até 70 anos') ? 0 : 1;
                        
                        system.debug('popularContratante - nomeGrupo: ' + this.nomeGrupo);
                        system.debug('popularContratante - Contem2Grupos: ' + Contem2Grupos);
                        system.debug('popularContratante - indice: ' + indice);
                        //PLV-4340 - FIM
                        
                        //PLV-4340 - INICIO
                        contratanteProposta.PremioComercial__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio.comercial;
                        contratanteProposta.PremioPuro__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio.puro;
                        contratanteProposta.PremioTotal__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].premio.total;
                        
                        system.debug('retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0]: ' + retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0]);
                        system.debug('retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].taxa: ' + retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa);
                        
                        if(retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa != null){
                            contratanteProposta.TaxaComercial__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa.comercial;
                            contratanteProposta.TaxaPura__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa.pura;
                            contratanteProposta.TaxaTotal__c = retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].taxa.total;
                        }
                        //PLV-4340 - FIM
                        
                        //PLV-2146 COMPLEMENTO - INICIO
                        for(EmissaoTO.DescontoAgravoTO descontoAgravo : retornoCalculo.precificacao.contratantes[0].grupos[indice].segurados[0].descontoAgravo) { //PLV-4340 - INICIO/FIM
                            if(descontoAgravo.tipo == 'FPG') {
                                contratanteProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                                contratanteProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
                            }
                            else if(descontoAgravo.tipo == 'TPR') {
                                contratanteProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                                contratanteProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
                            }
                        }
                        //PLV-2146 COMPLEMENTO - FIM
                    }
                }*/
                //PLV-4701-REMOVER TRECHO FIM               
                system.debug('contratanteJSON: ' + contratanteJSON);
                system.debug('contratanteJSON.grupos[0]: ' + contratanteJSON.grupos[0]);
                system.debug('contratanteJSON.grupos[0].segurados[0]: ' + contratanteJSON.grupos[0].segurados[0]);
                system.debug('contratanteJSON.grupos[0].segurados[0].enderecos[0]: ' + contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0]);
                if(contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0] != null){
                    contratanteProposta.Bairro__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].bairro;
                    //VIAG-205 INÍCIO
                    String enderecoCep = (contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].cep + contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].complementoCep) != null ? (contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].cep + contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].complementoCep) : '';
                    if(enderecoCep != ''){
                        contratanteProposta.CEP__c = enderecoCep.replaceAll('\\.', '');
                    }
                    //VIAG-205 FIM
                    contratanteProposta.Cidade__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].cidade;
                    contratanteProposta.Complemento__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].complemento;
                    contratanteProposta.Logradouro__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].logradouro;
                    contratanteProposta.NumeroEndereco__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].numeroLogradouro;
                    contratanteProposta.Pais__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].paisResidencia;
                    contratanteProposta.TipoEndereco__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].tipoEndereco;
                    // if(contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].tipoEndereco == 'RES'){
                    // 	contratanteProposta.TipoEndereco__c = 'Residencial'; 
                    // }else if(contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].tipoEndereco == 'COM'){
                    // 	contratanteProposta.TipoEndereco__c = 'Comercial'; 
                    // }else if(contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].tipoEndereco == 'VER'){
                    // 	contratanteProposta.TipoEndereco__c = 'Veraneio'; 
                    // }else if(contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].tipoEndereco == 'REC'){
                    // 	contratanteProposta.TipoEndereco__c = 'Recado'; 
                    // }else{
                    // 	contratanteProposta.TipoEndereco__c = ''; 
                    // }
                    
                    contratanteProposta.Estado__c = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].uf;
                    
                    String tipoLogradouro = contratanteJSON.grupos[0].segurados[0].pessoa.enderecos[0].tipoLogradouro;
                    if(tipoLogradouro == 'R' || tipoLogradouro == 'Rua' || tipoLogradouro == 'R.' || tipoLogradouro == 'rua'){
                        contratanteProposta.TipoLogradouro__c = 'RUA';
                    }else{
                        contratanteProposta.TipoLogradouro__c = tipoLogradouro;
                    }
                
                }
                
            }else{
                contratanteProposta.PremioIntegral__c = contratante.PremioIntegral__c; //PLV-5351 INICIO/FIM
                contratanteProposta.PremioComercial__c = contratante.PremioComercial__c;
                contratanteProposta.PremioPuro__c = contratante.PremioPuro__c;
                contratanteProposta.PremioTotal__c = contratante.PremioTotal__c;
                contratanteProposta.TaxaComercial__c = contratante.TaxaComercial__c;
                contratanteProposta.TaxaPura__c = contratante.TaxaPura__c;
                contratanteProposta.TaxaTotal__c = contratante.TaxaTotal__c;
                contratanteProposta.Bairro__c = contratante.Bairro__c;
                //VIAG-205 INÍCIO
                String enderecoCep = contratante.CEP__c != null ? contratante.CEP__c : '';
                if(enderecoCep != ''){
                    contratanteProposta.CEP__c = enderecoCep.replaceAll('\\.', '');
                }
                //VIAG-205 FIM
                contratanteProposta.Cidade__c = contratante.Cidade__c;
                contratanteProposta.Complemento__c = contratante.Complemento__c;
                contratanteProposta.Estado__c = contratante.Estado__c;
                contratanteProposta.Logradouro__c = contratante.Logradouro__c;
                contratanteProposta.NumeroEndereco__c = contratante.NumeroEndereco__c;
                contratanteProposta.Pais__c = contratante.Pais__c;
                contratanteProposta.TipoEndereco__c = contratante.TipoEndereco__c;			
                if(contratante.TipoLogradouro__c == 'R' || contratante.TipoLogradouro__c == 'Rua' || contratante.TipoLogradouro__c == 'R.' || contratante.TipoLogradouro__c == 'rua'){
                    contratanteProposta.TipoLogradouro__c = 'RUA';
                }else{
                    contratanteProposta.TipoLogradouro__c = contratante.TipoLogradouro__c;
                }
               
            }
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            
            System.debug(' @@testerson this.proposta.propostaWrapper.sfProposta ' + this.proposta.propostaWrapper.sfProposta);
            System.debug(' @@testerson FormaPagamento__c ' + this.proposta.propostaWrapper.sfProposta.FormaPagamento__c);
            contratanteProposta.FormaPagamento__c = this.proposta.propostaWrapper.sfProposta.FormaPagamento__c;
            //PLV-3285 - INICIO
            // contratanteProposta.Bairro__c = contratante.Bairro__c;
            // contratanteProposta.CEP__c = contratante.CEP__c;
            // contratanteProposta.Cidade__c = contratante.Cidade__c;
            // contratanteProposta.Complemento__c = contratante.Complemento__c;
            //PLV-3285 - FIM
            contratanteProposta.Conta__c = contratante.Conta__c;
            contratanteProposta.DescontoAgravoMonetarioComercial__c = contratante.DescontoAgravoMonetarioComercial__c;
            contratanteProposta.DescontoAgravoMonetarioInformado__c = contratante.DescontoAgravoMonetarioInformado__c;
            contratanteProposta.DescontoAgravoMonetarioTecnico__c = contratante.DescontoAgravoMonetarioTecnico__c;
            contratanteProposta.DescontoAgravoPercentualComercial__c = contratante.DescontoAgravoPercentualComercial__c;
            contratanteProposta.DescontoAgravoPercentualInformado__c = contratante.DescontoAgravoPercentualInformado__c;
            contratanteProposta.DescontoAgravoPercentualTecnico__c = contratante.DescontoAgravoPercentualTecnico__c;
            // contratanteProposta.Estado__c = contratante.Estado__c; //PLV-3285
            //contratanteProposta.IOF__c = contratante.IOF__c;//PLV-4701 -INICIO/FIM
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
            // contratanteProposta.Logradouro__c = contratante.Logradouro__c;
            // contratanteProposta.NumeroEndereco__c = contratante.NumeroEndereco__c;
            contratanteProposta.Numero__c = contratante.Numero__c;
            // contratanteProposta.Pais__c = contratante.Pais__c;
            // contratanteProposta.PremioComercial__c = contratante.PremioComercial__c;
            // contratanteProposta.PremioPuro__c = contratante.PremioPuro__c;
            // contratanteProposta.PremioTotal__c = contratante.PremioTotal__c;
            // contratanteProposta.TaxaComercial__c = contratante.TaxaComercial__c;
            // contratanteProposta.TaxaPura__c = contratante.TaxaPura__c;
            // contratanteProposta.TaxaTotal__c = contratante.TaxaTotal__c;
            contratanteProposta.TipoDescontoAgravo__c = contratante.TipoDescontoAgravo__c;
            // contratanteProposta.TipoEndereco__c = contratante.TipoEndereco__c;			
            // if(contratante.TipoLogradouro__c == 'R' || contratante.TipoLogradouro__c == 'Rua' || contratante.TipoLogradouro__c == 'R.' || contratante.TipoLogradouro__c == 'rua'){
            // 	contratanteProposta.TipoLogradouro__c = 'RUA';
            // }else{
            // 	contratanteProposta.TipoLogradouro__c = contratante.TipoLogradouro__c;
            // }
            //PLV-3285 - FIM - MVP A Transmissão da proposta
            contratanteProposta.Tipo__c = contratante.Tipo__c;


            //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            Integer indice = 0;
            //PLV-4798 - INICIO - GUSTAVO
            if('Viagem'.equalsIgnoreCase(this.segmento)) {
                indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
            }
            System.debug('Indicio passageiro' + indice);
            System.debug('Nome Grupo' + this.nomeGrupo);
            //PLV-4798 - FIM - GUSTAVO
            EmissaoTO.GrupoTO grupoPayload = null;
            EmissaoTO.DescontoagravoTO descontoAgravo = null;
            //PLV-4800 - INÍCIO
            EmissaoTO.PremioTO premio = null; 
            EmissaoTO.TaxaTO taxa = null;
            //PLV-4800 - FIM            
            // RVI-193 - INICIO 
            if (tpSeg == 'Renovacao') {
                this.opcaoPagamentoCliente = 0;
                indice = 0;
            }  
            // RVI-193 - FIM    
            System.debug('MAP OPCAO DESCONTO: ' + this.mapOpcaoDescontoGrupos);    
            System.debug('OPCAO PAGAMENTO CLIENTE: ' + this.opcaoPagamentoCliente);
            System.debug ('MAP OPCAO DESCONTO GRUPO: ' + this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice));
            if(this.mapOpcaoDescontoGrupos !=null && !this.mapOpcaoDescontoGrupos.isEmpty() && this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice)!=null){                
                grupoPayload = this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice);      
                System.debug('GRUPO PAYLOAD HENRIQUE: ' + grupoPayload);
                descontoAgravo = grupoPayload.segurados[0].descontoAgravo != null ? grupoPayload.segurados[0].descontoAgravo[0] : null;                
                //PLV-4800 - INÍCIO
                premio = grupoPayload.segurados[0].premio != null ? grupoPayload.segurados[0].premio : null;
                taxa = grupoPayload.segurados[0].taxa != null ? grupoPayload.segurados[0].taxa : null;
                //PLV-4800 - FI
            }

            if(descontoAgravo!=null){
                if(descontoAgravo.tipo=='FPG'){
                    contratanteProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                    contratanteProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
                }else if(descontoAgravo.tipo == 'TPR'){
                    contratanteProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                    contratanteProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
                }
                //PLV-4800 - INÍCIO
                if(premio != null){
                    contratanteProposta.PremioIntegral__c = premio.integral; //PLV-5351 INICIO/FIM
                    contratanteProposta.PremioComercial__c = premio.comercial;
                    contratanteProposta.PremioPuro__c = premio.puro;
                    contratanteProposta.PremioTotal__c = premio.total;
                }
                if(taxa != null){
                    contratanteProposta.TaxaComercial__c = taxa.comercial;
                    contratanteProposta.TaxaPura__c = taxa.pura;
                    contratanteProposta.TaxaTotal__c = taxa.total;
                }
                //PLV-4800 - FIM
            }
            //AV-658 INICIO  
            //contratanteProposta.IOF__c = grupoPayload!=null && grupoPayload.iof!=null ? grupoPayload.iof :contratante.IOF__c!=null? contratante.IOF__c : 0;
            //VIAG-225 INICIO
            if(grupoPayload != null){
                if(grupoPayload.segurados.size() > 0 && grupoPayload.segurados != null){
                    contratanteProposta.IOF__c = grupoPayload.segurados[0].iof != null ? grupoPayload.segurados[0].iof : 0;
                } else{
                    contratanteProposta.IOF__c = 0;
                }
            } else {
                contratanteProposta.IOF__c = 0;
            }
            //VIAG-225 FIM
            //AV-658 FIM 
            //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B


            
            System.debug('TESTESTEEFGBFKDSLNB ' + contratanteJSON);
            EmissaoTO.DadosPagamentoTO dadosPagamento = contratanteJSON.dadosPagamento;
            //PLV-3285 - INICIO - MVP A Transmissão da proposta 
            //system.debug('QNT PARCELAS ' + dadosPagamento.formaPagamento.planoParcelamentos[0].quantidadeParcelas);
            system.debug('QNT PARCELAS ' + dadosPagamento.quantidadeParcelas);
            
            if(dadosPagamento.tipoResponsavelPagamento != null){
                contratanteProposta.TipoResponsavelPagamento__c = dadosPagamento.tipoResponsavelPagamento;
            }
            // contratanteProposta.FormaPagamento__c = dadosPagamento.formaPagamento.idFormaPagamento;
            //contratanteProposta.PlanoParcelamento__c = dadosPagamento.formaPagamento.planoParcelamentos[0].idPlanoParcelamento;
            
            //PLV-4488 INICIO
            if(dadosPagamento.quantidadeParcelas == 0 || dadosPagamento.quantidadeParcelas == null){ //PLV-4488 FIX2 INICIO/FIM
                dadosPagamento.quantidadeParcelas = 1;
            }
            contratanteProposta.QuantidadeParcelas__c = dadosPagamento.quantidadeParcelas;

            // RVI-248 - INICIO
            // 97 - Cartao Porto
            // 62 - Cartao Crédito
            System.debug('dadosPagamento.formaInfoCartao=======' + dadosPagamento.formaInfoCartao);
            System.debug('this.codigoEmpresa' + this.codigoEmpresa);
            if(dadosPagamento.formaInfoCartao != null && this.codigoEmpresa == 14 && (dadosPagamento.codigoFormaPagamento == 97 || dadosPagamento.codigoFormaPagamento == 62) ){
                if(dadosPagamento.formaInfoCartao == 'Preencher agora'){
                    dadosPagamento.formaInfoCartao = 'Preencher agora';
                    contratanteProposta.FormaInfoCartao__c = dadosPagamento.formaInfoCartao;
                }else if(dadosPagamento.formaInfoCartao == 'Enviar por e-mail'){
                    dadosPagamento.formaInfoCartao = 'Enviar por e-mail';
                    contratanteProposta.FormaInfoCartao__c = dadosPagamento.formaInfoCartao;
                }else if(dadosPagamento.formaInfoCartao == 'Enviar por SMS'){
                    dadosPagamento.formaInfoCartao = 'Enviar por SMS';
                    contratanteProposta.FormaInfoCartao__c = dadosPagamento.formaInfoCartao;
                }
            }
            // RVI-248 - FIM
            
            if(dadosPagamento.codigoFormaPagamento == 0){
                if(this.contemViagem == true){
                    dadosPagamento.codigoFormaPagamento = 97;
                }else{
                    dadosPagamento.codigoFormaPagamento = 11;
                }
            }
            
            contratanteProposta.QuantidadeParcelas__c = dadosPagamento.quantidadeParcelas;
            this.codigoFormaPagamento = dadosPagamento.codigoFormaPagamento;
            //PLV-4488 FIM

            //contratanteProposta.PremioParcela__c = dadosPagamento.formaPagamento.planoParcelamentos[0].valorParcela;
            //Precisa fazer o calculo para o valor da parcela - entender como isso é armazenado no salesforce
            
            System.debug(' @#@tsterson contratanteProposta :> ' + contratanteProposta);
            System.debug(' @#@tsterson contratanteProposta.FormaPagamento__c :> ' + contratanteProposta.FormaPagamento__c);
            System.debug(' @#@tsterson contratanteProposta.QuantidadeParcelas__c :> ' + contratanteProposta.QuantidadeParcelas__c);
            
            //PLV-4488 - INICIO
            //PLV-4601 - INICIO - PEDRO AUGUSTO BRAZ 
            List<PlanoParcelamento__c> lstPlanoParc = new List<PlanoParcelamento__c>();
            
            String idFormaPGTO = dadosPagamento.formaPagamento.idFormaPagamento;
            String codFormaPGTO = String.valueOf(dadosPagamento.codigoFormaPagamento);
            String qtdParcelas = String.valueOf(contratanteProposta.QuantidadeParcelas__c);
            String prodId = orcamento.Produto__c;
            Double qtdParcelasDouble = contratanteProposta.QuantidadeParcelas__c; //RVI-276 INICIO-FIM

            if(String.isBlank(idFormaPGTO)){
                List<CondicaoCobranca__c> conCobrancaLst = [ 	
                    SELECT 	Id, Name, FormaPagamento__c, FormaPagamento__r.Codigo__c, Produto__c, QuantidadeParcelas__c
                    FROM 	CondicaoCobranca__c 
                    WHERE 	Produto__c = :prodId
                    AND 	FormaPagamento__r.Codigo__c = :codFormaPGTO
                    AND		QuantidadeParcelas__c INCLUDES (:qtdParcelas)
                ];
                if(conCobrancaLst!=null && conCobrancaLst.size()>0) idFormaPGTO = conCobrancaLst[0].FormaPagamento__c;
            }

            lstPlanoParc = [SELECT Id, FormaPagamento__c
                            FROM PlanoParcelamento__c 
                            WHERE FormaPagamento__c = : idFormaPGTO
                            AND NumeroParcela__c = :qtdParcelasDouble //RVI-276 INICIO-FIM
                            ];

            //PLV-4601 - FIM - PEDRO AUGUSTO BRAZ
            if(lstPlanoParc.size() > 0){
                this.planoParcelamento = lstPlanoParc[0].Id;										
                contratanteProposta.PlanoParcelamento__c = this.planoParcelamento;
                contratanteProposta.FormaPagamento__c = lstPlanoParc[0].FormaPagamento__c;
            }
            //PLV-4488 - FIM
            system.debug('Contratantes PARCELAS ' + contratanteProposta.QuantidadeParcelas__c);
            String contratanteIdExterno = montarChavePessoa(contratanteJSON.pessoa);
            
            //PLV-4440 - INICIO
            if(dadosPagamento != null){
                //PLV-4488 INICIO
                if(dadosPagamento.vigenciaInicial != null){
                    contratanteProposta.VigenciaInicial__c = String.isNotBlank(dadosPagamento.vigenciaInicial) ? Date.valueOf(dadosPagamento.vigenciaInicial) : null;
                }
                //PLV-4488 FIM
                contratanteProposta.QuantidadeParcelas__c = dadosPagamento.quantidadeParcelas;
                contratanteProposta.VencimentoDemaisParcelas__c = dadosPagamento.vencimentoDemaisParcelas; //PLV-4438-Fix2 - Inicio/Fim
            }
            system.debug('dadosPagamento: '+dadosPagamento);

            //PLV-5067 - INICIO - PEDRO AUGUSTO BRAZ
            Account responsavel = new Account();
            if(responsavelFinanceiro != null){
                // ANNVI-18 - INICIO
                String tipoPessoa= (responsavelFinanceiro.tipoPessoa == '' || responsavelFinanceiro.tipoPessoa == null)? 
                        'PessoaFisica': responsavelFinanceiro.tipoPessoa;
                Id tipoRegistroPessoa = RecordTypeBO.buscarTipoRegistro('Account', tipoPessoa).Id;
                // Id tipoRegistroPessoa = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id;
                
                String cpf= (responsavelFinanceiro.dadosPessoaFisica == null)? '': responsavelFinanceiro.dadosPessoaFisica.numeroCpf + responsavelFinanceiro.dadosPessoaFisica.digitoCpf;
                String cnpj= (responsavelFinanceiro.dadosPessoaJuridica == null)? '': responsavelFinanceiro.dadosPessoaJuridica.numeroCNPJ + responsavelFinanceiro.dadosPessoaJuridica.ordemCNPJ + responsavelFinanceiro.dadosPessoaJuridica.digitoCNPJ;
                // ANNVI-18 - FIM

                // ANNVI-18 - INICIO
                if (cpf != '') { // ANNVI-18 - pessoa física
                    responsavel = new Account (
                            //PLV-5241 - INICIO
                            //LastName = responsavelFinanceiro.nome, 
                            FirstName = Util.getPrimeironome(responsavelFinanceiro.nome),
                            LastName = Util.getSobrenome(responsavelFinanceiro.nome),
                            //PLV-5241 - FIM                        
                            Cpf__c = cpf, //responsavelFinanceiro.dadosPessoaFisica.numeroCpf + responsavelFinanceiro.dadosPessoaFisica.digitoCpf, // ANNVI-18 - INICIO/FIM
                            RecordTypeId = tipoRegistroPessoa,
                            // IdExterno__c = responsavelFinanceiro.dadosPessoaFisica.numeroCpf + responsavelFinanceiro.dadosPessoaFisica.digitoCpf,
                            IdExterno__c = cpf,
                            //PLV-5153 - INICIO
                            //PersonEmail = responsavelFinanceiro.email)
                            PersonEmail = responsavelFinanceiro.email,
                            Sexo__c = responsavelFinanceiro.dadosPessoaFisica.sexo,
                            PersonBirthdate =  (String.isNotBlank(responsavelFinanceiro.dadosPessoaFisica.dataNascimento) ? Date.valueOf(responsavelFinanceiro.dadosPessoaFisica.dataNascimento) : null)  , 
                            EstadoCivil__c = deparaEstadoCivil(responsavelFinanceiro.dadosPessoaFisica.estadoCivil)
                        );
                        if(responsavelFinanceiro.telefones != null && responsavelFinanceiro.telefones.size() > 0){
                            for(EmissaoTO.telefoneTO tel: responsavelFinanceiro.telefones){
                                String telefoneToInput = Util.getMascaraTelefone(tel.numeroTelefone,tel.dddTelefone);
                                if('RES'.equalsIgnoreCase(tel.tipoTelefone)){
                                    responsavel.PersonHomePhone = telefoneToInput;
                                }else if('CEL'.equalsIgnoreCase(tel.tipoTelefone)){
                                    responsavel.PersonMobilePhone = telefoneToInput;
                                }else if('PES'.equalsIgnoreCase(tel.tipoTelefone)){
                                    responsavel.Phone = telefoneToInput;
                                }
                            }
                        }                        
                } else { // ANNVI-18 - pessoal jurídica
                    responsavel = new Account (
                            //PLV-5241 - INICIO
                            //LastName = responsavelFinanceiro.nome, 
                            // FirstName = Util.getPrimeironome(responsavelFinanceiro.nome),
                            // LastName = Util.getSobrenome(responsavelFinanceiro.nome),
                            Name= responsavelFinanceiro.nome, // ANNVI-18 - INICIO/FIM
                            //PLV-5241 - FIM
                            Cnpj__c = cnpj, //responsavelFinanceiro.dadosPessoaJuridica.numeroCNPJ + responsavelFinanceiro.dadosPessoaJuridica.ordemCNPJ + responsavelFinanceiro.dadosPessoaJuridica.digitoCNPJ, // ANNVI-18 - INICIO/FIM
                            RecordTypeId = tipoRegistroPessoa,
                            // IdExterno__c = responsavelFinanceiro.dadosPessoaFisica.numeroCpf + responsavelFinanceiro.dadosPessoaFisica.digitoCpf,
                            IdExterno__c = cnpj,
                            //PLV-5153 - INICIO
                            //PersonEmail = responsavelFinanceiro.email
                            // PersonEmail = responsavelFinanceiro.email
                            Email__c = responsavelFinanceiro.email
                            // Sexo__c = responsavelFinanceiro.dadosPessoaFisica.sexo,
                            // PersonBirthdate =  (String.isNotBlank(responsavelFinanceiro.dadosPessoaFisica.dataNascimento) ? Date.valueOf(responsavelFinanceiro.dadosPessoaFisica.dataNascimento) : null)  , 
                            // EstadoCivil__c = deparaEstadoCivil(responsavelFinanceiro.dadosPessoaFisica.estadoCivil) 
                        );
                        if(responsavelFinanceiro.telefones != null && responsavelFinanceiro.telefones.size() > 0){
                            for(EmissaoTO.telefoneTO tel: responsavelFinanceiro.telefones){
                                String telefoneToInput = Util.getMascaraTelefone(tel.numeroTelefone,tel.dddTelefone);
                                responsavel.Phone = telefoneToInput;
                                // if('RES'.equalsIgnoreCase(tel.tipoTelefone)){
                                //     responsavel.PersonHomePhone = telefoneToInput;
                                // }else if('CEL'.equalsIgnoreCase(tel.tipoTelefone)){
                                //     responsavel.PersonMobilePhone = telefoneToInput;
                                // }else if('PES'.equalsIgnoreCase(tel.tipoTelefone)){
                                //     responsavel.Phone = telefoneToInput;
                                // }
                            }
                        }
                }
                // ANNVI-18 - FIM
                        //PLV-5153 - FIM

                // if(responsavelFinanceiro.telefones != null && responsavelFinanceiro.telefones.size() > 0){
                //     for(EmissaoTO.telefoneTO tel: responsavelFinanceiro.telefones){
                //         String telefoneToInput = Util.getMascaraTelefone(tel.numeroTelefone,tel.dddTelefone);
                //         if('RES'.equalsIgnoreCase(tel.tipoTelefone)){
                //             responsavel.PersonHomePhone = telefoneToInput;
                //         }else if('CEL'.equalsIgnoreCase(tel.tipoTelefone)){
                //             responsavel.PersonMobilePhone = telefoneToInput;
                //         }else if('PES'.equalsIgnoreCase(tel.tipoTelefone)){
                //             responsavel.Phone = telefoneToInput;
                //         }
                //     }
                // } // ANNVI-18 - INICIO/FIM - trecho removido
                
                System.debug('responsavel >>> '+responsavel+ ' IdExterno__c >>> '+responsavel.IdExterno__c);
                upsert responsavel IdExterno__c;
                mapContas.put(responsavel.IdExterno__c,responsavel);
            }
           
            //SE FALSO O RESPONSÁVEL É OUTREM, SE VERDADEIRO É O PROPRIO CONTRATANTE
            if(responsavelFinanceiroBoolean){
                contratanteProposta.ResponsavelPagamento__r = new Account(IdExterno__c = contratanteIdExterno);
            }else{
                contratanteProposta.ResponsavelPagamento__c = responsavel.Id;
            }
            //PLV-5067 - FIM - PEDRO AUGUSTO BRAZ
            if (dadosPagamento.dadosBancarios != null) {
                system.debug('dadosPagamento.dadosBancarios: '+dadosPagamento.dadosBancarios);
                List<Banco__c> bancos = [SELECT Id FROM Banco__c WHERE CodigoBanco__c = :dadosPagamento.dadosBancarios.banco];
                system.debug('bancos:: '+bancos);
                if(!bancos.isEmpty()){
                    system.debug('bancos:: '+bancos);
                    pInformacaoBancaria.Conta__r = responsavelFinanceiroBoolean ? new Account(IdExterno__c = contratanteIdExterno) : new Account(IdExterno__c = responsavel.IdExterno__c); //PLV-5067
                    pInformacaoBancaria.Agencia__c = String.isNotBlank(dadosPagamento.dadosBancarios.digitoAgencia) ? dadosPagamento.dadosBancarios.agencia +'-'+ dadosPagamento.dadosBancarios.digitoAgencia : dadosPagamento.dadosBancarios.agencia;
                    //pInformacaoBancaria.BancoNew__r = new Banco__c(CodigoBanco__c = dadosPagamento.dadosBancarios.banco);
                    pInformacaoBancaria.Banco__c = dadosPagamento.dadosBancarios.banco;
                    pInformacaoBancaria.BancoNew__c = !bancos.isEmpty() ? bancos[0].Id : null;
                    pInformacaoBancaria.NumeroConta__c              = dadosPagamento.dadosBancarios.conta;
                    pInformacaoBancaria.TipoPessoa__c               = dadosPagamento.dadosBancarios.tipoPessoa;
                    
                    //PLV-3918-FIX6-INICIO
                    //PLV-3918-FIX7-INICIO
                    pInformacaoBancaria.Digito__c = dadosPagamento.dadosBancarios.digitoConta;
                    //PLV-3918-FIX7-FIM
                    //PLV-3918-FIX6-FIM
                    pInformacaoBancaria.Papel__c = 'Segurado';
                }
            }
            //PLV-4440 - FIM
            
            //if (dadosPagamento.cartaoCredito != null) {
            if (dadosPagamento.dadosCartaoCredito != null) {
                //PLV-4449 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
                pCartaoCredito.Conta__r = responsavelFinanceiroBoolean ? new Account(IdExterno__c = contratanteIdExterno) : new Account(IdExterno__c = responsavel.IdExterno__c); //PLV-5067
                pCartaoCredito.NumeroCartao__c = dadosPagamento.dadosCartaoCredito.numero;
                pCartaoCredito.Vencimento__c = dadosPagamento.dadosCartaoCredito.validade;
                pCartaoCredito.VencimentoCriptografado__c = dadosPagamento.dadosCartaoCredito.validadeCriptografada;
                pCartaoCredito.Bandeira__c = dadosPagamento.dadosCartaoCredito.bandeira;//PLV-4926-INICIO/FIM - PEDRO AUGUSTO BRAZ
                if(dadosPagamento.dadosCartaoCredito.cartaoPorto != null) pCartaoCredito.CartoPortoSeguro__c = dadosPagamento.dadosCartaoCredito.cartaoPorto;
                pCartaoCredito.Ticket__c = dadosPagamento.dadosCartaoCredito.ticket;
                pCartaoCredito.Status__c = dadosPagamento.dadosCartaoCredito.ticket==null || String.isBlank(dadosPagamento.dadosCartaoCredito.ticket) ? 'Não integrado' : 'Integrado';//PLV-4926 INICIO/FIM
                pCartaoCredito.NomeTitular__c = dadosPagamento.dadosCartaoCredito.nome; //PLV-4992 FIX 1 - INÍCIO/FIM
                //PLV-4449 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            }
            // TKCL-473/INICIO
            if (dadosPagamentoRecorrencia != null) {
                System.debug('Gior => Valor Primeira parcela...'+dadosPagamentoRecorrencia.valorPrimeiraParcela);
                System.debug('Gior => Valor Demais parcelas...'+dadosPagamentoRecorrencia.valorDemaisParcelas);
                contratanteProposta.Recorrencia__c = true;
                contratanteProposta.Valor_PrimeiraParcela__c = Decimal.valueOf(dadosPagamentoRecorrencia.valorPrimeiraParcela);
                contratanteProposta.Valor_DemaisParcelas__c = Decimal.valueOf(dadosPagamentoRecorrencia.valorDemaisParcelas);
            }
            // TKCL-473/FIM
            
            //PLV-3285 - INICIO - MVP A Transmissão da proposta
	    //PLV-5067 - INICIO DO CÓDIGO MOVIDO - PEDRO AUGUSTO BRAZ
            //PLV-5067 - FIM DO CÓDIGO MOVIDO - PEDRO AUGUSTO BRAZ
            // PLV-4675 INICIO
            contratanteProposta.Nome_do_segurado__c =  contratante.Conta__r.Name;
            contratanteProposta.NomeSocial_do_Segurado__c = contratante.Conta__r.NomeSocial__c; // LECVPV-184 INICIO/FIM
            contratanteProposta.Celular__c =  contratante.Conta__r.PersonMobilePhone;
            contratanteProposta.Telefone__c = contratante.Conta__r.PersonHomePhone;
            contratanteProposta.Telefone_outro__c = contratante.Conta__r.Phone;
            contratanteProposta.Email__c = contratante.Conta__r.PersonEmail;
            contratanteProposta.Forma_de_receber_apolice__c = contratanteProposta.Proposta__r.FormaReceberApolice__c;
            // PLV-4675 FIM

            ContaResponsavelPagto = contratanteProposta.ResponsavelPagamento__r;
            
            //PLV-3285 - FIM - MVP A Transmissão da proposta
        }
        // 2666 - FIM
        catch (Exception e){
            throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularGrupoProposta(GrupoOrcamento__c grupo, GrupoProposta__c grupoProposta)
    {
        if (grupo==null) return;
        
        grupoProposta.Descricao__c = grupo.Descricao__c;
        //grupoProposta.IOF__c = grupo.IOF__c;
        grupoProposta.Name = grupo.Name;
        grupoProposta.Numero__c = grupo.Numero__c;
        //grupoProposta.Percentual__c = grupo.Percentual__c;
        grupoProposta.TipoCalculo__c = grupo.TipoCalculo__c;
        grupoProposta.TipoDescontoAgravo__c = grupo.TipoDescontoAgravo__c;
        grupoProposta.DescontoAgravoMonetarioComercial__c = grupo.DescontoAgravoMonetarioComercial__c;
        grupoProposta.DescontoAgravoMonetarioInformado__c = grupo.DescontoAgravoMonetarioInformado__c;
        grupoProposta.DescontoAgravoMonetarioTecnico__c = grupo.DescontoAgravoMonetarioTecnico__c;
        grupoProposta.DescontoAgravoPercentualComercial__c = grupo.DescontoAgravoPercentualComercial__c;
        grupoProposta.DescontoAgravoPercentualInformado__c = grupo.DescontoAgravoPercentualInformado__c;
        grupoProposta.DescontoAgravoPercentualTecnico__c = grupo.DescontoAgravoPercentualTecnico__c;



        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        Integer indice = 0;
        //PLV-4798 - INICIO - GUSTAVO
        if('Viagem'.equalsIgnoreCase(this.segmento)) {
            indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
        }
        //PLV-4798 - FIM - GUSTAVO
        EmissaoTO.GrupoTO grupoPayload = null;
        EmissaoTO.DescontoagravoTO descontoAgravo = null;
        if(this.mapOpcaoDescontoGrupos !=null && !this.mapOpcaoDescontoGrupos.isEmpty() && this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice)!=null){
            grupoPayload = this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice);
            descontoAgravo = grupoPayload.descontoAgravo != null ? grupoPayload.descontoAgravo[0] : null;
        }

        if(descontoAgravo!=null){
            if(descontoAgravo.tipo=='FPG'){
                grupoProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                grupoProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
            }else if(descontoAgravo.tipo == 'TPR'){
                grupoProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                grupoProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
            }
            if(grupoPayload.premio!=null){
                System.debug('grupoPayload.premio>3 ' + grupoPayload.premio);
                grupoProposta.PremioIntegral__c = grupoPayload.premio.integral; //PLV-5351 INICIO/FIM
                grupoProposta.PremioComercial__c = grupoPayload.premio.comercial;
                grupoProposta.PremioPuro__c = grupoPayload.premio.puro;
                grupoProposta.PremioTotal__c = grupoPayload.premio.total;
            }
            if(grupoPayload.taxa!=null){
                grupoProposta.TaxaComercial__c = grupoPayload.taxa.comercial;
                grupoProposta.TaxaPura__c = grupoPayload.taxa.pura;
                grupoProposta.TaxaTotal__c = grupoPayload.taxa.total;
            }
        }
        //PLV-5169-INICIO
        //grupoProposta.QuantidadeVidas__c = grupoPayload.qtdeVidas==null ? 1 : grupoPayload.qtdeVidas; //PLV-4788 INICIO/FIM - PEDRO AUGUSTO BRAZ
        grupoProposta.QuantidadeVidas__c = grupo.QuantidadeVidas__c;
        //PLV-5169-FIM
        grupoProposta.IOF__c = grupoPayload!=null && grupoPayload.iof!=null ? grupoPayload.iof :grupoProposta.IOF__c!=null? grupoProposta.IOF__c : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: ipopula os ojetos da nova proposta baseados no orçamento
*/
    private void popularSeguradoProposta(SeguradoOrcamento__c segurado, SeguradoProposta__c seguradoProposta, EmissaoTO.SeguradoTO seguradoPayloadProposta) //PLV-4440 - INICIO/FIM
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
        seguradoProposta.TemDependentes__c = segurado.TemDependentes__c; //PLV-4441-VI-Fix4 - INICIO/FIM

        seguradoProposta.DescontoAgravoMonetarioComercial__c = segurado.DescontoAgravoMonetarioComercial__c;
        seguradoProposta.DescontoAgravoMonetarioInformado__c = segurado.DescontoAgravoMonetarioInformado__c;
        seguradoProposta.DescontoAgravoMonetarioTecnico__c = segurado.DescontoAgravoMonetarioTecnico__c;
        seguradoProposta.DescontoAgravoPercentualComercial__c = segurado.DescontoAgravoPercentualComercial__c;
        seguradoProposta.DescontoAgravoPercentualInformado__c = segurado.DescontoAgravoPercentualInformado__c;
        seguradoProposta.DescontoAgravoPercentualTecnico__c = segurado.DescontoAgravoPercentualTecnico__c;

        //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
        //MOCK ENQUANTO A PLV-5097 NÃO FOR LIBERADA
        //seguradoPayloadProposta.pessoa.dadosPessoaFisica.tipoEmpresa = 'cnpj';
        //seguradoPayloadProposta.pessoa.dadosPessoaFisica.numeroCnpj = '27536942000145';
        //seguradoPayloadProposta.pessoa.dadosPessoaFisica.qtdFuncionarios = 20;

        seguradoProposta.tipoEmpresa__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica.tipoEmpresa != null ? seguradoPayloadProposta.pessoa.dadosPessoaFisica.tipoEmpresa.toUpperCase() : ''; // PLV-5098 FIX03 INICIO/FIM
        seguradoProposta.numeroCnpj__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica.numeroCnpj;
        seguradoProposta.qtdFuncionarios__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica.qtdFuncionarios;
        //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH

        seguradoProposta.GrupoRisco__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica.grupoProfissao;  //PLV-5161 - INICIO/FIM

        //PLV-5126 INICIO
        List<String> dominioCicloVacinal = new List<String>{'0', '1', '2','3'};
        String cicloVacinalSegurado = seguradoPayloadProposta.pessoa.dadosPessoaFisica.CicloVacinal;
        seguradoProposta.CicloVacinal__c = dominioCicloVacinal.contains(cicloVacinalSegurado) ? cicloVacinalSegurado : null;
		//PLV-5126 FIM
        //seguradoProposta.UltimaVacinaCicloVacinal__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica.DataUltimaVacina; //PLV-5090 - FIX03 - INICIO/FIM

        //PLV-5066 INICIO
        seguradoProposta.Nome_do_segurado__c = seguradoPayloadProposta.nome;
        seguradoProposta.NomeSocial_do_Segurado__c = seguradoPayloadProposta.pessoa.nomeSocial; // LECVPV-184 INICIO/FIM
        
        seguradoProposta.Renda__c = segurado.FaixaRenda__c != null ? Decimal.valueOf(segurado.FaixaRenda__c) : 0;
        //PLV-5066 FIM

        //PLV-5090 - FIX03 - INICIO
        EmissaoTO.EnderecoTO enderecoResidencial = new EmissaoTO.EnderecoTO();
        EmissaoTO.EnderecoTO enderecoComercial = new EmissaoTO.EnderecoTO();

        for(EmissaoTO.EnderecoTO endereco : seguradoPayloadProposta.pessoa.enderecos){
            if(endereco.tipoEndereco.toUpperCase() == 'RESIDENCIAL') enderecoResidencial = endereco;
            else if(endereco.tipoEndereco.toUpperCase() == 'COMERCIAL') enderecoComercial = endereco;
        }
        
        seguradoProposta.logradouroResidencial__c = enderecoResidencial.logradouro;
        seguradoProposta.numeroResidencial__c = enderecoResidencial.numeroLogradouro;
        seguradoProposta.ComplementoResidencial__c = enderecoResidencial.complemento;
        seguradoProposta.CidadeResidencial__c = enderecoResidencial.cidade;
        //VIAG-205 INÍCIO
        String enderecoCep = enderecoResidencial.cep + '-' + enderecoResidencial.complementoCep;
        if(enderecoCep != null && enderecoCep != '-'){
            seguradoProposta.cepResidencial__c = enderecoCep.replaceAll('\\.', '');
        }
        //VIAG-205 FIM
        seguradoProposta.paisResidencial__c = enderecoResidencial.paisResidencia;
        seguradoProposta.UFResidencial__c = enderecoResidencial.uf;
        seguradoProposta.bairroResidencial__c = enderecoResidencial.bairro;

        seguradoProposta.LogradouroComercial__c = enderecoComercial.logradouro;
        seguradoProposta.NumeroComercial__c = enderecoComercial.numeroLogradouro;
        seguradoProposta.ComplementoComercial__c = enderecoComercial.complemento;
        seguradoProposta.CidadeComercial__c = enderecoComercial.cidade;
        //VIAG-205 INÍCIO
        String enderecoCepComercial =  enderecoComercial.cep + '-' + enderecoComercial.complementoCep;
        if(enderecoCepComercial != null && enderecoCepComercial != '-'){
        	seguradoProposta.CEPComercial__c = enderecoCepComercial.replaceAll('\\.', '');
        }
        //VIAG-205 FIM
        seguradoProposta.PaisComercial__c = enderecoComercial.paisResidencia;
        seguradoProposta.UFComercial__c = enderecoComercial.uf;
        seguradoProposta.BairroComercial__c = enderecoComercial.bairro;
        //PLV-5090 - FIX03 - FIM
        
        
        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        Integer indice = 0;
        //PLV-4798 - INICIO - GUSTAVO
        if('Viagem'.equalsIgnoreCase(this.segmento)) {
            indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
        }
        //PLV-4798 - FIM - GUSTAVO
        EmissaoTO.GrupoTO grupoPayload = null;
        EmissaoTO.DescontoagravoTO descontoAgravo = null;
        //PLV-4800 - INÍCIO
        EmissaoTO.PremioTO premio = null; 
        EmissaoTO.TaxaTO taxa = null;
        //PLV-4800 - FIM
        if(this.mapOpcaoDescontoGrupos !=null && !this.mapOpcaoDescontoGrupos.isEmpty() && this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice)!=null){
            grupoPayload = this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice);
            descontoAgravo = grupoPayload.segurados[0].descontoAgravo != null ? grupoPayload.segurados[0].descontoAgravo[0] : null;
            //PLV-4800 - INÍCIO
            premio = grupoPayload.segurados[0].premio != null ? grupoPayload.segurados[0].premio : null;
            taxa = grupoPayload.segurados[0].taxa != null ? grupoPayload.segurados[0].taxa : null;
            //PLV-4800 - FIM
        }

        if(descontoAgravo!=null){
            if(descontoAgravo.tipo=='FPG'){
                seguradoProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                seguradoProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
            }else if(descontoAgravo.tipo == 'TPR'){
                seguradoProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                seguradoProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
            }
            //PLV-4800 - INÍCIO
            if(premio != null){
                seguradoProposta.PremioIntegral__c = premio.integral; //PLV-5351 INICIO/FIM
                seguradoProposta.PremioComercial__c = premio.comercial;
                seguradoProposta.PremioPuro__c = premio.puro;
                seguradoProposta.PremioTotal__c = premio.total;
            }
            if(taxa != null){
                seguradoProposta.TaxaComercial__c = taxa.comercial;
                seguradoProposta.TaxaPura__c = taxa.pura;
                seguradoProposta.TaxaTotal__c = taxa.total;
            }
            //PLV-4800 - FIM
        }
        //AV-658 INICIO 
        //seguradoProposta.IOF__c = grupoPayload!=null && grupoPayload.iof!=null ? grupoPayload.iof :segurado.IOF__c!=null? segurado.IOF__c : 0;
        seguradoProposta.IOF__c = grupoPayload.segurados[0].iof !=null ? grupoPayload.segurados[0].iof : 0;
        //AV-658 FIM 
        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

        //INICIO | PLV-2610			
        seguradoProposta.VigenciaInicial__c = this.proposta.propostaWrapper.sfProposta.VigenciaInicial__c;
        seguradoProposta.VigenciaFinal__c = this.proposta.propostaWrapper.sfProposta.VigenciaFinal__c;
        //INICIO | PLV-2610
        //PLV-4440 - INICIO

        //PLV-4563 - Vinícius Caetano Globant -INICIO
        if(seguradoPayloadProposta.responsavelFinanceiro != null){
            seguradoProposta.ResponsavelFinanceiroSeguro__c = seguradoPayloadProposta.responsavelFinanceiro;
            /*if(seguradoPayloadProposta.responsavelFinanceiro == false){
                if(seguradoPayloadProposta.nome != null)
                    seguradoProposta.NomeResponsavel__c = seguradoPayloadProposta.nome;
                if(seguradoPayloadProposta.cpf != null)
                    seguradoProposta.CpfResponsavel__c = seguradoPayloadProposta.cpf;
                if(seguradoPayloadProposta.vinculoComSegurado != null)
                    seguradoProposta.VinculoComSegurado__c = seguradoPayloadProposta.vinculoComSegurado;
            }*/
                        if(seguradoProposta.ResponsavelFinanceiroSeguro__c == false){
                //PLV-4911 - INICIO - PEDRO AUGUSTO BRAZ
                String idExterno = seguradoPayloadProposta.responsavelFinanceiroSeguro.dadosPessoaFisica.numeroCpf + seguradoPayloadProposta.responsavelFinanceiroSeguro.dadosPessoaFisica.digitoCpf;
                Account responsavel = [SELECT id, Name FROM Account WHERE IdExterno__c  = :idExterno LIMIT 1];
                seguradoProposta.ResponsavelPagamento__c = responsavel.Id;
                seguradoProposta.NomeResponsavel__c = seguradoPayloadProposta.responsavelFinanceiroSeguro.nome;
                seguradoProposta.CpfResponsavel__c = seguradoPayloadProposta.responsavelFinanceiroSeguro.dadosPessoaFisica.numeroCpf + seguradoPayloadProposta.responsavelFinanceiroSeguro.dadosPessoaFisica.digitoCpf;
                seguradoProposta.VinculoComSegurado__c = seguradoPayloadProposta.responsavelFinanceiroSeguro.vinculoComSegurado;
                if(seguradoPayloadProposta.responsavelFinanceiroSeguro.enderecos!=null && seguradoPayloadProposta.responsavelFinanceiroSeguro.enderecos.size()>0){
                    for(EmissaoTO.EnderecoTO endereco : seguradoPayloadProposta.responsavelFinanceiroSeguro.enderecos){
                        if(endereco.cep != null && endereco.cep != ''){
                            System.debug('endereco1> : ' + endereco);
                            Endereco__c endereco2Insert = new Endereco__c();
                            endereco2Insert.Conta__c = responsavel.Id;
                            //VIAG-205 INÍCIO
                            String enderecoCepInsert = (endereco.cep + endereco.complementoCep) != null ? (endereco.cep + endereco.complementoCep) : '';
                            if(enderecoCepInsert != ''){
                                endereco2Insert.CEP__c = enderecoCepInsert.replaceAll('\\.', '');
                            }
                            //VIAG-205 FIM
                            endereco2Insert.Logradouro__c = endereco.logradouro;
                            endereco2Insert.TipoEndereco__c = endereco.tipoEndereco;
                            endereco2Insert.TipoLogradouro__c = endereco.tipoLogradouro;
                            endereco2Insert.Numero__c = endereco.numeroLogradouro;
                            endereco2Insert.Complemento__c = endereco.complemento;
                            endereco2Insert.Bairro__c = endereco.bairro;
                            endereco2Insert.Cidade__c = endereco.cidade;
                            endereco2Insert.Estado__c = endereco.uf;
                            endereco2Insert.Pais__c = endereco.paisResidencia;
                            endereco2Insert.MaisAtual__c = true;
                            endereco2Insert.IdExterno__c = endereco2BO.montarIdExterno(endereco2Insert);
                            this.mapEndrecosToInsert.put(endereco2Insert.IdExterno__c,endereco2Insert);//PLV-4894 - INICIO/FIM
                        }
                    }
                }
                if(!mapEndrecosToInsert.values().isEmpty())
                upsert this.mapEndrecosToInsert.values() IdExterno__c;
                //PLV-4911 - FIM - PEDRO AUGUSTO BRAZ
            }
        }
        //PLV-4563 - Vinícius Caetano Globant - FIM

        seguradoProposta.Fumante__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica.fumante != null ? seguradoPayloadProposta.pessoa.dadosPessoaFisica.fumante : false; //PLV-4441-VI-Fix4 - INICIO/FIM  // II-25

        // PLV-4440
        seguradoProposta.PEP__c = seguradoPayloadProposta.pessoa.pessoaExpostaPoliticamente == 'Nao' ? 'Não' : seguradoPayloadProposta.pessoa.pessoaExpostaPoliticamente;
        if('RelacionamentoProximo'.equals(seguradoPayloadProposta.pessoa.pessoaExpostaPoliticamente)){
            seguradoProposta.TipoPessoaRelacionamentoProximo__c = 'PessoaFisica';					
            seguradoProposta.NomePessoaRelacionamentoProximo__c = seguradoPayloadProposta.pessoa.pessoaPEP.nome;
            seguradoProposta.CpfPessoaRelacionamentoProximo__c = seguradoPayloadProposta.pessoa.pessoaPEP.cpf;
            seguradoProposta.GrauParentesco__c = seguradoPayloadProposta.pessoa.pessoaPEP.grauParentesco;                
        }

        seguradoProposta.Pais_Residente__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica != null ? seguradoPayloadProposta.pessoa.dadosPessoaFisica.paisResidente : 'Brasil'; //PLV-4874 - Inicio/Fim
        seguradoProposta.PaisDeOrigem__c = seguradoPayloadProposta.pessoa.dadosPessoaFisica != null ? seguradoPayloadProposta.pessoa.dadosPessoaFisica.paisDeOrigem : 'Brasil'; //PLV-5231 - INICIO/FIM

        seguradoProposta.FaixaRenda__c  = seguradoPayloadProposta.faixaRenda;
        seguradoProposta.RegimeTrabalho__c  = seguradoPayloadProposta.formaTrabalho;
        String profissao = seguradoPayloadProposta.ocupacaoProfissionalPrincipal ;
        seguradoProposta.Profissao__r = String.isNotEmpty(profissao) ? new Profissao__c(CodigoProfissao__c = profissao) : null;
        //PLV-4440 - FIM
        // PLV-4675 - INICIO
        Account contaSegurado = [SELECT Id, Melhorperiodocontato__c FROM Account WHERE Id =: segurado.Conta__c];
        //List<Endereco__c> listEndereco = [Select id, TIpoEndereco__c from Endereco__c where Conta__c =: segurado.Conta__c AND MaisAtual__c = true order by CreatedDate asc]; // PLV-4900 - INICIO/FIM
        String endComercialId;
        String endResidencialId;
        // PLV-4675 - COMPLEMENTO INICIO
        String endVeraneioId;
        String endRecadoId;

        // PLV-4900 - INICIO
        for(Endereco__c e :mapEndrecosToInsert.values()) {

            if(e.Conta__c != contaSegurado.id) continue;
            if(e.idExterno__c == null) continue;

            Endereco__c endrc = new Endereco__c(idExterno__c = e.idExterno__c);

            if(e.TipoEndereco__c == 'Comercial')
            seguradoProposta.Endereco_comercial__r     = endrc;
            
            else if(e.TipoEndereco__c == 'Residencial')
            seguradoProposta.Endereco_residencial__r   = endrc;

            else if(e.TipoEndereco__c == 'Veraneio')
            seguradoProposta.Endereco_veraneio__r      = endrc;
            
            else if(e.TipoEndereco__c == 'Recado')
            seguradoProposta.Endereco_de_recado__r     = endrc;
        }

        // for(Endereco__c e : listEndereco){
        //     if(e.TipoEndereco__c == 'Comercial')
        //         endComercialId = e.Id;
        //     else if(e.TipoEndereco__c == 'Residencial')
        //         endResidencialId = e.Id;
        //     else if(e.TipoEndereco__c == 'Veraneio')
        //         endVeraneioId = e.Id;
        //     else if(e.TipoEndereco__c == 'Recado')
        //         endRecadoId = e.Id;
        // }
        // PLV-4900 - FIM
        
        contaSegurado.Melhorperiodocontato__c = this.proposta.propostaWrapper.sfProposta.MelhorPeriodoContato__c == null ? 'I' : this.proposta.propostaWrapper.sfProposta.MelhorPeriodoContato__c; 
        update contaSegurado;
        seguradoProposta.Nome_do_segurado__c = segurado.Conta__r.Name;
        seguradoProposta.Celular__c = segurado.Conta__r.PersonMobilePhone;
        seguradoProposta.Telefone_residencial__c = segurado.Conta__r.PersonHomePhone;
        seguradoProposta.Telefone_comercial__c = segurado.Conta__r.Phone;
        seguradoProposta.EmpresaTrabalhaSocio__c = segurado.Conta__r.EmpresaTrabalhaSocio__c;
        seguradoProposta.RamoAtividade__c = segurado.Conta__r.Ramo_de_atividade__c; // PLV-4810 INICIO/FIM SYS4B ODEMIR
        seguradoProposta.Email__c = segurado.Conta__r.PersonEmail;
        seguradoProposta.Melhor_periodo_para_contato__c = contaSegurado.Melhorperiodocontato__c;
        seguradoProposta.Renda__c = segurado.Conta__r.Renda__c;
        // PLV-4900 - INICIO
        // seguradoProposta.Endereco_residencial__c = endResidencialId;
        // seguradoProposta.Endereco_comercial__c = endComercialId;
        // seguradoProposta.Endereco_de_recado__c = endRecadoId;
        // seguradoProposta.Endereco_veraneio__c = endVeraneioId;
        // PLV-4900 - FIM
        // PLV-4675 - FIM
        // PLV-4675 - COMPLEMENTO FIM

    }
    
    private void popularSeguradoPropostaViagem(EmissaoTO.SeguradoTO seguradoPayloadProposta, SeguradoProposta__c seguradoProposta, EmissaoTO.PessoaTO responsavelFinanceiro) //PLV-4911 - INICIO/FIM
    {
        
        try{
            List<String> lNomeSplit = seguradoPayloadProposta.pessoa.nome.split(' ', 2);
            String firstName = lNomeSplit.size() == 2 ? lNomeSplit.get(0) : '';
            String LastName = lNomeSplit.size() == 2 ? lNomeSplit.get(1) : lNomeSplit.get(0);
            String pepConta = '';
            String nacionalidade = '';
            String idExterno = montarChavePessoa(seguradoPayloadProposta.pessoa);
            system.debug('popularSeguradoPropostaViagem - idExterno: ' + idExterno);
            //PLV-4440 - FIX INICIO

            //PLV-4621-INICIO
            if(seguradoPayloadProposta.pessoa?.pessoaExpostaPoliticamente != null){
                if(seguradoPayloadProposta.pessoa.pessoaExpostaPoliticamente == 'RelacionamentoProximo'){
                    pepConta = 'Relacionamento próximo';
                    seguradoProposta.PEP__c = 'RelacionamentoProximo';
                }else if(seguradoPayloadProposta.pessoa.pessoaExpostaPoliticamente == 'Sim'){
                    pepConta = 'Sim';
                    seguradoProposta.PEP__c = 'Sim';
                }else if(seguradoPayloadProposta.pessoa.pessoaExpostaPoliticamente == 'Nao'){
                    pepConta = 'Não';
                    seguradoProposta.PEP__c = 'Não';
                }
            }else{
                if(seguradoPayloadProposta.pessoa?.pep == 'RelacionamentoProximo'){
                    pepConta = 'Relacionamento próximo';
                    seguradoProposta.PEP__c = 'RelacionamentoProximo';
                }else if(seguradoPayloadProposta.pessoa?.pep == 'Sim'){
                    pepConta = 'Sim';
                    seguradoProposta.PEP__c = 'Sim';
                }else if(seguradoPayloadProposta.pessoa?.pep == 'Nao'){
                    pepConta = 'Não';
                    seguradoProposta.PEP__c = 'Não';
                }
            }            
            seguradoProposta.GrauParentesco__c = seguradoPayloadProposta.pessoa?.pessoaRelacionamentoPep?.grauParentesco;
            seguradoProposta.TipoPessoaRelacionamentoProximo__c = seguradoPayloadProposta.pessoa?.pessoaRelacionamentoPep?.tipo;
            seguradoProposta.NomePessoaRelacionamentoProximo__c = seguradoPayloadProposta.pessoa?.pessoaRelacionamentoPep?.nome;
            //seguradoProposta.CpfPessoaRelacionamentoProximo__c =  seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.dadosPessoaFisica.numeroCpf;
            //PLV-4621 - FIM
            //PLV-4440 - FIX FIM
            
            // if(seguradoPayloadProposta.pessoa.enderecos[0].paisResidencia == 'Brasil'){
            // 	nacionalidade = 'Brasileira';
            // }else{
            // 	nacionalidade = 'Estrangeira';
            // }
            
            Account contaSegurado = new Account(FirstName = firstName,
                                                LastName = LastName,
                                                Cpf__c = idExterno,
                                                idExterno__c = idExterno, 
                                                // PLV-4675 INICIO
                                                MelhorPeriodoContato__c = this.proposta.propostaWrapper.sfProposta.MelhorPeriodoContato__c == null ? 'I' : this.proposta.propostaWrapper.sfProposta.MelhorPeriodoContato__c,
                                                // PLV-4675 FIM
                                                pep__c = pepConta,
                                                //nacionalidade__c = nacionalidade,
                                                PersonBirthdate = Date.ValueOf(seguradoPayloadProposta.pessoa.dadosPessoaFisica.dataNascimento)
                                               );
            
            system.debug('contaSegurado: ' + contaSegurado);
            
            upsert contaSegurado idExterno__c;								
             // PLV-4675 - INICIO
             contaSegurado = [SELECT Id, Name, NomeSocial__c,PersonMobilePhone,PersonHomePhone,Phone,EmpresaTrabalhaSocio__c, // LECVPV-188-FIX05
             Ramo_de_atividade__c, // PLV-4810 INICIO/FIM SYS4B ODEMIR
             PersonEmail,MelhorPeriodoContato__c,Renda__c FROM Account WHERE Id =: contaSegurado.Id];
            //  Endereco__c enderecoComercial = [Select id from Endereco__c where Conta__c =: contaSegurado.Id AND MaisAtual__c = true AND TipoEndereco__c = 'Comercial' order by CreatedDate Desc LIMIT 1 ]; 
            //  Endereco__c enderecoResidencial = [Select id from Endereco__c where Conta__c =: contaSegurado.Id AND MaisAtual__c = true AND TipoEndereco__c = 'Residencial' order by CreatedDate Desc LIMIT 1]; 
            //List<Endereco__c> listEndereco = [Select id, TIpoEndereco__c from Endereco__c where Conta__c =: contaSegurado.Id AND MaisAtual__c = true order by CreatedDate asc]; //PLV-4900 - INICIO/FIM
            String endComercialId;
            String endResidencialId;
            // PLV-4675 - COMPLEMENTO INICIO
            String endRecadoId;
            String endVeraneioId;

            //PLV-4900 - INICIO
            for(Endereco__c e :mapEndrecosToInsert.values()) {
            
                if(e.Conta__c != contaSegurado.id) continue;
                if(e.idExterno__c == null) continue;
    
                Endereco__c endrc = new Endereco__c(idExterno__c = e.idExterno__c);
    
                if(e.TipoEndereco__c == 'Comercial')
                seguradoProposta.Endereco_comercial__r     = endrc;
                
                else if(e.TipoEndereco__c == 'Residencial')
                seguradoProposta.Endereco_residencial__r   = endrc;
    
                else if(e.TipoEndereco__c == 'Veraneio')
                seguradoProposta.Endereco_veraneio__r      = endrc;
                
                else if(e.TipoEndereco__c == 'Recado')
                seguradoProposta.Endereco_de_recado__r     = endrc;
            }

            // for(Endereco__c e : listEndereco){
            //     if(e.TIpoEndereco__c == 'Comercial')
            //         endComercialId = e.Id;
            //     else if(e.TIpoEndereco__c == 'Residencial') // PLV-4675-FIX
            //         endResidencialId = e.Id;
            //     else if(e.TIpoEndereco__c == 'Recado')
            //         endRecadoId = e.Id;
            //     else if(e.TIpoEndereco__c == 'Veraneio')
            //         endVeraneioId = e.Id;
            // }
            //PLV-4900 - FIM
          
            seguradoProposta.Nome_do_segurado__c = contaSegurado.Name;
            seguradoProposta.NomeSocial_do_Segurado__c = contaSegurado.NomeSocial__c; // LECVPV-188-FIX05 INICIO/FIM
            seguradoProposta.Celular__c = contaSegurado.PersonMobilePhone;
            seguradoProposta.Telefone_residencial__c = contaSegurado.PersonHomePhone;
            seguradoProposta.Telefone_comercial__c = contaSegurado.Phone;
            seguradoProposta.EmpresaTrabalhaSocio__c = contaSegurado.EmpresaTrabalhaSocio__c;
            seguradoProposta.Email__c = contaSegurado.PersonEmail;
            seguradoProposta.Melhor_periodo_para_contato__c = this.proposta.propostaWrapper.sfProposta.MelhorPeriodoContato__c;
            seguradoProposta.Renda__c = contaSegurado.Renda__c;
            //PLV-4900 - INICIO
            // seguradoProposta.Endereco_residencial__c = endResidencialId;
            // seguradoProposta.Endereco_comercial__c = endComercialId;
            // seguradoProposta.Endereco_de_recado__c = endRecadoId;
            // seguradoProposta.Endereco_veraneio__c = endVeraneioId;
            //PLV-4900 - FIM
            // PLV-4675 - COMPLEMENTO FIM
            seguradoProposta.Conta__c = contaSegurado.id;
            //PLV-3565 Início
            //seguradoProposta.formaPagamento__c = this.proposta.propostaWrapper.sfProposta.FormaPagamento__c;
            //seguradoProposta.responsavelPagamento__r = ContaResponsavelPagto;
            //seguradoProposta.planoParcelamento__c = this.planoParcelamento;			
            if(seguradoPayloadProposta.numero != null) seguradoProposta.Numero__c = Integer.Valueof(seguradoPayloadProposta.numero);
            //if(payload.proposta.contratantes[0].dadosPagamento.quantidadeParcelas != null) seguradoProposta.QuantidadeParcelas__c = payload.proposta.contratantes[0].dadosPagamento.quantidadeParcelas;
            system.debug('payload.proposta - payload: ' + payload);
            system.debug('payload.proposta - payload.proposta: ' + payload.proposta);
            system.debug('payload.proposta - payload.proposta.contratantes[0]: ' + payload.proposta.contratantes[0]);
            system.debug('payload.proposta - payload.proposta.contratantes[0].dadosPagamento: ' + payload.proposta.contratantes[0].dadosPagamento);			
            
            //seguradoProposta.TipoResponsavelPagamento__c = 'CON';
            system.debug('payload.proposta - tipoResponsavelPagamento: ' + payload.proposta.contratantes[0].dadosPagamento.tipoResponsavelPagamento);
            
            // if(payload.proposta.contratantes[0].dadosPagamento.tipoResponsavelPagamento != null 
            // && payload.proposta.contratantes[0].dadosPagamento.tipoResponsavelPagamento != '') seguradoProposta.VencimentoPrimeiraParcela__c = Date.ValueOf(payload.proposta.contratantes[0].dadosPagamento.vencimentoPrimeiraParcela);
            //PLV-3565 Fim
            system.debug('payload.proposta - vencimentoPrimeiraParcela: ' + payload.proposta.contratantes[0].dadosPagamento.vencimentoPrimeiraParcela);
            
            //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            Integer indice = 0;
            //PLV-4798 - INICIO - GUSTAVO
            if('Viagem'.equalsIgnoreCase(this.segmento)) {
                indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
            }
            //PLV-4798 - FIM - GUSTAVO
            EmissaoTO.GrupoTO grupoPayload = new EmissaoTO.GrupoTO();//ANNVI-48 - INICIO
            grupoPayload.segurados = new List<EmissaoTO.SeguradoTO>();
            EmissaoTO.DescontoagravoTO descontoAgravo = new EmissaoTO.DescontoagravoTO();
            //PLV-4800 - INÍCIO
            EmissaoTO.PremioTO premio = new EmissaoTO.PremioTO();
            EmissaoTO.TaxaTO taxa = new EmissaoTO.TaxaTO();//ANNVI-48 - FIM
            //PLV-4800 - FIM

            if(this.mapOpcaoDescontoGrupos !=null && !this.mapOpcaoDescontoGrupos.isEmpty() && this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice)!=null){
                grupoPayload = this.mapOpcaoDescontoGrupos.get(this.opcaoPagamentoCliente).get(indice);
                descontoAgravo = grupoPayload.segurados[0].descontoAgravo != null ? grupoPayload.segurados[0].descontoAgravo[0] : null;
                //PLV-4800 - INÍCIO
                premio = grupoPayload.segurados[0].premio != null ? grupoPayload.segurados[0].premio : null;
                taxa = grupoPayload.segurados[0].taxa != null ? grupoPayload.segurados[0].taxa : null;
                //PLV-4800 - FIM
            }

            if(descontoAgravo!=null){
                if(descontoAgravo.tipo=='FPG'){
                    seguradoProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                    seguradoProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
                }else if(descontoAgravo.tipo == 'TPR'){
                    seguradoProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                    seguradoProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
                }
		//PLV-4800 - INÍCIO
                if(premio!=null){
                    seguradoProposta.PremioIntegral__c = premio.integral; //PLV-5351 INICIO/FIM
                    seguradoProposta.PremioComercial__c = premio.comercial;
                    seguradoProposta.PremioPuro__c = premio.puro;
                    seguradoProposta.PremioTotal__c = premio.total;
                }
                if(taxa!=null){
                    seguradoProposta.TaxaComercial__c = taxa.comercial;
                    seguradoProposta.TaxaPura__c = taxa.pura;
                    seguradoProposta.TaxaTotal__c = taxa.total;
                }
		//PLV-4800 - FIM
            }
            //AV-658 INICIO 
            //seguradoProposta.IOF__c = grupoPayload!=null && grupoPayload.iof!=null ? grupoPayload.iof : 0;
            if(!grupoPayload.segurados.isEmpty()){ //ANNVI-48 - INICIO
                seguradoProposta.IOF__c = grupoPayload.segurados[0].iof !=null ? grupoPayload.segurados[0].iof : 0;
            }//ANNVI-48 - FIM
            //AV-658 FIM 
            //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

            //PLV-4563 - INICIO - Vinícius Caetano - Globant
            if(responsavelFinanceiro != null){
                //PLV-4911 - INICIO - PEDRO AUGUSTO BRAZ
                String idExternoResponsavel = responsavelFinanceiro.dadosPessoaFisica.numeroCpf + responsavelFinanceiro.dadosPessoaFisica.digitoCpf;
                Account responsavel = [SELECT id, Name FROM Account WHERE IdExterno__c  = :idExternoResponsavel LIMIT 1];
                seguradoProposta.ResponsavelPagamento__c = responsavel.Id;
                seguradoProposta.NomeResponsavel__c = responsavelFinanceiro.nome;
                seguradoProposta.CpfResponsavel__c = responsavelFinanceiro.dadosPessoaFisica.numeroCpf + responsavelFinanceiro.dadosPessoaFisica.digitoCpf;
                seguradoProposta.VinculoComSegurado__c = responsavelFinanceiro.vinculoComSegurado;
                if(responsavelFinanceiro.enderecos!=null && responsavelFinanceiro.enderecos.size()>0){
                    for(EmissaoTO.EnderecoTO endereco : responsavelFinanceiro.enderecos){
                        if(endereco.cep != null && endereco.cep != ''){
                            System.debug('endereco1> : ' + endereco);
                            Endereco__c endereco2Insert = new Endereco__c();
                            endereco2Insert.Conta__c = responsavel.Id;
                            //VIAG-205 INÍCIO
                            String enderecoCep = (endereco.cep + endereco.complementoCep) != null ? (endereco.cep + endereco.complementoCep) : '';
                            if(enderecoCep != ''){
                                endereco2Insert.CEP__c = enderecoCep.replaceAll('\\.', '');
                            }
                            //VIAG-205 FIM
                            endereco2Insert.Logradouro__c = endereco.logradouro;
                            endereco2Insert.TipoEndereco__c = endereco.tipoEndereco;
                            endereco2Insert.TipoLogradouro__c = endereco.tipoLogradouro;
                            endereco2Insert.Numero__c = endereco.numeroLogradouro;
                            endereco2Insert.Complemento__c = endereco.complemento;
                            endereco2Insert.Bairro__c = endereco.bairro;
                            endereco2Insert.Cidade__c = endereco.cidade;
                            endereco2Insert.Estado__c = endereco.uf;
                            endereco2Insert.Pais__c = endereco.paisResidencia;
                            endereco2Insert.MaisAtual__c = true;
                            endereco2Insert.IdExterno__c = endereco2BO.montarIdExterno(endereco2Insert);
                            this.mapEndrecosToInsert.put(endereco2Insert.IdExterno__c,endereco2Insert);//PLV-4894 - INICIO/FIM
                        }
                    }
                }
                if(!mapEndrecosToInsert.values().isEmpty())
                upsert this.mapEndrecosToInsert.values() IdExterno__c;
                //PLV-4911 - FIM - PEDRO AUGUSTO BRAZ
            } else {
                seguradoProposta.ResponsavelPagamento__c = contaSegurado.id;
                seguradoProposta.ResponsavelFinanceiroSeguro__c = true;
            }
            //PLV-4563 - FIM 
            
            //PLV-3455-Complemento2 - FIM
            
            
            if(seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep != null){
                
                system.debug('popularSeguradoPropostaViagem - seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.tipo: ' + seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.tipo);
                
                if(seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.tipo == 'FIS'){
                    seguradoProposta.TipoPessoaRelacionamentoProximo__c = 'PessoaFisica';					
                }else{
                    seguradoProposta.TipoPessoaRelacionamentoProximo__c = 'PessoaJuridica';
                }
                
                system.debug('popularSeguradoPropostaViagem - seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.nome: ' + seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.nome);
                seguradoProposta.NomePessoaRelacionamentoProximo__c = seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.nome;
                String CpfPessoaRelacionamentoPep = seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.dadosPessoaFisica.numeroCpf + seguradoPayloadProposta.pessoa.pessoaRelacionamentoPep.dadosPessoaFisica.digitoCpf;
                system.debug('popularSeguradoPropostaViagem - CpfPessoaRelacionamentoPep: ' + CpfPessoaRelacionamentoPep);
                seguradoProposta.CpfPessoaRelacionamentoProximo__c = CpfPessoaRelacionamentoPep;
            }
            
            if(seguradoPayloadProposta.contatoEmergencia != null){
                seguradoProposta.NomeContatoEmergencia__c = seguradoPayloadProposta.contatoEmergencia.nome;
                seguradoProposta.TelefoneContatoEmergencia__c = seguradoPayloadProposta.contatoEmergencia.ddd + seguradoPayloadProposta.contatoEmergencia.telefone;
            }
            
            if(this.proposta.propostaWrapper.sfProposta.VigenciaInicial__c != null)	
                seguradoProposta.VigenciaInicial__c = this.proposta.propostaWrapper.sfProposta.VigenciaInicial__c;
            
            if(this.proposta.propostaWrapper.sfProposta.VigenciaFinal__c != null)
                seguradoProposta.VigenciaFinal__c = this.proposta.propostaWrapper.sfProposta.VigenciaFinal__c;

            //******************************************************************************************** */

            
        }catch(exception e){
            throw new PropostaBuilderException('Origem: metodo >> popularSeguradoPropostaViagem - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }			
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    @TestVisible //ANNVI-48 - INICIO/
    private void popularBeneficiarioProposta(EmissaoTO.BeneficiarioTO beneficiario, BeneficiarioSeguradoProposta__c beneficiarioProposta)
    {
        if (beneficiario == null) return;
        //PLV-4440 - FIX INICIO
        if(beneficiario.pessoa != null){
        beneficiarioProposta.TipoBeneficiario__c = beneficiario.tipoBeneficiario;
        beneficiarioProposta.MotivoSemCpfCnpj__c = beneficiario.motivoSemCpfCnpj;
        
        if (beneficiario.tipoBeneficiario == 'Conforme artigo 792 do código civil') return;
        
        system.debug('beneficiario: '+JSON.serialize(beneficiario));
        
        String cpf = beneficiario.pessoa.dadosPessoaFisica.numeroCpf + beneficiario.pessoa.dadosPessoaFisica.digitoCpf;
        
        beneficiarioProposta.TipoBeneficiario__c = beneficiario.tipoBeneficiario;
        beneficiarioProposta.Nome__c = beneficiario.pessoa.nome;
        beneficiarioProposta.NomeSocial__c = beneficiario.pessoa.nomeSocial; // LECVPV-184 INICIO/FIM
       // beneficiarioProposta.CpfCnpj__c = cpf;
        beneficiarioProposta.CpfCnpj__c = beneficiario.cpf;
        beneficiarioProposta.Participacao__c = beneficiario.participacao;
        beneficiarioProposta.GrauParentesco__c = beneficiario.grauParentesco;
        beneficiarioProposta.Pep__c = beneficiario.pessoa.dadosPessoaFisica.pep;
        beneficiarioProposta.NomePessoaPep__c = beneficiario.pessoa.dadosPessoaFisica.nomePessoaPep;
        beneficiarioProposta.CpfPep__c = beneficiario.pessoa.dadosPessoaFisica.cpfPep;
        beneficiarioProposta.GrauParentescoPep__c = beneficiario.pessoa.dadosPessoaFisica.tipoRelacionamentoPep;
        beneficiarioProposta.MotivoSemCpfCnpj__c = beneficiario.motivoSemCpfCnpj;
        beneficiarioProposta.ImprimirCertificadoSeguro__c = beneficiario.imprimirCertificado==null ? false : beneficiario.imprimirCertificado;//PLV-4440
        }else{
            system.debug('beneficiario: '+beneficiario);
            
            beneficiarioProposta.Data_de_Nascimento__c = beneficiario.nascimento;
            beneficiarioProposta.PercentualIndenizacao__c = beneficiario.percentualIndenizacao;
            beneficiarioProposta.CpfCnpj__c = beneficiario.cpf;
            beneficiarioProposta.Nome__c = beneficiario.nome;
            beneficiarioProposta.NomeSocial__c = beneficiario.nomeSocial; // LECVPV-184 INICIO/FIM
            beneficiarioProposta.GrauParentesco__c = beneficiario.grauParentesco;
            beneficiarioProposta.BeneficiarioGrauParentescoOutros__c = beneficiario.grauParentescoOutros; // PLV-5231 INICIO/FIM
            beneficiarioProposta.TipoBeneficiario__c = beneficiario.tipoBeneficiario;
            beneficiarioProposta.ImprimirCertificadoSeguro__c = beneficiario.imprimirCertificado==null ? false : beneficiario.imprimirCertificado;//PLV-4440

        // beneficiarioProposta.Pep__c = 'Não';
            beneficiarioProposta.Participacao__c = beneficiario.percentualIndenizacao;
            beneficiarioProposta.Sexo__c = beneficiario.sexoBeneficiario; // PLV-4473 - complemento INICIO/FIM
        }
        //PLV-4440 - FIM FIX



    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/  @TestVisible //ANNVI-48 - INICIO
    private void popularGarantiaProposta(GarantiaOrcamento__c garantia, GarantiaProposta__c garantiaProposta, String nomeGrupo) //PLV-4340 - INICIO/FIM
    {
        if( garantia == null ) return;
        system.debug('garantia orcamento'+garantia);
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
        //PLV-3731 - INICIO

        //PLV-4620 FIX 2 INICIO
        garantiaProposta.Tipo_de_limite_de_utilizacao__c   = garantia.Tipo_de_limite_de_utilizacao__c;
        garantiaProposta.Limite_de_Uso__c         		   = garantia.Limite_de_Uso__c;
        //PLV-4620 FIX 2 FIM
        
        garantiaProposta.ValorCotacao__c = garantia.ValorCotacao__c;
        
        //PLV-3731 - FIM
        //PLV-3455 - INICIO - Trecho comentado
        /*garantiaProposta.PremioComercial__c = garantia.PremioComercial__c;
garantiaProposta.PremioPuro__c = garantia.PremioPuro__c;
garantiaProposta.PremioTotal__c = garantia.PremioTotal__c;
garantiaProposta.TaxaComercial__c = garantia.TaxaComercial__c;
garantiaProposta.TaxaPura__c = garantia.TaxaPura__c;
garantiaProposta.TaxaTotal__c = garantia.TaxaTotal__c;*/
        //PLV-3455 - FIM
        garantiaProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
        garantiaProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
        garantiaProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
        garantiaProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
        garantiaProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
        garantiaProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;
        
        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        Integer indice = 0;
        //PLV-4798 - INICIO - GUSTAVO
        if('Viagem'.equalsIgnoreCase(this.segmento)) {
            indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
        }
        //PLV-4798 - FIM - GUSTAVO
        EmissaoTO.CoberturaTO cobertura = null;
        EmissaoTO.DescontoagravoTO descontoAgravo = null;
        if(this.mapOpcaoDesconto!=null && !this.mapOpcaoDesconto.isEmpty() && this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).containsKey(garantia.Garantia__r.Sigla__c)){
            cobertura = this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).get(garantia.Garantia__r.Sigla__c);
            descontoAgravo = cobertura.descontoAgravo != null ? cobertura.descontoAgravo[0] : null;
        }

        if(descontoAgravo!=null){
            if(descontoAgravo.tipo=='FPG'){
                garantiaProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                garantiaProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
            }else if(descontoAgravo.tipo == 'TPR'){
                garantiaProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                garantiaProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
            }
            if(cobertura.premio!=null){
                garantiaProposta.PremioIntegral__c = cobertura.premio.integral; //PLV-5351 INICIO/FIM FIX 01
                garantiaProposta.PremioComercial__c = cobertura.premio.comercial;
                garantiaProposta.PremioPuro__c = cobertura.premio.puro;
                garantiaProposta.PremioTotal__c = cobertura.premio.total;
            }
            if(cobertura.taxa!=null){
                garantiaProposta.TaxaComercial__c = cobertura.taxa.comercial;
                garantiaProposta.TaxaPura__c = cobertura.taxa.pura;
                garantiaProposta.TaxaTotal__c = cobertura.taxa.total;
            }
        }
        garantiaProposta.IOF__c = cobertura!=null && cobertura.iof!=null ? cobertura.iof :0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularGarantiaContratanteProposta(GarantiaContratanteOrcamento__c garantia, GarantiaContratanteProposta__c garantiaContratanteProposta)
    {
        if(garantia == null) return;
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
        
        //PLV-3731 - INICIO
        garantiaContratanteProposta.ValorCotacao__c = garantia.ValorCotacao__c;
        //PLV-3731 - FIM
        
        //PLV-3455 - INICIO - Trecho comentado
        /*garantiaContratanteProposta.PremioComercial__c = garantia.PremioComercial__c;
garantiaContratanteProposta.PremioPuro__c = garantia.PremioPuro__c;
garantiaContratanteProposta.PremioTotal__c = garantia.PremioTotal__c;
garantiaContratanteProposta.TaxaComercial__c = garantia.TaxaComercial__c;
garantiaContratanteProposta.TaxaPura__c = garantia.TaxaPura__c;
garantiaContratanteProposta.TaxaTotal__c = garantia.TaxaTotal__c;*/
        //PLV-3455 - FIM
        garantiaContratanteProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
        garantiaContratanteProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
        garantiaContratanteProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
        garantiaContratanteProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
        garantiaContratanteProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
        garantiaContratanteProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;
        
        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        Integer indice = 0;
        //PLV-4798 - INICIO - GUSTAVO
        if('Viagem'.equalsIgnoreCase(this.segmento)) {
            indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
        }
	//PLV-4798 - FIM - GUSTAVO
        EmissaoTO.CoberturaTO cobertura = null;
        EmissaoTO.DescontoagravoTO descontoAgravo = null;
        if(this.mapOpcaoDesconto!=null && !this.mapOpcaoDesconto.isEmpty() && this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).containsKey(garantia.Garantia__r.Sigla__c)){
            cobertura = this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).get(garantia.Garantia__r.Sigla__c);
            descontoAgravo = cobertura.descontoAgravo != null ? cobertura.descontoAgravo[0] : null;
        }

        if(descontoAgravo!=null){
            if(descontoAgravo.tipo=='FPG'){
                garantiaContratanteProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                garantiaContratanteProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
            }else if(descontoAgravo.tipo == 'TPR'){
                garantiaContratanteProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                garantiaContratanteProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
            }
            if(cobertura.premio!=null){
                garantiaContratanteProposta.PremioIntegral__c = cobertura.premio.integral; //PLV-5351 INICIO/FIM
                garantiaContratanteProposta.PremioComercial__c = cobertura.premio.comercial;
                garantiaContratanteProposta.PremioPuro__c = cobertura.premio.puro;
                garantiaContratanteProposta.PremioTotal__c = cobertura.premio.total;
            }
            if(cobertura.taxa!=null){
                garantiaContratanteProposta.TaxaComercial__c = cobertura.taxa.comercial;
                garantiaContratanteProposta.TaxaPura__c = cobertura.taxa.pura;
                garantiaContratanteProposta.TaxaTotal__c = cobertura.taxa.total;
            }
        }
        garantiaContratanteProposta.IOF__c = cobertura!=null && cobertura.iof!=null ? cobertura.iof :0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularGarantiaGrupoProposta(GarantiaGrupoOrcamento__c garantia, GarantiasGrupoProposta__c garantiaGrupoProposta) //PLV-4340 - INICIO/FIM
    {
        if( garantia == null) return;
        
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
        
        //PLV-3731 - INICIO
        garantiaGrupoProposta.ValorCotacao__c = garantia.ValorCotacao__c;
        //PLV-3731 - FIM
        
        //PLV-3455 - INICIO - Trecho comentado
        /*garantiaGrupoProposta.PremioComercial__c = garantia.PremioComercial__c;
        garantiaGrupoProposta.PremioPuro__c = garantia.PremioPuro__c;
        garantiaGrupoProposta.PremioTotal__c = garantia.PremioTotal__c;
        garantiaGrupoProposta.TaxaComercial__c = garantia.TaxaComercial__c;
        garantiaGrupoProposta.TaxaPura__c = garantia.TaxaPura__c;
        garantiaGrupoProposta.TaxaTotal__c = garantia.TaxaTotal__c;*/
        //PLV-3455 - FIM
        garantiaGrupoProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
        garantiaGrupoProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
        garantiaGrupoProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
        garantiaGrupoProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
        garantiaGrupoProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
        garantiaGrupoProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;
        
        //PLV-2146 COMPLEMENTO - INICIO
               
        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        Integer indice = 0;
        //PLV-4798 - INICIO - GUSTAVO
        if('Viagem'.equalsIgnoreCase(this.segmento)) {
            indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
        }
        //PLV-4798 - FIM - GUSTAVO
        EmissaoTO.CoberturaTO cobertura = null;
        EmissaoTO.DescontoagravoTO descontoAgravo = null;
        if(this.mapOpcaoDesconto!=null && !this.mapOpcaoDesconto.isEmpty() && this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).containsKey(garantia.Garantia__r.Sigla__c)){
            cobertura = this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).get(garantia.Garantia__r.Sigla__c);
            descontoAgravo = cobertura.descontoAgravo != null ? cobertura.descontoAgravo[0] : null;
        }

        if(descontoAgravo!=null){
            if(descontoAgravo.tipo=='FPG'){
                garantiaGrupoProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                garantiaGrupoProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
            }else if(descontoAgravo.tipo == 'TPR'){
                garantiaGrupoProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                garantiaGrupoProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
            }
            if(cobertura.premio!=null){
                garantiaGrupoProposta.PremioIntegral__c = cobertura.premio.integral; //PLV-5351 INICIO/FIM
                garantiaGrupoProposta.PremioComercial__c = cobertura.premio.comercial;
                garantiaGrupoProposta.PremioPuro__c = cobertura.premio.puro;
                garantiaGrupoProposta.PremioTotal__c = cobertura.premio.total;
            }
            if(cobertura.taxa!=null){
                garantiaGrupoProposta.TaxaComercial__c = cobertura.taxa.comercial;
                garantiaGrupoProposta.TaxaPura__c = cobertura.taxa.pura;
                garantiaGrupoProposta.TaxaTotal__c = cobertura.taxa.total;
            }
        }
        garantiaGrupoProposta.IOF__c = cobertura!=null && cobertura.iof!=null ? cobertura.iof :0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularGarantiaSeguradoProposta(GarantiaSeguradoOrcamento__c garantia, GarantiaSeguradoProposta__c garantiaSeguradoProposta)
    {
        if( garantia == null ) return;
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
        garantiaSeguradoProposta.PremioIntegral__c = garantia.PremioIntegral__c; //PLV-5351 INICIO/FIM
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
        //PLV-3731 - INICIO
        garantiaSeguradoProposta.ValorCotacao__c = garantia.ValorCotacao__c;
        //PLV-3731 - FIM
        
        //PLV-4620 FIX 2 INICIO
        garantiaSeguradoProposta.Tipo_de_limite_de_utilizacao__c    = garantia.Tipo_de_limite_de_utilizacao__c;
        garantiaSeguradoProposta.Limite_de_Uso__c         		    = garantia.Limite_de_Uso__c;
		//PLV-4830 INICIO
        garantiaSeguradoProposta.ValorDias__c         		    = garantia.Limite_de_Uso__c;
        //PLV-4830 INICIO
        //PLV-4620 FIX 2 FIM
        
        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        Integer indice = 0;
        //PLV-4798 - INICIO - GUSTAVO
        if('Viagem'.equalsIgnoreCase(this.segmento)) {
            indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
        }
        //PLV-4798 - FIM - GUSTAVO
        EmissaoTO.CoberturaTO cobertura = null;
        EmissaoTO.DescontoagravoTO descontoAgravo = null;
        if(this.mapOpcaoDesconto!=null && !this.mapOpcaoDesconto.isEmpty() && this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).containsKey(garantia.Garantia__r.Sigla__c)){
            cobertura = this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).get(garantia.Garantia__r.Sigla__c);
            descontoAgravo = cobertura.descontoAgravo != null ? cobertura.descontoAgravo[0] : null;
        }

        if(descontoAgravo!=null){
            if(descontoAgravo.tipo=='FPG'){
                garantiaSeguradoProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                garantiaSeguradoProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
            }else if(descontoAgravo.tipo == 'TPR'){
                garantiaSeguradoProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                garantiaSeguradoProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
            }
            if(cobertura.premio!=null){
                garantiaSeguradoProposta.PremioIntegral__c = cobertura.premio.integral; //PLV-5351 INICIO/FIM
                garantiaSeguradoProposta.PremioComercial__c = cobertura.premio.comercial;
                garantiaSeguradoProposta.PremioPuro__c = cobertura.premio.puro;
                garantiaSeguradoProposta.PremioTotal__c = cobertura.premio.total;
            }
            if(cobertura.taxa!=null){
                garantiaSeguradoProposta.TaxaComercial__c = cobertura.taxa.comercial;
                garantiaSeguradoProposta.TaxaPura__c = cobertura.taxa.pura;
                garantiaSeguradoProposta.TaxaTotal__c = cobertura.taxa.total;
            }
        }
        garantiaSeguradoProposta.IOF__c = cobertura!=null && cobertura.iof!=null ? cobertura.iof :0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            

    }
    
    private void popularGarantiaSeguradoPropostaViagem(GarantiaGrupoOrcamento__c garantia, GarantiaSeguradoProposta__c garantiaSeguradoProposta) //PLV-4340 - INICIO/FIM
    {
        if( garantia == null ) return;
        
        garantiaSeguradoProposta.Capital__c = garantia.Capital__c ;
        garantiaSeguradoProposta.GarantiaProduto__c =  garantia.GarantiaProduto__c ;
        garantiaSeguradoProposta.Garantia__c =  garantia.Garantia__c ;
        garantiaSeguradoProposta.NumeroSerie__c =  garantia.NumeroSerie__c ;
        garantiaSeguradoProposta.NumeroSorte__c = garantia.NumeroSorte__c ;
        garantiaSeguradoProposta.Percentual__c = garantia.Percentual__c ;
        garantiaSeguradoProposta.TipoDescontoAgravo__c = garantia.TipoDescontoAgravo__c ;
        garantiaSeguradoProposta.CurrencyIsoCode = garantia.CurrencyIsoCode ; //PLV-3884 - INICIO/FIM - Preenchimento da moeda seguindo garantia do segurado do orcamento 
        garantiaSeguradoProposta.ValorCotacao__c = garantia.ValorCotacao__c;
        garantiaSeguradoProposta.Valor__c = garantia.Valor__c;
        
        //PLV-3731 - INICIO
        garantiaSeguradoProposta.ValorCotacao__c = garantia.ValorCotacao__c;
        //PLV-3731 - FIM
        //PLV-3455 - INICIO - Trecho comentado
        /*garantiaSeguradoProposta.PremioComercial__c = garantia.PremioComercial__c;
        garantiaSeguradoProposta.PremioPuro__c = garantia.PremioPuro__c;
        garantiaSeguradoProposta.PremioTotal__c = garantia.PremioTotal__c;
        garantiaSeguradoProposta.TaxaComercial__c = garantia.TaxaComercial__c;
        garantiaSeguradoProposta.TaxaPura__c = garantia.TaxaPura__c;
        garantiaSeguradoProposta.TaxaTotal__c = garantia.TaxaTotal__c;*/
        //PLV-3455 - FIM
        garantiaSeguradoProposta.DescontoAgravoMonetarioComercial__c = garantia.DescontoAgravoMonetarioComercial__c;
        garantiaSeguradoProposta.DescontoAgravoMonetarioInformado__c = garantia.DescontoAgravoMonetarioInformado__c;
        garantiaSeguradoProposta.DescontoAgravoMonetarioTecnico__c = garantia.DescontoAgravoMonetarioTecnico__c;
        garantiaSeguradoProposta.DescontoAgravoPercentualComercial__c = garantia.DescontoAgravoPercentualComercial__c;
        garantiaSeguradoProposta.DescontoAgravoPercentualInformado__c = garantia.DescontoAgravoPercentualInformado__c;
        garantiaSeguradoProposta.DescontoAgravoPercentualTecnico__c = garantia.DescontoAgravoPercentualTecnico__c;
        
        //PLV-4701 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        Integer indice = 0;
        //PLV-4798 - INICIO - GUSTAVO
        if('Viagem'.equalsIgnoreCase(this.segmento)) {
            indice = (String.isNotBlank(this.nomeGrupo) && (this.nomeGrupo == 'Passageiros até 70 anos')) ? 0 : 1;
        }
        //PLV-4798 - FIM - GUSTAVO
        EmissaoTO.CoberturaTO cobertura = null;
        EmissaoTO.DescontoagravoTO descontoAgravo = null;
        if(this.mapOpcaoDesconto!=null && !this.mapOpcaoDesconto.isEmpty() && this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).containsKey(garantia.Garantia__r.Sigla__c)){
            cobertura = this.mapOpcaoDesconto.get(this.opcaoPagamentoCliente).get(indice).get(garantia.Garantia__r.Sigla__c);
            descontoAgravo = cobertura.descontoAgravo != null ? cobertura.descontoAgravo[0] : null;
        }

        if(descontoAgravo!=null){
            if(descontoAgravo.tipo=='FPG'){
                garantiaSeguradoProposta.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                garantiaSeguradoProposta.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
            }else if(descontoAgravo.tipo == 'TPR'){
                garantiaSeguradoProposta.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                garantiaSeguradoProposta.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
            }
            if(cobertura.premio!=null){
                garantiaSeguradoProposta.PremioIntegral__c = cobertura.premio.integral; //PLV-5351 INICIO/FIM
                garantiaSeguradoProposta.PremioComercial__c = cobertura.premio.comercial;
                garantiaSeguradoProposta.PremioPuro__c = cobertura.premio.puro;
                garantiaSeguradoProposta.PremioTotal__c = cobertura.premio.total;
            }
            if(cobertura.taxa!=null){
                garantiaSeguradoProposta.TaxaComercial__c = cobertura.taxa.comercial;
                garantiaSeguradoProposta.TaxaPura__c = cobertura.taxa.pura;
                garantiaSeguradoProposta.TaxaTotal__c = cobertura.taxa.total;
            }
        }
        garantiaSeguradoProposta.IOF__c = cobertura!=null && cobertura.iof!=null ? cobertura.iof :0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //PLV-4701 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularRemuneracaoProposta(RemuneracaoOrcamento__c remuneracao, RemuneracaoProposta__c remuneracaoProposta, String tipoProposta, Decimal retencaoComissao, Double bonusCampanha) //RVI-49 - INICIO/FIM ------ AV-614 - INICIO/FIM //II-167 INICIO/FIM
    {
        if( remuneracao == null) return;
        remuneracaoProposta.TipoRemuneracao__c = remuneracao.TipoRemuneracao__c;
        //remuneracaoProposta.Percentual__c = remuneracao.Percentual__c; RVI-49 - INICIO/FIM
        //PLV-4234 - INICIO
        //AV-614 - INICIO
        System.debug('remuneracaoProposta: ' + remuneracaoProposta);
        System.debug('remuneracao: ' + remuneracao);
        System.debug('popular retencao: ' + retencaoComissao);
        remuneracaoProposta.Porcentagem_de_Retencao__c = retencaoComissao; 
        System.debug('populada retencao: ' + remuneracaoProposta.Porcentagem_de_Retencao__c);
        //remuneracaoProposta.Porcentagem_de_Retencao__c = remuneracao.Porcentagem_de_Retencao__c;
        //AV-614 - FIM
        //PLV-4234 - FIM
        //RVI-49 - INICIO
        //PLV-3285 - Inclusao do campo
        List<RemuneracaoProduto__c> lstRemProd = [SELECT Id, TipoRemuneracao__r.Codigo__c FROM RemuneracaoProduto__c WHERE TipoRemuneracao__c = :remuneracaoProposta.TipoRemuneracao__c];
        remuneracaoProposta.RemuneracaoProduto__c = lstRemProd[0].Id;
        //PLV-3285 - FIM
        // RVI-168 - INICIO
        //remuneracaoProposta.Percentual__c = lstRemProd[0].TipoRemuneracao__r.Codigo__c == 'AGE' && tipoProposta == 'Renovacao' ? 0 : remuneracao.Percentual__c;
        remuneracaoProposta.Percentual__c = remuneracao.Percentual__c;
        remuneracaoProposta.BonusCampanha__c = bonusCampanha; //II-167 INICIO/FIM
        // RVI-168 - FIM
        //RVI-49 - FIM
    }
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: popula os ojetos da nova proposta baseados no orçamento
*/
    private void popularFavorecidoRemuneracaoProposta(EmissaoTO.FavorecidoTO favorecido, FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta)
    {
        try
        {
            Account conta;
            DadosCorretor__c dadosCorretor;
            favorecidoRemuneracaoProposta.CorretorLider__c = favorecido.corretorLider == null ? false : favorecido.corretorLider;
            favorecidoRemuneracaoProposta.Papel__c = mapPapeis.get(favorecido.papel);
            favorecidoRemuneracaoProposta.Participacao__c = favorecido.participacao;
            favorecidoRemuneracaoProposta.Susep__c = favorecido.susep;
            favorecidoRemuneracaoProposta.SusepEmissao__c = favorecido.susepEmissao;
            favorecidoRemuneracaoProposta.SusepOficialCorretor__c = favorecido.susepOficialCorretor;
            favorecidoRemuneracaoProposta.SusepOrcamento__c = favorecido.susepOrcamento;
            favorecidoRemuneracaoProposta.AntecipacaoComissao__c = favorecido.antecipaComissao == null ? false : favorecido.antecipaComissao; //PLV-4344 - Inicio/Fim
            favorecidoRemuneracaoProposta.CorretorResponde__c = favorecido.corretorResponde == null ? false : Boolean.valueOf(favorecido.corretorResponde); //PLV-5493 - INICIO/FIM
            favorecidoRemuneracaoProposta.CelularCorretor__c = favorecido.corretorResponde == null ? '' : String.valueOf(favorecido.corretorCelular); //PLV-5493 - INICIO/FIM
            System.debug('favorecido.antecipaComissao>1 ' + favorecido.antecipaComissao);
            System.debug('favorecido.antecipaComissao>2 ' + favorecidoRemuneracaoProposta.AntecipacaoComissao__c);
            // obtem as contas associadas ao CPF/ CPNJ contidos nos favorecidos da remuneracao
            conta = mapContas.get(montarChavePessoa(favorecido.pessoa));
            if(conta != null)
                favorecidoRemuneracaoProposta.Conta__c  = conta.Id;   
            
            dadosCorretor = mapDadosCorretor.get(favorecido.susep);
            //PLV-5235 - INICIO
            if(dadosCorretor != null) {
                favorecidoRemuneracaoProposta.DadosCorretor__c = dadosCorretor.Id;
                favorecidoRemuneracaoProposta.SusepOficialCorretor__c = dadosCorretor.SusepOficialCorretor__c;
            }
            //PLV-5235 - FIM
            
            if (favorecidoRemuneracaoProposta.CorretorLider__c)
                this.proposta.propostaWrapper.sfProposta.CodigoCorretor__c = favorecidoRemuneracaoProposta.DadosCorretor__c;
        }
        catch (Exception e){
            throw new PropostaBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /* ---------------------------------- MODELOS ----------------------------------------------------------------- */
    
    /* ---------------------------------- HELPERS ----------------------------------------------------------------- */
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
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
        
        Set<String> setSuepsCorretores = new Set<string>();
        Set<String> setTipoRemuneracao = new Set<String>();
        
        // monta os sets p/ obter os corretores e as contas dos favorecidos da remuneracao
        if(payload.proposta.remuneracoes != null){
            for(EmissaoTO.RemuneracaoTO remuneracaoTO : payload.proposta.remuneracoes){
                setTipoRemuneracao.add(remuneracaoTO.tipoRemuneracao);
                for(EmissaoTO.FavorecidoTO favorecido : remuneracaoTO.favorecidos){ 
                    setSuepsCorretores.add(favorecido.susep);
                }
            }
        }
        
        for(TipoRemuneracao__c tipo : TipoRemuneracaoDAO.getInstance().listar(setTipoRemuneracao))
            mapTiposRemuneracao.put(tipo.Id, tipo);
        
        for(DadosCorretor__c corretor : daoDadosCorretor.buscarCorretorPorSusep(setSuepsCorretores))
            mapDadosCorretor.put(corretor.Name, corretor);
        
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
    
    /*
*  @author Everymind - Sprint 29 - (hackathon)
*  @Descrição: helper p/ montar a chave externa de contas
*/
    public String montarChavePessoa(EmissaoTO.PessoaTO pessoa)
    {
        //PLV-4440 INICIO
        String IdExterno=null;
        try {
        system.debug('pessoa:: '+pessoa);
        if(pessoa.tipo == PESSOA_JURIDICA)
            IdExterno = pessoa.dadosPessoaJuridica.numeroCnpj + pessoa.dadosPessoaJuridica.ordemCnpj + pessoa.dadosPessoaJuridica.digitoCnpj;
        else if(pessoa.tipo == PESSOA_FISICA)
            IdExterno = pessoa.dadosPessoaFisica.numeroCpf + pessoa.dadosPessoaFisica.digitoCpf;
        } catch ( Exception e ) {
            System.debug('Exception: Erro montando chave pessoa '+e.getMessage() + ' '+ e.getStackTraceString());
            System.debug('pessoa='+ JSON.serialize(pessoa));
        }
        //PLV-4440 FIM
        return IdExterno;
    }
    
    // 2610 - INICIO
    public Account preencherDadosContaPessoaFisica(EmissaoTO.PessoaTO pPessoaTO,EmissaoTO.PayloadTO payLoadProposta) { //PLV-4440 - INICIO/FIM
        
        List<String> lNomeSplit = pPessoaTO.nome.split(' ', 2);
        String firstName = lNomeSplit.size() == 2 ? lNomeSplit.get(0) : '';
        String LastName = lNomeSplit.size() == 2 ? lNomeSplit.get(1) : lNomeSplit.get(0);
        String idExterno = montarChavePessoa(pPessoaTO);
        //PLV-3857 - INICIO - Lógica para atribuir o valor certo ao campo picklist da conta
        String sexo;
        //PLV-4449 - INICIO - PEDRO AUGSUTO BRAZ - SYS4B
        if(String.isNotEmpty(pPessoaTO.dadosPessoaFisica.sexo)){
            if(pPessoaTO.dadosPessoaFisica.sexo.toUpperCase() == 'MASCULINO') {sexo = 'MASC';}
            else if(pPessoaTO.dadosPessoaFisica.sexo.toUpperCase() == 'FEMININO'){ sexo = 'FEM';}
            else sexo=pPessoaTO.dadosPessoaFisica.sexo.toUpperCase();
        }
        //PLV-4449 - FIM - PEDRO AUGSUTO BRAZ - SYS4B
        //PLV-3857 - FIM
        /*EmissaoTO.EnderecoTO enderecoTO = pPessoaTO.enderecos != null && pPessoaTO.enderecos.size() > 0 ?
            pPessoaTO.enderecos[0] :
            new EmissaoTO.EnderecoTO();*/
        system.debug('PessoaTO: ' + JSON.serialize(pPessoaTO));
        
        //PLV-3896 - INICIO - Hotfix - Ajustes na portal e emissão do Viagem.
        Account contaCriada = new Account();
        
        contaCriada.FirstName = firstName;
        contaCriada.LastName = LastName;
        contaCriada.NomeSocial__c = pPessoaTO.nomeSocial; // LECVPV-184 INICIO/FIM
        contaCriada.Imc__c = pPessoaTO.dadosPessoaFisica.imc; // ANNVI-17
        if(String.isNotBlank(pPessoaTO.email)) contaCriada.PersonEmail = pPessoaTO.email;
        contaCriada.Cpf__c = idExterno;
        contaCriada.IdExterno__c = idExterno;
        contaCriada.PersonBirthDate = String.isNotBlank(pPessoaTO.dadosPessoaFisica.dataNascimento) ? Date.valueOf(pPessoaTO.dadosPessoaFisica.dataNascimento) : null;//PLV-4449 - INICIO/FIM - PEDRO AUGSUTO BRAZ - SYS4B
        //PLV-5231 - INICIO (REMOVIDO COMENTARIO DA LINHA ABAIXO E INCLUSAO DA LINHA SUBSEQUENTE)
        //contaCriada.Nacionalidade__c = pPessoaTO.dadosPessoaFisica.nacionalidade; //PLV-4869 - FIX 2 - Guilherme Brito INICIO/FIM
        if(this.segmento == 'Individual'){
            contaCriada.Nacionalidade__c = pPessoaTO.dadosPessoaFisica.nacionalidade.toLowerCase().capitalize();
            contaCriada.PaisDeOrigem__c = pPessoaTO.dadosPessoaFisica.paisDeOrigem;
            contaCriada.PaisResidencia__c = pPessoaTO.dadosPessoaFisica.paisResidente;
            //contaCriada.ClasseRne__c = 'fghjku'; //PLV-5231 - FIX01 - INICIO/FIM
            System.debug('nacionalidadeVeio>>>> ' + pPessoaTO.dadosPessoaFisica.nacionalidade.toLowerCase().capitalize());
            System.debug('paisDeOrigemVeio>>>> ' + pPessoaTO.dadosPessoaFisica.paisDeOrigem);
            System.debug('paisResidente>>>> ' + pPessoaTO.dadosPessoaFisica.paisResidente);
        }    
        //PLV-5231 - FIM
        //PLV-4340 - INICIO
        //PLV-4440 - INICIO
        if(pPessoaTO.telefones != null && pPessoaTO.telefones.size() > 0){
            for(EmissaoTO.telefoneTO tel: pPessoaTO.telefones){
                String telefoneToInput = Util.getMascaraTelefone(tel.numeroTelefone,tel.dddTelefone);
                //PLV-4816 - INICIO
                if('RES'.equals(tel.tipoTelefone)){
                    contaCriada.PersonHomePhone = telefoneToInput;
                    system.debug('this.segmento: '+this.segmento);
                    if('Viagem'.equalsIgnoreCase(this.segmento)){
                        break;
                    }
                }
                //PLV-4816 - FIM
                if('CEL'.equals(tel.tipoTelefone)){
                    contaCriada.PersonMobilePhone = telefoneToInput;
                }
                if('PES'.equals(tel.tipoTelefone)){
                    contaCriada.Phone = telefoneToInput;
                }
            }
        }
        contaCriada.Fumante__c = pPessoaTO.dadosPessoaFisica.fumante == true ? 'Sim' : 'Não';
        //PLV-4440 - FIM
        //PLV-4340 - FIM
        //contaCriada.Phone = pPessoaTO.telefones != null && pPessoaTO.telefones.size() > 0 ?
        //Util.getMascaraTelefone(pPessoaTO.telefones[0].numeroTelefone, pPessoaTO.telefones[0].dddTelefone) : null;
        contaCriada.Renda__c = pPessoaTO.rendaMensal;
        contaCriada.Profissao__r = String.isNotBlank(pPessoaTO.dadosPessoaFisica.profissao) ? new Profissao__c(Codigo__c = pPessoaTO.dadosPessoaFisica.profissao) : null;//PLV-4449 - INICIO/FIM - PEDRO AUGSUTO BRAZ - SYS4B
        contaCriada.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id;
        contaCriada.Sexo__c = String.isNotBlank(sexo) ? sexo : null; //PLV-3857 PLV-4449 - INICIO/FIM - Inclusão do campo sexo preenchido do portal
        system.debug('pPessoaTO: '+pPessoaTO);
        
        //PLV-4440 - INICIO
        contaCriada.RegimeTrabalho__c = String.isNotBlank(pPessoaTO.dadosPessoaFisica.regimeTrabalho)?pPessoaTO.dadosPessoaFisica.regimeTrabalho :null;
        if ( payLoadProposta != null && 'Individual'.equalsIgnoreCase(payLoadProposta.proposta.segmento)){ 
            //  System.debug('PEP='+JSON.serialize(payLoadProposta));
            if(pPessoaTO.dadosPessoaFisica.estadoCivil == 'SOLTEIRO')
                contaCriada.EstadoCivil__c = 'Solteiro (a)';
            if(pPessoaTO.dadosPessoaFisica.estadoCivil == 'DIVORCIADO')
                contaCriada.EstadoCivil__c = 'Divorciado(a)';
            if(pPessoaTO.dadosPessoaFisica.estadoCivil == 'VIUVO')
                contaCriada.EstadoCivil__c = 'Viúvo(a)';
            if(pPessoaTO.dadosPessoaFisica.estadoCivil == 'DESQUITADO')
                contaCriada.EstadoCivil__c = 'Desquitado(a)';
            if(pPessoaTO.dadosPessoaFisica.estadoCivil == 'CASADO')
                contaCriada.EstadoCivil__c = 'Casado (a)';
            if(pPessoaTO.dadosPessoaFisica.estadoCivil == 'VIVEMARITALMENTE')
                contaCriada.EstadoCivil__c = 'Vive maritalmente';
            contaCriada.ResideBrasil__c = pPessoaTO.dadosPessoaFisica.resideBrasil == null? false : pPessoaTO.dadosPessoaFisica.resideBrasil;
            contaCriada.EmpresaTrabalhaSocio__c = payLoadProposta.proposta.contratantes[0].grupos[0].segurados[0].empresaQueTrabalha;
            contaCriada.Ramo_de_atividade__c = payLoadProposta.proposta.contratantes[0].grupos[0].segurados[0].ramoAtividade; //PLV-4595
            
            //contaCriada.Pep__c = payLoadProposta.proposta.contratantes[0].grupos[0].segurados[0].pessoa.pessoaExpostaPoliticamente;
            String strPep = payLoadProposta.proposta.contratantes[0].grupos[0].segurados[0].pessoa.pessoaExpostaPoliticamente;
            if(strPep == 'RelacionamentoProximo'){
                contaCriada.Pep__c = 'Relacionamento próximo';
            }else if(strPep == 'Sim'){
                contaCriada.Pep__c = 'Sim';
            }else if(strPep == 'Nao'){
                contaCriada.Pep__c = 'Não';
            }
            //  System.debug('##pep__c='+contaCriada.Pep__c );
            //  System.debug(JSON.serialize(payLoadProposta.proposta.contratantes[0].grupos[0].segurados[0].pessoa));
            String tipodoc = pPessoaTO.dadosPessoaFisica.tipoDocIdentificacao;
            String documento = pPessoaTO.dadosPessoaFisica.docIdentificacao;
            if(tipodoc=='cpf'){
                contaCriada.CPF__c = documento;
            }else if(tipodoc=='rg'){
                contaCriada.RG__c = documento;
            }else if(tipodoc=='rne'){
                contaCriada.Rne__c = documento;
            }else if(tipodoc=='classe'){
                contaCriada.Classe__pc = documento;
            }else if(tipodoc=='cnh'){
                contaCriada.CNH__pc = documento;
            }
            //PLV-5231 - REMOCAO DE COMENTARIO DA LINHA ABAIXO - INICIO
            if(this.segmento == 'Individual'){
                contaCriada.TipoDocidentificacao__c = pPessoaTO.dadosPessoaFisica.tipoDocIdentificacao == null? '': pPessoaTO.dadosPessoaFisica.tipoDocIdentificacao;
                contaCriada.DocIndentificacao__c = pPessoaTO.dadosPessoaFisica.docIdentificacao == null? '': pPessoaTO.dadosPessoaFisica.docIdentificacao;
            }
            //PLV-5231 - FIM
            //contaCriada.DocIndentificacao__c = pPessoaTO.dadosPessoaFisica.docIdentificacao == null? '': pPessoaTO.dadosPessoaFisica.docIdentificacao;
            contaCriada.OrgaoExpedidor__c = pPessoaTO.dadosPessoaFisica.orgaoExpedidor == null? '': pPessoaTO.dadosPessoaFisica.orgaoExpedidor;
            contaCriada.DataExpedicao__c =  pPessoaTO.dadosPessoaFisica.dataExpedicao;
            // contaCriada.FaixaRenda__c =  pPessoaTO.dadosPessoaFisica.faixaRenda;
            //contaCriada.Pep__c = pPessoaTO.dadosPessoaFisica.pep == null? '': pPessoaTO.dadosPessoaFisica.pep;
            // system.debug('SIZE:: '+pPessoaTO.telefones.size());
            // system.debug('pPessoaTO.telefones[0]:: '+pPessoaTO.telefones[0]);
            //  system.debug('pPessoaTO.telefones[1]:: '+pPessoaTO.telefones[1]);

            /*
            if ( pPessoaTO.telefones != null && pPessoaTO.telefones[0] != null  )
            contaCriada.PersonHomePhone = pPessoaTO.telefones[0].numeroTelefone == null? '':'('+ pPessoaTO.telefones[0].dddTelefone + ')' + pPessoaTO.telefones[0].numeroTelefone;
            if ( pPessoaTO.telefones != null && pPessoaTO.telefones.size() > 1 && pPessoaTO.telefones[1] != null  )
            contaCriada.PersonMobilePhone = pPessoaTO.telefones[1].numeroTelefone == null? '':'('+ pPessoaTO.telefones[1].dddTelefone + ')' + pPessoaTO.telefones[1].numeroTelefone;
            if ( pPessoaTO.telefones != null && pPessoaTO.telefones.size() > 2 && pPessoaTO.telefones[2] != null  )
            contaCriada.Phone = pPessoaTO.telefones[2].numeroTelefone == null? '':'('+ pPessoaTO.telefones[2].dddTelefone + ')' + pPessoaTO.telefones[2].numeroTelefone;
            */

             // PLV-4594 INICIO SYS4B ODEMIR
             contaCriada.IntegracaoPEP__c = payLoadProposta.proposta.contratantes[0].pessoa?.retornoIntegracaoPEP?.pep;
             contaCriada.CargoPEP__c =  payLoadProposta.proposta.contratantes[0].pessoa?.retornoIntegracaoPEP?.cargo;
             contaCriada.UltimaConsultaPEP__c = System.today();
             System.debug('dataAtualizacao='+payLoadProposta.proposta.contratantes[0].pessoa?.retornoIntegracaoPEP?.dataAtualizacao);
           //  contaCriada.DataAtualizacaoPEP__c = payLoadProposta.proposta.contratantes[0].pessoa?.retornoIntegracaoPEP?.dataAtualizacao;
           try {
            if ( payLoadProposta.proposta.contratantes[0].pessoa?.retornoIntegracaoPEP?.dataAtualizacao != null 
                && payLoadProposta.proposta.contratantes[0].pessoa?.retornoIntegracaoPEP?.dataAtualizacao.trim().length() > 0 )
                contaCriada.DataAtualizacaoPEP__c = Date.valueOf(payLoadProposta.proposta.contratantes[0].pessoa?.retornoIntegracaoPEP?.dataAtualizacao);
                else
                contaCriada.DataAtualizacaoPEP__c=null;
           } catch ( Exception e ) {
               System.debug('Erro convertendo data '+ e.getStackTraceString());
               contaCriada.DataAtualizacaoPEP__c=null;
           }
             // PLV-4594 FIM  SYS4B ODEMIR

        }
        
        //PLV-4440 - FIM

        return contaCriada; 
        //PLV-3896 - FIM - Hotfix - Ajustes na portal e emissão do Viagem.
    }
    // 2610 - FIM

    //VIAG-165 FIX02 INCIO

    /*VIAG-232 INICIO
    public void getAtualizaCupom(List<Quote> propostas) {
        //List<Quote> propostas = [SELECT Id, Name, Opportunity.CupomDesconto__c FROM Quote WHERE OpportunityId IN :opportunityIds];
        for (Quote proposta : propostas) {
            proposta.CupomDesconto__c = proposta.Opportunity.CupomDesconto__c;
        
        }
        update propostas;
    }
    VIAG-232 FIM*/

    //VIAG-165 FIX02 FIM


    //PLV-5153 - INICIO
    private String deparaEstadoCivil(String estadoCivilPayload) {

        switch on estadoCivilPayload {
            when 'SOLTEIRO' {
                return 'Solteiro (a)';
            }
            when 'DIVORCIADO' {
                return 'Divorciado(a)';
            }
            when 'VIUVO' {
                return 'Viúvo(a)';
            }
            when 'DESQUITADO' {
                return 'Desquitado(a)';
            }
            when 'CASADO' {
                return 'Casado (a)';
            }
            when 'VIVEMARITALMENTE' {
                return 'Vive maritalmente';
            }
            when else {
                return null;
            }
        }

        //PLV-5153 - FIM

    }
    //RVI-312 - INICIO
    //RVI-312-FIX01 - INICIO
    public List<Decimal> propostaDescontoAgravo(String numeroOferta){  

        List<Decimal> agravosOrcamento = new List<Decimal>();

        Opportunity orcProRenv = [SELECT Id, ContratoRenovado__r.Proposta__c, DescontoAgravoPercentualFormaPagto__c, DescontoAgravoMonetarioFormaPagto__c  FROM Opportunity WHERE Numero__c = :numeroOferta];
           
        if(orcProRenv != null){
            agravosOrcamento.add(orcProRenv.DescontoAgravoPercentualFormaPagto__c);
            agravosOrcamento.add(orcProRenv.DescontoAgravoMonetarioFormaPagto__c);
            return agravosOrcamento;
        }

        return null;
    }
    //RVI-312-FIX01 - FIM
    //RVI-312 - FIM

    //II-165 INICIO
    //II-165 FIX03 INICIO 
    // public static Boolean gerarCriticaAnalise(List<Quote> proposta){

    //     System.debug('Entrou no gerarCriticaAnalise');
    //     System.debug('Entrou no gerarCriticaAnalise');
    //     String produto = proposta[0].Produto__r.CodigoPrecificaProduto__c;
    //     //II-165 FIX01 INICIO
    //     String segmento = proposta[0].Segmento__c; 
    //     String tipo = proposta[0].Tipo__c;
    //     //II-165 FIX01 FIM
    //     String cpf = proposta[0].Account.Cpf__c;
    //     System.debug('cpf <><><> ' + cpf);
    //     System.debug('proposta <><><> ' + proposta);
    //     List<Quote> propostasTransmissao = new List<Quote>();
    //     if(produto != 'VIDA_ON' && segmento == 'Individual' && tipo == 'Novo'){ //II-165 FIX01 INICIO/FIM
    //         propostasTransmissao = [SELECT id FROM quote WHERE Segmento__c = 'Individual' AND Tipo__c = 'Novo' AND Status IN ('Em análise', 'Disponível para contratação') AND Account.Cpf__c = :cpf];
    //     }
    //     System.debug('propostasTransmissao <><><> ' + propostasTransmissao);
    //     System.debug('propostasTransmissao.size() <><><> ' + propostasTransmissao.size());
    //     if(!propostasTransmissao.isEmpty()){
    //         System.debug('Entrou no if gerar Critica Rogerio');
    //         CriticaProposta__c ctrProposta = new CriticaProposta__c(
    //                         Tipo__c = 'Analise',
    //                         Setor__c = 'Emissão',
    //                         Codigo__c = '233',
    //                         Proposta__c = proposta[0].id,
    //                         MomentoAnalise__c = 'Análise Interna',
    //                         Status__c = 'Pendente',
    //                         Area__c = 'ACE',
    //                         Descricao__c = 'Código 233 - Outras propostas estão em transmissão para o mesmo cpf', //II-165 FIX01 INICIO/FIM
    //                         Origem__c = 'Salesforce'
    //                     );
    //         insert ctrProposta;
    //         System.debug('ctrProposta <><><> ' + ctrProposta);
    //         return true;
    //     }
    //     return false;
    // }
    //II-165 FIX03 FIM 
    //II-165 FIM

    /* ---------------------------------- FIM HELPERS ------------------------------------------------------------- */
}
// FIN | PLV-2355-Hackathon
//PLV-3285 - FIM - MVP A Transmissão da proposta