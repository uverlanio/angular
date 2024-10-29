//PLV-4350 FIX 1 - INÍCIO
@isTest
public class GarantiaPropostaBOTest {
    @TestSetup
    static void setup() {
        TestDataFactory.gerarDadosSetup();
        
        Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica')
            .Id,
            LastName = 'Teste2',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = Date.valueOf('1980-12-24'),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert conta;
        
        Opportunity oportunidade = new Opportunity(
            Name = 'Teste Contrato',
            StageName = 'Em criação',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro(
                'Opportunity',
                'VidaIndividual'
            )
            .Id,
            AccountId = conta.Id,
            CloseDate = Date.today()
        );
        insert oportunidade;
        
        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Teste Versao',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro(
                'Product2',
                'ProdutoTecnico'
            )
            .Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual'
        );
        
        insert produtoTec;
        
        produtoTec.Status__c = 'Em ativação';
        produtoTec.NumeroSusep__c = '1234x';
        update produtoTec;
        
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoComercial = new Product2(
            ProdutoTecnico__c = produtoTec.Id,
            Name = 'Nome Produto Teste Versao',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            LimiteTotalCarregamento__c = 200,
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro(
                'Product2',
                'ProdutoComercial'
            )
            .Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual'
        );
        insert produtoComercial;
        
        RamoSeguro__c RamoSeguro = new RamoSeguro__c(
            Name = 'VIDA',
            CodigoEmpresa__c = '214',
            Codigo__c = '2',
            IdExterno__c = '214_2',
            Empresa__c = conta.Id,
            Status__c = 'Ativo',
            CodigoOrigemDoMovimentoBCP__c = '32'
        );
        insert RamoSeguro;
        
        Garantia__c garantia = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'CAP'
        );
        insert garantia;
        
        RamoGarantia__c ramoGarantia = new RamoGarantia__c(
            Garantia__c = garantia.Id,
            RamoSeguro__c = RamoSeguro.Id
        );
        insert ramoGarantia;
        
        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            Garantia__c = garantia.Id,
            Produto__c = produtoTec.Id,
            RamoSeguro__c = RamoSeguro.Id,
            OrdemPrioridade__c = 1,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro(
                'GarantiaProduto__c',
                'ProdutoTecnico'
            )
            .Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );
        insert garantiaProduto;
        
        Modalidade__c modalidade = new Modalidade__c(
            RamoSeguro__c = RamoSeguro.Id,
            Name = 'Mod teste',
            Codigo__c = '0'
        );
        insert modalidade;
        
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        Quote proposta = TestDataFactory.gerarPropostaObjeto(
            produtoComercial,
            ramoSeguro,
            conta,
            dadosCorretor,
            oportunidade,
            modalidade
        );
        
        ContratanteProposta__c segurado = new ContratanteProposta__c(
            conta__c = conta.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Principal'
        );
        insert segurado;
        
        GrupoProposta__c grupo = new GrupoProposta__c(
            Name = 'Teste',
            QuantidadeVidas__c = 1,
            ContratanteProposta__c = segurado.Id
        );
        insert grupo;
        
        SeguradoProposta__c vida = new SeguradoProposta__c(
            Conta__c = conta.Id,
            GrupoProposta__c = grupo.Id
        );
        insert vida;
        
        BeneficiarioSeguradoProposta__c beneficiario = new BeneficiarioSeguradoProposta__c(
            SeguradoProposta__c = vida.Id,
            CpfCnpj__c = '00478394659',
            Nome__c = 'Teste Contrato',
            TipoBeneficiario__c = 'Nome do beneficiário',
            GrauParentesco__c = 'Pai',
            Participacao__c = 100,
            Pep__c = 'Não'
        );
        insert beneficiario;
        
        Contract contrato = new Contract(
            Name = '111',
            Oportunidade__c = oportunidade.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Novo',
            AccountId = conta.Id
        );
        insert contrato;
        
        ContratanteContrato__c seguradoContrato = TestDataFactory.gerarContratanteContrato(
            contrato,
            conta,
            null
        );
        
        GarantiaProposta__c garantiaProposta = TestDataFactory.gerarGarantiaProposta(
            proposta,
            garantiaProduto
        );
    }
    // II-99 - INICIO
    @isTest
    public static void testSamplemedRecusa(){
        Quote proposta = [SELECT Id, NumeroProposta__c, Status, NumeroPropostaUnico__c FROM Quote WHERE NumeroProposta__c = '00006767' LIMIT 1];
        proposta.CodigoMotivoDevolucao__c = '89';
        update proposta;

         List<GarantiaProposta__c> lGarantiaProposta = [select 
                                                       Id, 
                                                       Proposta__r.NumeroPropostaUnico__c, 
                                                       Id_SampleMed__c, 
                                                       Status_sampleMed__c, 
                                                       Data_SampleMed__c, 
                                                       Observacao_SampleMed__c,  
                                                       Garantia__r.Sigla__c, 
                                                       Garantia__r.Name, 
                                                       Garantia__r.Status__c,
                                                       GarantiaProduto__r.CaracteristicaGarantia__c,
                                                       GarantiaProduto__r.Obrigatoria__c
                                                       from 
                                                       GarantiaProposta__c 
                                                      ];

        CriticaProposta__c critica = new CriticaProposta__c();
        critica.Proposta__c = proposta.Id;
        critica.Integracao__c = 'SAMPLE';
        critica.MomentoAnalise__c = 'Subscrição';       
        insert critica;
        
        String statusAprovado = 'Aprovado';
        String statusRecusado = 'Recusado';
        String statusInconclusivo = 'Inconclusivo';
        
        lGarantiaProposta[0].Status_sampleMed__c = statusRecusado;
        
        update lGarantiaProposta;
        
        GarantiaPropostaBo.getInstance().atualizarCritica(proposta.NumeroPropostaUnico__c, lGarantiaProposta);
        critica = [SELECT Id, Status__c FROm CriticaProposta__c LIMIT 1];
        
        String numeroProposta = proposta.NumeroProposta__c;       
        Test.startTest();
        GarantiaPropostaBO.getInstance().atualizarCriticaSampleMed(numeroProposta, 'Recusado');
        Test.stopTest();
        System.assertEquals(critica.Status__c, 'Inconclusiva');
    }
    // II-99 - FIM
    @isTest
    public static void testSamplemed() {
        Quote proposta = [SELECT Id, NumeroProposta__c, Status, NumeroPropostaUnico__c FROM Quote WHERE NumeroProposta__c = '00006767' LIMIT 1];
        //VEP - 146 INICIO
        proposta.NR__c = '5';
        update proposta;
        //VEP - 146 FIM

        List<GarantiaProposta__c> lGarantiaProposta = [select 
                                                       Id, 
                                                       Proposta__r.NumeroPropostaUnico__c, 
                                                       Id_SampleMed__c, 
                                                       Status_sampleMed__c, 
                                                       Data_SampleMed__c, 
                                                       Observacao_SampleMed__c,  
                                                       Garantia__r.Sigla__c, 
                                                       Garantia__r.Name, 
                                                       Garantia__r.Status__c,
                                                       GarantiaProduto__r.CaracteristicaGarantia__c,
                                                       GarantiaProduto__r.Obrigatoria__c
                                                       from 
                                                       GarantiaProposta__c 
                                                      ];
        CriticaProposta__c critica = new CriticaProposta__c();
        critica.Proposta__c = proposta.Id;
        critica.Integracao__c = 'SAMPLE';
        critica.MomentoAnalise__c = 'Subscrição';        
        insert critica;
        
        String statusAprovado = 'Aprovado';
        String statusRecusado = 'Recusado';
        String statusInconclusivo = 'Inconclusivo';
        
        lGarantiaProposta[0].Status_sampleMed__c = statusInconclusivo;
        
        update lGarantiaProposta;
        
        GarantiaPropostaBo.getInstance().atualizarCritica(proposta.NumeroPropostaUnico__c, lGarantiaProposta);
        critica = [SELECT Id, Status__c FROm CriticaProposta__c LIMIT 1];
        //System.assertEquals(proposta.Status, 'Em análise' ); //PLV - 4350 - FIX2 -INICIO/FIM
        //PLV-5023 - INICIO        
        String numeroProposta = proposta.NumeroProposta__c;    
        //VEP-146 INICIO    
        Test.startTest();
        GarantiaPropostaBO.getInstance().atualizarCriticaSampleMed(numeroProposta, 'Inconclusiva');
        Test.stopTest();
        //VEP-146 FIM
        //PLV-5023 - FIM
        System.assertEquals(critica.Status__c, 'Inconclusiva');
    }
    //PLV-4350 FIX 1 - FIM
    
    //VEP-146-INICIO
    @isTest
    public static void testSamplemedNR() {
        Quote proposta = [SELECT Id, NumeroProposta__c, Status, NumeroPropostaUnico__c FROM Quote WHERE NumeroProposta__c = '00006767' LIMIT 1];
        proposta.NR__c = '5';
        update proposta;
        List<GarantiaProposta__c> lGarantiaProposta = [select 
                                                       Id, 
                                                       Proposta__r.NumeroPropostaUnico__c, 
                                                       Id_SampleMed__c, 
                                                       Status_sampleMed__c, 
                                                       Data_SampleMed__c, 
                                                       Observacao_SampleMed__c,  
                                                       Garantia__r.Sigla__c, 
                                                       Garantia__r.Name, 
                                                       Garantia__r.Status__c,
                                                       GarantiaProduto__r.CaracteristicaGarantia__c,
                                                       GarantiaProduto__r.Obrigatoria__c
                                                       from 
                                                       GarantiaProposta__c 
                                                      ];
        CriticaProposta__c critica = new CriticaProposta__c();
        critica.Proposta__c = proposta.Id;
        critica.Integracao__c = 'SAMPLE';
        critica.MomentoAnalise__c = 'Subscrição';        
        insert critica;
        
        String statusAprovado = 'Aprovado';
        String statusRecusado = 'Recusado';
        String statusInconclusivo = 'Inconclusivo';
        
        lGarantiaProposta[0].GarantiaProduto__r.CaracteristicaGarantia__c = 'Principal';
        lGarantiaProposta[0].Status_sampleMed__c = statusRecusado;
        update lGarantiaProposta;

        Test.startTest();
        GarantiaPropostaBo.getInstance().atualizarCritica(proposta.NumeroPropostaUnico__c, lGarantiaProposta);
        Test.stopTest();

        critica = [SELECT Id, Status__c FROM CriticaProposta__c LIMIT 1];
        System.assertEquals(critica.Status__c, 'Inconclusiva');    
    }
    //VEP-146-FIM
    //ANNVI-225 - INICIO
    @IsTest
    static void atualizarCritSamplMedTest(){
        
        Test.startTest();

        Account conta = [SELECT Id FROM Account LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c LIMIT 1];
        Account empresa = [SELECT Id FROM Account LIMIT 1];
        DadosCorretor__c dadosCorretor = [SELECT Id FROM DadosCorretor__c LIMIT 1];
        Opportunity orcamento = [SELECT Id FROM Opportunity LIMIT 1];
        Modalidade__c modalidade = [SELECT Id FROM Modalidade__c LIMIT 1];

        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18', '00006859'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18', '00006859'),
                Produto__c = produto.Id,
                RamoSeguro__c = ramoSeguro.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = empresa.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamento.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00006859',
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO',
                MelhorPeriodoContato__c = 'I',
                NR__c = '5'
        );

        insert proposta;

        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        TestDataFactory.gerarContratanteProposta(conta, proposta, formaPagamento);

        CriticaProposta__c cp = new CriticaProposta__c();
        cp.Proposta__c = proposta.Id;
        cp.Integracao__c = 'SAMPLE';
        cp.MomentoAnalise__c = 'Subscrição';
        cp.Status__c = 'Em aprovação';
        insert cp;

        GarantiaPropostaBO.getInstance().atualizarCriticaSampleMed(proposta.NumeroPropostaUnico__c, cp.Status__c);
       
        Test.stopTest();
        
    }
    @IsTest
    static void atualizarGarsPropTest(){

        List<ServiceGarantiaProposta.ApplicantsProduct> aps = new List<ServiceGarantiaProposta.ApplicantsProduct>();
        ServiceGarantiaProposta.ApplicantsProduct ap = new ServiceGarantiaProposta.ApplicantsProduct();

        ap.capital_id = '123';
        ap.status = '1';
        ap.value = '1000';
        ap.id = 'applicant123';
        ap.applicant_id = 'user456';
        ap.label = 'Label 1';
        ap.id_on_origin = 'CAP';
        ap.medical_opinion = 'Opinion text';
        
        ap.ApplicantsProductsRule = new List<ServiceGarantiaProposta.Answer>();
        aps.add(ap);
        
        Test.startTest();

        Account conta = [SELECT Id FROM Account LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1];
        GarantiaProduto__c garantiaProduto = [SELECT Id, Garantia__c, CaracteristicaGarantia__c FROM GarantiaProduto__c LIMIT 1];
        RamoSeguro__c ramoSeguro = [SELECT Id FROM RamoSeguro__c LIMIT 1];
        Account empresa = [SELECT Id FROM Account LIMIT 1];
        DadosCorretor__c dadosCorretor = [SELECT Id FROM DadosCorretor__c LIMIT 1];
        Opportunity orcamento = [SELECT Id FROM Opportunity LIMIT 1];
        Modalidade__c modalidade = [SELECT Id FROM Modalidade__c LIMIT 1];

        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18', '00006858'),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18', '00006858'),
                Produto__c = produto.Id,
                RamoSeguro__c = ramoSeguro.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = empresa.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC',
                OpportunityId = orcamento.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00006858',
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO',
                MelhorPeriodoContato__c = 'I',
                NR__c = '5'
        );

        insert proposta;

        Profissao__c profissao = new Profissao__c(
	        CodigoProfissao__c = '2111-05'
        );

		insert profissao;

        conta.BillingCity = 'São Paulo';
        conta.BillingPostalCode = 'BillingPostalCode';
        conta.BillingState = 'SP';
        conta.BillingStreet = 'Barão de Piracicaba';
        conta.Cpf__c = '518.179.180-87';
        conta.PersonBirthdate = System.today();
        conta.PersonEmail = 'ifgois@gmail.com';
        conta.Profissao__c = profissao.Id;
        conta.Profissao__r = profissao;
        conta.Profissao__r.Name = 'ATUARIO';
        conta.Rg__c = '';
        conta.Sexo__c = 'MASC';

        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        TestDataFactory.gerarContratanteProposta(conta, proposta, formaPagamento);

        CriticaProposta__c cp = new CriticaProposta__c();
        cp.Proposta__c = proposta.Id;
        cp.Integracao__c = 'SAMPLE';
        cp.MomentoAnalise__c = 'Subscrição';
        cp.Status__c = 'Em aprovação';
        insert cp;

        TipoRemuneracao__c tp = TestDataFactory.gerarTipoRemuneracao();
        tp.Name = 'CORRETAGEM';

        update tp;

        RemuneracaoProposta__c rp = TestDataFactory.gerarRemuneracaoProposta(proposta, tp);
        FavorecidoRemuneracaoProposta__c frp = TestDataFactory.gerarFavorecidoRemuneracaoProposta(rp, conta);
        frp.CorretorResponde__c = true;
        frp.CorretorLider__c = true;
        frp.RemuneracaoProposta__r = rp;

        update frp;

        garantiaProduto.CaracteristicaGarantia__c = 'Principal';
        garantiaProduto.Obrigatoria__c = true;
        update garantiaProduto;

        GarantiaProposta__c gp = TestDataFactory.gerarGarantiaProposta(proposta, garantiaProduto);
        gp.GarantiaProduto__r = garantiaProduto;

        update gp;

        GarantiaPropostaBO.getInstance().atualizaGarantiasProposta(proposta.NumeroPropostaUnico__c, aps);

        Test.stopTest();        
    }

    @IsTest
    static void setGarsPropTest(){
        
        Test.startTest();
       
        Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1];   
        GarantiaProduto__c garantiaProduto = [SELECT Id FROM GarantiaProduto__c LIMIT 1];    
        Opportunity orcamento = [SELECT Id FROM Opportunity LIMIT 1];
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        
        List<GarantiaOrcamento__c> garsOrc = new List<GarantiaOrcamento__c>();
        GarantiaOrcamento__c garOrc = TestDataFactory.gerarGarantiaOrcamento(garantia, orcamento);
        garOrc.GarantiaProduto__c = garantiaProduto.Id; 
        garsOrc.add(garOrc);

        GarantiaPropostaBO.setGarantiasProposta(garsOrc, proposta.Id);

        Test.stopTest();        
    }

    @IsTest
    static void setGarCttPropTest(){
        
        Test.startTest();

        Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Opportunity orcamento = [SELECT Id FROM Opportunity LIMIT 1];
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];   

        ContratanteOrcamento__c cttOrtc = TestDataFactory.gerarContratanteOrcamento(orcamento, conta);
        List<GarantiaContratanteOrcamento__c> garsCttOrc = new List<GarantiaContratanteOrcamento__c>();
        GarantiaContratanteOrcamento__c garCttOrc = TestDataFactory.gerarGarantiaContratanteOrcamento(garantia, cttOrtc);
        garsCttOrc.add(garCttOrc);

        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c cp = TestDataFactory.gerarContratanteProposta(conta, proposta, formaPagamento);

        GarantiaPropostaBO.setGarantiaContratanteProposta(garsCttOrc, cp.Id);            
        
        Test.stopTest();        
    }

    @IsTest
    static void setGarsGrpPropTest(){
        
        Test.startTest();

        Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Opportunity orcamento = [SELECT Id FROM Opportunity LIMIT 1];
        GarantiaProduto__c garantiaProduto = [SELECT Id FROM GarantiaProduto__c LIMIT 1];
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];

        ContratanteOrcamento__c cttOrc = TestDataFactory.gerarContratanteOrcamento(orcamento, conta);

        GrupoOrcamento__c go = TestDataFactory.gerarGrupoOrcamento(cttOrc);
        
        Map<String, List<GarantiaGrupoOrcamento__c>> mgarantiaGOrcamento = new Map<String, List<GarantiaGrupoOrcamento__c>>();
        List<GarantiaGrupoOrcamento__c> garsGgo = new List<GarantiaGrupoOrcamento__c>();        

        GarantiaGrupoOrcamento__c ggo = TestDataFactory.gerarGarantiaGrupoOrcamento(garantia, go);
        ggo.GarantiaProduto__c = garantiaProduto.Id;

        update ggo;

        garsGgo.add(ggo);

        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c cp = TestDataFactory.gerarContratanteProposta(conta, proposta, formaPagamento);

        GrupoProposta__c gp = TestDataFactory.gerarGrupoProposta(cp);

        mgarantiaGOrcamento.put(gp.Id, garsGgo);

        GarantiaPropostaBO.setGarantiasGrupoPosposta(mgarantiaGOrcamento);

        Test.stopTest();        
    }


    @IsTest
    static void setGarsSegPropTest(){
        
        Test.startTest();

        Garantia__c garantia = [SELECT Id FROM Garantia__c LIMIT 1];
        Account conta = TestDataFactory.gerarConta();
        Quote proposta = [SELECT Id FROM Quote LIMIT 1];
        GarantiaProduto__c garantiaProduto = [SELECT Id FROM GarantiaProduto__c LIMIT 1];
       
        conta.Cpf__c = '368.125.100-25';
        update conta;

        List<GarantiasGrupoProposta__c> garsGp = new List<GarantiasGrupoProposta__c>();

        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c cp = TestDataFactory.gerarContratanteProposta(conta, proposta, formaPagamento);

        GrupoProposta__c gp = TestDataFactory.gerarGrupoProposta(cp);
        GarantiasGrupoProposta__c ggp = TestDataFactory.gerarGarantiaGrupoProposta(garantia, gp);
        ggp.CurrencyIsoCode = 'BRL';
        ggp.GarantiaProduto__c = garantiaProduto.Id;

        update ggp;
        
        garsGp.add(ggp);

        SeguradoProposta__c sp = TestDataFactory.gerarSeguradoProposta(conta, gp, formaPagamento);

        GarantiaPropostaBO.setGarantiasSeguradoProposta(garsGp, sp.Id);

        Test.stopTest();        
    }
    //ANNVI-225 - FIM
}