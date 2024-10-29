@isTest
private class CartaoCreditoTriggerHandlerTest {
	
	@isTest
	
	static void testUnit() {

		CartaoCredito__c cartaoCredito = (CartaoCredito__c) new CartaoCreditoFactory.PessoaFisica().createRecord();
		CartaoCredito__c cartaoCreditoClone = cartaoCredito.clone(false);

		try {
			
			insert cartaoCreditoClone;
	
		} catch (DmlException e) {

			System.assert(e.getMessage().contains('DUPLICATE_VALUE'));
		}
		
        cartaoCreditoClone.NumeroCartao__c = '1111.2222.3333.4444';
		//PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
		cartaoCreditoClone.ticket__c = '4444';
		//PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF
		insert cartaoCreditoClone;
		cartaoCreditoClone.NumeroCartao__c = '1111.2222.3333.5555';
		//PLV_2822 - INICIO - Informações do cartão de crédito não podem ser armazenadas no SF
		cartaoCreditoClone.ticket__c = '5555';
		//PLV_2822 - FIM - Informações do cartão de crédito não podem ser armazenadas no SF
		update cartaoCreditoClone;
		System.assertEquals(2, [SELECT COUNT() FROM CartaoCredito__c]);
	}
	//PLV-4926 - INICIO - PEDRO AUGUSTO BRAZ
	@isTest
	static void testarBandeiras() {
		List<String> cartoes= new List<String>();
		cartoes.add('378282246310005');				     // American Express
		cartoes.add('371449635398431');				     // American Express
		cartoes.add('5078601870000127985');				 // Aura
		cartoes.add('5078601800003247449');				 // Aura
		cartoes.add('30569309025904');				     // Diners Club
		cartoes.add('38520000023237');				     // Diners Club
		cartoes.add('6011111111111117');				 // Discover
		cartoes.add('6362970000457013');				 // Elo
		cartoes.add('6062825624254001');				 // Hipercard
		cartoes.add('5555555555554444');				 // MasterCard
		cartoes.add('5105105105105100');				 // MasterCard
		cartoes.add('6759649826438453');				 // Maestro
		cartoes.add('6799990100000000019');				 // Maestro
		cartoes.add('4111111111111111');				 // Visa
		cartoes.add('4012888888881881');				 // Visa

		for(String card :  cartoes){
			String retorno = CartaoCreditoTriggerHandler.verificarBandeira('MASTERCARD', card); // VIAG-152
			System.assert(!retorno.equalsIgnoreCase('não identificado'));
		}
	}
	//PLV-4926 - FIM - PEDRO AUGUSTO BRAZ
}