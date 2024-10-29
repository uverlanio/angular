/**
 * Test CondicaoCobranca__c
 * @author Fernando Barcellos @ 18/01/2018
 *
 **/
@isTest
private class CondicaoCobrancaTest {
	@isTest
	static void testarVerificacaoExistenciaDuplicidade() {
		Test.startTest();
		
		CondicaoCobranca__c cc = new CondicaoCobranca__c();
		insert cc;
		
        
		Test.stopTest();
	}
}