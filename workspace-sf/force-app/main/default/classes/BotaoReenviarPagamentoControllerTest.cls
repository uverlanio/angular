@isTest
private class  BotaoReenviarPagamentoControllerTest {

	//INICIO | PLV-2376-29
	private static Integer idPagamento;

    @testSetup
    private static void setup(){
       TestDataFactory.gerarConta();
        
    }

	
	@isTest
	private static void testarReenviarPagamentoComErro() {

	    List<Account> lst = [SELECT Id FROM Account limit 5];
        Account conta = lst[0];

        Pagamento__x pgto = TestDataFactory.mapeiaPagamento(conta, 'EM REPROCESSAMENTO');
        idPagamento = Integer.valueOf(pgto.Id__c);
		PagamentoDAO.mockedPagamentos.add(pgto);
		Test.startTest();

	    String retornoConsulta = BotaoReenviarPagamentoController.reenviarPagamento(pgto.Id);
	    Test.stopTest();

		System.assert(String.isNotBlank(retornoConsulta));
	}

	@isTest
	private static void testarReenviarPagamento() {

		Test.startTest();
	   List<Account> lst = [SELECT Id FROM Account limit 5];
        Account conta = lst[0];

        Pagamento__x pgto = TestDataFactory.mapeiaPagamento(conta, 'ERRO');
        idPagamento = Integer.valueOf(pgto.Id__c);
		PagamentoDAO.mockedPagamentos.add(pgto);

	    String retornoConsulta = BotaoReenviarPagamentoController.reenviarPagamento(pgto.Id);
	    Test.stopTest();

		System.assert(String.isNotBlank(retornoConsulta));
	}
	//FIM | PLV-2376-29
}