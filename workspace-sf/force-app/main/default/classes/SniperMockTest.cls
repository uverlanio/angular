/**
 * Teste SniperMock
 * @author Pedro Augusto Braz - Sys4b
 * @Date 24/04/2020
 **/
@isTest
private class SniperMockTest {
    
    
    @isTest static void retornoCivConsultivo(){
        Test.startTest();
            SniperMock.retornoCivConsultivo();
        Test.stopTest();
    }

    @isTest static void retornoSugestaoOrcamento(){
        Test.startTest();
            SniperMock.retornoSugestaoOrcamento();
        Test.stopTest();
    }
    @isTest static void retornoGravaoOrcamento(){
        Test.startTest();
            SniperMock.retornoGravaoOrcamento();
        Test.stopTest();
    }
    @isTest static void retornoTransmissao(){
        Test.startTest();
            SniperMock.retornoTransmissao();
        Test.stopTest();
    }
   
}