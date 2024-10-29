/*********************************************************************************************************************************************************************
@description Classe de teste de BO responsável usar metadados utilizados na Batch Baixar Assist Card
@author Uverlanio Silva - Globant
@date 31/05/2023
**********************************************************************************************************************************************************************/
//LECVP-318 - INICIO
@isTest
private class BaixarAssistCardBOTest {
    @isTest static void testarBaixarAssistCardBO(){

        Test.startTest();
        
        BaixarAssistCardBO.getInstance().agendarExecucao();         

        Test.stopTest();
    }
}
//LECVP-318 - FIM