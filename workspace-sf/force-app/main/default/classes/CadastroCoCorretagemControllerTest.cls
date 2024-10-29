/* ------------------------------------------------------------
Author: Alison Sousa
UserStory: ANNI-16
Description: Classe de testes da controller para cadastro de co-corretagem
Historic<Date> <Author ́s name> <Shortly description of update> 
2024-03-05, Alison Sousa, Creation
2024-03-21,Lucas Sousa, Coverade Ajusts (new coverade: 100%) 
------------------------------------------------------------*/

@isTest
public class CadastroCoCorretagemControllerTest {

    @isTest
    static void testValidarSusepError() {
        String susep = '123456';
        String result = CadastroCoCorretagemController.validarSusep(susep);
        System.debug('TESTE +> ' + result);
        System.assertEquals('Invalid Error', result);
    }

    @isTest
    static void testValidarSusep() {

        String susep = '123456';
        String result = CadastroCoCorretagemController.validarSusep(susep, new List<DadosCorretor__c>{new DadosCorretor__c(Name = 'Test')});
        System.assertEquals('Valid value', result);
    }
    
    @isTest
    static void testSalvar() {

        String susepTransmissao = '123456';
        String coCorretagem = '789012';
        Boolean transmissaoLider = true;
        Boolean corretagemLider = false;
        Decimal percentualTransmissao = 60;
        Decimal percentualCoCorretagem = 40;
        
        String result = CadastroCoCorretagemController.salvar(susepTransmissao, coCorretagem, transmissaoLider, corretagemLider, percentualTransmissao, percentualCoCorretagem);
       
        System.assertEquals('Ok', result);
        
        CoCorretagem__c[] corretagens = [SELECT Id FROM CoCorretagem__c WHERE SusepTransmissao__c = :susepTransmissao AND SusepDeCoCorretagem__c = :coCorretagem LIMIT 1];
        System.assertNotEquals(0, corretagens.size(), 'Nenhum registro de CoCorretagem__c foi encontrado após a inserção.');

        ApexPages.StandardController sc = new ApexPages.standardController(corretagens[0]);
        CadastroCoCorretagemController controller = new CadastroCoCorretagemController(sc);

        System.assertEquals(controller.susepDeCoCorretagemLider,corretagemLider);
    }

        
    @isTest
    static void testSalvarError() {

        String susepTransmissao = '123456';
        String coCorretagem = '789012';
        Boolean transmissaoLider = true;
        Boolean corretagemLider = false;
        Decimal percentualTransmissao = 1000;
        Decimal percentualCoCorretagem = 40;
        
        String result = CadastroCoCorretagemController.salvar(susepTransmissao, coCorretagem, transmissaoLider, corretagemLider, percentualTransmissao, percentualCoCorretagem);
       
        System.assertEquals(null, result);
    }
}