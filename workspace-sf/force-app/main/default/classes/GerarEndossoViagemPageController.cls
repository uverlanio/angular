/**
 * Gerarção de Endosso Viagem
 * Iskander/Jeferson
 * PLV-4578
 **/
public class GerarEndossoViagemPageController {
    //PLV-5063 - INICIO
    public String payload                                       { get; set; }
    public Contract contract                                    { get; set; }
    public List < Garantia > garantiasContract                  { get; set; }
    public Map < String, GarantiaProduto__c > garantiasProduct  { get; set; }
    public Decimal agenciamento                                 { get; set; }
    public String dataInicio                                    { get; set; }
    public String dataFim                                       { get; set; }
    public Double percentual                                    { get; set; }
    public String tipoRemuneracao                               { get; set; }
    public Decimal corretagem                                   { get; set; }
    public String accountProfession                             { get; set; }
    private ExceptionHub exceptionHub                           { get; set; }
    public RemuneracaoControl corretagemControl                 { get; set; }
    public String entradaCalculo                                { get; set; }
    public String ofertaPadrao                                  { get; set; }
    public String professionsData                               { get; set; }
    public String questionario                                  { get; set; }
    public String scriptGetFromStorage                          { get; set; }
    private Map < String, RespostaDeclaracaoSaude > mapRespostas = new Map < String, RespostaDeclaracaoSaude > ();
    private List < String > usedGarantias                       { get; set; }    
    private List < GrupoContrato__c > lstGrupoContrato;
    //PLV-4600 - INICIO
    public String contractS                                     { get; set; }
    public String beneficiarioscontrato                         { get; set; }
    public String enderecos                                     { get; set; }
    public String remuneracoes                                  { get; set; }
    public String dadoscorretores                               { get; set; }
    public String seguradoscontrato                             { get; set; }
    //PLV-4600 - FIM       
    public String entradaCalculoEndosso                         { get; set; }  
    public Integer periodoMaximoVigencia                        { get; set; } //PLV-5063 - FIX02 - INICIO/FIM  
    //PLV-5063 - FIM

    //private static final CtrFormularioSnipper instancia = new CtrFormularioSnipper();
    private static CIVServices civServ = CIVServices.getInstance();

    public GerarEndossoViagemPageController(ApexPages.StandardController controller) {
        this.exceptionHub = new ExceptionHub();
        this.garantiasContract = new List < Garantia > ();
        this.usedGarantias = new List < String > ();
        this.garantiasProduct = new Map < String, GarantiaProduto__c > ();
        this.questionario = '';

        lstGrupoContrato = new List < GrupoContrato__c > ();

        ID contractId = (ID) controller.getRecord().id;
        if (contractId == null) contractId = (ID) ApexPages.currentPage().getParameters().get('idContrato');
        System.debug('contractId >> ' + contractId);

        this.getData(contractId);

        // this.setupGarantias();
        this.getGrupoContrato(contractId);

        if (ApexPages.currentPage().getParameters().get('getFromStorage') == 'true'){
            scriptGetFromStorage = '<script>getFromStorage();</script>';
        }
    }

    private void getData(id ctrId) {
        this.getContract(ctrId);
        if(contract.Proposta__c != null){
            // this.getHealthStatement(contract.Proposta__c);
        }
        // this.getGarantiasProduto(contract.Produto__c);
        // this.corretagemControl = new RemuneracaoControl(this.contract.Produto__c);
    }

    private void getContract(id ctrId) {
        this.contract = null;
        try {

            this.contract = [
                SELECT  
                id,
                name,
                Status,
                StartDate, VigenciaFinal__c,
                Endosso__c, Empresa__c, CodigoRamo__c, Sucursal__c, NumeroApolice__c,
                MeioComercializacao__c,
                Produto__c,
                PaisesDestino__c,
                PaisesDestino_OLD__c,
                TipoViagem__c,
                ViagemAventura__c,
                UtilizaMoto__c,
                QuantidadePassageiros070Anos__c,
                VidasEntre7190Anos__c,
                Produto__r.Segmento__c,
                Produto__r.ProductCode,
                TipoContrato__c,
                Account.name,
                Account.PersonBirthdate,
                Account.Sexo__c,
                Account.Fumante__c,
                Account.Profissao__c,
                Account.RegimeTrabalho__c,
                Account.Renda__c,
                //PLV-4600 - INICIO
                Account.Profissao__pc,
          		Account.Profissao__r.NomeFantasia__c,
                Account.Phone
                  , AccountId
                  , Account.CNH__pc
                  , Account.CLASSE__pc
                  , Account.Sexo__pc
                  , Account.Rne__pc
                  , Account.Rg__pc
                  , Account.PaisResidencia__pc
                  , Account.Passaporte__pc
                  , Account.PEP__pc
                  , Account.OrgaoExpedidor__pc
                  , Account.EstadoCivil__pc
                  , Account.ClasseRne__pc
                  , Account.CPF__pc
                  , Account.Tributavel__c
                  , Account.ResideBrasil__c
                  , Account.DocIndentificacao__c
                  , Account.TipoDocidentificacao__c
                  , Account.empresa_estrangeira__c
                  , Account.OptaSimples__c
                  , Account.C_digo_do_Agenciador__c
                  , Account.Ativo__c
                  , Account.Num_Doc_Estrangeiro__c
                  , Account.NIT__c
                  , Account.Inscricao_Estadual__c
                  , Account.Pis__c
                  , Account.Inscricao_Municipal__c
                  , Account.Pescod__c
                  , Account.Rne__c
                  , Account.Rg__c
                  , Account.RamoAtividade__c
                  , Account.RamoAtividadeEmpresa__c
                  , Account.Pep__c
                  , Account.PaisResidencia__c
                  , Account.OrgaoExpedidor__c
                  , Account.MelhorPeriodoContato__c
                  , Account.NumeroRegistroProfissional__c
                  , Account.NumeroPassaporte__c
                  , Account.NumeroInscricao__c
                  , Account.NomeFantasia__c
                  , Account.NumeroContratoParceiro__c
                  , Account.NumeroContratoPrestador__c
                  , Account.NumeroContratoRespresentante__c
                  , Account.Nacionalidade__c
                  , Account.EstadoCivil__c
                  , Account.Especialidade__c
                  , Account.Email__c
                  , Account.EmpresaTrabalhaSocio__c
                  , Account.Ramo_de_atividade__c  // PLV-4810  INICIO/FIM SYS4B ODEMIR
                  , Account.DataExpedicao__c
                  , Account.DataAdmissao__c
                  , Account.Cpf__c
                  , Account.CodigoSusepCorretor__c
                  , Account.CodigoSusepCia__c
                  , Account.CodigoPais__c
                  , Account.CodigoEmpresa__c
                  , Account.Cnpj__c
                  , Account.ClasseRne__c
                  , Account.CNAE__c
                  , Account.PersonOtherAddress
                  , Account.PersonMobilePhone
                  , Account.PersonHomePhone
                  , Account.PersonOtherPhone
                  , Account.PersonEmail
                  , Account.PersonTitle
                  , Account.ServicosPrestador__c
                  , Account.SusepPrincipal__c
                  , Account.TipoAdministracao__c
                  , Account.TipoComunicacao__c,
                Oportunidade__r.NumeroOferta__c,
                Oportunidade__r.Name,
                Oportunidade__r.Numero__c,
                Oportunidade__r.CanalDistribuicao__r.Sigla__c,
                Oportunidade__r.CodigoCorretor__r.Name,
                Oportunidade__r.NumeroPortal__c,
                Oportunidade__r.TipoVigencia__c,
                Oportunidade__r.VigenciaInicial__c,
                Oportunidade__r.VigenciaFinal__c,
                Oportunidade__r.VigenciaFinalAlterada__c, //PLV-4684 INICIO/FIM
                Oportunidade__r.EntradaNegocio__c,
                Oportunidade__r.CloseDate,
                Oportunidade__r.Consultivo__c,
                Proposta__c,
                (
                    SELECT 
                        Id, 
                        Name, 
                        Tipo__c, 
                        TaxaComercial__c, 
                        TaxaPura__c, 
                        TaxaTotal__c,
                        PremioComercial__c, 
                        PremioPuro__c, 
                        PremioTotal__c,
                        PremioIntegral__c //PLV-5153 INICIO/FIM
                    FROM ContratantesContrato__r
                ),
                (
                    SELECT 
                        MoedaGarantia__c,
                        ValorCotacao__c,
                        Capital__c,
                        Garantia__r.Name,
                        Garantia__r.Sigla__c,
                        PremioTotal__c
                    FROM GarantiasContrato__r
                ),
                (	
					SELECT 
						Id,
                        Percentual__c,
                        Name,
                        TipoRemuneracao__r.Name
                    FROM RemuneracoesContrato__r
                    WHERE TipoRemuneracao__r.Name = 'CORRETAGEM'
				)
                FROM Contract
                WHERE id =: ctrId
                LIMIT 1
            ];
            
            this.enderecos = JSON.serialize([SELECT Bairro__c
                              , CEP__c
                              , Cidade__c
                              , Complemento__c
                              , Estado__c
                              , Logradouro__c
                              , Numero__c
                              , Pais__c
                              , TipoEndereco__c
                              , TipoLogradouro__c
                        FROM Endereco__c
                        WHERE Maisatual__c=true
                        AND conta__c=:this.contract.AccountId
                        LIMIT 2]);
           	
            		this.seguradoscontrato = JSON.serialize([SELECT NomeContatoEmergencia__c, 
                    	TelefoneContatoEmergencia__c 
                    FROM SeguradoContrato__c 
                    WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__r.id =: ctrId
                	LIMIT 1]);
            
            
            
      
          Set<Id> setRemuneracoes = new Set<Id>();
          for(RemuneracaoContrato__c rc : this.contract.RemuneracoesContrato__r){
            setRemuneracoes.add(rc.Id);
          }
          List<FavorecidoRemuneracaoContrato__c> listFavorecidos = new List<FavorecidoRemuneracaoContrato__c>();
          if(!setRemuneracoes.isEmpty()){
            listFavorecidos = [SELECT Id
                                      , CorretorLider__c
                                      , Participacao__c
                                      , Papel__c
                                      , Susep__c
                                      , SusepEmissao__c
                                      , SusepOficialCorretor__c
                                      , SusepOrcamento__c
                                      , AntecipacaoComissao__c
                                      , RemuneracaoContrato__c
                                      , RemuneracaoContrato__r.TipoRemuneracao__r.Name
                                      , RemuneracaoContrato__r.Percentual__c
                                      , RemuneracaoContrato__r.Porcentagem_de_Retencao__c
                                      , Conta__c
                                      , Conta__r.Cnpj__c
                                      , Conta__r.Cpf__c
                                      , Conta__r.C_digo_do_Agenciador__c
                                      , Conta__r.Name
                                FROM FavorecidoRemuneracaoContrato__c
                                WHERE RemuneracaoContrato__c in: setRemuneracoes];
            Set<Id> setAcc = new Set<Id>();
            for(FavorecidoRemuneracaoContrato__c lf : listFavorecidos){
              setAcc.add(lf.Conta__c);
            }
            System.debug('pedro: setAcc'+JSON.serialize(setAcc));
            Map<String,List<DadosCorretor__c>> mapDados = new Map<String,List<DadosCorretor__c>>();
            List<DadosCorretor__c> ldados= [SELECT Id
                                                  , Name
                                                  , CodigoSucursalDestinoCheque__c
                                                  , CodigoSucursalVinculo__c
                                                  , NomeCorretor__c
                                                  , SucursalDestinoCheque__c
                                                  , SucursalVinculo__c
                                                  , Tipo__c
                                            FROM DadosCorretor__c
                                            WHERE NomeCorretor__c IN:setAcc];
            System.debug('pedro: ldados'+JSON.serialize(ldados));
            
            for(DadosCorretor__c dc : ldados){
              if(!mapDados.containskey(dc.NomeCorretor__c))mapDados.put(dc.NomeCorretor__c, new List<DadosCorretor__c>());
              mapDados.get(dc.NomeCorretor__c).add(dc);
            }
            System.debug('mapDados: mapDados'+JSON.serialize(mapDados));
            System.debug('listFavorecidos: listFavorecidos'+JSON.serialize(listFavorecidos));
            
            this.remuneracoes = JSON.serialize(listFavorecidos);
            this.dadoscorretores = JSON.serialize(mapDados);
          }
            
        } catch (Exception e) {
            System.debug('Error while getting contract:');
            System.debug(e);
        }

        if (this.contract == null){
            this.exceptionHub.missingContractId();
        }

        if (this.contract.Status != 'Emitido'){
            this.exceptionHub.contractNotissued();
        }

        if (this.contract.Produto__r.Segmento__c != 'Viagem'){
            this.exceptionHub.invalidSegment();
        }

        if(this.contract.StartDate != null){
            this.dataInicio =  this.contract.StartDate.format();
        }

        if(this.contract.VigenciaFinal__c != null){
            this.dataFim = this.contract.VigenciaFinal__c.format();
        }

        if (this.contract.VigenciaFinal__c < Date.today()){
            this.exceptionHub.generic('Endosso não permitido - Contrato não vigente');
        }

        if(this.contract.RemuneracoesContrato__r.size() > 0){
            if(this.contract.RemuneracoesContrato__r[0].Percentual__c != null){
                this.percentual = Integer.valueOf(this.contract.RemuneracoesContrato__r[0].Percentual__c);
            }
        }else{
            this.percentual = 0;
        }
        
        if (this.contract.Account.Renda__c == null)
      this.contract.Account.Renda__c = 0;

    for (RemuneracaoContrato__c r : this.contract.RemuneracoesContrato__r) {
      if (r.TipoRemuneracao__r.name == 'AGENCIAMENTO') {
        this.agenciamento = r.Percentual__c;
      } else if (r.TipoRemuneracao__r.name == 'CORRETAGEM') {
        this.corretagem = r.Percentual__c;
      }

      this.tipoRemuneracao = r.TipoRemuneracao__r.name; 
    }

    this.accountProfession = this.contract.Account.Profissao__c != null
      ? this.contract.Account.Profissao__r.NomeFantasia__c
      : '';
  	
    this.beneficiarioscontrato = JSON.serialize([SELECT Id
                                        , Conta__c
                                        , CpfCnpj__c
                                        , CpfPep__c
                                        , Data_de_Nascimento__c
                                        , GrauParentesco__c
                                        , GrauParentescoPep__c
                                        , ImprimirCertificadoSeguro__c
                                        , MotivoSemCpfCnpj__c
                                        , Name
                                        , Nome__c
                                        , NomePessoaPep__c
                                        , Participacao__c
                                        , Pep__c
                                        , PercentualIndenizacao__c
                                        , SeguradoContrato__c
                                        , Sexo__c
                                        , TipoBeneficiario__c
                                  FROM BeneficiarioSeguradoContrato__c
                                  WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c=:contract.Id]);
        
        this.contractS = JSON.serialize(this.contract);
         //PLV-4600 - FIM
    }
	
	@TestVisible //PLV-5053 - INICIO/FIM
    private void getHealthStatement(Id prpId) {
        DeclaracaoSaude__c healthStatement = new DeclaracaoSaude__c();
        healthStatement = null;
        try {

            healthStatement = [
                SELECT
                Id,
                (
                    SELECT Id,
                    PerguntaQuestionarioRisco__r.Pergunta__r.Name,
                    PerguntaQuestionarioRisco__r.Pergunta__r.Pergunta__c,
                    Resposta__c FROM DeclaracaoSaude__r
                )
                FROM DeclaracaoSaude__c
                WHERE Proposta__c =: prpId
                LIMIT 1
            ];

        } catch (Exception e) {
            System.debug('Error while getting health statement:');
            System.debug(e);
            return;
        }
        if (healthStatement == null || healthStatement.DeclaracaoSaude__r.isEmpty()){
            return;
        }

        for (RespostaDeclaracaoSaude__c resp: healthStatement.DeclaracaoSaude__r) {
            if (resp.PerguntaQuestionarioRisco__r != null) {
                if (resp.PerguntaQuestionarioRisco__r.Pergunta__r != null) {
                    RespostaDeclaracaoSaude respostaObj = new RespostaDeclaracaoSaude();
                    respostaObj.nomePergunta = resp.PerguntaQuestionarioRisco__r.Pergunta__r.Name;
                    respostaObj.textoPergunta = resp.PerguntaQuestionarioRisco__r.Pergunta__r.Pergunta__c;
                    respostaObj.resposta = resp.Resposta__c;
                    this.mapRespostas.put(respostaObj.nomePergunta, respostaObj);
                }
            }
        }
        if (!this.mapRespostas.isEmpty()){
            this.questionario = JSON.serialize(this.mapRespostas);
        }
    }
	
	@TestVisible //PLV-5063 - INICIO/FIM
    private void setupGarantias() {
        for (
            GarantiaContrato__c garantiaContract: this.contract.GarantiasContrato__r
        ) {
            Garantia garantia = new Garantia(
                garantiaContract,
                this.garantiasProduct.get(garantiaContract.Garantia__r.Sigla__c),
                true
            );

            this.usedGarantias.add(garantia.initials);

            this.garantiasContract.add(garantia);
        }

        for (String key: this.garantiasProduct.keySet()) {
            if (!usedGarantias.contains(key)) {
                this.garantiasContract.add(
                    new Garantia(this.garantiasProduct.get(key))
                );
            }
        }
    }


    public void getProfessions() {
        List < Profissao__c > lstProfessions = [
            SELECT id, Name, NomeFantasia__c, CodigoProfissao__c
            FROM Profissao__c
            WHERE(Status__c = 'Ativo'
                OR id =: this.accountProfession)
            AND NomeFantasia__c != ''
        ];

        this.professionsData = JSON.serialize(lstProfessions);
    }

    private class Garantia {
        //PLV-5063 - INICIO
        public String name          { get; set; }
        public String initials      { get; set; }
        public Decimal capital      { get; set; }
        public Decimal minCapital   { get; set; }
        public Decimal maxCapital   { get; set; }
        public Boolean required     { get; set; }
        public Boolean isActive     { get; set; }
        public String coin          { get; set; }
        public String type          { get; set; }
        //PLV-5063 - FIM

        public Garantia(
            GarantiaContrato__c garantiaContract,
            GarantiaProduto__c garantiaProd,
            Boolean isActive
        ) {
            this.name = garantiaContract.Garantia__r.name;
            this.initials = garantiaContract.Garantia__r.Sigla__c;
            this.type = garantiaContract.Garantia__r.Tipo__c;
            this.isActive = isActive;

            if (garantiaContract.Capital__c != null)
                this.capital = garantiaContract.Capital__c;

            if (garantiaProd != null) {
                this.coin = garantiaProd.CurrencyIsoCode;
                this.minCapital = garantiaProd.LimiteCapitalMinimo__c;
                this.maxCapital = garantiaProd.LimiteCapitalMaximo__c;
                this.required = garantiaProd.Obrigatoria__c;
            } else {
                this.coin = '';
                this.minCapital = 0;
                this.maxCapital = 0;
                this.required = false;
            }
        }
        public Garantia(GarantiaProduto__c garantiaProd) {
            this.name = garantiaProd.Garantia__r.name;
            this.initials = garantiaProd.Garantia__r.Sigla__c;

            this.capital = garantiaProd.LimiteCapitalMinimo__c;
            this.isActive = false;
            this.type = garantiaProd.Garantia__r.Tipo__c;

            this.minCapital = garantiaProd.LimiteCapitalMinimo__c;
            this.maxCapital = garantiaProd.LimiteCapitalMaximo__c;
            this.required = garantiaProd.Obrigatoria__c;
            this.coin = garantiaProd.CurrencyIsoCode;
            this.type = garantiaProd.Garantia__r.Tipo__c;
        }
    }

    private class RemuneracaoControl {
		//PLV-5063 - INICIO
        public Decimal corretagemMinimum { get; set; }
        public Decimal corretagemMaximum { get; set; }
        //PLV-5063 - FIM             
        //PLV-5063 - REMOÇÃO DE CODIGO - INICIO/FIM 
    }
	//PLV-5063 - INICIO   
    public PageReference calculoEndosso() {
        System.debug('entradaCalculo: ' + entradaCalculo);                     
        Boolean redirectUrl = false;        
        if(validarVigenciaEndosso()) {        
            gerarPayload();                        
        } else {
            redirectUrl = true;
        }   
        return redirectEndossoViagem(redirectUrl);                      
    }       
    //PLV5063 - FIM

    private void getGrupoContrato(Id contractId) {
        lstGrupoContrato = [SELECT Id, Name, TipoCalculo__c, Numero__c, QuantidadeVidas__c
            FROM GrupoContrato__c
            WHERE ContratanteContrato__r.Contrato__c =: contractId
        ];
    }

    private class RespostaDeclaracaoSaude {
        //PLV-5063 - INICIO
        private String nomePergunta     { get; set; }
        private String textoPergunta    { get; set; }
        private String resposta         { get; set; }
        //PLV-5063 - FIM
    }

    public class EntradaPessoa {
		//PLV-5063 - INICIO
        public Date inicioVigencia              { get; set; }
        public Date finalVigencia               { get; set; }
        //PLV-4587 - INICIO
        public String tipoViagem                { get; set; }
        public Boolean praticaEsportesAventura  { get; set; }
        public Boolean utilizaraMotocicleta     { get; set; }
        public Integer passageirosNaoIdosos     { get; set; }
        public Integer passageirosIdosos        { get; set; }
        public List<DestinoTo> destinos         { get; set; }
        //PLV-4587-FIM
		//PLV-5063 - FIM
    }
    //PLV-4587 - INICIO
    public class DestinoTo{
		//PLV-5063 - INICIO
        public String codigo    { get; set; }
        public String pais      { get; set; }
		//PLV-5063 - FIM
    }
    //PLV-4587-FIM

    public class EntradaCobertura {

       //PLV-5063 - INICIO
	   public String sigla         { get; set; }
       public Decimal valor        { get; set; }
       public String moeda         { get; set; }
       public String cotacaoMoeda  { get; set; }
       public String quantidade    { get; set; }
       public String cobrado       { get; set; }
	   //PLV-5063 - FIM
    }

    public class RetornoTO {
        public List < RecusaTO > recusas;
    }
    public class RecusaTO {
        public MensagemTO mensagens;
        public Integer codigo;
    }
    public class MensagemTO {
        public String cliente;
    }

    public void gerarPayload() {

        system.debug('gerarPayload entradaCalculo >>> '+entradaCalculo); 

        EntradaPessoa entradaCalculo = (EntradaPessoa) JSON.deserialize(entradaCalculo, EntradaPessoa.class);

        //PLV-4587 - INICIO
        system.debug('entradaCalculo >>> '+entradaCalculo); 
        /*Profissao__c profissao = [SELECT Codigo__c    
                                  FROM Profissao__c
                                  WHERE Id =: contract.Account.Profissao__c];
        */
        //PLV-4587 - FIM
        EndossoTO.request request = new EndossoTO.request();
        request.orcamento = new EndossoTO.OrcamentoTO();

        // TAG ORCAMENTO
        request.orcamento.vigenciaInicial = entradaCalculo.inicioVigencia;
        request.orcamento.vigenciaFinal = entradaCalculo.finalVigencia;
        request.orcamento.tipoVigencia = contract.Oportunidade__r.TipoVigencia__c;
        request.orcamento.idProdutoSf = contract.Produto__c; // PLV-5382 INICIO / FIM FIX01
        request.orcamento.tipoSeguro = 'EDS';
        //PLV-4587-INICIO
        request.orcamento.viagem = new EndossoTO.ViagemTO();
        
        List<EndossoTO.DestinoTo> destino = new List<EndossoTO.DestinoTo>();
        for(DestinoTo d : entradaCalculo.destinos){
            EndossoTO.DestinoTo dest = new EndossoTO.DestinoTo();
            dest.codigo = d.codigo;
            dest.pais = d.pais;
            destino.add(dest);
        }
       
        request.orcamento.viagem.destinos = destino;
        request.orcamento.viagem.tipoViagem = entradaCalculo.tipoViagem;
        request.orcamento.viagem.passageirosIdosos = entradaCalculo.passageirosIdosos;
        request.orcamento.viagem.passageirosNaoIdosos = entradaCalculo.passageirosNaoIdosos;
        request.orcamento.viagem.utilizaraMotocicleta = entradaCalculo.utilizaraMotocicleta;
        request.orcamento.viagem.praticaEsportesAventura = entradaCalculo.praticaEsportesAventura;
        system.debug('viagem.orcamento'+request.orcamento.viagem);
        //PLV-4587-FIM
        request.orcamento.segmento = contract.Produto__r.Segmento__c;
        request.orcamento.ordemPortal = 1;
        request.orcamento.orcnum = '';
        request.orcamento.numeroPortal = contract.Oportunidade__r.NumeroPortal__c;

        //
        request.orcamento.numeroOrcamento = contract.Oportunidade__r.Numero__c;
        request.orcamento.numeroOferta = contract.Oportunidade__r.NumeroOferta__c;
        request.orcamento.meioComercializacao = 'CO2';
        request.orcamento.entradaNegocio = contract.Oportunidade__r.EntradaNegocio__c != null? 
                                            Integer.valueOf(contract.Oportunidade__r.EntradaNegocio__c):
                                            0;
        request.orcamento.dataCalculo = String.valueOf(Date.today());
        request.orcamento.consultivo = contract.Oportunidade__r.Consultivo__c;
        request.orcamento.codigoProdutoVida = contract.Produto__r.ProductCode;
        request.orcamento.closeDate = null;
        request.orcamento.canalDistribuicao = contract.Oportunidade__r.CanalDistribuicao__r.Sigla__c;
        request.orcamento.susepOrcamento = contract.Oportunidade__r.CodigoCorretor__r.Name; //PLV-4587 FIX 2 INICIO/FIM




        // TAG ORCAMENTO.CONTRATOORIGINAL
        request.orcamento.contratoOriginal = new EndossoTO.ContratoOriginalTO();
        request.orcamento.contratoOriginal.empresa = contract.Empresa__c;
        request.orcamento.contratoOriginal.sucursal = contract.Sucursal__c;
        request.orcamento.contratoOriginal.ramo = contract.CodigoRamo__c;
        request.orcamento.contratoOriginal.apolice = contract.NumeroApolice__c;
        request.orcamento.contratoOriginal.endosso = contract.Endosso__c;

        system.debug('request.orcamento.contratoOriginal.endosso >>> '+request.orcamento.contratoOriginal.endosso); 

        system.debug('request >>> '+request); 
        
        system.debug('request.orcamento.contratoOriginal >>> '+request.orcamento.contratoOriginal); 

        // PLV-4666-INICIO
        String idContratante = [SELECT id, name FROM ContratanteContrato__c WHERE Contrato__c = :contract.id LIMIT 1].Id;
        Decimal valorPago = 0;
        ParcelamentoContratoTO retornoParcelas = new ParcelamentoContratoTO();
        retornoParcelas.data = new List<ParcelamentoContratoTO.DataTO>();
        if(!Test.isRunningTest()){
          retornoParcelas = ContractFacade.getInstance().ObterParcelasContratoSegurado(idContratante);
        }

        if(!retornoParcelas.data.isEmpty())
        {
          for(ParcelamentoContratoTO.DataTO item: retornoParcelas.data)
          {
            if(item.status == 'PAGA'){
                valorPago += decimal.ValueOf(item.valorParcela);
            }
          }
        }
        request.orcamento.contratoOriginal.premioPago = valorPago;
        // PLV-4666-FIM

        // TAG ORCAMENTO.REMUNERACOES
        request.orcamento.remuneracoes = new List < EndossoTO.RemuneracaoTO > ();
        if(this.contract.RemuneracoesContrato__r.size() > 0){
            for(RemuneracaoContrato__c remuneracaoAtual: this.contract.RemuneracoesContrato__r){
                EndossoTO.RemuneracaoTO remuneracao = new EndossoTO.RemuneracaoTO();
                remuneracao.percentual = remuneracaoAtual.Percentual__c;
                remuneracao.tipoRemuneracao = contract.RemuneracoesContrato__r[0].TipoRemuneracao__r.Name;
                request.orcamento.remuneracoes.add(remuneracao);
            }
        }

        // TAG ORCAMENTO.CONTRATANTES
        request.orcamento.contratantes = new List < EndossoTO.ContratanteTO > ();
        EndossoTO.ContratanteTO contratante = new EndossoTO.ContratanteTO();
        contratante.tipo = 'PRI';
        contratante.numero = 1;

        // TAG ORCAMENTO.CONTRATANTES.GRUPOS
        contratante.grupos = new List < EndossoTO.GrupoTO > ();
        for (GrupoContrato__c grupoContrato: lstGrupoContrato) {

            EndossoTO.GrupoTO grupo = new EndossoTO.GrupoTO();
            grupo.tarifa = 0;
            grupo.tipoCalculo = grupoContrato.TipoCalculo__c;
            grupo.numero = Integer.valueOf(grupoContrato.Numero__c);
            grupo.nome = grupoContrato.Name;
            grupo.qtdeVidas = 1; //Integer.valueOf(grupoContrato.QuantidadeVidas__c); PLV-4587 - INICIO/FIM

            grupo.segurados = new List < EndossoTO.SeguradoTO > ();
            EndossoTO.SeguradoTO segurado = new EndossoTO.SeguradoTO();
            segurado.numero = 1;
            segurado.coberturas = new List < EndossoTO.CoberturaTO > ();
            segurado.pessoa = new EndossoTO.PessoaTO();
            segurado.pessoa.rendaMensal = String.valueOf(contract.Account.Renda__c);
            segurado.pessoa.nome = contract.Account.name;
            segurado.pessoa.dadosPessoaFisica = new EndossoTO.DadosPessoaFisicaTO();
            //segurado.pessoa.dadosPessoaFisica.profissao = String.valueOf(profissao.Codigo__c); PLV-4587 - INICIO/FIM
            segurado.pessoa.dadosPessoaFisica.sexo = contract.Account.Sexo__c;
            segurado.pessoa.dadosPessoaFisica.fumante = contract.Account.Fumante__c == 'Sim'? true: false;
            segurado.pessoa.dadosPessoaFisica.dataNascimento = String.valueOf(contract.Account.PersonBirthdate);
            segurado.pessoa.dadosPessoaFisica.regimeTrabalho = contract.Account.RegimeTrabalho__c;


            // List < String > siglas = new List < String > ();
            // for (EntradaCobertura eCobertura: ePessoa.coberturas) {
            //     siglas.add(eCobertura.sigla);
            // }

            // Map < String, FranquiaGarantia__c > mapFranquiaGarantia = new Map < String, FranquiaGarantia__c > ();
            // Map < String, GarantiaContrato__c > mapGarantiaContrato = new Map < String, GarantiaContrato__c > ();
            // List < FranquiaGarantia__c > listFranquiaGarantia = [SELECT Id, Franquia__r.CodigoFranquia__c, Franquia_Padrao__c, GarantiaProduto__r.Garantia__r.Sigla__c, GarantiaProduto__r.QuantidadeMaximaContratacao__c
            //     FROM FranquiaGarantia__c
            //     WHERE Franquia_Padrao__c = true
            //     AND GarantiaProduto__r.Garantia__r.Sigla__c IN: siglas
            // ];

            // List < String > siglasFranquia = new List < String > ();
            // for (FranquiaGarantia__c fg: listFranquiaGarantia) {
            //     siglasFranquia.add(fg.GarantiaProduto__r.Garantia__r.Sigla__c);
            //     mapFranquiaGarantia.put(fg.GarantiaProduto__r.Garantia__r.Sigla__c, fg);
            // }

            // List < GarantiaContrato__c > listGarantiaContrato = [SELECT Id, Capital__c, Garantia__r.Sigla__c
            //     FROM GarantiaContrato__c
            //     WHERE Garantia__r.Sigla__c IN: siglasFranquia
            // ];

            // for (GarantiaContrato__c gc: listGarantiaContrato) {
            //     mapGarantiaContrato.put(gc.Garantia__r.Sigla__c, gc);
            // }

            for (GarantiaContrato__c eCobertura: contract.GarantiasContrato__r) {
                System.debug('COBERTURA =>>> ' + eCobertura);
                EndossoTO.CoberturaTO cobertura = new EndossoTO.CoberturaTO();
                cobertura.sigla = eCobertura.Garantia__r.Sigla__c;
                cobertura.valor = eCobertura.Capital__c;
                cobertura.moeda = eCobertura.MoedaGarantia__c;
                cobertura.cotacaoMoeda = eCobertura.ValorCotacao__c != null? 
                                            eCobertura.ValorCotacao__c: 
                                            1;
                cobertura.cobrado = eCobertura.Garantia__r.Name;

                segurado.coberturas.add(cobertura);
            }

            grupo.segurados.add(segurado);
            contratante.grupos.add(grupo);
        }

        request.orcamento.contratantes.add(contratante);

        payload = JSON.serialize(request);

        System.debug('>PAYLOAD> gerarPayload ' + payload);
        System.debug('>CONTRATO>  gerarPayload ' + contract);

        // pagOfertas(payload);     //MGRC-1657 - INICIO/FIM     

        System.debug('ofertaPadrao '+ofertaPadrao);
    }

    //PLV-5063 - REMOÇÃO DE CODIGO - INICIO/FIM

    //Refencia Ofertas
    //MGRC-1657 - INICIO     
    // public void pagOfertas(String payload) {

    //     //entradaCalculo Recebe parametros de Entrada do Calculo
    //     //calculoOfertas tras o Retorno do Calculo.
    //     //ofertaPadrao recebe o objeto de Retorno do Calculo
    //     String retorno2;
    //     retorno2 = calculoOfertas(payload);
    //     if (retorno2 == 'Erro na requisição') {
    //         this.ofertaPadrao = '{' +
    //             +'  "message":"Erro no serviço. Entre em contato com o administrador."' +
    //             +'}';
    //         System.debug('Dentro do IF - retorno2');

    //     } else {

    //         this.ofertaPadrao = retorno2;
    //         System.debug('Dentro do ELSE - retorno2');
    //     }
    //     System.debug('Retorno Opção de Ofertas: ' + ofertaPadrao);
    // }
    //MGRC-1657 - FIM     
	//PLV-5063 - INICIO
    //Valida a vigência do endosso de extensão de dias em relação ao período máximo de vigência do produto
    public Boolean validarVigenciaEndosso() {

        EntradaPessoa entradaCalculoEndosso = (EntradaPessoa) JSON.deserialize(entradaCalculo, EntradaPessoa.class);
        
        Boolean geraPayload = true;
        Date dataVigenciaInicialAtual = Date.valueOf(entradaCalculoEndosso.inicioVigencia);
        Date dataVigenciaFinalAtual = Date.valueOf(entradaCalculoEndosso.finalVigencia);
        Integer diasVigenciaAtual = Integer.ValueOf(((dataVigenciaInicialAtual).daysBetween(dataVigenciaFinalAtual)+1));

        List<ParametroVigencia__c> lstParametroVigencia = [
            SELECT PeriodoMaximoVigencia__c 
            FROM ParametroVigencia__c 
            WHERE Produto__c =: contract.Produto__c];            
        
        periodoMaximoVigencia  = Integer.ValueOf(lstParametroVigencia[0].PeriodoMaximoVigencia__c); //PLV-5063 - FIX02 - INICIO/FIM
        
        if(diasVigenciaAtual > periodoMaximoVigencia) geraPayload = false;   
        
        return geraPayload;        
    } 

    public PageReference redirectEndossoViagem(Boolean retornaUrl) {                    
        
        PageReference retURL = null;

        if(retornaUrl){         
            retURL = Page.GerarEndossoViagemMensagem;
            String mensagem = 'A data informada para o retorno de viagem não pode ser superior a ' + periodoMaximoVigencia + ' dias do início de vigência.'; //PLV-5063 - FIX02 - INICIO/FIM         
            retURL.getParameters().put('idContrato',contract.Id);
            retURL.getParameters().put('mensagem',mensagem);   
            retURL.getParameters().put('numeroContrato',contract.Name);              
            retURL.setRedirect(true);  
        }
        
        return retURL;
    }   

    public PageReference redirectContractRecord() {        
        
        PageReference recContract = new PageReference('/'+contract.Id);
        recContract.setRedirect(true);
        return recContract;  
    }
    //PLV-5063 - FIM
    //MGRC-1657 - INICIO
    //Busca o calculo do Serviço da CIVSERVICE
    // public static String calculoOfertas(String calculosContrats) {
    //     system.debug('calculo contrato calculoOfertas >> '+calculosContrats);
    //     String Response;

    //     try {
    //         Response = ''; //civServ.criacaoCalculo(calculosContrats); 	 
    //         system.debug('Response Calculo Padrão ==>' + Response);

    //         String mensagem = '';
    //         Map < String, Object > result = (Map < String, Object > ) JSON.deserializeUntyped(Response);
    //         System.debug('result ' + result);
    //         if (result.get('recusas') != null) {
    //             System.debug('tem recusa');
    //             RetornoTO retorno = (RetornoTO) JSON.deserialize(Response, CtrFormularioSnipper.RetornoTO.class);
    //             System.debug('retorno ' + retorno);
    //             for (RecusaTO recusa: retorno.recusas) {
    //                 mensagem += recusa.mensagens.cliente + ',';
    //                 System.debug('MENSAGEM ' + mensagem);
    //             }
    //         }
    //         if (mensagem != '') {
    //             String mensagemRetorno = '{ ' +
    //                 +' "message":"' + mensagem + '' +
    //                 +'"}';
    //             return mensagemRetorno;
    //         }
    //     } catch (Exception ex) {
    //         System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());
    //         throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
    //     }

    //     return Response;
    // }
    //MGRC-1657 - FIM

    private class ExceptionHub {
        private CalloutException callExpt = new CalloutException();

        public void generic(String text) {
            this.callExpt.setMessage(text);
            throw callExpt;
        }

        public void missingContractId() {
            this.callExpt.setMessage('Endosso não permitido - Contrato não informado');
            throw callExpt;
        }

        public void contractNotissued() {
            this.callExpt.setMessage('Endosso não permitido - Contrato não Emitido');
            throw callExpt;
        }

        public void invalidSegment() {
            this.callExpt.setMessage(
                'Endosso não permitido - Segmento de produto não permite endosso de contrato'
            );
            throw callExpt;
        }
    }

    public class ServiceException extends Exception {}

}