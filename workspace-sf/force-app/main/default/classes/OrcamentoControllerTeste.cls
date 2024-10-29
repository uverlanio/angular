//INICIO | PLV-4261-4262-VIAGEM 
/*
*  @author Squad Avanxo 
*  @Descrição: ControllerTest OrcamentoPage
*/
@IsTest
public class OrcamentoControllerTeste {
    
    @TestSetup
    static void setup()
    {
        
        TestDataFactory.gerarDadosSetup();        
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
        
        Account contaTeste = TestDataFactory.gerarConta();
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(contaTeste);
        Garantia__c garantia = TestDataFactory.gerarGarantia();
        
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Produto Porto';
        update garantiaCobertura;
        //VIAG-253 INICIO - KAYMON
		//Garantia__c geraGarantias = TestDataFactory.gerarGarantias();
        GarantiaProduto__c geraGarantiaProduto = TestDataFactory.gerarGarantiaProdutoTecnicoViagem();
        //VIAG-253 FIM - KAYMON
        //INICIO | PLV-4301-4302-Vida 
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Incapacidade Temporária';
        update garantiaCobertura2;        
        //FIM | PLV-4301-4302-Vida
        
        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);
        Product2 produtoTec = TestDataFactory.gerarProdutoTecnico();
        produtoTec.Status__c = 'Ativo';
        produtoTec.Segmento__c ='Viagem';
        update produtoTec;
        
        Product2 produtoCom = TestDataFactory.gerarProdutoComericial(produtoTec);
        Map<String,List<SObject>> mapListSObject = TestDataFactory.gerarProdutoComercialAtivo(false);
        produtoCom.Status__c ='Ativo';
        produtoCom.Segmento__c ='Viagem';   
        produtoCom.ProductCode = 'VIAGEM-PRATA'; //AV-86 INICIO/FIM
        produtoCom.NumeroSusep__c = '15414.900476/2015-42'; //AV-86 INICIO/FIM
        update produtoCom;
        
        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;
        ProdutoCanal__c produtoCanal = TestDataFactory.gerarProdutoCanal(canalDistribuicao, produtoCom);
        FormaPagamento__c formaPagamento = TestDataFactory.gerarFormaPagamento();
        Parceiro__C parceiro = TestDataFactory.gerarParceiro(contaTeste, formaPagamento);
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoCom);       
        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(contaTeste, produtoCom, canalDistribuicao); 
        opp.CupomDesconto__c = 'CupomValido';
        update opp;
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura,opp);
        //INICIO | PLV-4301-4302-Vida 
        garantiaOrcamento.Capital__c=null;
        update garantiaOrcamento;
        GarantiaOrcamento__c garantiaOrcamento2 = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura2,opp);
        //FIM | PLV-4301-4302-Vida

    }
    
    //VIAG-174 INICIO
    @IsTest
    static void TestPass()
    {
        Opportunity opp = [select id, Numero__c from Opportunity]; 
        
        PageReference pageRef = Page.OrcamentoPage; 
        pageRef.getParameters().put('numeroOrcamento', opp.Numero__c);
        
        Test.setCurrentPage(pageRef);        
        orcamentoController apc = new orcamentoController();
    }
    //VIAG-174 FIM
    
    //INICIO | PLV-4301-4302-Vida 
    @IsTest
    static void TestPassGarantia()
    {        
        Opportunity opp = [select id, Numero__c, CupomDesconto__c from Opportunity];
        Garantia__c garantiaCobertura = TestDataFactory.gerarGarantia();
        garantiaCobertura.name = 'Incapacidade';
        update garantiaCobertura;
        GarantiaOrcamento__c garantiaOrcamento = TestDataFactory.gerarGarantiaOrcamento(garantiaCobertura,opp);
        
        PageReference pageRef = Page.OrcamentoPage; 
        system.debug('testess>> '+opp);
        system.debug('testess>> '+opp.Numero__c);
        pageRef.getParameters().put('numeroOrcamento', opp.Numero__c);
        
        Test.setCurrentPage(pageRef);        
        orcamentoController apc = new orcamentoController();
        
        
    }
    //FIM | PLV-4301-4302-Vida
    
    //VIAG-174 INICIO
    @IsTest
    static void TestParcelamentoPDF() {
        PageReference pageRef = Page.OrcamentoPage; 
        String json = '[{"opcao":0,"qtdParcelas":1,"valorPrimeiraParcela":"30.02","valorDemaisParcelas":null},{"opcao":0,"qtdParcelas":5,"valorPrimeiraParcela":"15.01","valorDemaisParcelas":"15.01"},{"opcao":0,"qtdParcelas":3,"valorPrimeiraParcela":"10.02","valorDemaisParcelas":"10.00"},{"opcao":0,"qtdParcelas":9,"valorPrimeiraParcela":"10.02","valorDemaisParcelas":"10.00"},{"opcao":0,"qtdParcelas":10,"valorPrimeiraParcela":"10.02","valorDemaisParcelas":"10.00"},{"opcao":1,"qtdParcelas":1,"valorPrimeiraParcela":"7.52","valorDemaisParcelas":"7.50"},{"opcao":1,"qtdParcelas":2,"valorPrimeiraParcela":"7.52","valorDemaisParcelas":"7.50"},{"opcao":1,"qtdParcelas":5,"valorPrimeiraParcela":"7.52","valorDemaisParcelas":"7.50"},{"opcao":1,"qtdParcelas":9,"valorPrimeiraParcela":"7.52","valorDemaisParcelas":"7.50"}]';
        pageRef.getParameters().put('parcelamentoPDF', json);
        
        Test.setCurrentPage(pageRef);        
        orcamentoController apc = new orcamentoController();
    }
    //VIAG-174 FIM

    //VIAG-241 INICIO
    @IsTest
    static void TestCoberturasPDF() {
        PageReference pageRef = Page.OrcamentoPage; 
        String json = '[{"orcamento":"00136505","rotulo":"Brasil terra - OK","selecionado":false,"premioTotal":33.52,"coberturas":[{"sigla":"PVB","name":"name of PVB sigla here","moeda":"BRL","selecionado":false,"valor":null,"valorFormatado":0},{"sigla":"RS","name":"name of RS sigla here","moeda":"BRL","selecionado":false,"valor":null,"valorFormatado":0}]},{"orcamento":"00136506","rotulo":"Brasil Ouro","selecionado":true,"premioTotal":204.46,"coberturas":[{"sigla":"DMHO","name":"Despesas Médicas, Hospitalares e Odontológicas","moeda":"BRL","selecionado":true,"valor":30000,"valorFormatado":"30.000,00"},{"sigla":"MAP","name":"name of MAP sigla here","moeda":"BRL","selecionado":true,"valor":100000,"valorFormatado":"100.000,00"}]}]';
        pageRef.getParameters().put('coberturasPDF', json);
        
        Test.setCurrentPage(pageRef);        
        orcamentoController apc = new orcamentoController();
    }
    //VIAG-241 FIM

    //VIAG-253 INICIO
    @IsTest
    static void TestMoedaNomePDF() {
        orcamentoController apc = new orcamentoController();
        Test.startTest(); 
        System.assertEquals('Dólar', apc.obterMoedaNome('USD'));
        System.assertEquals('Euro', apc.obterMoedaNome('EUR'));        
        System.assertEquals('Real', apc.obterMoedaNome('BRL'));        
        System.assertEquals('', apc.obterMoedaNome('XXX'));        
        Test.stopTest();
    }
    
    @IsTest
    static void TestTrataValoresValores() {
        String moeda = 'USD', moeda2 = 'EUR', valor = '100.00';
        Test.startTest();
        System.assertEquals('100,00', OrcamentoController.trataValores(valor, moeda));
        System.assertEquals('100,00', OrcamentoController.trataValores(valor, moeda2));
        Test.stopTest();
    }
    //VIAG-253 FIM

    @IsTest
    static void TestToken()
    {
        Opportunity opp = [select id, Produto__r.Segmento__c, Numero__c, CupomDesconto__c from Opportunity];
        CryptoToken c = new CryptoToken();      
        String cri = c.encrypt(opp.id+'|abc');
        system.debug('cri '+cri);
        
        PageReference pageRef2 = Page.OrcamentoPage; 
        pageRef2.getParameters().put('token',cri);
        //pageRef.getParameters().put('id','');
        
        Test.setCurrentPage(pageRef2);        
        orcamentoController apc2 = new orcamentoController();
        
    }
    
    //INICIO | PLV-4301-4302-Vida 
    @IsTest
    static void TestError()
    {
        
        Product2 produtoTec =[select id, Segmento__c from Product2 where Name ='Nome Produto Tecnico' limit 1];
        produtoTec.Segmento__c ='Coletivo';
        update produtoTec;
        
        Product2 produtoCom =[select id, Segmento__c from Product2 where Name ='Nome Produto Comercial' limit 1];       
        produtoCom.Segmento__c ='Coletivo';        
        update produtoCom;                    
        
        
        Opportunity opp =[select id, Numero__c from Opportunity  limit 1];  
        
        PageReference pageRef3 = Page.OrcamentoPage; 
        pageRef3.getParameters().put('numeroOrcamento', opp.Numero__c);
        
        Test.setCurrentPage(pageRef3);
        try{        
            orcamentoController apc3 = new orcamentoController();
        }catch(Exception e){
            system.debug('e '+e.getMessage());
        }    
    }    
    //FIM | PLV-4301-4302-Vida
    
    @IsTest
    static void TestOrcamentoInexistente(){
        OrcamentoController ctr = new OrcamentoController();
    
        Test.startTest(); 
        System.assertEquals(null, ctr.buscaIdOpp('erro'));
        System.assertEquals(null, ctr.buscarOpp('00Bf4000002kxVHEAY'));        
        Test.stopTest();
    }
}
//FIM | PLV-4261-4262-VIAGEM