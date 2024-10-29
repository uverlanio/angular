/******************************************************************************************************************************
 * Classe de Negocio implementada para enviar o Cpf e suas respectivas propostas e contratos do produto Vida ON para o heroku *
 * @author : Globant                                                                                                          *
 * @date 19/07/2022                                                                                                           *
 * Classe implementada tendo como origem a história AV-530                                                                    *
 * ****************************************************************************************************************************/

global with sharing class GravarVidaOnSchedule implements Database.AllowsCallouts, Schedulable {
    global void execute(SchedulableContext ctx){
        GravarVidaOnBO.gravarCPFVidaOn();
    }
}