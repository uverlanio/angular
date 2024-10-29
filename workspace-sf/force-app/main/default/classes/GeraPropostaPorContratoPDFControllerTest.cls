@isTest
global with sharing class GeraPropostaPorContratoPDFControllerTest {
    
    
    @testSetup static void setup(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();  
        //PLV-5231- INICIO
        conta.TipoDocidentificacao__c = 'rg'; 
        update conta;

        //PLV-5231- FIM      
        Endereco__c enderecoResidencial = (Endereco__c) TestDataFactory.gerarEndereco(conta);
        enderecoResidencial.TipoEndereco__c = 'Residencial';
        update enderecoResidencial;
        
        Endereco__c enderecoComercial = (Endereco__c) TestDataFactory.gerarEndereco(conta);
        enderecoComercial.TipoEndereco__c = 'Comercial';
        update enderecoComercial;
        
        ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.Segmento__c = 'Individual';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.Segmento__c = 'Individual';
        update produtoComercial;
        
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor1 = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Modalidade__c modalidade1 = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    

        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();

        Parceiro__c parceiro = new Parceiro__c(
            Status__c = 'Ativo',
            Sucursal__c = '1',
            Ramo__c = '1391',
            Empresa__c = '1',
            Conta__c = conta.Id,
            FormaPagamento__c = formaPagamento.Id,
            DiaFaturamento__c = '15',
            DiaPreFaturamento__c = '20',
            PrazoVencimento__c = '10',
            FaturaProdutosSeparados__c = 'Sim',
            PossuiAnexoFatura__c = 'Nao',
            SiglaParceiro__c = 'PAR'
        );
        insert parceiro;
        
        Contract contract = new Contract(
            Name = 'teste',
            AccountId = conta.Id,
            Produto__c = produtoComercial.Id,
            Parceria__c = parceiro.Id,
            CodigoRamo__c = '1369'
        );
        insert contract;

        RemuneracaoContrato__c remuneracao = new RemuneracaoContrato__c (Contrato__c = contract.Id);
        insert remuneracao;
        FavorecidoRemuneracaoContrato__c favRem = new FavorecidoRemuneracaoContrato__c();
        favRem.RemuneracaoContrato__c  = remuneracao.Id;
        favRem.Conta__c = conta.Id;
        insert favRem;
        //PLV-4425 - INICIO
        ContratanteContrato__c contratante1 = new ContratanteContrato__c(
            Contrato__c = contract.Id
        );
        insert contratante1;

        GrupoContrato__c grupo1 = new GrupoContrato__c(
            Name = 'Paulo',
            ContratanteContrato__c = contratante1.Id
        );
        insert grupo1;

        SeguradoContrato__c seguradoP = new SeguradoContrato__c(
            GrupoContrato__c = grupo1.Id
        );
        insert seguradoP;

        BeneficiarioSeguradoContrato__c beneficiario = new BeneficiarioSeguradoContrato__c(
            TipoBeneficiario__c = 'Nome do beneficiário',
            Nome__c = 'FRANCIS LIU',
            CpfCnpj__c = '518.179.180-87',
            Data_de_nascimento__c = system.today(),
            GrauParentesco__c = 'Amigo (a)',
            Participacao__c = 100,
            SeguradoContrato__c = seguradoP.Id
        );
        insert beneficiario;

        
        List<String> lstGarantiaSigla = new List<String>{'DG', 'DIT', 'BAS', 'MAP', 'IPA'};
        List<Garantia__c> lstGarantias = new List<Garantia__c>();
        List<GarantiaContrato__c> lstGarantiasContract = new List<GarantiaContrato__c>();
        
        for(String garantiaSigla : lstGarantiaSigla){
            Garantia__c garantia = new Garantia__c(
                Name        = 'garantia' + garantiaSigla,
                Sigla__c    = garantiaSigla
            );
            lstGarantias.add(garantia);
        }
        
        insert lstGarantias;
        
        for(Garantia__c garantia : lstGarantias){
            GarantiaContrato__c garantiaProposta = new GarantiaContrato__c(
                Contrato__c = contract.id,
                Garantia__c = garantia.id,
                Capital__c = 100000
            );

            lstGarantiasContract.add(garantiaProposta);
        }
        
        insert lstGarantiasContract;

        //Sys - NumeroPropostaUnico__c
        Account contaTeste = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '518.179.180-87',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert contaTeste;

        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c= 'Versão atual'
        );
        insert produtoTec;
        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = new Product2(
            ProdutoTecnico__c = produtoTec.Id,
            Name = 'Nome Produto Comercial',
            Status__c = 'Em criação',
            ProductCode = '201700001',            	
            VigenciaInicial__c = System.today(),
            VigenciaFinal__c = System.today().addDays(1),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            LimiteTotalCarregamento__c = 200,
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c = 'Versão atual'
        );
        insert produtoCom;

        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity orcamentoContratado = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);
        
        String origem = '18';
        String numeroProposta = '00006767';

        Quote proposta = new Quote(
                Name = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
                NumeroPropostaUnico__c = QuoteBO.getInstance().gerarNameProposta(origem,numeroProposta),
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
                MeioComercializacao__c = 'PMC', 
                OpportunityId = orcamentoContratado.Id,
                Origem__c = origem,
                Modalidade__c = modalidade.Id,
                NumeroProposta__c = numeroProposta,
                Parceiro__c = '67708896000139',
                CupomDesconto__c = 'VALE50DESCONTO'

        );
        insert proposta;

        System.debug('proposta ==>' + JSON.serialize(proposta));

        RemuneracaoProposta__c corretagem = new RemuneracaoProposta__c(
            Proposta__c = proposta.Id,
            Percentual__c = 10            
        );
        insert corretagem;

        RemuneracaoProposta__c agenciamento = new RemuneracaoProposta__c(
            Proposta__c = proposta.Id,
            Percentual__c = 100            
        );
        insert agenciamento;

        FavorecidoRemuneracaoProposta__c favorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c(
            Conta__c = contaTeste.Id,           
            CorretorLider__c = true,
            Papel__c = 'Corretor',
            Participacao__c = 10.00,
            RemuneracaoProposta__c = corretagem.Id,
            Susep__c = 'REN01J',
            SusepEmissao__c = 'REN01J',
            SusepOficialCorretor__c = '123',
            SusepOrcamento__c = 'REN01J',
            AntecipacaoComissao__c = true,
            DadosCorretor__c = dadosCorretor.Id
        );

        insert favorecidoRemuneracaoProposta;
        //II-167 FIM

        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contract, contaTeste, contaTeste);

        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);

        Garantia__c garantia = TestDataFactory.gerarGarantia();

        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);

        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoSegurado);
        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia, garantiaTecnica, ramoSegurado);
        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contract, garantiaComercial);




        ContratanteProposta__c contratante = new ContratanteProposta__c(
            Proposta__c = proposta.id,
            FormaPagamento__c = formaPagamento.Id,
            ResponsavelPagamento__c = contaTeste.Id,
            QuantidadeParcelas__c = 2            
        );
        insert contratante;
 
         GrupoProposta__c grupo = new GrupoProposta__c(
             ContratanteProposta__c = contratante.id
         );
         insert grupo;
 
        CondicaoCobranca__c condicaoCobranca = new CondicaoCobranca__c(
                Produto__c = produtoCom.Id,
                FormaPagamento__c = formaPagamento.Id,
                QuantidadeParcelas__c = '1;2;3;4;5;6;7;8;9;10',            	
                PercentualDescontoAgravo__c = 0            	
        );
        insert condicaoCobranca;

        SeguradoProposta__c SeguradoProposta = new SeguradoProposta__c(
            Conta__c = contaTeste.Id,
            GrupoProposta__c = grupo.Id,            
            ResponsavelPagamento__c = contaTeste.Id,
            FormaPagamento__c = formaPagamento.Id,
            PremioTotal__c = 10,
            Renda__c = 4000,
            Nome_do_segurado__c = contaTeste.Name,
            TemDependentes__c = true,
            RegimeTrabalho__c = 'CLT',
            FaixaRenda__c = '20000',
            EnderecoBoleto__c = 'http://www.google.com.br',
            PremioComercial__c = 10,
            IOF__c = 1,
            Numero__c = 1
        );
        insert SeguradoProposta;   
    
     }     


        
    @IsTest
    static void testContract(){
        Contract contract = [SELECT Id, Name, NumeroPropostaUnico__c FROM Contract LIMIT 1];
        
        Test.StartTest();
        PageReference pageRef = Page.PropostaSeguroViagem;
        pageRef.getParameters().put('numPropostaUnico', String.valueOf(contract.NumeroPropostaUnico__c));
        Test.setCurrentPage(pageRef);
        new GeraPropostaPorContratoPDFController();
        Test.stopTest();
    }
    
    @IsTest
    static void testInvalidContract(){
        Contract contract = [SELECT Id, Name, NumeroPropostaUnico__c FROM Contract];
        List<Product2> products = [SELECT Segmento__c from Product2];
        for(Product2 product:products){
            product.Segmento__c = 'Viagem';
            Update product;
        }
        
        Test.StartTest();
        PageReference pageRef = Page.PropostaSeguroViagem;
        pageRef.getParameters().put('numProposta', String.valueOf(contract.NumeroPropostaUnico__c));
        Test.setCurrentPage(pageRef);
        try{
            new GeraPropostaPorContratoPDFController();
        } catch(Exception e){
            System.assertEquals('Número de proposta inválido.' + contract + '  ', e.getMessage()); //PLV-5231 - INICIO/FIM
        }
        Test.stopTest();
    }
}