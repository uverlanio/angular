// PLV-4179
/*
/*  @author: Squad Avanxo 
/*  @description: Classe de teste para integração AS 
/*/
@isTest
public class IntegracaoASTest {
   //PLV - 4726 Inicio
    @testSetup
    private static void setup() {
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.Segmento__c = 'Individual';
        update produtoComercial;     
    }
     //PLV - 4726 FIM
    
    @IsTest
    static void TestIntegrationCriticaTrigger() {
         //PLV - 4726 Inicio
        Product2 produtoComercial = [SELECT id,Segmento__c  FROM Product2 where Segmento__c = 'Individual' limit 1];
         //PLV - 4726 Inicio
                    
        RamoAtividade__c  ramo = new RamoAtividade__c();
        ramo.Name='teste';
        insert ramo;     
             
        Account acct = TestDataFactory.gerarConta();
       	acct.RamoAtividade__c = ramo.id;
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Em criação';
        opp.CloseDate = date.today();
        opp.Name = 'teste';
        opp.AccountId = acct.id;
        opp.RecordTypeId = oppVidaEmGrupo;
        insert opp;
   
         //PLV - 4726 Inicio
        Quote Qtt = new Quote(OpportunityId = opp.id, 
                              Name = 'Teste Quote56', 
                              NumeroProposta__c = '356',
                              Origem__c = '9',
                              Produto__c= produtoComercial.id,
                              status = 'Em análise',
                              CodigoMotivoDevolucao__c = '18' //II-48 INCIO-FIM
                     );
         //PLV - 4726 FIM
        insert Qtt;
        
        CriticaProposta__c Ctt = new CriticaProposta__c(Proposta__c = Qtt.id,
                      MomentoAnalise__c = 'Crítica de Controle',
                      Status__c = 'Recusado',
                      Integracao__c = 'DOCUSIGN');      
        
        Test.setMock(HttpCalloutMock.class, 
        	new MockHttpResponse( 
                    '{"codigo":0,"mensagem":"Dados inseridos com sucesso."}', 
                     200,'OK'
            )
         );

        Test.startTest();   
            insert Ctt;
        	IntegracaoAS.inserirHistoricoAS(new Set<Id>{Qtt.id});
        Test.stopTest();
      
    }
    
    @IsTest
    static void TestIntegrationQuoteTrigger() {
         //PLV - 4726 Inicio
        Product2 produtoComercial = [SELECT id,Segmento__c  FROM Product2 where Segmento__c = 'Individual' limit 1];
         //PLV - 4726 Fim
        
        RamoAtividade__c  ramo = new RamoAtividade__c();
        ramo.Name='teste';
        insert ramo;     
             
        Account acct = TestDataFactory.gerarConta();
       	acct.RamoAtividade__c = ramo.id;
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Em criação';
        opp.CloseDate = date.today();
        opp.Name = 'teste';
        opp.AccountId = acct.id;
        opp.RecordTypeId = oppVidaEmGrupo;
        insert opp;
   
         //PLV - 4726 Inicio
        Quote Qtt = new Quote(OpportunityId = opp.id, 
                              Name = 'Teste Quote56', 
                              NumeroProposta__c = '356',
                              Produto__c= produtoComercial.id,
                              Origem__c = '9'
                     );
         //PLV - 4726 Fim
        Test.setMock(HttpCalloutMock.class, 
        	new MockHttpResponse( 
                    '{"codigo":0,"mensagem":"Dados inseridos com sucesso."}', 
                     200,'OK'
            )
         );

        Test.startTest();   
            insert Qtt;
        	IntegracaoAS.inserirHistoricoAS(new Set<Id>{Qtt.id});
        Test.stopTest();
      
    }
    
    @IsTest
    static void TestIntegrationAS() {
        
		Test.setMock(HttpCalloutMock.class, 
                     new MockHttpResponse('{"codigo":0,"mensagem":"Dados inseridos com sucesso."}', 200, 'OK'));

        Test.startTest();      
             String resposta = CIVServices.getInstance().integracaoAS('teste'); 
        Test.stopTest();             
    }
    
    @IsTest
    static void TestIntegrationError() {
        
        Test.setMock(HttpCalloutMock.class, 
                     new MockHttpResponse('{"codigo":0,"mensagem":"Dados inseridos com sucesso."}', 420, 'Error'));
    
        Test.startTest();
          
            try{        
                 String resposta = CIVServices.getInstance().integracaoAS('teste');
            }catch(Exception e){
                system.debug('e '+e.getMessage());
            }
                
        Test.stopTest();             
    }
    
    //PLV-4365 INICIO 
    @IsTest
    static void gerarTarefaTeleSubscricaoSuccess() {
        RamoAtividade__c  ramo = new RamoAtividade__c();
        ramo.Name='teste';
        insert ramo;     
             
        Account acct = TestDataFactory.gerarConta();
        acct.Cpf__c = '395.343.208-70';
       	acct.RamoAtividade__c = ramo.id;
       	update acct;
       	
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Em criação';
        opp.CloseDate = date.today();
        opp.Name = 'teste';
        opp.AccountId = acct.id;
        opp.RecordTypeId = oppVidaEmGrupo;
        insert opp;

        //TKCL-246 FIX05 INICIO
        Product2 produtoTecnicoAp = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnicoAp.Status__c = 'Em ativação';
        produtoTecnicoAp.NumeroSusep__c = '123';
        produtoTecnicoAp.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnicoAp;
        produtoTecnicoAp.Status__c = 'Ativo';
        produtoTecnicoAp.ProductCode = '49';
        produtoTecnicoAp.Segmento__c = 'Individual';
        update produtoTecnicoAp;
        Product2 produtoComercialAp = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnicoAp).createRecord();
        produtoComercialAp.Status__c = 'Ativo';
        produtoComercialAp.ProductCode = 'APTLMKT';
        produtoComercialAp.Segmento__c = 'Individual';
        produtoComercialAp.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercialAp;
        //TKCL-246 FIX05 FIM
   
        Quote Qtt = new Quote(
            OpportunityId = opp.id, 
            Name = 'Teste Quote56', 
            NumeroProposta__c = '356',
            Origem__c = '9',
            status = 'Em análise',
            Produto__c = produtoComercialAp.Id, //TKCL-246 FIX05 INICIO/FIM
            CodigoMotivoDevolucao__c = '18' //II-48 INCIO-FIM
        );
        insert Qtt; 
        
        CriticaProposta__c Ctt = new CriticaProposta__c(
            Proposta__c = Qtt.id,
            MomentoAnalise__c = 'Subscrição',
            Status__c = 'Recusado',
            Integracao__c = 'SAMPLE'
        ); 
        insert Ctt;
        
        Test.setMock(HttpCalloutMock.class, 
        	new MockHttpResponse( 
                '{"codigo":0,"mensagem":"Dados inseridos com sucesso."}', 
                    200,'OK'
            )
        );


        IntegracaoAS__mdt task = MetadataDAO.getInstance().buscarDadosIntegracaoAS('163'); 

        Test.startTest(); 
        IntegracaoAS.enviarSubscricao(Qtt, Ctt, task); //PLV-4644 INICIO/FIM
        Test.stopTest();
      
    }
    
    @IsTest
    static void gerarTarefaTeleSubscricaoFail() {
        RamoAtividade__c  ramo = new RamoAtividade__c();
        ramo.Name='teste';
        insert ramo;     
             
        Account acct = TestDataFactory.gerarConta();
        acct.Cpf__c = '395.343.208-70';
       	acct.RamoAtividade__c = ramo.id;
       	update acct;
       	
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Em criação';
        opp.CloseDate = date.today();
        opp.Name = 'teste';
        opp.AccountId = acct.id;
        opp.RecordTypeId = oppVidaEmGrupo;
        insert opp;

        //TKCL-246 FIX05 INICIO
        Product2 produtoTecnicoAp = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnicoAp.Status__c = 'Em ativação';
        produtoTecnicoAp.NumeroSusep__c = '123';
        produtoTecnicoAp.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnicoAp;
        produtoTecnicoAp.Status__c = 'Ativo';
        produtoTecnicoAp.ProductCode = '49';
        produtoTecnicoAp.Segmento__c = 'Individual';
        update produtoTecnicoAp;
        Product2 produtoComercialAp = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnicoAp).createRecord();
        produtoComercialAp.Status__c = 'Ativo';
        produtoComercialAp.ProductCode = 'APTLMKT';
        produtoComercialAp.Segmento__c = 'Individual';
        produtoComercialAp.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercialAp;
        //TKCL-246 FIX05 FIM
   
        Quote Qtt = new Quote(
            OpportunityId = opp.id, 
            Name = 'Teste Quote56', 
            NumeroProposta__c = '356',
            Origem__c = '9',
            status = 'Em análise',
            Produto__c = produtoComercialAp.Id, //TKCL-246 FIX05 INICIO/FIM
            CodigoMotivoDevolucao__c = '18' //II-48 INCIO-FIM
        );
        insert Qtt; 
        
        CriticaProposta__c Ctt = new CriticaProposta__c(
            Proposta__c = Qtt.id,
            MomentoAnalise__c = 'Subscrição',
            Status__c = 'Recusado',
            Integracao__c = 'SAMPLE'
        ); 
        insert Ctt;
        
        Test.setMock(HttpCalloutMock.class, 
        	new MockHttpResponse( 
                '{"codigo":1,"mensagem":"Dados inseridos com sucesso."}', 
                    200,'OK'
            )
        );


        IntegracaoAS__mdt task = MetadataDAO.getInstance().buscarDadosIntegracaoAS('163'); 

        Test.startTest();
        IntegracaoAS.enviarSubscricao(Qtt, Ctt, task); //PLV-4644 INICIO/FIM
        Test.stopTest();
      
    }
    //PLV-4365 FIM
   
    //PLV-4875 INICIO
    @IsTest
    static void executeProposta(){
        //II-42 FIXO1 INICIO
        List<ContratoTO.PayloadTO> payloadList = new List<ContratoTO.PayloadTO>();
        ContratoTO.PayloadTO payload = new ContratoTO.PayloadTO();
        payload.contrato = new ContratoTO();
        
        payload.contrato.segmento = '';
        payload.contrato.meioComercializacao = '';
        //payload.contrato.idSeguradoParceiro = '';
        payload.contrato.codigoEmpresa = '';
        payload.contrato.ramoSeguro = '';
        payload.contrato.vigenciaInicial = '';
        payload.contrato.tipoVigencia = '';
        payload.contrato.origem = 0;
        payload.contrato.tipoSeguro = '';
        payload.contrato.numeroEndosso = 0;
        payload.contrato.canalDistribuicao = '';
        payload.contrato.nomeEmpresa = '';
        payload.contrato.numero = '';
        payload.contrato.codigoSucursal = '';
        payload.contrato.nomeRamoSeguro = '';
        payload.contrato.vigenciaFinal = '';
        payload.contrato.valorPremio = 0.0;
        payload.contrato.idContratoParceiro = '';
        payload.contrato.dataCalculo = '';
        payload.contrato.numeroApolice = 0;
        payload.contrato.nomeProduto = '';
        payload.contrato.codigoProdutoVida = '';
        payload.contrato.parceiro = '';
        payload.contrato.numeroSusepProduto = '';
        payload.contrato.nomeCanalDistribuicao = '';
        
        payload.contrato.geracaoApolice = new ContratoTO.GeracaoapoliceTO();
        payload.contrato.geracaoApolice.unidadeNegocio = '';
        payload.contrato.geracaoApolice.nomeArquivoJasper = '';
        payload.contrato.geracaoApolice.leituraApartir = '';
        payload.contrato.geracaoApolice.centroDeCustoPagador = '';
        payload.contrato.geracaoApolice.tipoExtensaoGerada = '';
        payload.contrato.geracaoApolice.idAplicacaoUtilizadora = '';
        payload.contrato.geracaoApolice.nomeRelatorioGerado = '';
        payload.contrato.geracaoApolice.fileSystem = '';
        payload.contrato.geracaoApolice.nomeDiretorioArquivo = '';
        payload.contrato.geracaoApolice.assinaturaDiretor = '';
        
        payload.contrato.geracaoApolice.arquivo = new ContratoTO.ArquivoTO();
        payload.contrato.geracaoApolice.arquivo.textoInformativo = '';
        payload.contrato.geracaoApolice.arquivo.mensagemAssistenciaFuneral = '';
        payload.contrato.geracaoApolice.arquivo.exibirMensagemRenovacao  = '';
        payload.contrato.geracaoApolice.arquivo.mensagemProcessoSusep  = '';
        payload.contrato.geracaoApolice.arquivo.numeroProcessoSusepCNSP315  = '';
        payload.contrato.geracaoApolice.arquivo.unidadeOperacional  = '';
        
        payload.contrato.geracaoApolice.arquivo.observacoes = new ContratoTO.ObservacoesTO();
        payload.contrato.geracaoApolice.arquivo.observacoes.condicoesGerais = '';
        
        payload.contrato.geracaoApolice.arquivo.cabecalho = new ContratoTO.CabecalhoTO();
        payload.contrato.geracaoApolice.arquivo.cabecalho.image = ''; 
        
        payloadList.add(payload);
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(payloadList), 200, 'OK'));
		//II-42 FIX01 FIM
        Product2 produtoComercial = [SELECT id,Segmento__c  FROM Product2 where Segmento__c = 'Individual' limit 1];
        
        RamoAtividade__c  ramo = new RamoAtividade__c(Name='teste');
        insert ramo;     
        
        Account acct = TestDataFactory.gerarConta();
        acct.RamoAtividade__c = ramo.id;
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        
        Opportunity opp = new Opportunity(
            StageName = 'Em criação',
            CloseDate = date.today(),
            Name = 'teste',
            AccountId = acct.id,
            RecordTypeId = oppVidaEmGrupo
        );
        insert opp;
        
        Quote Qtt = new Quote(
            OpportunityId = opp.id, 
            Name = 'Teste Quote56', 
            NumeroProposta__c = '356',
            Origem__c = '9',
            Produto__c= produtoComercial.id,
            Status = 'Em criação'
        );
        
        
        Test.startTest();
        insert Qtt;
        
        
		ContratanteProposta__c segurado = new ContratanteProposta__c(
			conta__c = acct.Id,
			Proposta__c = Qtt.Id,
			Tipo__c = 'Principal'
		);
		insert segurado;
        
         Qtt.Status = 'Em análise';
         update Qtt;
        
        CriticaProposta__c critica = new CriticaProposta__c(
            Proposta__c = Qtt.Id,
            Status__c = 'Não iniciada',
            Integracao__c = 'DOCUSIGN',
            MomentoAnalise__c = 'Análise interna'
        );
        insert critica;
        
        critica.status__c = 'Pendente';
        update critica;
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetASTaskNumberCriticaProposta(){
        // Map<String, CriticaProposta__c> mpCriticaProposta = new Map<String, CriticaProposta__c>();
        
        CriticaProposta__c docusignNova = new CriticaProposta__c( Integracao__c = 'DOCUSIGN', Status__c = 'Não iniciada', MomentoAnalise__c = 'Análise interna' );        
        CriticaProposta__c docusignNovaRecalculo = new CriticaProposta__c( Integracao__c = 'DOCUSIGN', Status__c = 'Não iniciada', MomentoAnalise__c = 'Recalculo' );        
        CriticaProposta__c docusignRecalculoPendente = new CriticaProposta__c( Integracao__c = 'DOCUSIGN', Status__c = 'Pendente', MomentoAnalise__c = 'Recalculo' );        
        CriticaProposta__c docusignPendente = new CriticaProposta__c( Integracao__c = 'DOCUSIGN', Status__c = 'Pendente', MomentoAnalise__c = 'Análise interna' );
        CriticaProposta__c docusignRecusado = new CriticaProposta__c( Integracao__c = 'DOCUSIGN', Status__c = 'Recusado', MomentoAnalise__c = 'Análise interna' );
        CriticaProposta__c docusignLiberado = new CriticaProposta__c( Integracao__c = 'DOCUSIGN', Status__c = 'Liberado', MomentoAnalise__c = 'Análise interna' );
        
        CriticaProposta__c sampleNova = new CriticaProposta__c( Integracao__c = 'SAMPLE', Status__c = 'Não iniciada' );   
        CriticaProposta__c sampleInconclusiva = new CriticaProposta__c( Integracao__c = 'SAMPLE', Status__c = 'Inconclusiva' );   
        CriticaProposta__c sampleAuto = new CriticaProposta__c( Integracao__c = 'SAMPLE', Status__c = 'Pendente', Acao__c = 'auto' );        
        CriticaProposta__c sampleTele = new CriticaProposta__c( Integracao__c = 'SAMPLE', Status__c = 'Pendente', Acao__c = 'tele' );        
       
        
        Test.startTest();
        
        System.assertEquals('68', IntegracaoAS.getASTaskNumber(docusignPendente, docusignNova));
        System.assertEquals('168', IntegracaoAS.getASTaskNumber(docusignRecusado, docusignNova));
        System.assertEquals('169', IntegracaoAS.getASTaskNumber(docusignLiberado, docusignNova));
        System.assertEquals('57', IntegracaoAS.getASTaskNumber(docusignRecalculoPendente, docusignNovaRecalculo));
        
        System.assertEquals('162', IntegracaoAS.getASTaskNumber(sampleAuto, sampleNova));
        System.assertEquals('163', IntegracaoAS.getASTaskNumber(sampleTele, sampleNova));
        System.assertEquals('84', IntegracaoAS.getASTaskNumber(sampleInconclusiva, sampleNova));
        /*
        
        System.assertEquals('', IntegracaoAS.getASTaskNumber(sampleInconclusiva, null)); 
		*/
        Test.stopTest();
       
       
    }
    
    @IsTest
    static void testGetASTaskNumberProposta(){
        
        Test.startTest();
        
        System.assertEquals(IntegracaoAS.getASTaskNumber(new Quote(Status = 'Em criação'), null), ''); //PLV-5111 - INICIO/FIM
        
        System.assertEquals(IntegracaoAS.getASTaskNumber(new Quote(Status = 'Em análise'), new Quote(Status = 'Em criação')),'84');
        System.assertEquals(IntegracaoAS.getASTaskNumber(new Quote(Status = 'Contratada'), new Quote(Status = 'Em análise')),'117');
        System.assertEquals(IntegracaoAS.getASTaskNumber(new Quote(Status = 'Recusada'), new Quote(Status = 'Em análise')),'115');

        Test.stopTest();
    }
    //PLV-4875 FIM

    // FNPVVEP-16 - INICIO
    @isTest
    static void  testinserirHistoricoCritica(){
        RamoAtividade__c  ramo = new RamoAtividade__c();
        ramo.Name='teste';
        insert ramo;     
             
        Account acct = TestDataFactory.gerarConta();
        acct.Cpf__c = '395.343.208-71';
       	acct.RamoAtividade__c = ramo.id;
       	update acct;
       	
        
        Id  oppVidaEmGrupo  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vida em grupo').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.StageName = 'Em criação';
        opp.CloseDate = date.today();
        opp.Name = 'teste';
        opp.AccountId = acct.id;
        opp.RecordTypeId = oppVidaEmGrupo;
        insert opp;

        Product2 produtoTecnicoAp = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnicoAp.Status__c = 'Em ativação';
        produtoTecnicoAp.NumeroSusep__c = '123';
        produtoTecnicoAp.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnicoAp;
        produtoTecnicoAp.Status__c = 'Ativo';
        produtoTecnicoAp.ProductCode = '49';
        produtoTecnicoAp.Segmento__c = 'Individual';
        update produtoTecnicoAp;
        Product2 produtoComercialAp = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnicoAp).createRecord();
        produtoComercialAp.Status__c = 'Ativo';
        produtoComercialAp.ProductCode = 'APTLMKT';
        produtoComercialAp.Segmento__c = 'Individual';
        produtoComercialAp.CodigoPrecificaProduto__c = 'APTLMKT';
        update produtoComercialAp;
   
        Quote Qtt = new Quote(
            OpportunityId = opp.id, 
            Name = 'Teste Quote56', 
            NumeroProposta__c = '356',
            Origem__c = '9',
            status = 'Em análise',
            Produto__c = produtoComercialAp.Id,
            CodigoMotivoDevolucao__c = '18' 
        );
        insert Qtt; 

        Set<Id> setIdCriticaNew = new Set<Id>();
        
        CriticaProposta__c critica = new CriticaProposta__c(
            Proposta__c = Qtt.Id,
            Status__c = 'Não iniciada',
            Integracao__c = 'DOCUSIGN',
            MomentoAnalise__c = 'Análise interna'
        );
        insert critica;

        Map<Id,String> mapCriticaOldStatus = new Map<Id,String>();
        mapCriticaOldStatus.put(critica.id, critica.Status__c);

        setIdCriticaNew.add(critica.id);
        Test.startTest();
            IntegracaoAS.inserirHistoricoCritica(setIdCriticaNew, mapCriticaOldStatus);
        Test.stopTest();
    }
    // FNPVVEP-16 - FIM
}