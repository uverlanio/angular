/**
 * @description       : Testar funcionalidade da classe AtualizaPropOrcamentoCtr que é utilizada no BatchAtualizaPropostaOrcamento - RVI-265
 * @author            : Kevin Vogado e Matheus Meneses (GLOBANT)
 * @last modified on  : 14-04-2023
 * @last modified by  : Kevin Vogado e Matheus Meneses
**/
@isTest
public class BatchAtualizaPropostaOrcamentoTest {

    @TestSetup
    static void makeData(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        DadosCorretor__c dadosCorretor = new DadosCorretor__c(
            Name = 'REN01J',
            NomeCorretor__c = conta.Id
        );
        insert dadosCorretor;

        RamoSeguro__c ramoSegurado = new RamoSeguro__c(
            Name = 'Segurado',
            CodigoEmpresa__c = '1',
            Codigo__c = '2',
            IdExterno__c = '1' + '_3',
            Empresa__c = conta.Id,
            Status__c = 'Ativo',
            CodigoOrigemDoMovimentoBCP__c = '32'
        );
        insert ramoSegurado;

        Garantia__c garantia = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Cobertura',
            Sigla__c = 'AFF'
            
        );
        insert garantia;

        RamoGarantia__c ramoGarantia = new RamoGarantia__c(
            Garantia__c = garantia.Id,
            RamoSeguro__c = ramoSegurado.Id
        );
        insert ramoGarantia;
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Individual',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c                       = 1,
            VersaoMaxima__c                 = true,
            VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoTec;

        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = new Product2 (
            ProdutoTecnico__c               = produtoTec.Id,
            Name                            = 'VIAGEM_VIDA_ON',
            Status__c                       = 'Em criação',
            ProductCode                     = 'VI-PESSOAS',   
            VigenciaInicial__c              = System.today(),
            VigenciaFinal__c                = System.today().addDays(1),
            TipoCapital__c                  = 'Capital uniforme',
            Segmento__c                     = 'Individual',
            TipoResponsavelPagamento__c     = 'SEG',
            LimiteTotalCarregamento__c      = 200,
            NumeroSusep__c                  = '15414.900476/2015-42',
            RecordTypeId                    = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c                       = 1,
            VersaoMaxima__c                 = true,
            VersaoRenovacao__c              = 'Versão atual'
        );
        insert produtoCom;

        produtoCom.Status__c = 'Ativo';
        update produtoCom;

        GarantiaProduto__c garantiaProdutoTec = new GarantiaProduto__c(
            TipoGarantia__c = 'Cobertura',
            Garantia__c = garantia.Id,
            Produto__c = produtoTec.Id,
            RamoSeguro__c = ramoSegurado.Id,
            OrdemPrioridade__c = 1,
            TipoPagamento__c = 'Reembolso',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );
        insert garantiaProdutoTec;

        GarantiaProduto__c garantiaProdutoCom = new GarantiaProduto__c(
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoTec.Id,
            Produto__c = produtoCom.Id,
            OrdemPrioridade__c = 1,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            RamoSeguro__c = ramoSegurado.Id,
            TipoPagamento__c = 'Reembolso',
            TipoCaracteristicaEspecial__c = 'Cestas',
            LimiteMaximoCaracteristicaEspecial__c = 100,
            LimiteMinimoCaracteristicaEspecial__c = 10,
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1',
            CurrencyIsoCode = 'BRL',
            LimiteCapitalMinimo__c = 100,
            LimiteCapitalMaximo__c = 1000, 
            Obrigatoria__c = true
        );
        insert garantiaProdutoCom;

        Modalidade__c modalidade = new Modalidade__c(
                RamoSeguro__c = ramoSegurado.Id,
                Name = 'Mod teste',
                Codigo__c = '0'
        );
        insert modalidade;

        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c(
            Name = 'Canal Distribuição Teste 001',
            Status__c = 'Em criação',
            Sigla__c = 'EXE'
        );
        insert canalDistribuicao;

        Opportunity orcamentoOriginal = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-00006769',
            CloseDate = System.today().addDays(20),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            Produto__c = produtoCom.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
            AccountId = conta.Id,
            Numero__c = '00006769',
            CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert orcamentoOriginal;

        Opportunity orcamentoRenovado = new Opportunity(
            StageName = 'Em criação',
            CurrencyIsoCode = 'BRL',
            Name = 'ARQ-00006790',
            CloseDate = System.today().addDays(20),
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            Produto__c = produtoCom.Id,
            Probability = 10.0,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaGrupo').Id,
            AccountId = conta.Id,
            Numero__c = '00006790',
            CanalDistribuicao__c = canalDistribuicao.Id
        );
        insert orcamentoRenovado;

        String origem = '18';
        String numeroProposta = '00006767';
        String data = '2023-03-21';
        Quote quote = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em análise',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = conta.Id,
            CodigoCorretor__c = dadosCorretor.Id,
            DataCalculo__c = System.today(),
            DataProtocolo__c = Date.valueOf(data),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoOriginal.Id,
            Origem__c = origem,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta,
            Parceiro__c = '67708896000139',
            CupomDesconto__c = 'VALE50DESCONTO',
            Tipo__c = 'Renovacao'
        );
        insert quote;

        Date dataRenovacaoMinus15Days = Date.today().addDays(-15);
        Contract contratoOriginal = new Contract(
            AlteraFormaPagto__c = false,
            AccountId = conta.Id,
            Oportunidade__c = orcamentoOriginal.Id,
            Origem__c = '18',
            NumeroProposta__c = '00006767',
            NumeroApolice__c = '000014419',
            Tipo__c = 'Novo',
            Status = 'Emitido',
            Endosso__c = '0',
            Proposta__c = quote.Id,
            PremioTotal__c = 1300.00,
            VigenciaFinal__c = dataRenovacaoMinus15Days,	       		    		    
            StatusRenovacao__c = 'Não Renovado',
            CodigoRamo__c = '1391',
            DataRenovacao__c = dataRenovacaoMinus15Days,
            CodigoCorretor__c = dadosCorretor.id,
            Produto__c = produtoCom.id,
            ApolicePdfDownloadUrl__c = 'https://MestreChico.com'     
        );
        insert contratoOriginal;

        String origem1 = '19';
        String numeroProposta1 = '00006069';

        Quote quoteRenovada = new Quote(
            Name = QuoteBO.getInstance().gerarNameProposta(origem1,numeroProposta1),
            NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem1,numeroProposta1),
            Produto__c = produtoCom.Id,
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em análise',
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addMonths(1),
            Empresa__c = conta.Id,
            CodigoCorretor__c = dadosCorretor.Id,
            DataCalculo__c = System.today(),
            DataProtocolo__c = Date.valueOf(data),
            DataCriacaoPortal__c = System.today(),
            TipoVigencia__c = 'Anual',
            MeioComercializacao__c = 'PMC', 
            OpportunityId = orcamentoOriginal.Id,
            Origem__c = origem,
            Modalidade__c = modalidade.Id,
            NumeroProposta__c = numeroProposta,
            Parceiro__c = '67708896000139',
            CupomDesconto__c = 'VALE50DESCONTO',
            Tipo__c = 'Renovacao',
            ContratoRenovado__c = contratoOriginal.id
        );
        insert quoteRenovada;

        Contract contratoRenovado = new Contract(
            Oportunidade__c = orcamentoRenovado.Id,
            Produto__c = produtoCom.Id,        
            RamoSeguro__c = ramoSegurado.Id,
            Status = 'Em elaboração' ,
            Empresa__c = '22',
            CodigoCorretor__c = dadosCorretor.Id,
            Proposta__c = quote.Id,
            AccountId = conta.Id,
            AlteraFormaPagto__c = false,
            Name = contratoOriginal.Empresa__c + '-' + contratoOriginal.Sucursal__c  + '-' + contratoOriginal.CodigoRamo__c + '-' + contratoOriginal.NumeroApolice__c + '-1',       
            PrimeiroContratoRenovacao__c = contratoOriginal.Id,		
            NumeroPropostaUnico__c = '18-00001911',
            NumeroApolice__c = '000014419',
            Tipo__c = 'Renovacao',
            Endosso__c = '1',
            VigenciaFinal__c = System.today().addDays(366),		       		    		    
            StatusRenovacao__c = 'Não Renovado', 
            CodigoRamo__c = '1391',   
            ApolicePdfDownloadUrl__c = 'https://MestreChico.com'
        );
        insert contratoRenovado;

        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
            Name = 'CORRETAGEM',
            Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
            ModeloRecuperacao__c = 'Integral',
            Codigo__c = 'COR',
            LimiteMinimo__c = 10,
            LimiteMaximo__c = 50
        );
        insert tipoRemuneracao;

        RemuneracaoContrato__c remuneracaoContrato = new RemuneracaoContrato__c(
            Contrato__c = contratoOriginal.Id,
            TipoRemuneracao__c = tipoRemuneracao.Id,
            CurrencyIsoCode = 'BRL',
            Percentual__c = 10,
            Porcentagem_de_Retencao__c = 0
        );
        insert remuneracaoContrato;

        FavorecidoRemuneracaoContrato__c favRemCon = new FavorecidoRemuneracaoContrato__c(
            Conta__c = conta.Id,
            CorretorLider__c = true,
            AntecipacaoComissao__c = true,
            RemuneracaoContrato__c = remuneracaoContrato.Id,
            Papel__c = 'Corretor',
            Susep__c = 'REN01J'
        );
        insert favRemCon;

        RemuneracaoProposta__c remuneracaoProposta = new RemuneracaoProposta__c(            
            TipoRemuneracao__c = tipoRemuneracao.Id,                    
            Porcentagem_de_Retencao__c = 10.00,
            Percentual__c = 10.00,
            Proposta__c = quote.Id
        );

        insert remuneracaoProposta;

        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
            Conta__c = conta.Id,           
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 10.00,
            RemuneracaoProposta__c = remuneracaoProposta.Id,
            Susep__c = 'REN01J',
            SusepEmissao__c = 'REN01J',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'REN01J',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );

        insert favorecidoRemuneracaoProposta;

        RemuneracaoProposta__c remuneracaoProposta2 = new RemuneracaoProposta__c(            
            TipoRemuneracao__c = tipoRemuneracao.Id,                    
            Porcentagem_de_Retencao__c = 10.00,
            Percentual__c = 10.00,
            Proposta__c = quoteRenovada.Id
        );

        insert remuneracaoProposta2;

        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta2 = new FavorecidoRemuneracaoProposta__c(
            Conta__c = conta.Id,           
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 10.00,
            RemuneracaoProposta__c = remuneracaoProposta2.Id,
            Susep__c = 'REN01J',
            SusepEmissao__c = 'REN01J',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'REN01J',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );

        insert favorecidoRemuneracaoProposta2;

        TransferenciaCorretagem__c transCorre = new TransferenciaCorretagem__c(
            SusepAtual__c = dadosCorretor.id,
            ContratoTransferido__c = contratoOriginal.id,
            PercSusepLider__c = 100,
            SusepOriginal__c = dadosCorretor.id,
            ValidoAte__c = System.today()
        );
        insert transCorre;

        TransferenciaCorretagem__c transCorre2 = new TransferenciaCorretagem__c(
            SusepAtual__c = dadosCorretor.id,
            PercSusepLider__c = 100,
            SusepOriginal__c = dadosCorretor.id,
            ValidoAte__c = System.today(),
            TransferirCarteira__c = true
        );
        insert transCorre2;

        CriticaProposta__c criticaProposta = new CriticaProposta__c(
            Proposta__c = quote.Id,        
            Status__c = 'Pendente',
            Tipo__c = 'Analise'     
        );
        insert criticaProposta;
        
        CriticaProposta__c criticaProposta2 = new CriticaProposta__c(
            Proposta__c = quoteRenovada.Id,   
            Status__c = 'Pendente',
            Tipo__c = 'Analise'    
        );
        insert criticaProposta2;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 

        ContentVersion content= new ContentVersion(
            Title='Header_Picture1_localStorage',
            PathOnClient='/Header_Picture1_localStorage.jpg',
            VersionData=bodyBlob,
            origin = 'H'
        ); 
        insert content;
        
        ContentDocumentLink contentlink = new ContentDocumentLink(
            LinkedEntityId = quoteRenovada.id,
            contentdocumentid = [SELECT contentdocumentid FROM contentversion WHERE Id =: content.id].contentdocumentid,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert contentlink;
    }

    @isTest
    public static void TranferirCarteiraFalse(){
        List<EnviaEmailCliente.FlowInputs> requestIds = New List<EnviaEmailCliente.FlowInputs>();

        DadosCorretor__c dados = [SELECT id,Name FROM DadosCorretor__c LIMIT 1];

        Quote proposta = [SELECT id,ContratoRenovado__c FROM Quote limit 1];

        Contract contrato = [SELECT id,DataRenovacao__c,VigenciaFinal__c FROM Contract LIMIT 1];
        
        Product2 produtoCom = [SELECT id FROM Product2 LIMIT 1];

        CriticaProposta__c critica = [SELECT id FROM CriticaProposta__c LIMIT 1];

        TransferenciaCorretagem__c transf = [SELECT id,SusepAtual__c,ContratoTransferido__c,SusepOriginal__c FROM TransferenciaCorretagem__c limit 1];

        Test.startTest();
        BatchAtualizaPropostaOrcamento bc = new BatchAtualizaPropostaOrcamento();
        Database.executeBatch(bc);
        Test.stopTest();
    }

    @isTest
    public static void TranferirCarteiraTrue(){
        
        DadosCorretor__c dados = [SELECT id,Name FROM DadosCorretor__c LIMIT 1];

        Quote proposta = [SELECT id FROM Quote limit 1];

        Contract contrato = [SELECT id,DataRenovacao__c,VigenciaFinal__c FROM Contract LIMIT 1];

        Product2 produtoCom = [SELECT id FROM Product2 LIMIT 1];

        TransferenciaCorretagem__c tranf = [SELECT id,SusepAtual__c,ContratoTransferido__c,SusepOriginal__c,TransferirCarteira__c 
                                            FROM TransferenciaCorretagem__c 
                                            WHERE TransferirCarteira__c = true LIMIT 1];

        Test.startTest();
        BatchAtualizaPropostaOrcamento bc = new BatchAtualizaPropostaOrcamento();
        Database.executeBatch(bc);
        Test.stopTest();
    }

    @isTest
    public static void TestScheduler(){
        
        DadosCorretor__c dados = [SELECT id,Name FROM DadosCorretor__c LIMIT 1];

        Contract contrato = [SELECT id,DataRenovacao__c,VigenciaFinal__c FROM Contract LIMIT 1];

        Product2 produtoCom = [SELECT id FROM Product2 LIMIT 1];

        TransferenciaCorretagem__c tranf = [SELECT id,SusepAtual__c,ContratoTransferido__c,SusepOriginal__c,TransferirCarteira__c 
                                            FROM TransferenciaCorretagem__c 
                                            WHERE TransferirCarteira__c = true LIMIT 1];

        Test.startTest();
        BatchAtualizaPropostaOrcamento bc = new BatchAtualizaPropostaOrcamento();
        bc.scheduleBatch();
        Test.stopTest();

        List<CronTrigger> jobList = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'BatchAtualizaPropostaOrcamento'];
        System.assertEquals(1, jobList.size());
        System.assertEquals('0 0 5 * * ?', jobList[0].CronExpression);
    }
}