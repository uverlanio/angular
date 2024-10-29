/****************************
@description  Classe de teste para a classe CreditCardInformationController
@author Andreza R. e Luiz N. - SYS4B
@date 12/02/2023
@Classe de teste criada por conta da história RVI-223        
****************************/

@isTest
public class CreditCardInformationControllerTest {

    @IsTest
    static void testLinkValidations() {

        Profile p = [SELECT Id, Name FROM Profile LIMIT 1];

        User u = new User();
        u.ProfileId = p.Id;
        u.Username = 'userlink@example.com';
        u.Email = 'userlink@example.com';
        u.LastName = 'userlink';
        u.FirstName = 'userlink';
        u.Alias = 'userlink';
        u.TimeZoneSidKey = 'America/Sao_Paulo';
        u.LocaleSidKey = 'pt_BR';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'pt_BR';
        insert u;

        System.runAs(u) {
            String profileName = CreditCardInformationController.linkValidations();
            System.assertNotEquals(profileName, null);
        }
    }

    @IsTest
    static void testResendLinkCard() {
        String dadosProposta = '{"qtdeParcelas":5,"premioTotal":5.5,"numeroProposta":"5"}'; //RVI-294
        String dadosEmailRequest = '{"nome":"TESTE NOME","proposta":"PROP TESTE","email":"propsota@proposta.com","corretor":"corretor prop","link":""}';
        CreditCardInformationController.resendLinkCard(dadosEmailRequest, dadosProposta);
    }
}
// RVI-223 - FIM