/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de liberação da critica de palavra final atráves do fluxo de repique    *
 * @author : Rogerio Menezes - Globant                                                                                               *
 * @date 06/12/2024                                                                                                                  *
 * Classe implementada tendo como origem a história FNPVVEP-187                                                                      *
 * **************************************************************************************************************************/
public class BatchRepiqueRenovacaoJob implements Schedulable{
    public List<CriticaProposta__c> scope;
    
    public void execute(SchedulableContext SC) {
        System.debug(LoggingLevel.ERROR, scope);
        for (CriticaProposta__c critica : scope) {
            Map<String, Object> flowInputs = new Map<String, Object>{
                'RecordId' => critica.Id 
            };
            
            Flow.Interview flowInterview = Flow.Interview.createInterview('Repique_registros_renovacao', flowInputs);
            flowInterview.start();
        }
        System.abortJob(SC.getTriggerId());
    }
}