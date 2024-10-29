@IsTest
public class jsonTokenConsultaMoedaTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"access_token\": \"9630819c-0709-422e-9e66-d812d7b6cd00\",'+
		'    \"token_type\": \"Bearer\",'+
		'    \"expires_in\": 3600,'+
		'    \"scope\": \"oob\"'+
		'}';
		jsonTokenConsultaMoeda obj = jsonTokenConsultaMoeda.parse(json);
		System.assert(obj != null);
	}
}