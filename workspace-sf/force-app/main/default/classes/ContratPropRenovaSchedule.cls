/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de liberação automática de Propostas do tipo Renovação         *
 * @author : Globant                                                                                                        *
 * @date 19/07/2022                                                                                                         *
 * Classe implementada tendo como origem a história RVI- 150                                                                *
 * Disparada através do Schedule script para 'Liberar Contratação de Propostas de Renovação'                                *
 * **************************************************************************************************************************/
//RVI-150 - INICIO
global with sharing class ContratPropRenovaSchedule implements Schedulable {
    global void execute(SchedulableContext ctx){
        ContratPropRenova.liberarCriticaRenovacao();
    }
}
//RVI-150 - FIM