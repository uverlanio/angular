/*********************************************************************************************************************************************************************
@description Classe de teste de BO responsável usar metadados utilizados na Batch Reenvio de Contrato
@author Uverlanio Silva - Globant
@date 23/01/2023
**********************************************************************************************************************************************************************/
//LECVP-72 - INICIO
@isTest
private class BCPTcktContratoBOTest {
    @isTest static void testarBCPTcktContratoBO(){

        Test.startTest();
        
        BCPTcktContratoBO.getInstance().init();         

        Test.stopTest();
    }
} 
//LECVP-72 - FIM