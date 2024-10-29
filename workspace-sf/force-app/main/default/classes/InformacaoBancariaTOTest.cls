@isTest
private class InformacaoBancariaTOTest {

    @isTest
    static void informacaoBancariaTOTest() {
        
        Test.startTest();
        
        InformacaoBancariaTO ifTO = new InformacaoBancariaTO();
        InformacaoBancariaTO.RetornoNomeSerasaTO rnsTO = new InformacaoBancariaTO.RetornoNomeSerasaTO();
        rnsTO.codigo = '0';
        rnsTO.NOME_ENR = 'teste';

        Test.stopTest();

    }
}