//II-154 INICIO
@isTest
public class GarantiaContratoDAOTest {

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
            Name                            = 'VIDA_INDIVIDUAL_VP',
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
        
        CanalDistribuicao__c canalDistribuicao = new CanalDistribuicao__c(
            Name = 'Canal Distribuição Teste 001',
            Status__c = 'Em criação',
            Sigla__c = 'EXE'
        );
        insert canalDistribuicao;

        Opportunity orcamento = new Opportunity(
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
        insert orcamento;

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
                OpportunityId = orcamento.Id,
                Origem__c = origem,
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = numeroProposta,
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO' 

        );
        insert quote;

        Contract contrato = new Contract(
            AlteraFormaPagto__c = false,
            AccountId = conta.Id,
            Oportunidade__c = orcamento.Id,
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
        insert contrato;
    

        GarantiaContrato__c garantiaContrato = new GarantiaContrato__c(
                Contrato__c = contrato.Id,
                GarantiaProduto__c = garantiaProdutoCom.Id,
                Garantia__c = garantiaProdutoCom.Garantia__c,
                TipoCapital__c = 'Capital uniforme',
                VersaoTitulo__c = '1'
        );
        insert garantiaContrato;
    }

    @isTest
    static void BuscarGarantiasContratoPorContratoTest() {    
        Contract contrato = [SELECT Id, Name FROM Contract];
        List<String> contratos = new List<String>();
        contratos.add(contrato.Name);
        Test.startTest();
        List<GarantiaContrato__c> result = GarantiaContratoDAO.getInstance().buscarGarantiasContratoPorContrato(contratos);
        Test.stopTest();
    } 
}
//II-154 FIM