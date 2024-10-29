@isTest
private class LookupControllerTest {
	
	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        dadosSearchText();
	}

    @isTest
    public static void dadosSearchText(){
    	Map<String,String> mapFieldsController = new Map<String,String>();
    	mapFieldsController.put('Name', 'Name');
    	List<Account> searchText = LookupController.searchText('Conta', 'Account', null, mapFieldsController);
    	System.assertEquals(0, searchText.size());
    }
	
}