@isTest
public class QuoteControllerTest {

    @testSetup
    static void setupData() {
        Map<String, Sobject> records = CreateTestData.createIntegratedScenario();
    }

    @isTest
    static void testGetQuoteDetails() {
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        Map<String, Object> result = QuoteController.getQuoteDetails(testQuote.Id);
        Test.stopTest();

        System.assertEquals('Em criação', result.get('status'), 'O status deve corresponder');
        System.assertEquals(false, result.get('linkExpirado'), 'O linkExpirado deve corresponder');
    }

}