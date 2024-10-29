/**
 * InformacaoBancariaTest
 * @author; Fernando Barcellos @ 06/02/2018
 *  Avanxo linhas 56 a 133
 **/
@isTest
private class InformacaoBancariaTest {
    
    @isTest
    static void validarDuplicidadeInformacaoBancaria() {
        // PLV-4472 INICIO
        Account conta1 = new Account(Name = 'Conta 1', Cnpj__c = '08.370.609/0001-64');
        insert conta1;
        
        Account conta2 = new Account(Name = 'Conta 2', Cnpj__c = '84.762.465/0001-70');
        insert conta2;
        // PLV-4472 FIM

        String jsonValidarInformacaoBancaria = '{"status": 0 }';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(jsonValidarInformacaoBancaria, 200, 'OK'));

        //PLV-4363 - INICIO

        // dados bancários
        String banco = '341';
        String agencia = '0123';
        String numeroConta = '01234567';

        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = banco;
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'BANCO ITAU S/A';
        banconew.Ativo__c = true;
        insert banconew; 
        //PLV-4363 - FIM

        // informação bancária 1 para conta 1
        InformacaoBancaria__c ib1c1 = new InformacaoBancaria__c();
        ib1c1.Banco__c = banconew.CodigoBanco__c;//PLV-4363 - INICIO/FIM
        ib1c1.Conta__c = conta1.Id;
        ib1c1.Agencia__c = agencia;
        ib1c1.NumeroConta__c = numeroConta;
        //PLV-4363 - INICIO
        ib1c1.BancoNew__c = banconew.Id;
        //PLV-4363 - FIM
        insert ib1c1;
        
        try {
            // informação bancária 2 para conta 1 - erro            
			InformacaoBancaria__c ib2c2 = new InformacaoBancaria__c();
            ib2c2.Banco__c = banconew.CodigoBanco__c;//PLV-4363 - INICIO/FIM
            ib2c2.Conta__c = conta1.Id; 
            ib2c2.Agencia__c = agencia;
            ib2c2.NumeroConta__c = numeroConta;
            //PLV-4363 - INICIO
            ib2c2.BancoNew__c = banconew.Id;
            //PLV-4363 - FIM
            insert ib2c2;
        }
        catch(Exception e) {
            System.debug('::: e.getMessage(): ' + e.getMessage());
            System.assert(e.getMessage().contains('DUPLICATE_VALUE'));
        }
        
        // informação bancária 1 para conta 2
        InformacaoBancaria__c ib1c2 = new InformacaoBancaria__c();
        ib1c2.Banco__c = banconew.CodigoBanco__c;//PLV-4363 - INICIO/FIM
        ib1c2.Conta__c = conta2.Id;
        ib1c2.Agencia__c = agencia;
        ib1c2.NumeroConta__c = numeroConta;
        ib1c2.IdExterno__c = '123';
        //PLV-4363 - INICIO
        ib1c2.BancoNew__c = banconew.Id;
        //PLV-4363 - FIM
        insert ib1c2;
        
        //LINHAS AVANXO
        InformacaoBancaria__c vInfoBancTest = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantia = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisica, vInfoBancTest, pag).createRecord();
        
        Test.startTest();
        //PLV-2310-28 - Código removido para ajuste na cobertura da classe de teste
        String retorno = InformacaoBancariaBO.verificarbloqueiobancario(beneGarantia.Id);
        //PLV-2310-28 - Código removido para ajuste na cobertura da classe de teste
        Boolean testCheque = InformacaoBancariaBO.validarcheque(beneGarantia.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método criado para aumento de cobertura na classe de teste
    @isTest
    static void testServicoSerasaCod404(){
        InformacaoBancaria__c vInfoBancTestCod404 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisicaCod404 = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pagCod404 = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantiaCod404 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisicaCod404, vInfoBancTestCod404, pagCod404).createRecord();

        String mockCod404 = '{"NOME_ENR": "NOME DO NOME", "codigo": "404"}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockCod404, 404, 'OK'));
        String serasa = InformacaoBancariaBO.validarnomeserasa(beneGarantiaCod404.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método criado para aumento de cobertura na classe de teste
    @isTest
    static void testServicoSerasaCod500(){
        InformacaoBancaria__c vInfoBancTestCod500 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisicaCod500 = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pagCod500 = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantiaCod500 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisicaCod500, vInfoBancTestCod500, pagCod500).createRecord();

        String mockCod404 = '{"NOME_ENR": "NOME DO NOME", "codigo": "500"}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockCod404, 500, 'OK'));
        String serasa = InformacaoBancariaBO.validarnomeserasa(beneGarantiaCod500.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método criado para aumento de cobertura na classe de teste
    @isTest
    static void testServicoSerasaCod200(){
        InformacaoBancaria__c vInfoBancTestCod200 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisicaCod200 = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pagCod200 = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantiaCod200 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisicaCod200, vInfoBancTestCod200, pagCod200).createRecord();

        String mockCod404 = '{"NOME_ENR": "NOME DO NOME", "codigo": "200"}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockCod404, 200, 'OK'));
        String serasa = InformacaoBancariaBO.validarnomeserasa(beneGarantiaCod200.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método criado para aumento de cobertura na classe de teste
    @isTest
    static void testServicoSerasaCod200MesmoNome(){
        InformacaoBancaria__c vInfoBancTestCod200 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisicaCod200 = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pagCod200 = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantiaCod200 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisicaCod200, vInfoBancTestCod200, pagCod200).createRecord();
        beneGarantiaCod200.StatusSerasa__c = 'Aguardando atualização';
        update beneGarantiaCod200;

        String mockCod404 = '{"NOME_ENR": "TestFirstNamePessoaFisica TestLastNamePessoaFisica", "codigo": "200"}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockCod404, 200, 'OK'));
        String serasa = InformacaoBancariaBO.validarnomeserasa(beneGarantiaCod200.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método criado para aumento de cobertura na classe de teste
    @isTest
    static void testValidarComposicaoBancariaStatus0(){
        InformacaoBancaria__c vInfoBancTestCompBanSt0 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisicaCompBanSt0 = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pagCompBanSt0 = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantiaCompBanSt0 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisicaCompBanSt0, vInfoBancTestCompBanSt0, pagCompBanSt0).createRecord();

        String mockCompBanSt0 = '{"status":0}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockCompBanSt0, 200, 'OK'));
        String compBancariaStatus0 = InformacaoBancariaBO.validarComposicaoBancaria(beneGarantiaCompBanSt0.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método criado para aumento de cobertura na classe de teste
    @isTest
    static void testValidarComposicaoBancariaStatusNull(){
        InformacaoBancaria__c vInfoBancTestCompBanStNull = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisicaCompBanStNull = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pagCompBanStNull = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantiaCompBanStNull = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisicaCompBanStNull, vInfoBancTestCompBanStNull, pagCompBanStNull).createRecord();

        String mockCompBanStNull = '{"status":null}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockCompBanStNull, 200, 'OK'));
        String compBancariaStatusNull = InformacaoBancariaBO.validarComposicaoBancaria(beneGarantiaCompBanStNull.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método criado para aumento de cobertura na classe de teste
    @isTest
    static void testValidarComposicaoBancariaStatus1(){
        InformacaoBancaria__c vInfoBancTestCompBanSt1 = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        Account contaFisicaCompBanSt1 = (Account) new AccountFactory.PessoaFisica().createRecord();
        PagamentoGarantia__c pagCompBanSt1 = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c beneGarantiaCompBanSt1 = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(contaFisicaCompBanSt1, vInfoBancTestCompBanSt1, pagCompBanSt1).createRecord();

        String mockCompBanSt1 = '{"status":1}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(mockCompBanSt1, 200, 'OK'));
        String compBancariaStatus1 = InformacaoBancariaBO.validarComposicaoBancaria(beneGarantiaCompBanSt1.Id);
        Test.stopTest();
    }

    //PLV-2310-28 - Método ajustado na classe de teste para aumento de cobertura
    @isTest
    static void testPreencherNomenclatura(){
        Test.startTest();
        InformacaoBancaria__c vInfoBancTest = (InformacaoBancaria__c) new InformacaoBancariaFactory.InfoPessoaFisica().createRecord();
        system.assert([SELECT NomenclaturaPesquisa__c 
                       FROM InformacaoBancaria__c 
                       WHERE Id = :vInfoBancTest.Id].NomenclaturaPesquisa__c != null);
        Test.stopTest();
    } 

    // PLV-3667 - INICIO
    @isTest
    static void testBuscarInformacoesPorIdExterno(){
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        //PLV-4363 - INICIO
        
        // dados bancários
        String banco = '021';
        String agencia = '0123';
        String numeroConta = '01234567';
        
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = banco;
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'BANCO ITAU S/A';
        banconew.Ativo__c = true;
        insert banconew; 
        //PLV-4363 - FIM

        InformacaoBancaria__c infoBank = new InformacaoBancaria__c();
        infoBank.Banco__c = banconew.CodigoBanco__c;//PLV-4363 - INICIO/FIM
        infoBank.Conta__c = contaFisica.Id;
        infoBank.Agencia__c = '0123';
        infoBank.NumeroConta__c = '01234567';
        infoBank.IdExterno__c = '666';
        infoBank.BancoNew__c = banconew.Id; //PLV-4363
        insert infoBank;
        
        List<InformacaoBancaria__c> listaInformacoesBancarias = new List<InformacaoBancaria__c>();
        
        Set<String> idsExternos = new Set<String>();
        idsExternos.add(infoBank.IdExterno__c);
        
        Test.startTest();
        listaInformacoesBancarias = InformacaoBancariaDAO.getInstance().buscarInformacoesBancariasPorIdExterno(idsExternos);
        Test.stopTest();
    }

    @isTest
    static void testBuscarInformacoesPorId(){
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();

        //PLV-4363 - INICIO

        // dados bancários
        String banco = '331';
        String agencia = '3210';
        String numeroConta = '01234567';

        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = banco;
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'BANCO ITAU S/A';
        banconew.Ativo__c = true;
        insert banconew; 
        //PLV-4363 - FIM

        InformacaoBancaria__c infoBank = new InformacaoBancaria__c();
        infoBank.Banco__c = banconew.CodigoBanco__c;//PLV-4363 - INICIO/FIM
        infoBank.Conta__c = contaFisica.Id;
        infoBank.Agencia__c = '0123';
        infoBank.NumeroConta__c = '01234567';
        infoBank.IdExterno__c = '666';
        infoBank.BancoNew__c = banconew.Id; //PLV-4363
        insert infoBank;
        
        List<InformacaoBancaria__c> listaInformacoesBancarias = new List<InformacaoBancaria__c>();
        
        Set<Id> ids = new Set<Id>();
        ids.add(infoBank.Id);
        
        Test.startTest();
        listaInformacoesBancarias = InformacaoBancariaDAO.getInstance().buscarInformacoesBancariasPorId(ids);
        Test.stopTest();
    }
    // PLV-3667 - FIM
    //MGRC-1252 - INICIO - FIX1
    @isTest
    static void testarGetMapBancos() {
      
        Test.startTest();

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Map<Id,Banco__c> bancoMap = InformacaoBancariaBO.getMapBancos();
       
        System.assert(bancoMap.values().size() > 0);

        Test.stopTest();
    }

    @IsTest
    static void testarPreenchNomncltrInfoBancaria(){
        
        Test.startTest();

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        List<InformacaoBancaria__c> lInfoBanc = new List<InformacaoBancaria__c>{(InformacaoBancaria__c) records.get('InformacaoBancaria')};

        InformacaoBancariaBO.getInstance().preencherNomenclaturaInformacaoBancaria(lInfoBanc);
        
        Test.stopTest();        
    }

    @IsTest
    static void testarGetIdExterno(){
        
        Test.startTest();
        
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        String retorno = InformacaoBancariaBO.getIdExterno((InformacaoBancaria__c) records.get('InformacaoBancaria'));

        System.assert(retorno != '');

        Test.stopTest();        
    }

    @IsTest
    static void testarAcionaCIVLiquidacao(){
        
        Test.startTest();

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(((Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro')).Id);
       
        Test.stopTest();        
    }

    @IsTest
    static void testarAcionaCIVLiquidacaoSemDadosBancarios(){
        
        Test.startTest();

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Pagamento_de_Sinistro__c pagamentoDeSinistro = (Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro');
        pagamentoDeSinistro.Dados_Bancarios__c = null;

        update pagamentoDeSinistro;

        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(pagamentoDeSinistro.Id);
       
        Test.stopTest();        
    }

    @IsTest
    static void testarAcionaCIVLiquidacaoSemBeneficiario(){
        
        Test.startTest();

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        Pagamento_de_Sinistro__c pagamentoDeSinistro = (Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro');
        pagamentoDeSinistro.Beneficiario_da_Garantia__c = null;

        update pagamentoDeSinistro;

        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(pagamentoDeSinistro.Id);
       
        Test.stopTest();        
    }

    @IsTest
    static void testarAcionaCIVLiquidacaoSensedia(){

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        String json = JSON.serialize(mockRetornoSensedia());

        Pagamento_de_Sinistro__c pagamentoDeSinistro = (Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro');
        pagamentoDeSinistro.Status__c = 'Pendente';

        update pagamentoDeSinistro;

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));
        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(pagamentoDeSinistro.Id);
       
        Test.stopTest();       
    }

    @IsTest
    static void testarAcionaCIVLiquidacaoSensediaCodigo1(){

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        InformacaoBancariaBO.RetornoCIVLiquidacaoTO retornoSensediaMock = mockRetornoSensedia();
        retornoSensediaMock.bloqueioBancario.MsgRetornoSOAP.Mensagem.codigoRetorno = 1;
        String json = JSON.serialize(retornoSensediaMock);

        Pagamento_de_Sinistro__c pagamentoDeSinistro = (Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro');
        pagamentoDeSinistro.Status__c = 'Pendente';
        pagamentoDeSinistro.BeneficiarioValidado__c = true;

        update pagamentoDeSinistro;

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));
        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(pagamentoDeSinistro.Id);
       
        Test.stopTest();       
    }

    @IsTest
    static void testarAcionaCIVLiquidacaoSensediaSemCodigoSerasa(){

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        InformacaoBancariaBO.RetornoCIVLiquidacaoTO retornoSensediaMock = mockRetornoSensedia();
        retornoSensediaMock.bloqueioBancario.MsgRetornoSOAP.Mensagem.codigoRetorno = 1;
        retornoSensediaMock.serasa.codigo = null;
        String json = JSON.serialize(retornoSensediaMock);

        Pagamento_de_Sinistro__c pagamentoDeSinistro = (Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro');
        pagamentoDeSinistro.Status__c = 'Pendente';
        pagamentoDeSinistro.BeneficiarioValidado__c = true;

        update pagamentoDeSinistro;

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));
        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(pagamentoDeSinistro.Id);
       
        Test.stopTest();       
    }

    @IsTest
    static void testarAcionaCIVLiquidacaoSensediaNRMNameDifAccName(){

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        InformacaoBancariaBO.RetornoCIVLiquidacaoTO retornoSensediaMock = mockRetornoSensedia();
        retornoSensediaMock.bloqueioBancario.MsgRetornoSOAP.Mensagem.codigoRetorno = 1;
        retornoSensediaMock.serasa.nome_ENR = 'name lastName teste';
        retornoSensediaMock.serasa.codigo = null;
        String json = JSON.serialize(retornoSensediaMock);

        Pagamento_de_Sinistro__c pagamentoDeSinistro = (Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro');
        pagamentoDeSinistro.Status__c = 'Pendente';
        pagamentoDeSinistro.BeneficiarioValidado__c = true;

        update pagamentoDeSinistro;

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));
        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(pagamentoDeSinistro.Id);
       
        Test.stopTest();       
    }

    @IsTest
    static void testarAcionaCIVLiquidacaoSensediaSerasa404(){

        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();

        InformacaoBancariaBO.RetornoCIVLiquidacaoTO retornoSensediaMock = mockRetornoSensedia();
        retornoSensediaMock.bloqueioBancario.MsgRetornoSOAP.Mensagem.codigoRetorno = 1;
        retornoSensediaMock.serasa.codigo = 404;
        String json = JSON.serialize(retornoSensediaMock);

        Pagamento_de_Sinistro__c pagamentoDeSinistro = (Pagamento_de_Sinistro__c) records.get('PagamentoDeSinistro');
        pagamentoDeSinistro.Status__c = 'Pendente';
        pagamentoDeSinistro.BeneficiarioValidado__c = true;

        update pagamentoDeSinistro;

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(json, 200, 'OK'));
        Map<String, Object> retorno = InformacaoBancariaBO.acionaCIVLiquidacao(pagamentoDeSinistro.Id);
       
        Test.stopTest();       
    }

    private static InformacaoBancariaBO.RetornoCIVLiquidacaoTO mockRetornoSensedia(){
        InformacaoBancariaBO.RetornoCIVLiquidacaoTO retornoCIVLiquidacao = new InformacaoBancariaBO.RetornoCIVLiquidacaoTO();
        
        InformacaoBancariaBO.InformacoesTO informacoes = new InformacaoBancariaBO.InformacoesTO();
        informacoes.cpfBeneficiario = '12345678900';
        informacoes.tipoConsulta = 1;
        informacoes.DadosBancarios = new InformacaoBancariaBO.DadosBancariosTO();
        informacoes.DadosBancarios.banco = 'Banco ABC';
        informacoes.DadosBancarios.agencia = '1234';
        informacoes.DadosBancarios.contaCorrente = '567890';
        informacoes.DadosBancarios.digitoContaCorrente = '1';

        retornoCIVLiquidacao.bloqueioBancario = new InformacaoBancariaBO.BloqueioBancarioTO();
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP = new InformacaoBancariaBO.MsgRetornoSOAPTO();
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP.Header = new InformacaoBancariaBO.HeaderTO();
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP.Header.tipoConsulta = 2;
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP.Mensagem = new InformacaoBancariaBO.MensagemTO();
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP.Mensagem.codigoRetorno = 100;
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP.Mensagem.mensagem = 'Success';
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP.Trailer = new InformacaoBancariaBO.TrailerTO();
        retornoCIVLiquidacao.bloqueioBancario.MsgRetornoSOAP.Trailer.qntdRegistros = 5;

        retornoCIVLiquidacao.composicaoBancaria = new InformacaoBancariaBO.ComposicaoBancariaTO();
        retornoCIVLiquidacao.composicaoBancaria.status = 1;

        retornoCIVLiquidacao.serasa = new InformacaoBancariaBO.SerasaTO();
        retornoCIVLiquidacao.serasa.nome_ENR = 'TestFirstNamePessoaFisica TestLastNamePessoaFisica';
        retornoCIVLiquidacao.serasa.codigo = 1;
        retornoCIVLiquidacao.serasa.status = 'Active';
        retornoCIVLiquidacao.serasa.data_de_atualizacao = '2022-01-01';
        retornoCIVLiquidacao.serasa.origem_informacao = 'Credit Bureau';

        retornoCIVLiquidacao.serasa.dddcel2_ENR = '123';
        retornoCIVLiquidacao.serasa.dddcel2_ENR = 'dddcel2_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_TITULO2_ENR = 'logr_TITULO2_ENR de teste';
        retornoCIVLiquidacao.serasa.cel3_ENR = 'cel3_ENR de teste';
        retornoCIVLiquidacao.serasa.cep3_ENR = 'cep3_ENR de teste';
        retornoCIVLiquidacao.serasa.cep2_ENR = 'cep2_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_TITULO1_ENR = 'logr_TITULO1_ENR de teste';
        retornoCIVLiquidacao.serasa.ddd3_ENR = 'ddd3_ENR de teste';
        retornoCIVLiquidacao.serasa.ddd2_ENR = 'ddd2_ENR de teste';
        retornoCIVLiquidacao.serasa.orgao_EMISSOR_ENR = 'orgao_EMISSOR_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_NUMERO2_ENR = 'logr_NUMERO2_ENR de teste';
        retornoCIVLiquidacao.serasa.fone2_ENR = 'fone2_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_COMPLEMENTO1_ENR = 'logr_COMPLEMENTO1_ENR de teste';
        retornoCIVLiquidacao.serasa.uf1_ENR = 'uf1_ENR de teste';
        retornoCIVLiquidacao.serasa.fone3_ENR = 'fone3_ENR de teste';
        retornoCIVLiquidacao.serasa.endereco2_ENR = 'endereco2_ENR de teste';
        retornoCIVLiquidacao.serasa.cpf_DIGITO = 'cpf_DIGITO de teste';
        retornoCIVLiquidacao.serasa.bairro2_ENR = 'bairro2_ENR de teste';
        retornoCIVLiquidacao.serasa.nome_ENR = 'nome_ENR de teste';
        retornoCIVLiquidacao.serasa.cel1_ENR = 'cel1_ENR de teste';
        retornoCIVLiquidacao.serasa.uf3_ENR = 'uf3_ENR de teste';
        retornoCIVLiquidacao.serasa.bairro1_ENR = 'bairro1_ENR de teste';
        retornoCIVLiquidacao.serasa.dddcel1_ENR = 'dddcel1_ENR de teste';
        retornoCIVLiquidacao.serasa.endereco3_ENR = 'endereco3_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_TIPO2_ENR = 'logr_TIPO2_ENR de teste';
        retornoCIVLiquidacao.serasa.cep1_ENR = 'cep1_ENR de teste';
        retornoCIVLiquidacao.serasa.nome_MAE_ENR = 'nome_MAE_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_COMPLEMENTO3_ENR = 'logr_COMPLEMENTO3_ENR de teste';
        retornoCIVLiquidacao.serasa.cel2_ENR = 'cel2_ENR de teste';
        retornoCIVLiquidacao.serasa.sexo_ENR = 'sexo_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_TITULO3_ENR = 'logr_TITULO3_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_NOME3_ENR = 'logr_NOME3_ENR de teste';
        retornoCIVLiquidacao.serasa.cpf_RADICAL = 'cpf_RADICAL de teste';
        retornoCIVLiquidacao.serasa.ddd1_ENR = 'ddd1_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_NUMERO3_ENR = 'logr_NUMERO3_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_TIPO1_ENR = 'logr_TIPO1_ENR de teste';
        retornoCIVLiquidacao.serasa.nascimento_ENR = 'nascimento_ENR de teste';
        retornoCIVLiquidacao.serasa.endereco1_ENR = 'endereco1_ENR de teste';
        retornoCIVLiquidacao.serasa.uf2_ENR = 'uf2_ENR de teste';
        retornoCIVLiquidacao.serasa.rg_ENR = 'rg_ENR de teste';
        retornoCIVLiquidacao.serasa.cidade2_ENR = 'cidade2_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_NUMERO1_ENR = 'logr_NUMERO1_ENR de teste';
        retornoCIVLiquidacao.serasa.uf_EMISSAO_ENR = 'uf_EMISSAO_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_TIPO3_ENR = 'logr_TIPO3_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_COMPLEMENTO2_ENR = 'logr_COMPLEMENTO2_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_NOME1_ENR = 'logr_NOME1_ENR de teste';
        retornoCIVLiquidacao.serasa.logr_NOME2_ENR = 'logr_NOME2_ENR de teste';
        retornoCIVLiquidacao.serasa.cidade3_ENR = 'cidade3_ENR de teste';
        retornoCIVLiquidacao.serasa.dddcel3_ENR = 'dddcel3_ENR de teste';
        
        retornoCIVLiquidacao.serasa.logr_TITULO2_ENR = 'Rua Teste';

        retornoCIVLiquidacao.pep = new InformacaoBancariaBO.PepTO();
        retornoCIVLiquidacao.pep.pep = 0;
        retornoCIVLiquidacao.pep.ultimaConsulta = '2022-02-01';
        retornoCIVLiquidacao.pep.dataAtualizacao = '2022-03-01';

        return retornoCIVLiquidacao;
    }
    //MGRC-1252 - FIM - FIX1
}