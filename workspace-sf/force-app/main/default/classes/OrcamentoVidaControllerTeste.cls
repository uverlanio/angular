/*INICIO | PLV-4301-4302-Vida 

*  @author Squad Avanxo 
*  @Descrição: Pagina de orcamentoVidaPage
*/
@IsTest
public class OrcamentoVidaControllerTeste{
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
        garantiaCobertura.name = 'Doenças Graves';
        update garantiaCobertura;
        
        Garantia__c garantiaCobertura2 = TestDataFactory.gerarGarantia();
        garantiaCobertura2.name = 'Incapacidade Temporária';
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
        //PLV-5070 INICIO
        TipoRemuneracao__c tipoRemuneracao = TestDataFactory.gerarTipoRemuneracao('CORRETAGEM', 100, 200, null);
        TipoRemuneracao__c tipoRemuneracao2 = TestDataFactory.gerarTipoRemuneracao('AGENCIAMENTO', 100, 200, null);
		//PLV-5070 FIM
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
        
        
        //PLV-4677 INICIO
        ContratanteOrcamento__c contratanteOrcNovo = (ContratanteOrcamento__c) new contratanteOrcamentoFactory(opp).createRecord();
        GrupoOrcamento__c grupoOrcNovo = (GrupoOrcamento__c) new grupoOrcamentoFactory(contratanteOrcNovo).createRecord();
        Account contaPF = (Account) new AccountFactory.PessoaFisica().createRecord();
        SeguradoOrcamento__c seguradoOrcNovo = (SeguradoOrcamento__c) new seguradoOrcamentoFactory(contaPF,grupoOrcNovo).createRecord();
        //PLV-4677 FIM
    }
        
    @IsTest
    static void TestPass()
    {      
        Opportunity opp = [select id, Numero__c, PremioTotal__c from Opportunity]; //PLV-4677 INICIO/FIM
        
        //PLV-5070 INICIO
        TipoRemuneracao__c tipoRemuneracao3 = [SELECT Id FROM TipoRemuneracao__c WHERE Name ='AGENCIAMENTO'  LIMIT 1];
		RemuneracaoOrcamento__c remuneracaoOrcamento  = TestDataFactory.gerarRemuneracaoOrcamento(opp,tipoRemuneracao3);
        
        remuneracaoOrcamento.Percentual__c = 0;
        update remuneracaoOrcamento;
        
        TipoRemuneracao__c tipoRemuneracao4 = [SELECT Id FROM TipoRemuneracao__c WHERE Name ='CORRETAGEM'  LIMIT 1];
		RemuneracaoOrcamento__c remuneracaoOrcamento2  = TestDataFactory.gerarRemuneracaoOrcamento(opp,tipoRemuneracao4);
        
        remuneracaoOrcamento2.Percentual__c = 0;
        update remuneracaoOrcamento2;
        //PLV-5070 FIM
         
        //PLV-4677 INICIO
         opp.PremioTotal__c = 1000;
         update opp;
         //PLV-4677 FIM

        //Pagina de referencia
        PageReference pageRef = Page.OrcamentoVidaPage;       
        pageRef.getParameters().put('numeroOrcamento', opp.Numero__c);

        //PLV-4677 INICIO
        Profissao__c prof = new Profissao__c(
            NomeFantasia__c = 'Médico',
            CodigoProfissao__c = '2111-05');
        insert prof;
        pageRef.getParameters().put('nomeSeguradoPDF', 'João do Pulo');
        pageRef.getParameters().put('nomeSocialSeguradoPDF', 'Teste TI'); //LECVPV 189-FIX02 - INICIO/FIM
        pageRef.getParameters().put('nascimentoSeguradoPDF', '1964-05-22');
        pageRef.getParameters().put('fumanteSeguradoPDF', 'sim');
        pageRef.getParameters().put('sexoSeguradoPDF', 'MASCULINO');
        pageRef.getParameters().put('dependenteSeguradoPDF', 'true');
        pageRef.getParameters().put('ocupacaoSeguradoPDF', '2111-05');
        pageRef.getParameters().put('formaTrabalhoSeguradoPDF', 'CLT');
        pageRef.getParameters().put('rendaSeguradoPDF', '8000');
        //pageRef.getParameters().put('inputPremioTotalPDF', '12000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //pageRef.getParameters().put('inputPremioMensalPDF', '1000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //PLV-4677 FIM

        //teste Page
        Test.setCurrentPage(pageRef);        
        OrcamentoVidaController apc = new OrcamentoVidaController();  
    }

    @IsTest
    static void TestToken()
    {
        Opportunity opp = [select id, Produto__r.Segmento__c, Numero__c, PremioTotal__c from Opportunity limit 1]; //PLV-4677 INICIO/FIM
 
        CryptoToken c = new CryptoToken();      
        String cri = c.encrypt(opp.id+'|abc');
        system.debug('cri '+cri);
        
        //Pagina de referencia
        PageReference pageRef2 = Page.OrcamentoVidaPage; 
        pageRef2.getParameters().put('token',cri); 

        //PLV-4677 INICIO
        pageRef2.getParameters().put('nomeSeguradoPDF', 'João do Pulo');
        pageRef2.getParameters().put('nomeSocialSeguradoPDF', 'Teste TI'); //LECVPV 189-FIX02 - INICIO/FIM
        pageRef2.getParameters().put('nascimentoSeguradoPDF', '1964-05-22');
        pageRef2.getParameters().put('fumanteSeguradoPDF', 'sim');
        pageRef2.getParameters().put('sexoSeguradoPDF', 'MASCULINO');
        pageRef2.getParameters().put('dependenteSeguradoPDF', 'true');
        pageRef2.getParameters().put('ocupacaoSeguradoPDF', '2111-05');
        pageRef2.getParameters().put('formaTrabalhoSeguradoPDF', 'CLT');
        pageRef2.getParameters().put('rendaSeguradoPDF', '8000');
        //pageRef2.getParameters().put('inputPremioTotalPDF', '12000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //pageRef2.getParameters().put('inputPremioMensalPDF', '1000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //PLV-4677 FIM

        //teste Page
        Test.setCurrentPage(pageRef2);        
        OrcamentoVidaController apc2 = new OrcamentoVidaController();        
    }
    
    @IsTest
    static void TestError()
    {    
        Product2 produtoTec =[select id, Segmento__c from Product2 where Name ='Nome Produto Tecnico' limit 1];
        produtoTec.Segmento__c ='Coletivo';
        update produtoTec;
        
        Product2 produtoCom =[select id, Segmento__c from Product2 where Name ='Nome Produto Comercial' limit 1];       
        produtoCom.Segmento__c ='Coletivo';        
        update produtoCom;                    
               
        Opportunity opp =[select id, Numero__c, PremioTotal__c from Opportunity  limit 1]; //PLV-4677 INICIO/FIM     
 
 	    //Pagina de referencia
        PageReference pageRef3 = Page.OrcamentoVidaPage; 
        pageRef3.getParameters().put('numeroOrcamento', opp.Numero__c);
        //PLV-4677 INICIO
        pageRef3.getParameters().put('nomeSeguradoPDF', 'João do Pulo');
        pageRef3.getParameters().put('nomeSocialSeguradoPDF', 'Teste TI'); //LECVPV 189-FIX02 - INICIO/FIM
      	pageRef3.getParameters().put('nascimentoSeguradoPDF', '1964-05-22');
      	pageRef3.getParameters().put('fumanteSeguradoPDF', 'sim');
      	pageRef3.getParameters().put('sexoSeguradoPDF', 'MASCULINO');
      	pageRef3.getParameters().put('dependenteSeguradoPDF', 'true');
      	pageRef3.getParameters().put('ocupacaoSeguradoPDF', '2111-05');
      	pageRef3.getParameters().put('formaTrabalhoSeguradoPDF', 'CLT');
      	pageRef3.getParameters().put('rendaSeguradoPDF', '8000');
        //pageRef3.getParameters().put('inputPremioTotalPDF', '12000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //pageRef3.getParameters().put('inputPremioMensalPDF', '1000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //PLV-4677 FIM
        //teste Page
        Test.setCurrentPage(pageRef3);
        try{        
            OrcamentoVidaController apc3 = new OrcamentoVidaController();
        }catch(Exception e){
            system.debug('e '+e.getMessage());
        }
          
    }
    //PLV-4677 INICIO
    @IsTest
    static void TestErroOcupacaoSegurado()
    {      
        Opportunity opp = [select id, Numero__c, PremioTotal__c from Opportunity]; //PLV-4677 INICIO/FIM
        //Pagina de referencia
        PageReference pageRef4 = Page.OrcamentoVidaPage;       
        pageRef4.getParameters().put('numeroOrcamento', opp.Numero__c);       
        pageRef4.getParameters().put('nomeSeguradoPDF', 'João do Pulo');
        pageRef4.getParameters().put('nomeSocialSeguradoPDF', 'Teste TI'); //LECVPV 189-FIX02 - INICIO/FIM
        pageRef4.getParameters().put('nascimentoSeguradoPDF', '1964-05-22');
        pageRef4.getParameters().put('fumanteSeguradoPDF', 'sim');
        pageRef4.getParameters().put('sexoSeguradoPDF', 'MASCULINO');
        pageRef4.getParameters().put('dependenteSeguradoPDF', 'true');
        pageRef4.getParameters().put('ocupacaoSeguradoPDF', '');
        pageRef4.getParameters().put('formaTrabalhoSeguradoPDF', 'CLT');
        pageRef4.getParameters().put('rendaSeguradoPDF', '8000');        
        //pageRef4.getParameters().put('inputPremioTotalPDF', '12000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //pageRef4.getParameters().put('inputPremioMensalPDF', '1000'); //PLV-5224 - FIX01 - INICIO/FIM 
        //teste Page
        Test.setCurrentPage(pageRef4);        
        OrcamentoVidaController apc = new OrcamentoVidaController();  
    }
     //PLV-4677 FIM
    //ANNVI-119 - INICIO
    @IsTest
    static void ajustarHora(){        
        
        Test.startTest();

        Opportunity orcamento = [SELECT Id, CreatedDate FROM Opportunity LIMIT 1];
        
        Datetime dataHora = OrcamentoVidaController.ajustarHora(orcamento);     

        Timezone tz = Timezone.getTimeZone('America/Sao_Paulo');
        Integer offSet = tz.getOffset(System.today());
        Datetime horaAConferir = System.now().addSeconds(offSet/1000);

        Test.stopTest();

        System.assertEquals(horaAConferir.hour() , dataHora.hour());
        
    }
     //ANNVI-119 - FIM
}

//FIM | PLV-4301-4302-Vida