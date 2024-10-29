/**
 * @author Guilherme Azevedo
 * @date 2020-11-17
 * @description Criada para a história PLV-4365
 */
@IsTest
public with sharing class IntegracaoSampleMedTest {
    //PLV-4365 INICIO
    
    @TestSetup
    static void makeData(){
        RamoAtividade__c  ramo = new RamoAtividade__c();
        ramo.Name='teste';
        insert ramo;

        //FNPVVEP-98 INICIO
        // Account acct = TestDataFactory.gerarConta();
        // acct.Sexo__c = 'Masculino';
        // acct.RamoAtividade__c = ramo.id;
        // update acct;

        Account acct = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            LastName = 'Teste',
            NomeSocial__c = 'Teste TI', 
            Nacionalidade__c = 'Brasileira',
            CPF__c = '00478394659',
            Rg__c = '232323231',
            Sexo__c = 'Masculino',
            RamoAtividade__c = ramo.id,
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)',
            PersonEmail = 'abc@portoseguro.com.br'
        );
        insert acct;
        //FNPVVEP-98 FIM

        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(acct).createRecord();
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Em criação';
        opp.CloseDate = date.today();
        opp.Name = 'teste';
        opp.AccountId = acct.id;
        opp.RecordTypeId = oppVidaEmGrupo;
        insert opp;

        //TKCL-246 FIX05 INICIO
        ContadorCodigo__c contadorTecnico = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contadorComercial = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(acct).createRecord();
        CanalDistribuicao__c canalDistribuicao = (CanalDistribuicao__c) new CanalDistribuicaoFactory().createRecord(); 

        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.ProductCode = '49';
        produtoTecnico.Segmento__c = 'Individual';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.ProductCode = 'APTLMKT';
        produtoComercial.Segmento__c = 'Individual';
        produtoComercial.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercial;
        //TKCL-246 FIX05 FIM
   
        Quote proposta = new Quote(
            OpportunityId = opp.id, 
            Name = 'Teste Quote56', 
            NumeroProposta__c = '356',
            Origem__c = '9',
            status = 'Pendente',
            CodigoCorretor__c = dadosCorretor.Id,
            Produto__c = produtoComercial.id //TKCL-246 FIX05 INICIO/FIM
        );
        insert proposta; 
        //PLV-5493 - INICIO
        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
                Name = 'CORRETAGEM',
                Codigo__c = 'COR',
                LimiteMinimo__c = 10000,
                LimiteMaximo__c = 100000,
                ModeloRecuperacao__c = 'Integral'
        );
        
        insert tipoRemuneracao;
        
        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(
                TipoRemuneracao__c = tipoRemuneracao.Id,
                Proposta__c = proposta.Id,
                Percentual__c = 100
        );
        
        insert remuneracaoProposta;
        
        FavorecidoRemuneracaoProposta__c favorecido = new FavorecidoRemuneracaoProposta__c(
        		Conta__c = acct.Id,
                Papel__c = 'Parceiro',
                Participacao__c = 100,
                RemuneracaoProposta__c = remuneracaoProposta.Id,
                Susep__c = '123',
                SusepEmissao__c = '123',
                SusepOficialCorretor__c = '123',
                SusepOrcamento__c = '123',
            	CorretorResponde__c = false
        );
        
        insert favorecido;

		//PLV-5493 - FIM
        List<String> lstGarantiaName = new List<String>{'Morte Acidental', 'Diagnóstico de Câncer','Doenças Graves', 'Diárias por Incapacidade Temporária por Acidente'};
        List<Garantia__c> lstGarantias = new List<Garantia__c>();
        List<GarantiaProposta__c> lstGarantiasQuote = new List<GarantiaProposta__c>();
        
        for(String garantiaName : lstGarantiaName){
            Garantia__c garantia = (Garantia__c) new GarantiaFactory().createRecord();
            garantia.name = garantiaName;
            
            update garantia;
            lstGarantias.add(garantia);
        }
        
        for(Garantia__c garantia : lstGarantias){
            GarantiaProposta__c garantiaProposta = new GarantiaProposta__c();
            garantiaProposta.Proposta__c = proposta.id;
            garantiaProposta.Garantia__c = garantia.id;
            garantiaProposta.Capital__c = 100000;
            lstGarantiasQuote.add(garantiaProposta);
        }
        
        insert lstGarantiasQuote;

        CriticaProposta__c Ctt2 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Subscrição',
            Status__c = 'Não iniciada',
            Integracao__c = 'SAMPLE',
            Acao__c = 'auto' //INICIO/FIM | PLV-4647-VI-Guilherme Brito
        ); 
        
        insert Ctt2;

        CriticaProposta__c Ctt3 = new CriticaProposta__c(
            Proposta__c = proposta.Id,
            MomentoAnalise__c = 'Subscrição',
            Status__c = 'Não iniciada',
            Integracao__c = 'SAMPLE',
            Acao__c = 'tele' //INICIO/FIM | PLV-4647-VI-Guilherme Brito
        ); 
        
        insert Ctt3;
        
        //PLV-4790 FIX 12 - INÍCIO
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        ContratanteProposta__c contratante = new ContratanteProposta__c( //PLV-4854-FIX2 - INICIO/FIM
            conta__c = acct.Id,
            Proposta__c = proposta.Id,
            Tipo__c = 'Principal',
            FormaPagamento__c = formaPagamento.Id
        );
        insert contratante; //PLV-4854-FIX2 - INICIO/FIM
        //PLV-4790 FIX 12 - FIM
        
        //PLV-4854-FIX2 - INICIO
        GrupoProposta__c grupo = new GrupoProposta__c(
            Name = 'Teste Quote56',
            ContratanteProposta__c = contratante.Id
        ); 
        insert grupo;

        Profissao__c profissao = new Profissao__c(
            Codigo__c = '123456'
        ); 
        insert profissao;

        SeguradoProposta__c segurado = new SeguradoProposta__c(
            Profissao__c = profissao.id,
            GrupoProposta__c = grupo.Id
        ); 
        insert segurado;
        //PLV-4854-FIX2 - FIM
    }

    @IsTest
	static void integrarSuccessTest() {  
        Set<Id> criticasId = new Set<Id>();
        
        Test.startTest(); 
        IntegracaoSampleMed.integrar((new Map<Id, CriticaProposta__c>([SELECT Id FROM CriticaProposta__c WHERE Acao__c = 'auto' LIMIT 10])).keySet()); //INICIO/FIM | PLV-4647-VI-Guilherme Brito
        Test.stopTest();
    }
    
    @IsTest
	static void integrarFailTest() {  
        Set<Id> criticasId = new Set<Id>();
        
        Test.startTest(); 
        IntegracaoSampleMed.integrar((new Map<Id, CriticaProposta__c>([SELECT Id FROM CriticaProposta__c WHERE Acao__c = 'tele' LIMIT 10])).keySet()); //INICIO/FIM | PLV-4647-VI-Guilherme Brito
        Test.stopTest();
    }
    
    //PLV-4365 FIM

    //II-183 - INICIO
    @IsTest
	static void integrarTest1() {  
        Set<Id> criticasId = new Set<Id>();
        FavorecidoRemuneracaoProposta__c fav = [SELECT Id,CorretorResponde__c, RemuneracaoProposta__r.Proposta__c, CorretorLider__c FROM FavorecidoRemuneracaoProposta__c];
        fav.CorretorResponde__c = True;
        fav.CorretorLider__c = True;
        update fav;
        Test.startTest(); 
        IntegracaoSampleMed.integrar((new Map<Id, CriticaProposta__c>([SELECT Id FROM CriticaProposta__c WHERE Acao__c = 'auto' LIMIT 10])).keySet());
        Test.stopTest();
    }

    @IsTest
	static void integrarTest2() {  
        Set<Id> criticasId = new Set<Id>();
        FavorecidoRemuneracaoProposta__c fav = [SELECT Id,CorretorResponde__c, RemuneracaoProposta__r.Proposta__c, CorretorLider__c FROM FavorecidoRemuneracaoProposta__c];
        fav.CorretorLider__c = True;
        update fav;
        Test.startTest(); 
        IntegracaoSampleMed.integrar((new Map<Id, CriticaProposta__c>([SELECT Id FROM CriticaProposta__c WHERE Acao__c = 'auto' LIMIT 10])).keySet());
        Test.stopTest();
    }
    //II-183 - FIM

    //FNPVVEP-98 INICIO
    @IsTest
    static void integrarTest3() {  
        Set<Id> criticasId = new Set<Id>();
        FavorecidoRemuneracaoProposta__c fav = [SELECT Id,CorretorResponde__c, RemuneracaoProposta__r.Proposta__c, CorretorLider__c FROM FavorecidoRemuneracaoProposta__c];
        fav.CorretorLider__c = True;
        update fav;
        Test.startTest(); 
        IntegracaoSampleMed.integrar((new Map<Id, CriticaProposta__c>([SELECT Id FROM CriticaProposta__c WHERE Acao__c = 'tele' LIMIT 10])).keySet());
        Test.stopTest();
    }
    //FNPVVEP-98 INICIO
}