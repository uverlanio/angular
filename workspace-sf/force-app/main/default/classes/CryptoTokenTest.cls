//PLV_3743 - INICIO - Classe de teste para cobrir a classe CryptoToken
@isTest
public class CryptoTokenTest {
    
    @isTest
    public static void testEncryptDecrypt(){

        //PLV-4337 - INÍCIO - CORRECAO AMBIENTE
        /*
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';

        insert sCripto;
        */
        //PLV-4337 - FIM

        Test.startTest();
        CryptoToken token = new CryptoToken();

        String testEncry = token.encrypt('teste');

        String testDecry = token.decrypt(testEncry);

        System.assert(testDecry == 'teste');
        Test.stopTest();
    }
    
    // PLV-5188 INICIO
    @isTest
    public static void testEncryptUrlDecryptUrl(){
        Test.startTest();
        CryptoToken tokenUrl = new CryptoToken();
            
        String testEncryUrl = tokenUrl.encryptUrl('testing');
        String testDecryUrl = tokenUrl.decryptUrl(testEncryUrl);

        System.assert(testDecryUrl == 'testing');
        Test.stopTest(); 
    }    
    // PLV-5188 FINAL

}
//PLV-3743 - FIM