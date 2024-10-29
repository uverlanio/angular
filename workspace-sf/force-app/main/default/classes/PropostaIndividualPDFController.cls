/*INICIO | PLV-4331-Vida 
*  @author Elsa Garnica - Globant, Gabriel Loch - Globant
*  @Descrição: Pagina de Proposta Individual
*/
public without sharing class PropostaIndividualPDFController { //PLV-5172 - INICIO/FIM
    public PublicQuote proposta {get;set;}
    public publicAccount segurado {get;set;}
    public Corretor corretor {get;set;}
    public List<Corretor> corretores {get;set;} //II-157 - INICIO/FIM
    public List<Beneficiario> beneficiarios {get;set;}
    public List<Garantia> garantias {get;set;}
    public FormaPagamento formapagamento {get;set;} //PLV-4425 - INICIO/FIM

    public Boolean hasDoencaGrave {get;set;}
    public Boolean hasdDit {get;set;}
    public Boolean hasSocialName {get;set;} //LECVPV 189 - INICIO/FIM
    //PLV-4425 - INICIO
    public Boolean hasMorteNaturalAcidental {get;set;}
    public Boolean hasMorteNatural {get;set;}
    public Boolean hasMorteAcidental {get;set;}
    public Boolean hasIPA {get;set;}
    public Boolean has792 {get;set;}
    public Boolean hasTerceiro {get;set;}
    public Boolean hasBoleto {get;set;}
    public Boolean hasSubscricao {get;set;}
    public Boolean hasQuestSubs {get;set;} //PLV-4425 - INICIO/FIM
    public Boolean hasAssinatura {get;set;} //PLV-5090 - INICIO/FIM
    public Boolean hasCorretorAssina {get;set;} //PLV-5493 INICIO/FIM
    public Boolean isVidaON {get; set;} //VIDA-192 - INICIO/FIM
    //AV-86 - INICIO
    public Boolean exibirObservacoesCapitaisSegurados {get;set;} 
    public Boolean exibirFormaDePagamento {get;set;} 
    public Boolean exibirObservacaoVidaOn {get;set;}
    //AV-86 - FIM
    //AV-574 - INICIO
    public Boolean ajustarPDFVidaOn {get;set;}   
    public Boolean exibeDadosVidaON {get;set;}
    public Boolean removeFieldsVidaOn {get;set;} //VIDA-90 - INICIO/FIM
    public Boolean exibeTituloCorretor {get;set;}
    //AV-574 - FIM
    public String somaTotal {get;set;}
    public String somaIof {get;set;}
    public String somaLiquido {get;set;}
    public String mensagem {get;set;} //PLV-4425 - INICIO/FIM
    //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM   
    public String franqDit {get;set;} //PLV-4425 - INICIO/FIM    

    public DeclaracaoSaude__c questionarioRisco {get;set;}
    public List<CarenciaGarantia__c> carencias {get;set;} //PLV-4425 - INICIO/FIM
    //PLV-4425 - FIM

    //PLV-5231 - INICIO
    public Boolean hasRNE {get;set;}
    public Boolean hasClasse {get;set;}
    public Boolean hasPaisEstrangeiro {get;set;}
    //public Boolean hasGrauParentescoOutros {get;set;}
    public Boolean hasRG {get;set;} //PLV-5231 - FIX01 - INICIO/FIM
    //PLV-5231 - FIM

    //TKCL-246 INICIO FIX01
    public Boolean isCodigoPrecificacaoAPTLMKT                                      {get; set;}
    //TKCL-246 FIM FIX01   

    public Boolean isCodigoPrecificacaoVDSJ {get; set;} //II-178 INICIO/FIM
    
    public  PropostaIndividualPDFController(){
        //II-177 INICIO
        String numProposta  = ApexPages.CurrentPage().getParameters().get('numProposta');
        String idproposta  = ApexPages.CurrentPage().getParameters().get('idProposta');
        Quote qto = this.getQuote(numProposta, idProposta);
        //II-177 FIM
        if(qto == null) this.throwException('Número de proposta inválido.');
        //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM

        this.hasDoencaGrave = false;
        this.hasdDit = false;
        //PLV-4425 - INICIO
        this.hasMorteNaturalAcidental = false;
        this.hasMorteNatural = false;
        this.hasMorteAcidental = false;
        this.removeFieldsVidaOn = true; //VIDA-90 INICIO/FIM
        this.hasIPA = false;
        this.has792 = false;
        this.hasTerceiro = false;
        this.hasBoleto = false;
        this.hasSubscricao = false;
        this.hasQuestSubs= false; //PLV-4425 - INICIO/FIM
        this.franqDit = ''; //PLV-4425 - INICIO/FIM
        this.hasAssinatura = false; //PLV-5090 - INICIO/FIM
        this.hasCorretorAssina = false; //PLV-5493 INICIO/FIM
        Decimal incrementSomaTotal = 0;
        Decimal incrementSomaIof = 0;
        Decimal incrementSomaLiquido = 0;
        //PLV-4425 - FIM
        

        this.proposta = new PublicQuote(qto);
        this.segurado = new publicAccount(qto);
        
        this.beneficiarios = new List<Beneficiario>();
        //PLV-4425 - INICIO
        if (this.getBeneficiario(qto.id)[0].TipoBeneficiario__c.contains('Herdeiros legais, conforme artigo 792 do código civil.')) { //PLV-4901 - INICIO/FIM
            this.has792 = true;
        }else {
            for (BeneficiarioSeguradoProposta__c ben : this.getBeneficiario(qto.id)) {
                this.beneficiarios.add(new Beneficiario(ben));
            }
        }
        //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM
        if(qto.ContratantesProposta__r[0].ResponsavelPagamento__r.Cpf__c != qto.ContratantesProposta__r[0].Conta__r.Cpf__c) 
        this.hasTerceiro = true;
        if(!(qto.ContratantesProposta__r[0].FormaPagamento__r.Codigo__c == '11' || qto.ContratantesProposta__r[0].FormaPagamento__r.Codigo__c == '41')) 
        this.hasBoleto = true;
        this.formapagamento = new FormaPagamento(qto.ContratantesProposta__r);

        this.questionarioRisco= this.getQuestionario(qto.id);
        
        if(!qto.CriticasProposta__r.isEmpty()) {
            this.hasSubscricao = true;
            this.mensagem = qto.CriticasProposta__r[0].MensagemCliente__c;
        }
        System.debug('hasSubscricao henrique: ' + hasSubscricao);
        //System.debug('this.questionarioRisco. size: ' + this.questionarioRisco.DeclaracaoSaude__r.size());
        System.debug('this.questionarioRisco henrique  : ' + this.questionarioRisco);
        this.hasQuestSubs = this.questionarioRisco != null && this.questionarioRisco.DeclaracaoSaude__r.size() > 0 && !this.hasSubscricao;
        //PLV-4425 - FIM
        System.debug('hasQuestSubs henrique: ' + hasQuestSubs);


        //PLV-5090 - INICIO
        if(qto.ContratantesProposta__r[0].FormaPagamento__r.Codigo__c == '52') this.hasAssinatura = true;
        //PLV-5090 - FIM

        //II-116 - INICIO
        Boolean isAPTLMKT = proposta.productCodePrec.toUpperCase().equals('APTLMKT'); //II-178 FIX01 INICIO/FIM
        this.isCodigoPrecificacaoAPTLMKT = isAPTLMKT;
        //II-116 - FIM

        this.garantias = new List<Garantia>();
        List<Id> garantiaProdutoId = new List<Id>(); //PLV-4425 - INICIO/FIM
        for (GarantiaProposta__c garantia : qto.GarantiasProposta__r){
            this.checkGarantia(garantia);   
            this.garantias.add(new Garantia(garantia));
            //PLV-4425 - INICIO
            incrementSomaTotal   += garantia.PremioTotal__c;
            incrementSomaLiquido += garantia.PremioComercial__c;
            incrementSomaIof     += (garantia.PremioTotal__c - garantia.PremioComercial__c);
            garantiaProdutoId.add(garantia.GarantiaProduto__c);
        }
        this.carencias = this.hasdDit || this.hasDoencaGrave ? this.getCarencias(garantiaProdutoId, this.hasdDit, this.hasDoencaGrave) : new List<CarenciaGarantia__c>();

        //AV-86 - INICIO
        Boolean isViagemVidaON = proposta.productCode.toUpperCase().equals('VIAGEM-PRATA');
        this.exibirObservacaoVidaOn = false;
        this.exibirObservacoesCapitaisSegurados = !isViagemVidaON;
        this.exibirFormaDePagamento = !isViagemVidaON;
        if(isViagemVidaON) this.exibirObservacaoVidaOn = true;
        //AV-86 - FIM

        //AV-574 - INICIO
        this.isVidaON = proposta.productCode.toUpperCase().equals('VIDA_ON'); //VIDA-192 - INICIO/FIM
        this.ajustarPDFVidaOn = !isVidaON;
        this.exibeDadosVidaON = false;
        this.exibeTituloCorretor = true;

        if(this.isVidaON){ //VIDA-192 - INICIO/FIM
            this.removeFieldsVidaOn = false; //VIDA-90 - INICIO/FIM
            this.exibeDadosVidaON = true;
            this.exibeTituloCorretor = false;
        }
        //AV-574 - FIM
        //TKCL-246 INICIO FIX01
        isAPTLMKT = proposta.productCodePrec.toUpperCase().equals('APTLMKT'); //II-116 - INICIO/FIM //II-178 FIX01 INICIO/FIM
        this.isCodigoPrecificacaoAPTLMKT = !isAPTLMKT;
        
        //TKCL-246 FIM FIX01

        //II-178 INICIO
        Boolean isVDSJ;
        isVDSJ = proposta.productCodePrec.toUpperCase().equals('VI-PESSOAS');
        this.isCodigoPrecificacaoVDSJ = !isVDSJ;
        //II-178 FIM 


        this.somaTotal = this.convertBRValue(incrementSomaTotal);
        this.somaLiquido = this.convertBRValue(incrementSomaLiquido);
        this.somaIof = this.convertBRValue(incrementSomaIof);
        //PLV-4425 - FIM
        System.debug('qto: ' + qto);
        this.corretor = new Corretor(this.getCorretorLider(qto.id));
        this.corretores = new Corretor().corretores(this.getCorretores(qto.id)); //II-157 - INICIO/FIM
        System.debug('corretor: ' + corretor);
        System.debug('corretor.Name: ' + corretor.Name);
        System.debug('corretor.susepPorto: ' + corretor.susepPorto);
        this.hasCorretorAssina = this.isVidaON ? false : this.getCorretorLider(qto.id).CorretorResponde__c; //VIDA-192 INICIO/FIM

        //PLV-5231 - INICIO
        this.hasRNE = false;
        this.hasClasse = false;
        this.hasPaisEstrangeiro = false;
        //this.hasGrauParentescoOutros = false;
        this.hasRG = false; //PLV-5231 - FIX01 - INICIO/FIM

        Boolean isRNE = segurado.tipoDocIdentificacao.toLowerCase().equals('rne');
        Boolean isClasse = segurado.tipoDocIdentificacao.toLowerCase().equals('classe');
        Boolean isEstrangeiro = segurado.nationality.toUpperCase().equals('ESTRANGEIRA');
        System.debug('Alexandre tipoDoc>>> ' + segurado.tipoDocIdentificacao);
        //Boolean isGrauParentescoOutros = beneficiarios[0].relationship.toUpperCase().equals('OUTROS');
        Boolean isRG = segurado.tipoDocIdentificacao.toLowerCase().equals('rg'); //PLV-5231 - FIX01 - INICIO/FIM

        if(isRNE) this.hasRNE = true;
        if(isClasse) this.hasClasse = true;
        if(isEstrangeiro) this.hasPaisEstrangeiro = true;
        //if(isGrauParentescoOutros) this.hasGrauParentescoOutros = true;
        System.debug('Alexandre RNE>>>> ' + hasRNE);
        if(isRG) this.hasRG = true; //PLV-5231 - FIX01 - INICIO/FIM
        //PLV-5231 - FIM
       //PLV-5158 INICIO
       if ((segurado.docIdentificacao == '-')||(segurado.docIdentificacao == null)) { 
          this.hasRG = false; 
       }
        //PLV-5158 FIM

        this.hasSocialName = String.isEmpty(segurado.socialName) ? false : true; //LECVPV 189 - INICIO/FIM          
        
    }

    private void checkGarantia(GarantiaProposta__c garantia){
        //PLV-4425 - INICIO
        String garantiaSigla = garantia.Garantia__r.Sigla__c;

        if(garantiaSigla == null) return;
        if(!this.hasDoencaGrave){
            if(garantiaSigla.contains('DG') || garantiaSigla.contains('CAN')){
                this.hasDoencaGrave = true;
            }
        }

        if(!this.hasdDit){
            if(garantiaSigla.contains('DIT') ||  garantiaSigla.contains('DITA')){ //TKCL-246 INICIO/FIM FIX01
                this.hasdDit = true;
                this.franqDit = garantia.FranquiaGarantia__r.Franquia__r.Descricao__c; //PLV-4425 - INICIO/FIM
            }
        }

        if(!this.hasMorteNatural){
            if(garantiaSigla.contains('BAS')){
                this.hasMorteNatural = true;
            }
        }

        if(!this.hasMorteAcidental){
            if(garantiaSigla.contains('MAP')){
                this.hasMorteAcidental = true;
            }
        }

        if(!this.hasMorteNaturalAcidental && !this.isCodigoPrecificacaoAPTLMKT){ //II-116 - INICIO / FIM
            if(this.hasMorteNatural && this.hasMorteAcidental){
                this.hasMorteNaturalAcidental = true;
            }
        }

        if(!this.hasIPA){
            if(garantiaSigla.contains('IPA')){
                this.hasIPA = true;
            }
        }
        //PLV-4425 - FIM

        //PLV-5139 - INICIO
        if (garantiaSigla == 'DIH' || garantiaSigla == 'DIA'){ //TKCL-246 INICIO/FIM FIX01
            Integer dias = (this.segurado.daysDIH > 0 ? this.segurado.daysDIH : null);       
            garantia.Garantia__r.Name += ( 
                        dias == null 
                            ? ''
                            : ' (' + dias.format() + ' dia' + (dias == 1 ? '': 's') +  ')' 
                        );
        }
        //PLV-5139 - FIM
    }
    //PLV-4425 - INICIO
    private List<CarenciaGarantia__c> getCarencias (List<Id> garantiaProdutoId, Boolean dit, Boolean dg){
        List<CarenciaGarantia__c> carencia = new List<CarenciaGarantia__c>();
        List<String> sigla = new List<String>();
        //TKCL-246 INICIO FIX01
        if(dit){
            sigla.add('DIT');
            sigla.add('DITA'); 
        } 
        //TKCL-246 FIM FIX01
        if(dg) {
            Sigla.add('DG10');
            Sigla.add('DG17');
            Sigla.add('CAN');
        }
        try {
            carencia = [
                    SELECT
                        id,
                        Carencia__r.Descricao__c,
                        GarantiaProduto__r.Garantia__r.Sigla__c
                    FROM CarenciaGarantia__c 
                    WHERE GarantiaProduto__c =: garantiaProdutoId
                    AND GarantiaProduto__r.Garantia__r.Sigla__c IN :sigla
               ];  
        } catch (Exception e) {
            System.debug(e);
        } 
        return carencia;
    }
    //PLV-4425 - FIM
    private void throwException(String message){
        CalloutException e = new CalloutException();
        e.setMessage(message);
        throw e;
    }

    private Quote getQuote (String numProposta, String idProposta){ //II-177 INICIO/FIM
        Quote qte = null;
        String[] acao = new String[]{'auto', 'tele'}; //PLV-4425 - INICIO/FIM
        try {
            qte = [
                    SELECT
                        id,
                        Name,
                        NumeroProposta__c,
                        VigenciaInicial__c,
                        Vigenciafinal__c,
                        Produto__r.name,
                        Produto__r.ProductCode, //AV-86 - INICIO/FIM
                        Produto__r.CodigoPrecificaProduto__c, //II-178 - INICIO/FIM
                        Produto__r.NumeroSusep__c,
                        Produto__r.Segmento__c,
                        Produto__r.RegistroSusep__c, // RVI-41-INICIO/FIM
                        Produto__r.Empresa__r.Name, // RVI-41-INICIO/FIM
                        Produto__r.Empresa__r.Cnpj__c, // RVI-41-INICIO/FIM 

                        Account.id,
                        Account.Name,
                        Account.NomeSocial__c, //LECVPV 189 - INICIO/FIM
                        Account.PersonBirthdate,
                        Account.Cpf__c,
                        Account.Cnpj__c,
                        Account.Pep__c,
                        Account.Sexo__c,
                        Account.Fumante__c,
                        Account.Nacionalidade__c,
                        Account.PaisResidencia__c,
                        Account.BillingStreet,
                        Account.BillingPostalCode,
                        Account.BillingCity,
                        Account.BillingState,
                        Account.PersonHomePhone,
                        Account.PersonMobilePhone,
                        Account.Phone,
                        Account.PersonEmail,
                        
                        Account.NumeroPassaporte__c,
                        Account.RegimeTrabalho__c,
                        Account.Profissao__r.name,
                        Account.Profissao__r.NomeFantasia__c,//PLV-4855 - INICIO/FIM
                        Account.Renda__c,
                        Account.RamoAtividade__c,
                        Account.RamoAtividade__r.Name,
                        Account.Especialidade__c,
                        Account.EstadoCivil__c,
                        Account.NumberOfEmployees,
                        //PLV-5231 - INICIO
                        Account.TipoDocidentificacao__c,
                        Account.DocIndentificacao__c,
                        Account.PaisDeOrigem__c,
                        //PLV-5231 - FIM

                        //PLV-4425 - INICIO
                        (
                            SELECT 
                                Id,
                                Garantia__r.Sigla__c,
                                Garantia__r.Name,
                                FranquiaGarantia__r.Franquia__r.Descricao__c,
                                Capital__c,
                                PremioComercial__c,
                                PremioTotal__c,
                                PremioPuro__c,
                                GarantiaProduto__c
                            FROM GarantiasProposta__r
                        ),

                        (
                            SELECT 
                                Id,
                                MensagemCliente__c
                            FROM CriticasProposta__r
                            WHERE Acao__c IN :acao
                            LIMIT 1
                        ),

                        (
                            SELECT 
                                Id,
                                FormaPagamento__r.Name,
                                FormaPagamento__r.Codigo__c,
                                //II-125 INICIO
                                InformacaoBancaria__r.Agencia__c, 
                                InformacaoBancaria__r.Digito__c, 
                                InformacaoBancaria__r.NumeroConta__c, 
                                InformacaoBancaria__r.BancoNew__r.Name,
                                //II-125 FIM
                                QuantidadeParcelas__c,
                                Conta__r.Cpf__c,
                                ResponsavelPagamento__r.Name,
                                ResponsavelPagamento__r.Cpf__c,
                                ResponsavelPagamento__r.Cnpj__c
                            FROM ContratantesProposta__r
                            LIMIT 1
                        )
                        //PLV-4425 - FIM

                    FROM Quote 
                    WHERE name = :numProposta OR Id = :idProposta //II-177 INICIO/FIM
                    LIMIT 1
               ];  
        } catch (Exception e) {
            System.debug(e);
        } 
        return qte;
    }

    private FavorecidoRemuneracaoProposta__c getCorretorLider(String quoteId){
        FavorecidoRemuneracaoProposta__c favRemContrato = null;
        try {
            favRemContrato = [
                    SELECT
                        id,
                        CorretorLider__c,
                        Conta__r.name,                  //nome
                        Conta__r.Phone,                 //tel
                        Conta__r.Email__c,              //email
                        Susep__c,                       //susep porto
                        SusepOficialCorretor__c,         //susep oficial
                        CorretorResponde__c             //PLV-5493 INICIO/FIM
                    FROM FavorecidoRemuneracaoProposta__c 
                    WHERE RemuneracaoProposta__r.Proposta__c =: quoteId
                    ORDER BY SusepOficialCorretor__c DESC, CreatedDate DESC
                    LIMIT 1
               ];  
        } catch (Exception e) {
            System.debug(e);
        } 
        return favRemContrato;
    }

    //II-157 - INICIO
    private List<FavorecidoRemuneracaoProposta__c> getCorretores(String quoteId){
        
        List<FavorecidoRemuneracaoProposta__c> favsRemContrato = new List<FavorecidoRemuneracaoProposta__c>();
        List<FavorecidoRemuneracaoProposta__c> lTemp = [
                    SELECT
                        id,
                        CorretorLider__c,
                        Conta__r.name,                  
                        Conta__r.Phone,                 
                        Conta__r.Email__c,              
                        Susep__c,                       
                        SusepOficialCorretor__c,         
                        CorretorResponde__c             
                    FROM 
                        FavorecidoRemuneracaoProposta__c 
                    WHERE 
                        RemuneracaoProposta__r.Proposta__c =: quoteId
                    AND Papel__c = 'Corretor' //FNPVVEP - 69 INICIO/FIM
                    ORDER BY 
                        SusepOficialCorretor__c DESC,
                        CreatedDate DESC
               ];
               
               for(FavorecidoRemuneracaoProposta__c frp : lTemp){
                    if(frp.CorretorLider__c){
                        favsRemContrato.add(frp);
                    }
               }

               for(FavorecidoRemuneracaoProposta__c frp : lTemp){
                if(!frp.CorretorLider__c){
                    favsRemContrato.add(frp);
                }
           }
        
        return favsRemContrato;
    }
    //II-157 - FIM

    //PLV-4425 - INICIO
    private List<BeneficiarioSeguradoProposta__c> getBeneficiario(String quoteId){
        List<BeneficiarioSeguradoProposta__c> Benefics = null;        
        //PLV-5119 - REMOÇÃO DE CODIGO - INICIO/FIM
        try {
            Benefics = [
                    SELECT
                        id,
                        Nome__c,
                        NomeSocial__c,//LECVPV 189 - INICIO/FIM
                        CpfCnpj__c,
                        Data_de_nascimento__c,
                        GrauParentesco__c,
                        Participacao__c,
                        TipoBeneficiario__c,
                        BeneficiarioGrauParentescoOutros__c, //PLV-5231 INICIO/FIM
                        SeguradoProposta__r.Ramo_de_atividade__c
                    FROM BeneficiarioSeguradoProposta__c 
                    WHERE SeguradoProposta__r.GrupoProposta__r.ContratanteProposta__r.Proposta__c =: quoteId
               ];  
        } catch (Exception e) {
            System.debug(e);
        } 
        return Benefics;
    }

    private DeclaracaoSaude__c getQuestionario(String quoteId){
        DeclaracaoSaude__c decSaude = null;
        try {
            decSaude= [
                SELECT 
                (SELECT 
                        Resposta__c,
                        PerguntaQuestionarioRisco__r.Pergunta__r.Pergunta__c 
                FROM DeclaracaoSaude__r)

                FROM DeclaracaoSaude__c
                WHERE Proposta__c =: quoteId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug(e);
        } 
        return decSaude;
    }
    //PLV-4425 - FIM

    private class PublicQuote{

        public String product {get;set;}
        public String productCode  {get;set;} //AV-86 - INICIO/FIM
        public String susepProcess  {get;set;}
        public String propostaNumber {get;set;}
        public String propostaOrigin {get;set;}
        public Date initialTerm {get;set;}
        public Date finalTerm {get;set;}
        //RVI-41-INICIO
        public String registroSusep     {get; set;}
        public String nomeEmpresa       {get; set;}
        public String cnpjEmpresa       {get; set;}
        //RVI-41-FIM
        public String productCodePrec  {get;set;} //II-178 - INICIO/FIM

        public PublicQuote(Quote qto){
            this.product = qto.Produto__r.name;
            this.productCode = qto.Produto__r.ProductCode; //AV-86 - INICIO/FIM
            this.susepProcess = qto.Produto__r.NumeroSusep__c;
            this.propostaNumber = qto.NumeroProposta__c;
            this.propostaOrigin = qto.name;
            this.initialTerm = qto.VigenciaInicial__c;
            this.finalTerm = qto.Vigenciafinal__c;
            //RVI-41-INICIO
            this.registroSusep = qto.Produto__r.RegistroSusep__c;
            this.nomeEmpresa = qto.Produto__r.Empresa__r.Name;
            this.cnpjEmpresa = qto.Produto__r.Empresa__r.Cnpj__c;
            //RVI-41-FIM
            this.productCodePrec = qto.Produto__r.CodigoPrecificaProduto__c; //II-178 - INICIO/FIM
        }
    }

    private class publicAccount{
        public String name {get;set;}
        public String socialName {get;set;} //LECVPV 189 - INICIO/FIM
        public Date birthdate {get;set;}
        public String cpf {get;set;}
        public String cnpj {get;set;}
        public String maritalStatus {get;set;}
        public String gender {get;set;}
        public String isSmoker {get;set;}
        public String nationality {get;set;}
        public String originCountry {get;set;}
        public String livesOnBrazil {get;set;}
        public String passport {get;set;}
        public String expeditionCountry {get;set;} //PLV-5090 - INICIO/FIM       
        public String pep {get;set;}
        public String workRegime {get;set;}
        public String profession {get;set;}
        public String income {get;set;}
        public String specialty {get;set;}
        //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM
        public String numberOfEmployees {get;set;}

        //PLV-5090 - FIX03 - INICIO
        //public Address personalAddres {get;set;}
        //public Address comercialAddres {get;set;} 
        //PLV-5090 - FIX03 - FIM

        public String personalPhone {get;set;}
        public String comercialPhone {get;set;}
        public String cellphone {get;set;}
        public String email {get;set;}  
        
        //PLV-5090 - INICIO
        public Boolean hasComercialAddress  {get;set;}
        public Boolean hasPersonalAddress   {get;set;}
        public String branch                {get;set;}
        //PLV-5090 - FIX03 - INICIO
        public String jobStreet             {get;set;}
        public String jobNumber             {get;set;}
        public String jobComplement         {get;set;}
        public String jobZipCode            {get;set;}
        public String jobState              {get;set;}
        public String jobCity               {get;set;}
        public String resStreet             {get;set;}
        public String resNumber             {get;set;}
        public String resComplement         {get;set;}
        public String resZipCode            {get;set;}
        public String resState              {get;set;}
        public String resCity               {get;set;}        
        //PLV-5090 - FIX03 - FIM
        //PLV-5090 - FIM

        //PLV-5119 - INICIO
        public String vaccineCicle              {get;set;}
        public Date lastVaccinationDate         {get;set;}
        public Boolean hasVaccination           {get;set;}  
        public Boolean hasVaccinationDate       {get;set;}        
        //PLV-5119 - FIM

        public Boolean completeVaccinationCycle {get;set;} //PLV-5145 - INICIO/FIM
        //PLV-5371 - INICIO
        public Boolean boosterShot {get;set;} 
        public Boolean hasVaccinationFalse {get;set;} 
        //PLV-5371 - FIM
		public Integer daysDIH {get;set;} //PLV-5139 - FIX01 - INICIO/FIM

        //PLV-5231 - INICIO
        public String tipoDocIdentificacao      {get;set;}
        public String docIdentificacao          {get;set;}
        public String paisDeOrigem              {get;set;}
        //PLV-5231 - FIM

        public publicAccount(Quote qto){
            //PLV-5090 - INICIO
            Map<String, String> mapDadosSegProposta = new Map<String, String>(); //PLV-4874 - Inicio/Fim
            mapDadosSegProposta = retornarDadosSegProposta(qto.Id); //PLV-4874 - Inicio/Fim
            this.hasComercialAddress = true; 
            this.hasPersonalAddress = true;  
            //PLV-5090 - FIM
            //PLV-5119 - INICIO
            this.hasVaccination = true;
            //this.hasVaccinationDate = true;
            //PLV-5119 - FIM

            this.name = qto.Account.Name;
            this.socialName = qto.Account.NomeSocial__c; //LECVPV 189 - INICIO/FIM
            this.birthdate = qto.Account.PersonBirthdate;
            this.cpf = qto.Account.Cpf__c;
            this.cnpj =mapDadosSegProposta.get('cnpj'); //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
            this.maritalStatus = qto.Account.EstadoCivil__c;
            this.gender = qto.Account.Sexo__c;
            this.isSmoker = qto.Account.Fumante__c;
            this.nationality = qto.Account.Nacionalidade__c != null ? qto.Account.Nacionalidade__c : '-'; //PLV-5090 - FIX03 - INICIO/FIM
            //PLV-4874 - Inicio
            //PLV-5090 - INICIO
            //PLV-5090 - FIX03 - INICIO
            this.originCountry = mapDadosSegProposta.get('pais') != null ? mapDadosSegProposta.get('pais') : '-';
            this.livesOnBrazil = mapDadosSegProposta.get('viveNoBrasil') != null ? mapDadosSegProposta.get('viveNoBrasil') : '-';
            //PLV-5090 - FIX03 - FIM
            //PLV-5090 - FIM
            //PLV-4874 - Fim
            //PLV-5090 - INICIO
            this.passport = qto.Account.NumeroPassaporte__c !=null ? qto.Account.NumeroPassaporte__c : '-';
            this.pep = qto.Account.Pep__c;             
            this.expeditionCountry = '-'; //(Enquanto o campo não é criado)        
            //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM
            this.income = qto.Account.Renda__c !=null ? qto.Account.Renda__c + '' : '- ';
            //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM
            //PLV-5090 - FIM
            this.specialty = qto.Account.Especialidade__c != null ? qto.Account.Especialidade__c : '-'; //PLV-5090 - INICIO/FIM
            //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM
            this.numberOfEmployees = mapDadosSegProposta.get('numeroFuncionarios');

            List<Endereco__c> lstAddress = getAddress(qto.Account.id);
            //PLV-5090 - FIX03 - INICIO
            //this.personalAddres = new Address(this.geAddressByType(lstAddress , 'Residencial'));
            //this.comercialAddres = new Address(this.geAddressByType(lstAddress , 'Comercial'));                                               
            
            this.resStreet = mapDadosSegProposta.get('logradouroResSegProposta');           
            this.resNumber = mapDadosSegProposta.get('numeroResSegProposta');
            this.resComplement = mapDadosSegProposta.get('complementoResSegProposta');
            this.resZipCode = mapDadosSegProposta.get('cepResSegProposta');
            this.resState = mapDadosSegProposta.get('ufResSegProposta');
            this.resCity = mapDadosSegProposta.get('cidadeResSegProposta');
            
            this.resStreet = this.resNumber != '-' ? this.resStreet + ' ' + this.resNumber + ' ' : this.resStreet + ' '; 
            this.resStreet = this.resComplement != '-' ? this.resStreet + ' ' + this.resComplement : this.resStreet;                
            
            this.jobStreet = mapDadosSegProposta.get('logradouroComSegProposta');           
            this.jobNumber = mapDadosSegProposta.get('numeroComSegProposta');
            this.jobComplement = mapDadosSegProposta.get('complementoComSegProposta');
            this.jobZipCode = mapDadosSegProposta.get('cepComSegProposta');
            this.jobState = mapDadosSegProposta.get('ufComSegProposta');
            this.jobCity = mapDadosSegProposta.get('cidadeComSegProposta');            
                         
            this.jobStreet = this.jobNumber != '-' ? this.jobStreet + ' ' + this.jobNumber + ' ' : this.jobStreet + ' '; 
            this.jobStreet = this.jobComplement != '-' ? this.jobStreet + ' ' + this.jobComplement : this.jobStreet;                            
            //PLV-5090 - FIX03 - FIM    

            //PLV-5090 - INICIO    
            //PLV-5090 - FIX02 - INICIO                                                          
            //PLV-5090 - FIX03 - INICIO/FIM
            if (mapDadosSegProposta.get('logradouroResSegProposta').trim() == '-') this.hasPersonalAddress = false;
            if (mapDadosSegProposta.get('logradouroComSegProposta').trim() == '-') this.hasComercialAddress = false;
            //PLV-5090 - FIX03 - FIM
            //PLV-5090 - FIX02 - FIM             
                         
            this.personalPhone = qto.Account.PersonHomePhone !=null ? qto.Account.PersonHomePhone : '-';
            this.comercialPhone = qto.Account.Phone !=null ? qto.Account.Phone : '-';
            this.cellphone = qto.Account.PersonMobilePhone !=null ? qto.Account.PersonMobilePhone : '-';
            this.email = qto.Account.PersonEmail !=null ? qto.Account.PersonEmail : '-';            
            
            this.profession = mapDadosSegProposta.get('profissaoSegProposta');            
            System.debug('profession>>>>>>>> '+ this.profession);
            this.workRegime = mapDadosSegProposta.get('regimeTrabalhoSegProposta');
            //PLV-5090 FIX04 INICIO 
            if(mapDadosSegProposta.get('regimeTrabalhoSegProposta') == 'CLT'){
                this.branch = mapDadosSegProposta.get('empresaTrabalhaSegProposta');
                this.specialty ='-'; //PLV-5090 FIX05 INICIO/FIM 
            }else{
                this.branch = mapDadosSegProposta.get('ramoAtividade') != null ? mapDadosSegProposta.get('ramoAtividade') : '';
            }
             //PLV-5090 FIX04 FIM 
            //PLV-5090 - FIM
            //PLV-5119 - INICIO
            this.vaccineCicle = mapDadosSegProposta.get('cicloVacinal') != null ? mapDadosSegProposta.get('cicloVacinal') : '-';
            //String vaccinationDate = mapDadosSegProposta.get('ultimaVacinaCicloVacinal') != null ? mapDadosSegProposta.get('ultimaVacinaCicloVacinal') : null;                                                
            //this.lastVaccinationDate = vaccinationDate != null ? Date.valueOf(vaccinationDate) : null;            
            
            //PLV-5371 - INICIO

            /*if(this.vaccineCicle == 'Não iniciado') {
                this.hasVaccination = false;
                //this.lastVaccinationDate = null;
            }  */
            
            system.debug('ciclo vacinal: ' + vaccineCicle);
            if(this.vaccineCicle == 'Não Iniciado ou incompleto') {
                this.hasVaccination = false;
            }
            

            this.hasVaccinationFalse = false;
            if(hasVaccination == false){
                this.hasVaccinationFalse = true;
            }

            this.completeVaccinationCycle = false;
            if(hasVaccination == true && this.vaccineCicle == 'Completo'){
                this.completeVaccinationCycle = true;
            }  

            this.boosterShot = false;
            if(hasVaccination == true && this.vaccineCicle == 'Dose de reforço'){
                this.boosterShot = true;
            }

            system.debug('tem vacinação: ' + hasVaccination);

            //PLV-5371 - FIM

            //this.hasVaccinationDate = this.lastVaccinationDate != null ? true : false;  
            //PLV-5119 - FIM

            //PLV-5145 - INICIO
            /*this.completeVaccinationCycle = false;
            if(hasVaccination == true && this.vaccineCicle == 'Completo'){
                this.completeVaccinationCycle = true;
            }  */
            //PLV-5145 - FIM
            //PLV-5231 - INICIO
            this.tipoDocIdentificacao = qto.Account.TipoDocidentificacao__c != null? qto.Account.TipoDocidentificacao__c : '-';
            this.docIdentificacao = qto.Account.DocIndentificacao__c != null? qto.Account.DocIndentificacao__c : '-';
            this.paisDeOrigem = qto.Account.PaisDeOrigem__c != null? qto.Account.PaisDeOrigem__c : '-';
            System.debug('Alexandre tipoDoc Account ' + qto.Account.TipoDocidentificacao__c);
            System.debug('Alexandre DocIdentificacao Account ' + qto.Account.DocIndentificacao__c);
            System.debug('Alexandre qto Account ' + qto.Account);
            System.debug('Alexandre qto ' + qto);
            
            //PLV-5231 - FIM
            
            this.daysDIH = Integer.valueOf('0' + mapDadosSegProposta.get('valorDiasDIH')); //PLV-5139 - FIX01 - INICIO/FIM
            
        }

        private List<Endereco__c> getAddress(String acctId){
            return [
                SELECT 
                    Id,
                    TipoEndereco__c,
                    Logradouro__c,
                    Numero__c,
                    Complemento__c,
                    CEP__c,
                    Cidade__c,
                    Estado__c,
                    Pais__c
                FROM Endereco__c
                WHERE Conta__c =: acctId
                ORDER BY MaisAtual__c DESC, CreatedDate DESC
            ];
        }

        private Endereco__c geAddressByType(List<Endereco__c> lstAddress, String type){
            for (Endereco__c address : lstAddress){
                if(address.TipoEndereco__c == type) return address;
            }

            return null;
        }
    }

    private class Address{
        //PLV-5090 - INICIO
        public String street        {get;set;}
        public String zipcode       {get;set;}
        public String city          {get;set;}
        public String state         {get;set;}                
        //PLV-5090 - FIM

        public Address(Endereco__c address){
            if(address == null) {
                this.street = '';
                this.zipcode = '';
                this.city = '';
                this.state = '';
            }else{
                //PLV-5090 - INICIO                
                this.street = address.Logradouro__c != null ? address.Logradouro__c  : '- ';
                this.street = address.Numero__c != null ? this.street + ' ' + address.Numero__c + ' ' : address.Logradouro__c + ' '; //PLV-4425 - INICIO/FIM
                this.street = address.Complemento__c != null ? this.street + ' ' + address.Complemento__c : this.street;                
                this.zipcode = address.CEP__c !=null ? address.CEP__c : '-';
                this.city = address.Cidade__c !=null ? address.Cidade__c : '-';
                this.state = address.Estado__c !=null ? address.Estado__c : '-';
                //PLV-5090 - FIM
                
            }
        }
    }

    //PLV-4425 - INICIO
    public class Beneficiario{
        public String name {get;set;}
        public String socialName {get;set;} //LECVPV 189 - INICIO/FIM
        public Boolean hasBenefSocialName {get;set;} //LECVPV 189 - INICIO/FIM
        public String cpf {get;set;}
        public Date birthdate {get;set;}
        public String relationship {get;set;}
        public String grauParentescoOutros {get;set;} //PLV-5231 - INICIO/FIM
        public String percentage {get;set;}

        public Beneficiario(BeneficiarioSeguradoProposta__c benef){
            this.name           = benef.Nome__c;
            this.socialName     = benef.NomeSocial__c; //LECVPV 189 - INICIO/FIM
            this.hasBenefSocialName = String.isEmpty(benef.NomeSocial__c) ? false : true; //LECVPV 189 - INICIO/FIM
            this.cpf            = benef.CpfCnpj__c;
            this.birthdate      = benef.Data_de_nascimento__c;
            this.relationship   = benef.GrauParentesco__c;
            this.grauParentescoOutros = benef.BeneficiarioGrauParentescoOutros__c == null ? '' : benef.BeneficiarioGrauParentescoOutros__c; //PLV-5231 - INICIO/FIM
            this.percentage     = benef.Participacao__c + '';
        }
    }

    public class Garantia{
        public String name      {get;set;}
        public String capital   {get;set;}
        public String premioLiq {get;set;}
        public String iof       {get;set;}
        public String premium   {get;set;}

        public Garantia(GarantiaProposta__c garantia){
            if(garantia.PremioComercial__c == null) garantia.PremioComercial__c = 0;
            if(garantia.PremioTotal__c == null) garantia.PremioTotal__c = 0;
            //PLV-5162 - INICIO - Ajuste temporário - Adicionar 'Plus' para cobertura IPA
            if(garantia.Garantia__r.Name.toLowerCase().contains('invalidez permanente total ou parcial')){
                garantia.Garantia__r.Name += ' Plus';
            }
            //PLV-5162 - FIM

            this.name       = garantia.Garantia__r.Name;
            this.capital    = this.convertBRValue(garantia.Capital__c);
            this.premioLiq  = this.convertBRValue(garantia.PremioComercial__c);
            this.premium    = this.convertBRValue(garantia.PremioTotal__c);
            this.iof        = this.convertBRValue(garantia.PremioTotal__c - garantia.PremioComercial__c);
        }

        private String convertBRValue(Decimal value){
            if(value == null || value == 0) return ' - ';
            value = value.setScale(2);
            String val = value.format();
            if(!val.contains(',')) val += ',00';
            else if((val.substring((val.length()-2),(val.length()))).contains(',')) val = val+'0';
            return 'R$ ' + val;
        }
    }
    //PLV-4425 - FIM
    private class Corretor{
        public String name {get;set;}
        public String phone {get;set;}
        public String email {get;set;}
        public String susepPorto {get;set;}
        public String susepOficial {get;set;}
        public Boolean isCorretorLider {get;set;} //II-157 - INICIO/FIM

        public Corretor(){} //II-157 - INICIO/FIM

        public Corretor(FavorecidoRemuneracaoProposta__c favRemContract){
            
            if(favRemContract == null){
                this.name= '';
                this.phone='';
                this.email='';
                this.susepPorto='';
                this.susepOficial='';
            }
            else{
                this.name= favRemContract.Conta__r.name;
                this.phone= favRemContract.Conta__r.Phone;
                this.email= favRemContract.Conta__r.Email__c;
                this.susepPorto= favRemContract.Susep__c;
                this.susepOficial= favRemContract.SusepOficialCorretor__c;
            }
        }

        //II-157 - INICIO
        public List<Corretor> corretores(List<FavorecidoRemuneracaoProposta__c> favsRemContract){
            
            List<Corretor> corretores = new List<Corretor>();
            Corretor corretor = null;

            for(FavorecidoRemuneracaoProposta__c favRemContract : favsRemContract){
               
                corretor = new Corretor();
                
                if(favRemContract == null){
                    corretor.name= '';
                    corretor.phone='';
                    corretor.email='';
                    corretor.susepPorto='';
                    corretor.susepOficial='';
                } else {
                    corretor.name = favRemContract.Conta__r.name;
                    corretor.phone = favRemContract.Conta__r.Phone;
                    corretor.email = favRemContract.Conta__r.Email__c;
                    corretor.susepPorto = favRemContract.Susep__c;
                    corretor.susepOficial = favRemContract.SusepOficialCorretor__c;
                    corretor.isCorretorLider = favRemContract.CorretorLider__c;
                }
                corretores.add(corretor); 
            }

            return corretores;
        }
        //II-157 - FIM
    }

    //PLV-4425 - INICIO
    private class FormaPagamento{
        public String name {get;set;}
        public String codigo {get;set;}
        public String qtdParcelas {get;set;}
        public String namePay {get;set;}
        public String cpfPay {get;set;}
        public String cnpjPay {get;set;}
        //II-125 INICIO
        public String banco {get;set;}
        public String agencia {get;set;}
        public String numeroConta {get;set;}
        //II-125 FIM


        public FormaPagamento(ContratanteProposta__c contratante) {

            this.name        = contratante.FormaPagamento__r.Name;
            this.codigo      = contratante.FormaPagamento__r.Codigo__c;
            this.qtdParcelas = contratante.QuantidadeParcelas__c + '';
            this.namePay     = contratante.ResponsavelPagamento__r.Name;
            this.cpfPay      = contratante.ResponsavelPagamento__r.Cpf__c;
            this.cnpjPay     = contratante.ResponsavelPagamento__r.Cnpj__c;
            //II-125 INICIO
            this.banco          = contratante.InformacaoBancaria__r.BancoNew__r.Name;
            this.agencia        = contratante.InformacaoBancaria__r.Agencia__c;
            this.numeroConta    = contratante.InformacaoBancaria__r.NumeroConta__c + '-' + contratante.InformacaoBancaria__r.Digito__c;
            //II-125 FIM
        }
    }

    private String convertBRValue(Decimal value){
        if(value == null || value == 0) return ' - ';
        value = value.setScale(2);
        String val = value.format();
        if(!val.contains(',')) val += ',00';
        else if((val.substring((val.length()-2),(val.length()))).contains(',')) val = val+'0';
        return 'R$ ' + val;
    }
    //PLV-4425 - FIM

    //PLV-4874 - Inicio
    //PLV-5119 - INICIO
    //PLV-5090 - FIX-3 - REMOÇÃO DE CODIGO - INICIO/FIM
    public static Map<String, String> retornarDadosSegProposta(Id quoteid){
        Map<String, String>         mapaRetorno         = new Map<String, String>();
        
        List<SeguradoProposta__c>   ltSeguradoProposta  = [ SELECT  Pais_Residente__c, Reside_no_Brasil__c, 
                                                            numeroCnpj__c, qtdFuncionarios__c, //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
                                                            Profissao__r.Name, Profissao__r.NomeFantasia__c, toLabel(RegimeTrabalho__c), Renda__c, RamoAtividade__c, //PLV-5090 FIX04 - INICIO/FIM
                                                            toLabel(CicloVacinal__c), LogradouroComercial__c, NumeroComercial__c, ComplementoComercial__c, //PLV-5090 - FIX03 - INICIO/FIM
                                                            CEPComercial__c, UFComercial__c, CidadeComercial__c, cepResidencial__c, CidadeResidencial__c,  //PLV-5090 - FIX03 - INICIO/FIM
                                                            ComplementoResidencial__c, logradouroResidencial__c, numeroResidencial__c, UFResidencial__c //PLV-5090 - FIX03 - INICIO/FIM
                                                            ,EmpresaTrabalhaSocio__c //PLV-5090 FIX04 - INICIO/FIM
                                                            , ( SELECT Id, ValorDias__c FROM GarantiasSeguradoProposta__r WHERE Garantia__r.Sigla__c = 'DIH' OR Garantia__r.Sigla__c  = 'DIA') //PLV-5139 - FIX01 - INICIO/FIM //TKCL-246 INICIO/FIM FIX01
                                                            FROM    SeguradoProposta__c
                                                            WHERE   GrupoProposta__r.ContratanteProposta__r.Proposta__r.Id =: quoteid]; 
        system.debug('ltSeguradoProposta>>>>>>' + ltSeguradoProposta[0]);
        if(!ltSeguradoProposta.isEmpty()){
            //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
            mapaRetorno.put('cnpj', ltSeguradoProposta[0].numeroCnpj__c != null ? Util.imprimeCNPJ(ltSeguradoProposta[0].numeroCnpj__c, '/'):'');
            mapaRetorno.put('numeroFuncionarios', ltSeguradoProposta[0].qtdFuncionarios__c != null ? ltSeguradoProposta[0].qtdFuncionarios__c + '' : '-');

            //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
            mapaRetorno.put('pais', ltSeguradoProposta[0].Pais_Residente__c);
            mapaRetorno.put('viveNoBrasil', ltSeguradoProposta[0].Reside_no_Brasil__c);            
            //PLV-5090 - INICIO
            mapaRetorno.put('profissaoSegProposta', ltSeguradoProposta[0].Profissao__r.NomeFantasia__c);
            system.debug('profissaoSegProposta>>>>>>>>> '+ltSeguradoProposta[0].Profissao__r.NomeFantasia__c);
            mapaRetorno.put('regimeTrabalhoSegProposta', ltSeguradoProposta[0].RegimeTrabalho__c);
            mapaRetorno.put('renda', String.valueOf(ltSeguradoProposta[0].Renda__c));
            mapaRetorno.put('ramoAtividade', String.valueOf(ltSeguradoProposta[0].RamoAtividade__c));
            //PLV-5090 - FIX03 - INICIO                  
            mapaRetorno.put('logradouroComSegProposta', ltSeguradoProposta[0].LogradouroComercial__c != null ? ltSeguradoProposta[0].LogradouroComercial__c : '-');
            mapaRetorno.put('numeroComSegProposta', ltSeguradoProposta[0].NumeroComercial__c != null ? ltSeguradoProposta[0].NumeroComercial__c : '-');
            mapaRetorno.put('complementoComSegProposta', ltSeguradoProposta[0].ComplementoComercial__c != null ? ltSeguradoProposta[0].ComplementoComercial__c : '-');
            mapaRetorno.put('cepComSegProposta', ltSeguradoProposta[0].CEPComercial__c != null ? ltSeguradoProposta[0].CEPComercial__c : '-');            
            mapaRetorno.put('ufComSegProposta', ltSeguradoProposta[0].UFComercial__c != null ? ltSeguradoProposta[0].UFComercial__c : '-');
            mapaRetorno.put('cidadeComSegProposta', ltSeguradoProposta[0].CidadeComercial__c != null ? ltSeguradoProposta[0].CidadeComercial__c : '-'); 
            mapaRetorno.put('logradouroResSegProposta', ltSeguradoProposta[0].logradouroResidencial__c != null ? ltSeguradoProposta[0].logradouroResidencial__c : '-');
            mapaRetorno.put('numeroResSegProposta', ltSeguradoProposta[0].numeroResidencial__c != null ? ltSeguradoProposta[0].numeroResidencial__c : '-');
            mapaRetorno.put('complementoResSegProposta', ltSeguradoProposta[0].ComplementoResidencial__c != null ? ltSeguradoProposta[0].ComplementoResidencial__c : '-');
            mapaRetorno.put('cepResSegProposta', ltSeguradoProposta[0].cepResidencial__c != null ? ltSeguradoProposta[0].cepResidencial__c : '-');            
            mapaRetorno.put('ufResSegProposta', ltSeguradoProposta[0].UFResidencial__c != null ? ltSeguradoProposta[0].UFResidencial__c : '-');
            mapaRetorno.put('cidadeResSegProposta', ltSeguradoProposta[0].CidadeResidencial__c != null ? ltSeguradoProposta[0].CidadeResidencial__c : '-');	
            mapaRetorno.put('empresaTrabalhaSegProposta', ltSeguradoProposta[0].EmpresaTrabalhaSocio__c != null ? ltSeguradoProposta[0].EmpresaTrabalhaSocio__c : '-'); //PLV-5090 FIX04 INICIO/FIM			
            //PLV-5090 - FIX03 - FIM
            //PLV-5090 - FIM
            //PLV-5119 - INICIO         
            mapaRetorno.put('cicloVacinal', ltSeguradoProposta[0].CicloVacinal__c);
            //mapaRetorno.put('ultimaVacinaCicloVacinal', String.valueOf(ltSeguradoProposta[0].UltimaVacinaCicloVacinal__c));
            //PLV-5119 - FIM

            //PLV-5139 - FIX01 - INICIO
            if (ltSeguradoProposta[0].GarantiasSeguradoProposta__r.size() == 0) {
                mapaRetorno.put('valorDiasDIH', '' );
            }
            else {
                mapaRetorno.put('valorDiasDIH', ltSeguradoProposta[0].GarantiasSeguradoProposta__r[0].ValorDias__c.format()  ); 
            }
            //PLV-5139 - FIX01 - FIM
        }else{
            mapaRetorno.put('pais', 'Brasil');
            mapaRetorno.put('viveNoBrasil', 'Sim');
            //PLV-5090 - INICIO
            mapaRetorno.put('profissaoSegProposta', '-');
            mapaRetorno.put('regimeTrabalhoSegProposta', '-');
            mapaRetorno.put('renda', '-');
            mapaRetorno.put('ramoAtividade', '');
            //PLV-5090 - FIX03 - INICIO
            mapaRetorno.put('logradouroComSegProposta', '-');
            mapaRetorno.put('numeroComSegProposta', '-');
            mapaRetorno.put('complementoComSegProposta', '');
            mapaRetorno.put('cepComSegProposta', '-');            
            mapaRetorno.put('ufComSegProposta', '-');
            mapaRetorno.put('cidadeComSegProposta', '-');  
            mapaRetorno.put('logradouroResSegProposta', '-');
            mapaRetorno.put('numeroResSegProposta', '-');
            mapaRetorno.put('complementoResSegProposta', '-');
            mapaRetorno.put('cepResSegProposta', '-');            
            mapaRetorno.put('ufResSegProposta', '-');
            mapaRetorno.put('cidadeResSegProposta', '-');            
            //PLV-5090 - FIX03 - FIM
            //PLV-5090 - FIM
            //PLV-5119 - INICIO
            mapaRetorno.put('cicloVacinal', '-');
            //mapaRetorno.put('ultimaVacinaCicloVacinal', '-');
            //PLV-5119 - FIM
            mapaRetorno.put('valorDiasDIH', '' ); //PLV-5139 - FIX01 - INICIO/FIM
        }         
        
        return mapaRetorno;
    }
    //PLV-5119 - FIM
    //PLV-4874 - Fim    
}