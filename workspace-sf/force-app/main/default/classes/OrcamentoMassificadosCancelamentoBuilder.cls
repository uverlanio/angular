/**
 * Created by Alessandro Ponte on 30/01/2019.
 */

public with sharing class OrcamentoMassificadosCancelamentoBuilder extends OrcamentoBuilder{

    private static final OrcamentoMassificadosCancelamentoBuilder instance = new OrcamentoMassificadosCancelamentoBuilder();
    public static OrcamentoMassificadosCancelamentoBuilder getInstance() { return instance; }
    private OrcamentoMassificadosCancelamentoBuilder() { this.setInstancia(this); }
    private ProductDAO daoProduto = ProductDAO.getInstance();
    private AccountBO boConta = AccountBO.getInstance();

    // instancias de negocio
    private Map<String, GarantiaProduto__c> mapGarantiaProdutoPorSigla = new Map<String, GarantiaProduto__c>();
    private Map<String,Garantia__c> mapGarantiaPorSigla = new Map<String, Garantia__c>();
    private Map<Integer, CriticaParceiro__c>  mapCriticas = new Map<Integer, CriticaParceiro__c>();
    private Product2 produto;
    private Opportunity orcamentoOriginal;
    private Quote propostaOriginal;
    // PLV-2372 INICIO
    private Contract contratoOriginal;
    // PLV-2372 FIM

    // Constantes
    private final Map<String, RecordType> mapRecordType = new Map<String, RecordType>();

    /* ---------------------------------- INTERFACE --------------------------------------------------------------- */

    public override void gerarOrcamento(EmissaoTO.PayloadTO payloadTO){

        // Gera e popula as variaveis auxiliares do negocio
        this.buscarRegistrosDominios(payloadTO);

        // Verifica se existe devolutivas e aborta a geracao de orcamento
        if(!this.orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.isEmpty()){
            return;
        }

        // Gera o numero de propsta
        String numeroProposta = this.gerarNumeroProposta().leftPad(8,'0');

        // PLV-2372 INICIO
        // Recupera as propostas de cancelamento pendentes e apaga
        List<Opportunity> listOrcamentosAnteriores = new List<Opportunity>();
        List<Quote> listPropostasCancelamentoAnteriores = QuoteDAO.getInstance().buscarPropostasCancelamentoPendentesPorContratoOriginal(new Set<Id>{this.contratoOriginal.Id});

        for(Quote proposta : listPropostasCancelamentoAnteriores){
            listOrcamentosAnteriores.add(proposta.Opportunity);
        }

        if(!listPropostasCancelamentoAnteriores.isEmpty()) {
            delete listPropostasCancelamentoAnteriores;
        }
        if(!listOrcamentosAnteriores.isEmpty()){
            delete listOrcamentosAnteriores;
        }
        // PLV-2372 FIM

        // Popula o orcamento
        this.popularModeloOrcamento(payloadTO, this.orcamento.orcamentoWrapper.sfOrcamento, 18, numeroProposta);

        // Clona os filhos do orcamento
        this.clonarFilhosOrcamento();

        this.gerarContratantes(payloadTO);

        System.debug('ORCAMENTO WRAPPER FINAL');
        System.debug(JSON.serialize(this.orcamento));

    }
    public override List<Orcamento.ContratanteWrapper> gerarContratantes(EmissaoTO.PayloadTO payloadTO){

        this.clonarContratantes();

        this.gerarGrupos(null);

        return null;

    }
    public override List<Orcamento.GrupoWrapper> gerarGrupos(EmissaoTO.PayloadTO payloadTO){

        this.clonarGrupos();

        this.gerarSegurados(null);

        return  null;
    }
    public override List<Orcamento.SeguradoWrapper> gerarSegurados(EmissaoTO.PayloadTO payloadTO){

        this.clonarSegurados();

        return  null;
    }

    public override void popularPrecificacao(EmissaoTO.PrecificacaoTO precificacaoTO){}

    public override Orcamento inserirRegistros(Orcamento orcamento) {

        // Instancias
        List<GarantiaOrcamento__c> listGarantiaOrcamento = new List<GarantiaOrcamento__c>();
        List<GarantiaContratanteOrcamento__c> listGarantiaContratanteOrcamento = new List<GarantiaContratanteOrcamento__c>();
        List<GarantiaGrupoOrcamento__c> listGarantiaGrupoOrcamento = new List<GarantiaGrupoOrcamento__c>();
        List<GarantiaSeguradoOrcamento__c> listGarantiaSeguradoOrcamento = new List<GarantiaSeguradoOrcamento__c>();
        List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento = new List<RemuneracaoOrcamento__c>();
        List<CriticaOrcamento__c> listCriticaOrcamento = new List<CriticaOrcamento__c>();
        List<ContratanteOrcamento__c> listContratanteOrcamento = new List<ContratanteOrcamento__c>();
        List<GrupoOrcamento__c> listGrupoOrcamento = new List<GrupoOrcamento__c>();
        List<SeguradoOrcamento__c> listSeguradoOrcamento = new List<SeguradoOrcamento__c>();

        // Verifica se existe devolutivas e aborta a geracao de orcamento
        if(!this.orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.isEmpty()){
            return orcamento;
        }

        // Insere o orcamento
        try{
            insert this.orcamento.orcamentoWrapper.sfOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        //Atribui id do orcamento nas Remuneracoes
        for(Orcamento.RemuneracaoOrcamentoWrapper remuneracaoOrcamentoWrapper : this.orcamento.orcamentoWrapper.remuneracaoOrcamentoWrapper){
            remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento.Id = null;
            remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento.Oportunidade__c = this.orcamento.orcamentoWrapper.sfOrcamento.Id;
            listRemuneracaoOrcamento.add(remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento);

        }

        // Atribui id do orcamento nas garantias
        for(Orcamento.GarantiaWrapper garantiaWrapper : this.orcamento.orcamentoWrapper.garantiasWrapper){
            garantiaWrapper.sfGarantiaOrcamento.Id = null;
            garantiaWrapper.sfGarantiaOrcamento.Orcamento__c = this.orcamento.orcamentoWrapper.sfOrcamento.Id;
            listGarantiaOrcamento.add(garantiaWrapper.sfGarantiaOrcamento);

        }

        //Atribui id do orcamento nos contratantes
        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper ){

            contratanteWrapper.sfContratante.Id = null;
            contratanteWrapper.sfContratante.Orcamento__c = this.orcamento.orcamentoWrapper.sfOrcamento.Id;
            listContratanteOrcamento.add(contratanteWrapper.sfContratante);

        }

        // Atribui Id da proposta nas criticas da proposta
        for(CriticaOrcamento__c criticaOrcamento : this.orcamento.orcamentoWrapper.criticas){
            criticaOrcamento.Id = null;
            criticaOrcamento.Orcamento__c = this.orcamento.orcamentoWrapper.sfOrcamento.Id;
            listCriticaOrcamento.add(criticaOrcamento);
        }

        // Insere os contratantes da proposta
        try{
            insert listContratanteOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir contratantes do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Insere as remuneracoes da proposta
        try{
            insert listRemuneracaoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir remuneracoes do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Insere as garantias da proposta
        try{
            insert listGarantiaOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Insere as criticas da proposta
        try{
            insert listCriticaOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir criticas da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Atualiza o status da proposta
        this.orcamento.orcamentoWrapper.sfOrcamento.StageName = 'Disponível para contratação';

        try{
            update this.orcamento.orcamentoWrapper.sfOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Atualizar proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Atribui o id do contratante nas garantias e grupos
        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper){

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

        // Insere as garantias do contratante do orcamento
        try{
            insert listGarantiaContratanteOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias do contratante do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Insere os grupos do contratante do orcamento
        try{
            insert listGrupoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir grupos do contratante do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Atribui o id do grupo nas garantias e segurados
        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper){

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

        // Insere as garantias do grupo da proposta
        try{
            insert listGarantiaGrupoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias dos grupos do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Insere os segurados dos grupos da proposta
        try{
            insert listSeguradoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir segurados dos grupos do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Atribui o id do segurado nas garantias e beneficiarios
        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper){

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

        // Insere as garantias do segurado da proposta
        try{
            insert listGarantiaSeguradoOrcamento;
        }catch (Exception e){
            throw new OrcamentoBuilderException('Exception: Inserir garantias dos segurados do orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        return orcamento;
    }

    /* ---------------------------------- FIM INTERFACE ----------------------------------------------------------- */

    /* ---------------------------------- MODELOS ----------------------------------------------------------------- */

    private void popularModeloOrcamento(EmissaoTO.PayloadTO objPayloadTO, Opportunity orcamento, Integer origem, String numeroProposta){

        try
        {
            orcamento.Origem__c = String.valueOf(origem);
            orcamento.Name = this.gerarOpportunityName(objPayloadTO.proposta.meioComercializacao, numeroProposta);
            orcamento.Numero__c = numeroProposta;
            orcamento.VigenciaInicial__c = Date.valueOf(objPayloadTO.proposta.dataCancelamento);
            orcamento.Type = objPayloadTO.proposta.tipoSeguro;
            orcamento.TipoEndosso__c = objPayloadTO.proposta.tipoEndosso;
            orcamento.StageName = 'Em criação';
            orcamento.Produto__c = produto.Id;
            orcamento.Payload__c = JSON.serialize(objPayloadTO);
            //PLV-5884 FIX-02 INICIO
            // Dados clonados do orcamento original
            orcamento.VigenciaFinal__c = this.contratoOriginal.VigenciaFinal__c;
            orcamento.AccountId = this.contratoOriginal.AccountId;
            orcamento.CloseDate = this.contratoOriginal.StartDate;
            orcamento.CanalDistribuicao__c = this.contratoOriginal.CanalDistribuicao__c;
            orcamento.DataCalculo__c = this.contratoOriginal.StartDate;
            //orcamento.QuantidadeDias__c = this.orcamentoOriginal.QuantidadeDias__c;
            orcamento.MeioComercializacao__c = this.contratoOriginal.MeioComercializacao__c;
            //orcamento.Description = this.orcamentoOriginal.Description;
            orcamento.Probability = 100;
            //orcamento.RecordTypeId = this.orcamentoOriginal.RecordTypeId;
            //PLV-5884 FIX-02 FIM
        }
        catch(Exception e)
        {
            throw new OrcamentoBuilderException('Exception: Erro ao gerar um orcamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

    }

    private List<SObject> clonarSObjects(Set<String> setSObjectName, String criterio, Boolean comId){

        List<SObject> listSObjects = new List<SObject>();
        List<SObject> listSObjectsClonados = new List<SObject>();

        // Busca os filhos direto do orcamento original
        for(String sobjectName : setSObjectName){
            listSObjects.addAll(this.buscarDadosObjeto(sobjectName, criterio));
        }

        if(!listSObjects.isEmpty()){
            listSObjectsClonados = listSObjects.deepClone(comId);
        }

        return listSObjectsClonados;

    }

    /* ---------------------------------- FIM MODELOS ------------------------------------------------------------- */

    /* ---------------------------------- HELPERS ----------------------------------------------------------------- */

    // PLV-2372-29 INICIO
    private void buscarRegistrosDominios(EmissaoTO.PayloadTO payloadTO){

        //Recupera e mapeia todas as criticas do parceiro
        for(CriticaParceiro__c critica : CriticaParceiroDAO.getInstance().buscarCriticasParceiro(new Set<String>{payloadTO.proposta.parceiro})){
            mapCriticas.put(Integer.ValueOf(critica.Name), critica);
        }

        // Busca os tipos de registro de orcamento e popula o mapa
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Opportunity')){
            mapRecordType.put(tipo.DeveloperName, tipo);
        }

        // Verifica se o contrato original veio no payload
        if(payloadTO.proposta.contratoOriginal == null){
            throw new OrcamentoBuilderException('Payload inválido. Contrato original não enviado.');
        }

        // Busca a proposta original atraves do contrato original
        // TODO: A historia PLV-2021 Ira entrar futuramente buscar o contrato ao inves da proposta, ja deixei pronta a pesquisa do contrato
        //PLV-2646 - Fix 4 - INÍCIO - Crítica para cancelamento de proposta não contratada
       //PLV-5884 FIX-04 INICIO
        /*if(payloadTO.proposta.contratoOriginal == null || payloadTO.proposta.contratoOriginal.chaveContrato == null){
            this.orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.add(gerarDevolutiva(mapCriticas.get(56),'SF',null, 56));
            return; 
        }*/
        
        List<Contract> listContrato = ContractDAO.getInstance().buscarContratosPorId(new Set<Id>{Id.valueOf(payloadTO.proposta.contratoOriginal.chaveContrato)});

        // Verifica se o contrato foi encontrado
        if(listContrato.isEmpty()){
            // Gera a devolutiva abortiva de proposta original nao encontrada
            this.orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.add(gerarDevolutiva(mapCriticas.get(69), 'SF', null, 69));
            return;
        }

        this.contratoOriginal = listContrato[0];

        // Verifica se o contrato original ja esta cancelado
        if(this.contratoOriginal.Status == 'Cancelado'){
            // Gera a devolutiva abortiva de proposta já cancelada
            this.orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.add(gerarDevolutiva(mapCriticas.get(56),'SF',null, 56));
            return;
        }
        //PLV-5884 FIX-04 FIM
        this.propostaOriginal = this.contratoOriginal.Proposta__r; 

        // Busca o orcamento original
        List<Opportunity> listOrcamento = OpportunityDAO.getInstance().buscarOportunidadesPorId(new Set<Id>{ this.propostaOriginal.OpportunityId });
        //PLV-5884 FIX-05 INICIO
        /*
        if(listOrcamento.isEmpty()){
            // Gera a devolutiva abortiva de proposta original nao encontrada
            this.orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.add(gerarDevolutiva(mapCriticas.get(69), 'SF', null, 69));
            //throw new OrcamentoBuilderException('Orçamento original não encontrado!');
        }
        */
        //PLV-5884 FIX-05 FIM
        if(!listOrcamento.isEmpty()) this.orcamentoOriginal = listOrcamento[0];  //PLV-5884 FIX-02 INICIO/FIM

        // Busca o produto
        List<Product2> listProduto = daoProduto.buscarProdutoPorId(new Set<Id>{this.contratoOriginal.Produto__c}); //PLV-5884 INICIO/FIM
        if(listProduto.isEmpty()){
        // Produto não encontrado
        }
        produto = listProduto[0];


        // Popula o mapa de garantias do produto
        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r){
            this.mapGarantiaProdutoPorSigla.put(garantiaProduto.Garantia__r.Sigla__c,garantiaProduto);
            this.mapGarantiaPorSigla.put(garantiaProduto.Garantia__r.Sigla__c,garantiaProduto.Garantia__r);
        }

    }
    // PLV-2372-29 FIM

    private String gerarNumeroProposta(){

        ContratoTO.SolicitarTituloTO solicitarTituloTO = new ContratoTO.SolicitarTituloTO();
        solicitarTituloTO.quantidade = 1;
        solicitarTituloTO.origemproposta = 18;

        // gera um numero de proposta
        HerokuResponseTO.TituloTO retorno = HerokuService.getInstance().gerarNumeroProposta(solicitarTituloTO);

        return String.valueOf(retorno.data.numeros[0]);
    }

    private void clonarFilhosOrcamento(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosOrcamento = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'CriticaOrcamento__c', 'GarantiaOrcamento__c', 'ContratanteOrcamento__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos de orcamento
        String criterio = (orcamentoOriginal != null) ? 'Orcamento__c = \'' + orcamentoOriginal.Id + '\'' : 'Orcamento__c = \'' + 'DELETED' + '\''; //PLV-5884 FIX-02 INCIO/FIM
        if (orcamentoOriginal != Null) listFilhosOrcamento.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        // Armazena os filhos diretos de orcamento no OrcamentoWrapper
        for(SObject sobj : listFilhosOrcamento){

            switch on sobj{

                when ContratanteOrcamento__c contratanteOrcamento{

                    Orcamento.ContratanteWrapper contratanteWrapper = new Orcamento.ContratanteWrapper();

                    // Remove os dados de precificacao
                    contratanteOrcamento.TaxaPura__c = null;
                    contratanteOrcamento.TaxaComercial__c = null;
                    contratanteOrcamento.TaxaTotal__c = null;
                    contratanteOrcamento.PremioPuro__c = null;
                    contratanteOrcamento.PremioComercial__c = null;
                    contratanteOrcamento.PremioTotal__c = null;
                    contratanteOrcamento.DescontoAgravoMonetarioComercial__c = null;
                    contratanteOrcamento.DescontoAgravoMonetarioInformado__c = null;
                    contratanteOrcamento.DescontoAgravoMonetarioTecnico__c = null;
                    contratanteOrcamento.DescontoAgravoPercentualComercial__c = null;
                    contratanteOrcamento.DescontoAgravoPercentualInformado__c = null;
                    contratanteOrcamento.DescontoAgravoPercentualTecnico__c = null;

                    contratanteWrapper.sfContratante = contratanteOrcamento;
                    contratanteWrapper.chave = String.valueOf(contratanteOrcamento.Id);

                    this.orcamento.orcamentoWrapper.contratantesWrapper.add( contratanteWrapper );
                }
                when GarantiaOrcamento__c garantiaOrcamento {
                    Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();

                    // Remove os dados de precificacao
                    garantiaOrcamento.TaxaPura__c = null;
                    garantiaOrcamento.TaxaComercial__c = null;
                    garantiaOrcamento.TaxaTotal__c = null;
                    garantiaOrcamento.TaxaMensal__c = null;
                    garantiaOrcamento.TaxaAnual__c = null;
                    garantiaOrcamento.TaxaPuroInterno__c = null;
                    garantiaOrcamento.TaxaPuroResseguro__c = null;
                    garantiaOrcamento.PremioPuro__c = null;
                    garantiaOrcamento.PremioComercial__c = null;
                    garantiaOrcamento.PremioTotal__c = null;
                    garantiaOrcamento.PremioPuroResseguro__c = null;
                    garantiaOrcamento.PremioPuroInterno__c = null;
                    garantiaOrcamento.PremioComercialDesconto__c = null;
                    garantiaOrcamento.PremioPuroDesconto__c = null;
                    garantiaOrcamento.DescontoAgravoMonetarioComercial__c = null;
                    garantiaOrcamento.DescontoAgravoMonetarioInformado__c = null;
                    garantiaOrcamento.DescontoAgravoMonetarioTecnico__c = null;
                    garantiaOrcamento.DescontoAgravoPercentualComercial__c = null;
                    garantiaOrcamento.DescontoAgravoPercentualInformado__c = null;
                    garantiaOrcamento.DescontoAgravoPercentualTecnico__c = null;

                    garantiaWrapper.sfGarantiaOrcamento = garantiaOrcamento;

                    setGarantiaId.add(garantiaOrcamento.Garantia__c);
                    this.orcamento.orcamentoWrapper.garantiasWrapper.add(garantiaWrapper);
                }
                when CriticaOrcamento__c criticaOrcamento{
                    criticaOrcamento.Id = null;
                    this.orcamento.orcamentoWrapper.criticas.add(criticaOrcamento);
                }
            }
        }

        // Busca as garantias para inserir a sigla na GarantiaWrapper correspondente
        List<Garantia__c> listGarantias = GarantiaDAO.getInstance().buscarGarantiasPorId(setGarantiaId, null);

        for(Garantia__c garantia : listGarantias){

            mapSiglaGarantiaPorId.put(garantia.Id, garantia.Sigla__c);

        }

        // Insere a sigla na garantiaWrapper
        for(Orcamento.GarantiaWrapper garantiaWrapper : this.orcamento.orcamentoWrapper.garantiasWrapper){
            garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaOrcamento.Garantia__c);
        }

        // limpa os filhos do orcamento
        listFilhosOrcamento.clear();

        // Busca os filhos diretos de orcamento
        criterio = (orcamentoOriginal != null) ? 'Oportunidade__c = \'' + orcamentoOriginal.Id + '\'':'Oportunidade__c = \'' + 'DELETED' + '\''; //PLV-5884 FIX-02 INCIO/FIM
        if (orcamentoOriginal != Null) listFilhosOrcamento.addAll(this.clonarSObjects(new Set<String>{'RemuneracaoOrcamento__c'}, criterio, true));

        // Armazena os filhos diretos de orcamento no OrcamentoWrapper
        for(SObject sobj : listFilhosOrcamento){

            switch on sobj{

                when RemuneracaoOrcamento__c RemuneracaoOrcamento{
                    Orcamento.RemuneracaoOrcamentoWrapper remuneracaoOrcamentoWrapper = new Orcamento.RemuneracaoOrcamentoWrapper();
                    remuneracaoOrcamentoWrapper.sfRemuneracaoOrcamento = RemuneracaoOrcamento;
                    remuneracaoOrcamentoWrapper.chave = String.valueOf(RemuneracaoOrcamento.Id);

                    this.orcamento.orcamentoWrapper.remuneracaoOrcamentoWrapper.add( remuneracaoOrcamentoWrapper );
                }
            }
        }




    }

    private void clonarContratantes(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosContratanteOrcamento = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'GrupoOrcamento__c', 'GarantiaContratanteOrcamento__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = (orcamentoOriginal != Null)?'ContratanteOrcamento__r.Orcamento__c = \'' + orcamentoOriginal.Id + '\'':'ContratanteOrcamento__r.Orcamento__c = \'' + 'DELETED' + '\''; //PLV-5884 FIX-02 INICIO/FIM
        if (orcamentoOriginal != Null) listFilhosContratanteOrcamento.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper){

            for(SObject sobj : listFilhosContratanteOrcamento){

                switch on sobj{

                    when GarantiaContratanteOrcamento__c garantiaContratanteOrcamento {
                        Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();

                        // Remove os dados de precificacao
                        garantiaContratanteOrcamento.TaxaPura__c = null;
                        garantiaContratanteOrcamento.TaxaComercial__c = null;
                        garantiaContratanteOrcamento.TaxaTotal__c = null;
                        garantiaContratanteOrcamento.TaxaMensal__c = null;
                        garantiaContratanteOrcamento.TaxaAnual__c = null;
                        garantiaContratanteOrcamento.TaxaPuroInterno__c = null;
                        garantiaContratanteOrcamento.TaxaPuroResseguro__c = null;
                        garantiaContratanteOrcamento.PremioPuro__c = null;
                        garantiaContratanteOrcamento.PremioComercial__c = null;
                        garantiaContratanteOrcamento.PremioTotal__c = null;
                        garantiaContratanteOrcamento.PremioPuroResseguro__c = null;
                        garantiaContratanteOrcamento.PremioPuroInterno__c = null;
                        garantiaContratanteOrcamento.PremioComercialDesconto__c = null;
                        garantiaContratanteOrcamento.PremioPuroDesconto__c = null;
                        garantiaContratanteOrcamento.DescontoAgravoMonetarioComercial__c = null;
                        garantiaContratanteOrcamento.DescontoAgravoMonetarioInformado__c = null;
                        garantiaContratanteOrcamento.DescontoAgravoMonetarioTecnico__c = null;
                        garantiaContratanteOrcamento.DescontoAgravoPercentualComercial__c = null;
                        garantiaContratanteOrcamento.DescontoAgravoPercentualInformado__c = null;
                        garantiaContratanteOrcamento.DescontoAgravoPercentualTecnico__c = null;

                        garantiaWrapper.sfGarantiasContratanteOrcamento = garantiaContratanteOrcamento;

                        setGarantiaId.add(garantiaContratanteOrcamento.Garantia__c);

                        if(contratanteWrapper.chave == String.valueOf(garantiaContratanteOrcamento.ContratanteOrcamento__c)){
                            contratanteWrapper.garantiasWrapper.add(garantiaWrapper);
                        }
                    }

                    when GrupoOrcamento__c grupoOrcamento{
                        Orcamento.GrupoWrapper grupoWrapper = new Orcamento.GrupoWrapper();
                        grupoWrapper.sfGrupo = grupoOrcamento;

                        // Remove dados de precificacao
                        grupoOrcamento.TaxaPura__c = null;
                        grupoOrcamento.TaxaComercial__c = null;
                        grupoOrcamento.TaxaTotal__c = null;
                        grupoOrcamento.PremioPuro__c = null;
                        grupoOrcamento.PremioComercial__c = null;
                        grupoOrcamento.PremioTotal__c = null;
                        grupoOrcamento.DescontoAgravoMonetarioComercial__c = null;
                        grupoOrcamento.DescontoAgravoMonetarioInformado__c = null;
                        grupoOrcamento.DescontoAgravoMonetarioTecnico__c = null;
                        grupoOrcamento.DescontoAgravoPercentualComercial__c = null;
                        grupoOrcamento.DescontoAgravoPercentualInformado__c = null;
                        grupoOrcamento.DescontoAgravoPercentualTecnico__c = null;

                        grupoWrapper.chave = String.valueOf(grupoOrcamento.Id);

                        if(contratanteWrapper.chave == String.valueOf(grupoOrcamento.ContratanteOrcamento__c)){
                            contratanteWrapper.gruposWrapper.add(grupoWrapper);
                        }
                    }
                }
            }
        }

        // Busca as garantias para inserir a sigla na GarantiaWrapper correspondente
        List<Garantia__c> listGarantias = GarantiaDAO.getInstance().buscarGarantiasPorId(setGarantiaId, null);

        for(Garantia__c garantia : listGarantias){

            mapSiglaGarantiaPorId.put(garantia.Id, garantia.Sigla__c);

        }

        // Insere a sigla na garantiaWrapper do contratante
        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper) {

            for (Orcamento.GarantiaWrapper garantiaWrapper : contratanteWrapper.garantiasWrapper) {
                garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiasContratanteOrcamento.Garantia__c);
            }

        }


    }

    private void clonarGrupos(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosGrupoOrcamento = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'SeguradoOrcamento__c', 'GarantiaGrupoOrcamento__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = (orcamentoOriginal != Null) ? 'GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c = \'' + orcamentoOriginal.Id + '\'' : 'GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c = \'' + 'DELETED' + '\''; //PLV-5884 FIX-02 INICIO/FIM
        if (orcamentoOriginal != Null) listFilhosGrupoOrcamento.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper){

            for(Orcamento.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){

                for(SObject sobj : listFilhosGrupoOrcamento){

                    switch on sobj{

                        when GarantiaGrupoOrcamento__c garantiaGrupoOrcamento {
                            Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();

                            // Remove os dados de precificacao
                            garantiaGrupoOrcamento.TaxaPura__c = null;
                            garantiaGrupoOrcamento.TaxaComercial__c = null;
                            garantiaGrupoOrcamento.TaxaTotal__c = null;
                            garantiaGrupoOrcamento.TaxaMensal__c = null;
                            garantiaGrupoOrcamento.TaxaAnual__c = null;
                            garantiaGrupoOrcamento.TaxaPuroInterno__c = null;
                            garantiaGrupoOrcamento.TaxaPuroResseguro__c = null;
                            garantiaGrupoOrcamento.PremioPuro__c = null;
                            garantiaGrupoOrcamento.PremioComercial__c = null;
                            garantiaGrupoOrcamento.PremioTotal__c = null;
                            garantiaGrupoOrcamento.PremioPuroResseguro__c = null;
                            garantiaGrupoOrcamento.PremioPuroInterno__c = null;
                            garantiaGrupoOrcamento.PremioComercialDesconto__c = null;
                            garantiaGrupoOrcamento.PremioPuroDesconto__c = null;
                            garantiaGrupoOrcamento.DescontoAgravoMonetarioComercial__c = null;
                            garantiaGrupoOrcamento.DescontoAgravoMonetarioInformado__c = null;
                            garantiaGrupoOrcamento.DescontoAgravoMonetarioTecnico__c = null;
                            garantiaGrupoOrcamento.DescontoAgravoPercentualComercial__c = null;
                            garantiaGrupoOrcamento.DescontoAgravoPercentualInformado__c = null;
                            garantiaGrupoOrcamento.DescontoAgravoPercentualTecnico__c = null;

                            garantiaWrapper.sfGarantiaGrupoOrcamento = garantiaGrupoOrcamento;
                            setGarantiaId.add(garantiaGrupoOrcamento.Garantia__c);

                            if(grupoWrapper.chave == String.valueOf(garantiaGrupoOrcamento.GrupoOrcamento__c)){
                                grupoWrapper.garantiasWrapper.add(garantiaWrapper);
                            }
                        }

                        when SeguradoOrcamento__c seguradoOrcamento{
                            Orcamento.SeguradoWrapper seguradoWrapper = new Orcamento.SeguradoWrapper();
                            seguradoWrapper.chave = String.valueOf(seguradoOrcamento.Id);

                            // Remove os dados de precificacao
                            seguradoOrcamento.TaxaPura__c = null;
                            seguradoOrcamento.TaxaComercial__c = null;
                            seguradoOrcamento.TaxaTotal__c = null;
                            seguradoOrcamento.PremioPuro__c = null;
                            seguradoOrcamento.PremioComercial__c = null;
                            seguradoOrcamento.PremioTotal__c = null;
                            seguradoOrcamento.DescontoAgravoMonetarioComercial__c = null;
                            seguradoOrcamento.DescontoAgravoMonetarioInformado__c = null;
                            seguradoOrcamento.DescontoAgravoMonetarioTecnico__c = null;
                            seguradoOrcamento.DescontoAgravoPercentualComercial__c = null;
                            seguradoOrcamento.DescontoAgravoPercentualInformado__c = null;
                            seguradoOrcamento.DescontoAgravoPercentualTecnico__c = null;

                            seguradoWrapper.sfSegurado = seguradoOrcamento;

                            if(grupoWrapper.chave == String.valueOf(seguradoOrcamento.GrupoOrcamento__c)){
                                grupoWrapper.seguradosWrapper.add(seguradoWrapper);
                            }
                        }
                    }
                }

            }
        }

        // Busca as garantias para inserir a sigla na GarantiaWrapper correspondente
        List<Garantia__c> listGarantias = GarantiaDAO.getInstance().buscarGarantiasPorId(setGarantiaId, null);

        for(Garantia__c garantia : listGarantias){

            mapSiglaGarantiaPorId.put(garantia.Id, garantia.Sigla__c);

        }

        // Insere a sigla na garantiaWrapper do grupo
        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper) {

            for(Orcamento.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for (Orcamento.GarantiaWrapper garantiaWrapper : grupoWrapper.garantiasWrapper) {
                    garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaGrupoOrcamento.Garantia__c);
                }
            }

        }


    }

    private void clonarSegurados(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhoSeguradoOrcamento = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'GarantiaSeguradoOrcamento__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = (orcamentoOriginal != Null) ? 'SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c = \'' + orcamentoOriginal.Id + '\'' : 'SeguradoOrcamento__r.GrupoOrcamento__r.ContratanteOrcamento__r.Orcamento__c = \'' + 'DELETED' + '\''; //PLV-5884 FIX-02 INICIO/FIM
        if (orcamentoOriginal != Null) listFilhoSeguradoOrcamento.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper){

            for(Orcamento.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){

                for(Orcamento.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

                    for (SObject sobj : listFilhoSeguradoOrcamento) {

                        switch on sobj {

                            when GarantiaSeguradoOrcamento__c garantiaSeguradoOrcamento {
                                Orcamento.GarantiaWrapper garantiaWrapper = new Orcamento.GarantiaWrapper();

                                // Remove os dados de precificacao
                                garantiaSeguradoOrcamento.TaxaPura__c = null;
                                garantiaSeguradoOrcamento.TaxaComercial__c = null;
                                garantiaSeguradoOrcamento.TaxaTotal__c = null;
                                garantiaSeguradoOrcamento.TaxaMensal__c = null;
                                garantiaSeguradoOrcamento.TaxaAnual__c = null;
                                garantiaSeguradoOrcamento.TaxaPuroInterno__c = null;
                                garantiaSeguradoOrcamento.TaxaPuroResseguro__c = null;
                                garantiaSeguradoOrcamento.PremioPuro__c = null;
                                garantiaSeguradoOrcamento.PremioComercial__c = null;
                                garantiaSeguradoOrcamento.PremioTotal__c = null;
                                garantiaSeguradoOrcamento.PremioPuroResseguro__c = null;
                                garantiaSeguradoOrcamento.PremioPuroInterno__c = null;
                                garantiaSeguradoOrcamento.PremioComercialDesconto__c = null;
                                garantiaSeguradoOrcamento.PremioPuroDesconto__c = null;
                                garantiaSeguradoOrcamento.DescontoAgravoMonetarioComercial__c = null;
                                garantiaSeguradoOrcamento.DescontoAgravoMonetarioInformado__c = null;
                                garantiaSeguradoOrcamento.DescontoAgravoMonetarioTecnico__c = null;
                                garantiaSeguradoOrcamento.DescontoAgravoPercentualComercial__c = null;
                                garantiaSeguradoOrcamento.DescontoAgravoPercentualInformado__c = null;
                                garantiaSeguradoOrcamento.DescontoAgravoPercentualTecnico__c = null;

                                garantiaWrapper.sfGarantiaSeguradoOrcamento = garantiaSeguradoOrcamento;

                                setGarantiaId.add(garantiaSeguradoOrcamento.Garantia__c);

                                if (seguradoWrapper.chave == String.valueOf(garantiaSeguradoOrcamento.SeguradoOrcamento__c)){
                                    seguradoWrapper.garantiasWrapper.add(garantiaWrapper);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Busca as garantias para inserir a sigla na GarantiaWrapper correspondente
        List<Garantia__c> listGarantias = GarantiaDAO.getInstance().buscarGarantiasPorId(setGarantiaId, null);

        for(Garantia__c garantia : listGarantias){

            mapSiglaGarantiaPorId.put(garantia.Id, garantia.Sigla__c);

        }

        // Insere a sigla na garantiaWrapper do segurado
        for(Orcamento.ContratanteWrapper contratanteWrapper : this.orcamento.orcamentoWrapper.contratantesWrapper) {

            for(Orcamento.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for(Orcamento.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

                    for (Orcamento.GarantiaWrapper garantiaWrapper : seguradoWrapper.garantiasWrapper) {
                        garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaSeguradoOrcamento.Garantia__c);
                    }
                }
            }
        }

    }

    /* ---------------------------------- FIM HELPERS ------------------------------------------------------------- */


}