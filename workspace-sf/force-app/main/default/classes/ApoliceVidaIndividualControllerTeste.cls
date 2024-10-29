/*INICIO | PLV-4368
*  @author Squad Avanxo 
*  @Descrição: Classe de Teste Pagina  ApoliceVidaInvididual
*/ 
@IsTest
public class ApoliceVidaIndividualControllerTeste {
    @TestSetup
    static void setup()
    {
        TestDataFactory.gerarDadosSetup();        
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
        
        Account contaTeste = TestDataFactory.gerarConta();
        contaTeste.Email__c = 'teste@teste.com.br';
        update contaTeste;
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
        contrato.Tipo__c ='Endosso';
        update contrato;
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
        
        //PLV-4817 INICIO
        RamoSeguro__c ramoSegurado1 = (RamoSeguro__c) new RamoSeguroFactory().createRecord();
        RamoSeguro__c ramoSegurado2 = (RamoSeguro__c) new RamoSeguroFactory().createRecord();

        new RamoGarantiaFactory(garantiaCobertura, ramoSegurado1).createRecord(); 
        new RamoGarantiaFactory(garantiaCobertura, ramoSegurado2).createRecord(); 
        GarantiaProduto__c garantiaProdutoTEC  = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantiaCobertura, ramoSegurado1);
        GarantiaProduto__c garantiaProdutoTEC2 = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTecnico, garantiaCobertura, ramoSegurado2);

        GarantiaProduto__c garantiaProdutoCobertura = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura, garantiaProdutoTEC, ramoSegurado1).createRecord();
        GarantiaProduto__c garantiaProdutoCobertura2 = (GarantiaProduto__c) new GarantiaProdutoFactory.GarantiaProdutoCom(produtoComercial, garantiaCobertura2, garantiaProdutoTEC2, ramoSegurado2).createRecord();
        garantiaProdutoCobertura.TipoGarantia__c = 'Cobertura';
        garantiaProdutoCobertura.ambitoTerritorial__c = 'TerritorioNacional';
        garantiaProdutoCobertura.CaracteristicaGarantia__c = 'Principal';
        update garantiaProdutoCobertura;
        garantiaContratanteContratoCobertura.GarantiaProduto__c = garantiaProdutoCobertura.Id;
        update garantiaContratanteContratoCobertura;

        TestDataFactory.gerarGarantiaContrato(contrato, garantiaProdutoCobertura);
        TestDataFactory.gerarGarantiaContrato(contrato, garantiaProdutoCobertura2);
        //PLV-4817 FIM
    }
    
    @IsTest
    static void TestPass()
    {   
        Contract ctr = [select Id, Name, AccountId from Contract];
        Account conta = [select Id, Name, TipoDocidentificacao__c From Account where Id =: ctr.AccountId];
        conta.TipoDocidentificacao__c = 'rg';
        conta.Rg__c = '272146524';
        update conta;
        List<GarantiaContratanteContrato__c> gar = [select Id, Name, GarantiaProduto__r.TipoGarantia__c from GarantiaContratanteContrato__c];
        
        List<GarantiaProduto__c> oGar= [select Id, Name, TipoGarantia__c from GarantiaProduto__c];
        
        //Pagina de referencia
        PageReference pageRef = Page.ApoliceVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef);        
        ApoliceVidaIndividualController apc = new ApoliceVidaIndividualController(); //PLV-5231 - INICIO/FIM 
    }
   
    
    @IsTest
    static void TestToken()
    {
        Contract ctr = [select Id, Name, AccountId from Contract];
        Account conta = [select Id, Name, TipoDocidentificacao__c From Account where Id =: ctr.AccountId];
        conta.TipoDocidentificacao__c = 'rg';
        conta.Rg__c = '272146524';
        update conta;       
        
        CryptoToken c = new CryptoToken();      
        String cri = c.encrypt(ctr.id+'|abc');
        system.debug('cri '+cri);
        
        //Pagina de referencia
        PageReference pageRef2 = Page.ApoliceVidaIndividual; 
        pageRef2.getParameters().put('token',cri);
        
        //teste Page
        Test.setCurrentPage(pageRef2);        
        ApoliceVidaIndividualController apc2 = new ApoliceVidaIndividualController(); //PLV-5231 - INICIO/FIM        
    }
    
    @IsTest
    static void TestPass2()
    {   
        Contract ctr = [select Id, Name, AccountId from Contract];
        Account conta = [select Id, Name, TipoDocidentificacao__c From Account where Id =: ctr.AccountId];
        conta.TipoDocidentificacao__c = 'rg';
        conta.Rg__c = '272146524';
        update conta;
        GarantiaContratanteContrato__c gar = [SELECT id, ContratanteContrato__r.Contrato__c, CurrencyIsoCode 
                                              from GarantiaContratanteContrato__c 
                                              where ContratanteContrato__r.Contrato__c =:ctr.id limit 1];
        gar.CurrencyIsoCode = 'USD';
        update gar;        
        
       
            
        //Pagina de referencia
        PageReference pageRef = Page.ApoliceVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef);             
        ApoliceVidaIndividualController apc = new ApoliceVidaIndividualController(); //PLV-5231 - INICIO/FIM  
        
    }
    
    //PLV-4817 INICIO
    @IsTest
    static void TestValores(){
        Test.startTest();
        ApoliceVidaIndividualController.trataValores('5.000,00', 'BRL');
        ApoliceVidaIndividualController.trataValores('5,000.00', 'USD');
        ApoliceVidaIndividualController.trataValores('500.00', 'USD'); 
        ApoliceVidaIndividualController.trataValores('500', 'USD');
        ApoliceVidaIndividualController.trataValores(',2', 'BRL');
        Test.stopTest();
    }
    //PLV-4817 FIM

    @IsTest
    static void TestError()
    {      
        Contract ctr = [select Id, Name, Produto__c  from Contract];        
        Product2 prod = [SELECT id, Segmento__c from Product2 where id =:ctr.Produto__c limit 1];
        prod.Segmento__c = 'Viagem';
        update prod;
        system.debug('prod '+prod);
        
       
        PageReference pageRef = Page.ApoliceVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef); 
         try{        
             ApoliceVidaIndividualController apc = new ApoliceVidaIndividualController();  
        }catch(Exception e){
            system.debug('e '+e.getMessage());
        }
       
    }
    //PLV-5438 INICIO
    @IsTest
    static void TestEndereco()
    {      
        Contract ctr = [select Id, Name, AccountId, Produto__c from Contract];
        Account conta = [select Id, Name, TipoDocidentificacao__c From Account where Id =: ctr.AccountId];
        conta.TipoDocidentificacao__c = 'rg';
        conta.Rg__c = '272146524';
        update conta;
        Endereco__c endereco = [SELECT Id, TipoEndereco__c, Bairro__c, Cidade__c, logradouro__c, Estado__c, Complemento__c, CEP__c,Numero__c
                                FROM Endereco__c 
                                where Conta__c =: ctr.AccountId
                                Limit 1 ];
        Product2 prod = [SELECT id, Segmento__c from Product2 where id =:ctr.Produto__c limit 1];
        prod.Segmento__c = 'Individual';
        update prod;
        system.debug('prod '+prod);
        
       
        PageReference pageRef = Page.ApoliceVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef); 
         try{        
             ApoliceVidaIndividualController apc = new ApoliceVidaIndividualController();  
        }catch(Exception e){
            system.debug('e '+e.getMessage());
        }
       
    }
    //PLV-5438 FIM
   //PLV-5438 INICIO
    @IsTest
    static void TestEnderecoBranco()
    {      
        Contract contrato = [select Id, Name, AccountId, Produto__c from Contract];
        Account contaTeste2 = [select Id, Name, TipoDocidentificacao__c From Account where Id =: contrato.AccountId];

        contaTeste2.Email__c = 'teste@teste.com.br';
        contaTeste2.Name = 'conta 14';
        contaTeste2.TipoDocidentificacao__c = 'rg';
        contaTeste2.Rg__c = '183545734'; //II-157 - INICIO/FIM
        contaTeste2.CodigoEmpresa__c = '214';
        contaTeste2.IdExterno__c = '30792848012';
        contaTeste2.Papel__c = 'Parceiro';
        contaTeste2.Sexo__c = 'Masc';
        contaTeste2.Cpf__c = '30792848012';
        contaTeste2.Pis__c = '123456789';
        contaTeste2.Cnpj__c = '09.532.797/0001-42';
        contaTeste2.Inscricao_Municipal__c = '123456789';
        contaTeste2.Nacionalidade__c = 'Brasileira';
        contaTeste2.EstadoCivil__c = 'Casado (a)';
        update contaTeste2;
        
        SeguradoContrato__c EnderecoTeste = new SeguradoContrato__c();
        EnderecoTeste.Conta__c = contaTeste2.Id;
        EnderecoTeste.Numero__c = 00860376;
        EnderecoTeste.CPF__c = '30792848012';
        insert EnderecoTeste;
            
        Contract ctr = [select Id, Name, AccountId, Produto__c from Contract where AccountId =: contaTeste2.Id ];
          
        Product2 prod = [SELECT id, Segmento__c from Product2 where id =:ctr.Produto__c limit 1];
        prod.Segmento__c = 'Individual';
        update prod;
        system.debug('prod '+prod);
                  
        //Pagina de referencia
        PageReference pageRef = Page.ApoliceVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef);        
        ApoliceVidaIndividualController apc = new ApoliceVidaIndividualController(); 
       
    }
    //PLV-5438 FIM
    // PLV 5032 - INICIO
    @IsTest
    static void TestValorNegativo()
    {      
        Contract ctr = [select Id, Name, AccountId from Contract];
        Account conta = [select Id, Name, TipoDocidentificacao__c From Account where Id =: ctr.AccountId];
        conta.TipoDocidentificacao__c = 'rg';
        conta.Rg__c = '272146524';
        update conta;
       	List<ContratanteContrato__c>lstContratantes = [
            SELECT Id 
			FROM ContratanteContrato__c 
            WHERE Contrato__c =: ctr.Id
        ];
        
        for(ContratanteContrato__c contratantes : lstContratantes ) contratantes.PremioTotal__c = -10;
        update lstContratantes;
     
        List<GarantiaContratanteContrato__c> gar = [select Id, Name, GarantiaProduto__r.TipoGarantia__c from GarantiaContratanteContrato__c];
        
        List<GarantiaProduto__c> oGar= [select Id, Name, TipoGarantia__c from GarantiaProduto__c];
        
        //Pagina de referencia
        PageReference pageRef = Page.ApoliceVidaIndividual;            
        pageRef.getParameters().put('nomeContract', ctr.Name);
        
        //teste Page
        Test.setCurrentPage(pageRef);        
        ApoliceVidaIndividualController apc = new ApoliceVidaIndividualController(); //PLV-5231 - INICIO/FIM  
    }
    // PLV 5032 - FIM
    //FCVEP-39 - INICIO
    @IsTest
    static void testarInserirNumeroReemissao(){
        
        Test.startTest();        
        
        Contract contrato = [SELECT Id, Sucursal__c, CodigoRamo__c, NumeroApoliceFiltro__c  FROM Contract LIMIT 1];
        
        ApoliceVidaIndividualController.inserirNumeroReemissao(contrato);

        ApoliceVidaIndividualController.inserirNumeroReemissao(null);

        Test.stopTest();
        
    }
    //FCVEP-39 - FIM
   
}