/*******************************************************************************************************************************
* Classe de teste para consulta de extrado de propostas para o Megaday
* @author Squad Globant
* @date 19/07/2021
* Classe criada por conta da história PLV-5068
******************************************************************************************************************************/

@isTest
public class ExtratoPropostaRestTest{
    @testSetup
    static void createData(){

        //Criação da conta
        Account conta = new Account(
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
			LastName = 'Teste',
			Nacionalidade__c = 'Brasileira',
			CPF__c = '00478394659',
			Rg__c = '232323231',
			DataExpedicao__c = Date.today(),
			OrgaoExpedidor__c = '123132',
			PersonBirthDate = (Date.today()-7300),
			EstadoCivil__c = 'Solteiro (a)'
		);
		insert conta;

        ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();

        //Criação da garantia
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        garantiaCobertura.Sigla__c = 'PP';
        garantiaCobertura.Tipo__c = 'Cobertura';
        update garantiaCobertura;
        
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Morte Acidental';
        garantiaCobertura2.Sigla__c = 'DMHO';
        garantiaCobertura2.Tipo__c = 'Cobertura';
        update garantiaCobertura2;

        //Criação do ramo do seguro
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        ramoSeguro.Codigo__c = '1391';
        update ramoSeguro;
        RamoGarantia__c ramoGarantia = (RamoGarantia__c) new RamoGarantiaFactory(garantiaCobertura, ramoSeguro).createRecord();
        RamoGarantia__c ramoGarantia2 = new RamoGarantia__c(
            Garantia__c = garantiaCobertura2.Id,
            RamoSeguro__c = ramoSeguro.Id
        );
        insert ramoGarantia2;

        //Criação da modalidade do ramo
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();

        List<Account> conta1 = [SELECT id FROM Account WHERE LastName = 'Teste'];

        //Criação do produto e suas garantias
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.Segmento__c = 'Viagem';
        update produtoTecnico;

        GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
            Garantia__c = garantiaCobertura2.Id,
            Produto__c = produtoTecnico.Id,
            RamoSeguro__c = ramoSeguro.Id,
            OrdemPrioridade__c = 2,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoTecnico').Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1');
        insert garantiaProduto;

        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        produtoComercial.Segmento__c = 'Viagem';
		update produtoComercial;

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

        GarantiaProduto__c garanProdCom2 =  new GarantiaProduto__c(
            Garantia__c = garantiaCobertura2.Id,
            GarantiaProduto__c = garantiaProduto.Id,
            Produto__c = produtoComercial.Id,
            OrdemPrioridade__c = 2,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id,
            TipoGarantia__c = 'Cobertura',
            TipoCapital__c = 'Capital uniforme',
            RamoSeguro__c = ramoSeguro.Id,
            TipoCaracteristicaEspecial__c = 'Cestas',
            LimiteMaximoCaracteristicaEspecial__c = 1000000001,
            LimiteMinimoCaracteristicaEspecial__c = 10,
            CodigoPromocao__c = 'VITST',
            VersaoTitulo__c = '1',
            Obrigatoria__c = true,
            PrazoMaximoLiquidacao__c = 10,
            TipoPrazoMaximoLiquidacao__c = 'Dia',
            PrazoAvisoSinistro__c = 20,
            TipoPrazoAvisoSinistro__c = 'Ano',
            OrigemSinistroBeneficio__c = 'Acidente',
            LimiteCapitalMinimo__c = 200,
            LimiteCapitalMaximo__c = 900000001,
            currencyIsoCode = 'BRL'
        );        
        insert garanProdCom2;

        GarantiaProduto__c garanProdTec = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoTec(garantiaCobertura, produtoTecnico, ramoSeguro).createRecord();
        GarantiaProduto__c garanProdCom = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura, garanProdTec, ramoSeguro).createRecord();        
        garanProdCom.VigenciaGarantia__c = 'Contratação até fim da apólice';
        update garanProdCom;

        //Criação do orçamento
        Opportunity oportunidade = new Opportunity(
			Name = 'Teste Contrato',
			StageName = 'Em criação',
			RecordTypeId = RecordTypeBO.buscarTipoRegistro('Opportunity', 'VidaIndividual').Id,
			AccountId = conta.Id,
			CloseDate = Date.today()
		);
		insert oportunidade;

        //Criação da proposta
        Quote proposta = new Quote(
			Name= 'Teste Contrato',
			OpportunityId = oportunidade.Id,
			DataProtocolo__c = Date.today(),    //PLV- 5068 - FIX01 - INICIO/FIM
			Empresa__c = conta.Id,
			ExpirationDate = Date.today(),
            RamoSeguro__c = ramoSeguro.Id,
            PremioTotal__c = 1000,
            Produto__c = produtoComercial.Id //TKCL-246 FIX05 INICIO/FIM
		);
		insert proposta;

        //Criação da garantia da proposta
        GarantiaProposta__c garantiaProposta = new GarantiaProposta__c(
                Proposta__c = proposta.Id,
                GarantiaProduto__c = garantiaProduto.Id,
                Garantia__c = garantiaProduto.Garantia__c,
                TipoCapital__c = 'Capital uniforme'

        );

        insert garantiaProposta;

        //Criação do segurado
        ContratanteProposta__c segurado = new ContratanteProposta__c(
			conta__c = conta.Id,
			Proposta__c = proposta.Id,
			Tipo__c = 'Principal'
		);
		insert segurado;

        
        //Criação do grupo
        GrupoProposta__c grupo = new GrupoProposta__c(
			Name = 'Teste',
			QuantidadeVidas__c = 1,
			ContratanteProposta__c = segurado.Id
		);
		insert grupo;

        //Segurado
        SeguradoProposta__c vida = new SeguradoProposta__c(
			Conta__c = conta.Id,
			GrupoProposta__c = grupo.Id
		);
		insert vida;
        
        //Criação do beneficiario do segurado
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

        BeneficiarioSeguradoProposta__c beneficiario2 = new BeneficiarioSeguradoProposta__c(
			SeguradoProposta__c = vida.Id,
			CpfCnpj__c = '99235310075',
			Nome__c = 'Teste Contrato',
			TipoBeneficiario__c = 'Nome do beneficiário',
			GrauParentesco__c = 'Pai',
			Participacao__c = 100,
			Pep__c = 'Não'
		);
        insert beneficiario2;
        
        //Conta Parceiro
        Account contaParceiro = new Account(Name = 'ParceiroTeste', CodigoEmpresa__c = '12', IdExterno__c = '67708896000139', Inscricao_Municipal__c = '123456789', Cnpj__c = '67.708.896/0001-39'); // PLV-4445
        insert contaParceiro;
        FormaPagamento__c formaPagamento2 = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro  = TestDataFactory.gerarParceiro(contaParceiro,formaPagamento2);

        //Criação do corretor
        Account contaCorretor = new Account(Name = 'ContaCorretor', Papel__c = 'Corretor', IdExterno__c = '38012786532', Cnpj__c = '38.579.897/0001-22');       
        insert contaCorretor;                   
        
        Account contaCorretorTest = [SELECT Id,Name FROM Account  WHERE Papel__c = 'Corretor' LIMIT 1];
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaCorretorTest);
        InformacaoBancaria__c informacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaCorretorTest);
        InformacaoBancaria__c informacaoBancariaParceiro = TestDataFactory.gerarInformacaoBancaria(contaParceiro);
        informacaoBancariaParceiro.Principal__c = true;
        update informacaoBancariaParceiro;

        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);

        TipoRemuneracao__c tipoRemuneracao = new TipoRemuneracao__c(
            Name = 'CORRETAGEM',
            Codigo__c = 'COR',
            LimiteMinimo__c = 0,
            LimiteMaximo__c = 100
        );		
		insert tipoRemuneracao;

        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro = new RemuneracaoProdutoParceiro__c(
                Percentual__c = 20,
                TipoRemuneracao__c = tipoRemuneracao.Id,
                ProdutoParceiro__c = produtoParceiro.Id
        );
        insert remuneracaoProdutoParceiro;

        FavorecidoRemuneracao__c favorecidoRemuneracao = new FavorecidoRemuneracao__c(
            Conta__c = contaCorretorTest.Id,
            Percentual__c = 80.00,
            Papel__c = 'Corretor',
            Lider__c = true,            
            DadosCorretor__c = (dadosCorretor != null) ? dadosCorretor.Id : null,
            RemuneracaoProdutoParceiro__c = remuneracaoProdutoParceiro.Id,
            InformacaoBancaria__c = informacaoBancaria.Id
        );
        insert favorecidoRemuneracao;

        RemuneracaoProposta__c remuneracao = new RemuneracaoProposta__c (Proposta__c = proposta.Id, tipoRemuneracao__c = tipoRemuneracao.Id);
        insert remuneracao;
        insert new FavorecidoRemuneracaoProposta__c (RemuneracaoProposta__c = remuneracao.Id, Conta__c = contaCorretor.Id);
    }
       
    @isTest
    static void consultaExtratoProposta_Success(){   
        String requestBody = '{'
        + '"inicio": "' + String.valueOf(System.today()) + '",'
        + '"fim": "' + String.valueOf(System.today()) + '",'
        + '"coberturas": ["DMHO", "AFI", "AFF", "PP"],' 
        + '"ramos": ["1391", "1381"]'
        + '}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        Test.startTest();
        ExtratoPropostaREST.ResponseTO result = ExtratoPropostaREST.consultaExtratoProposta();
        Test.stopTest();
        //PLV-5200 - INICIO
        //Quote proposta = [SELECT Id, Name, PremioTotal__c FROM Quote LIMIT 1];
        //System.assertEquals(result.data.propostas[0].premio, proposta.PremioTotal__c);
        //PLV-5200 - FIM
    }
    @isTest
    static void consultaExtratoProposta_Fail(){   
        String requestBody = '{}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        Test.startTest();
        ExtratoPropostaREST.ResponseTO result = ExtratoPropostaREST.consultaExtratoProposta();
        Test.stopTest();
    }
}