/**************************************************************************************************************************
 * Classe implementada para garantir que uma proposta de renovação, com a forma de pagamento cartão, não se perca         *
 * no processo de Renovação originada pela tarefa RVI-171                                                                 *                                                                                             *
 * @author : Globant                                                                                                      *
 * @date   : 16/01/2022                                                                                                   *
 * Schedule 'AltFPgtRenSchedulable'                                                                                       *
 * ************************************************************************************************************************/

 global with sharing class AltFPgtRenSchedulable implements Schedulable {
    
    global void execute(SchedulableContext ctx){
        //UptFormPagPropRen.altFPgt(); //FNPVVEP-172 INICIO/FIM
    }
}