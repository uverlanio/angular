/****************************************************************************************************************************
* Classe de Negocio implementada para o processo automático de alteração automática de Status de Renovação do contrato     *
* @author : Globant                                                                                                        *
* @date 21/08/2022                                                                                                         *
* Classe implementada tendo como origem a história RVI- 160                                                                *
* Disparada através do Schedule script para 'Atualizar status renovação do contato'                                        *
* **************************************************************************************************************************/

//RVI-160 - INICIO
global with sharing class UptCtrStatusRenSchedule implements Schedulable {
    global void execute(SchedulableContext ctx){
        UptCtrStatusRen.atualizarStatusRenovacao();
    }
}
//RVI-160 - FIM