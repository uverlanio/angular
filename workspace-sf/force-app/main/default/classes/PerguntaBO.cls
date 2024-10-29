/*********************************************************************************************************************************************************************

@description  Classe para preencher o campo Pergunta Resumida e assim utiliza-lá para o Lookup no objeto "Pergunta do questionário".
@author Matheus Takata - Avanxo
@date 21/08/2019
@Classe criada por conta da história PLV-2578
        
**********************************************************************************************************************************************************************/

public class PerguntaBO {
	private static final PerguntaBO instance = new PerguntaBO();
    public static PerguntaBO getInstance() {return instance; }
    
    public void preencherResumoPergunta(List<Pergunta__c> plPerguntaNew, Map<Id,Pergunta__c> pmPerguntaOld) {
        for(Pergunta__c pgtNew : plPerguntaNew) {
            
            Pergunta__c pgtOld = Trigger.isUpdate ? pmPerguntaOld.get(pgtNew.Id) : null;

            if (String.isEmpty(pgtNew.Pergunta__c) || (Trigger.isUpdate && pgtNew.Pergunta__c == pgtOld.Pergunta__c)) continue;
            
            pgtNew.PerguntaResumida__c = pgtNew.Pergunta__c.left(80);
        }
    }
}

//PLV-2578 - Fim - Classe para preencher o campo Pergunta Resumida e assim utiliza-lá para o Lookup no objeto "Pergunta do questionário".