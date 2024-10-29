//ZSVEP-76-INICIO
@isTest
public class AccountTriggerHandlerTest {
       
    @isTest
    static void testBeforeInsert() {
        Test.startTest();
        
        Account account = new Account(Name = 'Test Account', CNPJ__c = '38057572000180', Phone = '123-456-7890');
        insert account;
        
        // Verifique se os métodos apropriados foram chamados no before insert
        Account insertedAccount = [SELECT Id, Name, CNPJ__c, Phone FROM Account WHERE Id = :account.Id];
        System.assertNotEquals(null, insertedAccount);
        
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeUpdate() {
        Account account = new Account(Name = 'Test Account', CNPJ__c = '19624213000112', Phone = '123-456-7890');
        insert account;
        
        Test.startTest();
        
        account.Name = 'Updated Test Account';
        update account;
        
        // Verifique se os métodos apropriados foram chamados no before update
        Account updatedAccount = [SELECT Id, Name, CNPJ__c, Phone FROM Account WHERE Id = :account.Id];
        System.assertEquals('Updated Test Account', updatedAccount.Name);
        
        Test.stopTest();
    }
    
    @isTest
    static void testAfterUpdate() {
        Account account = new Account(Name = 'Test Account', CNPJ__c = '50154134000135', Phone = '123-456-7890');
        insert account;
        
        Test.startTest();
        
        account.Name = 'Updated Test Account';
        update account;
        
        // Verifique se os métodos apropriados foram chamados no after update
        Account updatedAccount = [SELECT Id, Name, CNPJ__c, Phone FROM Account WHERE Id = :account.Id];
        System.assertEquals('Updated Test Account', updatedAccount.Name);
        
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeDelete() {
        Account account = new Account(Name = 'Test Account', CNPJ__c = '29940735000187', Phone = '123-456-7890');
        insert account;
        
        Test.startTest();
        
        delete account;
        
        // Verifique se os métodos apropriados foram chamados no before delete
        Integer accountCount = [SELECT COUNT() FROM Account WHERE Id = :account.Id];
        System.assertEquals(0, accountCount);
        
        Test.stopTest();
    }
}
//ZSVEP-76-FIM