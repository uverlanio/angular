/**
 * @author Renato Matheus Simião / Diego Zampieri
 * @author Avanxo
 * @date 2019-01-22
 * @description Essa classe calcula o SLA do Marco
 */

public with sharing class MilestoneHelper implements Support.MilestoneTriggerTimeCalculator {

    //PLV-4122 - INÍCIO - PEDRO AUGUSTO - SYS4B
    public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {

        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
               
        
        List<ReaberturaSinistro__mdt> metaSLA= [SELECT Marco__c, Tempo_minutos__c, TipoRegistro__c FROM ReaberturaSinistro__mdt WHERE TipoRegistro__c='Tempo Marco Sinistro'];
        
        Map<String,Decimal> mapProcessoMarco = new Map<String,Decimal>();
        for(ReaberturaSinistro__mdt sla :metaSLA){
            mapProcessoMarco.put(sla.Marco__c,sla.Tempo_minutos__c);
        }
        if (mt!=null && mt.Name != null && mapProcessoMarco.keyset().contains(mt.Name)) {

            Case c = [SELECT Id
                            , Sinistro_Judicial__c
                            , DataReabertura__c
                            , Contrato__r.Produto__c
                            , TipoContagem__c
                            , Garantia_do_segurado_do_contrato__r.Garantia__c
                            , Data_sinistro_avisado__c 
                  		FROM Case 
                        WHERE Id = :caseId];
          
            
            if(String.isBlank(c.TipoContagem__c) || c.TipoContagem__c !='Calcular Tempo'){
                return Integer.valueOf(mapProcessoMarco.get(mt.Name));
            }


            List<CaseMilestone> milestone = [SELECT Id
                                                    , IsCompleted
                                                    , IsViolated
                                                    , TimeRemainingInMins
                                                    , ElapsedTimeInMins
                                                    , TimeSinceTargetInMins
                                                    , CompletionDate
                                                    , StartDate
                                                    , TargetDate
                                                    , MilestoneType.Name
                                                FROM CaseMilestone
                                                WHERE CaseId=:caseId
                                                AND MilestoneType.Name =:mt.Name
                                                
                                                ORDER BY createdDate DESC
                                                LIMIT 1];
            if(!milestone.isEmpty()){
                if( milestone[0].IsCompleted == true &&  milestone[0].IsViolated == false){
                    Long dataMaior = milestone[0].TargetDate.getTime();
                    Long dataMenor = milestone[0].CompletionDate.getTime();

                    Long diferenca = dataMaior-dataMenor;

                    diferenca = diferenca / 1000 / 60;

                    Integer minutos = Integer.valueOf(diferenca);
                    if(minutos<=1){
                        return Integer.valueOf(mapProcessoMarco.get(mt.Name));
                    }
                    return minutos;
                }
            }

            //Se não encontrar um milestone iniciar do zero OU se estiver violado
            return Integer.valueOf(mapProcessoMarco.get(mt.Name));
  
        }
        //Se tudo der errado insere o tempo padrão
        return Integer.valueOf(mapProcessoMarco.get('DEFAULT VALUE'));

    }
    //PLV-4122 - FIM - PEDRO AUGUSTO - SYS4B
}