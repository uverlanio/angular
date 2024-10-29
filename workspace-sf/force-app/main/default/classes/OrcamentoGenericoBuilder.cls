/**************************************************************************************************************************************************************************
* 
*  Classe responsável por montar um orcamento genérico
*
// *  
**************************************************************************************************************************************************************************/
public without sharing class OrcamentoGenericoBuilder extends OrcamentoBuilder 
{
    private static final OrcamentoGenericoBuilder instance = new OrcamentoGenericoBuilder(true); //PLV-3926 - INICIO/FIM - Ajuste
    public static OrcamentoGenericoBuilder getInstance() { return instance; }
    private String numeroApolice;  
    private Boolean gerarArquivo; //PLV-3926 - INICIO/FIM - Ajuste
    // PLV-3895 - INICIO - Variaveis
    public EmissaoTO.PayloadTO payloadTOpublic;
    public Map<String, EmissaoTO.CoberturaTO   > mapCoberturasGarantiaOrcamento               = new Map<String, EmissaoTO.CoberturaTO>();
    public Map<String, EmissaoTO.CoberturaTO   > mapCoberturasGarantiaContratanteOrcamento    = new Map<String, EmissaoTO.CoberturaTO>();
    public Map<String, EmissaoTO.CoberturaTO   > mapCoberturasGarantiaGrupoOrcamento          = new Map<String, EmissaoTO.CoberturaTO>();
    public Map<String, EmissaoTO.CoberturaTO   > mapCoberturasGarantiaSeguradoOrcamento       = new Map<String, EmissaoTO.CoberturaTO>();
    public Map<String, String                  > mapGarantiasSigla                            = new Map<String, String               >();
    Map<String, Map<String, EmissaoTo.DescontoAgravoTO>> descontoMap = new Map<String, Map<String, EmissaoTo.DescontoAgravoTO>>();//PLV-5676-INICIO/FIM


    private List<String> tipoSeguro = new List<String>{'EDS' , 'CAN'}; //PLV-5676-INICIO/FIM
    // PLV-3895 -FIM - Variaveis
    private static final String TIPO_SEGURO_CANCELAMENTO = 'CAN';
    @TestVisible //ANNVI-55 - INICIO
    private Contract contrato;
    @TestVisible
    private List<GrupoContrato__c> grupos = new List<GrupoContrato__c>(); 
    @TestVisible
    private List<GarantiaContratanteContrato__c> garantiasContratante = new List<GarantiaContratanteContrato__c>();
    @TestVisible
    private List<GarantiaSeguradoContrato__c> garantiasSeguradoContrato = new List<GarantiaSeguradoContrato__c>();//ANNVI-55 - FIM
    private ContractDAO daoContrato = ContractDAO.getInstance();
    private OpportunityDAO daoOpportunity = OpportunityDAO.getInstance();
    //PLV-3130 - INICIO
    //Código removido para PLV-3317
    //PLV-3130 - FIM
    
    //PLV2365: INICIO
    private AccountBO contaBO = AccountBO.getInstance();
    //PLV2365: FIM
    
    //PLV-2727 - Inicio
    private EnderecoBO endereco2BO = EnderecoBO.getInstance();
    //PLV-2727 - Fim
    
    public Map<Id, List<GarantiaContratanteContrato__c>> mapGarantiaContratanteContrato = new Map<Id, List<GarantiaContratanteContrato__c>>();
    public Map<Id, List<GrupoContrato__c>> mapGruposContrato = new Map<Id, List<GrupoContrato__c>>();
    private Map<String,  List<GarantiaSeguradoContrato__c>> mapGarantiaSeguradoContrato = new Map<String,  List<GarantiaSeguradoContrato__c>>();
    private Map<String, Id> mapGarantias = new Map<String, Id>();
    //PLV-3317 - INICIO - Map criado para gerar os registros de garantias da forma correta
    Map<String, EmissaoTO.CoberturaTO> mapCoberturas;
    //PLV-3317 - FIM
    //PLV-3285 - INICIO - Mudanca para global para atender a necessidade
    @TestVisible //ANNVI-55 - INICIO/FIM
    Map<String, GarantiaProduto__c> mGarantiaProd; //PLV-3884 - INICIO/FIM - Mapa de objeto de garantia do produto para seleção de moeda
    //PLV-3285 - FIM
    //PLV-3136 - INÍCIO
    //private static Map<String, EmissaoTo.RetornoCalculoTO> mapRetornosCalculo = new Map<String, EmissaoTo.RetornoCalculoTO>();
    //PLV-3136 - FIM

    private Map<String, ID> mpFranquiaProdIds = new Map<String, ID>();  //PLV-4598 - INICIO/FIM
    
    /* ---------------------------------- INTERFACE --------------------------------------------------------------- */
    public override List<Orcamento.ContratanteWrapper> gerarContratantes(EmissaoTO.PayloadTO payloadTo){return null; }
    public override List<Orcamento.GrupoWrapper> gerarGrupos(EmissaoTO.PayloadTO payloadTo){return null; }
    public override List<Orcamento.SeguradoWrapper> gerarSegurados(EmissaoTO.PayloadTO payloadTo){return null; }
    public override void popularPrecificacao(EmissaoTO.PrecificacaoTO precificacaoTO){}
    
    //PLV-3926 - INICIO - Ajuste no construtor
    public OrcamentoGenericoBuilder(Boolean gerarArquivo) {
        this.setInstancia(this);
        this.gerarArquivo = gerarArquivo; 
    }
    //PLV-3926 - FIM
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: Gera objeto de oportunidade de acordo com o dados do payload 
*/
    public override void gerarOrcamento(EmissaoTO.PayloadTO payloadTO)
    {
        System.debug('Orcamento' + JSON.serializePretty(payloadTO.orcamento));
        system.debug('MetodoGerarOrcamento');
        // PLV-2372 INICIO
        // verifica se é endo >> so p/ criar o orcamento
        if(payloadTO.orcamento.tipoSeguro == TIPO_SEGURO_CANCELAMENTO)
        {
            system.debug('gerarOrcamento >> builder >> generico >> inicio');
            //payloadTO.orcamento.endosso = '0'; //PLV-4695-FIX6 - INICIO/FIM
            // recuperar todas as informações do Contrato anterior  (buscar com empresa, sucursal, ramo, apólice, e max do endosso)
            
            numeroApolice = String.valueOf(payloadTO.orcamento.apolice).leftPad(8,'0');
            
            system.debug('Logando numeroApolice: '+ numeroApolice);
            system.debug('Logando payloadTO.orcamento.empresa: '+ payloadTO.orcamento.empresa);
            system.debug('Logando payloadTO.orcamento.sucursal: '+ payloadTO.orcamento.sucursal);
            system.debug('Logando payloadTO.orcamento.ramo: '+ payloadTO.orcamento.ramo);
            system.debug('Logando payloadTO.orcamento.endosso: '+ payloadTO.orcamento.endosso);

            // Gera o name do contrato original
            String nameContratoOriginal = ContractBO.getInstance().gerarNameContrato(String.valueOf(payloadTO.orcamento.empresa), String.valueOf(payloadTO.orcamento.sucursal), String.valueOf(payloadTO.orcamento.ramo), numeroApolice, String.valueOf(payloadTO.orcamento.endosso));
            
            System.debug('nameContratoOriginal ' + nameContratoOriginal);
            
            
            system.debug('recuperar todas as informações do Contrato anterior  (buscar com empresa, sucursal, ramo, apólice, e max do endosso)');
            List<Contract> lstContratos = daoContrato.buscarContratoPorName(nameContratoOriginal);
            
            system.debug('contrato obtido:' + lstContratos );
            
            //PLV-1197-27 - Tratamento para apolice não encontrada
            if(lstContratos.isEmpty()) {
                throw new OrcamentoBuilderException('Contrato ' + numeroApolice + ' não encontrado');
            }
            //PLV-1197-27 - Tratamento para apolice não encontrada
            
            // Gera o numero de propsta
            String numeroOrcamento = this.gerarNumeroProposta();
            
            // Recupera o contrato original e verifica os status
            Contract contratoOriginal = lstContratos[0];
            if(contratoOriginal.Status == 'Cancelado' || contratoOriginal.Status != 'Emitido'){
                throw new OrcamentoBuilderException('Contrato já cancelado ou não emitido.');
            }
            
            /*
            // Recupera as propostas de cancelamento pendentes e apaga
            List<Opportunity> listOrcamentosAnteriores = new List<Opportunity>();
            List<Quote> listPropostasCancelamentoAnteriores = QuoteDAO.getInstance().buscarPropostasCancelamentoPendentesPorContratoOriginal(new Set<Id>{contratoOriginal.Id});
            
            for(Quote proposta : listPropostasCancelamentoAnteriores){
                listOrcamentosAnteriores.add(proposta.Opportunity);
            }*/

            // PLV-2567 INICIO
            // Recupera as propostas de cancelamento pendentes e apaga
            system.debug('payloadTO >>>>>>>>: '+payloadTO);
            List<Opportunity> listOrcamentosAnteriores = new List<Opportunity>();
            List<Quote> listPropostasCancelamentoAnteriores = new List<Quote>();
            List<Quote> listPropostasCancelamento = QuoteDAO.getInstance().buscarPropostasCancelamentoPorContratoOriginal(new Set<Id>{contratoOriginal.Id});
            
            //PLV-4695-FIX7 - INICIO
            system.debug('listPropostasCancelamento'+listPropostasCancelamento);
            for(Quote proposta : listPropostasCancelamento){
                if(proposta.Status == 'Devolvida'){
                    listOrcamentosAnteriores.add(proposta.Opportunity);
                    listPropostasCancelamentoAnteriores.add(proposta);
                }/*else{
                    // Gera a devolutiva abortiva de proposta já cancelada
                    throw new OrcamentoBuilderException('Já existe uma proposta para cancelar esse contrato.');
                }*/
            }

            //PLV-4695-FIX7 FIM

            // PLV-2567 FIM
            
            if(!listPropostasCancelamentoAnteriores.isEmpty()) {
                delete listPropostasCancelamentoAnteriores;
            }
            if(!listOrcamentosAnteriores.isEmpty()){
                delete listOrcamentosAnteriores;
            }
            
            //obtem o contrato com o endosso maior (mais recente)
            Map<Integer, Contract> mapContratos = new Map<Integer, Contract>();
            for(Contract contratoTemp : lstContratos)
            {
                if(payloadTO.orcamento.endosso < contratoTemp.Endosso__c)
                    payloadTO.orcamento.endosso = contratoTemp.Endosso__c;
                
                mapContratos.put(Integer.valueOf(contratoTemp.Endosso__c), contratoTemp);
            }
            contrato = mapContratos.get(Integer.valueOf(payloadTO.orcamento.endosso));
            system.debug('gerar ocamento >> contrato '+ contrato);
            system.debug('gerar ocamento >> Id contrato '+ contrato.Id);
            
            // depara de contrato p/ oportunidade
            this.popularOrcamento(contrato, this.orcamento.orcamentoWrapper.sfOrcamento, payloadTO, numeroOrcamento);
            
            system.debug('popularOrcamento fim ');		
            
            this.orcamento.orcamentoWrapper.retornoWrapper.codigoEmpresa = payloadTO.orcamento.empresa;
            this.orcamento.orcamentoWrapper.retornoWrapper.codigoSucursal = String.valueOf(payloadTO.orcamento.sucursal);
            this.orcamento.orcamentoWrapper.retornoWrapper.numeroApolice = numeroApolice;
            this.orcamento.orcamentoWrapper.retornoWrapper.codigoRamo = String.valueOf(payloadTO.orcamento.ramo);
            this.orcamento.orcamentoWrapper.retornoWrapper.tipoEndosso = String.valueOf(payloadTO.orcamento.tipoEndosso);
            
            system.debug('dados retorno fim ');		
            
            // Gera as remuneracoes da orcamento
            this.gerarRemuneracaoOrcamentoWrapper(contrato.RemuneracoesContrato__r, this.orcamento.orcamentoWrapper.RemuneracaoOrcamentoWrapper);
            
            system.debug('gerarRemuneracaoOrcamentoWrapper fim ');		
            
            // Gera as garantias da orcamento
            this.popularGarantiasWrapper(contrato.GarantiasContrato__r, this.orcamento.orcamentoWrapper.garantiasWrapper);
            system.debug('popularGarantiasWrapper fim ');		
            
            this.buscarRegistrosDominios();
            
            system.debug('buscarRegistrosDominios fim ');		
            
            // Gera os contratantes
            this.gerarContratantes(contrato.ContratantesContrato__r, this.orcamento.orcamentoWrapper.contratantesWrapper);
            system.debug('gerarContratantes fim ');
        }
        // PLV-2372 FIM
    }
    
    // PLV-3130 - INICIO
    // Código removido para PLV-3317
    // PLV-3130 - FIM
    
    //PLV2365: INICIO
    public ServiceTO.PayRetornoOfertasTO gerarOrcamentoGravar(String payload)
    {
        system.debug('MetodoGerarOrcamentoGravar');
        system.debug('gerarOrcamentoEmissao >> inicio');
        system.debug('Payload ENTRADA = '+ payload);
        // teste de deploy - Iskander
        
        EmissaoTO.PayloadTO payloadTO = (EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class);

        system.debug('payloadTO rm1 >> ' + Json.serialize(payloadTO)); 
        
        //PLV-3318 - INICIO
        /*system.debug('payloadTO.versoesCalculo'+payloadTO.versoesCalculo);
        map<string,integer> mversoesCalculo = new map<string,integer>();
        for(EmissaoTO.VersoesCalculo mversao : payloadTO.versoesCalculo){
        string valorDesconto = String.valueOf(mversao.descontoAgravo);
        system.debug('valor desconto'+mversao.descontoAgravo);
        system.debug('tamanho desconto'+valorDesconto.length());
        //Código removido para Fix da PLV-3318
        mversoesCalculo.put(valorDesconto,mversao.opcao);
        }
        system.debug('emisso VersoesCalculo'+ mversoesCalculo);
        */
        //PLV-3318 - FIM
        
        ServiceTO.PayRetornoOfertasTO ofertasRetorno = new ServiceTO.PayRetornoOfertasTO();
        
        // PLV-2502 INICIO 
        //Renan Inserir Classe ValidaRegrasGarantiaSniper(Recusa)
        //PLV_2826 - INICIO - Criar oportunidade sem conta
        ofertasRetorno  = ValidaRegrasGarantiaSniper.ValidaGarantias(payloadTO);
        //PLV_2826 - FIM - Criar oportunidade sem conta
        if (ofertasRetorno.retornoValidacaoProduto != null && !ofertasRetorno.retornoValidacaoProduto.recusas.isEmpty() ) {        
            return ofertasRetorno;
        }
        // PLV-2502 FIM
        
        List<ServiceTO.OfertaTO> ofertas = new List<ServiceTO.OfertaTO>();
        system.debug('ofertas rm3 >> ' + ofertas);
        
        // PLV-3130 - INICIO
        // Código removido para PLV-3317
        // PLV-3130 - FIM
        
        for(EmissaoTO.OfertasTO oferta : payloadTO.ofertas)
        {
            ServiceTO.OfertaTO ofertaCriada = new ServiceTO.OfertaTO();
            system.debug('ofertaCriada rm4 >> ' + ofertaCriada);
            
            System.debug('Entrada de oferta criada');
            ofertaCriada.orcamento = (gravarOrcamentoEmissao(oferta));
            system.debug('orcamento rm5 >> ' + orcamento);
            System.debug('Oferta criada orcamento = > ' + ofertaCriada.orcamento);
            
            //PLV-2414-INICIO
            System.debug('Entrada de oferta criada');
            // System.debug('oferta.retornoCalculo.precificacao.premio.total' + oferta.retornoCalculo.precificacao.premio.total);
            //PLV-2938 - Inicio - Alteração de parametro no metodo
            
            //PLV-3318 - INICIO INCLUSAO DE PARAMETRO NO METODO
            ofertaCriada.parcelamentos = buscarParcelamentos(oferta);
            //system.debug('parcelamentos santana'+ ofertaCriada.parcelamentos);
            //PLV-3318 - FIM
            
            //PLV-2938 - Fim - Alteração de parametro no metodo
            
            // PLV-2962 - INICIO
            ofertaCriada.retornoAceitacao = retornarCriticasODM(ofertaCriada.orcamento.numeroOrcamento);
            // PLV-2962 - FIM
            
            system.debug('Retorno de aceitacao => ' + ofertaCriada.retornoAceitacao);
            system.debug('parcelamentos rm6 >> ' + ofertaCriada.parcelamentos);
            System.debug('Oferta criada parcelamento = > ' + ofertaCriada.orcamento);
            //PLV-2414-FIM
            
            //PLV-3079 INICIO
            Boolean recusa = false;
            
            if(!ofertaCriada.retornoAceitacao.analises.isEmpty() || !ofertaCriada.retornoAceitacao.recusas.isEmpty() || !ofertaCriada.retornoAceitacao.pendencias.isEmpty()) recusa = true;
            if(recusa && ofertaCriada.orcamento.varConsultivo) continue;
            //PLV-3079 FIM
            
            //--> PLV2427 INICIO
            //PLV-2421 - Inicio - Inclução de parametro
            GerarRetornoRegras(ofertaCriada, oferta);           
            //PLV-2421 - Fim - Inclução de parametro
            //--> PLV2427 FIM
            
            //PLV-3079 fix INICIO
            ofertaCriada.orcamento.varConsultivo = false;
            //PLV-3079 fix FIM
            
            //PLV-3455 - INICIO - Criação do arquivo para guardar o payload
            Opportunity orc = [SELECT Id, Name FROM Opportunity WHERE Numero__c = :ofertaCriada.orcamento.numeroOrcamento LIMIT 1];
            
            FileController.createTextFile(orc.Name + '_' + Datetime.now().format('dd-MM-yyyy_HH:mm:ss') + '_' + 'retornoServico', JSON.serialize(ofertaCriada), orc.Id, '.min.json');
            
            //PLV-3455 - FIM
            
            ofertas.add(ofertaCriada);
            system.debug('ofertaCriada rm7 >> ' + ofertaCriada);
        }
        
        ofertasRetorno.ofertas = ofertas;
        system.debug('ofertaCriada rm8 >> ' + ofertasRetorno.ofertas);
        //PLV-3649 - INICIO/FIM - Código removido        
        return ofertasRetorno;
    }
    //PLV2365: FIM
    
    
    //PLV2365: INICIO
    public ServiceTO.PayRetornoOfertasTO gerarOrcamentoGravar(EmissaoTO.PayloadTO payloadTO)
    {
        ServiceTO.PayRetornoOfertasTO ofertasRetorno = new ServiceTO.PayRetornoOfertasTO();
        
        return ofertasRetorno;
    }
    //PLV2365: FIM
    
    //PLV2365: INICIO
    public EmissaoTO.PayloadTO gerarOrcamentoCivCalculo(String payload){
        system.debug('gerarOrcamentoCivCalculo >> inicio');
        system.debug(payload);
        
        EmissaoTO.OfertasTO oferta = (EmissaoTO.OfertasTO) JSON.deserialize(payload, EmissaoTO.OfertasTO.class);
        
        System.debug('=====> CIV: ' + oferta);
        
        EmissaoTO.PayloadTO payloadRetorno = new EmissaoTO.PayloadTO();
        
        payloadRetorno = gravarOrcamentoCIV(oferta);
        
        return payloadRetorno;
    }
    //PLV2365: FIM
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: cria os contratantes da proposta
*/
    public void gerarContratantes(List<ContratanteContrato__c> contratantes, List<Orcamento.ContratanteWrapper> listContratanteWrapper)
    {
        // Gera os contrantantes, enderecos, dados de pagamentos, garantias e seus grupos
        for (ContratanteContrato__c contratante : contratantes)
        {
            // Instancias
            Orcamento.ContratanteWrapper contratanteWrapper = new Orcamento.ContratanteWrapper();
            contratanteWrapper.sfContratante  = new ContratanteOrcamento__c();
            
            // Gera o contratante da proposta
            this.popularContratanteOrcamento(contratante, contratanteWrapper.sfContratante);
            
            //// gera as garantias do contratante da proposta
            contratanteWrapper.garantiasWrapper = new List<Orcamento.GarantiaWrapper>();
            System.debug('Alexandre mapGarantiaContratanteContrato: ' + mapGarantiaContratanteContrato.get(contratante.Id));
            this.popularGarantiasContratanteWrapper(mapGarantiaContratanteContrato.get(contratante.Id), contratanteWrapper.garantiasWrapper); 
            
            //// gera os grupos deste contratante
            contratanteWrapper.gruposWrapper = new List<Orcamento.GrupoWrapper>();
            this.gerarGrupos(mapGruposContrato.get(contratante.Id), contratanteWrapper.gruposWrapper);
            
            listContratanteWrapper.add(contratanteWrapper);
        }
    }
    
    /*
* @author Everymind - Sprint 23
* @Descrição: cria os grupos dos contratantes do orcamento
*/
    public void gerarGrupos(List<GrupoContrato__c> grupos, List<Orcamento.GrupoWrapper> listGrupoWrapper)
    {
        // Gera os grupos, garantias dos grupos e seus segurados
        for(GrupoContrato__c grupo : grupos)
        {
            // Instancias
            Orcamento.GrupoWrapper grupoWrapper = new Orcamento.GrupoWrapper();
            grupoWrapper.sfGrupo = new GrupoOrcamento__c();
            
            // Popular GrupoOrcamento__c
            this.popularGrupoOrcamento(grupo, grupoWrapper.sfGrupo);
            
            // gera as garantias do grupo da proposta
            grupoWrapper.garantiasWrapper = new List<Orcamento.GarantiaWrapper>();
            this.popularGarantiasGrupoWrapper(grupo.GarantiasGrupoContrato__r, grupoWrapper.garantiasWrapper); 
            
            // gera os segurados desse grupo
            grupoWrapper.seguradosWrapper = new List<Orcamento.SeguradoWrapper>();
            this.gerarSegurados(grupo.SeguradosContrato__r, grupoWrapper.seguradosWrapper); 
            
            listGrupoWrapper.add(grupoWrapper);
        }
    }
    
    /*
* @author Everymind - Sprint 23
* @Descrição: cria os segurados dos grupos dos contratantes da proposta
*/
    public void gerarSegurados(List<SeguradoContrato__c> segurados, List<Orcamento.SeguradoWrapper> listSeguradoWrapper)
    {
        for(SeguradoContrato__c segurado : segurados)
        {
            // Instancias
            Orcamento.SeguradoWrapper seguradoWrapper = new Orcamento.SeguradoWrapper();
            // Popular Segurado Orcamento
            seguradoWrapper.sfSegurado = new SeguradoOrcamento__c();
            this.popularSeguradoOrcamento(segurado, seguradoWrapper.sfSegurado);
            
            // gera as garantias do contratante da proposta
            seguradoWrapper.garantiasWrapper = new List<Orcamento.GarantiaWrapper>();
            this.popularGarantiasSeguradoWrapper(mapGarantiaSeguradoContrato.get(segurado.Id), seguradoWrapper.garantiasWrapper);
            
            listSeguradoWrapper.add(seguradoWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: persiste o orcamento
*/
    @testvisible // PLV-5331 INICIO / FIM
    public override Orcamento inserirRegistros(Orcamento orcamento)
    {        
        system.debug('orcamento => : ' + JSON.serialize(orcamento));
        system.debug('inserirRegistros');
        // Instancias
        List<GarantiaOrcamento__c> listGarantiaOrcamento = new List<GarantiaOrcamento__c>();
        List<GarantiaContratanteOrcamento__c> listGarantiaContratanteOrcamento = new List<GarantiaContratanteOrcamento__c>();
        List<GarantiaGrupoOrcamento__c> listGarantiaGrupoOrcamento = new List<GarantiaGrupoOrcamento__c>();
        List<GarantiaSeguradoOrcamento__c> listGarantiaSeguradoOrcamento = new List<GarantiaSeguradoOrcamento__c>();
        List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento = new List<RemuneracaoOrcamento__c>();
        List<ContratanteOrcamento__c> listContratanteOrcamento = new List<ContratanteOrcamento__c>();
        List<GrupoOrcamento__c> listGrupoOrcamento = new List<GrupoOrcamento__c>();
        List<SeguradoOrcamento__c> listSeguradoOrcamento = new List<SeguradoOrcamento__c>();
        
        // Insere a orcamento
        try{
            System.debug('Danilo this.orcamento.OrcamentoWrapper.sfOrcamento ' + orcamento.OrcamentoWrapper.sfOrcamento);//ANNVI-55 - INICIO
            Upsert orcamento.OrcamentoWrapper.sfOrcamento;//ANNVI-55 - FIM
            //PLV-3926 - INICIO - Ajuste para não atualizar o orçamento
            //this.orcamento.OrcamentoWrapper.sfOrcamento.StageName = 'Disponível para Contratação';
            //update this.orcamento.OrcamentoWrapper.sfOrcamento;
            //PLV-3926 - FIM
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        //Atribui id da orcamento nas Remuneracoes
        for(Orcamento.RemuneracaoOrcamentoWrapper remuneracaoOrcamentoWrapper : orcamento.OrcamentoWrapper.remuneracaoOrcamentoWrapper){//ANNVI-55 - INICIO
            remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento.Id = null;
            remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento.Oportunidade__c = orcamento.OrcamentoWrapper.sfOrcamento.Id;//ANNVI-55 - FIM
            listRemuneracaoOrcamento.add(remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento);
            
        }
        
        // Atribui id da orcamento nas garantias
        for(Orcamento.GarantiaWrapper garantiaWrapper : orcamento.OrcamentoWrapper.garantiasWrapper){ //ANNVI-55 - INICIO
            garantiaWrapper.sfGarantiaOrcamento.Id = null;
            garantiaWrapper.sfGarantiaOrcamento.Orcamento__c = orcamento.OrcamentoWrapper.sfOrcamento.Id;//ANNVI-55 - FIM
            listGarantiaOrcamento.add(garantiaWrapper.sfGarantiaOrcamento);
        }
        
        //Atribui id da orcamento nos contratantes
        for(Orcamento.ContratanteWrapper contratanteWrapper : orcamento.OrcamentoWrapper.contratantesWrapper ){//ANNVI-55 - INICIO
            
            contratanteWrapper.sfContratante.Id = null;
            contratanteWrapper.sfContratante.Orcamento__c = orcamento.OrcamentoWrapper.sfOrcamento.Id;//ANNVI-55 - FIM
            listContratanteOrcamento.add(contratanteWrapper.sfContratante);
            
        }
        
        // Insere os contratantes da orcamento
        try{
            insert listContratanteOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir contratantes da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        // Insere as remuneracoes da orcamento
        try{
            insert listRemuneracaoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir remuneracoes da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        // Insere as garantias da orcamento
        try{
            insert listGarantiaOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        // Atribui o id do contratante nas garantias e grupos
        for(Orcamento.ContratanteWrapper contratanteWrapper : orcamento.OrcamentoWrapper.contratantesWrapper){//ANNVI-55 - INICIO/FIM
            
            for(Orcamento.GarantiaWrapper garantiaWrapper : contratanteWrapper.garantiasWrapper){
                
                // Atribui o id do contratante para a garantiaWrapper
                garantiaWrapper.sfGarantiasContratanteOrcamento.Id = null;
                garantiaWrapper.sfGarantiasContratanteOrcamento.ContratanteOrcamento__c = contratanteWrapper.sfContratante.Id;
                listGarantiaContratanteOrcamento.add(garantiaWrapper.sfGarantiasContratanteOrcamento);
            }
            
            for(Orcamento.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){
                
                // Atribui o id do contratante para a grupoWrapper
                grupoWrapper.sfGrupo.Id = null;
                grupoWrapper.sfGrupo.ContratanteOrcamento__c = contratanteWrapper.sfContratante.Id;
                listGrupoOrcamento.add(grupoWrapper.sfGrupo);
            }
        }
        
        // Insere as garantias do contratante da orcamento
        try{
            insert listGarantiaContratanteOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias do contratante da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        // Insere os grupos do contratante da orcamento
        try{
            insert listGrupoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir grupos do contratante da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        // Atribui o id do grupo nas garantias e segurados
        for(Orcamento.ContratanteWrapper contratanteWrapper : orcamento.OrcamentoWrapper.contratantesWrapper){//ANNVI-55 - INICIO/FIM
            
            for(Orcamento.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {
                
                for (Orcamento.GarantiaWrapper garantiaWrapper : grupoWrapper.garantiasWrapper) {
                    
                    // Atribui o id do grupo para a garantiaWrapper
                    garantiaWrapper.sfGarantiaGrupoOrcamento.Id = null;
                    garantiaWrapper.sfGarantiaGrupoOrcamento.GrupoOrcamento__c = grupoWrapper.sfGrupo.Id;
                    listGarantiaGrupoOrcamento.add(garantiaWrapper.sfGarantiaGrupoOrcamento);
                    
                }
                
                for (Orcamento.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {
                    
                    // Atribui o id do grupo para o seguradoWrapper
                    seguradoWrapper.sfSegurado.Id = null;
                    seguradoWrapper.sfSegurado.GrupoOrcamento__c = grupoWrapper.sfGrupo.Id;
                    listSeguradoOrcamento.add(seguradoWrapper.sfSegurado);
                }
            }
            
        }
        
        // Insere as garantias do grupo da orcamento
        try{
            insert listGarantiaGrupoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias dos grupos da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        // Insere os segurados dos grupos da orcamento
        try{
            insert listSeguradoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir segurados dos grupos da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        // Atribui o id do segurado nas garantias e beneficiarios
        for(Orcamento.ContratanteWrapper contratanteWrapper : orcamento.OrcamentoWrapper.contratantesWrapper){//ANNVI-55 - INICIO/FIM
            
            for(Orcamento.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {
                
                for(Orcamento.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper){
                    
                    for (Orcamento.GarantiaWrapper garantiaWrapper : seguradoWrapper.garantiasWrapper) {
                        
                        // Atribui o id do grupo para a garantiaWrapper
                        garantiaWrapper.sfGarantiaSeguradoOrcamento.Id = null;
                        garantiaWrapper.sfGarantiaSeguradoOrcamento.SeguradoOrcamento__c = seguradoWrapper.sfSegurado.Id;
                        listGarantiaSeguradoOrcamento.add(garantiaWrapper.sfGarantiaSeguradoOrcamento);
                        
                    }
                }
            }
        }
        
        // Insere as garantias do segurado da orcamento
        try{
            insert listGarantiaSeguradoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias dos segurados da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        system.debug('inserirRegistros fim');
        
        return orcamento;
    }
    
    /*
* @author Everymind - Sprint 23
* @Descrição: monta o retorno do processamento de orcamento
*/
    public RetornoOrcamentoRestTO.ValidacaoOrcamentoTO converterOrcamentoParaRetornoOrcamento(Orcamento orcamento)
    {
        system.debug('converterOrcamentoParaRetornoOrcamento inicio');
        if(orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.isEmpty())
        {
            if(orcamento.orcamentoWrapper.sforcamento.Id != null)
            {
                orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas = new List<RetornoOrcamentoRestTO.DevolutivasTO>();
                
                RetornoOrcamentoRestTO.DevolutivasTO devolutivaTO = new RetornoOrcamentoRestTO.DevolutivasTO();
                devolutivaTO.tipoRegistro = 1;
                devolutivaTO.origem = 'INT';
                devolutivaTO.numeroCampo = 0;
                devolutivaTO.descricao = 'EMISSÃO: - registro inserido/atualizado com sucesso.';
                devolutivaTO.codigo = 0;
                
                orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.add(devolutivaTO);
            }
        }
        
        try 
        {
            orcamento.orcamentoWrapper.retornoWrapper.retorno.ofertas = new List<RetornoOrcamentoRestTO.OfertasTO>();
            RetornoOrcamentoRestTO.OfertasTO oferta = new RetornoOrcamentoRestTO.OfertasTO();
            
            RetornoOrcamentoRestTO.OrcamentoTO orcamentoRetorno = new RetornoOrcamentoRestTO.OrcamentoTO();
            
            orcamentoRetorno.status = orcamento.orcamentoWrapper.sforcamento.StageName;
            orcamentoRetorno.tipoSeguro = orcamento.orcamentoWrapper.sforcamento.Type;
            
            orcamentoRetorno.vigenciaFinal = String.valueOf(orcamento.orcamentoWrapper.sforcamento.VigenciaFinal__c);
            orcamentoRetorno.dataCalculo = String.valueOf(orcamento.orcamentoWrapper.sforcamento.DataCalculo__c);
            orcamentoRetorno.vigenciaInicial = String.valueOf(orcamento.orcamentoWrapper.sforcamento.VigenciaInicial__c);
            orcamentoRetorno.numeroOrcamento = Integer.valueOf(orcamento.orcamentoWrapper.sforcamento.Numero__c);
            orcamentoRetorno.meioComercializacao = orcamento.orcamentoWrapper.sforcamento.MeioComercializacao__c;
            orcamentoRetorno.qtdDiasVigencia = orcamento.orcamentoWrapper.sforcamento.VigenciaInicial__c.daysBetween(orcamento.orcamentoWrapper.sforcamento.VigenciaFinal__c);
            
            orcamentoRetorno.empresa = integer.valueOf(orcamento.orcamentoWrapper.retornoWrapper.codigoEmpresa);
            orcamentoRetorno.sucursal = integer.valueOf(orcamento.orcamentoWrapper.retornoWrapper.codigoSucursal);
            orcamentoRetorno.apolice = integer.valueOf(orcamento.orcamentoWrapper.retornoWrapper.numeroApolice);
            orcamentoRetorno.ramo = integer.valueOf(orcamento.orcamentoWrapper.retornoWrapper.codigoRamo);
            orcamentoRetorno.tipoAdesao = orcamento.orcamentoWrapper.retornoWrapper.tipoEndosso;
            
            oferta.orcamento = orcamentoRetorno;
            
            orcamento.orcamentoWrapper.retornoWrapper.retorno.ofertas.add(oferta);
            
        }catch (Exception e){
            throw new orcamentoBuilderException('Exception: Erro ao gerar retorno da orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        system.debug('converterOrcamentoParaRetornoOrcamento fim');
        
        return orcamento.orcamentoWrapper.retornoWrapper.retorno;
    }
    
    /* ---------------------------------- WRAPPERS ---------------------------------------------------------------- */
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: inclui no wrapper
*/
    @TestVisible //ANNVI-55 - INICIO/FIM
    private void popularGarantiasWrapper(List<GarantiaContrato__c> garantias, List<Orcamento.GarantiaWrapper> listGarantiasWrapper)
    {
        for(GarantiaContrato__c garantia : garantias) 
        {
            Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();
            garantiaWrapper.sfGarantiaOrcamento = new GarantiaOrcamento__c();
            this.popularGarantiaOrcamento(garantiaWrapper.sfGarantiaOrcamento, garantia); 
            
            listGarantiasWrapper.add(garantiaWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: inclui no wrapper
*/
    private void popularGarantiasContratanteWrapper(List<GarantiaContratanteContrato__c> garantias, List<Orcamento.GarantiaWrapper> listGarantiasWrapper)
    {
        for(GarantiaContratanteContrato__c garantia : garantias) 
        {
            Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();
            garantiaWrapper.sfGarantiasContratanteOrcamento = new GarantiaContratanteOrcamento__c();
            this.popularGarantiaContratanteOrcamento(garantiaWrapper.sfGarantiasContratanteOrcamento, garantia);
            
            listGarantiasWrapper.add(garantiaWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: inclui no wrapper
*/
    private void popularGarantiasGrupoWrapper(List<GarantiaGrupoContrato__c> garantias, List<Orcamento.GarantiaWrapper> listGarantiasWrapper)
    {
        for(GarantiaGrupoContrato__c garantia : garantias) 
        {
            Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();
            garantiaWrapper.sfGarantiaGrupoOrcamento = new GarantiaGrupoOrcamento__c();
            this.popularGarantiaGrupoOrcamento(garantiaWrapper.sfGarantiaGrupoOrcamento, garantia);
            listGarantiasWrapper.add(garantiaWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: inclui no wrapper
*/
    private void popularGarantiasSeguradoWrapper(List<GarantiaSeguradoContrato__c> garantias, List<Orcamento.GarantiaWrapper> listGarantiasWrapper)
    {
        for(GarantiaSeguradoContrato__c garantia : garantias) 
        {
            Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();
            garantiaWrapper.sfGarantiaSeguradoOrcamento = new GarantiaSeguradoOrcamento__c();
            this.popularGarantiaSeguradoOrcamento(garantiaWrapper.sfGarantiaSeguradoOrcamento, garantia);
            listGarantiasWrapper .add(garantiaWrapper);
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: inclui no wrapper
*/
    public void gerarRemuneracaoOrcamentoWrapper(List<RemuneracaoContrato__c> remuneracoes, List<Orcamento.RemuneracaoOrcamentoWrapper> listRemuneracaoOrcamentoWrappers)
    {
        // Gera as remuneracoes e seus favorecidos
        for(RemuneracaoContrato__c remuneracao : remuneracoes)
        {
            // Instancias
            Orcamento.RemuneracaoOrcamentoWrapper remuneracaoOrcamentoWrapper = new Orcamento.RemuneracaoOrcamentoWrapper();
            remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento = new RemuneracaoOrcamento__c();
            // Popula a remuneracao da proposta
            this.popularRemuneracaoOrcamento(remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento, remuneracao);
            
            listRemuneracaoOrcamentoWrappers.add(remuneracaoOrcamentoWrapper);
        }
    }
    // PLV-3926 - INICIO  - Metodo para gerar o numero da oferta
    public String gerarNumeroOferta(){
        ContadorCodigo__c confNumOferta = [SELECT Numero__c FROM ContadorCodigo__c WHERE Name = 'NumeroOferta' FOR UPDATE];
        Integer numOferta = Integer.valueOf(confNumOferta.Numero__c);
        numOferta++;
        confNumOferta.Numero__c = numOferta;
        update confNumOferta;
        return String.valueOf(numOferta).leftPad(10,'0');
    }
    // PLV-3926 - FIM
    
    /* ---------------------------------- MODELOS ----------------------------------------------------------------- */
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos de endosso do orcamento baseado no contrato antigo
*/
    @TestVisible
    private void popularOrcamento(Contract contrato, Opportunity orcamento, EmissaoTO.PayloadTO payloadTO, String numeroOrcamento)
    {
        try
        {
            system.debug('payload DaniloOrcamentoGenericoBuilder' + payloadTO);
            
            // PLV-3895 - INICIO
            payloadTOpublic = payloadTO;
            //PLV-3926 - INICIO - Ajuste para não quebrar a classe
            if(payloadTOpublic.retornoCalculo != null){
                for(EmissaoTO.CoberturaTO cobertura : payloadTOpublic.retornoCalculo.precificacao.coberturas){
                    mapCoberturasGarantiaOrcamento.put(cobertura.sigla, cobertura);
                }
                for(EmissaoTO.CoberturaTO cobertura : payloadTOpublic.retornoCalculo.precificacao.contratantes[0].coberturas){
                    mapCoberturasGarantiaContratanteOrcamento.put(cobertura.sigla, cobertura);
                }
                for(EmissaoTO.CoberturaTO cobertura : payloadTOpublic.retornoCalculo.precificacao.contratantes[0].grupos[0].coberturas){
                    mapCoberturasGarantiaGrupoOrcamento.put(cobertura.sigla, cobertura);
                }
                for(EmissaoTO.CoberturaTO cobertura : payloadTOpublic.retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0].coberturas){
                    mapCoberturasGarantiaSeguradoOrcamento.put(cobertura.sigla, cobertura);
                }
            }
            //PLV-3926 - FIM
            for(Garantia__c garantia : [Select Id, Sigla__c FROM Garantia__c]){
                mapGarantiasSigla.put(garantia.Id, garantia.Sigla__c);
            }
            // PLV-3895 - FIM
            // número do orcamento: deve gerar um novo orcamento com outro número
            orcamento.Name = payloadTO.orcamento.meioComercializacao + '-' + numeroOrcamento.leftPad(8,'0');
            orcamento.Numero__c = numeroOrcamento.leftPad(8,'0');
            // MOCK - FAVOR REVERTER APÓS dataCalculo VIER PREENCHIDO
            orcamento.DataCalculo__c = Date.valueOf(payloadTO.orcamento.dataCalculo);
            // payloadTO.orcamento.dataCalculo = '2020-06-30';
            // orcamento.DataCalculo__c = Date.valueOf(payloadTO.orcamento.dataCalculo);
            // MOCK - FIM
            //PLV-3926 - INICIO
            orcamento.NumeroOferta__c = gerarNumeroOferta();
            //PLV-3926 - FIM
            // PLV-2271-28 Inclusao da vigencia inicial
            orcamento.VigenciaInicial__c = Date.valueOf(payloadTO.orcamento.dataCalculo); //PLV-4154 - INICIO/FIM - Ajuste variavel
            // PLV-2271-28 Inclusao da vigencia inicial
            orcamento.Type = payloadTO.orcamento.tipoSeguro;
            //RVI-117/118 - INICIO
            orcamento.indiceIPCA__c = payloadTO.orcamento.IndiceIPCA;
            orcamento.ContratoRenovado__c = payloadTO.orcamento.idContratoRenovado;
            //RVI-117/118 - FIM
            orcamento.ContractId = contrato.Id;
            // quantidade de dias: vigência final - vigência inicial + 1 (alterar fórmula para todo tipo de seguro, inclusive contrato novo)
            // Retornar as informações do orcamento criado.
            orcamento.MeioComercializacao__c = payloadTO.orcamento.meioComercializacao;
            System.debug('JSON.serialize(payloadTO) ' + JSON.serialize(payloadTO));
            orcamento.Payload__c = JSON.serialize(payloadTO);
            orcamento.StageName = 'Em criação';
            orcamento.CloseDate = System.today();//orcamento.VigenciaFinal__c;
            orcamento.TipoEndosso__c = payloadTO.orcamento.tipoEndosso;
            System.debug('Danilo payloadTO.orcamento.tipoEndosso '+ payloadTO.orcamento.tipoEndosso);
            //orcamento.CupomDesconto__c = payloadTO.orcamento.cupom; // AV-664 INICIO FIM
            //PLV-1197-27 - Validação para proposta e orçamento não encontrado
            //PLV-5883 INICIO
            if(contrato.Proposta__r == null){
                throw new OrcamentoBuilderException('Proposta não encontrada');
            }
            
            if(contrato.Proposta__r.Opportunity == null){
                throw new OrcamentoBuilderException('Orçamento não encontrada');
            }
            //PLV-5883 FIM
            //PLV-1197-27 - Validação para proposta e orçamento não encontrado
            
            // Campos clonados do contrato
            orcamento.Nome_Social__c = contrato.Nome_Social__c; // LECVPV-188(CANCELAMENTO) INICIO/FIM
            orcamento.Produto__c = contrato.Produto__c;
            orcamento.FormaPagamento__c = contrato.FormaPagamento__c;
            orcamento.CanalDistribuicao__c = contrato.CanalDistribuicao__c;
            orcamento.AccountId = contrato.AccountId;
            orcamento.CodigoCorretor__c = contrato.CodigoCorretor__c;
            orcamento.Description = contrato.Description;
            orcamento.RecordTypeId = contrato.Proposta__r.Opportunity.RecordTypeId; //PLV-5883 INICIO/FIM
            orcamento.Origem__c = contrato.Origem__c;
            orcamento.VigenciaFinal__c = contrato.VigenciaFinal__c;
            
            // PLV-3895 - Inicio
            if(payloadTO.retornoCalculo != null && payloadTO.retornoCalculo.precificacao != null){//TODO
                orcamento.Juros__c = payloadTO.retornoCalculo.precificacao.juros;
                orcamento.IOF__c = payloadTO.retornoCalculo.precificacao.iof;
                orcamento.Encargos__c = payloadTO.retornoCalculo.precificacao.encargos;
                orcamento.CustoApolice__c = payloadTO.retornoCalculo.precificacao.custoApolice;
                
                if(payloadTO.retornoCalculo.precificacao.premio != null){
                    System.debug('Rogerio ' + payloadTO.retornoCalculo.precificacao.premio);
                    orcamento.PremioPuro__c = payloadTO.retornoCalculo.precificacao.premio.puro;
                    orcamento.PremioTotal__c = payloadTO.retornoCalculo.precificacao.premio.total;
                    orcamento.PremioPuroInterno__c = payloadTO.retornoCalculo.precificacao.premio.puroInterno;
                    orcamento.DescontoPremioPuro__c = payloadTO.retornoCalculo.precificacao.premio.puroDesconto;
                    orcamento.PremioPuroResseguro__c = payloadTO.retornoCalculo.precificacao.premio.puroResseguro;
                    orcamento.PremioComercial__c = payloadTO.retornoCalculo.precificacao.premio.comercial;
                    orcamento.DescontoPremioComercial__c = payloadTO.retornoCalculo.precificacao.premio.comercialDesconto;
                    orcamento.PremioInformado__c = payloadTO.retornoCalculo.precificacao.premio.informado;
                }
                if(payloadTO.retornoCalculo.precificacao.taxa != null){
                    orcamento.TaxaPura__c = payloadTO.retornoCalculo.precificacao.taxa.pura;
                    orcamento.TaxaMensal__c = payloadTO.retornoCalculo.precificacao.taxa.mensal;
                    orcamento.TaxaAnual__c = payloadTO.retornoCalculo.precificacao.taxa.anual;
                    orcamento.TaxaPuraResseguro__c = payloadTO.retornoCalculo.precificacao.taxa.puroResseguro;
                    orcamento.TaxaPuraInterna__c = payloadTO.retornoCalculo.precificacao.taxa.puroInterno;
                    orcamento.TaxaComercial__c = payloadTO.retornoCalculo.precificacao.taxa.comercial;
                }
            }
            // PLV-3895 - Fim
        }
        catch (Exception e){
            throw new OrcamentoBuilderException('Origem: orcamento >> mapeiaOrcmento >> DEPARA de contrado p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos remuneracao do orcamento baseados no contato original
*/
    @testVisible
    private void popularRemuneracaoOrcamento(RemuneracaoOrcamento__c remuneracaoOrcamento, RemuneracaoContrato__c remuneracao)
    {
        try
        {
            remuneracaoOrcamento.TipoRemuneracao__c = remuneracao.TipoRemuneracao__c;
            remuneracaoOrcamento.Percentual__c = remuneracao.Percentual__c;
        }
        catch(Exception e){
            throw new OrcamentoBuilderException('Origem: orcamento >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos do orcamento baseados no contrato
*/
    @testvisible // PLV-5331 INICIO / FIM
    private void popularContratanteOrcamento(ContratanteContrato__c contratanteContrato, ContratanteOrcamento__c contratanteOrcamento)
    {
        
        system.debug('entrou ===> OrcamentoGenericoBuilder - popularContratanteOrcamento L:894'  );
        
        try 
        {
            contratanteOrcamento.Bairro__c = contratanteContrato.Bairro__c;
            contratanteOrcamento.CEP__c = contratanteContrato.CEP__c;
            contratanteOrcamento.Cidade__c = contratanteContrato.Cidade__c;
            contratanteOrcamento.Complemento__c = contratanteContrato.Complemento__c;
            contratanteOrcamento.Conta__c = contratanteContrato.Conta__c;
            contratanteOrcamento.TipoEndereco__c = contratanteContrato.TipoEndereco__c;
            contratanteOrcamento.TipoLogradouro__c = contratanteContrato.TipoLogradouro__c;
            contratanteOrcamento.Tipo__c = contratanteContrato.Tipo__c;
            contratanteOrcamento.Estado__c = contratanteContrato.Estado__c;
            contratanteOrcamento.Logradouro__c = contratanteContrato.Logradouro__c;
            contratanteOrcamento.NumeroEndereco__c = contratanteContrato.NumeroEndereco__c;
            contratanteOrcamento.Pais__c = contratanteContrato.Pais__c;
            contratanteOrcamento.Numero__c = contratanteContrato.Numero__c;
            // PLV-3895 - Inicio
            if(payloadTOpublic.retornoCalculo != null && payloadTOpublic.retornoCalculo.precificacao != null &&
                payloadTOpublic.retornoCalculo.precificacao.contratantes[0] != null){
                    EmissaoTO.ContratanteTO base = payloadTOpublic.retornoCalculo.precificacao.contratantes[0];
                    system.debug('===> base' + base );

                    contratanteOrcamento.IOF__c = base.iof;
                    if(base.premio != null){
                       contratanteOrcamento.PremioComercial__c = base.premio.comercial;
                       contratanteOrcamento.PremioPuro__c = base.premio.puro; 
                       contratanteOrcamento.PremioTotal__c = base.premio.total;
                    }
                    if(base.taxa != null){
                       contratanteOrcamento.TaxaPura__c = base.taxa.pura;
                       contratanteOrcamento.TaxaTotal__c = base.taxa.total;
                       contratanteOrcamento.TaxaComercial__c = base.taxa.comercial;
                    }
                    if(base.descontoAgravo[0] != null){
                        if(contratanteOrcamento.TipoDescontoAgravo__c != null)
                            contratanteOrcamento.TipoDescontoAgravo__c = base.descontoAgravo[0].tipo;
                        for(EmissaoTO.DescontoAgravoTO descontoAgravo : base.descontoAgravo) {
                            if(contratanteOrcamento.TipoDescontoAgravo__c == 'TEC') {
                                contratanteOrcamento.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                                contratanteOrcamento.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                            }
                            else if(contratanteOrcamento.TipoDescontoAgravo__c == 'COM') {
                                contratanteOrcamento.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                                contratanteOrcamento.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                            }
                            else if(contratanteOrcamento.TipoDescontoAgravo__c == 'BAT') {
                                contratanteOrcamento.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                                contratanteOrcamento.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                            }
                        }
                    }
                }
            // PLV-3895 - FIM
            
        }
        catch (Exception e){
            throw new OrcamentoBuilderException('Origem: orcamento >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }

    private final String descAgrPercTec = 'DescontoAgravoPercentualTecnico__c';
    private final String descAgrMonTec = 'DescontoAgravoMonetarioTecnico__c';

    @TestVisible
    private void fillFieldsDescAgr(SObject sObj, EmissaoTO.DescontoAgravoTO descAgr){

        System.debug('Entrou no Método: FILLFIELDSDESCAGR');

        System.debug('Sobject Antes >>>: ' + sObj );
                
        SObjectType currentType = sObj.getSobjectType();
        
        Map<String,Schema.SObjectField> mfields = currentType.getDescribe().fields.getMap();

        List<String> fields = new List<String>();
        
        for(Schema.SObjectField sobjectField : mfields.values()){

            String fieldName = sobjectField.getDescribe().getName();

            if(fieldName == descAgrPercTec || fieldName == descAgrMonTec){
                fields.add(fieldName);
            }
        }

        if(fields.contains(descAgrPercTec) || fields.contains(descAgrMonTec)){
            sObj.put(descAgrPercTec, descAgr.percentual);
            sObj.put(descAgrMonTec, descAgr.monetario);
        }

        System.debug('Sobject DEPOIS >>>: ' + sObj );

    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos da novo grupo baseados no orcamento
*/
    @TestVisible
    private void popularGrupoOrcamento(GrupoContrato__c grupoContrato, GrupoOrcamento__c grupo)
    {
        try
        {
            grupo.Descricao__c = grupoContrato.Descricao__c;
            grupo.Name = grupoContrato.Name;
            grupo.TipoCalculo__c = grupoContrato.TipoCalculo__c;
            grupo.QuantidadeVidas__c = grupoContrato.QuantidadeVidas__c;
            grupo.Numero__c = grupoContrato.Numero__c;
            
            // PLV-3895 - Inicio
            if(payloadTOpublic.retornoCalculo != null && payloadTOpublic.retornoCalculo.precificacao != null &&
               payloadTOpublic.retornoCalculo.precificacao.contratantes[0] != null && 
               payloadTOpublic.retornoCalculo.precificacao.contratantes[0].grupos != null){
                   EmissaoTO.GrupoTO base = payloadTOpublic.retornoCalculo.precificacao.contratantes[0].grupos[0];
                   grupo.IOF__c = base.iof;
                   if(base.premio != null){
                       grupo.PremioComercial__c = base.premio.comercial;
                       grupo.PremioPuro__c = base.premio.puro;
                       grupo.PremioTotal__c = base.premio.total;
                   }
                   if(base.taxa != null){
                       grupo.TaxaPura__c = base.taxa.pura;
                       grupo.TaxaTotal__c = base.taxa.total;
                       grupo.TaxaComercial__c = base.taxa.comercial;
                   }
                   
                   if(base.descontoAgravo[0] != null){
                       if(grupo.TipoDescontoAgravo__c != null)
                           grupo.TipoDescontoAgravo__c = base.descontoAgravo[0].tipo;
                       
                       for(EmissaoTO.DescontoAgravoTO descontoAgravo : base.descontoAgravo) {
                           if(grupo.TipoDescontoAgravo__c == 'TEC') {
                               grupo.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                               grupo.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                           }
                           else if(grupo.TipoDescontoAgravo__c == 'COM') {
                               grupo.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                               grupo.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                           }
                           else if(grupo.TipoDescontoAgravo__c == 'BAT') {
                               grupo.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                               grupo.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                           }
                       }
                   }
               }
            // PLV-3895 - FIM
            
        }
        catch (Exception e)
        {
            throw new OrcamentoBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: ipopula os ojbetos da novo orcamento  baseados no contrato
*/
    @TestVisible
    private void popularSeguradoOrcamento(SeguradoContrato__c seguradoContrato, SeguradoOrcamento__c segurado)
    {
        try
        {
            segurado.Conta__c = seguradoContrato.Conta__c;
            segurado.EnderecoBoleto__c = seguradoContrato.EnderecoBoleto__c;
            segurado.IOF__c = seguradoContrato.IOF__c;
            segurado.IPCA__c = seguradoContrato.IPCA__c;
            segurado.PorcentagemParticipacaoSegurado__c = seguradoContrato.PorcentagemParticipacaoSegurado__c;
            segurado.PorcentagemParticipacaoVida__c = seguradoContrato.PorcentagemParticipacaoVida__c;
            segurado.QuantidadeParcelas__c = seguradoContrato.QuantidadeParcelas__c;
            segurado.Reenquadramento__c = seguradoContrato.Reenquadramento__c;
            segurado.TipoCusteio__c = seguradoContrato.TipoCusteio__c;
            segurado.TipoResponsavelPagamento__c = seguradoContrato.TipoResponsavelPagamento__c;
            segurado.VencimentoPrimeiraParcela__c = seguradoContrato.VencimentoPrimeiraParcela__c;
            segurado.Numero__c = seguradoContrato.Numero__c;
            System.debug('ISABELA FIN');
            // PLV-3895 - Inicio
            if(payloadTOpublic.retornoCalculo != null && payloadTOpublic.retornoCalculo.precificacao != null &&
               payloadTOpublic.retornoCalculo.precificacao.contratantes[0] != null && 
               payloadTOpublic.retornoCalculo.precificacao.contratantes[0].grupos[0] != null &&
               payloadTOpublic.retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0] != null){
                   EmissaoTO.SeguradoTO base = payloadTOpublic.retornoCalculo.precificacao.contratantes[0].grupos[0].segurados[0];
                   segurado.IOF__c = base.iof;
                   if(base.premio != null){
                       segurado.PremioComercial__c = base.premio.comercial;
                       segurado.PremioPuro__c = base.premio.puro;
                       segurado.PremioTotal__c = base.premio.total;
                   }
                   if(base.taxa != null){
                       segurado.TaxaPura__c = base.taxa.pura;
                       segurado.TaxaTotal__c = base.taxa.total;
                       segurado.TaxaComercial__c = base.taxa.comercial;
                   }
                   
                   if(base.descontoAgravo[0] != null){
                       if(segurado.TipoDescontoAgravo__c != null)
                           segurado.TipoDescontoAgravo__c = base.descontoAgravo[0].tipo;
                       
                       for(EmissaoTO.DescontoAgravoTO descontoAgravo : base.descontoAgravo) {
                           if(segurado.TipoDescontoAgravo__c == 'TEC') {
                               segurado.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                               segurado.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                           }
                           else if(segurado.TipoDescontoAgravo__c == 'COM') {
                               segurado.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                               segurado.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                           }
                           else if(segurado.TipoDescontoAgravo__c == 'BAT') {
                               segurado.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                               segurado.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                           }
                       }
                   }
               }
            // PLV-3895 - FIM
            
        }
        catch (Exception e)
        {
            throw new OrcamentoBuilderException('Origem: Proposta >> mapeiaProposta >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos da nova proposta baseados no orcamento
*/
    @TestVisible
    private void popularGarantiaOrcamento(GarantiaOrcamento__c garantia, GarantiaContrato__c garantiaContrato)
    {
        try
        {
            garantia.Capital__c = garantiaContrato.Capital__c;
            garantia.GarantiaProduto__c = garantiaContrato.GarantiaProduto__c;
            garantia.Garantia__c = garantiaContrato.Garantia__c;
            garantia.LimiteCapital__c = garantiaContrato.LimiteCapital__c;
            garantia.NumeroSerie__c = garantiaContrato.NumeroSerie__c;
            garantia.NumeroSorte__c = garantiaContrato.NumeroSorte__c;
            garantia.Percentual__c = garantiaContrato.Percentual__c;
            garantia.TipoCapital__c = garantiaContrato.TipoCapital__c;
            //PLV-3926 - INICIO
            garantia.CurrencyIsoCode = garantiaContrato.CurrencyIsoCode;
            //PLV-3926 - FIM
            //PLV-3731 - INICIO
            garantia.ValorCotacao__c = garantiaContrato.ValorCotacao__c;
            //PLV-3731-FIM
            
            // PLV-3895 - Inicio
            EmissaoTO.CoberturaTO base = mapCoberturasGarantiaOrcamento.get(mapGarantiasSigla.get(garantia.Garantia__c));

            if(base != null){
                garantia.IOF__c = base.iof!=null ? base.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                
                if(base.premio != null){
                    garantia.PremioComercial__c = base.premio.comercial;
                    garantia.PremioPuro__c = base.premio.puro;
                    garantia.PremioTotal__c = base.premio.total;
                }
                if(base.taxa != null){
                    garantia.TaxaPura__c = base.taxa.pura;
                    garantia.TaxaTotal__c = base.taxa.total;
                    garantia.TaxaComercial__c = base.taxa.comercial;
                }
                if(base.descontoAgravo[0] != null){
                    if(garantia.TipoDescontoAgravo__c != null)
                        garantia.TipoDescontoAgravo__c = base.descontoAgravo[0].tipo;
                    
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : base.descontoAgravo) {
                        if(garantia.TipoDescontoAgravo__c == 'TEC') {
                            garantia.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'COM') {
                            garantia.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'BAT') {
                            garantia.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                        }
                    }
                }
            }
            // PLV-3895 - FIM
        }
        catch (Exception e){
            throw new OrcamentoBuilderException('Origem: Orcamento >> mapeiaOrcamento >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos da nova proposta baseados no orcamento
*/
    @TestVisible
    private void popularGarantiaContratanteOrcamento(GarantiaContratanteOrcamento__c garantia, GarantiaContratanteContrato__c garantiaContratanteContrato)
    {
        try
        {
            garantia.Capital__c = garantiaContratanteContrato.Capital__c;
            garantia.GarantiaProduto__c = garantiaContratanteContrato.GarantiaProduto__c;
            garantia.Garantia__c = garantiaContratanteContrato.Garantia__c;
            garantia.NumeroSerie__c = garantiaContratanteContrato.NumeroSerie__c;
            garantia.NumeroSorte__c = garantiaContratanteContrato.NumeroSorte__c;
            garantia.Percentual__c = garantiaContratanteContrato.Percentual__c;
            //PLV-3731 - INICIO
            garantia.ValorCotacao__c = garantiaContratanteContrato.ValorCotacao__c;
            //PLV-3731 - FIM
            //PLV-3926 - INICIO
            garantia.CurrencyIsoCode = garantiaContratanteContrato.CurrencyIsoCode;
            //PLV-3926 - FIM
            // PLV-3895 - Inicio
            EmissaoTO.CoberturaTO base = mapCoberturasGarantiaContratanteOrcamento.get(mapGarantiasSigla.get(garantia.Garantia__c));
            
            if(base != null){
                garantia.IOF__c = base.iof!=null ? base.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                
                if(base.premio != null){
                    garantia.PremioComercial__c = base.premio.comercial;
                    garantia.PremioPuro__c = base.premio.puro;
                    garantia.PremioTotal__c = base.premio.total;
                }
                if(base.taxa != null){
                    garantia.TaxaPura__c = base.taxa.pura;
                    garantia.TaxaTotal__c = base.taxa.total;
                    garantia.TaxaComercial__c = base.taxa.comercial;
                }
                if(base.descontoAgravo[0] != null){
                    if(garantia.TipoDescontoAgravo__c != null)
                        garantia.TipoDescontoAgravo__c = base.descontoAgravo[0].tipo;
                    
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : base.descontoAgravo) {
                        if(garantia.TipoDescontoAgravo__c == 'TEC') {
                            garantia.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'COM') {
                            garantia.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'BAT') {
                            garantia.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                        }
                    }
                }
            }
            // PLV-3895 - FIM
            
        }
        catch (Exception e){
            throw new OrcamentoBuilderException('Origem: Orcamento >> mapeiaOrcamento >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos da nova proposta baseados no orcamento
*/
    @testVisible
    private void popularGarantiaGrupoOrcamento(GarantiaGrupoOrcamento__c garantia, GarantiaGrupoContrato__c garantiaGrupoContrato)
    {
        try
        {
            garantia.Capital__c = garantiaGrupoContrato.Capital__c;
            garantia.GarantiaProduto__c = garantiaGrupoContrato.GarantiaProduto__c;
            garantia.Garantia__c = garantiaGrupoContrato.Garantia__c;
            garantia.NumeroSerie__c = garantiaGrupoContrato.NumeroSerie__c;
            garantia.NumeroSorte__c = garantiaGrupoContrato.NumeroSorte__c;
            garantia.Percentual__c = garantiaGrupoContrato.Percentual__c;
            //PLV-3731 - INICIO
            garantia.ValorCotacao__c = garantiaGrupoContrato.ValorCotacao__c;
            //PLV-3731-FIM
            //PLV-3926 - INICIO
            garantia.CurrencyIsoCode = garantiaGrupoContrato.CurrencyIsoCode;
            //PLV-3926 - FIM
            // PLV-3895 - Inicio
            EmissaoTO.CoberturaTO base = mapCoberturasGarantiaGrupoOrcamento.get(mapGarantiasSigla.get(garantia.Garantia__c));
            
            if(base != null){
                garantia.IOF__c = base.iof!=null ? base.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                
                if(base.premio != null){
                    garantia.PremioComercial__c = base.premio.comercial;
                    garantia.PremioPuro__c = base.premio.puro;
                    garantia.PremioTotal__c = base.premio.total;
                }
                if(base.taxa != null){
                    garantia.TaxaPura__c = base.taxa.pura;
                    garantia.TaxaTotal__c = base.taxa.total;
                    garantia.TaxaComercial__c = base.taxa.comercial;
                }
                if(base.descontoAgravo[0] != null){
                    if(garantia.TipoDescontoAgravo__c != null)
                        garantia.TipoDescontoAgravo__c = base.descontoAgravo[0].tipo;
                    
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : base.descontoAgravo) {
                        if(garantia.TipoDescontoAgravo__c == 'TEC') {
                            garantia.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'COM') {
                            garantia.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'BAT') {
                            garantia.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                        }
                    }
                }
            }
            // PLV-3895 - FIM
            
        }
        catch (Exception e){
            throw new OrcamentoBuilderException('Origem: Orcamento >> mapeiaOrcamento >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: popula os ojetos da nova proposta baseados no orcamento
*/
    @TestVisible
    private void popularGarantiaSeguradoOrcamento(GarantiaSeguradoOrcamento__c garantia, GarantiaSeguradoContrato__c garantiaSeguradoContrato)
    {
        try
        {
            garantia.Capital__c = garantiaSeguradoContrato.Capital__c;
            garantia.GarantiaProduto__c = garantiaSeguradoContrato.GarantiaProduto__c;
            garantia.Garantia__c = garantiaSeguradoContrato.Garantia__c;
            garantia.NumeroSerie__c = garantiaSeguradoContrato.NumeroSerie__c;
            garantia.NumeroSorte__c = garantiaSeguradoContrato.NumeroSorte__c;
            garantia.Percentual__c = garantiaSeguradoContrato.Percentual__c;
            //PLV-3731 - INICIO
            garantia.ValorCotacao__c = garantiaSeguradoContrato.ValorCotacao__c;
            //PLV-3731-FIM
            //PLV-3926 - INICIO
            garantia.CurrencyIsoCode = garantiaSeguradoContrato.CurrencyIsoCode;
            //PLV-3926 - FIM
            // PLV-3895 - Inicio
            EmissaoTO.CoberturaTO base = mapCoberturasGarantiaSeguradoOrcamento.get(mapGarantiasSigla.get(garantia.Garantia__c));
            
            if(base != null){
                garantia.IOF__c = base.iof!=null ? base.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
                
                if(base.premio != null){
                    garantia.PremioComercial__c = base.premio.comercial;
                    garantia.PremioPuro__c = base.premio.puro;
                    garantia.PremioTotal__c = base.premio.total;
                }
                if(base.taxa != null){
                    garantia.TaxaPura__c = base.taxa.pura;
                    garantia.TaxaTotal__c = base.taxa.total;
                    garantia.TaxaComercial__c = base.taxa.comercial;
                }
                if(base.descontoAgravo[0] != null){
                    if(garantia.TipoDescontoAgravo__c != null)
                        garantia.TipoDescontoAgravo__c = base.descontoAgravo[0].tipo;
                    
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : base.descontoAgravo) {
                        if(garantia.TipoDescontoAgravo__c == 'TEC') {
                            garantia.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'COM') {
                            garantia.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                        }
                        else if(garantia.TipoDescontoAgravo__c == 'BAT') {
                            garantia.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                            garantia.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                        }
                    }
                }
            }
            // PLV-3895 - FIM
            
        }
        catch (Exception e){
            throw new OrcamentoBuilderException('Origem: Orcamento >> mapeiaOrcamento >> DEPARA de orcamento p/ objeto SF \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }
    
    /* ---------------------------------- HELPERS ----------------------------------------------------------------- */
    
    /*
*  @author Everymind - Sprint 23
*  @Descrição: helper p/ carregas os registros complementares p/ criaçãoda novo Contrato
*/
    @TestVisible //ANNVI-55 - INICIO/FIM
    private void buscarRegistrosDominios()
    {
        // Declara variveis
        Set<String> setContratante = new Set<String>();
        Set<String> setSegurado	= new Set<String>();
        
        List<GrupoContrato__c> gruposTemp;
        List<GarantiaSeguradoContrato__c> garantias;
        List<GarantiaContratanteContrato__c> garantiasContratanteTemp;

        // Varre os contratantes e monta a chave p/ contulta dos grupos filhos dele
        for(ContratanteContrato__c contratante : contrato.ContratantesContrato__r)
            setContratante.add(contratante.Id);
        
        if(!Test.isRunningTest()){//ANNVI-55 - INICIO
            grupos = daoContrato.buscarGruposPorContratante(setContratante);
            garantiasContratante = daoContrato.buscarGarantiasContratante(setContratante);  
        }//ANNVI-55 - FIM
        
        // Varre os segurados dos grupos e monta a chave p/ contulta das garantias do segurado filhos dele
        for(GrupoContrato__c grupo : grupos)
        {
            for(SeguradoContrato__c segurado : grupo.SeguradosContrato__r)
                setSegurado.add(segurado.Id);
        }
        
        // Monta os mapas de grupo e garantias do segurado do orcamento
        for(ContratanteContrato__c contratante : contrato.ContratantesContrato__r)
        {
            gruposTemp = new List<GrupoContrato__c>();
            garantiasContratanteTemp = new List<GarantiaContratanteContrato__c>();
            
            for(GrupoContrato__c grupo : grupos)
            {
                if(contratante.Id == grupo.ContratanteContrato__c)
                    gruposTemp.add(grupo);
            }
            
            for(GarantiaContratanteContrato__c garantiaContatante : garantiasContratante)
            {
                if(contratante.Id == garantiaContatante.ContratanteContrato__c)
                    garantiasContratanteTemp.add(garantiaContatante);
            }

            //ANNVI-55 - INICIO
            if(!Test.isRunningTest()){
                garantiasSeguradoContrato = daoContrato.buscarGarantiasSegurado(setSegurado);
            }
            //ANNVI-55 - FIM
            for(GrupoContrato__c grupo : gruposTemp)
            {
                for(SeguradoContrato__c segurado : grupo.SeguradosContrato__r)
                {
                    garantias = new List<GarantiaSeguradoContrato__c>();
                    for(GarantiaSeguradoContrato__c garantia : garantiasSeguradoContrato)
                    {
                        if(segurado.Id == garantia.SeguradoContrato__c)
                            garantias.add(garantia);
                    }
                    mapGarantiaSeguradoContrato.put(segurado.Id, garantias);                  
                }
            }
            
            mapGarantiaContratanteContrato.put(contratante.Id, garantiasContratanteTemp);
            mapGruposContrato.put(contratante.Id, gruposTemp);
        }
    }
    
    private String gerarNumeroProposta(){
        
        ContratoTO.SolicitarTituloTO solicitarTituloTO = new ContratoTO.SolicitarTituloTO();
        solicitarTituloTO.quantidade = 1;
        solicitarTituloTO.origemproposta = 18;
        
        // gera um numero de proposta
        HerokuResponseTO.TituloTO retorno = HerokuService.getInstance().gerarNumeroProposta(solicitarTituloTO);
        
        return String.valueOf(retorno.data.numeros[0]);
    }
    
    
    //PLV2365: INICIO
    public ServiceTO.OrcamentoTO gravarOrcamentoEmissao(EmissaoTO.OfertasTO payloadTO)
    {
        Opportunity orcamentoCriado;
        system.debug('payloadTO teste'+payloadTO);
        orcamentoCriado = gravarDadosOrcamento(payloadTO);
        
        ServiceTO.OrcamentoTO orcamento = new ServiceTO.OrcamentoTO();
        
        orcamento.numeroPortal      = orcamentoCriado.NumeroPortal__c;
        orcamento.numeroOrcamento   = orcamentoCriado.Numero__c;
        //orcamento.numeroOrcamento   = orcamentoCriado.Name;
        //PLV2365: INICIO
        orcamento.ordemPortal       = payloadTO.orcamento.ordemPortal;
        //PLV2365: FIM
        //PLV 3079 INICIO
        orcamento.varConsultivo       = orcamentoCriado.Consultivo__c;
        //PLV 3079 INICIO
        return orcamento;
    }
    
    public EmissaoTO.PayloadTO gravarOrcamentoCIV(EmissaoTO.OfertasTO payloadTO)
    {
        EmissaoTO.PayloadTO payloadRetorno = new EmissaoTO.PayloadTO();
        Opportunity orcamentoCriado;

        //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B
        if('eds'.equalsIgnoreCase(payloadTO.orcamento.tipoSeguro)){
            system.debug('Entrou no orcamento eds');
            orcamentoCriado = gravarDadosOrcamentoEndosso(payloadTO);
        }else{
            orcamentoCriado = gravarDadosOrcamento(payloadTO);

        }
        //PLV - 4626 - VI - FIM - GUSTAVO PEREIRA SYS4B
        payloadRetorno = gerarPaylodRetorno(orcamentoCriado.id);
        return payloadRetorno;
    }
    //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B
    @TestVisible
    private Opportunity gravarDadosOrcamentoEndosso(EmissaoTO.OfertasTO payloadTO){	

        system.debug('Entrou no gravarDadosOrcamentoEndosso');
        system.debug('jsonEntrada: '+JSON.Serialize(payloadTO, true));
        system.debug('jsonEntrada2: '+ JSON.Serialize(payloadTO));
        system.debug('jsonEntrada3: '+ payloadTO);
        
        //PLV - 4655 INICIO
       	String numeroApolice ;
        numeroApolice = payloadTO.orcamento.contratoOriginal.empresa +'-'+
        payloadTO.orcamento.contratoOriginal.sucursal +'-'+  
        payloadTO.orcamento.contratoOriginal.ramo +'-'+
        payloadTO.orcamento.contratoOriginal.apolice +'-'+
        payloadTO.orcamento.contratoOriginal.endosso;
        system.debug('numeroApolice: >< '+ numeroApolice);
        Contract contaContrato = [SELECT Id, VigenciaFinal__c, VigenciaFinalALterada__c, AccountId FROM Contract WHERE NAME =: numeroApolice]; //PLV-4684 INICIO/FIM
        Account idConta = [SELECT Id,PersonBirthdate, Sexo__c, Fumante__c,
            Profissao__c, Profissao__r.Codigo__c, Renda__c, RegimeTrabalho__c  FROM Account WHERE Id =: contaContrato.AccountId];
        system.debug('Conta: '+idConta);
	    //PLV - 4655 FIM
	    
        mapCoberturas = new Map<String, EmissaoTO.CoberturaTO>(); 
        
        Map<String,EmissaoTO.ItensCotacaoTO> mapCotacao = new Map<String,EmissaoTO.ItensCotacaoTO>();
        
        if(payloadTO.retornoIntegracoes.IndiceMonetario != null){
            for(EmissaoTO.ItensCotacaoTO itenCotacao : payloadTO.retornoIntegracoes.IndiceMonetario.ItensCotacao){
                mapCotacao.put(itenCotacao.moedaOrigem,itenCotacao);
            }
        }
        
        Map<String, ContratanteOrcamento__c>   mapOrcamentoContratante = new Map<String, ContratanteOrcamento__c>();
        Map<String, GrupoOrcamento__c>         mapOrcamentoGrupo = new Map<String, GrupoOrcamento__c>();
        Map<String, SeguradoOrcamento__c>      mapOrcamentoSegurado = new Map<String, SeguradoOrcamento__c>();
        
        Map<String, Account>                   mapSeguradoOrcamentoConta = new Map<String, Account>();
        Map<String, List<Endereco__c>>         mapSeguradoOrcamentoContaEndereco = new Map<String, List<Endereco__c>>();
        
        Map<String, List<GarantiaSeguradoOrcamento__c>> mapOrcamentoSeguradoCobertura = new Map<String, List<GarantiaSeguradoOrcamento__c>>();
        Map<String, List<GarantiaSeguradoOrcamento__c>> mapOrcamentoSeguradoCoberturaPrecificacao = new Map<String, List<GarantiaSeguradoOrcamento__c>>();
        Map<String, List<GarantiaGrupoOrcamento__c>> mapOrcamentoGrupoCobertura = new Map<String, List<GarantiaGrupoOrcamento__c>>();
        Map<String, List<GarantiaContratanteOrcamento__c>> mapOrcamentoContratanteCobertura = new Map<String, List<GarantiaContratanteOrcamento__c>>();
        
        Set<String> setSiglasCoberturas = new Set<String>();
        
        List<RemuneracaoOrcamento__c> lstRemuneracao = new List<RemuneracaoOrcamento__c>();
        
        // PLV-5331 INÍCIO
        ProductDAO produtoDao = ProductDAO.getInstance();
        Product2 prodPrec = produtoDao.buscProdPrecDtCalc(payLoadTO.orcamento.codigoProdutoVida, payLoadTO.orcamento.idProdutoSf);
        // PLV-5331 FIM
        
        mGarantiaProd = new Map<String, GarantiaProduto__c>(); 
        ProductBO produtoBo = ProductBO.getInstance();
        Product2 produto = produtoBO.buscarProdutoPorDataCalculo(prodPrec.ProductCode, Date.valueOf(payLoadTO.orcamento.dataCalculo)); // PLV-5331 - INICIO/FIM
        system.debug('PRODUTO 1509 '+ produto);
        // Product2 produto = produtoBO.buscarProdutoPorDataCalculo(payLoadTO.orcamento.codigoProdutoVida, Date.valueOf(payLoadTO.orcamento.dataCalculo)); // PLV-5331 - INICIO/FIM
        for(GarantiaProduto__c gProduto: produto.GarantiasProduto__r){
            mGarantiaProd.put(gProduto.Garantia__r.Sigla__c, gProduto); 
        }

        system.debug('produto: '+produto);
        
        Map<String, TipoRemuneracao__c> mapTiposRemuneracoes = new Map<String, TipoRemuneracao__c>();
        List<TipoRemuneracao__c> listTiposRemuneracoes = TipoRemuneracaoDAO.getInstance().buscarTipoRemuneracao();
        for (TipoRemuneracao__c tipoRemuneracao : listTiposRemuneracoes) 
            mapTiposRemuneracoes.put(tipoRemuneracao.Name.toUpperCase(), tipoRemuneracao);

        system.debug('mapTiposRemuneracoes: '+mapTiposRemuneracoes);
            
        
        for(Garantia__c garantia: GarantiaDAO.getInstance().buscarGarantias())
        {
            mapGarantias.put(garantia.Sigla__c, garantia.Id);
        }

        system.debug('mapGarantias: '+mapGarantias);

        String strContratante;
        String strGrupo;
        String strSegurado;
        
        Opportunity orcamentoCriado;
        
        
        //---  Gravar Orçamento
        
        try
        {
            
            //---- leitura dos contratantes
            for (EmissaoTO.ContratanteTO contratante : payLoadTO.orcamento.contratantes) //PLV - 4655 FIX 2 INICIO/FIM
            {
                strContratante = contratante.numero.substring(0,1);
                mapSeguradoOrcamentoConta.put(strContratante.substring(0,1), idConta); //PLV - 4655 INICIO/FIM
                
                ContratanteOrcamento__c contratanteOrc = new ContratanteOrcamento__c();
                
                montarContratante(contratante, contratanteOrc);
                
                mapOrcamentoContratante.put(strcontratante, contratanteOrc);                
                //------ leitura dos grupos 
                for (EmissaoTO.GrupoTO grupo : contratante.grupos)
                {
                    if(grupo.qtdeVidas > 0){                
                        strGrupo = strContratante + '_' + grupo.numero.substring(0,1);
                        
                        GrupoOrcamento__c GrupoOrc = new GrupoOrcamento__c();

                        system.debug('strGrupo: '+strGrupo);
                        
                        montarGrupo(grupo, GrupoOrc);
                        
                        mapOrcamentoGrupo.put(strGrupo, GrupoOrc);

                        system.debug('mapOrcamentoGrupo: '+mapOrcamentoGrupo);
                        
                        System.debug('GRUPO ATUAL => ' + grupo);
                        
                        if(grupo.segurados != null){
                            //----- leitura dos Segurados

                            for (EmissaoTO.SeguradoTO segurado : grupo.segurados){
                                strSegurado = strGrupo + '_' + segurado.numero.substring(0,1); 
                                
                                SeguradoOrcamento__c SeguradoOrc = new SeguradoOrcamento__c();
                                //Account conta = new Account();
                                List<Endereco__c> endereco = new List<Endereco__c>();
                                
                                //-- montar segurado
                                montarSegurado(segurado, SeguradoOrc);
                                
                                mapOrcamentoSegurado.put(strSegurado, SeguradoOrc);
                                                                
                                //----- leitura das coberturas
                                List<GarantiaSeguradoOrcamento__c> lstCobertura = new List<GarantiaSeguradoOrcamento__c>();
                                //PLV - 4655 INICIO
                                for (EmissaoTO.CoberturaTO cobertura : contratante.grupos[0].segurados[0].coberturas) //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B - FIX 1	
                                {
                                //PLV - 4655 FIM
                                    system.debug('cobertura: '+cobertura);
                                    GarantiaSeguradoOrcamento__c coberturaOrc = new GarantiaSeguradoOrcamento__c();
                                    setSiglasCoberturas.add(cobertura.sigla);
                                    mapCoberturas.put(cobertura.sigla, cobertura);
                                    system.debug('mapCoberturas: '+mapCoberturas);
                                    montarCobertura(cobertura, coberturaOrc, setSiglasCoberturas);
                                    system.debug('Gilberto Gravar dados: ');
                                    if(coberturaOrc.Garantia__c != null)
                                        lstCobertura.add(coberturaOrc);
                                        system.debug('Gilberto coberturaOrc: ');
                                }
                                
                                mapOrcamentoSeguradoCobertura.put(strSegurado, lstCobertura);
                                system.debug('teste mapOrcamentoSeguradoCobertura:'+mapOrcamentoSeguradoCobertura);
                            }
                        }else if(grupo.coberturas != null){
                            system.debug('TESTE PASSOU AQUI!');
                            List<GarantiaGrupoOrcamento__c> lstCobertura = new List<GarantiaGrupoOrcamento__c>();
                            for(EmissaoTO.CoberturaTO cobertura : grupo.coberturas){
                                GarantiaGrupoOrcamento__c coberturaOrc = new GarantiaGrupoOrcamento__c();
                                setSiglasCoberturas.add(cobertura.sigla);
                                mapCoberturas.put(cobertura.sigla, cobertura);
                                
                                montarCobertura(cobertura, coberturaOrc, setSiglasCoberturas);
                                if(coberturaOrc.Garantia__c != null){
                                    lstCobertura.add(coberturaOrc);
                                }
                            }
                            
                            system.debug('mapCoberturas: ' + JSON.serialize(mapCoberturas));
                        }
                    }
                }
            }
            
            
            //----- leitura das remunerações
            
            for (EmissaoTO.RemuneracaoTO remuneracao : payLoadTO.orcamento.remuneracoes)
            {                
                RemuneracaoOrcamento__c RemuneracaoOrc = new RemuneracaoOrcamento__c();
                
                montarRemuneracao(remuneracao, RemuneracaoOrc, mapTiposRemuneracoes);
                if(remuneracao.tipoRemuneracao.toUpperCase() == 'AGENCIAMENTO') remuneracaoOrc.Percentual__c = 0; //PLV-5101 - INICIO/FIM
                
                lstRemuneracao.add(RemuneracaoOrc);  
                System.debug('LISTA REMUNERAÇÕES: '+ lstRemuneracao);      
            }
            
            //--- Leitura da Precificação
            //INICIO - PLV-VI-4865 - Guilherme Brito
            if(payloadTO.retornosCalculo != null && !payloadTO.retornosCalculo.isEmpty()){
                EmissaoTO.RetornoCalculoTO retornoCalculo = new EmissaoTO.RetornoCalculoTO();
                if(payloadTO.retornosCalculo.size() > 1) {
                    retornoCalculo = payloadTO.retornosCalculo.get(payloadTO.retornosCalculo.size()-1);
                } else {
                    retornoCalculo = payloadTO.retornosCalculo[0];
                }
                
                if(retornoCalculo.precificacao != null) {
                    for (EmissaoTO.ContratanteTO contratante : retornoCalculo.precificacao.contratantes) {
                        system.debug('contratante: '+contratante);
                        system.debug('mapOrcamentoContratante: '+mapOrcamentoContratante);
                        system.debug('mapOrcamentoContratanteCobertura: '+mapOrcamentoContratanteCobertura);
                        system.debug('setSiglasCoberturas: '+setSiglasCoberturas);
                        montaContratantePrecificacao(contratante, mapOrcamentoContratante, mapOrcamentoContratanteCobertura, setSiglasCoberturas, payloadTO);//PLV-5676-INICIO/FIM
                        
                        for (EmissaoTO.GrupoTO grupo : contratante.grupos) {
                            montaGrupoPrecificacao(contratante.numero, grupo, mapOrcamentoGrupo, mapOrcamentoGrupoCobertura, setSiglasCoberturas, payloadTO);//PLV-5676-INICIO/FIM
                            system.debug('contratante.numero: '+contratante.numero);
                            system.debug('grupo: '+grupo);
                            system.debug('mapOrcamentoGrupo: '+mapOrcamentoGrupo);
                            system.debug('mapOrcamentoGrupoCobertura: '+mapOrcamentoGrupoCobertura);
                            system.debug('setSiglasCoberturas: '+setSiglasCoberturas);
                            if(grupo.segurados != null) {
                                for (EmissaoTO.SeguradoTO segurado : grupo.segurados) {
                                    montaSeguradoPrecificacao(contratante.numero, grupo.numero, segurado, mapOrcamentoSegurado, mapOrcamentoSeguradoCoberturaPrecificacao, setSiglasCoberturas, payloadTO);//PLV-5676-INICIO/FIM
                                    system.debug('contratante.numero: '+contratante.numero);
                                    system.debug('grupo.numero: '+grupo.numero);
                                    system.debug('segurado: '+segurado);
                                    system.debug('mapOrcamentoSegurado: '+mapOrcamentoSegurado);
                                    system.debug('mapOrcamentoSeguradoCoberturaPrecificacao: '+mapOrcamentoSeguradoCoberturaPrecificacao);
                                    system.debug('setSiglasCoberturas: '+setSiglasCoberturas);
                                }
                            }
                        }
                    }
                }
            }
            //FIM - PLV-VI-4865 - Guilherme Brito
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Montagem maps \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        //---- Executa gravação
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            String chaveContaPadraoSegurado;
            
            //---> Grava Orçamento
            orcamentoCriado = gravarObjOrcamento(payloadTO, contaContrato, mapSeguradoOrcamentoConta, chaveContaPadraoSegurado, setSiglasCoberturas); //PLV-4684 INICIO/FIM
            
            System.debug('Orcamento: ' + orcamentoCriado.Id);
            
            //---> Grava Contratante
            List<ContratanteOrcamento__c> listContratante = new List<ContratanteOrcamento__c>();
            
            
            String chaveSelecionada;
            
            for (String key : mapOrcamentoContratante.keySet())
            {
                ContratanteOrcamento__c contratante = new ContratanteOrcamento__c();
                contratante = mapOrcamentoContratante.get(key);
                contratante.Orcamento__c = orcamentoCriado.Id;
                //PLV-4813 INICIO
                if('viagem'.equalsIgnoreCase(payloadTO.orcamento.segmento) && 'eds'.equalsIgnoreCase(payLoadTO.orcamento.tipoSeguro)) {
                    Account conta = new Account(IdExterno__c = PropostaGenericaBuilder.getInstance().montarChavePessoa(payloadTO.orcamento.contratoOriginal.contratantes[0].pessoa));
                    contratante.Conta__r = conta;
                }
                else {
                    contratante.Conta__c = idConta.Id; //PLV - 4655 INICIO/FIM
                }
                //PLV-4813 FIM                
                listContratante.add(contratante);
            }
            
            system.debug(' listContratante:'  + listContratante);
            Insert listContratante;
            
            //---> Grava Grupo
            List<GrupoOrcamento__c> lstGrupoGrava = new List<GrupoOrcamento__c>();
            
            for (String key : mapOrcamentoGrupo.keySet())
            {
                GrupoOrcamento__c grupoOrcamento = new GrupoOrcamento__c();
                
                grupoOrcamento = mapOrcamentoGrupo.get(key);
                
                grupoOrcamento.ContratanteOrcamento__c = mapOrcamentoContratante.get(PegaParteChave(key,1)).Id;   
                
                lstGrupoGrava.add(grupoOrcamento);
            }
            
            system.debug(' lstGrupoGrava: ' + lstGrupoGrava);
            Insert lstGrupoGrava;
            
            
            //---> Gravar Segurados
            List<SeguradoOrcamento__c> lstSeguradoGrava = new List<SeguradoOrcamento__c>();
            
            String keyGrupo;
            Id idGrupo;
            
            for (String key : mapOrcamentoSegurado.keySet())
            {
                SeguradoOrcamento__c seguradoGrava = new SeguradoOrcamento__c();
                GrupoOrcamento__c grupoOrcamento = new GrupoOrcamento__c();
                
                seguradoGrava = mapOrcamentoSegurado.get(key);
                
                //--- busca id do grupo
                keyGrupo = PegaParteChave(key,1) + '_' + PegaParteChave(key,2);
                
                if(mapOrcamentoGrupo.containsKey(keyGrupo))
                {
                    grupoOrcamento = mapOrcamentoGrupo.get(keyGrupo);
                    
                    seguradoGrava.GrupoOrcamento__c = grupoOrcamento.Id;
                    seguradoGrava.Conta__c          = idConta.Id;//PLV - 4655 INICIO/FIM                    
                    
                    lstSeguradoGrava.add(seguradoGrava);
                }
            }
            
            System.debug(' lstSeguradoGrava: ' + lstSeguradoGrava);
            Insert lstSeguradoGrava;
            //PLV - 4655 INICIO
            //PLV - 4655 fix INICIO
            // TKCL-584-FIX01 INICIO
            Boolean payloadNovaIntegradora = payloadTO.orcamento.contratoOriginal.contratantes == null;
            EmissaoTO.DadosPessoaFisicaTO dadosPessoa = payloadNovaIntegradora == true ?
                 payLoadTO.orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica :
                 payLoadTO.orcamento.contratoOriginal.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica;
            IdConta.PersonBirthdate = Date.ValueOf(dadosPessoa.dataNascimento);
            IdConta.Sexo__c = dadosPessoa.sexo;
            IdConta.Fumante__c = dadosPessoa.fumante == true ? 'Sim':'Não';
            if(String.isNotBlank(dadosPessoa.profissao)){
                Profissao__c prof = [SELECT Id FROM Profissao__c WHERE Codigo__c =: dadosPessoa.profissao Limit 1];
                IdConta.Profissao__c=prof.Id;
            }
            idConta.RegimeTrabalho__c = dadosPessoa.regimeTrabalho == null ? '' : dadosPessoa.regimeTrabalho;
            System.debug('Conta após endosso...'+IdConta);
            // TKCL-584-FIX01 FIM
            update idConta;
            //PLV - 4655 fix FIM
			//PLV - 4655 FIM
             //            -------
            
            //----> gravar remunerações
            for (RemuneracaoOrcamento__c remuneracao : lstRemuneracao)
            {
                remuneracao.Oportunidade__c = orcamentoCriado.Id;
            }
            
            system.debug(' lstRemuneracao: ' + lstRemuneracao);
            insert lstRemuneracao;
            
            
            //-----> gravar garantia/precificação
            
            List<GarantiaContratanteOrcamento__c> garantiaContratanteList = new  List<GarantiaContratanteOrcamento__c>();
            Set<Id> idGarantiaProduto = new Set<Id>();
            for (String key : mapOrcamentoContratanteCobertura.keySet())
            {
                for(GarantiaContratanteOrcamento__c garantia : mapOrcamentoContratanteCobertura.get(key))
                {
                    garantia.ContratanteOrcamento__c = mapOrcamentoContratante.get(key).Id;
                    idGarantiaProduto.add(garantia.GarantiaProduto__c);
                    garantiaContratanteList.add(garantia);
                }
            }
            
            system.debug(' garantiaContratanteList: ' + garantiaContratanteList);
            
            system.debug('idGarantiaProduto'+idGarantiaProduto);
            Map<Id,GarantiaProduto__c> mpGarantiaProdutoCotacao = new Map<Id,GarantiaProduto__c>();
            
            if(idGarantiaProduto.size() > 0){
                List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                
                for(GarantiaProduto__c g : garantiasP){
                    mpGarantiaProdutoCotacao.put(g.Id,g);
                }
                
            }
            
            for(GarantiaContratanteOrcamento__c garantia : garantiaContratanteList){
                if(mpGarantiaProdutoCotacao.containsKey(garantia.GarantiaProduto__c)){
                    if(mapCotacao.containsKey(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode)){
                        garantia.ValorCotacao__c = mapCotacao.get(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode).cotacao;
                    }
                } 
                
            }
            
            
            insert garantiaContratanteList;
            
            List<GarantiaGrupoOrcamento__c> garantiaGrupoList = new  List<GarantiaGrupoOrcamento__c>();
            idGarantiaProduto.clear();
            for (String key : mapOrcamentoGrupoCobertura.keySet())
            {
                
                for(GarantiaGrupoOrcamento__c garantia : mapOrcamentoGrupoCobertura.get(key))
                {
                    garantia.GrupoOrcamento__c = mapOrcamentoGrupo.get(key).Id;
                    idGarantiaProduto.add(garantia.GarantiaProduto__c);
                    garantiaGrupoList.add(garantia);
                }
            }
            
            if(idGarantiaProduto.size() > 0){
                mpGarantiaProdutoCotacao.clear();
                List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                
                for(GarantiaProduto__c g : garantiasP){
                    mpGarantiaProdutoCotacao.put(g.Id,g);
                }
                
            }
            for(GarantiaGrupoOrcamento__c garantia : garantiaGrupoList){
                if(mpGarantiaProdutoCotacao.containsKey(garantia.GarantiaProduto__c)){
                    if(mapCotacao.containsKey(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode)){
                        garantia.ValorCotacao__c = mapCotacao.get(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode).cotacao;
                    }
                } 
            }
            
            system.debug(' garantiaGrupoList: ' + garantiaGrupoList);
            insert garantiaGrupoList;
            
            List<GarantiaSeguradoOrcamento__c> garantiaSeguradoList = new  List<GarantiaSeguradoOrcamento__c>();
            idGarantiaProduto.clear();
            for (String key : mapOrcamentoSeguradoCoberturaPrecificacao.keySet())
            {
                
                for(GarantiaSeguradoOrcamento__c garantia : mapOrcamentoSeguradoCoberturaPrecificacao.get(key))
                {
                    garantia.SeguradoOrcamento__c = mapOrcamentoSegurado.get(key).Id;
                    idGarantiaProduto.add(garantia.GarantiaProduto__c);
                    garantiaSeguradoList.add(garantia);
                }
            }
            if(idGarantiaProduto.size() > 0){
                mpGarantiaProdutoCotacao.clear();
                List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                
                for(GarantiaProduto__c g : garantiasP){
                    mpGarantiaProdutoCotacao.put(g.Id,g);
                }
                
            }
            for(GarantiaSeguradoOrcamento__c garantia : garantiaSeguradoList){
                if(mpGarantiaProdutoCotacao.containsKey(garantia.GarantiaProduto__c)){
                    if(mapCotacao.containsKey(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode)){
                        garantia.ValorCotacao__c = mapCotacao.get(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode).cotacao;
                    }
                } 
            }
            system.debug(' garantiaSeguradoList: ' + garantiaSeguradoList);
            insert garantiaSeguradoList;
            
            
        }catch (Exception e){
            Database.rollback(sp);
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            
            throw new OrcamentoBuilderException('Exception: Inserir orcamento detalhes\r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - StackTrace: ' + e.getStackTraceString() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        //---------------------*/
        
       return orcamentoCriado;
    }
    //PLV - 4626 - VI - FIM - GUSTAVO PEREIRA SYS4B
    
    // PLV-2327 - INICIO
    //PLV2365: INICIO
    private Opportunity gravarDadosOrcamento(EmissaoTO.OfertasTO payloadTO)
    {
        system.debug('@jvbdsOrça '+ JSON.serialize(payloadTO));
        //PLV-2146 - Código removido (Map Inutilizado)
        
        mapCoberturas = new Map<String, EmissaoTO.CoberturaTO>(); //PLV-3317 - INICIO/FIM - Instanciação do Map para criar os registros de garantias da forma correta
        
        //PLV-3731 - INICIO
        Map<String,EmissaoTO.ItensCotacaoTO> mapCotacao = new Map<String,EmissaoTO.ItensCotacaoTO>();
        //Set<Id> idGarantiaProduto = new Set<Id>();
        //Map<Id,GarantiaProduto__c> mpGarantiaProdutoCotacao = new Map<Id,GarantiaProduto__c>();
        if(payloadTO.retornoIntegracoes.IndiceMonetario != null){
            for(EmissaoTO.ItensCotacaoTO itenCotacao : payloadTO.retornoIntegracoes.IndiceMonetario.ItensCotacao){
                mapCotacao.put(itenCotacao.moedaOrigem,itenCotacao);
            }
        }
        //PLV-3731 - FIM
        
        Map<String, ContratanteOrcamento__c>   mapOrcamentoContratante = new Map<String, ContratanteOrcamento__c>();
        Map<String, GrupoOrcamento__c>         mapOrcamentoGrupo = new Map<String, GrupoOrcamento__c>();
        Map<String, SeguradoOrcamento__c>      mapOrcamentoSegurado = new Map<String, SeguradoOrcamento__c>();
        
        Map<String, Account>                   mapSeguradoOrcamentoConta = new Map<String, Account>();
        Map<String, List<Endereco__c>>         mapSeguradoOrcamentoContaEndereco = new Map<String, List<Endereco__c>>();
        
        Map<String, List<GarantiaSeguradoOrcamento__c>> mapOrcamentoSeguradoCobertura = new Map<String, List<GarantiaSeguradoOrcamento__c>>();
        Map<String, List<GarantiaSeguradoOrcamento__c>> mapOrcamentoSeguradoCoberturaPrecificacao = new Map<String, List<GarantiaSeguradoOrcamento__c>>();
        Map<String, List<GarantiaGrupoOrcamento__c>> mapOrcamentoGrupoCobertura = new Map<String, List<GarantiaGrupoOrcamento__c>>();
        Map<String, List<GarantiaContratanteOrcamento__c>> mapOrcamentoContratanteCobertura = new Map<String, List<GarantiaContratanteOrcamento__c>>();
        
        //PLV-2607 - Inicio
        Set<String> setSiglasCoberturas = new Set<String>();
        //PLV-2607 - Fim
        
        List<RemuneracaoOrcamento__c> lstRemuneracao = new List<RemuneracaoOrcamento__c>();

        // PLV-5331 INÍCIO
        ProductDAO produtoDao = ProductDAO.getInstance();
        Product2 prodPrec = produtoDao.buscProdPrecDtCalc(payLoadTO.orcamento.codigoProdutoVida, payLoadTO.orcamento.idProdutoSf);
        // PLV-5331 FIM
        
        //PLV-3285 - INICIO - Ajuste logica
        mGarantiaProd = new Map<String, GarantiaProduto__c>(); //PLV-3884 - INICIO/FIM - Mapa de objeto de garantia do produto para seleção de moeda
        ProductBO produtoBo = ProductBO.getInstance();
        Product2 produto = produtoBO.buscarProdutoPorDataCalculo(prodPrec.ProductCode, Date.valueOf(payLoadTO.orcamento.dataCalculo));
        system.debug('PRODUTO 1962 '+ produto);
        for(GarantiaProduto__c gProduto: produto.GarantiasProduto__r){
            mGarantiaProd.put(gProduto.Garantia__r.Sigla__c, gProduto); //PLV-3884 - INICIO/FIM - Mapa de objeto de garantia do produto para seleção de moeda
        }
        //PLV-3285 - FIM
        
        Map<String, TipoRemuneracao__c> mapTiposRemuneracoes = new Map<String, TipoRemuneracao__c>();
        List<TipoRemuneracao__c> listTiposRemuneracoes = TipoRemuneracaoDAO.getInstance().buscarTipoRemuneracao();
        for (TipoRemuneracao__c tipoRemuneracao : listTiposRemuneracoes) 
            mapTiposRemuneracoes.put(tipoRemuneracao.Name.toUpperCase(), tipoRemuneracao);
        
        for(Garantia__c garantia: GarantiaDAO.getInstance().buscarGarantias())
        {
            mapGarantias.put(garantia.Sigla__c, garantia.Id);
        }
        
        String strContratante;
        String strGrupo;
        String strSegurado;
        
        Opportunity orcamentoCriado;
        
        
        //---  Gravar Orçamento
        
        try
        {
            
            //---- leitura dos contratantes
            for (EmissaoTO.ContratanteTO contratante : payLoadTO.orcamento.contratantes)
            {
                System.debug('Gior Contratante.......'+contratante);
                strContratante = contratante.numero;
                
                ContratanteOrcamento__c contratanteOrc = new ContratanteOrcamento__c();
                
                montarContratante(contratante, contratanteOrc);
                
                mapOrcamentoContratante.put(strcontratante, contratanteOrc);
                System.debug('Test ISA');
                //PLV2365: INICIO
                //--- conta do contratante
                if(contratante.pessoa != null)
                {
                    System.debug('Test ISA 2');
                    
                    //PLV_2826 - INICIO - Criar oportunidade sem conta
                    //A conta será criada apenas se o CPF estiver preenchido
                    if(String.isNotEmpty(contratante.pessoa.dadosPessoaFisica.numeroCpf)){
                        Account contaContratante = new Account();
                        List<Endereco__c> enderecoContratante = new List<Endereco__c>();
                        
                        //-- monta conta/endereço
                        contaContratante = montarSeguradoPessoa(contratante.pessoa);
                        enderecoContratante = montarSeguradoPessoaEndereco(contratante.pessoa);
                        
                        //-- montar conta/endereco 
                        mapSeguradoOrcamentoConta.put(strContratante, contaContratante);
                        //PLV- 2727 - Inicio
                        if(enderecoContratante != null){
                            mapSeguradoOrcamentoContaEndereco.put(strContratante, enderecoContratante);
                        }
                        //PLV- 2727 - Fim
                    }
                    //PLV_2826 - INICIO - Criar oportunidade sem conta
                }    
                //PLV2365: FIM
                
                
                //------ leitura dos grupos 
                for (EmissaoTO.GrupoTO grupo : contratante.grupos)
                {
                    //PLV-3141 - INICIO - Ajuste para criar apenas o grupo com alguma vida
                    if(grupo.qtdeVidas > 0){                
                        strGrupo = strContratante + '_' + grupo.numero;
                        
                        GrupoOrcamento__c GrupoOrc = new GrupoOrcamento__c();
                        
                        montarGrupo(grupo, GrupoOrc);
                        
                        mapOrcamentoGrupo.put(strGrupo, GrupoOrc);
                        
                        System.debug('GRUPO ATUAL => ' + grupo);
                        
                        // PLV-3138 - ORCAMENTO SEM SEGURADO - INICIO
                        if(grupo.segurados != null){
                            // PLV-3138 - ORCAMENTO SEM SEGURADO - FIM
                            //----- leitura dos Segurados
                            for (EmissaoTO.SeguradoTO segurado : grupo.segurados){
                                strSegurado = strGrupo + '_' + segurado.numero; 
                                
                                SeguradoOrcamento__c SeguradoOrc = new SeguradoOrcamento__c();
                                Account conta = new Account();
                                List<Endereco__c> endereco = new List<Endereco__c>();
                                
                                //-- montar segurado
                                montarSegurado(segurado, SeguradoOrc);
                                
                                mapOrcamentoSegurado.put(strSegurado, SeguradoOrc);
                                
                                //PLV2365: INICIO
                                //PLV_2826 - INICIO - Criar oportunidade sem conta
                                //-- monta conta/endereço
                                if(String.isNotEmpty(segurado.pessoa.dadosPessoaFisica.numeroCpf)){
                                    conta = montarSeguradoPessoa(segurado.pessoa);
                                    endereco = montarSeguradoPessoaEndereco(segurado.pessoa);
                                    //PLV2365: FIM
                                    
                                    //-- montar conta/endereco 
                                    mapSeguradoOrcamentoConta.put(strSegurado, conta);
                                    //PLV- 2727 - Inicio
                                    if (endereco != null) {
                                        mapSeguradoOrcamentoContaEndereco.put(strSegurado, endereco);
                                    }
                                }
                                //PLV- 2727 - Fim
                                //PLV_2826 - FIM - Criar oportunidade sem conta
                                
                                //----- leitura das coberturas
                                List<GarantiaSeguradoOrcamento__c> lstCobertura = new List<GarantiaSeguradoOrcamento__c>();
                                
                                for (EmissaoTO.CoberturaTO cobertura : segurado.coberturas)
                                {
                                    GarantiaSeguradoOrcamento__c coberturaOrc = new GarantiaSeguradoOrcamento__c();
                                    setSiglasCoberturas.add(cobertura.sigla);
                                    //PLV-3317 - INICIO - Popular a lista com as coberturas
                                    mapCoberturas.put(cobertura.sigla, cobertura);
                                    //PLV-3317 - FIM
                                    //PLV-2607 - Inicio
                                    montarCobertura(cobertura, coberturaOrc, setSiglasCoberturas);
                                    if(coberturaOrc.Garantia__c != null)
                                        //PLV-2607 - Fim
                                        lstCobertura.add(coberturaOrc);
                                }
                                system.debug('teste cob3'+mapCoberturas);
                                mapOrcamentoSeguradoCobertura.put(strSegurado, lstCobertura);
                            }
                            // PLV-3138 - ORCAMENTO SEM SEGURADO - INICIO
                        }else if(grupo.coberturas != null){
                            system.debug('TESTE PASSOU AQUI!');
                            List<GarantiaGrupoOrcamento__c> lstCobertura = new List<GarantiaGrupoOrcamento__c>();
                            for(EmissaoTO.CoberturaTO cobertura : grupo.coberturas){
                                GarantiaGrupoOrcamento__c coberturaOrc = new GarantiaGrupoOrcamento__c();
                                setSiglasCoberturas.add(cobertura.sigla);
                                //PLV-3317 - INICIO - Popular a lista com as coberturas
                                mapCoberturas.put(cobertura.sigla, cobertura);
                                //PLV-3317 - FIM
                                
                                montarCobertura(cobertura, coberturaOrc, setSiglasCoberturas);
                                if(coberturaOrc.Garantia__c != null){
                                    lstCobertura.add(coberturaOrc);
                                }
                            }
                            
                            system.debug('mapCoberturas: ' + JSON.serialize(mapCoberturas));
                        }
                        // PLV-3138 - ORCAMENTO SEM SEGURADO - FIM
                    }
                    //PLV-3141 - FIM
                }
            }
            
            
            //----- leitura das remunerações
            
            for (EmissaoTO.RemuneracaoTO remuneracao : payLoadTO.orcamento.remuneracoes)
            {                
                RemuneracaoOrcamento__c RemuneracaoOrc = new RemuneracaoOrcamento__c();
                
                montarRemuneracao(remuneracao, RemuneracaoOrc, mapTiposRemuneracoes);
                
                lstRemuneracao.add(RemuneracaoOrc);  
                System.debug('LISTA REMUNERAÇÕES: '+ lstRemuneracao);      
            }
            
            //--- Leitura da Precificação
            //PLV-3136 - INÍCIO
            //PLV-2146 - INÍCIO
            if(payloadTO.retornosCalculo != null && !payloadTO.retornosCalculo.isEmpty()){

                //INÍCIO - PLV-VI-4865 - Guilherme Brito
                EmissaoTO.RetornoCalculoTO retornoCalculo = new EmissaoTO.RetornoCalculoTO();
                if(payloadTO.retornosCalculo.size() > 1) {
                    retornoCalculo = payloadTO.retornosCalculo.get(payloadTO.retornosCalculo.size()-1);
                } else {
                    retornoCalculo = payloadTO.retornosCalculo[0];
                }                
                if(retornoCalculo.precificacao != null) {
                    for (EmissaoTO.ContratanteTO contratante : retornoCalculo.precificacao.contratantes) {
                        //PLV-2607 - Inicio - Alteração de parametros
                        //contratante.numero = '1'; // TKCL-461 INICIO/FIM FIX 04
                        montaContratantePrecificacao(contratante, mapOrcamentoContratante, mapOrcamentoContratanteCobertura, setSiglasCoberturas, payloadTO);//PLV-5676 - INICIO/FIM                 
                        for (EmissaoTO.GrupoTO grupo : contratante.grupos) {
                            //grupo.numero = '1'; // TKCL-461 INICIO/FIM FIX 04
                            montaGrupoPrecificacao(contratante.numero, grupo, mapOrcamentoGrupo, mapOrcamentoGrupoCobertura, setSiglasCoberturas, payloadTO);//PLV-5676-INICIO/FIM
                            if(grupo.segurados != null) {
                                for (EmissaoTO.SeguradoTO segurado : grupo.segurados) {
                                    //segurado.numero = '1'; // TKCL-461 INICIO/FIM FIX 04
                                    montaSeguradoPrecificacao(contratante.numero, grupo.numero, segurado, mapOrcamentoSegurado, mapOrcamentoSeguradoCoberturaPrecificacao, setSiglasCoberturas, payloadTO);//PLV-5676-INICIO/FIM
                                }
                            }
                            //PLV2607 - Fim - Alteração de parametros
                        }
                    }
                }
                //FIM - PLV-VI-4865 - Guilherme Brito
            }
            //PLV-2146 - FIM
            //PLV-3136 - FIM
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Montagem maps \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        //---- Executa gravação
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //PLV_2826 - INICIO - Criar oportunidade sem conta
            String chaveContaPadraoSegurado;
            
            if(!mapSeguradoOrcamentoConta.isEmpty() && mapSeguradoOrcamentoConta != null){
                //PLV_2826 - FIM - Criar oportunidade sem conta
                
                //PLV2365: INICIO
                //---> Gravar Conta/endereço
                for (String key : mapSeguradoOrcamentoConta.keySet())
                {
                    Account contaNova = new Account();
                    List<Endereco__c> enderecosNovos = new List<Endereco__c>();

                    system.debug('mapSeguradoOrcamentoContaEndereco => ' + mapSeguradoOrcamentoContaEndereco);
                    
                    contaNova    = mapSeguradoOrcamentoConta.get(key);
                    //PLV-2727 - Inicio
                    if(mapSeguradoOrcamentoContaEndereco.containsKey(key)) enderecosNovos = mapSeguradoOrcamentoContaEndereco.get(key);
                    
                    system.debug('CONTA QUE VAI SER INSERIDA '+ contaNova);
                    system.debug('ENDERECOS '+ enderecosNovos);

                    contaBO.salvarContasOferta(new List<Account>{contaNova});
                    
                    if(enderecosNovos != null || !enderecosNovos.isEmpty()) {
                        for(Endereco__c endereco : enderecosNovos)
                        {
                            endereco.Conta__c = contaNova.Id;
                            endereco.IdExterno__c = endereco2BO.montarIdExterno(endereco);
                        }
                        contaBO.salvarEnderecosContas(enderecosNovos);
                    }
                    //PLV-2727 - Fim
                }
                
                //--- busca conta padrão no segurado
                chaveContaPadraoSegurado = buscarChaveContaPadrao(mapOrcamentoContratante, mapOrcamentoSegurado, mapSeguradoOrcamentoConta);
                
                //PLV_2826 - INICIO - Criar oportunidade sem conta    
            }
            //PLV_2826 - FIM - Criar oportunidade sem conta
            
            //---> Grava Orçamento
            orcamentoCriado = gravarObjOrcamento(payloadTO, null, mapSeguradoOrcamentoConta, chaveContaPadraoSegurado, setSiglasCoberturas); //PLV-4684 INICIO/FIM
            
            System.debug('Orcamento: ' + orcamentoCriado.Id);
            //PLV2365: FI 
            
            //---> Grava Contratante
            List<ContratanteOrcamento__c> listContratante = new List<ContratanteOrcamento__c>();
            
            //PLV2365: INICIO
            
            String chaveSelecionada;
            
            for (String key : mapOrcamentoContratante.keySet())
            {
                ContratanteOrcamento__c contratante = new ContratanteOrcamento__c();
                contratante = mapOrcamentoContratante.get(key);
                contratante.Orcamento__c = orcamentoCriado.Id;
                
                //PLV_2826 - INICIO - Criar oportunidade sem conta
                if(!mapSeguradoOrcamentoConta.isEmpty()){
                    //PLV_2826 - FIM - Criar oportunidade sem conta
                    if(mapSeguradoOrcamentoConta.containsKey(key))
                        chaveSelecionada = key;
                    else
                        chaveSelecionada = chaveContaPadraoSegurado;
                    
                    contratante.Conta__c = mapSeguradoOrcamentoConta.get(chaveContaPadraoSegurado).Id;
                    //PLV- 2727 - Inicio
                    if(mapSeguradoOrcamentoContaEndereco.containsKey(chaveContaPadraoSegurado)) {
                        Endereco__c endereco = mapSeguradoOrcamentoContaEndereco.get(chaveContaPadraoSegurado)[0];
                        
                        contratante.Bairro__c       = endereco.Bairro__c;
                        contratante.CEP__c          = endereco.CEP__c;
                        contratante.Cidade__c       = endereco.Cidade__c;
                        contratante.Estado__c       = endereco.Estado__c;
                        contratante.Logradouro__c   = endereco.Logradouro__c;
                        contratante.NumeroEndereco__c = endereco.Numero__c;
                        contratante.TipoEndereco__c = endereco.TipoEndereco__c;
                        contratante.TipoLogradouro__c = endereco.TipoLogradouro__c;
                    }
                    //PLV- 2727 - Fim
                    //PLV_2826 - INICIO - Criar oportunidade sem conta
                }
                //PLV_2826 - FIM - Criar oportunidade sem conta
                listContratante.add(contratante);
            }
            //PLV2365: FIM
            
            system.debug('PLV_2826 listContratante:'  + listContratante);
            Insert listContratante;
            
            //---> Grava Grupo
            List<GrupoOrcamento__c> lstGrupoGrava = new List<GrupoOrcamento__c>();
            
            for (String key : mapOrcamentoGrupo.keySet())
            {
                GrupoOrcamento__c grupoOrcamento = new GrupoOrcamento__c();
                
                grupoOrcamento = mapOrcamentoGrupo.get(key);
                
                grupoOrcamento.ContratanteOrcamento__c = mapOrcamentoContratante.get(PegaParteChave(key,1)).Id;   
                
                lstGrupoGrava.add(grupoOrcamento);
            }
            
            system.debug('PLV_2826 lstGrupoGrava: ' + lstGrupoGrava);
            Insert lstGrupoGrava;
            
            
            //---> Gravar Segurados
            List<SeguradoOrcamento__c> lstSeguradoGrava = new List<SeguradoOrcamento__c>();
            
            String keyGrupo;
            Id idGrupo;
            
            for (String key : mapOrcamentoSegurado.keySet())
            {
                SeguradoOrcamento__c seguradoGrava = new SeguradoOrcamento__c();
                GrupoOrcamento__c grupoOrcamento = new GrupoOrcamento__c();
                
                seguradoGrava = mapOrcamentoSegurado.get(key);
                
                //--- busca id do grupo
                keyGrupo = PegaParteChave(key,1) + '_' + PegaParteChave(key,2);
                
                if(mapOrcamentoGrupo.containsKey(keyGrupo))
                {
                    grupoOrcamento = mapOrcamentoGrupo.get(keyGrupo);
                    
                    seguradoGrava.GrupoOrcamento__c = grupoOrcamento.Id;
                    
                    //PLV_2826 - INICIO - Criar oportunidade sem conta
                    if(!mapSeguradoOrcamentoConta.isEmpty()){
                        seguradoGrava.Conta__c          = mapSeguradoOrcamentoConta.get(key).Id;
                    }
                    //PLV_2826 - FIM - Criar oportunidade sem conta
                    
                    
                    lstSeguradoGrava.add(seguradoGrava);
                }
            }
            
            System.debug('PLV_2826 lstSeguradoGrava: ' + lstSeguradoGrava);
            Insert lstSeguradoGrava;
            
            
            //            ---> Gravar Coberturas
            //            List<GarantiaSeguradoOrcamento__c> lstCoberturaGrava = new List<GarantiaSeguradoOrcamento__c>();
            //
            //            for (Integer key : mapOrcamentoSeguradoCobertura.keySet())
            //            {
            //                lstCoberturaGrava = mapOrcamentoSeguradoCobertura.get(key);
            //
            //                for(GarantiaSeguradoOrcamento__c cobertura : lstCoberturaGrava)
            //                {
            //                    cobertura.SeguradoOrcamento__c = mapSeguradoOrcamentocobertura.get(key).Id;   
            //                }
            //            }
            //
            //           Insert lstCoberturaGrava;
            //
            //            -------
            
            //----> gravar remunerações
            for (RemuneracaoOrcamento__c remuneracao : lstRemuneracao)
            {
                remuneracao.Oportunidade__c = orcamentoCriado.Id;
            }
            
            system.debug('PLV_2826 lstRemuneracao: ' + lstRemuneracao);
            insert lstRemuneracao; 
            
            
            //-----> gravar garantia/precificação
            
            List<GarantiaContratanteOrcamento__c> garantiaContratanteList = new  List<GarantiaContratanteOrcamento__c>();
            //PLV-3731 - INICIO
            Set<Id> idGarantiaProduto = new Set<Id>();
            //PLV-3731 - FIM                      
            for (String key : mapOrcamentoContratanteCobertura.keySet())
            {
                for(GarantiaContratanteOrcamento__c garantia : mapOrcamentoContratanteCobertura.get(key))
                {
                    garantia.ContratanteOrcamento__c = mapOrcamentoContratante.get(key).Id;
                    //PLV-3731 - INICIO
                    idGarantiaProduto.add(garantia.GarantiaProduto__c);
                    //PLV-3731 - FIM
                    garantiaContratanteList.add(garantia);
                }
            }
            
            system.debug('PLV_2826 garantiaContratanteList: ' + garantiaContratanteList);
            
            //PLV-3731 - INICIO
            system.debug('idGarantiaProduto'+idGarantiaProduto);
            Map<Id,GarantiaProduto__c> mpGarantiaProdutoCotacao = new Map<Id,GarantiaProduto__c>();
            
            if(idGarantiaProduto.size() > 0){
                List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                
                for(GarantiaProduto__c g : garantiasP){
                    mpGarantiaProdutoCotacao.put(g.Id,g);
                }
                
            }
            
            for(GarantiaContratanteOrcamento__c garantia : garantiaContratanteList){
                if(mpGarantiaProdutoCotacao.containsKey(garantia.GarantiaProduto__c)){
                    if(mapCotacao.containsKey(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode)){
                        garantia.ValorCotacao__c = mapCotacao.get(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode).cotacao;
                    }
                } 
                
            }
            
            //PLV-3731 - FIM
            System.debug('Gior Garantias do Contratante List........'+ garantiaContratanteList);
            insert garantiaContratanteList;
            
            List<GarantiaGrupoOrcamento__c> garantiaGrupoList = new  List<GarantiaGrupoOrcamento__c>();
            //PLV-3731 - INICIO
            idGarantiaProduto.clear();
            //PLV-3731 - FIM
            for (String key : mapOrcamentoGrupoCobertura.keySet())
            {
                
                for(GarantiaGrupoOrcamento__c garantia : mapOrcamentoGrupoCobertura.get(key))
                {
                    garantia.GrupoOrcamento__c = mapOrcamentoGrupo.get(key).Id;
                    //PLV-3731 - INICIO
                    idGarantiaProduto.add(garantia.GarantiaProduto__c);
                    //PLV-3731 - FIM
                    garantiaGrupoList.add(garantia);
                }
            }
            
            //PLV-3731 - INICIO
            if(idGarantiaProduto.size() > 0){
                mpGarantiaProdutoCotacao.clear();
                List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                
                for(GarantiaProduto__c g : garantiasP){
                    mpGarantiaProdutoCotacao.put(g.Id,g);
                }
                
            }
            for(GarantiaGrupoOrcamento__c garantia : garantiaGrupoList){
                if(mpGarantiaProdutoCotacao.containsKey(garantia.GarantiaProduto__c)){
                    if(mapCotacao.containsKey(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode)){
                        garantia.ValorCotacao__c = mapCotacao.get(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode).cotacao;
                    }
                } 
            }
            //PLV-3731 - FIM
            
            system.debug('PLV_2826 garantiaGrupoList: ' + garantiaGrupoList);
            insert garantiaGrupoList;
            
            //PLV2365: INICIO
            List<GarantiaSeguradoOrcamento__c> garantiaSeguradoList = new  List<GarantiaSeguradoOrcamento__c>();
            //PLV-3731 - INICIO
            idGarantiaProduto.clear();
            //PLV-3731 - FIM
            for (String key : mapOrcamentoSeguradoCoberturaPrecificacao.keySet())
            {
                
                for(GarantiaSeguradoOrcamento__c garantia : mapOrcamentoSeguradoCoberturaPrecificacao.get(key))
                {
                    garantia.SeguradoOrcamento__c = mapOrcamentoSegurado.get(key).Id;
                    //PLV-3731 - INICIO
                    idGarantiaProduto.add(garantia.GarantiaProduto__c);
                    //PLV-3731 - FIM
                    garantiaSeguradoList.add(garantia);
                }
            }
            //PLV-3731 - INICIO
            if(idGarantiaProduto.size() > 0){
                mpGarantiaProdutoCotacao.clear();
                List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                
                for(GarantiaProduto__c g : garantiasP){
                    mpGarantiaProdutoCotacao.put(g.Id,g);
                }
                
            }
            for(GarantiaSeguradoOrcamento__c garantia : garantiaSeguradoList){
                if(mpGarantiaProdutoCotacao.containsKey(garantia.GarantiaProduto__c)){
                    if(mapCotacao.containsKey(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode)){
                        garantia.ValorCotacao__c = mapCotacao.get(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode).cotacao;
                    }
                } 
            }
            //PLV-3731 - FIM
            system.debug('PLV_2826 garantiaSeguradoList: ' + garantiaSeguradoList);
            insert garantiaSeguradoList;
            //PLV2365: FIM
            
            
        }catch (Exception e){
            Database.rollback(sp);
            System.debug(e.getLineNumber() + ': ' + e.getMessage());
            
            throw new OrcamentoBuilderException('Exception: Inserir orcamento detalhes\r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - StackTrace: ' + e.getStackTraceString() + ' \r - Mensagem: ' + e.getMessage());
        }
        
        //---------------------
        
        return orcamentoCriado;
    }
    
    //PLV-2414-iNICIO
    //PLV-2938 - Inicio - Alteração no metodo para atender regra de negócio
    //PLV-3318 - INCIO - INCLUSAO DO MAP NO METODO
    public static List<ServiceTO.ParcelamentoTO> buscarParcelamentos(EmissaoTO.OfertasTO orcamento){
        //PLV-3318 - FIM
        //PLV-3136 - INÍCIO
        //PLV-2146 - INÍCIO
        //PLV-3318 - INICIO
        Map<String, Integer> versaocalculo = new map<string, integer>();
        
        for(EmissaoTO.VersoesCalculo mversao : orcamento.orcamento.versoesCalculos){
            string valorDesconto = String.valueOf(mversao.descontoAgravo);
            versaocalculo.put(valorDesconto,mversao.opcao);
        }
        system.debug('versaocalculo novo'+versaocalculo);
        
        List<EmissaoTO.RetornoCalculoTO> retornoCalculov = new List<EmissaoTO.RetornoCalculoTO>();        
        //PLV-3318 - FIM      
        EmissaoTO.RetornoCalculoTO retornoCalculo = new EmissaoTO.RetornoCalculoTO();
        if(orcamento.retornosCalculo != null && !orcamento.retornosCalculo.isEmpty()){
            //PLV-3318 - INICIO
            //retornoCalculo = orcamento.retornosCalculo[0];
            retornoCalculov = orcamento.retornosCalculo;
            //PLV-3318 - FIM
        }else{
            throw new OrcamentoBuilderException('Exception: retornosCalculo - Lista vazia');
        }
        //PLV-2146 - FIM
        System.debug('retornoCalculo ' + retornoCalculo);
        System.debug('orcamento ' + JSON.serialize(orcamento));
        //PLV-3136 - FIM

        // PLV-5331 INÍCIO
        ProductDAO produtoDao = ProductDAO.getInstance();
        Product2 prodPrec = produtoDao.buscProdPrecDtCalc(orcamento.orcamento.codigoProdutoVida, orcamento.orcamento.idProdutoSf);
        system.debug('Retorno buscProdPrecDtCalc = '+prodPrec);
        // PLV-5331 FIM
        //Buscar condições de cobrança atreladas ao produto
        List<CondicaoCobranca__c> condicoesCobrancas =  ContratanteOrcamentoDAO.getInstance().buscarCondicaoCobranca(orcamento.orcamento.codigoProdutoVida);
        ParametroVigencia__c parametroVigencia = [SELECT ParcelamentoAposFinalVigencia__c 
                                                  FROM ParametroVigencia__c 
                                                  WHERE Produto__r.ProductCode = :orcamento.orcamento.codigoProdutoVida
                                                  LIMIT 1];
        System.debug('Entrada parcelamentos' + condicoesCobrancas);         
        
        if (parametroVigencia.ParcelamentoAposFinalVigencia__c) {
            //Instaciação se um set de formas de pagamento 
            Set<Id> sFormaPagamento = new Set<Id>();
            for(CondicaoCobranca__c cond: condicoesCobrancas){
                sFormaPagamento.add(cond.FormaPagamento__c);
            }
            
            List<ServiceTO.ParcelamentoTO> parcelamentos = new List<ServiceTO.ParcelamentoTO>();
            
            ///PLV-3137 - Inicio
            Map<String, Set<PlanoParcelamento__c>> planoMap = new Map<String, Set<PlanoParcelamento__c>>();
            for(PlanoParcelamento__c plano : ([SELECT Id, FormaPagamento__c, 
                                               CodigoMeioRecebimento__c, 
                                               DescricaoMeioRecebimento__c,
                                               NumeroParcela__c 
                                               FROM PlanoParcelamento__c 
                                               WHERE FormaPagamento__c IN :sFormaPagamento
                                               ORDER BY NumeroParcela__c
                                              ]) ){
                                                  if(!planoMap.containsKey(plano.FormaPagamento__c))   planoMap.put(plano.FormaPagamento__c, new Set<PlanoParcelamento__c>());
                                                  planoMap.get( plano.FormaPagamento__c).add(plano);
                                              }
            system.debug('sFormaPagamento'+sFormaPagamento);
            ///PLV-3137 - FIM
            
            //Atribuição das variavéis na tag parcelamento
            system.debug('condicoesCobrancas' +condicoesCobrancas);
            //PLV-3318 - INICIO
            integer opcao;
            //PLV-3318 - FIM
            for(CondicaoCobranca__c condicao: condicoesCobrancas){
                //PLV-3318 - INICIO 
                decimal perDesconto = condicao.PercentualDescontoAgravo__c; 
                for(String valor : versaocalculo.keySet()) {
                    if(Decimal.valueOf(valor) == perDesconto){
                        opcao = versaocalculo.get(valor);
                        system.debug('versaocalculo.get opca'+perDesconto+'-'+versaocalculo.get(valor));
                        for(integer y=0; y < retornoCalculov.size(); y++){
                            if(retornoCalculov[y].opcao == opcao){
                                retornoCalculo = retornoCalculov[y];
                                break;
                            }  
                        }
                        
                    }
                }
                
                system.debug('retornoCalculov'+retornoCalculo);
                //PLV-3318 - FIM
                
                ///PLV-3137 - Inicio
                List<PlanoParcelamento__c> planoList = new List<PlanoParcelamento__c>(planoMap.get(condicao.FormaPagamento__c));
                
                //PLV-3318 - INICIO
                //PLV-3136 - INÍCIO
                Decimal valorParcela;               
                String[] arrQuantidadeParc = condicao.QuantidadeParcelas__c.split('\\;');
                system.debug('lista de parecelas'+arrQuantidadeParc);
                integer qtTotal = arrQuantidadeParc.size();
                integer totalParcelamento;
                system.debug(qtTotal);
                Decimal primeiraParcela;       
                //PLV-4668 INICIO
                String segmento  = orcamento.orcamento.segmento;
                String tipoSeguro = orcamento.orcamento.tipoSeguro;

                System.debug('segmento' + segmento);
                System.debug('tipoSeguro' + tipoSeguro);
                
                Integer limiteParcela = null;
                if(segmento == 'Individual' && tipoSeguro == 'eds'){
                    Double premioTotal = retornoCalculo.precificacao.premio.total;

                    if(premioTotal > 0){
                        Integer diasLimiteVigencia = Date.valueOf(orcamento.orcamento.dataCalculo).DaysBetween(Date.valueOf(orcamento.orcamento.vigenciaFinal));
                        if(diasLimiteVigencia > 120 ){
                            Integer diasLimiteParcelamento = Date.valueOf(orcamento.orcamento.dataCalculo).DaysBetween(Date.valueOf(orcamento.orcamento.vigenciaFinal).addDays(-60));
                            System.debug('diasLimiteParcelamento' + diasLimiteParcelamento);
                            limiteParcela = diasLimiteParcelamento/30;
                        }else{
                            limiteParcela = 1;
                        }
                    }else if(premioTotal < 0){
                        limiteParcela = 1;
                    }else{
                        limiteParcela = 0;
                    }
                }
                //PLV-4668 FIM
                for(integer x=0; x < qtTotal; x++){
                    ServiceTO.ParcelamentoTO parcelamento = new ServiceTO.ParcelamentoTO();
                    
                    totalParcelamento = Integer.ValueOf(arrQuantidadeParc[x]);
                    system.debug('total parcela'+totalParcelamento);         
                    if(limiteParcela != null && limiteParcela < totalParcelamento) continue;
                    
                    primeiraParcela = (retornoCalculo.precificacao.premio.total - ((totalParcelamento-1)*(retornoCalculo.precificacao.premio.total/totalParcelamento).SetScale(2))).SetScale(2);
                    valorParcela = (retornoCalculo.precificacao.premio.total/totalParcelamento).setScale(2);
                    parcelamento.valorPrimeiraParcela = '' + primeiraParcela;
                    System.debug('primeira parcela'+primeiraParcela);
                    
                    parcelamento.qtdParcelas = totalParcelamento;
                    parcelamento.meioRecebimentoPrimeiraParcela = '' + planoList[0].CodigoMeioRecebimento__c;
                    if( totalParcelamento > 1 ){
                        parcelamento.valorDemaisParcelas = '' + valorParcela;
                        parcelamento.meioRecebimentoDemaisParcelas = '' + planoList[1].CodigoMeioRecebimento__c;
                    }
                    ///PLV-3137 - FIM
                    
                    parcelamento.idFormaPagamento = condicao.FormaPagamento__c;
                    parcelamento.juros = Integer.valueof(retornoCalculo.precificacao.juros);
                    parcelamento.iof = retornoCalculo.precificacao.iof;
                    parcelamento.encargos = Integer.valueof(retornoCalculo.precificacao.encargos);
                    //parcelamento.custoapolice = Integer.valueOf(retornoCalculo.precificacao.custoApolice);
                    parcelamento.custoapolice = 0;
                    parcelamento.descricao = condicao.FormaPagamento__r.Name;
                    //PLV-3571 - INÍCIO
                    parcelamento.nomeFormaPagamento = condicao.NomeFormaPagamento__c;
                    //PLV-3571 - FIM
                    parcelamento.codigo = Integer.valueOf(condicao.FormaPagamento__r.Codigo__c);
                    //PLV-2678 - INICIO - Retornar agrupamento da Forma de pagamento para o portal
                    parcelamento.agrupamento = condicao.TipoPagamento__c;            
                    //PLV-2678 - FIM - Retornar agrupamento da Forma de pagamento para o portal
                    
                    //PLV-3318 - INICIO INCLUSAO TAG OPCAO
                    //system.debug('entrou no metodo versaocalculo'+versaocalculo);
                    system.debug('condicao tags'+condicao);
                    
                    //PLV-3318 - INICIO DA INCLUSAO DO DESCONTO NO PARCELAMENTO
                    parcelamento.descontoAgravo = condicao.PercentualDescontoAgravo__c;
                    //PLV-3318 - FIM
                    system.debug('perDesconto'+perDesconto);
                    //parcelamento.opcao = 0;
                    /*for(String valor : versaocalculo.keySet()) {
if(Decimal.valueOf(valor) == perDesconto){
parcelamento.opcao = versaocalculo.get(valor);
}
}*/
                    parcelamento.opcao = opcao;
                    system.debug('parcelamento.opcao'+parcelamento.opcao);
                    //PLV-3318 - FIM

                    // parcelamento.limiteValorParcela= condicao.LimiteValorParcela__c; // ANNVI-48 - INICIO/FIM
                    
                    parcelamentos.add(parcelamento);
                    //PLV-3136 - FIM
                }
                //y++;
                //PLV-3318 - FIM
                
            }
            return parcelamentos;
        }
        
        //Criar código com a lógica necessária
        //Pegar a diferença em dias das vigencias (utilizar MonthsBetween)
        Integer diasDeVigencia = Date.valueOf(orcamento.orcamento.vigenciaInicial).DaysBetween(Date.valueOf(orcamento.orcamento.vigenciaFinal));
        Integer mesesDeVigencia = DiasDeVigencia/30;
        //PLV-2938 Fix1 - Inicio - Ajustes no mes de vigencia
        if(mesesDeVigencia == 0) mesesDeVigencia = 1;
        //PLV-2938 Fix1 - Fim - Ajustes no mes de vigencia
        
        //Colocar Forma Pagamento
        Map<Id,List<Integer>> mQuantidadeParcelas = new Map<Id,List<Integer>>();
        
        for(CondicaoCobranca__c conCobranca: condicoesCobrancas){
            List<Integer> lParcela;
            if(mQuantidadeParcelas.containsKey(conCobranca.FormaPagamento__c)){
                lParcela = mQuantidadeParcelas.get(conCobranca.FormaPagamento__c);
            }else {
                lParcela = new List<Integer>();
            }
            //PLV-2938 Fix1 - Inicio/Fim - Codigo removido
            
            for(String parcela: conCobranca.QuantidadeParcelas__c.split(';')){
                if(Integer.valueOf(parcela) <= mesesDeVigencia){
                    lParcela.add(Integer.valueOf(parcela));
                }
            }
            if(!lParcela.isEmpty()){
                mQuantidadeParcelas.put(conCobranca.FormaPagamento__c, lParcela);
            }
        }
        
        //Validar map
        if(mQuantidadeParcelas.isEmpty()) return null;
        
        ///PLV-3137 -  - Inicio
        Map<String, Set<PlanoParcelamento__c>> planoMap = new Map<String, Set<PlanoParcelamento__c>>();
        for(PlanoParcelamento__c plano : ([SELECT Id, FormaPagamento__c, 
                                           CodigoMeioRecebimento__c, 
                                           DescricaoMeioRecebimento__c,
                                           NumeroParcela__c 
                                           FROM PlanoParcelamento__c 
                                           WHERE FormaPagamento__c IN :mQuantidadeParcelas.keySet()
                                           ORDER BY NumeroParcela__c
                                          ]) ){
                                              
                                              if(!planoMap.containsKey(plano.FormaPagamento__c)) planoMap.put(plano.FormaPagamento__c, new Set<PlanoParcelamento__c>());
                                              planoMap.get( plano.FormaPagamento__c).add(plano);
                                          }
        ///PLV-3137 - FIM
        
        List<ServiceTO.ParcelamentoTO> parcelamentos = new List<ServiceTO.ParcelamentoTO>();
        system.debug('condicoesCobrancas'+condicoesCobrancas);
        system.debug('planoMap'+planoMap);
        //PLV-3318 - INICIO
        integer opcao;
        //PLV-3318 - FIM
        for(CondicaoCobranca__c condicao: condicoesCobrancas){
            //PLV-3318 - INICIO
            //ServiceTO.ParcelamentoTO parcelamento = new ServiceTO.ParcelamentoTO();
            //PLV-3318 - FIM
            //PLV-2938 Fix1 - Inicio - Ajustes no retorno da tag parcelamentos
            //PLV-3318 - INICIO 
            decimal perDesconto = condicao.PercentualDescontoAgravo__c; 
            system.debug('valor desconto agravo'+perDesconto);
            for(String valor : versaocalculo.keySet()) {
                if(Decimal.valueOf(valor) == perDesconto){
                    opcao = versaocalculo.get(valor);
                    system.debug('versaocalculo.get opca'+perDesconto+'-'+versaocalculo.get(valor));
                    for(integer y=0; y < retornoCalculov.size(); y++){
                        if(retornoCalculov[y].opcao == opcao){
                            retornoCalculo = retornoCalculov[y];
                            break;
                        }  
                    }
                    
                }
            }
            
            system.debug('retornoCalculov'+retornoCalculo);
            //PLV-3318 - FIM
            if(planoMap.containsKey(condicao.FormaPagamento__c)){
                
                ///PLV-3137 - Inicio
                List<PlanoParcelamento__c> planoList = new List<PlanoParcelamento__c>(planoMap.get(condicao.FormaPagamento__c));				               
                //PLV-3318 - INICIO
                //PLV-3136 - INÍCIO
                System.debug('retornoCalculo ' + retornoCalculo);
                System.debug('retornoCalculo.precificacao ' + retornoCalculo.precificacao);
                system.debug('Quantidade parcelas'+condicao.QuantidadeParcelas__c);
                Decimal valorParcela;               
                String[] arrQuantidadeParc = condicao.QuantidadeParcelas__c.split('\\;');
                system.debug('lista de parcelas'+arrQuantidadeParc);
                integer qtTotal = arrQuantidadeParc.size();
                integer totalParcelamento;
                Decimal primeiraParcela;
                //system.debug('premio.total'+retornoCalculo.precificacao.premio.total);
                
                for(integer x=0; x < qtTotal; x++){
                    totalParcelamento = Integer.ValueOf(arrQuantidadeParc[x]);
                    if(totalParcelamento <= mesesDeVigencia){
                        ServiceTO.ParcelamentoTO parcelamento = new ServiceTO.ParcelamentoTO();
                        system.debug('total parcela'+totalParcelamento);         
                        
                        primeiraParcela = (retornoCalculo.precificacao.premio.total - ((totalParcelamento-1)*(retornoCalculo.precificacao.premio.total/totalParcelamento).SetScale(2))).SetScale(2);
                        valorParcela = (retornoCalculo.precificacao.premio.total/totalParcelamento).setScale(2);
                        parcelamento.valorPrimeiraParcela = '' + primeiraParcela;
                        System.debug('primeira parcela'+primeiraParcela);                           
                        parcelamento.qtdParcelas = totalParcelamento;
                        System.debug('parcelamento.qtdParcelas'+totalParcelamento); 
                        parcelamento.meioRecebimentoPrimeiraParcela = '' + planoList[0].CodigoMeioRecebimento__c;
                        if( totalParcelamento > 1 ){
                            parcelamento.valorDemaisParcelas = '' + valorParcela;
                            parcelamento.meioRecebimentoDemaisParcelas = '' + planoList[1].CodigoMeioRecebimento__c;
                        }
                        ///PLV-3137 - FIM
                        
                        parcelamento.idFormaPagamento = condicao.FormaPagamento__c;
                        parcelamento.juros = Integer.valueof(retornoCalculo.precificacao.juros);
                        parcelamento.iof = retornoCalculo.precificacao.iof;
                        parcelamento.encargos = Integer.valueof(retornoCalculo.precificacao.encargos);
                        //parcelamento.custoapolice = Integer.valueOf(retornoCalculo.precificacao.custoApolice);
                        parcelamento.custoapolice = 0;
                        parcelamento.descricao = condicao.FormaPagamento__r.Name;
                        parcelamento.codigo = Integer.valueOf(condicao.FormaPagamento__r.Codigo__c);
                        //PLV-2678 - INICIO - Retornar agrupamento da Forma de pagamento para o portal
                        parcelamento.agrupamento = condicao.TipoPagamento__c;            
                        //PLV-2678 - FIM - Retornar agrupamento da Forma de pagamento para o portal
                        
                        //PLV-3318 - INICIO INCLUSAO TAG OPCAO
                        //system.debug('entrou no metodo versaocalculo'+versaocalculo);
                        system.debug('condicao tags'+condicao);
                        
                        //PLV-3318 - INICIO DA INCLUSAO DO DESCONTO NO PARCELAMENTO
                        parcelamento.descontoAgravo = condicao.PercentualDescontoAgravo__c;
                        parcelamento.opcao = opcao;
                        //PLV-3318 - FIM
                        
                        /*system.debug('perDesconto'+perDesconto);
parcelamento.opcao = 0;
for(String valor : versaocalculo.keySet()) {
if(Decimal.valueOf(valor) == perDesconto){
parcelamento.opcao = versaocalculo.get(valor);
}
}*/
                        system.debug('parcelamento.opcao'+parcelamento.opcao);
                        //PLV-3318 - FIM
                    
                        // parcelamento.limiteValorParcela= condicao.LimiteValorParcela__c; // ANNVI-48 - INICIO/FIM
                        
                        parcelamentos.add(parcelamento);
                    }
                    //PLV-3136 - FIM
                }
                
                //PLV-3318 - FIM
            }
        }
        
        return parcelamentos;
    }
    //PLV-2938 - Fim - Alteração no metodo para atender regra de negócio
    //PLV-2414-FIM
    //PLV2365: FIM
    
    //PLV2365: INICIO
    private String buscarChaveContaPadrao(Map<String, ContratanteOrcamento__c> mapContratante, Map<String, SeguradoOrcamento__c> mapSegurado, Map<String, Account> mapConta)
    {
        String retorno;
        
        String contratantePrincipal = buscarChaveContratantePrincipal(mapContratante);
        
        if(contratantePrincipal != null)
        {
            if(mapConta.containsKey(contratantePrincipal))
                retorno = contratantePrincipal;
            else
            {
                for(String key : mapSegurado.keySet())
                {
                    retorno = key;
                    break;
                }
            }
            
        }
        
        return retorno;
    }
    //PLV2365: FIM
    //PLV-2607- Inicio
    private void montaContratantePrecificacao(EmissaoTO.ContratanteTO contratante, Map<String, ContratanteOrcamento__c> mapOrcamentoContratante, Map<String, List<GarantiaContratanteOrcamento__c>> mapOrcamentoCotratanteCobertura, Set<String> setSiglasCoberturas, EmissaoTO.OfertasTO payloadTO)
    {
        System.debug('Gior contratante...........'+JSON.serialize(contratante));
        System.debug('Gior mapOrcamentoContratante...........'+JSON.serialize(mapOrcamentoContratante));
        System.debug('Gior mapOrcamentoCotratanteCobertura...........'+JSON.serialize(mapOrcamentoCotratanteCobertura));
        System.debug('Gior setSiglasCoberturas...........'+JSON.serialize(setSiglasCoberturas));

        system.debug('===> payloadTO' + JSON.serialize(payloadTO));

        EmissaoTO orcamento = payloadTO.orcamento;//PLV-5676 - INICIO/FIM
        system.debug('===> orcamento' + orcamento );

        //PLV-2607- Fim
        ContratanteOrcamento__c contratanteObj = new ContratanteOrcamento__c();   
        
        
        System.debug('Giordano contratante_numero1'+contratante.numero);
        if(mapOrcamentoContratante.containsKey(contratante.numero))
        {
            System.debug('Giordano contratante_numero2'+contratante.numero);
            System.debug('Giordano Entrou aqui!!!!');
            contratanteObj = mapOrcamentoContratante.get(contratante.numero);
            
            contratanteObj.IOF__c               = contratante.iof;
            //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse
            if(contratante.premio != null){
                contratanteObj.PremioComercial__c   = contratante.premio.comercial;
                contratanteObj.PremioPuro__c        = contratante.premio.puro;
                contratanteObj.PremioTotal__c       = contratante.premio.total;
            }
            
            if(contratante.taxa != null){
                contratanteObj.TaxaComercial__c     = contratante.taxa.comercial;
                contratanteObj.TaxaPura__c          = contratante.taxa.pura;
                contratanteObj.TaxaTotal__c         = contratante.taxa.total;
            }
            //PLV-3317 - FIM
            
            system.debug('descontoAgravo: ' + contratante);
            system.debug('descontoAgravo: ' + contratante.descontoAgravo);

            //PLV-5676- INICIO
            if(tipoSeguro.contains(orcamento.tipoSeguro)){
                if(orcamento.contratoOriginal.precificacao != null){
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : orcamento.contratoOriginal.precificacao.descontoAgravo){
                        if(descontoAgravo.tipo == 'TEC'){
                            this.fillFieldsDescAgr(contratanteObj, descontoAgravo);
                        }
                    }
                }
            //PLV-2148 - INICIO - Inclusao do IF para atender o processo
            }else if(contratante.descontoAgravo != null) { //PLV-5676 - FIM
                //II-54 FIX01 INICIO
                String IdCtrOrgiginal = payloadTO.orcamento.idContratoRenovado;
                List<Contract> contratoOrig = [SELECT Id, DescontoAgravoPercentualTecnico__c FROM Contract WHERE Id =: IdCtrOrgiginal];
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : contratante.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        if(payloadTO.orcamento.tipoSeguro == 'Renovacao'){
                            System.debug('ENTROU NO TIPO TEC Renovação Objeto contratante');
                            contratanteObj.DescontoAgravoPercentualTecnico__c = contratoOrig[0].DescontoAgravoPercentualTecnico__c;
                            contratanteObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }else{
                            contratanteObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            contratanteObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        // contratanteObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        // contratanteObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    } //II-54 FIX01 FIM
                    else if(descontoAgravo.tipo == 'COM') {
                        contratanteObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        contratanteObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        contratanteObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        contratanteObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }
            //PLV-2148 - FIM
            
            List<GarantiaContratanteOrcamento__c> garantiaContratanteList = new List<GarantiaContratanteOrcamento__c>();
            //PLV-3317 - INICIO - Ajuste na logica para pegar todas as coberturas e capitais
            Map<String, EmissaoTO.coberturaTO> mapCalculos = new Map<String, EmissaoTO.coberturaTO>(); 
            for(EmissaoTO.coberturaTO cobertura : contratante.coberturas){
                mapCalculos.put(cobertura.sigla,cobertura);
            }
            
            System.debug('Gior MapCoberturas.......'+ mapCoberturas);
            for(EmissaoTO.coberturaTO cobertura : mapCoberturas.values())
            {
                GarantiaContratanteOrcamento__c coberturaOrc = new GarantiaContratanteOrcamento__c();
                system.debug('ENVIO -- SIGLA COBETURA '+ cobertura.sigla);
                system.debug('ENVIO -- MAP '+ coberturaOrc);
                //PLV-2607- Inicio
                montarCoberturaContratante(cobertura, coberturaOrc, setSiglasCoberturas, mapCalculos, payloadTO); //PLV-5676 - INICIO/FIM
                
                if(coberturaOrc.Garantia__c != null)
                    //PLV-2607- Fim
                    garantiaContratanteList.add(coberturaOrc);
            }
            //PLV-3317 - FIM - Ajuste na logica para pegar todas as coberturas e capitais
            
            mapOrcamentoCotratanteCobertura.put(contratante.numero, garantiaContratanteList);
        }
        
    }
    //PLV-2607- Inicio
    private void montaGrupoPrecificacao(String strContratante, EmissaoTO.GrupoTO grupo, Map<String, GrupoOrcamento__c> mapOrcamentoGrupo, Map<String, List<GarantiaGrupoOrcamento__c>> mapOrcamentoGrupoCobertura, Set<String> setSiglasCoberturas, EmissaoTO.OfertasTO payloadTO)
    {

        system.debug('===> payloadTO' + JSON.serialize(payloadTO));

        EmissaoTO orcamento = payloadTO.orcamento;//PLV-5676 - INICIO/FIM 
        System.debug('===> orcamento: ' + orcamento);


        //PLV-2607- Fim
        String key = strContratante + '_' + grupo.numero;
        
        if(mapOrcamentoGrupo.containsKey(key))
        {
            GrupoOrcamento__c grupoObj = mapOrcamentoGrupo.get(key);
            
            grupoObj.IOF__c               = grupo.iof;
            //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse
            if(grupo.premio != null){
                grupoObj.PremioComercial__c   = grupo.premio.comercial;
                grupoObj.PremioPuro__c        = grupo.premio.puro;
                grupoObj.PremioTotal__c       = grupo.premio.total;
            }
            if(grupo.taxa != null){
                grupoObj.TaxaComercial__c     = grupo.taxa.comercial;
                grupoObj.TaxaPura__c          = grupo.taxa.pura;
                grupoObj.TaxaTotal__c         = grupo.taxa.total;
            }
            //PLV-3317 - FIM
            //PLV-5657 - INICIO
            //PLV-5676- INICIO
            if(tipoSeguro.contains(orcamento.tipoSeguro)){
                if(orcamento.contratoOriginal.precificacao != null){
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : orcamento.contratoOriginal.precificacao.descontoAgravo){
                        if(descontoAgravo.tipo == 'TEC'){
                            this.fillFieldsDescAgr(grupoObj, descontoAgravo);
                        }
                    }
                }
            }else if(grupo.descontoAgravo != null) {//PLV-5676 - INICIO/FIM
                //II-54 FIX01 INICIO
                String IdCtrOrgiginal = payloadTO.orcamento.idContratoRenovado;
                List<Contract> contratoOrig = [SELECT Id, DescontoAgravoPercentualTecnico__c FROM Contract WHERE Id =: IdCtrOrgiginal];
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : grupo.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        if(payloadTO.orcamento.tipoSeguro == 'Renovacao'){
                            System.debug('ENTROU NO TIPO TEC Renovação Objeto grupo');
                            grupoObj.DescontoAgravoPercentualTecnico__c = contratoOrig[0].DescontoAgravoPercentualTecnico__c;
                            grupoObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }else{
                            grupoObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            grupoObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        // grupoObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        // grupoObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }//II-54 FIX01 FIM
                    else if(descontoAgravo.tipo == 'COM') {
                        grupoObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        grupoObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        grupoObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        grupoObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }
            //PLV-2146 - FIM
            List<GarantiaGrupoOrcamento__c> garantiaGrupoList = new List<GarantiaGrupoOrcamento__c>();
            //PLV-3317 - INICIO - Ajuste na logica para pegar todas as coberturas e capitais
            Map<String,EmissaoTO.coberturaTO> mapCalculos = new Map<String,EmissaoTO.coberturaTO>();
            for(EmissaoTO.coberturaTO cobertura : grupo.coberturas){
                mapCalculos.put(cobertura.sigla, cobertura);
            }
            
            for(EmissaoTO.coberturaTO cobertura : mapCoberturas.values())
            {
                
                GarantiaGrupoOrcamento__c coberturaOrc = new GarantiaGrupoOrcamento__c();
                //PLV-2607- Inicio
                montarCoberturaGrupo(cobertura, coberturaOrc, setSiglasCoberturas, mapCalculos, payloadTO);
                
                if(coberturaOrc.Garantia__c != null)
                    //PLV-2607- Fim
                    garantiaGrupoList.add(coberturaOrc);
            }
            //PLV-3317 - FIM - Ajuste na logica para pegar todas as coberturas e capitais
            
            mapOrcamentoGrupoCobertura.put(key, garantiaGrupoList);
        }
        
    }
    //PLV-2607- Inicio -  Alteração de parametros
    private void montaSeguradoPrecificacao(String strcontratante, String strgrupo, EmissaoTO.SeguradoTO segurado, Map<String, SeguradoOrcamento__c> mapOrcamentoSegurado, Map<String, List<GarantiaSeguradoOrcamento__c>> mapOrcamentoSeguradoCoberturaPrecificacao, Set<String> setSiglasCoberturas, EmissaoTO.OfertasTO payloadTO)
    {
        System.debug('Entrou montaSeguradoPrecificacao;');

        system.debug('===> payloadTO' + JSON.serialize(payloadTO));

        EmissaoTO orcamento = payloadTO.orcamento;//PLV-5676 - INICIO/FIM 
        System.debug('===> orcamento: ' + orcamento);

        //PLV-2607- Fim -  Alteração de parametros
        String key = strcontratante + '_' + strgrupo + '_' + segurado.numero;
        
        if(mapOrcamentoSegurado.containsKey(key))
        {
            SeguradoOrcamento__c seguradoObj = mapOrcamentoSegurado.get(key);
            
            seguradoObj.IOF__c               = segurado.iof;
            //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse
            if(segurado.premio != null){
                seguradoObj.PremioComercial__c   = segurado.premio.comercial;
                seguradoObj.PremioPuro__c        = segurado.premio.puro;
                seguradoObj.PremioTotal__c       = segurado.premio.total;
            }
            if(segurado.taxa != null){
                seguradoObj.TaxaComercial__c     = segurado.taxa.comercial;
                seguradoObj.TaxaPura__c          = segurado.taxa.pura;
                seguradoObj.TaxaTotal__c         = segurado.taxa.total;
            }
            //PLV-3317 - FIM
            //PLV-5676- INICIO
            if(tipoSeguro.contains(orcamento.tipoSeguro)){
                if(orcamento.contratoOriginal.precificacao != null){
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : orcamento.contratoOriginal.precificacao.descontoAgravo){
                        if(descontoAgravo.tipo == 'TEC'){
                            this.fillFieldsDescAgr(seguradoObj, descontoAgravo);
                        }
                    }
                }
            //PLV-2146 - INÍCIO
            }else if(segurado.descontoAgravo != null) {//PLV-5676 - INICIO/FIM
                //II-54 FIX01 INICIO
                String IdCtrOrgiginal = payloadTO.orcamento.idContratoRenovado;
                List<Contract> contratoOrig = [SELECT Id, DescontoAgravoPercentualTecnico__c FROM Contract WHERE Id =: IdCtrOrgiginal];
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : segurado.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        if(payloadTO.orcamento.tipoSeguro == 'Renovacao'){
                            System.debug('ENTROU NO TIPO TEC Renovação Objeto segurado');
                            seguradoObj.DescontoAgravoPercentualTecnico__c = contratoOrig[0].DescontoAgravoPercentualTecnico__c;
                            seguradoObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }else{
                            seguradoObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            seguradoObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        // seguradoObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        // seguradoObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    } //II-54 FIX01 FIM
                    else if(descontoAgravo.tipo == 'COM') {
                        seguradoObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        seguradoObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        seguradoObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        seguradoObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }
            //PLV-2146 - FIM
            List<GarantiaSeguradoOrcamento__c> garantiaSeguradoList = new List<GarantiaSeguradoOrcamento__c>();
           
           //PLV-4620 - INICIO
           Map<String,EmissaoTO.coberturaTO> mapCalculos = new Map<String,EmissaoTO.coberturaTO>();
            for(EmissaoTO.coberturaTO cobertura : segurado.coberturas){
                mapCalculos.put(cobertura.sigla, cobertura);
            }
           //for(EmissaoTO.coberturaTO cobertura : segurado.coberturas){
           system.debug('mapCoberturas: '+mapCoberturas.values());
           for(EmissaoTO.coberturaTO cobertura : mapCoberturas.values()){             
                
                GarantiaSeguradoOrcamento__c coberturaOrc = new GarantiaSeguradoOrcamento__c();
                
                //PLV-2607- Inicio
                system.debug('cobertura: '+cobertura);
                system.debug('coberturaOrc: '+coberturaOrc);
                system.debug('setSiglasCoberturas: '+setSiglasCoberturas);
                
                montarCoberturaSegurado(cobertura, coberturaOrc, setSiglasCoberturas, mapCalculos, payloadTO);
                if(coberturaOrc.Garantia__c != null)
                    //PLV-2607- Fim
                    garantiaSeguradoList.add(coberturaOrc);
                    system.debug('Gilberto garantiaSeguradoList>> '+garantiaSeguradoList);
                system.debug('setSiglasCoberturas: '+setSiglasCoberturas);
            }
            //PLV-4620 - FIM
            
            mapOrcamentoSeguradoCoberturaPrecificacao.put(key, garantiaSeguradoList);
        }
        
    }
    //PLV-4684 INICIO
    //PLV2365: INICIO
    private Opportunity gravarObjOrcamento(EmissaoTO.OfertasTO payloadTO, Contract contratoOriginal, Map<String, Account>  mapSeguradoOrcamentoConta, String chaveContaPadraoSegurado, Set<String> setSiglasCoberturas)
    {
        //PLV-4684 FIM
        system.debug('TESTE Rogerio123' + mapCoberturas);
        system.debug('Payload: '+ JSON.serialize(payloadTO));

        //PLV-3136 - INÍCIO
        //PLV-2146 - INÍCIO
       
        //INICIO - PLV-VI-4865 - Guilherme Brito
        EmissaoTO.RetornoCalculoTO retornoCalculo = new EmissaoTO.RetornoCalculoTO();
        if(payloadTO.retornosCalculo != null && !payloadTO.retornosCalculo.isEmpty()) {
            //TKCL-461 INCIO FIX03
            if(payloadTO.orcamento.codigoProdutoVida == 'APTLMKT'){
                retornoCalculo = payloadTO.retornosCalculo[0];
            }
            else if(payloadTO.retornosCalculo.size() > 1) {
                //ANNVI-163 INICIO
                for(EmissaoTO.RetornoCalculoTO retorno: payloadTO.retornosCalculo){
                    for(EmissaoTO.DescontoAgravoTO descAgrav : retorno.precificacao.DescontoAgravo){
                        if(descAgrav.tipo == 'FPG'){
                            if(descAgrav.percentual == 0){
                                retornoCalculo = retorno;
                                break;
                            } 
                        }
                    }
                }
                if(retornoCalculo == null) retornoCalculo = payloadTO.retornosCalculo[0];
                //ANNVI-163 FIM
                //retornoCalculo = payloadTO.retornosCalculo.get(payloadTO.retornosCalculo.size()-1);
            }
            else {
                retornoCalculo = payloadTO.retornosCalculo[0];
            }
            //TKCL-461 FIM FIX03
        }
        else {
            throw new OrcamentoBuilderException('Exception: retornoCalculo vazio.');
        }
        System.debug('retornoCalculo Rogerio' + retornoCalculo);
        //PLV-2146 - FIM
        //PLV-3136 - FIM
        // PLV-2327 - INICIO
        Opportunity orcamento = new Opportunity();
        system.debug('ENTROU NO METODO');
        // PLV-4666 - INICIO
        if(retornoCalculo != null && retornoCalculo != null){
            orcamento.tarifa__c = retornoCalculo.tarifa;
            if(retornoCalculo.dlls != null){
                for(String dll : retornoCalculo.dlls){
                    if(dll != null){
                        orcamento.dll__c = orcamento.dll__c != null ? orcamento.dll__c + ';' + dll : dll;
                    }
                }
            }
        }
        // PLV-4666 - FIM
        //PLV2365: INICIO
        List<GarantiaOrcamento__c> garantiaOrcamentoList = new List<GarantiaOrcamento__c>();
        //PLV2365: FIM
        
        ProductBO produtoBo = ProductBO.getInstance();
        //PLV_2826 - INICIO - Criar oportunidade sem conta
        String contaId; 
        
        system.debug('mapSeguradoOrcamentoConta:' + mapSeguradoOrcamentoConta);
        system.debug('chaveContaPadraoSegurado' + chaveContaPadraoSegurado);        
        if(!mapSeguradoOrcamentoConta.isEmpty() && String.isNotEmpty(chaveContaPadraoSegurado)){
            if(mapSeguradoOrcamentoConta.containsKey(chaveContaPadraoSegurado))
                contaId = mapSeguradoOrcamentoConta.get(chaveContaPadraoSegurado).Id;
            system.debug('contaId: ' + contaId);
        }//PLV - 4655 INICIO
        else if('eds'.equalsIgnoreCase(payLoadTO.orcamento.tipoSeguro)){
                contaId = Test.isRunningTest() ? mapSeguradoOrcamentoConta.get('0').Id : mapSeguradoOrcamentoConta.get('1').Id; //ANNVI-55 - INICIO/FIM
            }
        //PLV - 4655 FIM
        //PLV_2826 - FIM - Criar oportunidade sem conta
        
        payloadTO.orcamento.endosso = '0';
        
        try {
            system.debug('NUMERO '+ payloadTO.orcamento.numeroOrcamento);
            //PLV-2995 - INICIO - Chamada do método para consultar o produto pela data de calculo
            //system.debug('Abaixo cod e id');
            //system.debug(payLoadTO.orcamento.codigoProdutoVida);
            //system.debug(payLoadTO.orcamento.idProdutoSf);
            //system.debug('Acima cod e id');

            // PLV-5331 INÍCIO
            ProductDAO produtoDao = ProductDAO.getInstance();
            Product2 prodPrec = produtoDao.buscProdPrecDtCalc(payLoadTO.orcamento.codigoProdutoVida, payLoadTO.orcamento.idProdutoSf);
            // PLV-5331 FIM

            Product2 produto = produtoBO.buscarProdutoPorDataCalculo(prodPrec.ProductCode, Date.valueOf(payLoadTO.orcamento.dataCalculo));
            //PLV-2995 - FIM
            system.debug('PRODUTO 3153 '+ produto);
            CanalDistribuicao__c canalDistribuicao = CanalDistribuicaoDAO.getInstance().buscarCanalDistribuicaoOrcamentoPorSigla(payloadTO.orcamento.canalDistribuicao);
            system.debug('CANAL '+ canalDistribuicao);
            
            //PLV-2932 Fix2 - Inicio - Adição de map
            //PLV-3884 - INICIO - Mapa de garantia para selecao de moeda
            Map<String, GarantiaProduto__c> mGarantiaProd = new Map<String, GarantiaProduto__c>();
            for(GarantiaProduto__c gProduto: produto.GarantiasProduto__r){
                mGarantiaProd.put(gProduto.Garantia__r.Sigla__c, gProduto);
            }
            //PLV-3884 - FIM
            //PLV-2932 Fix2 - Fim - Adição de map
            
            system.debug('Map Diego: ' + JSON.serialize(mGarantiaProd));
            //rotulo
            //segmento
            orcamento.MeioComercializacao__c = payloadTO.orcamento.meioComercializacao;
            //PLV-2422 - Inicio - Incluir logica para para preencher o name com o meio de comercialização
            if(payloadTO.orcamento.numeroOrcamento != null){
                orcamento.Numero__c          = payloadTO.orcamento.numeroOrcamento;
                if(payloadTO.orcamento.meioComercializacao != null || payloadTO.orcamento.meioComercializacao != ''){
                    orcamento.Name               = payloadTO.orcamento.meioComercializacao + '-' + payloadTO.orcamento.numeroOrcamento;
                }else{
                    orcamento.Name               = 'ORC-' + payloadTO.orcamento.numeroOrcamento;
                }
                
            }else{
                orcamento.Name               = 'provisorio';
            }
            //PLV-2422 - Fim
            //PLV-3130 - INICIO
            //Código removido para PLV-3317
            //PLV-3130 - FIM
            //PLV-4199 - INICIO - Ajuste para incluir a susep no orcamento
            
            List<DadosCorretor__c> lstCorretores = [SELECT Id FROM DadosCorretor__c WHERE Name = :payloadTO.orcamento.susepOrcamento];
            if(!lstCorretores.isEmpty()) orcamento.CodigoCorretor__c = lstCorretores[0].Id;
            //PLV-4199 - FIM
            orcamento.NumeroPortal__c        = payloadTO.orcamento.numeroPortal;
            orcamento.DataCalculo__c         = Date.valueOf(payloadTO.orcamento.dataCalculo);
            orcamento.TipoVigencia__c        = payloadTO.orcamento.tipoVigencia;
            orcamento.VigenciaInicial__c     = Date.valueOf(payloadTO.orcamento.vigenciaInicial);
            orcamento.VigenciaFinal__c       = Date.valueOf(payloadTO.orcamento.vigenciaFinal);
            orcamento.VigenciaFinalAlterada__c = hasVigenciaChanged(payloadTO, contratoOriginal); //PLV-4684 INICIO/FIM
            orcamento.EntradaNegocio__c      = payloadTO.orcamento.entradaNegocio;
            orcamento.StageName              = 'Em criação';
            orcamento.CloseDate              = Date.valueOf(payloadTO.orcamento.vigenciaFinal);
            //PLV-3079 INICIO
            orcamento.Consultivo__c              = payloadTO.orcamento.varConsultivo != null? payloadTO.orcamento.varConsultivo : false;
            //PLV-3079 FIM
            
            //PLV2365: INICIO
            orcamento.Type                   = payloadTO.orcamento.tipoSeguro == 'eds'? 'Endosso':payloadTO.orcamento.tipoSeguro;//PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B 
            //PLV2365: FIM
            //RVI-117/118 INICIO
            orcamento.indiceIPCA__c           = payloadTO.orcamento.IndiceIPCA;
            orcamento.ContratoRenovado__c     = payloadTO.orcamento.idContratoRenovado;
            //RVI-117/118 FIM
            orcamento.Produto__c             = produto.Id;
            orcamento.CanalDistribuicao__c   = canalDistribuicao.Id;
            system.debug('Payload: '+payloadTO);
            
            //PLV - 4442 inicio
            //PLV - 4442 - fix 1 inicio
            if(payloadTO.orcamento.segmento == 'Individual'){
                if(String.isNotBlank(payloadTO.orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.tempoGarantiaRenda))
                    orcamento.PorQuantoTempoQuerGarantirRenda__c = payloadTO.orcamento.contratantes[0].grupos[0].segurados[0].pessoa.dadosPessoaFisica.tempoGarantiaRenda;
                //PLV-4928 - FIX - INICIO
                if(String.isNotBlank(payloadTO.orcamento.contratantes[0].grupos[0].segurados[0].pessoa.nome))
                    orcamento.NomeOrcamento__c = payloadTO.orcamento.contratantes[0].grupos[0].segurados[0].pessoa.nome;
                    orcamento.Nome_Social__c = payloadTO.orcamento.contratantes[0].grupos[0].segurados[0].pessoa.nomeSocial;  // LECVPV-184 INICIO/FIM
                    System.debug('Gior -> Nome Orçamento: '+ orcamento.NomeOrcamento__c);
                    System.debug('Gior -> Nome Social: '+ orcamento.Nome_Social__c);
                //PLV-4928 - FIX - FIM
                //PLV-4928 - FIX - FIM
            }
            //PLV - 4442 - fix 1 fim
            //PLV - 4442 fim
           
            
            //PLV-4393 - Pedro Augusto Braz - Sys4b - Inicio
            orcamento.Customizavel__c = payloadTO.orcamento.customizavel!=null ? payloadTO.orcamento.customizavel : false;
            //PLV-4393 - Pedro Augusto Braz - Sys4b - Fim
            
            //PLV_2826 - INICIO - Criar oportunidade sem conta
            //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B - FIX 1		
            //PLV - 4655 INICIO
            if(String.isNotEmpty(contaId)){
                system.debug('orcamento.AccountId dentro do IF:' + contaId );
                orcamento.AccountId               = contaId;
            }
            //PLV - 4655 FIM
            //PLV - 4626 - VI - FIM - GUSTAVO PEREIRA SYS4B - FIX 1	
            //PLV_2826 - FIM - Criar oportunidade sem conta
            //--- dados precificação
            //PLV-3136 - INÍCIO
            if(retornoCalculo != null && retornoCalculo.precificacao != null)
            { 
                orcamento.Juros__c          = retornoCalculo.precificacao.juros;
                orcamento.IOF__c            = retornoCalculo.precificacao.iof;
                orcamento.Encargos__c       = retornoCalculo.precificacao.encargos;
                orcamento.CustoApolice__c   = retornoCalculo.precificacao.custoApolice;
                //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse
                if(retornoCalculo.precificacao.premio != null){
                    orcamento.PremioComercial__c= retornoCalculo.precificacao.premio.comercial;
                    orcamento.PremioPuro__c     = retornoCalculo.precificacao.premio.puro;
                    orcamento.PremioTotal__c    = retornoCalculo.precificacao.premio.total;
                }
                //PLV-3317 - FIM
                //PLV-3141 - INICIO - Seguro Viagem - Atualização do serviço de criação de orçamento
                //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse
                if(retornoCalculo.precificacao.taxa != null){
                    orcamento.TaxaPura__c       = retornoCalculo.precificacao.taxa.pura;
                    orcamento.TaxaComercial__c  = retornoCalculo.precificacao.taxa.comercial;
                    orcamento.TaxaTotal__c      = retornoCalculo.precificacao.taxa.total;
                }
                //PLV-3317 - FIM
                //PLV-3141 - FIM - Seguro Viagem - Atualização do serviço de criação de orçamento


                //PLV-5676- INICIO
                if(tipoSeguro.contains(payloadTO.orcamento.tipoSeguro)){
                    if(payloadTO.orcamento.contratoOriginal.precificacao != null){
                        for(EmissaoTO.DescontoAgravoTO descontoAgravo : payloadTO.orcamento.contratoOriginal.precificacao.descontoAgravo){
                            if(descontoAgravo.tipo == 'TEC'){
                                this.fillFieldsDescAgr(orcamento, descontoAgravo);
                            }
                        }
                        
                        for(EmissaoTO.DescontoAgravoTO descontoAgravo : retornoCalculo.precificacao.descontoAgravo){
                            if(retornoCalculo.precificacao.descontoAgravo != null) {
                                if(descontoAgravo.tipo == 'FPG') {
                                    orcamento.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                                    orcamento.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
                                }
                            }
                        }
                    }
                //PLV-5676-FIM
                }else if(retornoCalculo.precificacao.descontoAgravo != null) { //PLV-5676 - INICIO/FIM
                    //II-54 FIX01 INICIO
                    String IdCtrOrgiginal = payloadTO.orcamento.idContratoRenovado;
                    List<Contract> contratoOrig = [SELECT Id, DescontoAgravoPercentualTecnico__c FROM Contract WHERE Id =: IdCtrOrgiginal];
                    System.debug('contratoOriginal >>>> ' + contratoOriginal);
                    System.debug('contratoOrig >>>> ' + contratoOrig);
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : retornoCalculo.precificacao.descontoAgravo) {
                        if(descontoAgravo.tipo == 'TEC') {
                            if(payloadTO.orcamento.tipoSeguro == 'Renovacao'){
                                System.debug('ENTROU NO TIPO TEC Renovação Objeto Orcamento');
                                orcamento.DescontoAgravoPercentualTecnico__c = contratoOrig[0].DescontoAgravoPercentualTecnico__c;
                                orcamento.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                                System.debug('orcamento.DescontoAgravoPercentualTecnico__c TESTE RENOVA ' + orcamento.DescontoAgravoPercentualTecnico__c);
                            }else{
                                System.debug('ENTROU NO TIPO TEC NOVO');
                                System.debug('descontoAgravo.percentual NOVO: ' + descontoAgravo.percentual);
                                orcamento.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                                orcamento.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                            }
                            // System.debug('ENTROU NO TIPO TEC ');
                            // System.debug('descontoAgravo.percentual: ' + descontoAgravo.percentual);
                            // orcamento.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            // orcamento.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        } //II-54 FIX01 FIM
                        else if(descontoAgravo.tipo == 'COM') {
                            orcamento.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                            orcamento.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                        }
                        else if(descontoAgravo.tipo == 'BAT') {
                            orcamento.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                            orcamento.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                        }
                        //PLV-2146 - INÍCIO
                        else if(descontoAgravo.tipo == 'FPG') {
                            orcamento.DescontoAgravoPercentualFormaPagto__c = descontoAgravo.percentual;
                            orcamento.DescontoAgravoMonetarioFormaPagto__c = descontoAgravo.monetario;
                        }
                        else if(descontoAgravo.tipo == 'TPR') {
                            orcamento.DescontoAgravoPercentualParcelamento__c = descontoAgravo.percentual;
                            orcamento.DescontoAgravoMonetarioParcelamento__c = descontoAgravo.monetario;
                        }
                        //PLV-2146 - FIM
                    }
                }
                //PLV-3317 - INICIO - Ajuste para atender as necessidades do sinapse
                Map<String, EmissaoTO.coberturaTO> mapCalculos = new Map<String, EmissaoTO.coberturaTO>();
                for(EmissaoTO.coberturaTO cobertura : retornoCalculo.precificacao.coberturas){
                    mapCalculos.put(cobertura.sigla,cobertura);
                }
                //PLV-3317 - FIM

                // PLV-4598 - INICIO
                List<String> codFranquiasOrcamento = new List<String>();
                for(EmissaoTO.coberturaTO cobertura : mapCoberturas.values()) {
                    if(cobertura.franquia != null) codFranquiasOrcamento.add(cobertura.franquia);
                }
                
                List<String> lstIdsGarantiaProd = new List<String>();
                for(String key :mGarantiaProd.keySet()) lstIdsGarantiaProd.add(mGarantiaProd.get(key).id);


                List<FranquiaGarantia__c> lstFranquiasGarantias = Test.isRunningTest() ? new List<FranquiaGarantia__c>() : this.getListGarantia(codFranquiasOrcamento, lstIdsGarantiaProd);

                for(FranquiaGarantia__c fqr : lstFranquiasGarantias) mpFranquiaProdIds.put(fqr.Franquia__r.CodigoFranquia__c, fqr.id);
                System.debug('Rogerio mpFranquiaProdIds: '+ mpFranquiaProdIds);
                // PLV-4598 - FIM

                //PLV2365: INICIO
                //FIM - PLV-VI-4865 - Guilherme Brito

                //PLV-3317 - INICIO - Ajuste para atender as necessidades do sinapse
                for(EmissaoTO.coberturaTO cobertura : mapCoberturas.values())
                {
                    GarantiaOrcamento__c garatiaOrc = new GarantiaOrcamento__c();
                    //PLV-2607- Inicio
                    //PLV-2932 Fix2 - Inicio - Adição de parametro para cobertura da logica 
                    montarCoberturaOrcamento(cobertura, garatiaOrc, setSiglasCoberturas, mGarantiaProd, mapCalculos, payloadTO);//PLV-5676-INICIO/FIM
                    //PLV-2932 Fix2 - Fim - Adição de parametro para cobertura da logica 
                    
                    if(garatiaOrc.Garantia__c != null)      
                        //PLV-2607- Fim              
                        garantiaOrcamentoList.add(garatiaOrc);
                }
                //PLV-3317 - FIM
                //PLV2365: FIM
                
            }
            //PLV-3141 - INICIO - Seguro Viagem - Atualização do serviço de criação de orçamento
            if(payloadTO.orcamento.viagem != null){
                System.debug('payloadTO ' + payloadTO);
                System.debug('payloadTO.orcamento ' + payloadTO.orcamento);
                
                List<String> listaDestinos = new List<String>();
                
                orcamento.VigenciaInicial__c = date.valueOf(payloadTO.orcamento.vigenciaInicial);
                orcamento.VigenciaFinal__c = date.valueOf(payloadTO.orcamento.vigenciaFinal);
                orcamento.QuantidadeDias__c = date.valueOf(payloadTO.orcamento.vigenciaInicial).daysbetween(date.valueOf(payloadTO.orcamento.vigenciaFinal)) + 1; //PLV-4829 INICIO/FIM
                orcamento.TipoViagem__c = payloadTO.orcamento.viagem.tipoViagem;
                orcamento.ViagemAventura__c = Boolean.valueOf(payloadTO.orcamento.viagem.praticaEsportesAventura);
                //Existe uma pendencia em relação a tag incluiPaisSchengen. Com isso, a linha abaixo permanecerá comentada
                //e a flag correspondente permanecerá sem ser preenchida na tela até orientação em contrário.
                //orcamento.IncluiPaisEuropeu__c = Boolean.valueOf(payloadTO.orcamento.viagem.incluiPaisSchengen);
                orcamento.UtilizaMoto__c = Boolean.valueOf(payloadTO.orcamento.viagem.utilizaraMotocicleta);
                orcamento.NomeOrcamento__c = payloadTO.orcamento.viagem.nomePrincipal; // PLV-4928 - FIX - INICIO/FIM
                orcamento.Nome_Social__c = payloadTO.orcamento.viagem.nomeSocial;  // LECVPV-184 INICIO/FIM
                System.debug('Gior -> Nome Orçamento: '+ orcamento.NomeOrcamento__c);
                System.debug('Gior -> Nome Social: '+ orcamento.Nome_Social__c);
                
                for(EmissaoTO.ContratanteTO contratante : payloadTO.orcamento.contratantes){
                    
                    for(EmissaoTO.GrupoTO grupo : contratante.grupos){
                        
                        if(grupo.numero == '1'){                        
                            orcamento.QuantidadePassageiros070Anos__c  = grupo.qtdeVidas;
                        }else{                        
                            orcamento.VidasEntre7190Anos__c  = grupo.qtdeVidas;
                        }
                    }
                }            
                for(EmissaoTO.DestinoTO destino : payloadTO.orcamento.viagem.destinos){                
                    listaDestinos.add(destino.pais);
                } 
                orcamento.PaisesDestino__c = String.join(listaDestinos, ';');
            }
            //PLV-3141 - FIM - Seguro Viagem - Atualização do serviço de criação de orçamento
            
            //PLV-3136 - FIM
            system.debug('ORCAMENTO DEBUG: '+ orcamento);
            
            //PLV-2589 - Inicio
            upsert orcamento Numero__c;
            //PLV-2589 - Fim
            
            //PLV-2439 - INICIO
            //gerarCriticasODMOrcamento(payloadTO.retornoAceitacao, orcamento.id); //PLV-4693 INICIO/FIM
            //PLV-2439 - FIM
            
            //PLV-3731 - INICIO
            Map<String,EmissaoTO.ItensCotacaoTO> mapCotacao = new Map<String,EmissaoTO.ItensCotacaoTO>();
            Set<Id> idGarantiaProduto = new Set<Id>();
            Map<Id,GarantiaProduto__c> mpGarantiaProdutoCotacao = new Map<Id,GarantiaProduto__c>();
            
            if(payloadTO.retornoIntegracoes.IndiceMonetario != null){
                for(EmissaoTO.ItensCotacaoTO itenCotacao : payloadTO.retornoIntegracoes.IndiceMonetario.ItensCotacao){
                    mapCotacao.put(itenCotacao.moedaOrigem,itenCotacao);
                }
                
                for(GarantiaOrcamento__c gp : garantiaOrcamentoList){
                    idGarantiaProduto.add(gp.GarantiaProduto__c);
                }
                
                if(idGarantiaProduto.size() > 0){
                    List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                    
                    for(GarantiaProduto__c g : garantiasP){
                        mpGarantiaProdutoCotacao.put(g.Id,g);
                    }
                    
                }
                system.debug('cotacao map garantia'+mpGarantiaProdutoCotacao);
                system.debug('cotacao id'+IdGarantiaProduto);
                
            }        	
            //PLV-3731 -  FIM
            
            //---- grava garantia do orçamento
            //PLV2365: INICIO
            for(GarantiaOrcamento__c garantia : garantiaOrcamentoList)
            {
                garantia.Orcamento__c = orcamento.Id;  
                //PLV-3731 - INICIO
                if(mpGarantiaProdutoCotacao.containsKey(garantia.GarantiaProduto__c)){
                    if(mapCotacao.containsKey(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode)){
                        garantia.ValorCotacao__c = mapCotacao.get(mpGarantiaProdutoCotacao.get(garantia.GarantiaProduto__c).CurrencyIsoCode).cotacao;
                    }
                }
                //PLV-3731 - FIM
                
            }
            
            insert garantiaOrcamentoList;
            //PLV2365: FIM
            
            //PLV-4693 INICIO
            if (String.isBlank(orcamento.RamoOrcamento__c) && garantiaOrcamentoList.size() > 0) {

                if (mpGarantiaProdutoCotacao.values().size() == 0) {
                    for(GarantiaOrcamento__c gp : garantiaOrcamentoList){
                        idGarantiaProduto.add(gp.GarantiaProduto__c);
                    }
                    
                    if(idGarantiaProduto.size() > 0){
                        List<GarantiaProduto__c> garantiasP = GarantiaProdutoDAO.getInstance().buscarGarantiasPorId(idGarantiaProduto);
                        
                        for(GarantiaProduto__c g : garantiasP){
                            mpGarantiaProdutoCotacao.put(g.Id,g);
                        }
                    }
                }

                orcamento.RamoOrcamento__c = getRamoOrcamento(mpGarantiaProdutoCotacao);
                update orcamento;
            }
            
            gerarCriticasODMOrcamento(payloadTO.retornoAceitacao, orcamento.id);
            //PLV-4693 FIM

            //--- cria número do orçamento
            if(payloadTO.orcamento.numeroOrcamento == null)
            {
                orcamento = daoOpportunity.buscarOportunidadesPorId(new Set<Id>{orcamento.Id})[0];
                
                String numeroOrcamento = 'ORC-' + orcamento.ContadorOrcamento__c;
                
                orcamento.Name      = numeroOrcamento; 
                orcamento.Numero__c = numeroOrcamento;
                
                update orcamento;
                
                System.debug('Id:' + orcamento.Id);
                System.debug('Id:' + numeroOrcamento);
            }
            
            //PLV-3649 - INICIO/FIM - Código Removido
            if(this.gerarArquivo) FileController.createTextFile(orcamento.Name + '_' + Datetime.now().format('dd-MM-yyyy_HH:mm:ss'), JSON.serialize(payloadTO), orcamento.Id, '.min.json');
            
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        // PLV-2327 - FIM
        return orcamento;
        
    }
    //PLV2365: FIM

    //PLV-4684 INICIO
    private Boolean hasVigenciaChanged(EmissaoTO.OfertasTO payloadTO, Contract contratoOriginal) {
        Boolean result = false;
        
        //É Endosso
        if (payloadTO != null && payloadTO.orcamento != null 
            && 'eds'.equalsIgnoreCase(payLoadTO.orcamento.tipoSeguro) && contratoOriginal != null) {

            //Verifica se o contratoOriginal já teve a vigenciaFinal alterada após o inicio da vigência
            if (contratoOriginal.VigenciaFinalAlterada__c != null && contratoOriginal.VigenciaFinalAlterada__c) {
                result = true;
            }
            //Senão, valida se o atual teve alteração
            else if (payloadTO.orcamento.vigenciaInicial != null && payloadTO.orcamento.vigenciaFinal != null 
                && contratoOriginal.VigenciaFinal__c != null) {

                Date vigenciaInicial = Date.valueOf(payloadTO.orcamento.vigenciaInicial);
                Date vigenciaFinal = Date.valueOf(payloadTO.orcamento.vigenciaFinal);

                //Se já iniciou a vigência e a data de vigência final foi alterada
                if (Date.today() >= vigenciaInicial && vigenciaFinal != contratoOriginal.VigenciaFinal__c) {
                    result = true;
                }
            }
        }
        
        System.debug('OrcamentoGenericoBuilder => hasVigenciaChanged => result => ' + result);
        
        return result;
    }
    //PLV-4684 FIM
    
    //PLV-4693 INICIO
    @TestVisible
    private String getRamoOrcamento(Map<Id,GarantiaProduto__c> mpGarantiaProdutoCotacao) {
        System.debug('OrcamentoGenericoBuilder :: getRamoOrcamento :: mpGarantiaProdutoCotacao => ' + mpGarantiaProdutoCotacao);
        String codigoRamo = '';
        Decimal prioridade = 9999999;

        for (GarantiaProduto__c garantiaProduto : mpGarantiaProdutoCotacao.values()) {

            if (garantiaProduto.OrdemPrioridade__c < prioridade) {
                prioridade = garantiaProduto.OrdemPrioridade__c;
    
                if (garantiaProduto.RamoSeguro__r != null) {
                    codigoRamo = garantiaProduto.RamoSeguro__r.Codigo__c;
                }
            }
        }

        System.debug('OrcamentoGenericoBuilder :: getRamoOrcamento ::  codigoRamo :' + codigoRamo);
        return codigoRamo;
    }
    //PLV-4693 FIM

    // PLV-4598 INICIO
    @TestVisible
    private List<FranquiaGarantia__c> getListGarantia(List<String> codFranquiasOrcamento, List<String> lstIdsGarantiaProd){

        return [ SELECT ID, Franquia__r.CodigoFranquia__c FROM FranquiaGarantia__c
            WHERE Franquia__r.CodigoFranquia__c IN: codFranquiasOrcamento AND GarantiaProduto__c IN: lstIdsGarantiaProd
        ] ;
    }
    // PLV-4598 FIM

    //PLV2365: INICIO
    private String buscarChaveContratantePrincipal(Map<String, ContratanteOrcamento__c> mapContratante)
    {
        String retorno;
        
        ContratanteOrcamento__c contratante = new ContratanteOrcamento__c();
        
        for (String key : mapContratante.keySet())
        {
            contratante = mapContratante.get(key);
            
            if(contratante.tipo__C == 'Principal')
            {
                retorno = key;
                break;
            }
        }
        
        return retorno;
    }
    //PLV2365: FIM
    
    
    private void montarContratante(EmissaoTO.ContratanteTO contratanteEnt, ContratanteOrcamento__c contratanteObj)
    {
        contratanteObj.Tipo__c = contratanteEnt.tipo == 'PRI' ? 'Principal' : 'Dependente';
    } 
    
    private void montarGrupo(EmissaoTO.GrupoTO grupoEnt, GrupoOrcamento__c grupoObj)
    {
        grupoObj.Numero__c          = Integer.valueOf(grupoEnt.numero);
        system.debug('NUMERO DE GRUPO DEU CERTO');
        grupoObj.Name               = grupoEnt.nome;
        grupoObj.QuantidadeVidas__c = grupoEnt.qtdeVidas; //PLV-2666 - Alterado nome de variável
        grupoObj.IOF__c             = grupoEnt.iof!=null ? grupoEnt.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
    } 
    
    private void montarSegurado(EmissaoTO.SeguradoTO seguradoEnt, SeguradoOrcamento__c seguradoObj)
    {
        system.debug('seguradoEnt: '+seguradoEnt);
        seguradoObj.Numero__c        = Decimal.valueOf(seguradoEnt.numero);
        //PLV-4071 - INICIO - PEDRO AUGUSTO - SYS4B
        if(String.isNotBlank(seguradoEnt.pessoa.dadosPessoaFisica.profissao)){
            Profissao__c prof = new Profissao__c(Codigo__c=seguradoEnt.pessoa.dadosPessoaFisica.profissao);
            seguradoObj.Profissao__r=prof;
        }
        //PLV-4071 - FIM - PEDRO AUGUSTO - SYS4B
        
        
        //PLV-4442 - INCIO
        if(seguradoEnt.pessoa.dadosPessoaFisica.fumante != null) 
            seguradoObj.Fumante__c = seguradoEnt.pessoa.dadosPessoaFisica.fumante;
        if(String.isNotBlank(seguradoEnt.pessoa.dadosPessoaFisica.renda))
            seguradoObj.FaixaRenda__c = seguradoEnt.pessoa.dadosPessoaFisica.renda;
        if(String.isNotBlank(seguradoEnt.pessoa.dadosPessoaFisica.regimeTrabalho))
            seguradoObj.RegimeTrabalho__c = seguradoEnt.pessoa.dadosPessoaFisica.regimeTrabalho; 
        if(seguradoEnt.pessoa.dadosPessoaFisica.temDependentes != null) 
            seguradoObj.TemDependentes__c = seguradoEnt.pessoa.dadosPessoaFisica.temDependentes;
        //PLV-4442 - FIM
        //PLV-4655 fix 1 - INICIO
        if(String.isNotBlank(String.ValueOf(seguradoEnt.pessoa.rendaMensal)))
        seguradoObj.FaixaRenda__c = String.ValueOf(Integer.ValueOf(seguradoEnt.pessoa.rendaMensal));

        //PLV-5124 INICIO
        List<String> dominioCicloVacinal = new List<String>{'0', '1', '2'};
        String cicloVacinalSegurado = seguradoEnt.pessoa.dadosPessoaFisica.CicloVacinal;
        seguradoObj.CicloVacinal__c = dominioCicloVacinal.contains(cicloVacinalSegurado) ? cicloVacinalSegurado: null ;
        //PLV-5124 FIM 
        //PLV-4655 fix 1 - FIM

    } 
    
    //PLV2365: INICIO
    private Account montarSeguradoPessoa(EmissaoTO.PessoaTO pessoaEnt)
    {
        Account parametro = new Account();
        
        system.debug('pessoaEnt.dadosPessoaFisica.numeroCpf: ' + pessoaEnt.dadosPessoaFisica.numeroCpf);
        system.debug('pessoaEnt.dadosPessoaFisica.digitoCpf: ' + pessoaEnt.dadosPessoaFisica.digitoCpf);
        system.debug('CONCATENADO: ' + pessoaEnt.dadosPessoaFisica.numeroCpf + pessoaEnt.dadosPessoaFisica.digitoCpf);
        
        if (pessoaEnt.tipo == 'FIS')
        {
            parametro =  contaBO.preencherDadosContaPessoaFisica(
                null,
                pessoaEnt.nome,
                pessoaEnt.email,
                pessoaEnt.dadosPessoaFisica.numeroCpf + pessoaEnt.dadosPessoaFisica.digitoCpf,
                null,
                null,
                null,
                Date.valueOf(pessoaEnt.dadosPessoaFisica.dataNascimento),
                contaBO.buscarEstadoCivil(pessoaEnt.dadosPessoaFisica.estadoCivil),
                null,
                pessoaEnt.dadosPessoaFisica.profissao,
                pessoaEnt.dadosPessoaFisica.sexo,
                //PLV-2720 - Inicio - Adição de parâmetro
                //PLV-5231 INICIO
                pessoaEnt.dadosPessoaFisica.fumante,
                null 
                //PLV-5231 FIM
                //PLV-2720 - Fim - Adição de parâmetro
            );
            
        }
        else
        {
            //                parametro =  contaBO.preencherDadosContaPessoaJuridica();
            
        }
        
        return parametro;
    } 
    //PLV2365: FIM
    
    private List<Endereco__c> montarSeguradoPessoaEndereco(EmissaoTO.PessoaTO pessoaEnt)
    {
        List<Endereco__c> parametro = new List<Endereco__c>();
        
        if (pessoaEnt.tipo == 'FIS')
        {
            parametro = contaBO.gerarEnderecoContaEmissao(pessoaEnt.enderecos);
            //PLV- 2727 - Inicio
            if (parametro.isEmpty() || parametro == null) return null;
            //PLV- 2727 - Fim
            for(Endereco__c endereco : parametro)
            {
                endereco.TipoEndereco__c    = contaBO.buscarTipoEndereco(endereco.TipoEndereco__c);
                endereco.TipoLogradouro__c  = contaBO.buscarTipoLogradouro(endereco.TipoLogradouro__c);
            }
        } 
        
        return parametro;
        
    } 
    
    //PLV-2607- Inicio
    private void montarCobertura(EmissaoTO.CoberturaTO coberturaEnt, GarantiaSeguradoOrcamento__c coberturaObj, Set<String> setSiglasCoberturas)
    {
        system.debug('teste montagem garantia');
        if(!setSiglasCoberturas.contains(coberturaEnt.sigla)) return;
        system.debug('setSiglasCoberturas'+setSiglasCoberturas);
        system.debug('coberturaEnt.sigla'+coberturaEnt.sigla);
        //PLV-2607- Fim
        coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);
        if(coberturaEnt.valor != null) 
            coberturaObj.valor__c = coberturaEnt.valor;
        if(coberturaEnt.percentual != null) 
            coberturaObj.percentual__c = coberturaEnt.percentual;
        //        if(coberturaEnt.garantiaReferenciada != null) 
        //            coberturaObj.garantiaReferenciada__c = coberturaEnt.garantiaReferenciada;
        
    }
    
    @TestVisible //ANNVI-55 - INICIO/FIM
    private void montarCobertura(EmissaoTO.CoberturaTO coberturaEnt, GarantiaGrupoOrcamento__c coberturaObj, Set<String> setSiglasCoberturas)
    {
        if(!setSiglasCoberturas.contains(coberturaEnt.sigla)) return;
        //PLV-2607- Fim
        coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);
        if(coberturaEnt.valor != null) 
            coberturaObj.valor__c = coberturaEnt.valor;
        if(coberturaEnt.percentual != null) 
            coberturaObj.percentual__c = coberturaEnt.percentual;

        coberturaObj.IOF__c = coberturaEnt.iof!=null ? coberturaEnt.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
        
        //        if(coberturaEnt.garantiaReferenciada != null) 
        //            coberturaObj.garantiaReferenciada__c = coberturaEnt.garantiaReferenciada;
    }  
    //PLV2365: INICIO
    //PLV-2607- Inicio
    //PLV-2932 Fix2 - Inicio - Adição de parametro para cobertura da logica 
    //PLV-3317 - INICIO - Ajuste na logica para pegar todas as coberturas e capitais
    
    //PLV-3884 - INICIO - Mapa de objeto de garantia do produto para seleção de moeda
    @TestVisible//ANNVI-55 - INICIO/FIM
    private void montarCoberturaOrcamento(EmissaoTO.CoberturaTO coberturaEnt, GarantiaOrcamento__c coberturaObj, Set<String> setSiglasCoberturas, Map<String, GarantiaProduto__c> mGarantiaProd, Map<String, EmissaoTO.coberturaTO> mapCalculos, EmissaoTO.OfertasTO payloadTO){
       
        system.debug('===> payloadTO' + JSON.serialize(payloadTO));

        EmissaoTO orcamento = payloadTO.orcamento;//PLV-5676 - INICIO/FIM 
        System.debug('===> orcamento: ' + orcamento);

        // PLV-4598 - INICIO
        if(coberturaEnt.franquia != null) coberturaObj.FranquiaGarantia__c = mpFranquiaProdIds.get(coberturaEnt.franquia);
        System.debug('Rogerio coberturaObj.FranquiaGarantia__c '+ coberturaObj.FranquiaGarantia__c);
        // PLV-4598 - FIM


        if(mapCalculos.containsKey(coberturaEnt.sigla)){
            EmissaoTO.coberturaTO calculo = new EmissaoTO.coberturaTO();
            if(!setSiglasCoberturas.contains(coberturaEnt.sigla)) return;
            //PLV-2607- Fim
            calculo = mapCalculos.get(coberturaEnt.sigla);
            if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mGarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
                system.debug('mGarantiaProd: '+ mGarantiaProd);
            }
            system.debug('calculo: '+ calculo);

            //PLV-2932 Fix2 - Fim - Adição de parametro para cobertura da logica
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);
            system.debug('coberturaEnt.sigla: '+ coberturaEnt.sigla);
            system.debug('coberturaEnt >>> '+ coberturaEnt);
            system.debug('==> coberturaObj '+ JSON.serialize(coberturaObj));

            coberturaObj.Capital__c         = coberturaEnt.valor;
            //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse

            //PLV-4620 FIX 2 INICIO
            //PLV-4620 FIX3 INICIO
            //PLV-5747 INICIO
            //II-74 INICIO
            if(coberturaEnt.caracteristicaespecialvalor != null){
                coberturaObj.Limite_de_Uso__c         			= coberturaEnt.caracteristicaespecialvalor;
            }else if(coberturaEnt.sigla == 'DIA'){
                coberturaObj.Limite_de_Uso__c = Decimal.valueOf(coberturaEnt.quantidade);
            }else{
                coberturaObj.Limite_de_Uso__c = 0;
            }
            //II-74 FIM

            if(coberturaEnt.caracteristicaespecialtipo != null){
                coberturaObj.Tipo_de_limite_de_utilizacao__c = coberturaEnt.caracteristicaespecialtipo;         
            }else{
                coberturaObj.Tipo_de_limite_de_utilizacao__c = 'Monetário';
            }
            //PLV-5747 FIM
            system.debug('==> coberturaObj depois '+ JSON.serialize(coberturaObj));
            //coberturaObj.Tipo_de_limite_de_utilizacao__c = 'Dias';
            //PLV-4620 FIX3 FIM
            //PLV-4620 FIX 2 FIM
            coberturaObj.IOF__c = calculo.iof!=null ? calculo.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            if(calculo.premio != null){
                coberturaObj.PremioComercial__c = calculo.premio.comercial;
                coberturaObj.PremioPuro__c      = calculo.premio.puro;
                coberturaObj.PremioTotal__c     = calculo.premio.total;
            }
            if(calculo.taxa != null){
                coberturaObj.TaxaComercial__c   = calculo.taxa.comercial;
                coberturaObj.TaxaPura__c        = calculo.taxa.pura;
                coberturaObj.TaxaTotal__c       = calculo.taxa.total;
            }
            //PLV-3317 - FIM
             //PLV-5676- INICIO
            if(tipoSeguro.contains(orcamento.tipoSeguro) && orcamento.contratoOriginal.precificacao != null){

                descontoMap = getDescontosMap(orcamento.contratoOriginal.precificacao.coberturas);

                coberturaObj.DescontoAgravoPercentualTecnico__c = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.percentual;
                coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.monetario;

            //PLV-2146 - INÍCIO
            }else if(calculo.descontoAgravo != null) {//PLV - 5676 - INICIO/FIM
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : calculo.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        coberturaObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        coberturaObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        coberturaObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }
            //PLV-2146 - FIM
        } else {
            if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mGarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
            }
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);
            coberturaObj.Capital__c         = coberturaEnt.valor;
            coberturaObj.Limite_de_Uso__c = 0; //PLV-5674 - INICIO/FIM
        }  
    } 
    //PLV-3884 - FIM - Mapa de objeto de garantia do produto para seleção de moeda
    
    //PLV2365: FIM
    //PLV-3317 - FIM - Ajuste na logica para pegar todas as coberturas e capitais

    //PLV-5676- INICIO
    public static Map<String, Map<String, EmissaoTo.DescontoAgravoTO>> getDescontosMap(List<EmissaoTO.CoberturaTO> coberturas){
        Map<String, Map<String, EmissaoTo.DescontoAgravoTO>> descontoMap = new Map<String, Map<String, EmissaoTo.DescontoAgravoTO>>();
        
        for(EmissaoTO.CoberturaTO cobertura :  coberturas){

            if(!descontoMap.containsKey(cobertura.sigla))
                descontoMap.put(cobertura.sigla, new Map<String, EmissaoTo.DescontoAgravoTO>());

            for(EmissaoTo.DescontoAgravoTO desconto : cobertura.descontoAgravo)
                descontoMap.get(cobertura.sigla).put(desconto.tipo, desconto);

        }

        return descontoMap;
    }
    //PLV-5676- FIM

    //PLV-2607- Inicio
    //PLV-3317 - INICIO - Ajuste na logica para pegar todas as coberturas e capitais
    @TestVisible //ANNVI-55 - INICIO/FIM
    private void montarCoberturaContratante(EmissaoTO.CoberturaTO coberturaEnt, GarantiaContratanteOrcamento__c coberturaObj, Set<String> setSiglasCoberturas, Map<String, EmissaoTO.coberturaTO> mapCalculos, EmissaoTO.OfertasTO payloadTO)
    {

        system.debug('===> payloadTO' + JSON.serialize(payloadTO));

        EmissaoTO orcamento = payloadTO.orcamento;//PLV-5676 - INICIO/FIM 
        System.debug('===> orcamento: ' + orcamento);

        if(mapCalculos.containsKey(coberturaEnt.sigla)){
            EmissaoTO.coberturaTO calculo = new EmissaoTO.coberturaTO();
            if(!setSiglasCoberturas.contains(coberturaEnt.sigla)) return;
            calculo = mapCalculos.get(coberturaEnt.sigla);
            //PLV-2607- Fim
            system.debug('SIGLA DA COBERTURA '+ coberturaEnt.sigla);
            system.debug('MAP DAS GARANTIAS '+ mGarantiaProd);
            //if(mapGarantias.containsKey(coberturaEnt.sigla))
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);
            
            coberturaObj.Capital__c         = coberturaEnt.valor;
            //PLV-3285 - INICIO - Ajuste para preencher a garantia do produto
            if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                //PLV-3884 - INICIO - Mapa de objeto de garantia do produto para seleção de moeda
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mGarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
                //PLV-3884 - FIM - Mapa de objeto de garantia do produto para seleção de moeda
            }
            //PLV-3285 - FIM
            // IOF ??
            //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse
            coberturaObj.IOF__c = calculo.iof!=null ? calculo.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            if(calculo.premio != null){
                coberturaObj.PremioComercial__c = calculo.premio.comercial;
                coberturaObj.PremioPuro__c      = calculo.premio.puro;
                coberturaObj.PremioTotal__c     = calculo.premio.total;
            }
            if(calculo.taxa != null){
                coberturaObj.TaxaComercial__c   = calculo.taxa.comercial;
                coberturaObj.TaxaPura__c        = calculo.taxa.pura;
                coberturaObj.TaxaTotal__c       = calculo.taxa.total;
            }
            //PLV-3317 - FIM
            
            //PLV-5676 - INICIO
            if(tipoSeguro.contains(orcamento.tipoSeguro) && orcamento.contratoOriginal.precificacao != null){
                descontoMap = getDescontosMap(orcamento.contratoOriginal.precificacao.coberturas);
           
                coberturaObj.DescontoAgravoPercentualTecnico__c = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.percentual;
                coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.monetario;

            //PLV-2146 - INÍCIO
            }else if(calculo.descontoAgravo != null) {//PLV-5676 - FIM
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : calculo.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        coberturaObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        coberturaObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        coberturaObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }
        }else {
            //PLV-3285 - INICIO - Ajuste para preencher a garantia do produto
            if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                //PLV-3884 - INICIO - Mapa de objeto de garantia do produto para seleção de moeda
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mgarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
                //PLV-3884 - FIM - Mapa de objeto de garantia do produto para seleção de moeda
            }
            //PLV-3285 - FIM
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);
            coberturaObj.Capital__c         = coberturaEnt.valor;
        }
        //PLV-2146 - FIM
    } 
    //PLV-3317 - FIM - Ajuste na logica para pegar todas as coberturas e capitais
    //PLV-2607- Inicio
    //PLV-3317 - INICIO - Ajuste na logica para pegar todas as coberturas e capitais
    @TestVisible //ANNVI-55 - INICIO/FIM
    private void montarCoberturaGrupo(EmissaoTO.CoberturaTO coberturaEnt, GarantiaGrupoOrcamento__c coberturaObj, Set<String> setSiglasCoberturas, Map<String, EmissaoTO.coberturaTO> mapCalculos, EmissaoTO.OfertasTO payloadTO)
    {

        system.debug('===> payloadTO' + JSON.serialize(payloadTO));


        EmissaoTO orcamento = payloadTO.orcamento;//PLV-5676 - INICIO/FIM 
        System.debug('===> orcamento: ' + orcamento);

        if(mapCalculos.containsKey(coberturaEnt.sigla)){
            EmissaoTO.coberturaTO calculo = new EmissaoTO.coberturaTO();
            if(!setSiglasCoberturas.contains(coberturaEnt.sigla)) return;
            //PLV-2607- Fim
            calculo = mapCalculos.get(coberturaEnt.sigla);
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);   
            coberturaObj.Capital__c         = coberturaEnt.valor;
            //PLV-3285 - INICIO - Ajuste para preencher a garantia do produto
            if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                //PLV-3884 - INICIO - Mapa de objeto de garantia do produto para seleção de moeda
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mGarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
                //PLV-3884 - FIM - Mapa de objeto de garantia do produto para seleção de moeda
            }
            //PLV-3285 - FIM
            // IOF ??
            coberturaObj.IOF__c = calculo.iof!=null ? calculo.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            if(calculo.premio != null){
                coberturaObj.PremioComercial__c = calculo.premio.comercial;
                coberturaObj.PremioPuro__c      = calculo.premio.puro;
                coberturaObj.PremioTotal__c     = calculo.premio.total;
            }
            if(calculo.taxa != null){
                coberturaObj.TaxaComercial__c   = calculo.taxa.comercial;
                coberturaObj.TaxaPura__c        = calculo.taxa.pura;
                coberturaObj.TaxaTotal__c       = calculo.taxa.total;
            }
            //PLV-5676 - INICIO
            if(tipoSeguro.contains(orcamento.tipoSeguro) && orcamento.contratoOriginal.precificacao != null){
                descontoMap = getDescontosMap(orcamento.contratoOriginal.precificacao.coberturas);

                coberturaObj.DescontoAgravoPercentualTecnico__c = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.percentual;
                coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.monetario;

            //PLV-2146 - INÍCIO
            }else if(calculo.descontoAgravo != null) {//PLV-5676 - FIM
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : calculo.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        coberturaObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        coberturaObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        coberturaObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }
            //PLV-2146 - FIM
            system.debug('COBERTURA INSERIDA '+ coberturaObj);
        }else{
            //PLV-3285 - INICIO - Ajuste para preencher a garantia do produto
            if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                //PLV-3884 - INICIO - Mapa de objeto de garantia do produto para seleção de moeda
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mGarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
                //PLV-3884 - FIM - Mapa de objeto de garantia do produto para seleção de moeda
            }
            //PLV-3285 - FIM
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);   
            coberturaObj.Capital__c         = coberturaEnt.valor;
        }
    } 
    //PLV-3317 - FIM - Ajuste na logica para pegar todas as coberturas e capitais
    //PLV-2607- Inicio
    //PLV-4620 - INICIO
    @TestVisible //ANNVI-55 - INICIO/FIM
    private void montarCoberturaSegurado(EmissaoTO.CoberturaTO coberturaEnt, GarantiaSeguradoOrcamento__c coberturaObj, Set<String> setSiglasCoberturas, Map<String, EmissaoTO.coberturaTO> mapCalculos, EmissaoTO.OfertasTO payloadTO)
    {

        system.debug('===> payloadTO' + JSON.serialize(payloadTO));

        EmissaoTO orcamento = payloadTO.orcamento;//PLV-5676 - INICIO/FIM 
        System.debug('===> orcamento: ' + orcamento);

        system.debug('setSiglasCoberturas: '+setSiglasCoberturas);
        system.debug(' teste123 coberturaEnt: '+coberturaEnt);
        system.debug('coberturaEnt.sigla: '+coberturaEnt.sigla);
        system.debug('coberturaEnt.quantidade: '+coberturaEnt.quantidade);
        system.debug('coberturaEnt >>> '+coberturaEnt);
        system.debug('teste coberturaEnt.capital'+coberturaEnt.valor);
        system.debug('teste calculomap'+mapCalculos);
        if(mapCalculos.containsKey(coberturaEnt.sigla)){
            if(!setSiglasCoberturas.contains(coberturaEnt.sigla)) return;
       
            system.debug('passou do IF contains');
            EmissaoTO.coberturaTO calculo = new EmissaoTO.coberturaTO();
            calculo = mapCalculos.get(coberturaEnt.sigla);
            system.debug('teste coberturaEnt.sigla'+coberturaEnt.sigla);
            system.debug('teste valor calculo'+calculo);
            //PLV-2607- Fim
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);
            coberturaObj.Capital__c         = coberturaEnt.valor;
            
            //PLV-4620 FIX 2 INICIO
            //PLV-4620 FIX3 INICIO
            //PLV-5747 INICIO
            //II-74 INICIO
            if(coberturaEnt.caracteristicaespecialvalor != null){
                coberturaObj.Limite_de_Uso__c         			= coberturaEnt.caracteristicaespecialvalor;
                coberturaObj.ValorDias__c         			= coberturaEnt.caracteristicaespecialvalor;
            }else if(coberturaEnt.sigla == 'DIA'){
                coberturaObj.Limite_de_Uso__c = Decimal.valueOf(coberturaEnt.quantidade);
            }else{
                coberturaObj.Limite_de_Uso__c = 0;
            }
            //II-74 FIM

            if(coberturaEnt.caracteristicaespecialtipo != null){
                coberturaObj.Tipo_de_limite_de_utilizacao__c = coberturaEnt.caracteristicaespecialtipo;
            }else{
                coberturaObj.Tipo_de_limite_de_utilizacao__c = 'Monetário';
            }
            //PLV-5747 FIM
            //PLV-4620 FIX3 FIM
            //PLV-4620 FIX 2 FIM
            
            // IOF ??
            /*
            coberturaObj.PremioComercial__c = coberturaEnt.premio.comercial;
            coberturaObj.PremioPuro__c      = coberturaEnt.premio.puro;
            coberturaObj.PremioTotal__c     = coberturaEnt.premio.total;
            
            coberturaObj.TaxaComercial__c   = coberturaEnt.taxa.comercial;
            coberturaObj.TaxaPura__c        = coberturaEnt.taxa.pura;
            coberturaObj.TaxaTotal__c       = coberturaEnt.taxa.total;
            */
            coberturaObj.IOF__c = calculo.iof!=null ? calculo.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            if(calculo != null){
                if(calculo.premio != null){
                    coberturaObj.PremioComercial__c = calculo.premio.comercial;
                    coberturaObj.PremioPuro__c      = calculo.premio.puro;
                    coberturaObj.PremioTotal__c     = calculo.premio.total;
                }
                if(calculo.taxa != null){
                    coberturaObj.TaxaComercial__c   = calculo.taxa.comercial;
                    coberturaObj.TaxaPura__c        = calculo.taxa.pura;
                    coberturaObj.TaxaTotal__c       = calculo.taxa.total;
                }

                //PLV-5676 - INICIO
                if(tipoSeguro.contains(orcamento.tipoSeguro) && orcamento.contratoOriginal.precificacao != null){

                    descontoMap = getDescontosMap(orcamento.contratoOriginal.precificacao.coberturas);

                    coberturaObj.DescontoAgravoPercentualTecnico__c = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.percentual;
                    coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoMap?.get(coberturaEnt.sigla)?.get('TEC')?.monetario;

                }else if(calculo.descontoAgravo != null) { //PLV-5676 - FIM
                    for(EmissaoTO.DescontoAgravoTO descontoAgravo : calculo.descontoAgravo) {
                        if(descontoAgravo.tipo == 'TEC') {
                            coberturaObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                            coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                        }
                        else if(descontoAgravo.tipo == 'COM') {
                            coberturaObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                            coberturaObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                        }
                        else if(descontoAgravo.tipo == 'BAT') {
                            coberturaObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                            coberturaObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                        }
                    }
                }
            }
          
            system.debug('teste1234'+mapCoberturas);
            
             if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                system.debug('teste123'+mGarantiaProd);
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mGarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
                
            }
            
            //PLV-2146 - INÍCIO
            /*if(coberturaEnt.descontoAgravo != null) {
                for(EmissaoTO.DescontoAgravoTO descontoAgravo : coberturaEnt.descontoAgravo) {
                    if(descontoAgravo.tipo == 'TEC') {
                        coberturaObj.DescontoAgravoPercentualTecnico__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioTecnico__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'COM') {
                        coberturaObj.DescontoAgravoPercentualComercial__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioComercial__c  = descontoAgravo.monetario;
                    }
                    else if(descontoAgravo.tipo == 'BAT') {
                        coberturaObj.DescontoAgravoPercentualInformado__c = descontoAgravo.percentual;
                        coberturaObj.DescontoAgravoMonetarioInformado__c  = descontoAgravo.monetario;
                    }
                }
            }*/
            //PLV-2146 - FIM
        }
        else{ //PLV-5674 - INICIO
            if(mGarantiaProd.containsKey(coberturaEnt.sigla)){
                coberturaObj.GarantiaProduto__c = mGarantiaProd.get(coberturaEnt.sigla).Id;
                coberturaObj.CurrencyIsoCode = mGarantiaProd.get(coberturaEnt.sigla).CurrencyIsoCode;
            }
            
            coberturaObj.Garantia__c = mapGarantias.get(coberturaEnt.sigla);   
            coberturaObj.Capital__c         = coberturaEnt.valor;
            coberturaObj.Limite_de_Uso__c = 0;

        }//PLV-5674 - FIM
        
    } 
    //PLV-4620 - FIM
    
    
    private void montarRemuneracao(EmissaoTO.RemuneracaoTO remuneracaoEnt, RemuneracaoOrcamento__c remuneracaoObj, Map<String, TipoRemuneracao__c> mapTipo)
    {
        //PLV-2439 - INICIO
        remuneracaoObj.TipoRemuneracao__c = mapTipo.containsKey(remuneracaoEnt.tipoRemuneracao.toUpperCase()) ?
            mapTipo.get(remuneracaoEnt.tipoRemuneracao.toUpperCase()).Id : null;
        //PLV-2439 - FIM
        
        remuneracaoObj.Percentual__c      = remuneracaoEnt.percentual;
        // PLV-4234 - INICIO
        remuneracaoObj.Porcentagem_de_Retencao__c      = remuneracaoEnt.DICIO_RETENCAO;
        // PLV-4234 - FIM
    } 
    
    
    //--------------- RETORNO
    
    private EmissaoTO.PayloadTO gerarPaylodRetorno(Id idOrcamento)
    {
        EmissaoTO.PayloadTO payloadRetorno = new EmissaoTO.PayloadTO();
        payloadRetorno.orcamento = new EmissaoTO();
        
        MontarRetornoOrcamento(idOrcamento, payloadRetorno);
        
        System.debug('Orcamento: ' + JSON.serialize(payloadRetorno.orcamento, true));
        System.debug('Retorno FULL: ' + JSON.serializePretty(payloadRetorno, true));
        
        return payloadRetorno;
    }
    
    private void MontarRetornoOrcamento(Id idOrcamento, EmissaoTO.PayloadTO payLoadRetorno)
    {
        Map<Id, Account> mapPessoas = new Map<Id, Account>();
        
        Opportunity orcamento_contratante = daoOpportunity.buscarOrcamentosPorId(new Set<Id>{idOrcamento})[0];
        List<GrupoOrcamento__c> grupos_segurados = daoOpportunity.buscarGruposOrcamento(idOrcamento);
        
        Set<Id> idsContas = new Set<Id>();
        Set<Id> idsSegurados = new Set<Id>();
        
        for(GrupoOrcamento__c grupo : grupos_segurados)
        {
            for(SeguradoOrcamento__c segurado : grupo.SeguradosOrcamento__r)
            {
                idsContas.add(segurado.Conta__c);
            }
        }
        
        for(Account pessoa : AccountDAO.getInstance().buscarContasComFilhos(idsContas))
        {
            mapPessoas.put(pessoa.Id, pessoa);
        }
        
        List<GarantiaSeguradoOrcamento__c> garantiasSegurado = GrupoOrcamentoDAO.getInstance().listarGarantiasSegurados(idsSegurados);
        
        //--- Montar Nó orcamento
        montaNoOrcamento(orcamento_contratante, payLoadRetorno);
        
        List<EmissaoTO.ContratanteTO> contratantesTO;
        List<EmissaoTO.GrupoTO> gruposTO;
        List<EmissaoTO.SeguradoTO> seguradosTO;
        
        //--- montar nó Contratante
        for(ContratanteOrcamento__c contratante : orcamento_contratante.ContratantesOrcamento__r)
        {
            
            contratantesTO = new List<EmissaoTO.ContratanteTO>();
            
            //--- montar nó grupo
            for(GrupoOrcamento__c grupo : grupos_segurados)
            {
                if(grupo.ContratanteOrcamento__c != contratante.Id)
                    continue;
                
                seguradosTO =new List<EmissaoTO.SeguradoTO>();
                
                //--- montar nó segurado
                for(SeguradoOrcamento__c segurado : grupo.SeguradosOrcamento__r)
                {
                    
                    EmissaoTO.SeguradoTO seguradoTO =new EmissaoTO.SeguradoTO();
                    montaNoSegurado(segurado, seguradoTO, mapPessoas, garantiasSegurado);
                    
                    seguradosTO.add(seguradoTO);
                }
                
                gruposTO = new List<EmissaoTO.GrupoTO>();
                EmissaoTO.GrupoTO grupoTO =new EmissaoTO.GrupoTO();
                
                grupoTO.numero        = String.valueOf(grupo.Numero__c);
                grupoTO.nome          = grupo.name;
                grupoTO.qtdeVidas     = Integer.valueOf(grupo.QuantidadeVidas__c); //PLV-2666 - Alterado nome de variável
                grupoTO.segurados     = seguradosTO;
                gruposTO.add(GrupoTO);
            }
            
            EmissaoTO.ContratanteTO contratanteTO =new EmissaoTO.ContratanteTO();
            
            contratanteTO.numero = String.valueOf(contratante.Numero__c);
            contratanteTO.tipo   = contratante.Tipo__c ==  'Principal' ? 'PRI'  : 'DEP';
            contratanteTO.grupos = gruposTO;
            
            contratantesTO.add(contratanteTO);
        }
        
        payLoadRetorno.orcamento.contratantes = contratantesTO;
        
        
        List<EmissaoTO.RemuneracaoTO> remuneracaoLst = new List<EmissaoTO.RemuneracaoTO>();
        
        for(RemuneracaoOrcamento__c remuneracao : orcamento_contratante.RemuneracoesOrcamento__r)
        {
            EmissaoTO.RemuneracaoTO remuneracaoTO = new EmissaoTO.RemuneracaoTO();
            
            remuneracaoTO.tipoRemuneracao   = remuneracao.TipoRemuneracao__c;
            remuneracaoTO.percentual        = remuneracao.Percentual__c;
            
            remuneracaoLst.add(remuneracaoTO);
        }
        
        payLoadRetorno.orcamento.remuneracoes = remuneracaoLst;
        
        EmissaoTO.RetornoAceitacaoTO retornoCriticas = new EmissaoTO.RetornoAceitacaoTO();
        List<EmissaoTO.AnaliseTO> analises = new List<EmissaoTO.AnaliseTO>();
        List<EmissaoTO.AvisoTO> avisos = new List<EmissaoTO.AvisoTO>();
        List<EmissaoTO.RecusaTO> recusas = new List<EmissaoTO.RecusaTO>();
        List<EmissaoTO.PendenciaTO> pendencias = new List<EmissaoTO.PendenciaTO>();
        List<CriticaOrcamento__c> criticas = [SELECT id, name, Tipo__c, MensagemCliente__c from CriticaOrcamento__c WHERE Orcamento__c = :idOrcamento]; 
        for(CriticaOrcamento__c criticaAtual: criticas){
            EmissaoTO.MensagenTO mensagens = new EmissaoTO.MensagenTO();
            switch on criticaAtual.tipo__C{
                when 'Análise'{
                    EmissaoTO.AnaliseTO analise = new EmissaoTO.AnaliseTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    analise.mensagens = mensagens;
                    analises.add(analise);
                }when 'Aviso'{
                    EmissaoTO.AvisoTO aviso = new EmissaoTO.AvisoTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    aviso.mensagens = mensagens;
                    avisos.add(aviso);
                }when 'Pendência'{
                    EmissaoTO.PendenciaTO pendencia = new EmissaoTO.PendenciaTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    pendencia.mensagens = mensagens;
                    pendencias.add(pendencia);
                }when 'Recusa'{
                    EmissaoTO.RecusaTO recusa = new EmissaoTO.RecusaTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    recusa.mensagens = mensagens;
                    recusas.add(recusa);
                }
            }
        }
        retornoCriticas.analises = analises;
        retornoCriticas.avisos = avisos;
        retornoCriticas.recusas = recusas;
        retornoCriticas.pendencias = pendencias;
        payLoadRetorno.retornoAceitacao = retornoCriticas;
        system.debug('JSON do payload retorno criticas => ' + JSON.serialize(payLoadRetorno));
    }
    
    private void montaNoOrcamento(Opportunity orcamento, EmissaoTO.PayloadTO payLoadRetorno)
    {
        payLoadRetorno.orcamento.meioComercializacao    = orcamento.MeioComercializacao__c;
        payLoadRetorno.orcamento.numeroOrcamento        = orcamento.Name;
        payLoadRetorno.orcamento.numeroPortal           = orcamento.NumeroPortal__c;
        payLoadRetorno.orcamento.dataCalculo            = String.valueOf(orcamento.DataCalculo__c);
        payLoadRetorno.orcamento.codigoProdutoVida      = orcamento.Produto__r.ProductCode;
        payLoadRetorno.orcamento.tipoVigencia           = orcamento.TipoVigencia__c;
        payLoadRetorno.orcamento.vigenciaInicial        = String.valueOf(orcamento.VigenciaInicial__c);
        payLoadRetorno.orcamento.vigenciaFinal          = String.valueOf(orcamento.VigenciaFinal__c);
        payLoadRetorno.orcamento.entradaNegocio         = orcamento.EntradaNegocio__c;
        payLoadRetorno.orcamento.canalDistribuicao      = orcamento.CanalDistribuicao__r.Sigla__c;
        //        payLoadRetorno.orcamento.segmento               = orcamento.
        //        payLoadRetorno.orcamento.tipoSeguro             = orcamento.Tipo__c;
        
        
    }
    
    
    private void MontaNoSegurado(SeguradoOrcamento__c segurado, EmissaoTO.SeguradoTO seguradoTO, Map<Id, Account> mapPessoas, List<GarantiaSeguradoOrcamento__c> garantiasSegurados)
    {
        seguradoTO.numero = String.valueOf(segurado.Numero__c);
        
        if(segurado.Conta__c != null)
        {
            Account pessoa = mapPessoas.get(segurado.Conta__c);
            
            if(pessoa.RecordTypeId == RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id)
            {
                seguradoTO.pessoa = new EmissaoTO.PessoaTO();
                seguradoTO.pessoa.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
                
                seguradoTO.pessoa.tipo = 'FIS';
                seguradoTO.pessoa.nome = pessoa.Name;
                seguradoTO.pessoa.dadosPessoaFisica.sexo            = pessoa.Sexo__c; 
                seguradoTO.pessoa.dadosPessoaFisica.numeroCpf       = pessoa.Cpf__c;
                seguradoTO.pessoa.dadosPessoaFisica.digitoCpf       = pessoa.Cpf__c;
                seguradoTO.pessoa.dadosPessoaFisica.estadoCivil     = contaBO.buscarEstadoCivilSaida(pessoa.EstadoCivil__c);
                seguradoTO.pessoa.dadosPessoaFisica.dataNascimento  = String.valueOf(pessoa.PersonBirthdate);
                //            seguradoTO.pessoa.dadosPessoaFisica.profissao       = 
                
                List<EmissaoTO.EnderecoTO> enderecoList = new List<EmissaoTO.EnderecoTO>();
                
                for(Endereco__c endereco : pessoa.Enderecos__r)
                {
                    EmissaoTO.EnderecoTO enderecoTO = new EmissaoTO.EnderecoTO();
                    
                    enderecoTO.uf               = endereco.Estado__c;
                    enderecoTO.tipoLogradouro   = endereco.TipoLogradouro__c;
                    enderecoTO.tipoEndereco     = endereco.TipoEndereco__c;
                    enderecoTO.paisResidencia   = endereco.Pais__c;
                    enderecoTO.numeroLogradouro = endereco.Numero__c;
                    enderecoTO.logradouro       = endereco.Logradouro__c;
                    enderecoTO.complementoCep   = endereco.CEP__c;
                    enderecoTO.complemento      = endereco.Complemento__c;
                    enderecoTO.cidade           = endereco.Cidade__c;
                    enderecoTO.cep              = endereco.CEP__c;
                    enderecoTO.bairro           = endereco.Bairro__c;
                    
                    enderecoList.add(enderecoTO);
                }
                
                seguradoTO.pessoa.enderecos = enderecoList;
            }
        }
        
        List<EmissaoTO.CoberturaTO> coberturas = new List<EmissaoTO.CoberturaTO>();
        
        for(GarantiaSeguradoOrcamento__c garantia : garantiasSegurados)
        {
            if(garantia.SeguradoOrcamento__c == segurado.Id)
            {
                EmissaoTO.CoberturaTO cobertura = new EmissaoTO.CoberturaTO();
                
                cobertura.sigla                 = garantia.Garantia__r.Sigla__c;
                cobertura.valor                 = garantia.Valor__c;
                cobertura.percentual            = garantia.Percentual__c;
                
                coberturas.add(cobertura);
            }
        }
        
        seguradoTO.coberturas = coberturas;
        
    }
    
    private String PegaParteChave(String key, integer posicao)
    {
        String[] arrKey = key.split('_');
        
        return arrKey[posicao-1];
    }
    //PLV2365: FIM
    
    //--> PLV2427 INICIO
    ////PLV-2421 - Inicio - Inclução de parametro
    private void GerarRetornoRegras(ServiceTO.OfertaTO retorno, EmissaoTO.OfertasTO oferta)
    {
        System.debug('Entrada de GerarRetornoRegras');
        //PLV-2421 - Fim - Inclução de parametro
        List<String> coberturasLideres = new List<String>();
        List<ServiceTO.CoberturaRetornoOfertaTO> coberturas = new List<ServiceTO.CoberturaRetornoOfertaTO>();
        
        // busca proposta criada
        Opportunity orcamento = OpportunityDAO.getInstance().buscarOportunidadesPorNumero(new Set<String>{retorno.orcamento.numeroOrcamento})[0];
        System.debug('Orcamento pelo Iskander = > ' + orcamento);
        
        //PLV-2421 - Inicio - Lógica para atender regra de negócio
        GarantiaProduto__c garantiaProduto = null;
        
        // cria nó de regras
        for(GarantiaProduto__c garantia : GarantiaProdutoDAO.getInstance().buscarGarantiasProdutoPorProdutoId(new Set<Id>{orcamento.Produto__c}))
        {
            if(garantiaProduto == null){
                garantiaProduto = garantia;
            }else if(garantia.CaracteristicaGarantia__c == 'Principal'){
                if(garantia.OrdemPrioridade__c < garantiaProduto.OrdemPrioridade__c){
                    garantiaProduto = garantia;
                }else if(garantiaProduto.CaracteristicaGarantia__c != 'Principal'){
                    garantiaProduto = garantia;
                }
            }else if(garantiaProduto.CaracteristicaGarantia__c != 'Principal'){
                if(garantia.OrdemPrioridade__c < garantiaProduto.OrdemPrioridade__c){
                    garantiaProduto = garantia;
                }
            }
            
            //PLV-2421 - Fim - Lógica para atender regra de negócio
            
            if(garantia.CaracteristicaGarantia__c == 'Principal')
            {
                coberturasLideres.add(garantia.Garantia__r.Sigla__c);
            }
            
            ServiceTO.CoberturaRetornoOfertaTO cobertura = new ServiceTO.CoberturaRetornoOfertaTO();
            cobertura.sigla         = garantia.Garantia__r.Sigla__c;
            //PLV-3357 - INICIO - Add prioridade para apresentação no portal
            cobertura.prioridade    = garantia.OrdemPrioridade__c;
            //PLV-3357 - FIM
            //PLV-2422 Inteligencia de oferta - Inicio - Incluido o campo nome
            cobertura.nome          = garantia.Garantia__r.Name;
            //PLV-2422 Inteligencia de oferta - Fim
            cobertura.tipo          = garantia.TipoLimiteCapital__c;
            cobertura.obrigatorio   = garantia.Obrigatoria__c;
            cobertura.limiteMinimo  = garantia.LimiteCapitalMinimo__c;
            cobertura.limiteMaximo  = garantia.LimiteCapitalMaximo__c;
            cobertura.descricao = garantia.Garantia__r.Descricao__c;
            
            
            coberturas.add(cobertura);
        }
        
        retorno.regras = new ServiceTO.RegrasRetornoOfertaTO();
        
        retorno.regras.coberturasLideres = coberturasLideres;
        retorno.regras.coberturas        = coberturas;
        
        //PLV-2421 - Inicio - Lógica para atender regra de negócio
        //Comparar siglas da Garantias do Segurado e pegar capital do JSON
        
        if(oferta.orcamento.contratantes.isEmpty()) return;
        
        List<EmissaoTO.ContratanteTO> contratantes = oferta.orcamento.contratantes;
        
        List<EmissaoTO.GrupoTO> grupos = new List<EmissaoTO.GrupoTO>();
        for(EmissaoTO.ContratanteTO contratante: contratantes){
            if(contratante.grupos.isEmpty()) continue;
            grupos.addAll(contratante.grupos);
        }
        
        if(grupos.isEmpty()) return;
        
        List<EmissaoTO.SeguradoTO> segurados = new List<EmissaoTO.SeguradoTO>();
        for(EmissaoTO.GrupoTO grupo: grupos){
            if(grupo.segurados != null){
                if(grupo.segurados.isEmpty()) continue;           
                segurados.addAll(grupo.segurados);
            }
        }
        
        if(segurados.isEmpty()) return;
        
        List<EmissaoTO.CoberturaTO> coberturasSegurado = new List<EmissaoTO.CoberturaTO>();
        for(EmissaoTO.SeguradoTO segurado: segurados){
            if(segurado.coberturas.isEmpty()) continue;
            coberturasSegurado.addAll(segurado.coberturas);
        }
        
        if(coberturasSegurado.isEmpty()) return;
        
        // PLV-2768 - Inicio - Considerar prioridade dos questionários
        
        Map<String,Double> mapSiglaCapital = new Map<String,Double>();
        for(EmissaoTO.CoberturaTO coberSeg: coberturasSegurado){
            mapSiglaCapital.put(coberSeg.sigla, coberSeg.valor);
        }
        //Buscar questionários atrelados ao produto
        List<QuestionarioProduto__c> questionario = ([SELECT    id, Questionario__c, GarantiaProduto__r.Garantia__r.Sigla__c,
                                                      Prioridade__c
                                                      FROM      QuestionarioProduto__c 
                                                      WHERE     Produto__c =: orcamento.Produto__c  
                                                      AND       LimiteCapitalMinimo__c <= :mapSiglaCapital.values() 
                                                      AND       LimiteCapitalMaximo__c >= :mapSiglaCapital.values()
                                                      AND       GarantiaProduto__r.Garantia__r.Sigla__c IN :mapSiglaCapital.keySet()
                                                      ORDER BY  Prioridade__c ASC
                                                      LIMIT 1
                                                      //PLV-2771 - Codigo removido devido a exclusão do campo 
                                                     ]);
        List<PerguntaQuestionario__c> pergQuest = new List<PerguntaQuestionario__c>();
        if(!questionario.isEmpty())
            pergQuest = [ SELECT  Id, Pergunta__r.Pergunta__c, Pergunta__r.TipoResposta__c, 
                         Pergunta__r.OpcoesResposta__c, 
                         Obrigatorio__c, // PLV-4797 INICIO/FIM SYS4B ODEMIR 
                         ProximaPergunta__c, numero__c //PLV-4771 - INÍCIO/FIM
                         FROM    PerguntaQuestionario__c 
                         WHERE   Questionario__c = :questionario[0].Questionario__c
                         ORDER BY numero__c ASC]; //PLV-4771 - INÍCIO/FIM
        // PLV-2768 - FIM -
        List<ServiceTO.QuestionarioTO> questTO = new List<ServiceTO.QuestionarioTO>();
        
        for(PerguntaQuestionario__c perguntaQuest: pergQuest){
            ServiceTO.QuestionarioTO quest = new ServiceTO.QuestionarioTO();
            quest.idPergunta = perguntaQuest.Id;
            quest.pergunta = perguntaQuest.Pergunta__r.Pergunta__c;
            quest.tipoResposta = perguntaQuest.Pergunta__r.TipoResposta__c;
            quest.opcoesRespostas = perguntaQuest.Pergunta__r.OpcoesResposta__c;
            //PLV-4771 - INÍCIO
            //quest.proximaPergunta = perguntaQuest.ProximaPergunta__c;
            quest.ordenacao = perguntaQuest.numero__c;
            //PLV-4771 - FIM
            quest.obrigatorio = perguntaQuest.Obrigatorio__c;  // PLV-4797 INICIO/FIM SYS4B ODEMIR 
            questTO.add(quest);

        }
        
        //add questionarios nas regras da oferta
        retorno.regras.questionarios = questTO;
        
        //PLV-2421 - Fim - Lógica para atender regra de negócio
        // cria nó de remunerações
        Map<Id, RemuneracaoProduto__c> mapRemuneracaoProduto = new Map<Id, RemuneracaoProduto__c>();
        
        for(RemuneracaoProduto__c remuneracaoProduto : RemuneracaoProdutoDAO.getInstance().buscarRemuneracaoProdutoPorProdutos(new Set<Id>{orcamento.Produto__c}))
        {
            mapRemuneracaoProduto.put(remuneracaoProduto.TipoRemuneracao__c, remuneracaoProduto);
        }
        
        List<ServiceTO.RemuneracaoRetornoOfertaTO> remuneracoesRetorno = new List<ServiceTO.RemuneracaoRetornoOfertaTO>();
        
        for(RemuneracaoOrcamento__c remuneracao : RemuneracaoOrcamentoDAO.getInstance().buscarRemuneracoesOportunidade(new Set<Id>{orcamento.Id}))
        {
            if(mapRemuneracaoProduto.containsKey(remuneracao.TipoRemuneracao__c))
            {
                RemuneracaoProduto__c remuneracaoProduto = mapRemuneracaoProduto.get(remuneracao.TipoRemuneracao__c);
                
                ServiceTO.RemuneracaoRetornoOfertaTO remuneracaoRetorno = new ServiceTO.RemuneracaoRetornoOfertaTO();
                
                remuneracaoRetorno.tipoRemuneracao = remuneracao.TipoRemuneracao__r.Name;
                remuneracaoRetorno.obrigatorio     = remuneracaoProduto.Obrigatoria__c;
                remuneracaoRetorno.limiteMinimo    = remuneracaoProduto.LimiteMinimo__c;
                remuneracaoRetorno.limiteMaximo    = remuneracaoProduto.LimiteMaximo__c;
                
                remuneracoesRetorno.add(remuneracaoRetorno);
            }
            
        }
        
        retorno.regras.remuneracoes = remuneracoesRetorno;
        
    }
    //--> PLV2427 FIM
    
    //PLV-2439 - INICIO
    
    private void adicionarMensagens(CriticaOrcamento__c critica, EmissaoTO.MensagenTO mensagens) {
        
        if(mensagens != null) {
            critica.MensagemCliente__c = mensagens.cliente;
            critica.MensagemInterna__c = mensagens.interna;
            critica.MensagemRepresentante__c = mensagens.representante;
        }
    }
    
    // private EmissaoTO.RetornoAceitacaoTO gerarCriticasODMOrcamento(EmissaoTO.OfertasTO orcamento, Id orcamentoId) {
    @TestVisible //PLV-4370 - INICIO/FIM
    private void gerarCriticasODMOrcamento(EmissaoTO.RetornoAceitacaoTO retornoAceitacao, Id orcamentoId) {
        List<CriticaOrcamento__c> lstRetornoCriticaOrcamento = new List<CriticaOrcamento__c>();  
        Set<String> setTipoCritica = new Set<String>();   //PLV-2703 - Inicio/Fim - Criação do set para verificar qual critica foi adicionada ao orçamento
        // EmissaoTO.RetornoAceitacaoTO retornoAceitacao = orcamento.retornoAceitacao;
        system.debug('retornoAceitacao '+ retornoAceitacao);
        system.debug(retornoAceitacao);
        
        //PLV-2948 Início
        // COMPLEMENTO SE ALGUM DIA RETORNOACEITAÇÃO VIR VAZIO
        if(retornoAceitacao != null){
            //verificar se a lista que retorna no JSON está nula.
            if(retornoAceitacao.analises != null) {
                for(EmissaoTO.AnaliseTO analise : retornoAceitacao.analises) {
                    CriticaOrcamento__c critica = new CriticaOrcamento__c();
                    critica.Orcamento__c = String.valueOf(orcamentoId);
                    
                    critica.Severidade__c = analise.severidade;
                    critica.Codigo__c = String.valueOf(analise.codigo);
                    critica.Descricao__c = analise.descricao;
                    critica.Area__c = analise.area;
                    critica.Procedimento__c = analise.procedimento;
                    critica.Origem__c = 'ODM';
                    critica.Tipo__c = 'Análise';
                    critica.Status__c = 'Pendente';
                    
                    adicionarMensagens(critica, analise.mensagens);
                    lstRetornoCriticaOrcamento.add(critica);
                    setTipoCritica.add(critica.Tipo__c);    //PLV-2703 - Inicio/Fim - Atribuiçao do set
                }
            }
            //verificar se a lista que retorna no JSON está nula.
            if(retornoAceitacao.avisos != null) {
                for(EmissaoTO.AvisoTO aviso : retornoAceitacao.avisos) {
                    CriticaOrcamento__c critica = new CriticaOrcamento__c();
                    critica.Orcamento__c = String.valueOf(orcamentoId);
                    
                    critica.Severidade__c = aviso.severidade;
                    critica.Codigo__c = String.valueOf(aviso.codigo);
                    critica.Descricao__c = aviso.descricao;
                    critica.Area__c = aviso.area;
                    critica.Procedimento__c = aviso.procedimento;
                    critica.Origem__c = 'ODM';
                    critica.Tipo__c = 'Aviso';
                    critica.Status__c = 'Pendente';
                    
                    adicionarMensagens(critica, aviso.mensagens);
                    lstRetornoCriticaOrcamento.add(critica);
                    setTipoCritica.add(critica.Tipo__c);    //PLV-2703 - Inicio/Fim - Atribuiçao do set
                }
            }
            //verificar se a lista que retorna no JSON está nula.
            if(retornoAceitacao.pendencias != null) {
                for(EmissaoTO.PendenciaTO pendencia : retornoAceitacao.pendencias) {
                    CriticaOrcamento__c critica = new CriticaOrcamento__c();
                    critica.Orcamento__c = String.valueOf(orcamentoId);
                    
                    critica.Severidade__c = pendencia.severidade;
                    critica.Codigo__c = String.valueOf(pendencia.codigo);
                    critica.Descricao__c = pendencia.descricao;
                    critica.Area__c = pendencia.area;
                    critica.Procedimento__c = pendencia.procedimento;
                    critica.Origem__c = 'ODM';
                    critica.Tipo__c = 'Pendência';
                    critica.Status__c = 'Pendente';
                    
                    adicionarMensagens(critica, pendencia.mensagens);
                    lstRetornoCriticaOrcamento.add(critica);
                    setTipoCritica.add(critica.Tipo__c);    //PLV-2703 - Inicio/Fim - Atribuiçao do set
                }
                
            }
            //verificar se a lista que retorna no JSON está nula.
            if(retornoAceitacao.recusas != null) {
                for(EmissaoTO.RecusaTO recusa : retornoAceitacao.recusas) {
                    CriticaOrcamento__c critica = new CriticaOrcamento__c();
                    critica.Orcamento__c = String.valueOf(orcamentoId);
                    
                    critica.Severidade__c = recusa.severidade;
                    critica.Codigo__c = String.valueOf(recusa.codigo);
                    critica.Descricao__c = recusa.descricao;
                    critica.Area__c = recusa.area;
                    critica.Procedimento__c = recusa.procedimento;
                    critica.Origem__c = 'ODM';
                    critica.Tipo__c = 'Recusa';
                    critica.Status__c = 'Pendente';
                    
                    adicionarMensagens(critica, recusa.mensagens);
                    lstRetornoCriticaOrcamento.add(critica);
                    setTipoCritica.add(critica.Tipo__c);    //PLV-2703 - Inicio/Fim - Atribuiçao do set
                }
            }
            //PLV-4370 - INICIO
            system.debug('critica ODM SampleMed'+retornoAceitacao.decisoes);
            if(retornoAceitacao.decisoes != null) {
                for(EmissaoTO.DecisaoTO decisoes : retornoAceitacao.decisoes) {
                    CriticaOrcamento__c critica = new CriticaOrcamento__c();
                    critica.Orcamento__c = String.valueOf(orcamentoId);
                    
                    //critica.Severidade__c = aviso.severidade;
                    critica.Codigo__c = String.valueOf(decisoes.codigo);
                    critica.Descricao__c = decisoes.descricao;
                    //critica.Area__c = aviso.area;
                    //critica.Procedimento__c = aviso.procedimento;
                    critica.Origem__c = 'ODM';
                    critica.Tipo__c = decisoes.tipo;
                    critica.Acao__c = decisoes.acao;
                    critica.Status__c = 'Pendente';
                    
                    lstRetornoCriticaOrcamento.add(critica);
                }
            }
            //PLV-4370 - FIM

            insert lstRetornoCriticaOrcamento; // PLV-4370-FIX2 - INICIO/FIM
            //PLV-2703 - Inicio - Lógica criada para alterar o status do orçamento
            if(setTipoCritica.contains('Recusa')){
                Opportunity orc = new Opportunity();
                orc.Id = orcamentoId;
                orc.StageName = 'Recusado';
                update orc;
            } else if(setTipoCritica.contains('Pendência') || setTipoCritica.contains('Análise')){ //ANNVI-55 - INICIO/FIM
                Opportunity orc = new Opportunity();
                orc.Id = orcamentoId;
                orc.StageName = 'Em análise';
                update orc;
            }else{
                Opportunity orc = new Opportunity();
                orc.Id = orcamentoId;
                orc.StageName = 'Disponível para contratação';
                update orc;
            }
        }
        //PLV-2948 Fim
        
        //PLV-2703 - Fim
    }
    //PLV-2439 - FIM
    
    //PLV-2962 - INICIO
    @testvisible // PLV-5331 INICIO / FIM
    private ServiceTO.RetornoAceitacaoTO retornarCriticasODM(String idOrcamento){
        ServiceTO.RetornoAceitacaoTO retornoCriticas = new ServiceTO.RetornoAceitacaoTO();
        List<ServiceTO.AnaliseTO> analises = new List<ServiceTO.AnaliseTO>();
        List<ServiceTO.AvisoTO> avisos = new List<ServiceTO.AvisoTO>();
        List<ServiceTO.RecusaTO> recusas = new List<ServiceTO.RecusaTO>();
        List<ServiceTO.PendenciaTO> pendencias = new List<ServiceTO.PendenciaTO>();
        List<CriticaOrcamento__c> criticas = [SELECT id, name, Tipo__c, MensagemCliente__c from CriticaOrcamento__c WHERE Orcamento__r.Numero__c = :idOrcamento];  
        system.debug('criticas: '+criticas);
        for(CriticaOrcamento__c criticaAtual: criticas){
            ServiceTO.MensagenTO mensagens = new ServiceTO.MensagenTO();
            switch on criticaAtual.Tipo__C{
                when 'Análise'{
                    ServiceTO.AnaliseTO analise = new ServiceTO.AnaliseTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    analise.mensagens = mensagens;
                    analises.add(analise);
                }when 'Aviso'{
                    ServiceTO.AvisoTO aviso = new ServiceTO.AvisoTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    aviso.mensagens = mensagens;
                    avisos.add(aviso);
                }when 'Pendência'{
                    ServiceTO.PendenciaTO pendencia = new ServiceTO.PendenciaTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    pendencia.mensagens = mensagens;
                    pendencias.add(pendencia);
                }when 'Recusa'{
                    ServiceTO.RecusaTO recusa = new ServiceTO.RecusaTO();
                    mensagens.cliente = criticaAtual.MensagemCliente__c != null? criticaAtual.MensagemCliente__c : 'Oferta indisponível, em análise pela organização';
                    recusa.mensagens = mensagens;
                    recusas.add(recusa);
                }
            }
        }
        retornoCriticas.analises = analises;
        retornoCriticas.avisos = avisos;
        retornoCriticas.recusas = recusas;
        retornoCriticas.pendencias = pendencias;
        return retornoCriticas;
    }
    //PLV-2962 - FIM

    /* ---------------------------------- FIM HELPERS ------------------------------------------------------------- */
}