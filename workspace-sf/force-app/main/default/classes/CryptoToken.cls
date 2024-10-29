//PLV-3743 - INICIO - Classe de criptografia
public class CryptoToken {

    private AlgorithmType algorithm;
    private SenhaCriptografia__c customSetting = SenhaCriptografia__c.getValues('Senha');
    private String senha;

    public CryptoToken() {
        this(AlgorithmType.AES128);
    }

    public CryptoToken(AlgorithmType algorithm) {
        this.algorithm = algorithm;
        this.senha = this.customSetting.Senha__c;
        //PLV-4337 - INÍCIO - CORRECAO AMBIENTE
        if(Test.isRunningTest() && SenhaCriptografia__c.getValues('Senha') == null){
            SenhaCriptografia__c setting = new SenhaCriptografia__c();
            setting.Name = 'Senha';
            setting.Senha__c = 'P@ssword';
            insert setting;
            this.senha = SenhaCriptografia__c.getValues('Senha').Senha__c;
        }
        //PLV-4337 - FIM
    }

    private Blob getPasswd(){
        return Blob.valueOf(this.senha);
    }
    
    // PLV-5188 INICIO
    
    // public String encrypt(String data){
    //     Blob blobData = Blob.valueOf(data);
    //     Blob key = this.getPrivateKey();
    //     String algorithm = this.algorithm.name();
    //     Blob blobResult = Crypto.encryptWithManagedIV(algorithm, key, blobData);
    //     String base64 = EncodingUtil.base64Encode(blobResult).replace('/', ',,').replace('+', '..');//PLV-5008 INICIO/FIM
    //     return base64;//PLV-5008 INICIO/FIM
    // }

    // public String decrypt(String encrypted){
    //     encrypted = encrypted.replace(',,','/').replace('..', '+');//PLV-5008 INICIO/FIM
    //     Blob blobData = EncodingUtil.base64Decode(encrypted);
    //     Blob key = this.getPrivateKey();
    //     String algorithm = this.algorithm.name();
    //     Blob blobResult = Crypto.decryptWithManagedIV(algorithm, key, blobData);
        
    //     return blobResult.toString();
    // }

    //PLV-5188 - FIX04 - INICIO
    public String encrypt(String data){
        return encryptGeneric(data, new List<List<String>> { new String[]{'/', ',,'}, new String[]{'+', '..'} })   ;//PLV-5008 INICIO/FIM
    }
    public String encryptUrl(String data){
        return encryptGeneric(data, new List<List<String>>{ 
                                        new String[]{'/', '~~'},    //PLV-5188 - FIX07 - INICIO / FIM  
                                        new String[]{'+', '$$'} })   ;
    }
    public String decrypt(String encrypted){        
        return decryptGeneric(encrypted, new List<List<String>> { new String[]{',,', '/'}, new String[]{'..', '+'} });//PLV-5008 INICIO/FIM
    }
    public String decryptUrl(String encrypted){     
        //PLV-5188 - FIX07 - INICIO   
        //PLV-5188 - FIX06 - INICIO  
        return decryptGeneric(encrypted, new List<List<String>>{ 
                                            new String[]{'~~', '/'}, 
                                            new String[]{'$$', '+'} });
        //PLV-5188 - FIX06 - FIM
        //PLV-5188 - FIX07 - FIM  
    }
    //PLV-5188 - FIX04 - FIM

    private String encryptGeneric(String data, List<List<String>> charsToChange){ //PLV-5188 - FIX04 - INICIO/FIM
        Blob blobData = Blob.valueOf(data);
        Blob key = this.getPrivateKey();
        String algorithm = this.algorithm.name();
        Blob blobResult = Crypto.encryptWithManagedIV(algorithm, key, blobData);
        //PLV-5188 - FIX04 - INICIO
        String base64 = EncodingUtil.base64Encode(blobResult);
        for (List<String> chars: charsToChange) { //chFrom = chars[0], chTo = chars[1]
            base64 = base64.replace(chars[0], chars[1]); 
        }
        //PLV-5188 - FIX04 - FIM
        return base64;//PLV-5008 INICIO/FIM
    }

    //PLV-5188 - FIX04 - INICIO
    private String decryptGeneric(String encrypted, List<List<String>> charsToChange){
        for (List<String> chars: charsToChange) { //chFrom = chars[0], chTo = chars[1]
            encrypted = encrypted.replace(chars[0], chars[1]); 
        } 
        //PLV-5188 - FIX04 - FIM
        Blob blobData = EncodingUtil.base64Decode(encrypted);
        Blob key = this.getPrivateKey();
        String algorithm = this.algorithm.name();
        Blob blobResult = Crypto.decryptWithManagedIV(algorithm, key, blobData);
        return blobResult.toString();
    }

    //PLV-5188 FINAL

    private Blob getPrivateKey(){
		return Crypto.generateDigest('MD5', this.getPasswd());
	}

    public Enum AlgorithmType{
        AES128, AES192, AES256
    }
}
//PLV-3743 - FIM