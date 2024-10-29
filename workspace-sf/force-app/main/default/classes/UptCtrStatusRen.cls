/****************************************************************************************************************************
* Classe de Negocio implementada para o processo automático de liberação automática de status para Renovação               *
* @author : Globant                                                                                                        *
* @date 06/06/2022                                                                                                         *
* Classe implementada tendo como origem a história RVI-160                                                                 *
* Disparada através do Schedule Trggered Flow 'Atualizar Status renovação'                                                 *
* **************************************************************************************************************************/

//RVI-160 - INICIO
public with sharing class UptCtrStatusRen {
    public static void atualizarStatusRenovacao(){
        List<Contract> contratos = [SELECT Id, StartDate, VigenciaFinal__c, StatusRenovacao__c 
                                    FROM Contract 
                                    WHERE StatusRenovacao__c = 'Renovação em andamento' 
                                    LIMIT 2];

        for (Contract contrato : contratos) {
            System.debug('Contrato ID: ' + contrato.Id);
            System.debug('Contrato Status de renovação: ' + contrato.StatusRenovacao__c);
            if(contrato.VigenciaFinal__c.addDays(15) == System.today()){
                contrato.StatusRenovacao__c = 'Renovado';
            }
        }

        try{
            update contratos;
        }catch (Exception ex){
            System.debug(ex.getMessage());
        }
    }
}
//RVI-160 - FIM