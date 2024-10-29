/*********************************************************************************************************************************************************************

@description  Classe que contem a Trigger Profissao.
@author Renan Martins - Avanxo
@date 28/08/2019
@Classe criada por conta da história PLV-2585
        
**********************************************************************************************************************************************************************/


trigger ProfissaoTrigger on Profissao__c(before insert, before update) {

    new ProfissaoHandler().run();

}