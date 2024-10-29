@isTest
public class IntegracaoOpinTest {

    @testSetup
	private static void setup() {

        //Configurações OPIN
        insert new ConfiguracoesOPIN__c(Name = 'routing_key', Conteudo__c = 'opin.seg_vida');
        insert new ConfiguracoesOPIN__c(Name = 'content_type', Conteudo__c = 'application/json');
        insert new ConfiguracoesOPIN__c(Name = 'payload_encoding', Conteudo__c = 'string');

        TestDataFactory.gerarDadosSetup();

        gerarDadosProdutoCompleto();
        
        Product2 prod = [SELECT Id, Status__c, Segmento__c FROM Product2 WHERE RecordType.DeveloperName  = 'ProdutoComercial' LIMIT 1];
        prod.Status__c ='Ativo';
        prod.Segmento__c ='Individual';        
        update prod;    

        CatalogoOPIN__c catO = new CatalogoOPIN__c(
            Name = 'PADRAOTESTE',
            Versao__c = 1,
            Ativo__c = true
        );
        insert catO;
        
        ProdutoOPIN__c prodO = new ProdutoOPIN__c(
            Name = prod.id,
            SiglaProduto__c = 'PROD1',
            SistemaOrigem__c = 'SALESFORCE',
            DetalhesJson__c = '{"code":"PROD1"}'
        );
        insert prodO;
      
	}

    private static void gerarDadosProdutoCompleto() {

        Account contaParceiro = new Account(Name = 'ParceiroTeste', IdExterno__c = '74586138825',  Cnpj__c = '38.579.897/0001-22');
        insert contaParceiro;

        Account contaCorretor = new Account(Name = 'ContaCorretor', Papel__c = 'Corretor', IdExterno__c = '38012786532', Cnpj__c = '08.370.609/0001-64' );
        insert contaCorretor;


        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__c parceiro = TestDataFactory.gerarParceiro(contaParceiro,formaPagamento);
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        Account contaTeste = TestDataFactory.gerarConta();        
        RamoSeguro__c ramoVida = TestDataFactory.gerarRamoSeguro(contaTeste);
        ParametroVigencia__c paramVigencia = TestDataFactory.gerarParametroVigenciaProdutoTecnico(produtoTec);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao();
        RemuneracaoProduto__c remuneracaoProduto = TestDataFactory.gerarRemuneracaoProduto(produtoTec, tipoRemuneracao);
        Modalidade__c modalidade1 = TestDataFactory.gerarModalidade(ramoVida);
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoVida);
        GarantiaProduto__c garantiaProdutoTec = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
        GarantiaProduto__c garantiaProdutoTec2 = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoVida);
        garantiaProdutoTec.TipoPagamento__c = 'Reembolso';
        garantiaProdutoTec.TipoPagamento__c = 'Reembolso';
        update garantiaProdutoTec;
        update garantiaProdutoTec2;

        Carencia__c carencia = new Carencia__c(
            Name = 'Carencia 1'
        );
        insert carencia;

        CarenciaGarantia__c carenciaGarantiaTec = new CarenciaGarantia__c(
            GarantiaProduto__c = garantiaProdutoTec.Id,
            Carencia__c = carencia.Id,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoTecnico').Id
        );
        insert carenciaGarantiaTec;
        
        Franquia__c franquia = new Franquia__c(
            Name = 'Franquia 1'
        );
        insert franquia;

        FranquiaGarantia__c franquiaGarantiaTec = new FranquiaGarantia__c(
            GarantiaProduto__c = garantiaProdutoTec.Id,
            Franquia__c = franquia.Id,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoTecnico').Id
        );
        insert franquiaGarantiaTec;
                
        produtoTec.Status__c = 'Em ativação';
        produtoTec.NumeroSusep__c = '1234';
        update produtoTec;

        produtoTec.Status__c = 'Ativo';
        update produtoTec;
        
        Product2 produtoComercial = TestDataFactory.gerarProdutoComericial(produtoTec);
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        ParametroVigencia__c paramVigenciaComercial = TestDataFactory.gerarParametroVigenciaProdutoComercial(produtoComercial);
        FaixaDevolucao__c faixa = TestDataFactory.gerarFaixaDevolucaoProdutoComercial(paramVigenciaComercial);
        GarantiaProduto__c garantiaProdutoCom = TestDataFactory.gerarGarantiaProdutoComercial(produtoComercial, garantia, garantiaProdutoTec, ramoVida);
        GarantiaProduto__c garantiaProdutoCom2 = TestDataFactory.gerarGarantiaProdutoComercial(produtoComercial, garantia, garantiaProdutoTec, ramoVida);

        garantiaProdutoCom.TipoPagamento__c = 'Reembolso';
        garantiaProdutoCom2.TipoPagamento__c = 'Reembolso';
        update garantiaProdutoCom;
        update garantiaProdutoCom2;

        Territorio__c territorioGarantia = TestDataFactory.gerarTerritorioGarantiaComercial(garantiaProdutoCom);
        territorioGarantia.Produto__c = produtoComercial.Id;
        
        update territorioGarantia;
        
        RemuneracaoProduto__c remuneracaoProdutoComercial = TestDataFactory.gerarRemuneracaoProduto(produtoComercial, tipoRemuneracao);
        
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        RemuneracaoProdutoParceiro__c remuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 100);
        remuneracaoProdutoParceiro.RemuneracaoProduto__c = remuneracaoProdutoComercial.Id;
        
        update remuneracaoProdutoParceiro;
        
        GarantiaRelacionada__c garantiaRelTest = (GarantiaRelacionada__c) new GarantiaRelacionadaFactory.ProdutoTecnico(garantiaProdutoTec, garantiaProdutoTec2).createRecord();
        GarantiaRelacionada__c garantiaRelTest2 = (GarantiaRelacionada__c) new GarantiaRelacionadaFactory.ProdutoComercial(garantiaProdutoCom, garantiaProdutoCom2).createRecord();

        garantiaRelTest.TipoDependencia__c = 'Includente';
        update garantiaRelTest;

        garantiaRelTest2.TipoDependencia__c = 'Includente';
        update garantiaRelTest2;

        PremioMinimoProduto__c premioMinimoCom = TestDataFactory.gerarPremioMinimoProdutoComercial(produtoComercial, formaPagamento);        
            
        
        Risco__c risco = new Risco__c(
            Name = 'Risco 1'
        );
        insert risco;

        RiscoGarantia__c riscoGarantiaCom = new RiscoGarantia__c(
            GarantiaProduto__c = garantiaProdutoCom.Id,
            Risco__c = risco.Id,
            PermiteAlterarProdutoComercial__c = false,
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('RiscoGarantia__c', 'ProdutoComercial').Id
        );
        insert riscoGarantiaCom;
        
        GrupoRisco__c grupoRisco = new GrupoRisco__c();
        insert grupoRisco;
        
        GrupoRiscoGarantia__c grupoRiscoGarantiaCom = new GrupoRiscoGarantia__c(
            GarantiaProduto__c = garantiaProdutoCom.Id,
            GrupoRisco__c = grupoRisco.Id
        );
        insert grupoRiscoGarantiaCom;
        
        
        Carencia__c carencia2 = new Carencia__c(
            Name = 'Carencia 2'
        );
        insert carencia2;

        CarenciaGarantia__c carenciaGarantiaComercial = new CarenciaGarantia__c(
            GarantiaProduto__c = garantiaProdutoCom.Id,
            Carencia__c = carencia2.Id,
            CarenciaGarantia__c = carenciaGarantiaTec.Id, 
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('CarenciaGarantia__c', 'ProdutoComercial').Id
        );
        insert carenciaGarantiaComercial;
        
        Franquia__c franquia2 = new Franquia__c(
            Name = 'Franquia 2'
        );
        insert franquia2;

        FranquiaGarantia__c franquiaGarantiaComercial = new FranquiaGarantia__c(
            GarantiaProduto__c = garantiaProdutoCom.Id,
            Franquia__c = franquia2.Id,
            FranquiaGarantia__c = franquiaGarantiaTec.Id, 
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('FranquiaGarantia__c', 'ProdutoComercial').Id
        );
        insert franquiaGarantiaComercial;

        CondicaoCobranca__c condicaoCobranca = TestDataFactory.gerarCondicaoCobranca(produtoComercial,formaPagamento);
        
    }

    private static void SetarMockSuccess() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'PayloadEnvioOPIN' LIMIT 1];
        String payload = sr.Body.toString();        
        String jsonSuccess = '{"routed":true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonSuccess, 200, 'OK'));
    }

    @isTest
    private static void VerificarExecucaoOK_Test() {

        Product2 produtoTeste = [SELECT Id, Status__c, RecordTypeId  FROM Product2 WHERE Segmento__c = 'Individual' LIMIT 1];

        Test.startTest();
        
        SetarMockSuccess();
        IntegracaoOpin.getInstance().executar(produtoTeste);
        ProdutoIntegracaoOpin__c produtoIntegracaoOpin = ProdutoIntegracaoOpinDAO.getInstance().buscarProdutoIntegracaoOpin(produtoTeste.id);

        Test.stopTest();

        System.assert(produtoIntegracaoOpin.id <> null); //Se registro criado, então integração concluída ok
    }

    @isTest
    private static void VerificarExecucaoSemMudancaUltima_Test() {

        Product2 produtoTeste = [SELECT Id, Status__c, RecordTypeId  FROM Product2 WHERE Segmento__c = 'Individual' LIMIT 1];

        Test.startTest();

        SetarMockSuccess();
        
        //Executa integração 1a vez
        IntegracaoOpin.getInstance().executar(produtoTeste);
        ProdutoIntegracaoOpin__c produtoIntegracaoOpin1 = ProdutoIntegracaoOpinDAO.getInstance().buscarProdutoIntegracaoOpin(produtoTeste.id);

        //Executa integração 2a vez, sem mudança nos dados (processo deve ser abortado)
        IntegracaoOpin.getInstance().executar(produtoTeste);
        ProdutoIntegracaoOpin__c produtoIntegracaoOpin2 = ProdutoIntegracaoOpinDAO.getInstance().buscarProdutoIntegracaoOpin(produtoTeste.id);

        Test.stopTest();

        //Datas devem ser igual, caso contrário houve o envio da integração indevida na 2a execução
        System.assertEquals(produtoIntegracaoOpin1.Data_Ultima_Integracao__c, produtoIntegracaoOpin2.Data_Ultima_Integracao__c) ; 
    } 

    @isTest
    private static void VerificarExecucaoComMudanca_Test() {

        Product2 produtoTeste = [SELECT Id, Status__c, RecordTypeId, NumeroSusep__c  FROM Product2 WHERE Segmento__c = 'Individual' LIMIT 1];

        //Executa integração 1a vez
        ProdutoIntegracaoOpin__c produtoIntegracaoOpin1 = new ProdutoIntegracaoOpin__c(
            Dados_Ultima_Integracao__c = 'Json de TESTE',
            Data_Ultima_Integracao__c = Datetime.now(),
            Produto__c = produtoTeste.id
        );
        insert produtoIntegracaoOpin1;

        //Atualiza informação que entra no payload do OPIN
        produtoTeste.NumeroSusep__c = produtoTeste.NumeroSusep__c + '2';
        update produtoTeste;

        Test.startTest();

        SetarMockSuccess();
        
        //Executa integração 2a vez, com mudança nos dados (dados devem ser transmitidos)
        IntegracaoOpin.getInstance().executar(produtoTeste);
        ProdutoIntegracaoOpin__c produtoIntegracaoOpin2 = ProdutoIntegracaoOpinDAO.getInstance().buscarProdutoIntegracaoOpin(produtoTeste.id);

        Test.stopTest();

        //Datas devem ser diferentes, caso contrário não houve a transmissão do OPIN
        System.assertNotEquals(produtoIntegracaoOpin1.Dados_Ultima_Integracao__c, produtoIntegracaoOpin2.Dados_Ultima_Integracao__c);
        
    }      
    
    @isTest
    private static void VerificarDeparaOpinNaoEncontrado_Test() {

        IntegracaoOpinDeparaBO depara = IntegracaoOpinDeparaBO.getInstance();

        Test.startTest();

        String retorno = depara.consultar('DEPARA_INEXISTENTE', 'NADA');
        List<String> retornoLista = depara.consultarLista('DEPARA_INEXISTENTE2', 'NADA2');

        List<String> deparaNaoEncontrado = depara.consultarDeparasNaoEncontrados();        

        Test.stopTest();

        System.assertEquals(2, deparaNaoEncontrado.size(), 'Depara incorreto não adicionado na lista.');

    }

    @isTest
    private static void GerarCatalogoOpinExecucaoOK_Test() {

        Test.startTest();
        
        SetarMockSuccess();

        CatalogoOPINController.gerarBaseProdutosOpin();

        Test.stopTest();

        //Verifica há produto Opin no catálogo
        ProdutoOPIN__c prodO = [SELECT ID, Name FROM ProdutoOPIN__c LIMIT 1];
        System.assert(prodO <> null, 'Produto Opin não gerado.'); 
    }

    @isTest
    private static void GerarCatalogoOpinExecucaoOKBaseVazia_Test() {

        //Remove o produtoOpin incluido pelo Setup
        ProdutoOPIN__c prodO = [SELECT ID, Name FROM ProdutoOPIN__c LIMIT 1];
        delete prodO;

        Test.startTest();
        
        SetarMockSuccess();

        CatalogoOPINController.gerarBaseProdutosOpin();

        Test.stopTest();

        //Verifica há produto Opin no catálogo
        ProdutoOPIN__c prodtest = [SELECT ID, Name FROM ProdutoOPIN__c LIMIT 1];
        System.assert(prodtest <> null, 'Produto Opin não gerado.'); 
    }

    @isTest
    private static void GerarCatalogoOpinExecucaoErro_Test() {

        ProdutoOPIN__c prodO = [SELECT ID, Name FROM ProdutoOPIN__c LIMIT 1];
        prodO.Name = 'PROD1SALESFORCE'; //Causará o erro ao tentar associar a um Id dentro da rotina
        update prodO;

        Test.startTest();
        
        SetarMockSuccess();

        String ret = CatalogoOPINController.gerarBaseProdutosOpin();

        Test.stopTest();

        RetornoAcaoBotaoTO retB = new RetornoAcaoBotaoTO();
        retB.mensagens.add(CatalogoOPINController.MSG_SUCESSOGERACAO);
        retB.tipo = RetornoAcaoBotaoTO.SUCCESS;

        System.assertNotEquals(JSON.serialize(retB), ret, 'Geração deveria gerar Erro.'); 
    }

    @isTest
    private static void EnviarCatalogoOpinExecucaoOK_Test() {

        CatalogoOPINController.gerarBaseProdutosOpin();

        Test.startTest();
        
        SetarMockSuccess();
        
        String ret = CatalogoOPINController.transmitirBaseProdutosOpin();

        Test.stopTest();

        RetornoAcaoBotaoTO retB = new RetornoAcaoBotaoTO();
        retB.mensagens.add(CatalogoOPINController.MSG_SUCESSOTRANSMISSAO);
        retB.tipo = RetornoAcaoBotaoTO.SUCCESS;
        System.assertEquals(JSON.serialize(retB), ret, 'Teste de Trasmissão sem sucesso.'); 
    }

    @isTest
    private static void EnviarCatalogoOpinExecucaoErro_Test() {

        List<Product2> prods = [SELECT Id, Status__c, RecordTypeId  FROM Product2 WHERE Segmento__c = 'Individual'];
        for (Product2 prod:prods) {
            prod.Status__c = 'Inativo';
        }
        update prods;

        Test.startTest();
        
        SetarMockSuccess();
        
        String ret = CatalogoOPINController.transmitirBaseProdutosOpin();

        Test.stopTest();

        RetornoAcaoBotaoTO retB = new RetornoAcaoBotaoTO();
        retB.mensagens.add(CatalogoOPINController.MSG_SUCESSOTRANSMISSAO);
        retB.tipo = RetornoAcaoBotaoTO.SUCCESS;
        System.assertNotEquals(JSON.serialize(retB), ret, 'Transmissão deveria gerar Erro.'); 
    }
}