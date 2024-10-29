/**
 * @description       : Classe criada para a história PLV-5795
 * @author            : Matheus Meneses,Rogerio Menezes,Veronice Boesing,Romeu Bonfim@
 * @group             : 
 * @last modified on  : 03-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

 @isTest
public class BatchAceleraAFETest {
    @TestSetup
    static void makeData()
    {
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        DadosCorretor__c dadosCorretor = new DadosCorretor__c(
            Name = conta.Name,
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

        Garantia__c garantia2 = new Garantia__c(
            VigenciaInicial__c = System.today(),
            Tipo__c = 'Assistência',
            Sigla__c = 'AFE'
            
        );
        insert garantia2;

        RamoGarantia__c ramoGarantia = new RamoGarantia__c(
            Garantia__c = garantia.Id,
            RamoSeguro__c = ramoSegurado.Id
        );
        insert ramoGarantia;

        RamoGarantia__c ramoGarantia2 = new RamoGarantia__c(
            Garantia__c = garantia2.Id,
            RamoSeguro__c = ramoSegurado.Id
        );
        insert ramoGarantia2;

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

        GarantiaProduto__c garantiaProdutoTec2 = new GarantiaProduto__c(
            TipoGarantia__c = 'Assistência', //PLV-5795 FIX01 INICIO-FIM
            Garantia__c = garantia2.Id,
            Produto__c = produtoTec.Id,
            RamoSeguro__c = ramoSegurado.Id,
            OrdemPrioridade__c = 1,
            TipoPagamento__c = 'Reembolso',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1'
        );
        insert garantiaProdutoTec2;

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

        GarantiaProduto__c garantiaProdutoCom2 = new GarantiaProduto__c(
                Garantia__c = garantia2.Id,
                GarantiaProduto__c = garantiaProdutoTec2.Id,
                Produto__c = produtoCom.Id,
                OrdemPrioridade__c = 1,
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
                TipoGarantia__c = 'Assistência', //PLV-5795 FIX01 INICIO-FIM
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
        insert garantiaProdutoCom2;
        
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
                //Payload__c = EncodingUtil.base64Decode(EncodingUtil.base64Encode(payloadEntrada)).toString()
        );
        insert orcamentoOriginal;

        Modalidade__c modalidade = new Modalidade__c(
                RamoSeguro__c = ramoSegurado.Id,
                Name = 'Mod teste',
                Codigo__c = '0'
        );
        insert modalidade;

        String origem = '18';
        String numeroProposta = '00006767';
        String data = '2023-03-21';
        Quote quote = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                Produto__c = produtoCom.Id,
                RamoSeguro__c = ramoSegurado.Id,
                Status = 'Contratada',
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
                CupomDesconto__c = 'VALE50DESCONTO' 

        );
        insert quote;

        FormaPagamento__c formPag = TestDataFactory.gerarFormaPagamento(ramoSegurado, modalidade, 'CARTAO DE CREDITO (TODAS PARC.EM CARTAO)', '62');

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
            VigenciaFinal__c = System.today().addDays(30),	       		    		    
            StatusRenovacao__c = 'Não Renovado',
            CodigoRamo__c = '1391',
            Produto__c = produtoCom.id,
            ApolicePdfDownloadUrl__c = 'https://MestreChico.com'     
        );
        insert contratoOriginal;

        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1_localStorage'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=contratoOriginal.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        contentlink.LinkedEntityId = orcamentoOriginal.id;
        insert contentlink;

        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(
                CurrencyIsoCode = 'BRL',
                Contrato__c = contratoOriginal.Id,
                Conta__c = conta.Id,
                Tipo__c = 'Principal',
                QuantidadeParcelas__c = 2,
                VencimentoPrimeiraParcela__c = System.today().addDays(20),
                TipoResponsavelPagamento__c = 'PAR',
                IOF__c = 10,
                Logradouro__c = 'Rua xpto',
                NumeroEndereco__c = '55',
                Pais__c = 'Brasil',
                PremioComercial__c = 150,
                PremioPuro__c = 150,
                PremioTotal__c = 300,
                TaxaComercial__c = 0.10,
                TaxaPura__c =  0.10,
                TaxaTotal__c =  0.10,
                TipoEndereco__c = 'Comercial',
                TipoLogradouro__c = 'Rua'
        );
        insert contratanteContrato;

        GrupoContrato__c grupoContrato = new GrupoContrato__c(
                Name = 'Sócio',
                ContratanteContrato__c = contratanteContrato.Id,
                QuantidadeVidas__c = 1
        );
        insert grupoContrato;
 
        SeguradoContrato__c seguradoContrato = new SeguradoContrato__c(
                GrupoContrato__c = grupoContrato.Id,
                Conta__c = conta.Id,
                TipoResponsavelPagamento__c = 'PAR'
        );
        insert seguradoContrato;

        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
                Name = 'COMISSÃO',
                Descricao__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.',
                ModeloRecuperacao__c = 'Integral',
                Codigo__c = 'COM',
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
            Papel__c = 'Corretor'
        );
        insert favRemCon;	

        GarantiaContrato__c garantiaContrato = new GarantiaContrato__c(
                Contrato__c = contratoOriginal.Id,
                GarantiaProduto__c = garantiaProdutoCom.Id,
                Garantia__c = garantiaProdutoCom.Garantia__c,
                TipoCapital__c = 'Capital uniforme',
                VersaoTitulo__c = '1'
        );
        insert garantiaContrato;

        GarantiaContratanteContrato__c garantiaContratanteContrato = new GarantiaContratanteContrato__c(
                Garantia__c = garantia.Id,
                GarantiaProduto__c = garantiaProdutoCom.Id,
                ContratanteContrato__c = contratanteContrato.Id,
                Capital__c = 15000.00,
                PremioTotal__c = 15000.00
                
        );
        insert garantiaContratanteContrato;

        GarantiaGrupoContrato__c garantiaGrupoContrato = new GarantiaGrupoContrato__c(
            GrupoContrato__c =  grupoContrato.Id,
            Garantia__c = garantia.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id,
            Capital__c = 200,
            NumeroSorte__c = '444',
            NumeroSerie__c = '666'
        );        
        insert garantiaGrupoContrato;

        GarantiaSeguradoContrato__c garantiaSeguradoContrato = new GarantiaSeguradoContrato__c(
            Garantia__c = garantia.Id,
            SeguradoContrato__c = seguradoContrato.Id,
            GarantiaProduto__c = garantiaProdutoCom.Id,
            Capital__c = 200,
            NumeroSorte__c = '444',
            NumeroSerie__c = '666'
        );
        insert garantiaSeguradoContrato;

    }

    @isTest
    public static void metodoTest(){
        Product2 produtoCom = [SELECT id FROM Product2 LIMIT 1];

        Garantia__c garantia = [SELECT Id,Sigla__c FROM Garantia__c LIMIT 1];
        system.debug('garantia>>>>>'+ garantia);

        Quote proposta = [SELECT Id, DataProtocolo__c, Status FROM Quote LIMIT 1];
        system.debug('proposta====='+ proposta);

        Contract contrato = [SELECT Id,Segmento__c, Status,PremioTotal__c FROM Contract WHERE Status = 'Emitido' LIMIT 1];        
        system.debug('contrato======'+ contrato);

        Test.startTest();
            BatchAceleraAFE bc = new BatchAceleraAFE();
            Database.executeBatch(bc,100);
        Test.stopTest();
    }
    
    
}