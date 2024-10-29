@isTest
public class EnviaEmailLinkTest {//RVI-262  e RVI-223- INCIO
    
    @TestSetup
    static void makeData(){}
    
    @isTest static void sendLink(){
        String jsonEmail = '{"email":"test@test.com","link":"teste.com","nome":"Teste","proposta":"proposta","corretor":"corretor"}';
        EnviaEmailLink.Input input = EnviaEmailLink.parse(jsonEmail);
        EnviaEmailLink.formatarEmail(input);
    }
}//RVI-262  e RVI-223- FIM