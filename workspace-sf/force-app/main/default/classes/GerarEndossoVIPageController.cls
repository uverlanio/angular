/**
* GerarEndossoVIPageController // PLV - 4655 INICIO/FIM
* @author Gabriel Roetger Loch - gabriel.roetger@globant.com @ 19/10/2020
* PLV-4392-VI
**/
public class GerarEndossoVIPageController {
    
    //PLV-4484 - INÍCIO
    public String payload { get; set; } 
    public Contract contract { get; set; }
    public SeguradoContrato__c seguradoContrato {get; set;} //II-137 INICIO-FIM
    //PLV-4650 - INICIO
    public String contractS { get; set; }
    public String beneficiarioscontrato { get; set; }
    public String enderecos { get; set; }
    public String remuneracoes { get; set; }
    public String dadoscorretores { get; set; }
    //PLV-4650 - FIM
    public List<Garantia> garantiasContract { get; set; }
    public String garantiasJsonString { get; set; } //RSM
    public String corretagemControlJsonString { get; set; } //RSM
    public Map<String, GarantiaProduto__c> garantiasProduct { get; set; }
    public Decimal agenciamento { get; set; }
    public String tipoRemuneracao { get; set; } 
    public Integer corretagem { get; set; } //PLV-4730 - INÍCIO/FIM
    public String accountProfession { get; set; }
    private ExceptionHub exceptionHub { get; set; }
    public RemuneracaoControl corretagemControl { get; set; }
    public String entradaCalculo 		{get;set;}
    public String ofertaPadrao {get;set;}
    public String professionsData { get; set; }
    //PLV-4650 - Inicio - Isabela Fin - Globant
    public String questionario { get;set; }
    public String scriptGetFromStorage { get;set; }
    private Map<String, RespostaDeclaracaoSaude> mapRespostas = new Map<String, RespostaDeclaracaoSaude>();
    //PLV-4650 - Fim - Isabela Fin - Globant
    
    public String cicloVacinal { get; set; } //PLV-5150 - INÍCIO/FIM
    
    private List<String> usedGarantias { get; set; }
    private List<GrupoContrato__c> lstGrupoContrato; 
    public Map<Id, FranquiaGarantia__c> mapFranquiaDaGarantia {get;set;} //PLV-4481 DIT - VINICIUS - INICIO/FIM
    
    //private static final CtrFormularioSnipper instancia = new CtrFormularioSnipper();
    private static CIVServices civServ = CIVServices.getInstance();

    //PLV-4650 - Inicio - Isabela Fin - Globant
    public GerarEndossoVIPageController(ApexPages.StandardController controller) {
        System.debug('SENSEDIA - JOAO 1');
        this.exceptionHub = new ExceptionHub();
        this.professionsData = '{}';
        this.accountProfession = '';
        this.garantiasContract = new List<Garantia>();
        this.usedGarantias = new List<String>();
        this.garantiasProduct = new Map<String, GarantiaProduto__c>();
        this.corretagem = 0;
        this.agenciamento = 0;
        this.tipoRemuneracao = ''; 
        this.questionario = '';
        this.mapFranquiaDaGarantia = new Map<Id, FranquiaGarantia__c>(); //PLV-4481 DIT- VINICIUS - INICIO/FIM
        
        lstGrupoContrato = new List<GrupoContrato__c>(); 
        
        ID contractId = (ID) controller.getRecord().id;
        if(contractId == null) contractId = (ID) ApexPages.currentPage().getParameters().get('idContrato');
        System.debug('contractId >> ' + contractId);
        
        this.getData(contractId);
        
        this.setupGarantias();
        this.getGrupoContrato(contractId);
        this.getCicloVacinal(contractId); //PLV-5150 - INICIO/FIM  
        this.getProfessions();//RSM  
        System.debug('SENSEDIA - JOAO 2');
        //FNPVVEP-92 INICIO  
        // if(ApexPages.currentPage().getParameters().get('getFromStorage') == 'true')
        //     scriptGetFromStorage = '<script>getFromStorage();</script>';
        //FNPVVEP-92 FIM
    }
    //PLV-4650 - Fim - Isabela Fin - Globant
    
    
    private void getData(id ctrId) {
        this.getContract(ctrId);
        if(contract.Proposta__c != null) this.getHealthStatement(contract.Proposta__c); // PLV - 4655 INICIO/FIM
        System.debug('PRODUTO+++++' + contract.Produto__c);
        if(contract.Produto__c != null) this.getGarantiasProduto(contract.Produto__c);
        this.corretagemControl = new RemuneracaoControl(this.contract.Produto__c);
        this.corretagemControlJsonString = JSON.serialize(this.corretagemControl); //RSM
        
        System.debug('PEDRÃO >>> contractS'+ JSON.serialize(this.contractS));
        System.debug('PEDRÃO >>> beneficiarioscontrato'+ JSON.serialize(this.beneficiarioscontrato));
        System.debug('PEDRÃO >>> enderecos'+ JSON.serialize(this.enderecos));
    }
    
    private void getContract(id ctrId) {
        //II-137 INICIO
        Map<String, Object> combinedInfo = new Map<String, Object>();
        this.contract = null;
        this.seguradoContrato = null;
        //II-137 FIM
        try {
            
            this.contract = [
                SELECT
                id,
                name,
                Status,
                ValorIOF__c,
                StartDate, VigenciaFinal__c,
                TaxaComercial__c, TaxaPura__c, TaxaTotal__c,
                PremioComercial__c, PremioPuro__c, PremioTotal__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
                Endosso__c, Empresa__c, CodigoRamo__c, Sucursal__c, NumeroApolice__c,
                MeioComercializacao__c,
                DataEndosso__c, //INICIO/FIM - PLV-4686 - Guilherme Brito
                Produto__c,
                Produto__r.Segmento__c,
                Produto__r.ProductCode,
                Produto__r.CodigoPrecificaProduto__c, //PLV-5331 - INICIO/FIM
                TipoContrato__c, //PLV-4650 INICIO/FIM
                Nome_Social__c,  //RSM
                Account.name,
                Account.nomeSocial__c, // LECVPV-188 INICIO/FIM
                Account.PersonBirthdate,
                Account.Sexo__c,
                Account.Fumante__c,
                Account.Profissao__pc,
                Account.Profissao__c,
                Account.Profissao__r.NomeFantasia__c,
                Account.RegimeTrabalho__c,
                Account.Renda__c,
                Tipo__c, //PLV-5754 INICIO/FIM
                //PLV-4650 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
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
                //PLV-4650 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
                
                
                
                
                Oportunidade__r.NumeroOferta__c,
                Oportunidade__r.Name,
                Oportunidade__r.Numero__c,
                Oportunidade__r.CanalDistribuicao__r.Sigla__c,
                Oportunidade__r.CodigoCorretor__r.Name, // PLV-4481 INICIO/FIM
                Oportunidade__r.NumeroPortal__c,      
                Oportunidade__r.TipoVigencia__c,        
                Oportunidade__r.VigenciaInicial__c,     
                Oportunidade__r.VigenciaFinal__c,       
                Oportunidade__r.EntradaNegocio__c,            
                Oportunidade__r.CloseDate,              
                Oportunidade__r.Consultivo__c,
                Proposta__c, //PLV-4650 - Inicio/Fim - Isabela Fin - Globant
                (
                    SELECT
                    ID,
                    Capital__c,
                    TipoGarantia__c,
                    MoedaGarantia__c,
                    TaxaComercial__c, TaxaPura__c, TaxaTotal__c,
                    PremioComercial__c, PremioPuro__c, PremioTotal__c, PremioIntegral__c, //PLV-5351 INICIO/FIM
                    Garantia__r.name,
                    Garantia__r.Sigla__c,
                    Garantia__r.Tipo__c
                    FROM GarantiasContrato__r
                    ORDER BY Name
                ),
                (
                    SELECT id, Percentual__c, TipoRemuneracao__r.name
                    FROM RemuneracoesContrato__r
                ),
                (
                    SELECT  Id, Name, Tipo__c, TaxaComercial__c, TaxaPura__c, TaxaTotal__c,
                    PremioComercial__c, PremioPuro__c, PremioTotal__c, PremioIntegral__c //PLV-5351 INICIO/FIM
                    FROM ContratantesContrato__r
                )
                FROM Contract
                WHERE id = :ctrId
                LIMIT 1
            ];

            //II-137 INICIO
            this.seguradoContrato = [SELECT  Id, RamoAtividade__c, tipoEmpresa__c, numeroCnpj__c, qtdFuncionarios__c, 
            GrupoContrato__r.ContratanteContrato__r.Contrato__r.Id, CicloVacinal__c //RSM
            FROM SeguradoContrato__c
            WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__r.Id = :ctrId LIMIT 1];

            combinedInfo.put('contractInfo', this.contract);
            combinedInfo.put('seguradoInfo', this.seguradoContrato);
            //II-137 FIM

            //PLV-4650 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
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
                    if(!mapDados.containskey(dc.NomeCorretor__c))
                        mapDados.put(dc.NomeCorretor__c, new List<DadosCorretor__c>());
                    
                    if(dc.CodigoSucursalVinculo__c !=null){
                        System.debug('CodigoSucursalVinculo__c: ' + dc.CodigoSucursalVinculo__c );
                    }
                    mapDados.get(dc.NomeCorretor__c).add(dc);
                }
                System.debug('mapDados: mapDados'+JSON.serialize(mapDados));
                System.debug('listFavorecidos: listFavorecidos'+JSON.serialize(listFavorecidos));
                
                this.remuneracoes = JSON.serialize(listFavorecidos);
                this.dadoscorretores = JSON.serialize(mapDados);
            }
            
            
            //PLV-4650 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
            
        } catch (Exception e) {
            System.debug('Error while getting contract:');
            System.debug(e);
        }
        
        if (this.contract == null)
            this.exceptionHub.missingContractId();
        
        if (this.contract.Status != 'Emitido')
            this.exceptionHub.contractNotissued();
        
        if (this.contract.Produto__r.Segmento__c != 'Individual')
            this.exceptionHub.invalidSegment();
        
        
        if (this.contract.Account.Renda__c == null)
            this.contract.Account.Renda__c = 0;
        
        for (RemuneracaoContrato__c r : this.contract.RemuneracoesContrato__r) {
            if (r.TipoRemuneracao__r.name == 'AGENCIAMENTO') {
                this.agenciamento = r.Percentual__c;
            } else if (r.TipoRemuneracao__r.name == 'CORRETAGEM') {
                //PLV-4730 - INÍCIO
                if(r.Percentual__c != null){
                    this.corretagem = r.Percentual__c.intValue(); //PLV-4730 - INÍCIO/FIM
                }
                //PLV-4730 - FIM
            }
            
            this.tipoRemuneracao = r.TipoRemuneracao__r.name; //PLV-4484 INICIO/FIM
        }
        
        this.accountProfession = this.contract.Account.Profissao__c != null
            ? this.contract.Account.Profissao__r.NomeFantasia__c
            : '';
        //PLV-4650 INICIO
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
                                                     , NomeSocial__c // LECVPV-188 INICIO/FIM
                                                     , NomePessoaPep__c
                                                     , Participacao__c
                                                     , Pep__c
                                                     , PercentualIndenizacao__c
                                                     , SeguradoContrato__c
                                                     , Sexo__c
                                                     , TipoBeneficiario__c
                                                     FROM BeneficiarioSeguradoContrato__c
                                                     WHERE SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c=:contract.Id]);
        //II-137 INICIO                                             
        //this.contractS = JSON.serialize(this.contract);
        this.contractS = JSON.serialize(combinedInfo);
        //II-137 FIM
        //PLV-4650 -FIM
    }
    //PLV-4484 - FIM

    //TKCL-603 INICIO
    public String getTitleEndosso() {
        return ('APTLMKT'.equals(this.contract.Produto__r.CodigoPrecificaProduto__c)) ? 'Endosso Porto Acidentes Pessoais Individual' : 'Endosso de Seguros Individuais'; //FNPVVEP-92 INICIO/FIM
    }
    //TKCL-603 FIM

    //TKCL-603 INICIO
    public Boolean isAPTLMKT() {
        if (this.contract == null || this.contract.Produto__r == null) {
            return false;
        }
        return 'APTLMKT'.equals(this.contract.Produto__r.CodigoPrecificaProduto__c);
    }
    //TKCL-603 FIM
    
    //PLV-4650 - Inicio - Isabela Fin - Globant
    private void getHealthStatement(Id prpId){
        DeclaracaoSaude__c healthStatement = new DeclaracaoSaude__c();
        healthStatement = null;
        try {
            
            healthStatement = [
                SELECT
                Id,
                (
                    SELECT
                    Id,
                    PerguntaQuestionarioRisco__r.Pergunta__r.Name,
                    PerguntaQuestionarioRisco__r.Pergunta__r.Pergunta__c,
                    Resposta__c
                    FROM DeclaracaoSaude__r
                )
                FROM DeclaracaoSaude__c
                WHERE Proposta__c = :prpId
                LIMIT 1
            ];
            System.debug('XXX - healthStatement:' + JSON.serialize(healthStatement));
        } catch (Exception e) {
            System.debug('Error while getting health statement:');
            System.debug(e);
            return;
        }
        if(healthStatement == null || healthStatement.DeclaracaoSaude__r.isEmpty()) return;
        
        for(RespostaDeclaracaoSaude__c resp :healthStatement.DeclaracaoSaude__r){
            if(resp.PerguntaQuestionarioRisco__r != null){
                if(resp.PerguntaQuestionarioRisco__r.Pergunta__r != null){
                    RespostaDeclaracaoSaude respostaObj = new RespostaDeclaracaoSaude();
                    respostaObj.nomePergunta = resp.PerguntaQuestionarioRisco__r.Pergunta__r.Name;
                    respostaObj.textoPergunta = resp.PerguntaQuestionarioRisco__r.Pergunta__r.Pergunta__c;
                    respostaObj.resposta = resp.Resposta__c;
                    this.mapRespostas.put(respostaObj.nomePergunta,respostaObj);
                }
            }
        }
        
        if(!this.mapRespostas.isEmpty()) this.questionario = JSON.serialize(this.mapRespostas);
    }
    //PLV-4650 - Fim - Isabela Fin - Globant
    
    private void getGarantiasProduto(ID procuctId) {
        System.debug('PRODUTO ID+++ ' + procuctId);
        List<GarantiaProduto__c> garantiasProduto = [
            SELECT
            ID,
            Obrigatoria__c,
            LimiteCapitalMinimo__c,
            LimiteCapitalMaximo__c,
            Garantia__r.Name,
            Garantia__r.Sigla__c,
            Garantia__r.Tipo__c,
            CurrencyIsoCode
            FROM GarantiaProduto__c
            WHERE Produto__c = :procuctId
        ];
        System.debug('SELECT+++++ ' + garantiasProduto);
        
        for (GarantiaProduto__c garantiaProd : garantiasProduto)
            this.garantiasProduct.put(
                garantiaProd.Garantia__r.Sigla__c,
                garantiaProd
            );
        System.debug('MapPRODUTO++++ ' + garantiasProduct);
    }
    
    private void setupGarantias() {
        System.debug('this.contract.GarantiasContrato__r >> ' + this.contract.GarantiasContrato__r);
        for (GarantiaContrato__c garantiaContract : this.contract.GarantiasContrato__r){
            Garantia garantia = new Garantia(
                garantiaContract,
                this.garantiasProduct.get(garantiaContract.Garantia__r.Sigla__c),
                this.contract.Tipo__c, //PLV-5754 INICIO/FIM
                true
            );

            this.usedGarantias.add(garantia.initials);    
            this.garantiasContract.add(garantia);
        }
        System.debug('this.garantiasContract antes de tudo ' + this.garantiasContract);
        //setup garantias of the product that's not on contract
        System.debug('this.garantiasProduct antes de tudo ' + garantiasProduct);
        for (String key : this.garantiasProduct.keySet()) {
            if (!usedGarantias.contains(key)) {
                this.garantiasContract.add(
                    new Garantia(this.garantiasProduct.get(key))
                );
            }
        }
        System.debug('this.garantiasContract meio de tudo ' + this.garantiasContract);

        // for (Integer i = this.garantiasContract.size() - 1; i >= 0; i--) {
        //     if ((this.garantiasContract[i].initials == 'TELEMED' || this.garantiasContract[i].initials == 'APN') && this.garantiasContract[i].isActive) {
        //         this.garantiasContract.remove(i);
        //     }
        // }
        System.debug('this.garantiasContract depois de tudo ' + this.garantiasContract);   
        this.garantiasJsonString = JSON.serialize(this.garantiasContract); //RSM
    }
    
    public void getProfessions() {
        List<Profissao__c> lstProfessions = [
            SELECT id, Name, NomeFantasia__c, CodigoProfissao__c
            FROM Profissao__c
            WHERE
            Status__c = 'Ativo'
            //OR id = :this.accountProfession) //RSM
            AND NomeFantasia__c != ''
        ];
        
        this.professionsData = JSON.serialize(lstProfessions);
    }
    
    private class Garantia {
        public String name { get; set; }
        public String initials { get; set; }
        public Decimal capital { get; set; }
        public Decimal minCapital { get; set; }
        public Decimal maxCapital { get; set; }
        public Boolean required { get; set; }
        public Boolean isActive { get; set; }
        public String coin { get; set; }
        public String type { get; set; }
        public String TipoContrato { get; set; } //PLV-5754 INICIO/FIM
        public List<String> includentes { get;set; } // TKCL-603 INICO/FIM
        public List<String> excludentes { get;set; } // TKCL-603 INICIO/FIM
        // os incluintes representam as garantias que possuem a garantia em questao como includente.
        // P.Ex: Se A tem B como includente, A é incluinte de B, ou seja, A fará parte da lista de incluintes de B.
        // Quando retiramos uma garantia de um contrato, teremos que retirar automaticamente os seus incluintes.
        public List<String> incluintes { get;set; } // TKCL-603 INICO/FIM
       // public List<String> excluintes { get;set; } // TKCL-603 INICIO/FIM

        public Garantia(
            GarantiaContrato__c garantiaContract,
            GarantiaProduto__c garantiaProd,
            String TipoContrato, //PLV-5754 INICIO/FIM
            Boolean isActive
        ) {
            this.name = garantiaContract.Garantia__r.name;
            this.initials = garantiaContract.Garantia__r.Sigla__c;
            this.type = garantiaContract.Garantia__r.Tipo__c;
            this.isActive = isActive;
            this.TipoContrato = TipoContrato; //PLV-5754 INICIO/FIM
            this.includentes = new List<String>(); // TKCL-603 INICIO/FIM
            this.excludentes = new List<String>(); // TKCL-603 INICIO/FIM
            this.incluintes = new List<String>(); // TKCL-603 INICIO/FIM
          //  this.excluintes = new List<String>(); // TKCL-603 INICIO/FIM

            if (garantiaContract.Capital__c != null)
                this.capital = garantiaContract.Capital__c;
            
            if (garantiaProd != null) {
                this.coin = garantiaProd.CurrencyIsoCode;
                this.minCapital = garantiaProd.LimiteCapitalMinimo__c;
                //PLV-5754 INICIO
                if(TipoContrato == 'Renovacao'){
                    this.maxCapital = garantiaContract.Capital__c;
                }else{
                    this.maxCapital = garantiaProd.LimiteCapitalMaximo__c;
                }
                //PLV-5754 FIM
                this.required = garantiaProd.Obrigatoria__c;
                this.montarIncludentesExcludentes(garantiaProd); // TKCL-603 INICIO/FIM
                this.montarIncluintes(garantiaProd); // TKCL-603 INICIO/FIM
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
            this.includentes = new List<String>(); // TKCL-603 INICIO/FIM
            this.excludentes = new List<String>(); // TKCL-603 INICIO/FIM
            this.incluintes = new List<String>(); // TKCL-603 INICIO/FIM
            this.montarIncludentesExcludentes(garantiaProd); // TKCL-603 INICIO/FIM
            this.montarIncluintes(garantiaProd); // TKCL-603 INICIO/FIM
        }

        // TKCL-603 INICIO
        private void montarIncludentesExcludentes(GarantiaProduto__c garantiaProd) {
            List<GarantiaRelacionada__c> garantiasRelacionadas = [
                SELECT TipoDependencia__c, 
                GarantiaRelacionada__r.Garantia__r.Sigla__c 
                FROM GarantiaRelacionada__c 
                WHERE GarantiaProduto__c=:garantiaProd.ID
            ];
            if (garantiasRelacionadas !=null && !garantiasRelacionadas.isEmpty()) {
                for (GarantiaRelacionada__c relacionada: garantiasRelacionadas) {
                    if ('Excludente'.equals(relacionada.TipoDependencia__c)) {
                        this.excludentes.add(relacionada.GarantiaRelacionada__r.Garantia__r.Sigla__c);
                    }
                    if ('Includente'.equals(relacionada.TipoDependencia__c)) {
                        this.includentes.add(relacionada.GarantiaRelacionada__r.Garantia__r.Sigla__c);
                    }
                }
            }
        }
        // TKCL-603 FIM

        // TKCL-603 INICIO
        private void montarIncluintes(GarantiaProduto__c garantiaProd) {
            List<GarantiaRelacionada__c> garantiasRelacionadas = [
                SELECT TipoDependencia__c, 
                GarantiaProduto__r.Garantia__r.Sigla__c 
                FROM GarantiaRelacionada__c 
                WHERE GarantiaRelacionada__c=:garantiaProd.ID
            ];
            if (garantiasRelacionadas !=null && !garantiasRelacionadas.isEmpty()) {
                for (GarantiaRelacionada__c relacionada: garantiasRelacionadas) {
                    if ('Includente'.equals(relacionada.TipoDependencia__c)) {
                        this.incluintes.add(relacionada.GarantiaProduto__r.Garantia__r.Sigla__c);
                    }
                }
            }
        }
        // TKCL-603 FIM
    }
    
    private class RemuneracaoControl {
        public Decimal corretagemMinimum { get; set; }
        public Decimal corretagemMaximum { get; set; }
        
        public RemuneracaoControl(id prodID) {
            this.corretagemMinimum = 0;
            this.corretagemMaximum = 0;
            
            Product2 prod = [
                SELECT
                id,
                (
                    SELECT id, TipoRemuneracao__r.Name, LimiteMinimo__c, LimiteMaximo__c
                    FROM RemuneracoesProduto__r
                )
                FROM Product2
                WHERE id = :prodID
                LIMIT 1
            ];
            
            if (prod != null) {
                for (RemuneracaoProduto__c remuneracao : prod.RemuneracoesProduto__r) {
                    if (remuneracao.TipoRemuneracao__r.Name == 'CORRETAGEM') {
                        this.corretagemMinimum = remuneracao.LimiteMinimo__c;
                        this.corretagemMaximum = remuneracao.LimiteMaximo__c;
                    }
                }
            }
        }
    }
    //PLV-4484 - INÍCIO

    //MGRC-1489-INICIO
    public void calculoEndosso(){
        System.debug('entradaCalculo: ' + entradaCalculo);
        if(!Test.isRunningTest()){
            gerarPayload();
        }
    }
    //MGRC-1489-FIM
    
    private void getGrupoContrato( Id contractId ){
        lstGrupoContrato = [SELECT  Id, Name, TipoCalculo__c, Numero__c, QuantidadeVidas__c
                            FROM    GrupoContrato__c
                            WHERE   ContratanteContrato__r.Contrato__c =: contractId];
        
        
    }
    
    //PLV-5150 - INÍCIO
    private void getCicloVacinal( Id contractId ){
        List<SeguradoContrato__c> segContr = [SELECT  Id, CicloVacinal__c
                                              FROM    SeguradoContrato__c
                                              WHERE   GrupoContrato__r.ContratanteContrato__r.Contrato__c =: contractId LIMIT 1];
        
        if (segContr.size() == 0) {
            cicloVacinal = '0';
        } 
        else {
            cicloVacinal = ( segContr[0].CicloVacinal__c == null ? '0' : segContr[0].CicloVacinal__c );
        }
    }
    //PLV-5150 - FIM
    
    //PLV-4650 - Inicio - Isabela Fin - Globant
    private class RespostaDeclaracaoSaude {
        private String nomePergunta { get; set; }
        private String textoPergunta { get; set; }
        private String resposta { get; set; }
    }
    //PLV-4650 - Fim - Isabela Fin - Globant
    
    public class EntradaPessoa {
        public String nome {get;set;}
        public String nomeSocial {get;set;} // LECVPV-188 INICIO/FIM
        public String dataNascimento {get;set;}
        public String sexo {get;set;}
        public Boolean fumante {get;set;}
        public String profissao {get;set;}
        public String rendaMensal {get;set;} //PLV-4655 fix 1 - INICIO
        public String regimeTrabalho {get;set;}
        public List<EntradaCobertura> coberturas {get;set;}
        public Decimal percentual {get;set;}
        public String dataEndosso {get;set;} //INICIO/FIM - PLV-4686 - Guilherme Brito
        public Boolean manterParcelamento {get;set;} // PLV-5066 INICIO/FIM
        public String cicloVacinal { get; set; } // PLV-5150
    }
    
    public class EntradaCobertura{
        
        public String sigla {get;set;}
        public Decimal valor {get;set;}
        public String moeda {get;set;}
        public String cotacaoMoeda {get;set;}
        public String quantidade {get;set;}
        public String cobrado {get;set;}
    }
    
    public class RetornoTO{
        public List<RecusaTO> recusas;
    }
    public class RecusaTO{
        public MensagemTO mensagens;
        public Integer codigo; 
    }
    public class MensagemTO{
        public String cliente;
    }
    
    public void gerarPayload() {
        system.debug('@jvbds Entrada Calculo '+ JSON.serialize(entradaCalculo));
        
        EntradaPessoa ePessoa = (EntradaPessoa)JSON.deserialize(entradaCalculo, EntradaPessoa.Class);
        
        System.debug('ePessoaJSON:' + ePessoa);
        
        EndossoTO.request request = new EndossoTO.request();
        request.orcamento = new EndossoTO.OrcamentoTO();
        // PLV-4481 - INICIO
        request.orcamento.dataEndosso = String.isNotBlank(ePessoa.dataEndosso) && ePessoa.dataEndosso.contains('T') ? ePessoa.dataEndosso.split('T')[0] : ePessoa.dataEndosso; //INICIO/FIM - PLV-4686 - Guilherme Brito
        request.orcamento.tipoSeguro = 'EDS';
        request.orcamento.numeroOrcamento = contract.Oportunidade__r.Numero__c;
        request.orcamento.numeroOferta = contract.Oportunidade__r.NumeroOferta__c;
        request.orcamento.orcnum = '';
        //FNPVVEP-29 - INICIO 
        request.orcamento.dataCalculo = String.valueOf(contract.StartDate > System.today() ? contract.StartDate : System.today());
        //request.orcamento.dataCalculo = String.valueOf(System.today());
        //FNPVVEP-29 - FIM
        request.orcamento.codigoProdutoVida = contract.Produto__r.CodigoPrecificaProduto__c;
        // request.orcamento.codigoPrecProd = contract.Produto__r.CodigoPrecificaProduto__c; // PLV-5331 INICIO / FIM 
        request.orcamento.idProdutoSf = contract.Produto__c; // PLV-5331 INICIO / FIM 
        //request.orcamento.meioComercializacao = contract.MeioComercializacao__c;
        request.orcamento.meioComercializacao = 'SFC'; //PLV-4650 - Inicio/Fim - Isabela Fin - Globant //PLV-4550 INICIO/FIM
        request.orcamento.ordemPortal = 1;
        request.orcamento.canalDistribuicao = contract.Oportunidade__r.CanalDistribuicao__r.Sigla__c;
        // PLV-4481 - FIM
        //request.orcamento.susep = contract.Oportunidade__r.CodigoCorretor__r.Name; // PLV - 4655 INICIO/FIM
        
        request.orcamento.numeroPortal = contract.Oportunidade__r.NumeroPortal__c;
        request.orcamento.tipoVigencia = contract.Oportunidade__r.TipoVigencia__c;
        //FNPVVEP-29 - INICIO 
        request.orcamento.vigenciaInicial = contract.StartDate > System.today() ? contract.StartDate : (ePessoa.dataEndosso != null ? date.valueOf(ePessoa.dataEndosso) : System.today());
        //request.orcamento.vigenciaInicial = ePessoa.dataEndosso !=null ? date.valueOf(ePessoa.dataEndosso) : System.today();
        //FNPVVEP-29 - FIM
        request.orcamento.vigenciaFinal = contract.VigenciaFinal__c; 
        request.orcamento.qtdDiasVigencia = System.today().daysBetween(contract.VigenciaFinal__c) + 1;   //PLV-5833 INICIO/FIM
        //request.orcamento.closeDate = contract.Oportunidade__r.VigenciaFinal__c; // PLV - 4655 INICIO/FIM
        request.orcamento.entradaNegocio = 0;//contract.Oportunidade__r.EntradaNegocio__c != null ? contract.Oportunidade__r.EntradaNegocio__c : '';    // PLV - 4655 INICIO/FIM
        request.orcamento.segmento = contract.Produto__r.Segmento__c ;
        //request.orcamento.consultivo = contract.Oportunidade__r.Consultivo__c;   // PLV - 4655 INICIO/FIM
        
        request.orcamento.contratoOriginal = new EndossoTO.ContratoOriginalTO();
        request.orcamento.contratoOriginal.empresa = contract.Empresa__c;
        request.orcamento.contratoOriginal.sucursal = contract.Sucursal__c;
        System.debug('>>>>contract.Sucursal__c:' + contract.Sucursal__c);
        request.orcamento.contratoOriginal.ramo = contract.CodigoRamo__c;
        request.orcamento.contratoOriginal.apolice = contract.NumeroApolice__c;
        request.orcamento.contratoOriginal.endosso = contract.Endosso__c;
        request.orcamento.contratoOriginal.tipoContrato = contract.TipoContrato__c; // PLV - 4481 INICIO/FIM

        System.debug('contract.NumeroApolice__c:' + contract.NumeroApolice__c + 'contract.TipoContrato__c: '+contract.TipoContrato__c);
        // PLV-4655 - INICIO Vinícius Caetano - Globant
        request.orcamento.contratoOriginal.vigenciaFinal = contract.VigenciaFinal__c;
        request.orcamento.contratoOriginal.vigenciaInicial = contract.StartDate;
        request.orcamento.contratoOriginal.qtdDiasVigencia = contract.StartDate.daysBetween(contract.VigenciaFinal__c) + 1; //PLV-5833 INICO-FIM
        //request.orcamento.contratoOriginal.dataEndosso = String.valueOf(ePessoa.dataEndosso); //INICIO/FIM - PLV-4686 - Guilherme Brito
        
        //INICIO - PLV-4686 - Guilherme Brito
        if(contract != null && ePessoa.dataEndosso != null && ePessoa.dataEndosso != '' && ePessoa.dataEndosso < string.valueof(contract.VigenciaFinal__c)){
            contract.DataEndosso__c = date.valueOf(ePessoa.dataEndosso);
        }
        //FIM - PLV-4686 - Guilherme Brito
        
        //Calcular premio pago
        Decimal valorPago = 0;
        Decimal valorTotal = 0;
        
        String idContratante = [SELECT id, name FROM ContratanteContrato__c WHERE Contrato__c = :contract.id LIMIT 1].Id;
        
        ParcelamentoContratoTO retornoParcelas = new ParcelamentoContratoTO();
        retornoParcelas.data = new List<ParcelamentoContratoTO.DataTO>();
        if(!Test.isRunningTest()){
            retornoParcelas = ContractFacade.getInstance().ObterParcelasContratoSegurado(idContratante);
        }
        
        if(!retornoParcelas.data.isEmpty()){
            for(ParcelamentoContratoTO.DataTO item: retornoParcelas.data)
            {
                if(item.status == 'PAGA'){
                    valorPago += decimal.ValueOf(item.valorParcela);
                }
                valorTotal += decimal.ValueOf(item.valorParcela);
            }
        } else {
            for(ParcelamentoContratoTO.DataTO item: retornoParcelas.data)
            {
                if(item.status == 'PAGA'){
                    valorPago = 0 ;
                }
                valorTotal = 0;
            } 
        }
        request.orcamento.contratoOriginal.premioPago = valorPago; // PLV-4666-INICIO/FIM
        
        
        List<String> siglas = new List<String>();
        for( EntradaCobertura eCobertura : ePessoa.coberturas ){
            siglas.add(eCobertura.sigla);
        }
        
        Map<String, FranquiaGarantia__c> mapFranquiaGarantia = new Map<String, FranquiaGarantia__c>();
        Map<String, GarantiaContrato__c> mapGarantiaContrato = new Map<String, GarantiaContrato__c>();
        List<EndossoTO.CoberturaTO> listCobertura = new List<EndossoTO.CoberturaTO>();
        
        List<FranquiaGarantia__c> listFranquiaGarantia = [SELECT Id, Franquia__r.CodigoFranquia__c, Franquia_Padrao__c,  GarantiaProduto__r.Garantia__r.Sigla__c, GarantiaProduto__r.QuantidadeMaximaContratacao__c 
                                                        FROM FranquiaGarantia__c 
                                                        WHERE Franquia_Padrao__c = true 
                                                        AND GarantiaProduto__r.Garantia__r.Sigla__c IN: siglas];
        
        List<String> siglasFranquia = new List<String>();
        for(FranquiaGarantia__c fg : listFranquiaGarantia){
            siglasFranquia.add(fg.GarantiaProduto__r.Garantia__r.Sigla__c);
            mapFranquiaGarantia.put(fg.GarantiaProduto__r.Garantia__r.Sigla__c, fg);
        }
        
        // PLV-4488 FIX 3 INICIO - AJUSTE NA QUERY 
        List<GarantiaContrato__c> listGarantiaContrato = 
            [SELECT Id, Capital__c , 
                Garantia__r.Sigla__c, 
                GarantiaProduto__r.Garantia__r.Sigla__c, //FNPVVEP-159 INICIO/FIM
                FranquiaGarantia__c, //FNPVVEP-159 INICIO/FIM
                FranquiaGarantia__r.Franquia__r.CodigoFranquia__c,//FNPVVEP-159 INICIO/FIM
                Limite_de_uso__c//PLV-4889-INICIO/FIM //PLV-4481 DIT - VINICIUS - INICIO/FIM
            FROM GarantiaContrato__c 
            WHERE Contrato__c =: contract.id];//PLV-4889-INICIO/FIM
        System.debug('GARANTIAS VI CONTROLLL '+JSON.serialize(listGarantiaContrato));
        // PLV-4488 FIX 3 FIM - AJUSTE NA QUERY 
        
        //PLV-4481 DIT - VINICIUS - INICIO/FIM
        Set<id> idsGarantias = new Set<id>();
        Set<id> idsGarantiaContrato = new Set<id>();
        for(GarantiaContrato__c garantiaContrato: listGarantiaContrato){
            idsGarantias.add(garantiaContrato.FranquiaGarantia__c);
            idsGarantiaContrato.add(garantiaContrato.id);
            mapGarantiaContrato.put(garantiaContrato.Garantia__r.Sigla__c, garantiaContrato);//PLV-4889-INICIO/FIM
        }

        List<FranquiaGarantia__c> franquiatemp = new List<FranquiaGarantia__c>([SELECT Id, Name, Franquia__r.CodigoFranquia__c, (SELECT id, Name FROM Garantias_do_contrato__r where id in :idsGarantiaContrato  LIMIT 1) FROM FranquiaGarantia__c WHERE id IN :idsGarantias]);
        System.debug('franquiatemp'+JSON.serialize(franquiatemp));

        for(FranquiaGarantia__c franquiatmp : franquiatemp){
            if(!franquiatmp.Garantias_do_contrato__r.isEmpty()){
                for(GarantiaContrato__c fran : franquiatmp.Garantias_do_contrato__r){
                    mapFranquiaDaGarantia.put(fran.Id, franquiatmp);
                }
            }
        }
        //PLV-4481 DIT - VINICIUS - FIM
        //PLV-4889 - INICIO - PEDRO AUGUSTO BRAZ
        system.debug('mapGarantiaContrato.values() >> '+ mapGarantiaContrato.values());
        Decimal qntLimite = 360;
        for(GarantiaContrato__c gc : mapGarantiaContrato.values()){
            EndossoTO.CoberturaTO cobertura = new EndossoTO.CoberturaTO();
            cobertura.sigla = gc.Garantia__r.Sigla__c;
            cobertura.valor = gc.Capital__c;
            //II-74 INICIO
            system.debug('gc.Limite_de_uso__c >>'+ gc.Limite_de_uso__c);
            system.debug('gc.garantia >>'+ gc.FranquiaGarantia__c);
            if(gc.Garantia__r.Sigla__c == 'DIA' && gc.Limite_de_uso__c != 0){
                cobertura.quantidade = gc.Limite_de_uso__c;
                qntLimite = gc.Limite_de_uso__c;
            }else if(gc.Garantia__r.Sigla__c == 'DIA'){
                cobertura.quantidade = qntLimite;
            }else if(gc.Limite_de_uso__c !=null){
                cobertura.quantidade = gc.Limite_de_uso__c;
            }else{
                cobertura.quantidade = 0;
            }
            
            //cobertura.quantidade = gc.Limite_de_uso__c !=null ? gc.Limite_de_uso__c : 0;
            //II-74 FIM
            FranquiaGarantia__c franquia = mapFranquiaDaGarantia.get(gc.id);
            if(franquia != null ){
                system.debug('franquia >>'+ franquia.Franquia__r.CodigoFranquia__c);
                cobertura.franquia = franquia.Franquia__r.CodigoFranquia__c;// FNPVVEP-91 -- INICIO-FIM
            }else{
                cobertura.franquia = '';
            }
            listCobertura.add(cobertura);
            system.debug('listCobertura >> '+ listCobertura);
        }

        //PLV-4889 - FIM - PEDRO AUGUSTO BRAZ 
        system.debug('listCobertura >> '+ listCobertura);
        
        request.orcamento.contratoOriginal.contratantes = new List<EndossoTO.ContratanteTO>();
        EndossoTO.ContratanteTO contratanteOriginal = new EndossoTO.ContratanteTO();
        contratanteOriginal.grupos = new List<EndossoTO.GrupoTO>();
        EndossoTO.GrupoTO grupoOriginal = new EndossoTO.GrupoTO();
        grupoOriginal.segurados = new List<EndossoTO.SeguradoTO>();
        EndossoTO.SeguradoTO seguradoOriginal = new EndossoTO.SeguradoTO();
        seguradoOriginal.coberturas = listCobertura;
        grupoOriginal.segurados.add(seguradoOriginal);
        contratanteOriginal.grupos.add(grupoOriginal);
        request.orcamento.contratoOriginal.contratantes.add(contratanteOriginal);
        
        
        
        List<FavorecidoRemuneracaoContrato__c> listFavorecido = [SELECT Id
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
                                                                , RemuneracaoContrato__r.BonusCampanha__c //II-167 INICIO-FIM
                                                                , Conta__c
                                                                , Conta__r.Cnpj__c
                                                                , Conta__r.Cpf__c
                                                                , Conta__r.C_digo_do_Agenciador__c
                                                                , Conta__r.Name
                                                                FROM FavorecidoRemuneracaoContrato__c
                                                                WHERE RemuneracaoContrato__r.Contrato__c =:contract.id];
        //Map<Id, FavorecidoRemuneracaoContrato__c> mapFavorecidos = new Map<Id, FavorecidoRemuneracaoContrato__c>(listFavorecido);
        request.orcamento.remuneracoes = new List<EndossoTO.RemuneracaoTO>();
        System.debug('listFavorecido>>>' +  listFavorecido);
        // PLV-5160 - INICIO - Tipo de remuneração "CORRETAGEM" nunca deve ir para o JSON duplicada
        Boolean HasCor = false;
        for(FavorecidoRemuneracaoContrato__c lf: listFavorecido){
            System.debug('lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name >>>' + lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name);
            
        
            if(lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name == 'CORRETAGEM'){
                if(HasCor){
                    continue;
                }else{
                    HasCor = true;
                }                
            }

            // PLV-5160 - FIM
            
            EndossoTO.RemuneracaoTO remuneracao = new EndossoTO.RemuneracaoTO();
            // remuneracao.percentual = lf.RemuneracaoContrato__r.Percentual__c;
            remuneracao.percentual = lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name=='AGENCIAMENTO' ? lf.RemuneracaoContrato__r.Percentual__c : ePessoa.percentual; //PLV-4666 INICIO/FIM
            remuneracao.tipoRemuneracao =  lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name;
            remuneracao.bonusCampanha =  lf.RemuneracaoContrato__r.BonusCampanha__c; //II-167 INICIO-FIM
            
            System.debug('tipoRemuneracao>>>' +  remuneracao.tipoRemuneracao);
            System.debug('remuneracao.bonusCampanha>>>' +  remuneracao.bonusCampanha);
            
            request.orcamento.remuneracoes.add(remuneracao);
            System.debug('Gilberto  request.orcamento.remuneracoes mapFavorecidos.size() >>>' + request.orcamento.remuneracoes);
            
            /*if(lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name=='AGENCIAMENTO' && mapFavorecidos.size() > 2)
            {
                //mapFavorecidos.keySet().remove(lf.Id);
                System.debug('Gilberto if mapFavorecidos >>>' + mapFavorecidos.keySet());
            }
            else if(lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name=='CORRETAGEM' && lf.RemuneracaoContrato__r.TipoRemuneracao__r.Name != 'AGENCIAMENTO' && mapFavorecidos.size() > 1)
            {
                mapFavorecidos.keySet().remove(lf.Id);
                System.debug('Gilberto else mapFavorecidos >>>' + mapFavorecidos.keySet());
            }
            System.debug('Gilberto  request.orcamento.remuneracoes mapFavorecidos.size() >>>' + request.orcamento.remuneracoes);
            request.orcamento.remuneracoes.add(remuneracao);
            System.debug('>>>> Gilberto  request.orcamento.remuneracoes mapFavorecidos.size() >>>' + request.orcamento.remuneracoes);*/
            
            
        }
        
        request.orcamento.contratantes = new List<EndossoTO.ContratanteTO>();
        EndossoTO.ContratanteTO contratante = new EndossoTO.ContratanteTO();
        contratante.tipo = 'PRI'; 
        contratante.numero = 1; 
        contratante.manterPlanoParcelamento = ePessoa.manterParcelamento; //PLV-5066 INICIO/FIM 
        //contratante.taxa = new EndossoTO.TaxaTO(); 
        // contratante.taxa.pura = 0.0;
        // contratante.taxa.comercial = 0.0;
        // contratante.taxa.total = 0.0;
        /*
Contract PremioContrato = [Select Id, Name, PremioIntegral__c, PremioComercial__c, PremioPuro__c, PremioTotal__c, NumeroApolice__c from Contract where NumeroApolice__c =: contract.NumeroApolice__c and (PremioComercial__c != 0 and PremioTotal__c !=0 ) order by CreatedDate desc limit 1];
Decimal PremioIntegral = PremioContrato.PremioIntegral__c == null ? 0.0 : PremioContrato.PremioIntegral__c;
Decimal PremioComercial = PremioContrato.PremioComercial__c == null ? 0.0 : PremioContrato.PremioComercial__c;
Decimal PremioPuro = PremioContrato.PremioPuro__c == null ? 0.0 : PremioContrato.PremioPuro__c;
Decimal PremioTotal = PremioContrato.PremioTotal__c == null ? 0.0 : PremioContrato.PremioTotal__c;

contratante.premio = new EndossoTO.PremioTO();
// contratante.premio.integral = PremioIntegral;
contratante.premio.comercial = PremioComercial;
contratante.premio.puro =  PremioPuro;
contratante.premio.total = PremioTotal;
System.debug('Select PremioContratoFinal: '+ PremioContrato.PremioTotal__c +'Numero apolice : '+ contract.NumeroApolice__c );
//  PLV-4655 - FIM Vinícius Caetano - Globant
*/
        
        //PLV-4481 DIT - VINICIUS - INICIO    
        List<FranquiaGarantia__c> franquiaGarantiasTemp = new List<FranquiaGarantia__c> ([SELECT Id, 
                                                                                                Name, 
                                                                                                Franquia__r.CodigoFranquia__c, 
                                                                                                Franquia_Padrao__c, 
                                                                                                CodigoFranquia__c, 
                                                                                                GarantiaProduto__c,
                                                                                                GarantiaProduto__r.Garantia__r.Sigla__c
                                                                                                FROM FranquiaGarantia__c 
                                                                                                WHERE GarantiaProduto__r.Produto__c = :contract.Produto__c]);
        System.debug('franquiaGarantiasTemp: ' + JSON.serialize(franquiaGarantiasTemp));

        //FNPVVEP-159 - INICIO 
        Map<String, String> codigoFranquiaIndexedBySigla = new Map<String, String>();
        for(GarantiaContrato__c garantiaContrato : listGarantiaContrato){
            if(!codigoFranquiaIndexedBySigla.containsKey(garantiaContrato.GarantiaProduto__r.Garantia__r.Sigla__c)){
                codigoFranquiaIndexedBySigla.put(garantiaContrato.GarantiaProduto__r.Garantia__r.Sigla__c, garantiaContrato.FranquiaGarantia__r.Franquia__r.CodigoFranquia__c	);
            }
        }
        //FNPVVEP-159 - FIM 



        Map<String, List<FranquiaGarantia__c>> mapProdutoFranquia = new Map<String, List<FranquiaGarantia__c>>();
        for(FranquiaGarantia__c franquiaGarantiaTemp : franquiaGarantiasTemp){
            if(!mapProdutoFranquia.containsKey(franquiaGarantiaTemp.GarantiaProduto__c)){
                mapProdutoFranquia.put(franquiaGarantiaTemp.GarantiaProduto__c, new List<FranquiaGarantia__c>());
            }
            mapProdutoFranquia.get(franquiaGarantiaTemp.GarantiaProduto__c).add(franquiaGarantiaTemp);
        }

        System.debug('mapProdutoFranquia: ' + JSON.serialize(mapProdutoFranquia));

        //PLV-4481 DIT - VINICIUS - FIM

        //II-149 - INICIO        
        String codFranq = getCodigoFranq(contract.Id);
        //II-149 - FIM

        contratante.grupos = new List<EndossoTO.GrupoTO>();
        for( GrupoContrato__c grupoContrato : lstGrupoContrato ){
            
            EndossoTO.GrupoTO grupo = new EndossoTO.GrupoTO();
            //grupo.tarifa = '';);//PLV-4574
            grupo.tipoCalculo = grupoContrato.TipoCalculo__c;
            grupo.numero = Integer.valueOf(grupoContrato.Numero__c);//PLV-4574
            grupo.nome = grupoContrato.Name;
            grupo.qtdeVidas = Integer.valueOf(grupoContrato.QuantidadeVidas__c);//PLV-4574
            grupo.segurados = new List<EndossoTO.SeguradoTO>();
            EndossoTO.SeguradoTO segurado = new EndossoTO.SeguradoTO();
            segurado.numero = 1;
            segurado.pessoa = new EndossoTO.PessoaTO();
            segurado.pessoa.nome = ePessoa.nome;
            segurado.pessoa.nomeSocial = ePessoa.nomeSocial; // LECVPV-188 INICIO/FIM
            segurado.pessoa.dadosPessoaFisica = new EndossoTO.DadosPessoaFisicaTO();
            segurado.pessoa.dadosPessoaFisica.dataNascimento = ePessoa.dataNascimento;
            segurado.pessoa.dadosPessoaFisica.sexo = ePessoa.sexo;
            segurado.pessoa.dadosPessoaFisica.fumante = ePessoa.fumante;
            segurado.pessoa.dadosPessoaFisica.profissao = ePessoa.profissao;
            //PLV - 4655 INICIO
            //PLV-5174 INICIO
            //RVI-175-FIX01 - INICIO
            //PLV-5789 INICIO
            /*try{
                //PLV 4518 Fix2 Inicio
                //GrupoProfissoes__c g = [SELECT Id, GrupoRisco__r.Name FROM GrupoProfissoes__c WHERE Profissao__r.IdExterno__c =: ePessoa.profissao Limit 1];
                //segurado.pessoa.dadosPessoaFisica.grupoProfissao = g.GrupoRisco__r.Name;
                //PLV 4518 Fix2 Fim
                SeguradoContrato__c g = [SELECT Id, GrupoRisco__c FROM SeguradoContrato__c WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: contract.Id LIMIT 1]; 
                System.debug('segurado.pessoa.dadosPessoaFisica.grupoProfissao' + g);
                segurado.pessoa.dadosPessoaFisica.grupoProfissao = g.GrupoRisco__c;
            }catch(Exception e ){
                System.debug('segurado.pessoa.dadosPessoaFisica.grupoProfissao');
                segurado.pessoa.dadosPessoaFisica.grupoProfissao = '';
            }*/ 

            //RVI-175-FIX01 - FIM
            ////PLV-5174 FIM

            SeguradoContrato__c g = [SELECT Id, GrupoRisco__c FROM SeguradoContrato__c WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c =: contract.Id LIMIT 1]; 
            System.debug('segurado.pessoa.dadosPessoaFisica.grupoProfissao' + g);

            segurado.pessoa.dadosPessoaFisica.grupoProfissao = g.GrupoRisco__c != null ? g.GrupoRisco__c : '';
            //PLV-5789 FIM
            
            
            segurado.pessoa.dadosPessoaFisica.regimeTrabalho = ePessoa.regimeTrabalho;
            //PLV-5150 - FIX01 - INICIO
            //segurado.pessoa.dadosPessoaFisica.CicloVacinal = ePessoa.cicloVacinal; //PLV-5150
            request.orcamento.cicloVacinal = ePessoa.cicloVacinal == null ? 0 : Integer.valueOf( ePessoa.cicloVacinal ); //PLV-5150 - INICIO/FIM
            //PLV-5150 - FIX01 - FIM
            segurado.pessoa.dadosPessoaFisica.renda = ePessoa.rendaMensal; //PLV-5134 INICIO/FIM
            
            segurado.pessoa.rendaMensal = ePessoa.rendaMensal; //PLV-4655 fix 1 - INICIO
            segurado.pessoa.tipo = 'FIS';
            
            segurado.coberturas = new List<EndossoTO.CoberturaTO>();
            System.debug('ePessoa.coberturas >> ' + ePessoa.coberturas);
            for( EntradaCobertura eCobertura : ePessoa.coberturas ){
                EndossoTO.CoberturaTO cobertura = new EndossoTO.CoberturaTO();
                cobertura.sigla = eCobertura.sigla;
                cobertura.valor = eCobertura.valor;
                //PLV-5134 - FIX02 - INICIO
                if(eCobertura.sigla <> 'DIT') {
                    //II-74 INICIO
                    System.debug('qntLimite >> ' + qntLimite);
                    if(eCobertura.sigla == 'DIA' && qntLimite != 0){
                        System.debug('if limite diferente >> ');
                        cobertura.quantidade = qntLimite;
                    }else{
                        cobertura.quantidade = mapGarantiaContrato.containskey(eCobertura.sigla) && mapGarantiaContrato.get(eCobertura.sigla).Limite_de_uso__c!= null ? mapGarantiaContrato.get(eCobertura.sigla).Limite_de_uso__c:0; //PLV-4889 - INICIO/FIM
                    }
                    //cobertura.quantidade = mapGarantiaContrato.containskey(eCobertura.sigla) && mapGarantiaContrato.get(eCobertura.sigla).Limite_de_uso__c!= null ? mapGarantiaContrato.get(eCobertura.sigla).Limite_de_uso__c:0; //PLV-4889 - INICIO/FIM
                    //II-74 FIM
                }
                else {
                    cobertura.quantidade = 0;
                }
                //PLV-5134 - FIX02 - FIM
                
                //PLV-4481 DIT - VINICIUS - INICIO
                System.debug('Map++++' + this.garantiasProduct.get(eCobertura.sigla));
                System.debug('SIGLA+++ ' + eCobertura.sigla);
                System.debug('Mapreturn+++ ' + garantiasProduct);
                GarantiaProduto__c garantiaProd = this.garantiasProduct.get(eCobertura.sigla);
                
                System.debug('garantiaProd' + garantiaProd);

                // List<FranquiaGarantia__c> franquiasTemp = new List<FranquiaGarantia__c>();
                // FranquiaGarantia__c franquiaPadrao;
                // System.debug('mapProdutoFranquia Danilo: ' + mapProdutoFranquia);
                // if(garantiaProd != null && mapProdutoFranquia.containsKey(garantiaProd.id)) { //POR062-67 - INICIO/FIM  II-35 - INICIO
                //     franquiasTemp = (mapProdutoFranquia.get(garantiaProd.id));
                // }
                //II-35 - FIM                
                //II-149 - INICIO
                /*for(FranquiaGarantia__c franqTemp : franquiasTemp){
                    if(franqTemp.Franquia_Padrao__c){
                    franquiaPadrao = franqTemp;
                    }
                }*/
                // FNPVVEP-91 - INICIO

               //FNPVVEP-159 - INICIO 
                cobertura.franquia = '';//FNPVVEP-159_FIX01 - INICIO/FIM 
                if(!codigoFranquiaIndexedBySigla.values().isEmpty()){
                    for(String franquiasGarantia : codigoFranquiaIndexedBySigla.values()){
                        //FNPVVEP-159 FIX02 - INICIO 
                        // if(codigoFranquiaIndexedBySigla.containsKey(cobertura.sigla)){
                        //     cobertura.franquia = codigoFranquiaIndexedBySigla.get(cobertura.sigla);
                        // }else{
                        //     cobertura.franquia = '';
                        // }
                        cobertura.franquia = (codigoFranquiaIndexedBySigla.containsKey(cobertura.sigla) && codigoFranquiaIndexedBySigla.get(cobertura.sigla) != null) 
                        ? codigoFranquiaIndexedBySigla.get(cobertura.sigla) 
                        : '';
                        //FNPVVEP-159 FIX02 - FIM 
                    }
                }
                //FNPVVEP-159 - FIM 



                // if (franquiasTemp != null && !franquiasTemp.isEmpty()) {
                //     System.debug('franquia >>> ' + franquiasTemp);
                //     cobertura.franquia = franquiasTemp[0].Franquia__r.CodigoFranquia__c; 
                // } else {
                //     cobertura.franquia = ''; 
                // }
                // FNPVVEP-91 - FIM
                //II-149 - FIM
                //PLV-4481 DIT - VINICIUS - FIM
                System.debug('codigoFranquiaIndexedBySigla Rogerio>> ' + codigoFranquiaIndexedBySigla);
                System.debug('cobertura.franquia Rogerio>> ' + cobertura.franquia);
                System.debug('cobertura.quantidade >> ' + cobertura.quantidade);
                segurado.coberturas.add( cobertura );
                system.debug('segurado.coberturas >> ' + segurado.coberturas);
            }
            System.debug('>segurado> ' + grupo.segurados);
            System.debug('>grupo> ' + grupo.segurados);
            grupo.segurados.add(segurado);
            System.debug('>grupo.segurados> ' + grupo.segurados);
            contratante.grupos.add(grupo);
            System.debug('>contratante.grupos ' + contratante.grupos);
        }
        
        request.orcamento.contratantes.add(contratante);
        System.debug('>request.orcamento.contratantes> ' + request.orcamento.contratantes);
        //payload = JSON.serialize(request);
        payload = JSON.serialize(request, true);
        
        System.debug('>PAYLOAD> ' + payload);
        System.debug('>CONTRATO> ' + contract);
        
        //MGRC-1489-INICIO
        if(!Test.isRunningTest()){ //-- FNPVVEP-91 - INICIO/FIM
            pagOfertas(payload);
        }
        //MGRC-1489-FIM

        System.debug(this.ofertaPadrao);
        //PLV - 4655 FIM
        update contract; //INICIO - PLV-4686 - Guilherme Brito        
        //PLV-5147 - INICIO
        try {
            //System.debug('Tipos endossos '+ QuoteBO.getInstance().checkTipoEndosso((EmissaoTO.PayloadTO) JSON.deserialize(payload, EmissaoTO.PayloadTO.class)));
        } catch (Exception e) {
            System.debug('deu erro > '+ e);
        } 
        //PLV-5147 - FIM
    }
    
    public void atualizarVigencias() {
        
    }
    
    //Refencia Ofertas -- Não está testavel linha 1175
    public void pagOfertas(String payload) {
        System.debug('payload: '+ payload);
        //entradaCalculo Recebe parametros de Entrada do Calculo
        //calculoOfertas tras o Retorno do Calculo.
        //ofertaPadrao recebe o objeto de Retorno do Calculo
        String retorno2;
        retorno2 = calculoOfertas(payload);
        if(retorno2 == 'Erro na requisição'){
            this.ofertaPadrao = '{'+
                +'  "message":"Erro no serviço. Entre em contato com o administrador."'+
                +'}';
            System.debug('Dentro do IF - retorno2');
            
        }
        else{
            this.ofertaPadrao = retorno2;
            System.debug('Dentro do ELSE - retorno2');
        }  	
        System.debug('Retorno Opção de Ofertas: '+ ofertaPadrao);
    }
    
    //MGRC-1489-INICIO
    //Busca o calculo do Serviço da SENSEDIA SERVICES (Endosso VIDAON, VDSJ e APTMLK)
    public static String calculoOfertas(String calculosContrats) {
        
        String Response;

        Map<String, Object> calculosMap = (Map<String, Object>) JSON.deserializeUntyped(calculosContrats);        
        String codigoProdutoVida;

        try{
            if (calculosMap.containsKey('orcamento') && calculosMap.get('orcamento') != null) {
                Map<String, Object> orcamentoMap = (Map<String, Object>) calculosMap.get('orcamento');
                if (orcamentoMap.containsKey('codigoProdutoVida') && orcamentoMap.get('codigoProdutoVida') != null) {
                    codigoProdutoVida = (String) orcamentoMap.get('codigoProdutoVida');
                    System.debug('codigoProdutoVida MGRC1516 ' + codigoProdutoVida);     
                    
                    switch on codigoProdutoVida {
                        //MGRC-1518-INICIO
                        when 'VIDA_ON' {
                            response = SensediaServices.getInstance().montagemServicoSensedia(
                                SensediaServices.VERB.POST, 
                                SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                SensediaServices.OFERTAS_CONTRATACAO_ENDOSSO_VIDA_ON, 
                                calculosContrats
                            );
                        }
                        //MGRC-1518-FIM
                        //MGRC-1516-INICIO
                        when 'VI-PESSOAS' {
                            response = SensediaServices.getInstance().montagemServicoSensedia(
                                SensediaServices.VERB.POST, 
                                SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                SensediaServices.OFERTAS_CONTRATACAO_ENDOSSO_VDSJ, 
                                calculosContrats
                            );
                        }
                        //MGRC-1516-FIM
                        //MGRC-1517-INICIO
                        when 'APTLMKT' {
                            response = SensediaServices.getInstance().montagemServicoSensedia(
                                SensediaServices.VERB.POST, 
                                SensediaServices.DOMAIN.AWS_EXTERNO_EMISSAO, 
                                SensediaServices.OFERTAS_CONTRATACAO_ENDOSSO_APTLMK, 
                                calculosContrats
                            );
                        }
                        //MGRC-1517-FIM
                    }          
                }
            }
            // Response = civServ.criacaoCalculo(calculosContrats);   //MGRC-1657 - INICIO/FIM

            if(!Test.isRunningTest()){
                system.debug('Response Calculo Padrão ==>' + Response);
            }
            
            String mensagem = '';
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(Response);
            
            System.debug('result '+ result);
            if(result.get('recusas') != null){
                System.debug('tem recusa');
                RetornoTO retorno = (RetornoTO) JSON.deserialize(Response, RetornoTO.class);//PLV-4686 - INICIO/FIM - PEDRO AUGUSTO
                System.debug('retorno '+ retorno);
                for(RecusaTO recusa: retorno.recusas){
                    mensagem += recusa.mensagens.cliente + ',';
                    System.debug('MENSAGEM '+ mensagem);
                }
            }
            if(mensagem != ''){
                String mensagemRetorno = '{ '+
                    +' "message":"' +mensagem+''+
                    +'"}' ;
                return mensagemRetorno;
            }
        }
        catch(Exception ex){
            System.debug('###### ERROR: (' + ex.getLineNumber() + '): ' + ex.getMessage());
            throw new ServiceException('ERRO de serviço: ' + ex.getMessage() + ' Linha: ' + ex.getLineNumber());
        }	
        
        return Response;
    }
    //MGRC-1489-FIM

    private class ExceptionHub {
        private CalloutException callExpt = new CalloutException();
        
        public void generic(String text) {
            this.callExpt.setMessage(text);
            throw callExpt;
        }
        
        public void missingContractId() {
            this.callExpt.setMessage('Contrato não informado');
            throw callExpt;
        }
        
        public void contractNotissued() {
            this.callExpt.setMessage('Contrato não Emitido');
            throw callExpt;
        }
        
        public void invalidSegment() {
            this.callExpt.setMessage(
                'Segmento de produto não permite endosso de contrato'
            );
            throw callExpt;
        }
    }
    
    public class ServiceException extends Exception { }	
    
    //PLV-4484 - FIM
    
    // PLV-4481 INICIO
    public Pagereference redirecionarEndosso(){
        string url = '/'+contract.Id;
        PageReference retURL = new PageReference(url);
        retURL.setRedirect(true);
        
        return retURL;
    }
    // PLV-4481 FIM

    //II-149 - INICIO
    public static String getCodigoFranq(Id ctrId){

        String codFranq = '';

        List<GarantiaContrato__c> lctrs = [SELECT Id, FranquiaGarantia__r.Franquia__r.CodigoFranquia__c FROM GarantiaContrato__c WHERE Contrato__c = :ctrId];

        for(GarantiaContrato__c gc : lctrs){
            if(gc.FranquiaGarantia__r.Franquia__r.CodigoFranquia__c != null){
                codFranq = gc.FranquiaGarantia__r.Franquia__r.CodigoFranquia__c;
            }
        }

        return codFranq;
    }
    //II-149 - FIM
}