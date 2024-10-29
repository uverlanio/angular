/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de alteração de Status de Propostas que já foram liberadas     *
 * @author : Globant                                                                                                        *
 * @date 27/12/2023                                                                                                         *
 * Classe implementada tendo como origem a história PLV-5856                                                                *
 * **************************************************************************************************************************/
public class BatchReestimuloPropostaJob implements Schedulable{
    public Quote quoteToUpdate;
    
    public void execute(SchedulableContext SC) {
        System.debug(LoggingLevel.ERROR, quoteToUpdate);
        update quoteToUpdate;
        System.abortJob(SC.getTriggerId());
    }
}