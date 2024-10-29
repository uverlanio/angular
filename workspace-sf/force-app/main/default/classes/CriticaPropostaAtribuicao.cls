//INICIO | PLV-4517
/*
*  @author Squad Avanxo 
*  @Descrição: Logica de atribuicao das Filas
*/
public class CriticaPropostaAtribuicao {
    
    public static void AtribuirFilas(List<CriticaProposta__c> lstCriticaProposta, Map<Id, CriticaProposta__c> mapOld){
        
        Map<String,Id> mapFila = new Map<String,Id>();
        for(QueueSobject fila :[SELECT QueueID, Queue.developerName FROM QueueSObject WHERE SobjectType = 'CriticaProposta__c' AND Queue.developerName IN ('Filaaceitacao', 'Filaemissao', 'FilaPalavrafinalaceitacao', 'Fila_Renovacao')]){ //FNPVVEP-124 INICIO/FIM
            mapFila.put(fila.Queue.developerName, fila.QueueID);
        }

        //FNPVVEP-124 INICIO
        List<CriticaProposta__c> criticasFilaRenovacao = new List<CriticaProposta__c>();
        Set<id> idPropostas = new Set<id>();
        //FNPVVEP-124 FIM

        for(CriticaProposta__c critica : lstCriticaProposta){
            CriticaProposta__c criticaOld = mapOld.get(critica.Id);
            if(critica.Status__c != criticaOld.Status__c || critica.MomentoAnalise__c != criticaOld.MomentoAnalise__c 
               || critica.Setor__c != criticaOld.Setor__c || critica.Integracao__c != criticaOld.Integracao__c){

                // PLV-4619-VI - Inicio - Isabela Fin - Globant
                // Fila Aceitação
                if((critica.Status__c == 'Pendente' && critica.MomentoAnalise__c == 'Análise interna' && critica.Setor__c == 'Aceitação')
                || ((critica.Status__c == 'Pendente' || critica.Status__c == 'Em aprovação') && critica.MomentoAnalise__c == 'Resseguro')
                || (critica.Status__c == 'Pendente' && critica.MomentoAnalise__c == 'Recalculo' && critica.Setor__c == 'Aceitação')
                || (critica.Status__c == 'Inconclusiva' && critica.MomentoAnalise__c == 'Subscrição')){
                    critica.OwnerId = mapFila.get('Filaaceitacao');
                }
                // Fila Emissão
                else if((critica.Status__c == 'Pendente' && critica.MomentoAnalise__c == 'Análise interna' && critica.Setor__c == 'Emissão')
                    || (critica.Status__c == 'Pendente' && critica.MomentoAnalise__c == 'Recalculo' && critica.Setor__c == 'Emissão')
                    || (critica.Status__c == 'Em aprovação' && critica.Integracao__c == 'DOCUSIGN')){
                    critica.OwnerId = mapFila.get('Filaemissao');
                }
                // PLV-4619-VI - Fim - Isabela Fin - Globant

                // Fila Palavra Final
                else if(critica.Status__c == 'Pendente' && critica.MomentoAnalise__c == 'Palavra final'){
                    critica.OwnerId = mapFila.get('FilaPalavrafinalaceitacao');
                }

                //FNPVVEP-124 INICIO
                else if(critica.Status__c == 'Falha na Integração' && critica.MomentoAnalise__c == 'Palavra final'){
                    criticasFilaRenovacao.add(critica);
                    idPropostas.add(critica.proposta__c);
                }
            }
        }

        Map<Id, Quote> mapPropostas = new Map<Id, Quote>([SELECT Id, Tipo__c FROM Quote WHERE Id IN :idPropostas AND Tipo__c = 'Renovacao']);

        for(CriticaProposta__c critica : criticasFilaRenovacao){
            if(mapPropostas.containsKey(critica.proposta__c)){
                critica.OwnerId = mapFila.get('Fila_Renovacao');
            }
        }
        //FNPVVEP-124 FIM
    }
    //VEP-141 - INICIO - PEDRO AUGUSTO BRAZ
    public static void AtribuirFilasPrioritarias(List<CriticaProposta__c> lstCriticaProposta){
        
        Map<String,Id> mapFila = new Map<String,Id>();
        Map<Id,Quote> mapIdProposta = new Map<Id,Quote>();
        for(QueueSobject fila :[SELECT QueueID, Queue.developerName FROM QueueSObject WHERE SobjectType = 'CriticaProposta__c' AND Queue.developerName IN ('Fila_Propostas_Prioritarias')]){
            mapFila.put(fila.Queue.developerName, fila.QueueID);
        }
        //passa a primeira vez para pegar todos os ids de proposta
        for(CriticaProposta__c critica : lstCriticaProposta){
            System.debug('CRITICA' + critica);
            if(!mapIdProposta.containsKey(critica.proposta__c))
            mapIdProposta.put(critica.Proposta__c, null);
        }
        
        mapIdProposta = new Map<Id,Quote>([SELECT Id , NR__c FROM QUOTE WHERE Id IN :mapIdProposta.keyset()]);
        
        
        for(CriticaProposta__c critica : lstCriticaProposta){
            if(mapIdProposta.get(critica.proposta__c).NR__c=='5' || mapIdProposta.get(critica.proposta__c).NR__c=='6')
            critica.OwnerId = mapFila.get('Fila_Propostas_Prioritarias');
        }
    }
    //VEP-141 - FIM - PEDRO AUGUSTO BRAZ
}
//FIM | PLV-4517