/**
 * Created by Alessandro Ponte on 29/01/2019.
 */

public without sharing class PropostaMassificadosCancelamentoBuilder extends PropostaBuilder {

    private static final PropostaMassificadosCancelamentoBuilder instance = new PropostaMassificadosCancelamentoBuilder();
    public static PropostaMassificadosCancelamentoBuilder getInstance() { return instance; }
    private PropostaMassificadosCancelamentoBuilder() { this.setInstancia(this); }
    private ProductDAO daoProduto = ProductDAO.getInstance();
    private AccountBO boConta = AccountBO.getInstance();

    // instancias de negocio
    private Map<String, GarantiaProduto__c> mapGarantiaProdutoPorSigla = new Map<String, GarantiaProduto__c>();
    private Map<String,Garantia__c> mapGarantiaPorSigla = new Map<String, Garantia__c>();
    private Map<Integer, CriticaParceiro__c>  mapCriticas = new Map<Integer, CriticaParceiro__c>();
    private Product2 produto;
    private Quote propostaOriginal;
    private Contract contratoOriginal;
    private Opportunity novoOrcamento;

    // Constantes
    private final Map<String, RecordType> mapRecordType = new Map<String, RecordType>();

    // Conversores
    private final Map<String,String> mapTipoProposta = new Map<String, String>{'CAN' => 'Cancelamento'};

    /* ---------------------------------- INTERFACE --------------------------------------------------------------- */

    // INICIO | PLV-2355-Hackathon
    public override List<Proposta.BeneficiariosWrapper> gerarBeneficiarios(List<EmissaoTO.BeneficiarioTO> beneficiariosTO, Proposta.SeguradoWrapper seguradoWrapper) { return null; }
    public override void gerarContas(EmissaoTO.PayloadTO payloadTO, List<Proposta.PessoaWrapper> listPessoasWrapper){}
    // FIN | PLV-2355-Hackathon
    
    public override void validarPayload(EmissaoTO.PayloadTO payloadTO) {
    }

    public override void gerarProposta(EmissaoTO.PayloadTO payloadTO) {

        System.debug('PAYLOAD DE CANCELAMENTO');
        System.debug(JSON.serialize(payloadTO, true));

        OrcamentoMassificadosCancelamentoBuilder orcamentoMassificadosCancelamentoBuilder = OrcamentoMassificadosCancelamentoBuilder.getInstance();
        Orcamento orcamento = orcamentoMassificadosCancelamentoBuilder.montarOrcamento(payloadTO, null, true);

        System.debug('ORCAMENTO GERADO ------------------------------------------ ' + orcamento);

        // Verifica se existe devolutivas e aborta a geracao de proposta
        if(!orcamento.orcamentoWrapper.retornoWrapper.retorno.devolutivas.isEmpty()){
            this.proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.addAll(parseDevolutivasOrcamentoParaProposta(orcamento));
            return;
        }

        // Recupera o orcamento gerado
        novoOrcamento = orcamento.orcamentoWrapper.sfOrcamento;

        // Gera e popula as variaveis auxiliares do negocio
        this.buscarRegistrosDominios(payloadTO);

        // Verifica se existe devolutivas e aborta a geracao de proposta
        if(!this.proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.isEmpty()){
            return;
        }

        // Recupera o numero da proposta do name do orcamento
        List<String> splitNumeroProposta = novoOrcamento.Name.split(this.SEPARADOR_NOME_ORCAMENTO);
        String numeroProposta = splitNumeroProposta[1];

        // Popula a proposta
        this.popularModeloProposta(payloadTO, this.proposta.propostaWrapper.sfProposta, novoOrcamento ,18, numeroProposta);

        // Clona os filhos da proposta
        //PLV-5884 INICIO FIX-06
        if(this.propostaOriginal != null){ //PLV-5884 FIX-07 INICIO/FIM
            this.clonarFilhosProposta();
        }else{
            this.clonarFilhosContrato();
        }
        //PLV-5884 FIM FIX-06
        
        // Gera os contratantes
        this.gerarContratantes(payloadTO);

        System.debug('PROPOSTA WRAPPER FINAL');
        System.debug(JSON.serialize(this.proposta));

    }

    public override List<Proposta.ContratanteWrapper> gerarContratantes(EmissaoTO.PayloadTO payloadTO){

        
        // Clona os contratantes
        //PLV-5884 FIX-10 INICIO
        if(this.propostaOriginal != null){
            this.clonarContratantes();
        }else{
            this.clonarContratantesContrato();
        }
        //PLV-5884 FIX-10 FIM

        // Gera os contratantes e os dados de pagamento
        for (EmissaoTO.ContratanteTO contratanteTO : payloadTO.proposta.contratoOriginal.contratantes){

            for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

                // Recupera o contratante da proposta
                ContratanteProposta__c contratanteProposta = contratanteWrapper.sfContratante;

                // Preenche os dados de pagamento
                if(contratanteTO.dadosPagamento != null){
                    this.popularModelosContratanteComDadosPagamento(contratanteTO.dadosPagamento,contratanteProposta);
                }

            }

        }

        this.gerarGrupos(null, null);

        return null;
    }

    public override List<Proposta.GrupoWrapper> gerarGrupos(List<EmissaoTO.GrupoTO> gruposTO, String numeroContratante) {

        //PLV-5884 FIX-10 INICIO
        if(this.propostaOriginal != null){
            this.clonarGrupos();
        }else{
            this.clonarGruposContrato();
        }
        //PLV-5884 FIX-10 FIM
       
        this.gerarSegurados(null, null, null);

        return null;
    }

    public override List<Proposta.SeguradoWrapper> gerarSegurados(List<EmissaoTO.SeguradoTO> seguradosTO, String numeroContratante, String numeroGrupo) {

        //PLV-5884 FIX-10 INICIO
        if(this.propostaOriginal != null){
            this.clonarSegurados();
        }else{
            this.clonarSeguradosContrato();
        }
        //PLV-5884 FIX-10 FIM

        return null;
    }

    public override void popularPrecificacao(EmissaoTO.PrecificacaoTO precificacaoTO) {


        // Verifica se existe calculo para essa proposta
        if(precificacaoTO != null){
            // Popula a precificacao da proposta
            this.popularPrecificaoProposta(precificacaoTO);

            // Verifica se existem contratantes na precificacao
            if(precificacaoTO.contratantes != null) {

                // Popula a precificacao dos contratantes e suas coberturas
                for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper)
                {

                    this.popularPrecificacaoContratanteProposta(precificacaoTO, contratanteWrapper);

                }
            }
        }
    }

    // INICIO | PLV-2402-30
	public override void gerarCriticas(EmissaoTO.PayloadTO payloadTO, List<Proposta.CriticaPropostaWrapper> listCriticasWrapper){}
	// INICIO | PLV-2402-30

    public override Proposta inserirRegistros(Proposta proposta) {
		system.debug('ACESSOU Cancelamento');
        // Instancias
        List<GarantiaProposta__c> listGarantiaProposta = new List<GarantiaProposta__c>();
        List<GarantiaContratanteProposta__c> listGarantiaContratanteProposta = new List<GarantiaContratanteProposta__c>();
        List<GarantiasGrupoProposta__c> listGarantiaGrupoProposta = new List<GarantiasGrupoProposta__c>();
        List<GarantiaSeguradoProposta__c> listGarantiaSeguradoProposta = new List<GarantiaSeguradoProposta__c>();
        List<RemuneracaoProposta__c> listRemuneracaoProposta = new List<RemuneracaoProposta__c>();
        List<FavorecidoRemuneracaoProposta__c> listFavorecidoRemuneracaoProposta = new List<FavorecidoRemuneracaoProposta__c>();
        List<CriticaProposta__c> listCriticaProposta = new List<CriticaProposta__c>();
        List<ContratanteProposta__c> listContratanteProposta = new List<ContratanteProposta__c>();
        List<GrupoProposta__c> listGrupoProposta = new List<GrupoProposta__c>();
        List<SeguradoProposta__c> listSeguradoProposta = new List<SeguradoProposta__c>();
        List<BeneficiarioSeguradoProposta__c> listBeneficiarioSeguradoProposta = new List<BeneficiarioSeguradoProposta__c>();

        // Verifica se existe devolutivas e aborta o processo de insercao dos registros
        if(!this.proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.isEmpty()){
            return proposta;
        }

        // Insere a proposta
        try{
            insert this.proposta.propostaWrapper.sfProposta;
        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Inserir proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        //Atribui id da proposta nas Remuneracoes
        for(Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper : this.proposta.propostaWrapper.remuneracaoPropostaWrapper){
            remuneracaoPropostaWrapper.sfRemuneracaoProposta.Id = null;
            remuneracaoPropostaWrapper.sfRemuneracaoProposta.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
            listRemuneracaoProposta.add(remuneracaoPropostaWrapper.sfRemuneracaoProposta);

        }

        // Atribui id da proposta nas garantias
        for(Proposta.GarantiaWrapper garantiaWrapper : this.proposta.propostaWrapper.garantiasWrapper){
            garantiaWrapper.sfGarantiaProposta.Id = null;
            garantiaWrapper.sfGarantiaProposta.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
            listGarantiaProposta.add(garantiaWrapper.sfGarantiaProposta);

        }

        //Atribui id da proposta nos contratantes
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper ){

            contratanteWrapper.sfContratante.Id = null;
            contratanteWrapper.sfContratante.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
            listContratanteProposta.add(contratanteWrapper.sfContratante);

        }

        // Atribui Id da proposta nas criticas da proposta
        for(CriticaProposta__c criticaProposta : this.proposta.propostaWrapper.criticas){
            criticaProposta.Id = null;
            criticaProposta.Proposta__c = this.proposta.propostaWrapper.sfProposta.Id;
            listCriticaProposta.add(criticaProposta);
        }

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
        try{
            insert listCriticaProposta;
        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Inserir criticas da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        // Atribui o id das remuneracoes da proposta nos favorecidos

        for(Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper : this.proposta.propostaWrapper.remuneracaoPropostaWrapper){

            for(Proposta.FavorecidoRemuneracaoWrapper favorecidoRemuneracaoWrapper : remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper){
                favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta.Id = null;
                favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta.RemuneracaoProposta__c = remuneracaoPropostaWrapper.sfRemuneracaoProposta.Id;
                listFavorecidoRemuneracaoProposta.add(favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta);
            }
        }

        // Atribui o id do contratante nas garantias e grupos
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(Proposta.GarantiaWrapper garantiaWrapper : contratanteWrapper.garantiasWrapper){

                // Atribui o id do contratante para a garantiaWrapper
                garantiaWrapper.sfGarantiaContratanteProposta.Id = null;
                garantiaWrapper.sfGarantiaContratanteProposta.ContratanteProposta__c = contratanteWrapper.sfContratante.Id;
                listGarantiaContratanteProposta.add(garantiaWrapper.sfGarantiaContratanteProposta);

            }

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){

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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for (Proposta.GarantiaWrapper garantiaWrapper : grupoWrapper.garantiasWrapper) {

                    // Atribui o id do grupo para a garantiaWrapper
                    garantiaWrapper.sfGarantiaGrupoProposta.Id = null;
                    garantiaWrapper.sfGarantiaGrupoProposta.GrupoProposta__c = grupoWrapper.sfGrupo.Id;
                    listGarantiaGrupoProposta.add(garantiaWrapper.sfGarantiaGrupoProposta);

                }

                for (Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for(Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper){

                    for (Proposta.GarantiaWrapper garantiaWrapper : seguradoWrapper.garantiasWrapper) {

                        // Atribui o id do grupo para a garantiaWrapper
                        garantiaWrapper.sfGarantiaSeguradoProposta.Id = null;
                        garantiaWrapper.sfGarantiaSeguradoProposta.SeguradoProposta__c = seguradoWrapper.sfSegurado.Id;
                        listGarantiaSeguradoProposta.add(garantiaWrapper.sfGarantiaSeguradoProposta);

                    }

                    for (Proposta.BeneficiariosWrapper beneficiariosWrapper : seguradoWrapper.beneficiariosWrapper) {

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
        
        //PLV-5884 INICIO FIX-10
        // Atualiza o status da proposta
        this.proposta.propostaWrapper.sfProposta.Status = 'Disponível para contratação';

        try{
            update this.proposta.propostaWrapper.sfProposta;
        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Atualizar proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
        //PLV-5884 FIM FIX-10

        return proposta;

    }

    /* ---------------------------------- FIM INTERFACE ----------------------------------------------------------- */

    /* ---------------------------------- MODELOS ----------------------------------------------------------------- */

    private List<SObject> clonarSObjects(Set<String> setSObjectName, String criterio, Boolean comId){

        List<SObject> listSObjects = new List<SObject>();
        List<SObject> listSObjectsClonados = new List<SObject>();

        // Busca os filhos direto da Proposta original
        for(String sobjectName : setSObjectName){
            listSObjects.addAll(this.buscarDadosObjeto(sobjectName, criterio));
        }

        if(!listSObjects.isEmpty()){
            listSObjectsClonados = listSObjects.deepClone(comId);
        }

        return listSObjectsClonados;

    }

    private void popularModeloProposta(EmissaoTO.PayloadTO objPayloadTO, Quote proposta, Opportunity orcamento, Integer origem, String numeroProposta){
        try
        {
            proposta.Origem__c = String.valueOf(origem);
            proposta.NumeroProposta__c = numeroProposta;
            proposta.Name = this.gerarQuoteName(String.valueOf(origem), numeroProposta);
            //PLV-2291 INICIO Criacao de campo unico
            proposta.NumeroPropostaUnico__c = this.gerarQuoteName(String.valueOf(origem), numeroProposta);
            //PLV-2291 FIM Criacao de campo unico
            proposta.VigenciaInicial__c = Date.valueOf(objPayloadTO.proposta.dataCancelamento) > this.propostaOriginal.VigenciaFinal__c ? this.propostaOriginal.VigenciaInicial__c : Date.valueOf(objPayloadTO.proposta.dataCancelamento); //PGP-5559234
            proposta.Tipo__c = mapTipoProposta.get(objPayloadTO.proposta.tipoSeguro);
            proposta.TipoEndosso__c = objPayloadTO.proposta.tipoEndosso;
            proposta.Status = 'Em criação';
            proposta.Produto__c = produto.Id;
            proposta.OpportunityId = orcamento.Id;
            proposta.DataEmissao__c = System.today();

            //PLV-5884 INICIO FIX-07
            // Clonado da proposta e contrato orginal
            proposta.VigenciaFinal__c = this.propostaOriginal == null ? this.contratoOriginal.VigenciaFinal__c : this.propostaOriginal.VigenciaFinal__c; 
            proposta.Parceiro__c = this.propostaOriginal == null ? this.contratoOriginal.Parceiro__c : this.propostaOriginal.Parceiro__c;
            proposta.IdContratoParceiro__c = this.propostaOriginal == null ? this.contratoOriginal.IdContratoParceiro__c : this.propostaOriginal.IdContratoParceiro__c;
            proposta.IdContratanteParceiro__c = this.propostaOriginal == null ? this.contratoOriginal.IdContratanteParceiro__c : this.propostaOriginal.IdContratanteParceiro__c;
            proposta.CanalDistribuicao__c = this.propostaOriginal == null ? this.contratoOriginal.CanalDistribuicao__c : this.propostaOriginal.CanalDistribuicao__c;
            proposta.MeioComercializacao__c = this.propostaOriginal == null ? this.contratoOriginal.MeioComercializacao__c : this.propostaOriginal.MeioComercializacao__c;
            proposta.Description = this.propostaOriginal == null ? this.contratoOriginal.Description : this.propostaOriginal.Description;
            proposta.RamoSeguro__c = this.propostaOriginal == null ? this.contratoOriginal.RamoSeguro__c : this.propostaOriginal.RamoSeguro__c;
            proposta.Modalidade__c = this.propostaOriginal == null ? this.contratoOriginal.ModalidadeSeguro__c : this.propostaOriginal.Modalidade__c;
            proposta.TipoViagem__c = this.propostaOriginal == null ? this.contratoOriginal.TipoViagem__c : this.propostaOriginal.TipoViagem__c;
            proposta.Payload__c = this.propostaOriginal == null ? this.contratoOriginal.Payload__c : this.propostaOriginal.Payload__c;
            proposta.Empresa__c = this.propostaOriginal == null ? this.contratoOriginal.Seguradora__r.Id : this.propostaOriginal.Empresa__c; //PLV-5884 FIX-09 INICIO/FIM
            proposta.PremioInformado__c = this.propostaOriginal == null ? this.contratoOriginal.PremioInformado__c : this.propostaOriginal.PremioInformado__c;
            proposta.ContractId = this.contratoOriginal.Id;
            
            if(this.propostaOriginal != null){
                proposta.ResponsavelFinanceiro__c = this.propostaOriginal.ResponsavelFinanceiro__c;
                proposta.TecnicoResponsavel__c = this.propostaOriginal.TecnicoResponsavel__c;
                proposta.InformacoesEvento__c = this.propostaOriginal.InformacoesEvento__c;
                proposta.TipoEvento__c = this.propostaOriginal.TipoEvento__c;
                proposta.DataCriacaoPortal__c = this.propostaOriginal.DataCriacaoPortal__c;
                proposta.CustoApolice__c = this.propostaOriginal.CustoApolice__c;
                proposta.DataProtocolo__c = this.propostaOriginal.DataProtocolo__c;
                proposta.TipoVigencia__c = this.propostaOriginal.TipoVigencia__c;
                proposta.RecordtypeId = this.propostaOriginal.RecordtypeId; //PLV - 4582 - INICIO/FIM    
            }

            //PLV-5884 FIM FIX-07
            // PLV-2378-29 - INICIO
            proposta.Massificados__c = true;
            // PLV-2378-29 - FINAL
        }
        catch(Exception e)
        {
            throw new PropostaBuilderException('Exception: Erro ao gerar a proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

    }

    private void popularModelosContratanteComDadosPagamento(EmissaoTO.DadosPagamentoTO dadosPagamentoTO, ContratanteProposta__c contratanteProposta){

        // Popula os dados de pagamento para o contratante
        try{

            contratanteProposta.QuantidadeParcelas__c = dadosPagamentoTO.quantidadeParcelas;
        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao popular o contratante da proposta com dados de pagamento \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }

    /* ---------------------------------- FIM MODELOS ------------------------------------------------------------- */


    /* ---------------------------------- PRECIFICACAO ------------------------------------------------------------ */

    private void popularPrecificaoProposta (EmissaoTO.PrecificacaoTO precificacaoTO){

        // Instancias
        Map<String, EmissaoTO.CoberturaTO> mapCoberturaTOPropostaPorSigla = new Map<String, EmissaoTO.CoberturaTO>();

        // Popula a precificacao da proposta
        this.popularPrecificacaoModeloProposta(precificacaoTO, this.proposta.propostaWrapper.sfProposta);

        // Itera para popular mapa das coberturas da proposta
        for(EmissaoTO.CoberturaTO coberturaTO: precificacaoTO.coberturas) {
            mapCoberturaTOPropostaPorSigla.put(coberturaTO.sigla,coberturaTO);
        }

        for(Proposta.GarantiaWrapper garantiaWrapper : this.proposta.propostaWrapper.garantiasWrapper){

            EmissaoTO.CoberturaTO coberturaTO = mapCoberturaTOPropostaPorSigla.get(garantiaWrapper.sigla);

            // Verifica se a coberturaTO eh dessa garantia
            if(coberturaTO == null){ continue; }
            //Popula a precificacao na garantia da proposta
            this.popularPrecificacaoModeloGarantiaProposta(coberturaTO, garantiaWrapper.sfGarantiaProposta);

        }

    }

    private void popularPrecificacaoContratanteProposta(EmissaoTO.PrecificacaoTO precificacaoTO, Proposta.ContratanteWrapper contratanteWrapper ){

        // Instancias
        Map<String, EmissaoTO.ContratanteTO > mapContratanteTOPorNumero = new Map<String, EmissaoTO.ContratanteTO>();
        Map<String, EmissaoTO.CoberturaTO > mapCoberturaTOContratantePorSigla = new Map<String, EmissaoTO.CoberturaTO>();

        // Recupera o ContratanteProposta__c
        ContratanteProposta__c contratanteProposta = contratanteWrapper.sfContratante;

        // Itera para popular mapa de contratanteTO
        for(EmissaoTO.ContratanteTO contratanteTO : precificacaoTO.contratantes)
        {
            if(contratanteTO.numero == null){ contratanteTO.numero = '1'; }
            mapContratanteTOPorNumero.put(contratanteTO.numero,contratanteTo);
        }

        // Recupera o contratanteTO pelo Contratante da Proposta
        EmissaoTO.ContratanteTO contratanteTO = mapContratanteTOPorNumero.get(String.valueOf(contratanteProposta.Numero__c));

        // Verifica se eh a precificacao desse contratante
        if(contratanteTO != null) {

            // Popula a precificacao do contratante da proposta
            this.popularPrecificacaoModeloContratanteProposta(contratanteTO, contratanteProposta);

            // Popula o mapa de cobertura do contratante se existir coberturas
            if (contratanteTO.coberturas != null) {

                // Popula a precificacao das coberturas dos contratantes
                for (EmissaoTO.CoberturaTO coberturaTO : contratanteTO.coberturas) {
                    mapCoberturaTOContratantePorSigla.put(coberturaTO.sigla, coberturaTO);
                }

            }

            for (Proposta.GarantiaWrapper garantiaWrapper : contratanteWrapper.garantiasWrapper) {

                EmissaoTO.CoberturaTO coberturaTO = mapCoberturaTOContratantePorSigla.get(garantiaWrapper.sigla);

                // Verifica se a coberturaTO eh dessa garantia
                if (coberturaTO == null) {
                    continue;
                }
                // Popula precificacao na garantia do contratante
                this.popularPrecificacaoModeloGarantiaContratanteProposta(coberturaTO, garantiaWrapper.sfGarantiaContratanteProposta);

            }

            // Verifica se existe precificacao para os grupos desse contratante
            if (contratanteTO.grupos != null) {

                // Popula a precificacao dos grupos e suas coberturas
                for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                    this.popularPrecificacaoGrupoProposta(contratanteTO, grupoWrapper);

                }
            }
        }

    }

    private void popularPrecificacaoGrupoProposta(EmissaoTO.ContratanteTO contratanteTO, Proposta.GrupoWrapper grupoWrapper){

        GrupoProposta__c grupoProposta = grupoWrapper.sfGrupo;

        // Instancias
        Map<String, EmissaoTO.GrupoTO > mapGrupoTOPorNumero = new Map<String, EmissaoTO.GrupoTO>();
        Map<String, EmissaoTO.CoberturaTO > mapCoberturaTOGrupoPorSigla = new Map<String, EmissaoTO.CoberturaTO>();

        // Itera para popular mapa de grupoTO
        for(EmissaoTO.GrupoTO grupoTO : contratanteTO.grupos){

            if(grupoTO.numero == null){ grupoTO.numero = '1'; }
            mapGrupoTOPorNumero.put(grupoTO.numero,grupoTO);
        }

        // Recupera o GrupoTO pelo Grupo da Proposta
        EmissaoTO.GrupoTO grupoTO = mapGrupoTOPorNumero.get(String.valueOf(grupoProposta.Numero__c));

        // Verifica se eh a precificacao desse grupo
        if(grupoTO != null) {

            // Popula a precificacao do grupo da proposta
            this.popularPrecificacaoModeloGrupoProposta(grupoTO, grupoProposta);

            // Popula o mapa de cobertura do grupo se existir coberturas
            if (grupoTO.coberturas != null) {

                // Popula o mapa das coberturas desse grupo
                for (EmissaoTO.CoberturaTO coberturaTO : grupoTO.coberturas) {
                    mapCoberturaTOGrupoPorSigla.put(coberturaTO.sigla, coberturaTO);
                }

            }

            // Popula a precificacao das garantias desse grupo
            for (Proposta.GarantiaWrapper garantiaWrapper : grupoWrapper.garantiasWrapper) {

                // Recupera a coberturaTO
                EmissaoTO.CoberturaTO coberturaTO = mapCoberturaTOGrupoPorSigla.get(garantiaWrapper.sigla);

                // Verifica se a coberturaTO eh dessa garantia
                if (coberturaTO == null) {
                    continue;
                }

                // Popula precificacao na garantia do grupo
                this.popularPrecificacaoModeloGarantiaGrupoProposta(coberturaTO, garantiaWrapper.sfGarantiaGrupoProposta);

            }

            // Verifica se existe precificacao para os segurados desse grupo
            if (grupoTO.segurados != null) {

                // Popula a precificacao dos segurados e suas coberturas
                for (Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

                    this.popularPrecificacaoSeguradoProposta(grupoTO, seguradoWrapper);

                }

            }

        }


    }

    private void popularPrecificacaoSeguradoProposta(EmissaoTO.GrupoTO grupoTO, Proposta.SeguradoWrapper seguradoWrapper){

        SeguradoProposta__c seguradoProposta = seguradoWrapper.sfSegurado;

        // Instancias
        Map<String, EmissaoTO.SeguradoTO > mapSeguradoTOPorNumero = new Map<String, EmissaoTO.SeguradoTO>();
        Map<String, EmissaoTO.CoberturaTO > mapCoberturaTOSeguradoPorSigla = new Map<String, EmissaoTO.CoberturaTO>();

        // Itera para popular mapa de seguradoTO
        for(EmissaoTO.SeguradoTO seguradoTO : grupoTO.segurados){

            if(seguradoTO.numero == null){ seguradoTO.numero = '1'; }
            mapSeguradoTOPorNumero.put(seguradoTO.numero, seguradoTO);
        }

        // Recupera o SeguradoTO pelo Segurado da proposta
        EmissaoTO.SeguradoTO seguradoTO = mapSeguradoTOPorNumero.get(String.valueOf(seguradoProposta.Numero__c));

        // Verifica se eh a precificacao desse segurado
        if(seguradoTO != null) {

            // Popula a precificacao do segurado da proposta
            this.popularPrecificacaoModeloSeguradoProposta(seguradoTO, seguradoProposta);

            // Popula o mapa de cobertura do grupo se existir coberturas
            if (seguradoTO.coberturas != null) {

                // Popula o mapa da precificacao das coberturas desse grupo
                for (EmissaoTO.CoberturaTO coberturaTO : seguradoTO.coberturas) {
                    mapCoberturaTOSeguradoPorSigla.put(coberturaTO.sigla, coberturaTO);
                }

            }

            // Popula a precificacao das garantias desse segurado
            for (Proposta.GarantiaWrapper garantiaWrapper : seguradoWrapper.garantiasWrapper) {

                EmissaoTO.CoberturaTO coberturaTO = mapCoberturaTOSeguradoPorSigla.get(garantiaWrapper.sigla);

                // Verifica se a coberturaTO eh dessa garantia
                if (coberturaTO == null) {
                    continue;
                }
                // Popula precificacao na garantia do segurado
                this.popularPrecificacaoModeloGarantiaSeguradoProposta(coberturaTO, garantiaWrapper.sfGarantiaSeguradoProposta);

            }
        }

    }

    private void popularPrecificacaoModeloProposta(EmissaoTO.PrecificacaoTO precificacaoTO, Quote proposta){

        try {


            // preenche os dados de precificação da proposta
            proposta.Juros__c = precificacaoTO.juros;
            proposta.IOF__c = precificacaoTO.iof;
            proposta.Encargos__c = precificacaoTO.encargos;
            proposta.CustoApolice__c = precificacaoTO.custoApolice;

            proposta.PremioComercial__c = precificacaoTO.premio.comercial;
            proposta.PremioPuro__c = precificacaoTO.premio.puro;
            proposta.PremioTotal__c = precificacaoTO.premio.total;

            proposta.TaxaComercial__c = precificacaoTO.taxa.comercial;
            proposta.TaxaPura__c = precificacaoTO.taxa.pura;
            proposta.TaxaTotal__c = precificacaoTO.taxa.total;

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao na proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }

    private void popularPrecificacaoModeloGarantiaProposta(EmissaoTO.CoberturaTO coberturaTO, GarantiaProposta__c garantiaProposta){

        try{
            // pega os premios e taxas do calculo
            garantiaProposta.PremioPuro__c      = coberturaTO.premio.puro;
            garantiaProposta.PremioComercial__c = coberturaTO.premio.comercial;
            garantiaProposta.PremioTotal__c     = coberturaTO.premio.total;
            garantiaProposta.TaxaPura__c        = coberturaTO.taxa.pura;
            garantiaProposta.TaxaComercial__c   = coberturaTO.taxa.comercial;
            garantiaProposta.TaxaTotal__c       = coberturaTO.taxa.total;
            garantiaProposta.LoteCapitalizacao__c = coberturaTO.loteCapitalizacao;
            garantiaProposta.StatusCapitalizacao__c = coberturaTO.statusCapitalizacao;
            garantiaProposta.NumeroSerie__c = coberturaTO.numeroSerie;
            garantiaProposta.NumeroSorte__c = coberturaTO.numeroSorte;
            garantiaProposta.IOF__c             = coberturaTO.iof!=null ? coberturaTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

            if(!String.isBlank(coberturaTO.dataSorteio)){
                garantiaProposta.DataSorteio__c 	= Date.valueOf(coberturaTO.dataSorteio);
            }
            if(!String.isBlank(coberturaTO.dataSolicitacao)){
                garantiaProposta.DataSolicitacaoCapitalizacao__c = Date.valueOf(coberturaTO.dataSolicitacao);
            }

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao na garantia da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }


    }

    private void popularPrecificacaoModeloGarantiaContratanteProposta(EmissaoTO.CoberturaTO coberturaTO, GarantiaContratanteProposta__c garantiaContratanteProposta){

        try {
            // pega os premios e taxas do calculo
            garantiaContratanteProposta.PremioPuro__c = coberturaTO.premio.puro;
            garantiaContratanteProposta.PremioComercial__c = coberturaTO.premio.comercial;
            garantiaContratanteProposta.PremioTotal__c = coberturaTO.premio.total;
            garantiaContratanteProposta.TaxaPura__c = coberturaTO.taxa.pura;
            garantiaContratanteProposta.TaxaComercial__c = coberturaTO.taxa.comercial;
            garantiaContratanteProposta.TaxaTotal__c = coberturaTO.taxa.total;
            garantiaContratanteProposta.IOF__c             = coberturaTO.iof!=null ? coberturaTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao na garantia do contratante da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

    }

    private void popularPrecificacaoModeloGarantiaGrupoProposta(EmissaoTO.CoberturaTO coberturaTO, GarantiasGrupoProposta__c garantiaGrupoProposta){

        try{
            // pega os premios e taxas do calculo
            garantiaGrupoProposta.PremioPuro__c      = coberturaTO.premio.puro;
            garantiaGrupoProposta.PremioComercial__c = coberturaTO.premio.comercial;
            garantiaGrupoProposta.PremioTotal__c     = coberturaTO.premio.total;
            garantiaGrupoProposta.TaxaPura__c        = coberturaTO.taxa.pura;
            garantiaGrupoProposta.TaxaComercial__c   = coberturaTO.taxa.comercial;
            garantiaGrupoProposta.TaxaTotal__c       = coberturaTO.taxa.total;
            garantiaGrupoProposta.IOF__c             = coberturaTO.iof!=null ? coberturaTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao na garantia do grupo da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

    }

    private void popularPrecificacaoModeloGarantiaSeguradoProposta(EmissaoTO.CoberturaTO coberturaTO, GarantiaSeguradoProposta__c garantiaSeguradoProposta){

        try{
            // pega os premios e taxas do calculo
            garantiaSeguradoProposta.PremioPuro__c       = coberturaTO.premio.puro;
            garantiaSeguradoProposta.PremioComercial__c  = coberturaTO.premio.comercial;
            garantiaSeguradoProposta.PremioTotal__c      = coberturaTO.premio.total;
            garantiaSeguradoProposta.TaxaPura__c         = coberturaTO.taxa.pura;
            garantiaSeguradoProposta.TaxaComercial__c    = coberturaTO.taxa.comercial;
            garantiaSeguradoProposta.TaxaTotal__c        = coberturaTO.taxa.total;
            garantiaSeguradoProposta.IOF__c              = coberturaTO.iof!=null ? coberturaTO.iof : 0 ;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao na garantia do segurado da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

    }

    private void popularPrecificacaoModeloContratanteProposta(EmissaoTO.ContratanteTO contratanteTO, ContratanteProposta__c contratanteProposta){

        try {
            contratanteProposta.IOF__c = contratanteTO.iof!=null ? contratanteTO.iof : 0 ;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            contratanteProposta.PremioComercial__c = contratanteTO.premio.comercial;
            contratanteProposta.PremioPuro__c = contratanteTO.premio.puro;
            contratanteProposta.PremioTotal__c = contratanteTO.premio.total;

            contratanteProposta.TaxaComercial__c = contratanteTO.taxa.comercial;
            contratanteProposta.TaxaPura__c = contratanteTO.taxa.pura;
            contratanteProposta.TaxaTotal__c = contratanteTO.taxa.total;

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao no contratante proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }



    }

    private void popularPrecificacaoModeloGrupoProposta(EmissaoTO.GrupoTO grupoTO, GrupoProposta__c grupoProposta){

        try {
            // if(grupoCalculoPremio.iof == null)
            //  grupoProposta.IOF__c = precificacaoTO.iof;
            // else
            grupoProposta.IOF__c = grupoTO.iof!=null ? grupoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B

            grupoProposta.PremioComercial__c = grupoTO.premio.comercial;
            grupoProposta.PremioPuro__c = grupoTO.premio.puro;
            grupoProposta.PremioTotal__c = grupoTO.premio.total;

            grupoProposta.TaxaComercial__c = grupoTO.taxa.comercial;
            grupoProposta.TaxaPura__c = grupoTO.taxa.pura;
            grupoProposta.TaxaTotal__c = grupoTO.taxa.total;

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao no grupo da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

    }

    private void popularPrecificacaoModeloSeguradoProposta(EmissaoTO.SeguradoTO seguradoTO, SeguradoProposta__c seguradoProposta){

        try{
            seguradoProposta.IOF__c                 = seguradoTO.iof!=null ? seguradoTO.iof : 0;//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
            seguradoProposta.PremioComercial__c     = seguradoTO.premio.comercial;
            seguradoProposta.PremioPuro__c          = seguradoTO.premio.puro;
            seguradoProposta.PremioTotal__c         = seguradoTO.premio.total;
            seguradoProposta.TaxaComercial__c       = seguradoTO.taxa.comercial;
            seguradoProposta.TaxaPura__c            = seguradoTO.taxa.pura;
            seguradoProposta.TaxaTotal__c           = seguradoTO.taxa.total;

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao inserir a precificacao no segurado proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }
    }

    /* ---------------------------------- FIM PRECIFICACAO -------------------------------------------------------- */

    /* ---------------------------------- HELPERS ----------------------------------------------------------------- */
    //PLV-5884 FIX-01 INICIO
    // PLV-2372-29 INICIO
    private void buscarRegistrosDominios(EmissaoTO.PayloadTO payloadTO){

        // Verifica se o contrato original veio no payload
        if(payloadTO.proposta.contratoOriginal == null){
            throw new PropostaBuilderException('Payload inválido. Contrato original não enviado.');
        }

        //Recupera e mapeia todas as criticas do parceiro
        for(CriticaParceiro__c critica : CriticaParceiroDAO.getInstance().buscarCriticasParceiro(new Set<String>{payloadTO.proposta.parceiro})){
            mapCriticas.put(Integer.ValueOf(critica.Name), critica);
        }

        // Busca os tipos de registro de proposta e popula o mapa
        for(RecordType tipo: RecordTypeDAO.getInstance().getListRecordTypeBySobject('Quote')){
            mapRecordType.put(tipo.DeveloperName, tipo);
        }

//        String quoteName = this.gerarQuoteName(String.valueOf(payloadTO.proposta.contratoOriginal.origem), payloadTO.proposta.contratoOriginal.numero);

        // Busca a proposta original
        List<Contract> listContrato = ContractDAO.getInstance().buscarContratosPorId(new Set<Id>{Id.valueOf(payloadTO.proposta.contratoOriginal.chaveContrato)});

        if(listContrato.isEmpty()){
            // Gera a devolutiva abortiva de proposta original nao encontrada
            this.proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.add(gerarDevolutiva(mapCriticas.get(69),'SF',null, 69));
            return;
        }

        this.propostaOriginal = listContrato[0].Proposta__r;
        this.contratoOriginal = listContrato[0];
        System.debug('Danilo contratoOriginal ' + contratoOriginal); //PLV-5884 FIX-03 INICIO/FIM 
        System.debug('Danilo this.contratoOriginal ' + this.contratoOriginal); //PLV-5884 FIX-03 INICIO/FIM 
        System.debug('Danilo contratoOriginal.Status ' + contratoOriginal.Status); //PLV-5884 FIX-03 INICIO/FIM 
        System.debug('Danilo this.contratoOriginal.Status ' + this.contratoOriginal.Status); //PLV-5884 FIX-03 INICIO/FIM 
        // Verifica se o contrato ja foi cancelado
        if(this.contratoOriginal.Status == 'Cancelado'){ //PLV-5884 FIX-03 INICIO/FIM 
            // Gera a devolutiva abortiva de proposta já cancelada
            this.proposta.propostaWrapper.retornoWrapper.retorno.devolutivas.add(gerarDevolutiva(mapCriticas.get(56),'SF',null, 56));
            return;
        }

        // Busca o produto
        List<Product2> listProduto = daoProduto.buscarProdutoPorId(new Set<Id>{String.valueOf(this.contratoOriginal.Produto__c)});
        produto = listProduto[0];

        // Popula o mapa de garantias do produto
        for(GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r){
            this.mapGarantiaProdutoPorSigla.put(garantiaProduto.Garantia__r.Sigla__c,garantiaProduto);
            this.mapGarantiaPorSigla.put(garantiaProduto.Garantia__r.Sigla__c,garantiaProduto.Garantia__r);
        }

    }
    // PLV-2372-29 FIM
    //PLV-5884 FIX-01 FIM 


    private void clonarFilhosProposta(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'RemuneracaoProposta__c', 'CriticaProposta__c', 'GarantiaProposta__c', 'ContratanteProposta__c'};
        set<Id> setRemuneracaoPropostaId = new Set<Id>();
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos de proposta
        String criterio = 'Proposta__c = \'' + propostaOriginal.Id + '\'';
        listFilhosProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        // Armazena os filhos diretos de proposta na PropostaWrapper
        for(SObject sobj : listFilhosProposta){

            switch on sobj{

                when ContratanteProposta__c contratanteProposta{

                    Proposta.ContratanteWrapper contratanteWrapper = new Proposta.ContratanteWrapper();

                    // Remove os dados de precificacao
                    contratanteProposta.TaxaPura__c = null;
                    contratanteProposta.TaxaComercial__c = null;
                    contratanteProposta.TaxaTotal__c = null;
                    contratanteProposta.PremioPuro__c = null;
                    contratanteProposta.PremioComercial__c = null;
                    contratanteProposta.PremioTotal__c = null;
                    contratanteProposta.DescontoAgravoMonetarioComercial__c = null;
                    contratanteProposta.DescontoAgravoMonetarioInformado__c = null;
                    contratanteProposta.DescontoAgravoMonetarioTecnico__c = null;
                    contratanteProposta.DescontoAgravoPercentualComercial__c = null;
                    contratanteProposta.DescontoAgravoPercentualInformado__c = null;
                    contratanteProposta.DescontoAgravoPercentualTecnico__c = null;

                    contratanteWrapper.sfContratante = contratanteProposta;
                    contratanteWrapper.chave = String.valueOf(contratanteProposta.Id);

                    this.proposta.propostaWrapper.contratantesWrapper.add( contratanteWrapper );
                }
                when RemuneracaoProposta__c remuneracaoProposta{
                    Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper = new Proposta.RemuneracaoPropostaWrapper();
                    remuneracaoPropostaWrapper.sfRemuneracaoProposta = remuneracaoProposta;
                    remuneracaoPropostaWrapper.chave = String.valueOf(remuneracaoProposta.Id);

                    this.proposta.propostaWrapper.remuneracaoPropostaWrapper.add( remuneracaoPropostaWrapper );
                    setRemuneracaoPropostaId.add(remuneracaoProposta.Id);
                }
                when GarantiaProposta__c garantiaProposta{
                    Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();

                    // Remove os dados de precificacao
                    garantiaProposta.TaxaPura__c = null;
                    garantiaProposta.TaxaComercial__c = null;
                    garantiaProposta.TaxaTotal__c = null;
                    garantiaProposta.PremioPuro__c = null;
                    garantiaProposta.PremioComercial__c = null;
                    garantiaProposta.PremioTotal__c = null;
                    garantiaProposta.DescontoAgravoMonetarioComercial__c = null;
                    garantiaProposta.DescontoAgravoMonetarioInformado__c = null;
                    garantiaProposta.DescontoAgravoMonetarioTecnico__c = null;
                    garantiaProposta.DescontoAgravoPercentualComercial__c = null;
                    garantiaProposta.DescontoAgravoPercentualInformado__c = null;
                    garantiaProposta.DescontoAgravoPercentualTecnico__c = null;

                    garantiaWrapper.sfGarantiaProposta = garantiaProposta;
                    setGarantiaId.add(garantiaProposta.Garantia__c);
                    this.proposta.propostaWrapper.garantiasWrapper.add(garantiaWrapper);
                }
                when CriticaProposta__c criticaProposta{
                    criticaProposta.Id = null;
                    this.proposta.propostaWrapper.criticas.add(criticaProposta);
                }
            }
        }

        // Limpa a lista ja processada
        listFilhosProposta.clear();

        // Buscar os filhos de segundo grau da proposta
        // Busca os favorecidos da remuneracao
        criterio = 'RemuneracaoProposta__r.Proposta__c = \'' + propostaOriginal.Id + '\'';
        listFilhosProposta.addAll(this.clonarSObjects(new Set<String>{'FavorecidoRemuneracaoProposta__c'}, criterio, false));

        for(SObject sobj : listFilhosProposta){

            switch on sobj{

                when FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta{

                    for(Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper : this.proposta.propostaWrapper.remuneracaoPropostaWrapper){

                        if(remuneracaoPropostaWrapper.chave == String.valueOf(favorecidoRemuneracaoProposta.RemuneracaoProposta__c)){

                            // Instancias
                            Proposta.FavorecidoRemuneracaoWrapper favorecidoRemuneracaoWrapper = new Proposta.FavorecidoRemuneracaoWrapper();

                            // Armazena o favorecido da remuneracao
                            favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta = favorecidoRemuneracaoProposta;
                            remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper.add(favorecidoRemuneracaoWrapper);
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

        // Insere a sigla na garantiaWrapper
        for(Proposta.GarantiaWrapper garantiaWrapper : this.proposta.propostaWrapper.garantiasWrapper){
            garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaProposta.Garantia__c);
        }


    }

    private void clonarContratantes(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosContratanteProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'GrupoProposta__c', 'GarantiaContratanteProposta__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = 'ContratanteProposta__r.Proposta__c = \'' + propostaOriginal.Id + '\'';
        listFilhosContratanteProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(SObject sobj : listFilhosContratanteProposta){

                switch on sobj{

                    when GarantiaContratanteProposta__c garantiaContratanteProposta{
                        Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();

                        // Remove os dados de precificacao
                        garantiaContratanteProposta.TaxaPura__c = null;
                        garantiaContratanteProposta.TaxaComercial__c = null;
                        garantiaContratanteProposta.TaxaTotal__c = null;
                        garantiaContratanteProposta.PremioPuro__c = null;
                        garantiaContratanteProposta.PremioComercial__c = null;
                        garantiaContratanteProposta.PremioTotal__c = null;
                        garantiaContratanteProposta.DescontoAgravoMonetarioComercial__c = null;
                        garantiaContratanteProposta.DescontoAgravoMonetarioInformado__c = null;
                        garantiaContratanteProposta.DescontoAgravoMonetarioTecnico__c = null;
                        garantiaContratanteProposta.DescontoAgravoPercentualComercial__c = null;
                        garantiaContratanteProposta.DescontoAgravoPercentualInformado__c = null;
                        garantiaContratanteProposta.DescontoAgravoPercentualTecnico__c = null;

                        garantiaWrapper.sfGarantiaContratanteProposta = garantiaContratanteProposta;

                        setGarantiaId.add(garantiaContratanteProposta.Garantia__c);

                        if(contratanteWrapper.chave == String.valueOf(garantiaContratanteProposta.ContratanteProposta__c)){
                            contratanteWrapper.garantiasWrapper.add(garantiaWrapper);
                        }
                    }

                    when GrupoProposta__c grupoProposta{
                        Proposta.GrupoWrapper grupoWrapper = new Proposta.GrupoWrapper();

                        // Remove os dados de precificacao
                        grupoProposta.TaxaPura__c = null;
                        grupoProposta.TaxaComercial__c = null;
                        grupoProposta.TaxaTotal__c = null;
                        grupoProposta.PremioPuro__c = null;
                        grupoProposta.PremioComercial__c = null;
                        grupoProposta.PremioTotal__c = null;
                        grupoProposta.DescontoAgravoMonetarioComercial__c = null;
                        grupoProposta.DescontoAgravoMonetarioInformado__c = null;
                        grupoProposta.DescontoAgravoMonetarioTecnico__c = null;
                        grupoProposta.DescontoAgravoPercentualComercial__c = null;
                        grupoProposta.DescontoAgravoPercentualInformado__c = null;
                        grupoProposta.DescontoAgravoPercentualTecnico__c = null;

                        grupoWrapper.sfGrupo = grupoProposta;
                        grupoWrapper.chave = String.valueOf(grupoProposta.Id);

                        if(contratanteWrapper.chave == String.valueOf(grupoProposta.ContratanteProposta__c)){
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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper) {

            for (Proposta.GarantiaWrapper garantiaWrapper : contratanteWrapper.garantiasWrapper) {
                garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaContratanteProposta.Garantia__c);
            }

        }


    }

    private void clonarGrupos(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosGrupoProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'SeguradoProposta__c', 'GarantiasGrupoProposta__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = 'GrupoProposta__r.ContratanteProposta__r.Proposta__c = \'' + propostaOriginal.Id + '\'';
        listFilhosGrupoProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){

                for(SObject sobj : listFilhosGrupoProposta){

                    switch on sobj{

                        when GarantiasGrupoProposta__c garantiaGrupoProposta {
                            Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();

                            // Remove os dados de precificacao
                            garantiaGrupoProposta.TaxaPura__c = null;
                            garantiaGrupoProposta.TaxaComercial__c = null;
                            garantiaGrupoProposta.TaxaTotal__c = null;
                            garantiaGrupoProposta.PremioPuro__c = null;
                            garantiaGrupoProposta.PremioComercial__c = null;
                            garantiaGrupoProposta.PremioTotal__c = null;
                            garantiaGrupoProposta.DescontoAgravoMonetarioComercial__c = null;
                            garantiaGrupoProposta.DescontoAgravoMonetarioInformado__c = null;
                            garantiaGrupoProposta.DescontoAgravoMonetarioTecnico__c = null;
                            garantiaGrupoProposta.DescontoAgravoPercentualComercial__c = null;
                            garantiaGrupoProposta.DescontoAgravoPercentualInformado__c = null;
                            garantiaGrupoProposta.DescontoAgravoPercentualTecnico__c = null;

                            garantiaWrapper.sfGarantiaGrupoProposta = garantiaGrupoProposta;
                            setGarantiaId.add(garantiaGrupoProposta.Garantia__c);

                            if(grupoWrapper.chave == String.valueOf(garantiaGrupoProposta.GrupoProposta__c)){
                                grupoWrapper.garantiasWrapper.add(garantiaWrapper);
                            }
                        }

                        when SeguradoProposta__c seguradoProposta{
                            Proposta.SeguradoWrapper seguradoWrapper = new Proposta.SeguradoWrapper();

                            // Remove os dados de precificacao
                            seguradoProposta.TaxaPura__c = null;
                            seguradoProposta.TaxaComercial__c = null;
                            seguradoProposta.TaxaTotal__c = null;
                            seguradoProposta.PremioPuro__c = null;
                            seguradoProposta.PremioComercial__c = null;
                            seguradoProposta.PremioTotal__c = null;
                            seguradoProposta.DescontoAgravoMonetarioComercial__c = null;
                            seguradoProposta.DescontoAgravoMonetarioInformado__c = null;
                            seguradoProposta.DescontoAgravoMonetarioTecnico__c = null;
                            seguradoProposta.DescontoAgravoPercentualComercial__c = null;
                            seguradoProposta.DescontoAgravoPercentualInformado__c = null;
                            seguradoProposta.DescontoAgravoPercentualTecnico__c = null;

                            seguradoWrapper.sfSegurado = seguradoProposta;
                            seguradoWrapper.chave = String.valueOf(seguradoProposta.Id);

                            if(grupoWrapper.chave == String.valueOf(seguradoProposta.GrupoProposta__c)){
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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper) {

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for (Proposta.GarantiaWrapper garantiaWrapper : grupoWrapper.garantiasWrapper) {
                    garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaGrupoProposta.Garantia__c);
                }
            }

        }


    }

    private void clonarSegurados(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhoSeguradoProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'BeneficiarioSeguradoProposta__c', 'GarantiaSeguradoProposta__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = 'SeguradoProposta__r.GrupoProposta__r.ContratanteProposta__r.Proposta__c = \'' + propostaOriginal.Id + '\'';
        listFilhoSeguradoProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){

                for(Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

                    for (SObject sobj : listFilhoSeguradoProposta) {

                        switch on sobj {

                            when GarantiaSeguradoProposta__c garantiaSeguradoProposta {
                                Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();

                                // Remove os dados de precificacao
                                garantiaSeguradoProposta.TaxaPura__c = null;
                                garantiaSeguradoProposta.TaxaComercial__c = null;
                                garantiaSeguradoProposta.TaxaTotal__c = null;
                                garantiaSeguradoProposta.PremioPuro__c = null;
                                garantiaSeguradoProposta.PremioComercial__c = null;
                                garantiaSeguradoProposta.PremioTotal__c = null;
                                garantiaSeguradoProposta.DescontoAgravoMonetarioComercial__c = null;
                                garantiaSeguradoProposta.DescontoAgravoMonetarioInformado__c = null;
                                garantiaSeguradoProposta.DescontoAgravoMonetarioTecnico__c = null;
                                garantiaSeguradoProposta.DescontoAgravoPercentualComercial__c = null;
                                garantiaSeguradoProposta.DescontoAgravoPercentualInformado__c = null;
                                garantiaSeguradoProposta.DescontoAgravoPercentualTecnico__c = null;

                                garantiaWrapper.sfGarantiaSeguradoProposta = garantiaSeguradoProposta;

                                setGarantiaId.add(garantiaSeguradoProposta.Garantia__c);

                                if (seguradoWrapper.chave == String.valueOf(garantiaSeguradoProposta.SeguradoProposta__c)){
                                    seguradoWrapper.garantiasWrapper.add(garantiaWrapper);
                                }
                            }

                            when BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta {
                                Proposta.BeneficiariosWrapper beneficiariosWrapper = new Proposta.BeneficiariosWrapper();
                                beneficiariosWrapper.sfBeneficiarioSeguradoProposta = beneficiarioSeguradoProposta;

                                if (seguradoWrapper.chave == String.valueOf(beneficiarioSeguradoProposta.SeguradoProposta__c)){
                                    seguradoWrapper.beneficiariosWrapper.add(beneficiariosWrapper);
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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper) {

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for(Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

                    for (Proposta.GarantiaWrapper garantiaWrapper : seguradoWrapper.garantiasWrapper) {
                        garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaSeguradoProposta.Garantia__c);
                    }
                }
            }
        }

    }

    /*
  	 * @author Everymind - Sprint 22
  	 * @Descrição: monta o retorno do processamento de proposta
 	*/
    public RetornoPropostaRestTO.ValidacaopropostaTO converterPropostaParaRetornoProposta()
    {

        List<RetornoPropostaRestTO.DevolutivasTO> listDevolutivaTO =  this.proposta.propostaWrapper.retornoWrapper.retorno.devolutivas;

        try {


            if(listDevolutivaTO.isEmpty() && this.proposta.propostaWrapper.sfProposta.Id != null){

                RetornoPropostaRestTO.DevolutivasTO devolutivaTO = new RetornoPropostaRestTO.DevolutivasTO();
                devolutivaTO.tipoRegistro = 1;
                devolutivaTO.origem = 'INT';
                devolutivaTO.numeroCampo = 0;
                devolutivaTO.descricao = 'EMISSÃO: - numero:' + this.proposta.propostaWrapper.sfProposta.NumeroProposta__c + ' - Contratação realizada com sucesso.';
                devolutivaTO.codigo = 0;

                listDevolutivaTO.add(devolutivaTO);
            }

            // Busca dados da proposta gerada para retornar
            if(this.proposta.propostaWrapper.sfProposta != null){
                this.proposta.propostaWrapper.retornoWrapper.retorno.proposta = new RetornoPropostaRestTO.PropostaTO();
                this.proposta.propostaWrapper.retornoWrapper.retorno.proposta.numero = (this.proposta.propostaWrapper.sfProposta.NumeroProposta__c != null) ? this.proposta.propostaWrapper.sfProposta.NumeroProposta__c : null; //TKCL-246 INICIO-FIM
                this.proposta.propostaWrapper.retornoWrapper.retorno.proposta.origem = (this.proposta.propostaWrapper.sfProposta.Origem__c != null) ? Integer.valueOf(this.proposta.propostaWrapper.sfProposta.Origem__c) : null;
            }

        }catch (Exception e){
            throw new PropostaBuilderException('Exception: Erro ao gerar retorno da proposta \r - Causa: ' + e.getCause() + ' \r - linha: ' +  e.getLineNumber() + ' \r - Mensagem: ' + e.getMessage());
        }

        return this.proposta.propostaWrapper.retornoWrapper.retorno; 
    }

    //PLV-5884 INICIO FIX-06
    public void clonarFilhosContrato(){
        
        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'RemuneracaoContrato__c', 'CriticaContrato__c', 'GarantiaContrato__c', 'ContratanteContrato__c'};
        set<Id> setRemuneracaoContratoId = new Set<Id>();
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos de proposta
        String criterio = 'Contrato__c = \'' + contratoOriginal.Id + '\'';
        listFilhosProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        // Armazena os filhos diretos de proposta na PropostaWrapper
        for(SObject sobj : listFilhosProposta){

            switch on sobj{

                when ContratanteContrato__c contratanteContrato{

                    Proposta.ContratanteWrapper contratanteWrapper = new Proposta.ContratanteWrapper();
                    ContratanteProposta__c contratanteprop = new ContratanteProposta__c(); 
                    // Remove os dados de precificacao

                    contratanteprop.Celular__c = contratanteContrato.Celular__c;
                    contratanteprop.Conta__c = contratanteContrato.Conta__c;
                    contratanteprop.CurrencyIsoCode = contratanteContrato.CurrencyIsoCode;
                    contratanteprop.Email__c = contratanteContrato.Email__c;
                    contratanteprop.FormaPagamento__c = contratanteContrato.FormaPagamento__c;
                    contratanteprop.PlanoParcelamento__c = contratanteContrato.PlanoParcelamento__c;
                    contratanteprop.QuantidadeParcelas__c = contratanteContrato.QuantidadeParcelas__c;
                    contratanteprop.Recorrencia__c = contratanteContrato.Recorrencia__c;
                    contratanteprop.ResponsavelPagamento__c = contratanteContrato.ResponsavelPagamento__c;
                    contratanteprop.Telefone__c = contratanteContrato.Telefone__c;
                    contratanteprop.Tipo__c = contratanteContrato.Tipo__c;
                    contratanteprop.TipoResponsavelPagamento__c = contratanteContrato.TipoResponsavelPagamento__c;
                    contratanteprop.VencimentoDemaisParcelas__c = contratanteContrato.VencimentoDemaisParcelas__c;
                    contratanteprop.VencimentoPrimeiraParcela__c = contratanteContrato.VencimentoPrimeiraParcela__c;
                    
                    contratanteprop.TaxaPura__c = null;
                    contratanteprop.TaxaComercial__c = null;
                    contratanteprop.TaxaTotal__c = null;
                    contratanteprop.PremioPuro__c = null;
                    contratanteprop.PremioComercial__c = null;
                    contratanteprop.PremioTotal__c = null;
                    contratanteprop.DescontoAgravoMonetarioComercial__c = null;
                    contratanteprop.DescontoAgravoMonetarioInformado__c = null;
                    contratanteprop.DescontoAgravoMonetarioTecnico__c = null;
                    contratanteprop.DescontoAgravoPercentualComercial__c = null;
                    contratanteprop.DescontoAgravoPercentualInformado__c = null;
                    contratanteprop.DescontoAgravoPercentualTecnico__c = null;
                    if(contratanteContrato.VencimentoDemaisParcelas__c == null){
                        contratanteprop.VencimentoDemaisParcelas__c = '1';
                    }else{
                        contratanteprop.VencimentoDemaisParcelas__c = contratanteContrato.VencimentoDemaisParcelas__c;
                    }
                    
                    contratanteWrapper.sfContratante = contratanteprop;
                    contratanteWrapper.chave = String.valueOf(contratanteContrato.Id);
                    //PLV-5884 FIX-08 INICIO
                    System.debug('passou aqui');
                    System.debug('1: ' +this.proposta.propostaWrapper.contratantesWrapper);
                    System.debug('1: ' +contratanteWrapper);
                    //PLV-5884 FIX-08 FIM
                    this.proposta.propostaWrapper.contratantesWrapper.add( contratanteWrapper );
                }
                when RemuneracaoContrato__c remuneracaoContrato{
                    Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper = new Proposta.RemuneracaoPropostaWrapper();
                    RemuneracaoProposta__c remuneracaoprop = new RemuneracaoProposta__c();

                    remuneracaoprop.CurrencyIsoCode = remuneracaoContrato.CurrencyIsoCode;
                    remuneracaoprop.Percentual__c = remuneracaoContrato.Percentual__c;
                    remuneracaoprop.Porcentagem_de_Retencao__c = remuneracaoContrato.Porcentagem_de_Retencao__c;
                    remuneracaoprop.RemuneracaoProduto__c = remuneracaoContrato.RemuneracaoProduto__c;
                    remuneracaoprop.CurrencyIsoCode = remuneracaoContrato.CurrencyIsoCode;
                    remuneracaoprop.TipoRemuneracao__c = remuneracaoContrato.TipoRemuneracao__c;
                    
                    remuneracaoPropostaWrapper.sfRemuneracaoProposta = remuneracaoprop;
                    remuneracaoPropostaWrapper.chave = String.valueOf(remuneracaoContrato.Id);
                    //PLV-5884 FIX-08 INICIO
                    System.debug('passou aqui 2');
                    System.debug('2: ' +this.proposta.propostaWrapper.remuneracaoPropostaWrapper);
                    System.debug('2: ' +remuneracaoPropostaWrapper);
                    //PLV-5884 FIX-08 FIM
                    this.proposta.propostaWrapper.remuneracaoPropostaWrapper.add( remuneracaoPropostaWrapper );
                    setRemuneracaoContratoId.add(remuneracaoContrato.Id);
                }
                when GarantiaContrato__c garantiaContrato {
                    Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
                    GarantiaProposta__c garantiaProposta = new GarantiaProposta__c();
                    
                    garantiaProposta.Capital__c = garantiaContrato.Capital__c;
                    garantiaProposta.CurrencyIsoCode = garantiaContrato.CurrencyIsoCode;
                    garantiaProposta.Garantia__c = garantiaContrato.Garantia__c;
                    garantiaProposta.GarantiaProduto__c = garantiaContrato.GarantiaProduto__c;
                    garantiaProposta.Limite_de_Uso__c = garantiaContrato.Limite_de_Uso__c;
                    garantiaProposta.IOF__c = garantiaContrato.IOF__c;
                    garantiaProposta.Tipo_de_limite_de_utilizacao__c = garantiaContrato.Tipo_de_limite_de_utilizacao__c;

                    // Remove os dados de precificacao
                    garantiaProposta.TaxaPura__c = null;
                    garantiaProposta.TaxaComercial__c = null;
                    garantiaProposta.TaxaTotal__c = null;
                    garantiaProposta.PremioPuro__c = null;
                    garantiaProposta.PremioComercial__c = null;
                    garantiaProposta.PremioTotal__c = null;
                    garantiaProposta.DescontoAgravoMonetarioComercial__c = null;
                    garantiaProposta.DescontoAgravoMonetarioInformado__c = null;
                    garantiaProposta.DescontoAgravoMonetarioTecnico__c = null;
                    garantiaProposta.DescontoAgravoPercentualComercial__c = null;
                    garantiaProposta.DescontoAgravoPercentualInformado__c = null;
                    garantiaProposta.DescontoAgravoPercentualTecnico__c = null;

                    garantiaWrapper.sfGarantiaProposta = garantiaProposta;
                    setGarantiaId.add(garantiaContrato.Garantia__c);
                    //PLV-5884 FIX-08 INICIO
                    System.debug('passou aqui 3');
                    System.debug('3: ' +this.proposta.propostaWrapper.garantiasWrapper);
                    System.debug('3: ' +garantiaWrapper);
                    //PLV-5884 FIX-08 FIM
                    this.proposta.propostaWrapper.garantiasWrapper.add(garantiaWrapper);
                }
                when CriticaContrato__c criticaContrato{

                    CriticaProposta__c criticaProposta = new CriticaProposta__c();

                    criticaProposta.Area__c = criticaContrato.Area__c;
                    criticaProposta.Codigo__c = criticaContrato.Codigo__c;
                    criticaProposta.CurrencyIsoCode = criticaContrato.CurrencyIsoCode;
                    criticaProposta.Descricao__c = criticaContrato.Descricao__c;
                    criticaProposta.MensagemInterna__c = criticaContrato.MensagemInterna__c;
                    criticaProposta.Origem__c = criticaContrato.Origem__c;
                    criticaProposta.Severidade__c = criticaContrato.Severidade__c;
                    criticaProposta.Status__c = criticaContrato.Status__c;
                    criticaProposta.Tipo__c = criticaContrato.Tipo__c;

                    criticaProposta.Id = null;
                    //PLV-5884 FIX-08 INICIO
                    System.debug('passou aqui 4');
                    System.debug('4: ' +this.proposta.propostaWrapper.criticas);
                    System.debug('4: ' +criticaProposta);
                    //PLV-5884 FIX-08 FIM
                    this.proposta.propostaWrapper.criticas.add(criticaProposta);
                }
            }
        }

        // Limpa a lista ja processada
        listFilhosProposta.clear();

        // Buscar os filhos de segundo grau da proposta
        // Busca os favorecidos da remuneracao
        criterio = 'RemuneracaoContrato__r.Contrato__c  = \'' + contratoOriginal.Id + '\'';
        listFilhosProposta.addAll(this.clonarSObjects(new Set<String>{'FavorecidoRemuneracaoContrato__c'}, criterio, false));

        for(SObject sobj : listFilhosProposta){

            switch on sobj{

                when FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato{

                    for(Proposta.RemuneracaoPropostaWrapper remuneracaoPropostaWrapper : this.proposta.propostaWrapper.remuneracaoPropostaWrapper){

                        if(remuneracaoPropostaWrapper.chave == String.valueOf(favorecidoRemuneracaoContrato.RemuneracaoContrato__c)){

                            // Instancias
                            Proposta.FavorecidoRemuneracaoWrapper favorecidoRemuneracaoWrapper = new Proposta.FavorecidoRemuneracaoWrapper();
                            FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c();

                            favorecidoRemuneracaoProposta.AntecipacaoComissao__c = favorecidoRemuneracaoContrato.AntecipacaoComissao__c;
                            favorecidoRemuneracaoProposta.Conta__c = favorecidoRemuneracaoContrato.Conta__c;
                            favorecidoRemuneracaoProposta.CorretorLider__c = favorecidoRemuneracaoContrato.CorretorLider__c;
                            favorecidoRemuneracaoProposta.CurrencyIsoCode = favorecidoRemuneracaoContrato.CurrencyIsoCode;
                            favorecidoRemuneracaoProposta.DadosCorretor__c = favorecidoRemuneracaoContrato.DadosCorretor__c;
                            favorecidoRemuneracaoProposta.Papel__c = favorecidoRemuneracaoContrato.Papel__c;
                            favorecidoRemuneracaoProposta.Participacao__c = favorecidoRemuneracaoContrato.Participacao__c;
                            favorecidoRemuneracaoProposta.Susep__c = favorecidoRemuneracaoContrato.Susep__c;

                            // Armazena o favorecido da remuneracao
                            favorecidoRemuneracaoWrapper.sfFavorecidoRemuneracaoProposta = favorecidoRemuneracaoProposta;
                            //PLV-5884 FIX-08 INICIO
                            System.debug('passou aqui 5');
                            System.debug('5: ' +remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper);
                            System.debug('5: ' +favorecidoRemuneracaoWrapper);
                            //PLV-5884 FIX-08 FIM
                            remuneracaoPropostaWrapper.favorecidosRemuneracaoWrapper.add(favorecidoRemuneracaoWrapper);
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

        // Insere a sigla na garantiaWrapper
        for(Proposta.GarantiaWrapper garantiaWrapper : this.proposta.propostaWrapper.garantiasWrapper){
            garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaProposta.Garantia__c);
        }
    }
    //PLV-5884 FIM FIX-06

    //PLV-5884 FIM FIX-10 INICIO
    private void clonarContratantesContrato(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosContratanteProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'GrupoContrato__c', 'GarantiaContratanteContrato__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = 'ContratanteContrato__r.Contrato__c = \'' + contratoOriginal.Id + '\'';
        listFilhosContratanteProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(SObject sobj : listFilhosContratanteProposta){

                switch on sobj{

                    when GarantiaContratanteContrato__c GarantiaContratanteContrato{
                        Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
                        garantiaContratanteProposta__c garantiaContratanteProposta = new garantiaContratanteProposta__c();
                        // Remove os dados de precificacao
                        garantiaContratanteProposta.TaxaPura__c = null;
                        garantiaContratanteProposta.TaxaComercial__c = null;
                        garantiaContratanteProposta.TaxaTotal__c = null;
                        garantiaContratanteProposta.PremioPuro__c = null;
                        garantiaContratanteProposta.PremioComercial__c = null;
                        garantiaContratanteProposta.PremioTotal__c = null;
                        garantiaContratanteProposta.DescontoAgravoMonetarioComercial__c = null;
                        garantiaContratanteProposta.DescontoAgravoMonetarioInformado__c = null;
                        garantiaContratanteProposta.DescontoAgravoMonetarioTecnico__c = null;
                        garantiaContratanteProposta.DescontoAgravoPercentualComercial__c = null;
                        garantiaContratanteProposta.DescontoAgravoPercentualInformado__c = null;
                        garantiaContratanteProposta.DescontoAgravoPercentualTecnico__c = null;
                        
                        garantiaContratanteProposta.Capital__c = GarantiaContratanteContrato.Capital__c;
                        garantiaContratanteProposta.CurrencyIsoCode = GarantiaContratanteContrato.CurrencyIsoCode;
                        garantiaContratanteProposta.Garantia__c = GarantiaContratanteContrato.Garantia__c;
                        garantiaContratanteProposta.GarantiaProduto__c = GarantiaContratanteContrato.GarantiaProduto__c;
                        garantiaContratanteProposta.IOF__c = GarantiaContratanteContrato.IOF__c;

                        garantiaWrapper.sfGarantiaContratanteProposta = garantiaContratanteProposta;

                        setGarantiaId.add(garantiaContratanteProposta.Garantia__c);

                        if(contratanteWrapper.chave == String.valueOf(GarantiaContratanteContrato.ContratanteContrato__c)){
                            contratanteWrapper.garantiasWrapper.add(garantiaWrapper);
                        }
                    }

                    when GrupoContrato__c grupoContrato{
                        Proposta.GrupoWrapper grupoWrapper = new Proposta.GrupoWrapper();
                        GrupoProposta__c grupoSF = new GrupoProposta__c();
                        // Remove os dados de precificacao

                        grupoSF.TaxaPura__c = null;
                        grupoSF.TaxaComercial__c = null;
                        grupoSF.TaxaTotal__c = null;
                        grupoSF.PremioPuro__c = null;
                        grupoSF.PremioComercial__c = null;
                        grupoSF.PremioTotal__c = null;
                        grupoSF.DescontoAgravoMonetarioComercial__c = null;
                        grupoSF.DescontoAgravoMonetarioInformado__c = null;
                        grupoSF.DescontoAgravoMonetarioTecnico__c = null;
                        grupoSF.DescontoAgravoPercentualComercial__c = null;
                        grupoSF.DescontoAgravoPercentualInformado__c = null;
                        grupoSF.DescontoAgravoPercentualTecnico__c = null;

                        grupoSF.IOF__c = grupoContrato.IOF__c;
                        grupoSF.Name = grupoContrato.Name;
                        grupoSF.Numero__c = grupoContrato.Numero__c;
                        grupoSF.QuantidadeVidas__c = grupoContrato.QuantidadeVidas__c;
                        grupoSF.CurrencyIsoCode = grupoContrato.CurrencyIsoCode;

                        grupoWrapper.sfGrupo = grupoSF;
                        grupoWrapper.chave = String.valueOf(grupoContrato.Id);

                        if(contratanteWrapper.chave == String.valueOf(grupoContrato.ContratanteContrato__c)){
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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper) {
            for (Proposta.GarantiaWrapper garantiaWrapper : contratanteWrapper.garantiasWrapper) {
                garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaContratanteProposta.Garantia__c);
            }
        }
    }

    private void clonarGruposContrato(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhosGrupoProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'SeguradoContrato__c', 'GarantiaGrupoContrato__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = 'GrupoContrato__r.ContratanteContrato__r.Contrato__c = \'' + contratoOriginal.Id + '\'';
        listFilhosGrupoProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){

                for(SObject sobj : listFilhosGrupoProposta){

                    switch on sobj{

                        when GarantiaGrupoContrato__c garantiaGrupoContrato {
                            Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
                            GarantiasGrupoProposta__c garantiaGrupoProposta = new GarantiasGrupoProposta__c();
                            // Remove os dados de precificacao
                            garantiaGrupoProposta.TaxaPura__c = null;
                            garantiaGrupoProposta.TaxaComercial__c = null;
                            garantiaGrupoProposta.TaxaTotal__c = null;
                            garantiaGrupoProposta.PremioPuro__c = null;
                            garantiaGrupoProposta.PremioComercial__c = null;
                            garantiaGrupoProposta.PremioTotal__c = null;
                            garantiaGrupoProposta.DescontoAgravoMonetarioComercial__c = null;
                            garantiaGrupoProposta.DescontoAgravoMonetarioInformado__c = null;
                            garantiaGrupoProposta.DescontoAgravoMonetarioTecnico__c = null;
                            garantiaGrupoProposta.DescontoAgravoPercentualComercial__c = null;
                            garantiaGrupoProposta.DescontoAgravoPercentualInformado__c = null;
                            garantiaGrupoProposta.DescontoAgravoPercentualTecnico__c = null;

                            garantiaGrupoProposta.CurrencyIsoCode = garantiaGrupoContrato.CurrencyIsoCode;
                            garantiaGrupoProposta.Capital__c = garantiaGrupoContrato.Capital__c;
                            garantiaGrupoProposta.Garantia__c = garantiaGrupoContrato.Garantia__c;
                            garantiaGrupoProposta.GarantiaProduto__c = garantiaGrupoContrato.GarantiaProduto__c;
                            garantiaGrupoProposta.IOF__c = garantiaGrupoContrato.IOF__c;

                            garantiaWrapper.sfGarantiaGrupoProposta = garantiaGrupoProposta;
                            setGarantiaId.add(garantiaGrupoProposta.Garantia__c);

                            if(grupoWrapper.chave == String.valueOf(garantiaGrupoContrato.GrupoContrato__c)){
                                grupoWrapper.garantiasWrapper.add(garantiaWrapper);
                            }
                        }

                        when SeguradoContrato__c SeguradoContrato{
                            Proposta.SeguradoWrapper seguradoWrapper = new Proposta.SeguradoWrapper();
                            SeguradoProposta__c seguradoProposta = new SeguradoProposta__c();
                            // Remove os dados de precificacao
                            seguradoProposta.TaxaPura__c = null;
                            seguradoProposta.TaxaComercial__c = null;
                            seguradoProposta.TaxaTotal__c = null;
                            seguradoProposta.PremioPuro__c = null;
                            seguradoProposta.PremioComercial__c = null;
                            seguradoProposta.PremioTotal__c = null;
                            seguradoProposta.DescontoAgravoMonetarioComercial__c = null;
                            seguradoProposta.DescontoAgravoMonetarioInformado__c = null;
                            seguradoProposta.DescontoAgravoMonetarioTecnico__c = null;
                            seguradoProposta.DescontoAgravoPercentualComercial__c = null;
                            seguradoProposta.DescontoAgravoPercentualInformado__c = null;
                            seguradoProposta.DescontoAgravoPercentualTecnico__c = null;

                            seguradoProposta.BairroComercial__c = SeguradoContrato.BairroComercial__c;
                            seguradoProposta.bairroResidencial__c = SeguradoContrato.bairroResidencial__c;
                            seguradoProposta.Celular__c = SeguradoContrato.Celular__c;
                            seguradoProposta.CEPComercial__c = SeguradoContrato.CEPComercial__c;
                            seguradoProposta.cepResidencial__c = SeguradoContrato.cepResidencial__c;
                            seguradoProposta.CicloVacinal__c = SeguradoContrato.CicloVacinal__c;
                            seguradoProposta.CidadeComercial__c = SeguradoContrato.CidadeComercial__c;
                            seguradoProposta.CidadeResidencial__c = SeguradoContrato.CidadeResidencial__c;
                            seguradoProposta.ComplementoComercial__c = SeguradoContrato.ComplementoComercial__c;
                            seguradoProposta.ComplementoResidencial__c = SeguradoContrato.ComplementoResidencial__c;
                            seguradoProposta.Conta__c = SeguradoContrato.Conta__c;
                            seguradoProposta.CurrencyIsoCode = SeguradoContrato.CurrencyIsoCode;
                            seguradoProposta.Email__c = SeguradoContrato.Email__c;
                            seguradoProposta.EmpresaTrabalhaSocio__c = SeguradoContrato.EmpresaTrabalhaSocio__c;
                            seguradoProposta.Endereco_comercial__c = SeguradoContrato.EnderecoComercial__c;
                            seguradoProposta.Endereco_residencial__c = SeguradoContrato.EnderecoResidencial__c;
                            seguradoProposta.FaixaRenda__c = SeguradoContrato.FaixaRenda__c;
                            seguradoProposta.Fumante__c = SeguradoContrato.Fumante__c;
                            seguradoProposta.GrupoRisco__c = SeguradoContrato.GrupoRisco__c;
                            seguradoProposta.IOF__c = SeguradoContrato.IOF__c;
                            seguradoProposta.LogradouroComercial__c = SeguradoContrato.LogradouroComercial__c;
                            seguradoProposta.logradouroResidencial__c = SeguradoContrato.logradouroResidencial__c;
                            seguradoProposta.Melhor_periodo_para_contato__c = SeguradoContrato.MelhorPeriodoContato__c;
                            seguradoProposta.Nome_do_segurado__c = SeguradoContrato.NomeSegurado__c;
                            seguradoProposta.Numero__c = SeguradoContrato.Numero__c;
                            seguradoProposta.NumeroComercial__c = SeguradoContrato.NumeroComercial__c;
                            seguradoProposta.numeroResidencial__c = SeguradoContrato.numeroResidencial__c;
                            seguradoProposta.Pais_Residente__c = SeguradoContrato.Pais_Residente__c;
                            seguradoProposta.PEP__c = SeguradoContrato.PEP__c;
                            seguradoProposta.Profissao__c = SeguradoContrato.Profissao__c;
                            seguradoProposta.RegimeTrabalho__c = SeguradoContrato.RegimeTrabalho__c;
                            seguradoProposta.Renda__c = SeguradoContrato.Renda__c;
                            seguradoProposta.ResponsavelFinanceiroSeguro__c = SeguradoContrato.ResponsavelFinanceiroSeguro__c;
                            seguradoProposta.Telefone_comercial__c = SeguradoContrato.TelefoneComercial__c;
                            seguradoProposta.Telefone_residencial__c = SeguradoContrato.TelefoneResidencial__c;
                            seguradoProposta.TemDependentes__c = SeguradoContrato.TemDependentes__c;
                            seguradoProposta.UFComercial__c = SeguradoContrato.UFComercial__c;
                            seguradoProposta.UFResidencial__c = SeguradoContrato.UFResidencial__c;
                            seguradoProposta.UltimaConsultaPEP__c = SeguradoContrato.UltimaConsultaPEP__c;
                            seguradoProposta.VigenciaFinal__c = SeguradoContrato.VigenciaFinal__c;
                            seguradoProposta.VigenciaInicial__c = SeguradoContrato.VigenciaInicial__c;

                            seguradoWrapper.sfSegurado = seguradoProposta;
                            seguradoWrapper.chave = String.valueOf(SeguradoContrato.Id);

                            if(grupoWrapper.chave == String.valueOf(SeguradoContrato.GrupoContrato__c)){
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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper) {

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for (Proposta.GarantiaWrapper garantiaWrapper : grupoWrapper.garantiasWrapper) {
                    garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaGrupoProposta.Garantia__c);
                }
            }
        }
    }

    private void clonarSeguradosContrato(){

        // Instancias
        Map<Id,String> mapSiglaGarantiaPorId = new Map<Id, String>();
        List<SObject> listFilhoSeguradoProposta = new List<SObject>();
        Set<String> setSObjectName = new Set<String>{'BeneficiarioSeguradoContrato__c', 'GarantiaSeguradoContrato__c'};
        set<Id> setGarantiaId = new Set<Id>();

        // Busca os filhos diretos do contratante
        String criterio = 'SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c = \'' + contratoOriginal.Id + '\'';
        listFilhoSeguradoProposta.addAll(this.clonarSObjects(setSObjectName, criterio, true));

        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper){

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper){

                for(Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

                    for (SObject sobj : listFilhoSeguradoProposta) {

                        switch on sobj {

                            when GarantiaSeguradoContrato__c GarantiaSeguradoContrato {
                                Proposta.GarantiaWrapper garantiaWrapper = new Proposta.GarantiaWrapper();
                                GarantiaSeguradoProposta__c garantiaSeguradoProposta = new GarantiaSeguradoProposta__c();
                                // Remove os dados de precificacao
                                garantiaSeguradoProposta.TaxaPura__c = null;
                                garantiaSeguradoProposta.TaxaComercial__c = null;
                                garantiaSeguradoProposta.TaxaTotal__c = null;
                                garantiaSeguradoProposta.PremioPuro__c = null;
                                garantiaSeguradoProposta.PremioComercial__c = null;
                                garantiaSeguradoProposta.PremioTotal__c = null;
                                garantiaSeguradoProposta.DescontoAgravoMonetarioComercial__c = null;
                                garantiaSeguradoProposta.DescontoAgravoMonetarioInformado__c = null;
                                garantiaSeguradoProposta.DescontoAgravoMonetarioTecnico__c = null;
                                garantiaSeguradoProposta.DescontoAgravoPercentualComercial__c = null;
                                garantiaSeguradoProposta.DescontoAgravoPercentualInformado__c = null;
                                garantiaSeguradoProposta.DescontoAgravoPercentualTecnico__c = null;

                                garantiaSeguradoProposta.Capital__c = GarantiaSeguradoContrato.Capital__c;
                                garantiaSeguradoProposta.CurrencyIsoCode = GarantiaSeguradoContrato.CurrencyIsoCode;
                                garantiaSeguradoProposta.Garantia__c = GarantiaSeguradoContrato.Garantia__c;
                                garantiaSeguradoProposta.GarantiaProduto__c = GarantiaSeguradoContrato.GarantiaProduto__c;
                                garantiaSeguradoProposta.GarantiaReferenciada__c = GarantiaSeguradoContrato.GarantiaReferenciada__c;
                                garantiaSeguradoProposta.IOF__c = GarantiaSeguradoContrato.IOF__c;
                                garantiaSeguradoProposta.Limite_de_Uso__c = GarantiaSeguradoContrato.Limite_de_Uso__c;
                                garantiaSeguradoProposta.Tipo_de_limite_de_utilizacao__c = GarantiaSeguradoContrato.Tipo_de_limite_de_utilizacao__c;
                                garantiaSeguradoProposta.ValorDias__c = GarantiaSeguradoContrato.ValorDias__c;
                        
                                garantiaWrapper.sfGarantiaSeguradoProposta = garantiaSeguradoProposta;

                                setGarantiaId.add(garantiaSeguradoProposta.Garantia__c);

                                if (seguradoWrapper.chave == String.valueOf(GarantiaSeguradoContrato.SeguradoContrato__c)){
                                    seguradoWrapper.garantiasWrapper.add(garantiaWrapper);
                                }
                            }

                            when BeneficiarioSeguradoContrato__c BeneficiarioSeguradoContrato {
                                Proposta.BeneficiariosWrapper beneficiariosWrapper = new Proposta.BeneficiariosWrapper();
                                BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = new BeneficiarioSeguradoProposta__c();

                                if (BeneficiarioSeguradoContrato.Nome__c != null) beneficiarioSeguradoProposta.Nome__c  = BeneficiarioSeguradoContrato.Nome__c;
                                if (BeneficiarioSeguradoContrato.GrauParentesco__c != null) beneficiarioSeguradoProposta.GrauParentesco__c  = BeneficiarioSeguradoContrato.GrauParentesco__c;
                                beneficiarioSeguradoProposta.CurrencyIsoCode = BeneficiarioSeguradoContrato.CurrencyIsoCode;
                                beneficiarioSeguradoProposta.ImprimirCertificadoSeguro__c = BeneficiarioSeguradoContrato.ImprimirCertificadoSeguro__c;
                                beneficiarioSeguradoProposta.Participacao__c = BeneficiarioSeguradoContrato.Participacao__c;
                                beneficiarioSeguradoProposta.PercentualIndenizacao__c = BeneficiarioSeguradoContrato.PercentualIndenizacao__c;
                                beneficiarioSeguradoProposta.TipoBeneficiario__c = BeneficiarioSeguradoContrato.TipoBeneficiario__c;

                                beneficiariosWrapper.sfBeneficiarioSeguradoProposta = beneficiarioSeguradoProposta;

                                if (seguradoWrapper.chave == String.valueOf(BeneficiarioSeguradoContrato.SeguradoContrato__c)){
                                    seguradoWrapper.beneficiariosWrapper.add(beneficiariosWrapper);
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
        for(Proposta.ContratanteWrapper contratanteWrapper : this.proposta.propostaWrapper.contratantesWrapper) {

            for(Proposta.GrupoWrapper grupoWrapper : contratanteWrapper.gruposWrapper) {

                for(Proposta.SeguradoWrapper seguradoWrapper : grupoWrapper.seguradosWrapper) {

                    for (Proposta.GarantiaWrapper garantiaWrapper : seguradoWrapper.garantiasWrapper) {
                        garantiaWrapper.sigla = mapSiglaGarantiaPorId.get(garantiaWrapper.sfGarantiaSeguradoProposta.Garantia__c);
                    }
                }
            }
        }
    }
    
    /* ---------------------------------- FIM HELPERS ------------------------------------------------------------- */
}