/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de liberação automática de Propostas do tipo Renovação         *
 * @author : Globant                                                                                                        *
 * @date 17/07/2023                                                                                                         *
 * Classe implementada tendo como origem a história RVI-297                                                                 *
 * Disparada através da classe ContratPropRenova, responsável por atualizar as criticas de cada contrato encontrado pela batch                              *
 * **************************************************************************************************************************/
public class ContratPropRenovaJob implements Schedulable{
    public CriticaProposta__c criticaToUpdate;
    
    public void execute(SchedulableContext SC) {
        System.debug(LoggingLevel.ERROR, criticaToUpdate);
        update criticaToUpdate;
        System.abortJob(SC.getTriggerId());
    }
}