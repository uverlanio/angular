/*******************************************************************************************************************************
* Classe de Teste do serviço para atualização do campo PrimeiroContratoRenovacao__c
* @author Squad Novos Ares
* @date 21/08/2022
* Classe criada por conta da história RVI-160
******************************************************************************************************************************/

//RVI-160 - INICIO
@isTest
public class  UptCtrStatusRenScheduleTest {
    @testSetup
    public static void gerarDadosTeste(){ }

    @isTest static void testSchedule(){
        Test.StartTest();
        System.debug('Iniciando o processamento');
        UptCtrStatusRenSchedule schd = new UptCtrStatusRenSchedule();
        String scheduleTest = '0 0 23 ? * *';
		System.debug('Iniciando o comparativo');
        System.schedule('Teste de Job', scheduleTest, schd);
        System.debug('Terminando o comparativo');
        Test.stopTest();
    }
}
//RVI-160 - FIM