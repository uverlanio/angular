/*INICIO | PLV-4391
*  @author Squad Avanxo 
*  @Descrição: Classe de Teste Pagina EndossoSeguroDeVidaIndividual
*/ 
@IsTest
public class EndossoSeguroDeVidaIndividualTest {
    @TestSetup
    static void setup()
    {
        
        TestDataFactory.gerarDadosSetup();        
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
        
        Account contaTeste = TestDataFactory.gerarConta();
        //PLV-5247 INICIO
        Endereco__c endereco = TestDataFactory.gerarEndereco(contaTeste);
        endereco.TipoEndereco__c = 'Residencial';
        update endereco;
        //PLV-5247 FIM
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
        system.debug('favorecidoRemuneracao: '+favorecidoRemuneracao.RemuneracaoProdutoParceiro__c); 
        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, opp, modalidade);
        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, contaTeste, dadosCorretor, cot);
        RemuneracaoContrato__c remuneracaoContrato = TestDataFactory.gerarRemuneracaoContrato(contrato, tipoRemuneracao);
        FavorecidoRemuneracaoContrato__c favorecidoRemuneracaoContrato = new FavorecidoRemuneracaoContrato__c();
        favorecidoRemuneracaoContrato.Conta__c = contaTeste.Id;
        favorecidoRemuneracaoContrato.CorretorLider__c = TRUE;
        favorecidoRemuneracaoContrato.RemuneracaoContrato__c = remuneracaoContrato.Id;
        favorecidoRemuneracaoContrato.Susep__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepEmissao__c ='p5005j';
        favorecidoRemuneracaoContrato.SusepOrcamento__c='p5005j';
        favorecidoRemuneracaoContrato.DadosCorretor__c = dadosCorretor.Id;
        favorecidoRemuneracaoContrato.Papel__c ='Corretor';
        favorecidoRemuneracaoContrato.Participacao__c =100;
        insert favorecidoRemuneracaoContrato;
        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, contaTeste, contaTeste);
                
        GarantiaContratanteContrato__c garantiaContratanteContratoCobertura = TestDataFactory.gerarGarantiaContratanteContrato(garantiaCobertura, contratanteContrato);
        garantiaContratanteContratoCobertura.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContratoCobertura;
        GarantiaContratanteContrato__c garantiaContratanteContrato = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        garantiaContratanteContrato.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContrato;
        
        GarantiaContratanteContrato__c garantiaContratanteContratoCobertura2 = TestDataFactory.gerarGarantiaContratanteContrato(garantiaCobertura2, contratanteContrato);
        garantiaContratanteContratoCobertura2.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContratoCobertura2;
        GarantiaContratanteContrato__c garantiaContratanteContrato2 = TestDataFactory.gerarGarantiaContratanteContrato(garantia, contratanteContrato);
        garantiaContratanteContrato2.CurrencyIsoCode = 'BRL';
        update garantiaContratanteContrato2;
       
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, contaTeste);
        BeneficiarioSeguradoContrato__c beneficiario = new BeneficiarioSeguradoContrato__c();
        beneficiario.Nome__c ='';
        beneficiario.CpfCnpj__c= '';
        beneficiario.Conta__c = contaTeste.Id;
        beneficiario.GrauParentescoPep__c ='Avó';
        beneficiario.SeguradoContrato__c = segurado.Id;
        beneficiario.Participacao__c = 10;
        beneficiario.TipoBeneficiario__c ='Nome do beneficiário';
        insert beneficiario;
          
        Product2 produtoTecnico = (Product2) new produtoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';        
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        produtotecnico.Segmento__c ='Individual';
        update produtoTecnico;
                
        Product2 produtoComercial = (Product2) new produtoFactory.produtoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';       
        produtoComercial.productCode = 'CONSULTIVO';
        
        produtoComercial.VigenciaInicial__c = system.today().addDays(2);
        produtoComercial.VigenciaFinal__c = system.today().addDays(30);  
       
        produtoComercial.Segmento__c ='Individual';      
        update produtoComercial;
        
        RamoSeguro__c ramoSegurado1 = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        RamoGarantia__c ramoGarantia1 = (RamoGarantia__c) new RamoGarantiaFactory(garantiaCobertura, ramoSegurado1).createRecord(); 
        GarantiaProduto__c garantiaProdutoTEC = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantiaCobertura, ramoSegurado1);
        GarantiaProduto__c garantiaProdutoCobertura = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura, garantiaProdutoTEC, ramoSegurado1).createRecord();
        garantiaProdutoCobertura.TipoGarantia__c = 'Cobertura';
        garantiaProdutoCobertura.ambitoTerritorial__c = 'TerritorioNacional';
        garantiaProdutoCobertura.CaracteristicaGarantia__c = 'Principal';
        update garantiaProdutoCobertura;
        garantiaContratanteContratoCobertura.GarantiaProduto__c = garantiaProdutoCobertura.Id;
        update garantiaContratanteContratoCobertura;

        List<Contract> lContrato = new List<Contract>();
        lContrato.add(contrato);        
    }
    
    @IsTest
    static void TestPass()
    {      
        Contract ctr = [select Id, Name from Contract];
        List<GarantiaContratanteContrato__c> gar = [select Id, Name, GarantiaProduto__r.TipoGarantia__c from GarantiaContratanteContrato__c];
        
        List<GarantiaProduto__c> oGar= [select Id, Name, TipoGarantia__c from GarantiaProduto__c];
        
        //Pagina de referencia
        PageReference pageRef = Page.EndossoSeguroDeVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef);        
        EndossoSeguroDeVidaIndividualController apc = new EndossoSeguroDeVidaIndividualController();  
    }
    
    @IsTest
    static void TestToken()
    {
        Contract ctr = [select Id, Name from Contract];           
        
        CryptoToken c = new CryptoToken();      
        String cri = c.encrypt(ctr.id+'|abc');
        system.debug('cri '+cri);
        
        //Pagina de referencia
        PageReference pageRef2 = Page.EndossoSeguroDeVidaIndividual; 
        pageRef2.getParameters().put('token',cri);
        
        //teste Page
        Test.setCurrentPage(pageRef2);        
        EndossoSeguroDeVidaIndividualController apc2 = new EndossoSeguroDeVidaIndividualController();        
    }
    
    @IsTest
    static void TestPass2()
    {      
        Contract ctr = [select Id, Name, produto__r.Segmento__c, PremioComercial__c from Contract];        
        GarantiaContratanteContrato__c gar = [SELECT id, ContratanteContrato__r.Contrato__c, CurrencyIsoCode 
                                              from GarantiaContratanteContrato__c 
                                              where ContratanteContrato__r.Contrato__c =:ctr.id limit 1];
        gar.CurrencyIsoCode = 'USD';
        update gar;
            
        //Pagina de referencia
        PageReference pageRef = Page.EndossoSeguroDeVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef);             
        EndossoSeguroDeVidaIndividualController apc = new EndossoSeguroDeVidaIndividualController();  
        
    }
    @IsTest
    static void TestValores(){
        string valor= '5.000,00';
        string moeda= 'BRL';
        EndossoSeguroDeVidaIndividualController.trataValores(valor, moeda);
    }
    @IsTest
    static void TestValoresUS(){
        string valor= '5,000.00';
        string moeda= 'USD';
        EndossoSeguroDeVidaIndividualController.trataValores(valor, moeda);
    }
    @IsTest
    static void TestValoresUSB(){
        string valor= '500';
        string moeda= 'USD';
        EndossoSeguroDeVidaIndividualController.trataValores(valor, moeda);
    }
    @IsTest
    static void TestValoresBRL_twoDigits(){
        string valor= ',2';
        string moeda= 'BRL';
        EndossoSeguroDeVidaIndividualController.trataValores(valor, moeda);
    }
    @IsTest
    static void TestError()
    {      
        Contract ctr = [select Id, Name, Produto__c  from Contract];        
        Product2 prod = [SELECT id, Segmento__c from Product2 where id =:ctr.Produto__c limit 1];
        prod.Segmento__c = 'Viagem';
        update prod;
        system.debug('prod '+prod);        
       
        PageReference pageRef = Page.EndossoSeguroDeVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef); 
         try{        
            EndossoSeguroDeVidaIndividualController apc = new EndossoSeguroDeVidaIndividualController();  
        }catch(Exception e){
            system.debug('e '+e.getMessage());
        }
       
    }
}