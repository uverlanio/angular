@isTest
private class AltFPgtRenSchedulableTest {

    @isTest
    static void testExecute() {

        AltFPgtRenSchedulable schedulable = new AltFPgtRenSchedulable();
        
        Test.startTest();
        schedulable.execute(null);
        Test.stopTest();
        
    }
}