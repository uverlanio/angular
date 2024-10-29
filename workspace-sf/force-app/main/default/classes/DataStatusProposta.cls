//PLV-5436 - INCIO
/*
*  @author Angelo Henrique Almeida
*  @Descrição: Salvar a data que o status foi modificado
*/
public class DataStatusProposta {
    public static String dataAtual = String.valueOf(System.now());
    public static void dataStatus(List<Quote> lstQuotes, Map<Id, Quote> mapQuoteOld){
        List<String> lstStatus = new List<String>{'Em aprovação','Pendente'};
        Map<Id, Quote> mapProposta = new Map<Id, Quote>();
        for(Quote proposta : lstQuotes){
            Quote propostaOld = mapQuoteOld.get(proposta.Id);
            if(proposta.Status != propostaOld.Status){
                mapProposta.put(proposta.Id, proposta);
            }
        }
        if(mapProposta.size() > 0) {
            List<Quote> propostasFull = [
                SELECT Id
                    ,CreatedDate
                    ,DataFaseStatus__c
                    ,DataStatusAguardandoAnalise__c
                    ,DataStatusContratada__c
                    ,DataStatusDevolvida__c
                    ,DataStatusDisponivelContratacao__c
                    ,DataStatusEmAnalise__c
                    ,DataStatusRecusada__c
                    ,FaseStatus__c
                    ,Status
                    ,(SELECT Id,Codigo__c,Descricao__c,Status__c FROM CriticasProposta__r WHERE Status__c IN:lstStatus)
                FROM Quote
                WHERE Id IN : mapProposta.KeySet()
                LIMIT 10000
            ];
            if (propostasFull != null && propostasFull.size() > 0) {
                List<Quote> propostaToUpdate = new List<Quote>();
                for (Quote proposta : propostasFull) {
                    if(proposta.Status == 'Recusada'){
                        proposta.DataStatusRecusada__c  = dataAtual;
                    }
                    if(proposta.Status == 'Devolvida'){
                        proposta.DataStatusDevolvida__c  = dataAtual;
                    }
                    if(proposta.Status == 'Contratada'){
                        proposta.DataStatusContratada__c  = dataAtual;
                    }
                    if(proposta.Status == 'Disponível para contratação'){
                        proposta.DataStatusDisponivelContratacao__c  = dataAtual;
                    }
                    if(proposta.Status == 'Em análise'){
                        proposta.DataStatusEmAnalise__c  = dataAtual;
                        if(!proposta.CriticasProposta__r.isEmpty()){
                            proposta.DataFaseStatus__c = getStatusCritica(proposta);
                        }
                    }
                    if(proposta.Status == 'Aguardando análise'){
                        proposta.DataStatusAguardandoAnalise__c = dataAtual;
                    }
                    propostaToUpdate.add(proposta);
                }
                if (propostaToUpdate.size() > 0) {
                    update propostaToUpdate;
                }
            }
        }
    }
    private static String getStatusCritica(Quote proposta){
        String finalStatus = '';
        if(proposta != null && proposta.CriticasProposta__r.size() > 0 && !Test.isRunningTest()){
            for(CriticaProposta__c critica : proposta.CriticasProposta__r){
                Integer codigo = Integer.valueOf(critica.Codigo__c);
                if(codigo >= 70 && codigo <= 73){
                    finalStatus = 'Pendente de preenchimento de Questionário - ' + dataAtual;
                }
                else if(codigo >= 74 && codigo <= 77){
                    finalStatus = 'Tentativa de agendamento para Tele-Entrevista - ' + dataAtual;
                }
                else if(codigo == 78 || codigo == 79){
                    finalStatus = 'Tentativa de agendamento para Video-Entrevista - ' + dataAtual;
                }
                else if(codigo == 109){
                    finalStatus = 'Pendente de assinatura Eletrônica - ' + dataAtual;
                }
            }
        }
        return finalStatus;
    }
}
//PLV-5436 - FIM