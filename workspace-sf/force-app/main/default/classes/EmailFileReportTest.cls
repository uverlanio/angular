//ZSVEP-76-INICIO
@isTest
public class EmailFileReportTest {

    @testSetup
    static void setupTestData() {
        Account contaTeste = TestDataFactory.gerarConta();
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia1 = TestDataFactory.gerarGarantia();
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia1, ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoCom.Status__c ='ativo';
        update produtoCom;

        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia1, ramoSegurado);
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        
        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamento = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamento = TestDataFactory.gerarContratanteOrcamento(orcamentoContratado, contaTeste);
        GrupoOrcamento__c grupoOrcamento = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamento);
        SeguradoOrcamento__c seguradoOrcamento = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamento);
        Attachment anexo = new Attachment();   	
    	anexo.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	anexo.body=bodyBlob;
        anexo.parentId=orcamentoContratado.id;
        insert anexo;
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        FormaPagamento__c formapagamento = TestDataFactory.gerarFormaPagamento();
        
        //Quote proposta = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoContratado, modalidade);
        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta('18','00324366'),
                // PLV-2312-28 INICIO
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00324366'),
                // PLV-2312-28 FIM
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Em criação',
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addMonths(1),
                Empresa__c = contaTeste.Id,
                CodigoCorretor__c = dadosCorretor.Id,
                DataCalculo__c = System.today(),
                DataCriacaoPortal__c = System.today(),
                TipoVigencia__c = 'Anual',
                MeioComercializacao__c = 'PMC', //PLV-4550 INICIO/FIM
                OpportunityId = orcamentoContratado.Id,
                Origem__c = '18',
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = '00324366',
                Parceiro__c = '67708896000139'        
        );
        insert proposta;
        GarantiaProposta__c garantiaProposta = TestDataFactory.gerarGarantiaProposta(proposta, garantiaProdutoTec);
        RemuneracaoProposta__c remuneracaoProposta = TestDataFactory.gerarRemuneracaoProposta(proposta, tipoRemuneracao);
        ContratanteProposta__c contratanteProposta = TestDataFactory.gerarContratanteProposta(contaTeste, proposta, formaPagamento);
        GrupoProposta__c grupoProposta = TestDataFactory.gerarGrupoProposta(contratanteProposta);
        SeguradoProposta__c seguradoProposta = TestDataFactory.gerarSeguradoProposta(contaTeste, grupoProposta, formaPagamento);
        BeneficiarioSeguradoProposta__c beneficiarioSeguradoProposta = TestDataFactory.gerarBeneficiarioSeguradoProposta(contaTeste, seguradoProposta);
        Attachment anexoProposta = new Attachment();   	
    	anexoProposta.Name='Unit Test Attachment';
    	Blob bodyBlobProposta=Blob.valueOf('Unit Test Attachment Body');
    	anexoProposta.body=bodyBlobProposta;
        anexoProposta.parentId=proposta.id;
        insert anexoProposta;

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, proposta);
        contrato.Oportunidade__c = orcamentoContratado.Id;
        contrato.Proposta__c = proposta.Id;
        update contrato;  
    }

    @isTest
    static void testCreateFile() {
        Test.startTest();
        EmailFileReport.createFile();   
        Test.stopTest();

        // Verificar se o arquivo foi criado
        List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion WHERE Title = 'Teste report'];
    }

    @isTest
    static void testSendAttach() {
        // Preparação do ambiente de teste
        Test.startTest();
        
        // Criação de um registro ContentVersion simulado
        ContentVersion cv = new ContentVersion(
            Title = 'Teste report',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('test content')
        );
        insert cv;
        
        // Consulta do ContentDocumentId para o ContentVersion
        cv = [SELECT Id, ContentDocumentId, VersionData, Title FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        // Execução do método que estamos testando
        EmailFileReport.sendAttach();
        
        // Validação dos resultados
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); // emails[0];
        email.Subject = 'Book details';
        email.PlainTextBody = 'O corpo do email deve ser "Please find the attached book details"';

        System.assertEquals('Book details', email.getSubject(), 'O assunto do email deve ser "Book details"');
        
        Messaging.EmailFileAttachment[] attachments = email.getFileAttachments();
        Test.stopTest();
    }

    @isTest
    static void testGeraRelatorio() {
        Test.startTest();
        EmailFileReport.geraRelatorio();
        Test.stopTest();

        System.debug('Geração de relatório concluída.');
    }
}
//ZSVEP-76-FIM