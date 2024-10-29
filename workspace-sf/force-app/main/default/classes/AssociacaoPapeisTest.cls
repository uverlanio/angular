@isTest
private class AssociacaoPapeisTest {
    //PVL-4445 INICIO
    @TestSetup
    static void makeData(){
        Account conta = new Account();
        conta.Name = 'Maria';
        conta.Papel__c = 'Parceiro;Corretor;Agenciador;Representante de Seguros;';
		conta.CodigoSusepCorretor__c = '1';
		conta.Sucursal__c = '2';
		conta.CodigoSusepCia__c = '3';
		conta.ServicosParceiro__c = '545';
        conta.NumeroContratoParceiro__c = '000';
         // PLV-4472 INICIO
        conta.Inscricao_Municipal__c = '123456789';
        conta.Cnpj__c = '38.579.897/0001-22';
        // PLV-4472 FIM
		insert conta;
		
        //PLV-4363 - INICIO
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '341';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'BANCO ITAU S/A';
        banconew.Ativo__c = true;
        insert banconew; 
		//PLV-4363 - FIM
    }
	
	@isTest 
	static void buscarContaPapelTest() {
        Test.startTest();
        Account conta = getAccount();
        AssociacaoPapeisController.buscarContaPapel(conta.Id);
		System.assertEquals(conta.Papel__c, 'Parceiro;Corretor;Agenciador;Representante de Seguros;');
        Test.stopTest();
    }

    @isTest 
	static void buscarServicosPapelTest() {
        Test.startTest();
        String servicos = AssociacaoPapeisController.buscarServicosPapel();
		System.assert(String.isNotBlank(servicos));
        Test.stopTest();
    }

    @isTest 
	static void salvarPapeisTest() {
        ValidarComposicaoBancariaTO validarComposicaoBancaria = new ValidarComposicaoBancariaTO();
    	validarComposicaoBancaria.status = 0;
		validarComposicaoBancaria.codigo = '';
		validarComposicaoBancaria.mensagem = '';
		validarComposicaoBancaria.dataOcorrencia  = '';
		validarComposicaoBancaria.fonte = '';
		validarComposicaoBancaria.tipo = '';
		validarComposicaoBancaria.additionalInfo = '';

    	validarComposicaoBancaria.DadosBancarios = new ValidarComposicaoBancariaTO.DadosBancarios();
		validarComposicaoBancaria.DadosBancarios.banco = '341';
		validarComposicaoBancaria.DadosBancarios.agencia = '2332';
		validarComposicaoBancaria.DadosBancarios.contaCorrente = '1234545';
		validarComposicaoBancaria.DadosBancarios.digitoContaCorrente = '5';

    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(validarComposicaoBancaria), 200, 'OK'));

        Test.startTest();
        Account conta = getAccount();
        Banco__c banco = getBanco();
		AssociacaoPapeisController.salvarPapeis(conta, new List<InformacaoBancaria__c>{ 
        	new InformacaoBancaria__c(Papel__c = 'Parceiro', Banco__c = '341', Agencia__c = '2332', NumeroConta__c = '1234545', Digito__c = '5', Conta__c = conta.Id, BancoNew__c = banco.Id), //PLV-4363 - INICIO/FIM
        	new InformacaoBancaria__c(Papel__c = 'Agenciador', Banco__c = '341', Agencia__c = '2332', NumeroConta__c = '1234548', Digito__c = '5', Conta__c = conta.Id, BancoNew__c = banco.Id) //PLV-4363 - INICIO/FIM
        });

        List<InformacaoBancaria__c> info = [Select Id From InformacaoBancaria__c Where Conta__c =: conta.Id];
		System.assert(!info.isEmpty());
        Test.stopTest();
    } 

    @isTest 
	static void salvarPapeisDadosBancariosInvalidosTest() {
        ValidarComposicaoBancariaTO validarComposicaoBancaria = new ValidarComposicaoBancariaTO();
		validarComposicaoBancaria.codigo = '';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(validarComposicaoBancaria), 200, 'OK'));

        Test.startTest();
        Account conta = getAccount();
        Banco__c banco = getBanco();
		try {
            //Dados Bancários Inválidos
            AssociacaoPapeisController.salvarPapeis(conta, new List<InformacaoBancaria__c>{ 
                new InformacaoBancaria__c(Papel__c = 'Parceiro', Banco__c = '341', Agencia__c = '2332', NumeroConta__c = '1234545', Digito__c = '5', Conta__c = conta.Id, BancoNew__c = banco.Id), //PLV-4363 - INICIO/FIM
                new InformacaoBancaria__c(Papel__c = 'Agenciador', Banco__c = '341', Agencia__c = '2332', NumeroConta__c = '1234548', Digito__c = '5', Conta__c = conta.Id, BancoNew__c = banco.Id) //PLV-4363 - INICIO/FIM
            });
        } catch (Exception ex) {
            //catch thrown aura exception
        }
        Test.stopTest();
    } 

    @isTest 
	static void salvarPapeisBancoNaoEncontradoTest() {
        ValidarComposicaoBancariaTO validarComposicaoBancaria = new ValidarComposicaoBancariaTO();
    	validarComposicaoBancaria.status = 0;
		validarComposicaoBancaria.codigo = '';
		validarComposicaoBancaria.mensagem = '';
		validarComposicaoBancaria.dataOcorrencia  = '';
		validarComposicaoBancaria.fonte = '';
		validarComposicaoBancaria.tipo = '';
		validarComposicaoBancaria.additionalInfo = '';

    	validarComposicaoBancaria.DadosBancarios = new ValidarComposicaoBancariaTO.DadosBancarios();
		validarComposicaoBancaria.DadosBancarios.banco = '341';
		validarComposicaoBancaria.DadosBancarios.agencia = '2332';
		validarComposicaoBancaria.DadosBancarios.contaCorrente = '1234545';
		validarComposicaoBancaria.DadosBancarios.digitoContaCorrente = '5';

    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(validarComposicaoBancaria), 200, 'OK'));

        Test.startTest();
        Account conta = getAccount();
        Banco__c banco = getBanco();

        try {
            AssociacaoPapeisController.salvarPapeis(conta, new List<InformacaoBancaria__c>{ 
                new InformacaoBancaria__c(Papel__c = 'Parceiro', Banco__c = '123', Agencia__c = '2332', NumeroConta__c = '1234545', Digito__c = '5', Conta__c = conta.Id), //PLV-4363 - INICIO/FIM
                new InformacaoBancaria__c(Papel__c = 'Agenciador', Banco__c = '123', Agencia__c = '2332', NumeroConta__c = '1234548', Digito__c = '5', Conta__c = conta.Id) //PLV-4363 - INICIO/FIM
            });
        } catch (Exception ex) {
            //catch thrown aura exception

        }
        Test.stopTest();
    } 

    
    @isTest 
    static void excluirPapelTest() {
        Test.startTest();
        Account conta = getAccount();
    	AssociacaoPapeisController.excluirPapel(conta.Id, 'Parceiro');
    	AssociacaoPapeisController.excluirPapel(conta.Id, 'Corretor');
    	AssociacaoPapeisController.excluirPapel(conta.Id, 'Agenciador');
        AssociacaoPapeisController.excluirPapel(conta.Id, 'Representante de Seguros');
        conta = AssociacaoPapeisController.buscarContaPapel(conta.Id);
    	System.assertEquals(conta.Papel__c, null);
    	System.assertEquals(conta.ServicosParceiro__c, null);
        Test.stopTest();
    }

    private static Banco__c getBanco() {
        return [
            SELECT Id
                ,CodigoBanco__c
                ,ConveniadoADC__c
                ,Name
                ,Ativo__c
            FROM Banco__c
            LIMIT 1
        ] ;
    }
    
    private static Account getAccount() {
        return [
            SELECT Id
                ,Name
                ,Papel__c
                ,CodigoSusepCorretor__c
                ,Sucursal__c
                ,CodigoSusepCia__c
                ,ServicosParceiro__c
                ,NumeroContratoParceiro__c
            FROM Account
            LIMIT 1
        ] ;
    }
    //PLV-4445 FIM
}