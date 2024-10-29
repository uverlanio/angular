/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de mudança de status para Renovado no contrato original        *
 * @author : Globant                                                                                                        *
 * @date 30/08/2022                                                                                                         *
 * Classe implementada tendo como origem a história RVI-160                                                                 *
 * Disparada através do Flow 'Atualiza Contrato Status Renovacao em andamento para Renovado'                                *
 * **************************************************************************************************************************/

 //RVI-160 - INICIO
 public with sharing class ContratOriginalStatusRenovado {
    
    public class FlowInputs {
        @InvocableVariable public String contratoRenovado ;
    }

    @invocableMethod
    public static void uptCtrSttRen(List<FlowInputs> request){
        Contract contratoOriginal = [SELECT Id, StatusRenovacao__c FROM Contract WHERE Id =: request[0].contratoRenovado LIMIT 1 ];
        if(contratoOriginal <> null){
            contratoOriginal.StatusRenovacao__c = 'Renovado';
            update contratoOriginal;
        }
    }
 }
//RVI-160 - FIM