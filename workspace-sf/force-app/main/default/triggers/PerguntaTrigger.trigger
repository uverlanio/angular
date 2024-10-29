/*********************************************************************************************************************************************************************

@description  Trigger para acionar toda vez em before insert e before update no objeto "Pergunta"
@author Matheus Takata - Avanxo
@date 21/08/2019
@Trigger criada por conta da história PLV-2578
        
**********************************************************************************************************************************************************************/

trigger PerguntaTrigger on Pergunta__c (before insert, before update) {
	new PerguntaTriggerHandler().run();
}

//PLV-2578 - Fim - Trigger para acionar toda vez em before insert e before update no objeto "Pergunta"