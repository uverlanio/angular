/*********************************************************************************************************************************************************************
@description Classe BO que testa agendamento da batch.
@author Uverlanio Silva - Globant
@date 25/09/2023
**********************************************************************************************************************************************************************/
//RVI-297 - INICIO
@isTest
private class BatchContrPropRenvBOTest {
    
    @isTest static void testarAgendamentoBatch(){

        Test.startTest();
        
        BatchContrPropRenvBO.getInstance().init();    

        Test.stopTest();
    }
} 
//RVI-297 - FIM