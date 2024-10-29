// PLV-4998 - INÍCIO
@istest
public class BatchExpurgoPropostasTest 
{
    @testSetup
    static void setup() 
    {
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
        
        Opportunity orcamentoNaoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        GarantiaOrcamento__c garantiaOrcamentoNC = TestDataFactory.gerarGarantiaOrcamento(garantia1, orcamentoNaoContratado);   
        RemuneracaoOrcamento__c remuneracaoOrcamentoNC = TestDataFactory.gerarRemuneracaoOrcamento(orcamentoNaoContratado, tipoRemuneracao);
        ContratanteOrcamento__c contratanteOrcamentoNC = TestDataFactory.gerarContratanteOrcamento(orcamentoNaoContratado, contaTeste);
        GrupoOrcamento__c grupoOrcamentoNC = TestDataFactory.gerarGrupoOrcamento(contratanteOrcamentoNC);
        SeguradoOrcamento__c seguradoOrcamentoNC = TestDataFactory.gerarSeguradoOrcamento(grupoOrcamentoNC);
        Attachment anexoNC = new Attachment();   	
    	anexoNC.Name ='Unit Test Attachment';
    	Blob bodyBlobNC = Blob.valueOf('Unit Test Attachment Body');
    	anexoNC.body = bodyBlobNC;
        anexoNC.parentId = orcamentoNaoContratado.id;
        insert anexoNC;

        //Quote propostaNC = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, orcamentoNaoContratado, modalidade);
        Quote propostaNC = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta('18','00324367'),
            // PLV-2312-28 INICIO
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta('18','00324367'),
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
            NumeroProposta__c = '00324367',
            Parceiro__c = '67708896000139'        
        );
        insert propostaNC;
        GarantiaProposta__c garantiaPropostaNC = TestDataFactory.gerarGarantiaProposta(propostaNC, garantiaProdutoTec);
        RemuneracaoProposta__c remuneracaoPropostaNC = TestDataFactory.gerarRemuneracaoProposta(propostaNC, tipoRemuneracao);
        ContratanteProposta__c contratantePropostaNC = TestDataFactory.gerarContratanteProposta(contaTeste, propostaNC, formaPagamento);
        GrupoProposta__c grupoPropostaNC = TestDataFactory.gerarGrupoProposta(contratantePropostaNC);
        SeguradoProposta__c seguradoPropostaNC = TestDataFactory.gerarSeguradoProposta(contaTeste, grupoPropostaNC, formaPagamento);
        BeneficiarioSeguradoProposta__c beneficiarioSeguradoPropostaNC = TestDataFactory.gerarBeneficiarioSeguradoProposta(contaTeste, seguradoPropostaNC);
        Attachment anexoPropostaNC = new Attachment();   	
    	anexoPropostaNC.Name='Unit Test Attachment';
        Blob bodyBlobPropostaNC = Blob.valueOf('Unit Test Attachment Body');
    	anexoPropostaNC.body=bodyBlobPropostaNC;
        anexoPropostaNC.parentId=propostaNC.id;
        insert anexoPropostaNC;
    }

    @IsTest
    static void expurgoContratadosTest()
    {
        
        List<Contract> contratadosAntesExclusao = [SELECT Id, CreatedDate, Proposta__c FROM Contract WHERE Proposta__c != NULL AND Proposta__r.QuantidadeGarantias__c > 0];
        
        for(Contract contrato : contratadosAntesExclusao)
        {
            Test.setCreatedDate(contrato.Id, Datetime.newInstance(2015,1,1));
        }
        
        Test.startTest();
        BatchExpurgoPropostas batchPropostas = new BatchExpurgoPropostas(1);
        Database.executeBatch(batchPropostas, 100);     
        Test.stopTest();
        
        List<Contract> contratadosAposExclusao = [SELECT Proposta__c FROM Contract WHERE CreatedDate < LAST_N_YEARS:2 AND Proposta__c != NULL AND Proposta__r.QuantidadeGarantias__c > 0];
        System.assertEquals(0, contratadosAposExclusao.size(), 'Falha no expurgo de Propotas Contratadas!');
    }
    
    @IsTest
    static void expurgoNaoContratadosTest()
    {
        List<Quote> naoContratadosAntesExclusao = [SELECT Id, CreatedDate FROM Quote WHERE Status NOT IN ('Contratada','Em análise') AND QuantidadeGarantias__c > 0];
        
        for(Quote naoContratado : naoContratadosAntesExclusao)
        {
            Test.setCreatedDate(naoContratado.Id, Datetime.newInstance(2015,1,1));
        }

        Test.startTest(); 
        BatchExpurgoPropostas batchPropostas = new BatchExpurgoPropostas(2);
        Database.executeBatch(batchPropostas, 100);
        Test.stopTest();
        
        List<Quote> naoContratadosAposExclusao = [SELECT Id FROM Quote WHERE CreatedDate < LAST_N_YEARS:1 AND Status NOT IN ('Contratada','Em análise') AND QuantidadeGarantias__c > 0];
        System.assertEquals(0, naoContratadosAposExclusao.size(), 'Falha no expurgo de Propostas Não Contratadas!');
    }

    @IsTest
    static void agendarExpurgoTest()
    {
        Test.startTest();
        System.schedule('BatchExpurgoPropostas: Expurgo de Propostas Contratadas > 9 horas', '0 0 9 * * ?', new BatchExpurgoPropostas(1));
        System.schedule('BatchExpurgoPropostas: Expurgo de Propostas Não Contratadas > 9 horas','0 0 9 * * ?', new BatchExpurgoPropostas(2));
        Test.stopTest();
    }
}
// PLV-4998 - FIM