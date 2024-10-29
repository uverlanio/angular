/*********************************************************************************************************************************************************************

@description  Classe criada para cobertura da classe PerguntaBO.
@author Matheus Takata - Avanxo
@date 21/08/2019
@Classe criada por conta da história PLV-2578
        
**********************************************************************************************************************************************************************/

@isTest
public class PerguntaTest {
	
    @isTest
    static void preencherPerguntaResumida() {
        Pergunta__c pgt = new Pergunta__c();
        pgt.Id = pgt.Id;
        pgt.Pergunta__c = 'Qual seria a pergunta?';
        pgt.TipoResposta__c = 'Texto';
        
        insert pgt;
        
        // PLV-4921-INICIO
        // PLV-3667 - INICIO
        pgt.Pergunta__c = 'A pergunta ainda é a mesma?';
        update pgt;
        // PLV-3667 - FIM
        // PLV-4921-FIM
    }
}

//PLV-2578 - Fim - Classe criada para cobertura da classe PerguntaBO.