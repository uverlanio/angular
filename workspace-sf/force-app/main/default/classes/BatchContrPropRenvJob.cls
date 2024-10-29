/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de liberação da critica de palavra final    *
 * @author : Rogerio Menezes - Globant                                                                                                        *
 * @date 08/10/2024                                                                                                         *
 * Classe implementada tendo como origem a história FNPVVEP-117 FIX01                                                            *
 * **************************************************************************************************************************/
public class BatchContrPropRenvJob implements Schedulable{
    public CriticaProposta__c criticaToUpdate;
    
    public void execute(SchedulableContext SC) {
        System.debug(LoggingLevel.ERROR, criticaToUpdate);
        update criticaToUpdate;
        System.abortJob(SC.getTriggerId());
    }
}