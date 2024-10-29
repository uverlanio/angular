public class SequenciaMovimentoSinistroHelper {

	//AVX SP 28 - PLV 2296
    public static Map<Id, Integer> sequenciaMovimentos(Set<Id> sCasos) {

    	Map<Id, Integer> mapQtdCaso = new Map<Id, Integer>();

    	for(AggregateResult ar : [SELECT Caso__c, COUNT(Id) total
    							  FROM MovimentoSinistro__c 
    							  WHERE Caso__c IN :sCasos
    							  GROUP BY Caso__c]) {
    		mapQtdCaso.put((Id)ar.get('Caso__c'), (Integer)ar.get('total'));
    	}		

    	if(mapQtdCaso.isEmpty()) return null;
    	return mapQtdCaso;
    }
}