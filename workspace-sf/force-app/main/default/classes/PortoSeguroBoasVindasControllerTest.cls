//INICIO | PLV-4433-VI (Digital)
/*
*  @author Squad Avanxo 
*  @Descrição: Classe de Teste Controller PortoSeguroBoasVindas
*/
@IsTest
public class PortoSeguroBoasVindasControllerTest {

    @TestSetup
    public static void setup(){
        
        TestDataFactory.gerarDadosSetup();
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c(Name = 'Senha', Senha__c = 'TesteCrypto');
        insert sCripto;
        
        Account contaTeste = TestDataFactory.gerarConta();
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Invalidez Permanente Total';
        update garantiaCobertura;
        
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Morte';
        update garantiaCobertura2;
        
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c ='Individual';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='Ativo';
        produtoCom.Segmento__c ='Individual';        
        update produtoCom;
        
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);       
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao);        
        
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura,opp);
        garantiaOrcamento.PremioTotal__c=100;
        update garantiaOrcamento;
        
        GarantiaOrcamento__c garantiaOrcamento2 = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura2,opp);   
        
        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('COR', 100, 200, null);
        InformacaoBancaria__c InformacaoBancaria = TestDataFactory.gerarInformacaoBancaria(contaTeste);
        RemuneracaoProdutoParceiro__c RemuneracaoProdutoParceiro = TestDataFactory.gerarRemuneracaoProdutoParceiro(tipoRemuneracao, produtoParceiro, 20);
        FavorecidoRemuneracao__c favorecidoRemuneracao = TestDataFactory.gerarFavorecidoRemuneracao(contaTeste, 20.00, 'Corretor', true, remuneracaoProdutoParceiro,dadosCorretor, informacaoBancaria);        
        
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c(
            Conta__c = contaTeste.Id,
            CorretorLider__c = TRUE,
            RemuneracaoContrato__c = remuneracaoContrato.Id,
            Susep__c = 'p5005j',
            SusepEmissao__c = 'p5005j',
            SusepOrcamento__c= 'p5005j',
            DadosCorretor__c = dadosCorretor.Id,
            Papel__c = 'Corretor',
            Participacao__c = 100
        );
        insert favorecidoRemuneracaoContrato;
    }

    @IsTest
    public static void NumeroContrato_Success(){
        Contract contrato = [SELECT Id, Name FROM Contract];

        PageReference pageRef = Page.PortoSeguroBoasVindas;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('numeroContrato', contrato.Name);
        
        Test.startTest();
            PortoSeguroBoasVindasController controller = new PortoSeguroBoasVindasController();
        Test.stopTest();
        
        System.assertEquals(contrato.Id, controller.contrato.Id);
        System.assertEquals(controller.corretor != NULL, true);
        System.assertEquals(string.isBlank(controller.errorMessage), true);
    }

    @IsTest
    public static void NumeroContrato_Error(){
        
        PageReference pageRef = Page.PortoSeguroBoasVindas;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('numeroContrato', '1234');
        
        Test.startTest();
            PortoSeguroBoasVindasController controller = new PortoSeguroBoasVindasController();
        Test.stopTest();
        
        System.assertEquals(controller.contrato == NULL, true);
        System.assertEquals(controller.corretor == NULL, true);
        System.assertEquals(controller.errorMessage, 'Número de contrato inválido');
    }

    @IsTest
    public static void Token_Success(){
        Contract contrato = [SELECT Id, Name FROM Contract];
        
        CryptoToken cryptoToken = new CryptoToken();      
        String token = cryptoToken.encrypt(contrato.Id+'|boasVindas');

        PageReference pageRef = Page.PortoSeguroBoasVindas;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('token', token);
        
        Test.startTest();
            PortoSeguroBoasVindasController controller = new PortoSeguroBoasVindasController();
        Test.stopTest();
        
        System.assertEquals(contrato.Id, controller.contrato.Id);
        System.assertEquals(controller.corretor != NULL, true);
        System.assertEquals(string.isBlank(controller.errorMessage), true);
    }

    @IsTest
    public static void Token_Error(){
        
        CryptoToken cryptoToken = new CryptoToken();      
        String token = cryptoToken.encrypt('contrato.Id'+'|boasVindas');

        PageReference pageRef = Page.PortoSeguroBoasVindas;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('token', token);
        
        Test.startTest();
            PortoSeguroBoasVindasController controller = new PortoSeguroBoasVindasController();
        Test.stopTest();
        
        System.assertEquals(controller.contrato == NULL, true);
        System.assertEquals(controller.corretor == NULL, true);
        System.assertEquals(controller.errorMessage, 'Token inválido');
    }
}
//FIM | PLV-4433-VI (Digital)