/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de liberação automática de Propostas do tipo Renovação         *
 * @author : Globant                                                                                                        *
 * @date 30/06/2022                                                                                                         *
 * Classe implementada tendo como origem a história RVI-95                                                                  * 
 * **************************************************************************************************************************/

//RVI-95 - FIX01 - INICIO 
public class PriContratRenova {
    private static final PriContratRenova instance = new PriContratRenova();
    public static PriContratRenova getInstance() {
        return instance;
    }    
    public void updContracts(List<Contract> lstCTR) {        
        Set<Id> setIdCtrRen = new Set<Id>();        
        Map<Id, Contract> mapCtrPAI = new Map<Id, Contract>();
        Map<Id, Contract> mapCtrFIL = new Map<Id, Contract>();   
        List<Contract> lstCTRenova = new List<Contract>();
        
        for (Contract contrato : lstCTR) {         
            if(contrato.Tipo__c == 'Renovacao'){
                lstCTRenova.add(contrato);               
            }            
        }

        if(lstCTRenova.size() > 0) {

            for(Contract ctr : lstCTRenova){            
                setIdCtrRen.add(ctr.ContratoRenovado__c);            
            }
    
            List<Contract> lstCtrREN = [SELECT Id, PrimeiroContratoRenovacao__c, ContratoRenovado__c
                                        FROM Contract
                                        WHERE Id IN :setIdCtrRen];                                    
            
            if(lstCtrREN.size() > 0){
                for(Contract ctrREN : lstCtrREN){            
                    if(ctrREN.PrimeiroContratoRenovacao__c == null){
                        mapCtrPAI.put(ctrREN.Id, ctrREN);
                    }else{
                        mapCtrFIL.put(ctrREN.Id, ctrREN);
                    }
                }            
                        
                for(Contract ctr : lstCTRenova){
                    if(mapCtrPAI.get(ctr.ContratoRenovado__c) != null){
                        ctr.PrimeiroContratoRenovacao__c = mapCtrPAI.get(ctr.ContratoRenovado__c).Id;
                    } else if(mapCtrFIL.get(ctr.ContratoRenovado__c) != null) {
                        ctr.PrimeiroContratoRenovacao__c = mapCtrFIL.get(ctr.ContratoRenovado__c).PrimeiroContratoRenovacao__c;
                    }            
                }
            }
        }                             
    }
}
//RVI-95 - FIX01 - FIM