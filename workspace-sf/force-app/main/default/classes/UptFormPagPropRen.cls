/********************************************************************************************************************
* Classe implementada para garantir que uma proposta de renovação, com a forma de pagamento cartão, não se perca    *
* no processo de Renovação originada pela tarefa RVI-171                                                            *                                                                             *       
* @author : Globant                                                                                                 *
* @date 16/01/2023                                                                                                  *
* Disparada através do Schedule  'AltFPgtRenSchedulable'                                                            *
* *******************************************************************************************************************/

public with sharing class UptFormPagPropRen {

    //FNPVVEP-172 INICIO
    @InvocableMethod
    public static void altFPgtFlow(List<String> IdPropostas) { 
        altFPgt(IdPropostas);
    }
    //FNPVVEP-172 FIM

    public static String altFPgt(List<String> IdPropostas) { //FNPVVEP-172 INICIO/FIM
        
        Set<Id> ctrSt = new Set<Id>();
        Set<Id> ctrPrd = new Set<Id>();
        Set<Id> opUpd = new Set<Id>();

        List<Quote> lstQtUpd = new List<Quote>();
        List<Quote> lstQtCan = new List<Quote>();
        List<ContratanteContrato__c> lstCctUpd = new List<ContratanteContrato__c>();
        List<Contract> lstCtUpd = new List<Contract>();
        List<Opportunity> lstOpCan = new List<Opportunity>();
        
        Boolean stAltFpPg = true;
        String resUpdOk = 'Propostas Processadas';
        String resUpdErr = 'Não há propostas para processar';
        String codFpPg = '41';
        String stsQtRen = 'Em análise';
        String tipQtRen = 'Renovacao'; 
        String msgIntCtc = 'REJEITADO'; 
        String stsCtc = 'Falha na Integração'; 
        String stsQtCan = 'Cancelada';
        String stsNanRen = 'Não Renovado'; 
        String fpgFrac = 'FRAC.1.A PARCELA CARNE'; 
        String stsOrc = 'Cancelado';

        List<Quote> lstQtRen = [SELECT Id, Status, Name, Tipo__c, ContratoRenovado__c, OpportunityId, 
                               (SELECT Id, Codigo__c, Status__c, MensagemInterna__c, Proposta__c FROM CriticasProposta__r) 
                                FROM Quote WHERE Status =: stsQtRen AND Tipo__c =: tipQtRen AND Id IN :IdPropostas]; // RVI-171-FIX01-INICIO/FIM  //FNPVVEP-172 INICIO/FIM     

        if(lstQtRen.size() == 0)
        {
            return resUpdErr;    
        }

        for(Quote qt : lstQtRen) 
        {	                     
            for(CriticaProposta__c ctr : qt.CriticasProposta__r) 
            { 
                // RVI-171-FIXO1-INICIO
                if(lstQtRen.size() > 0)
                {     
                    if(ctr.MensagemInterna__c == msgIntCtc && ctr.Status__c == stsCtc) 
                    {  
                        lstQtUpd.add(qt);  
                        opUpd.add(qt.OpportunityId);             
                    }
                }
                // RVI-171-FIXO1-FIM    
            }      
        }

        if(opUpd.size() == 0)
        {
            return resUpdErr;
        }

        List<Opportunity> lstOpUpd = [SELECT Id, StageName FROM Opportunity WHERE Id IN : opUpd];
        
        if(lstOpUpd.size() == 0)
        {
            return resUpdErr;
        }

        for(Opportunity opCan : lstOpUpd) 
        {
            opCan.StageName = stsOrc;
            lstOpCan.add(opCan);
        }

        if(lstOpCan.size() > 0){
            update lstOpCan;
        }

        for (Quote qtUpd : lstQtUpd) 
        {
            qtUpd.Status = stsQtCan;
            if(!lstQtCan.contains(qtUpd)){
                lstQtCan.add(qtUpd);
            }
            ctrSt.add(qtUpd.ContratoRenovado__c);
        }

        if(lstQtCan.size() > 0) 
        {
            update lstQtCan;
        }

        List<Contract> lstctr = [SELECT Id, StatusRenovacao__c, Produto__c, AlteraFormaPagto__c, 
                                (SELECT Id, QuantidadeParcelas__c, FormaPagamento__r.Name, FormaPagamento__c, PlanoParcelamento__c, PlanoParcelamento__r.NumeroParcela__c FROM ContratantesContrato__r ORDER BY PlanoParcelamento__r.NumeroParcela__c) // RVI-171-FIX01-INICIO/FIM   
                                 FROM Contract 
                                 WHERE Id IN :ctrSt];

        if(lstctr.size() > 0) 
        {
            for (Contract ctr : lstctr) 
            {
                ctrPrd.add(ctr.Produto__c);
            }
        }

        Map<String, PlanoParcelamento__c> mpPlanParc = FormaPagamentoDAO.retPlan(ctrPrd, codFpPg);
        
        if(lstctr.size() > 0) 
        {
            for (Contract ctr : lstctr) 
            {
                ctr.StatusRenovacao__c = stsNanRen;   
                ctr.AlteraFormaPagto__c = stAltFpPg;
                lstCtUpd.add(ctr);

                // RVI-275 - INICIO
                // for (ContratanteContrato__c cttCtr : ctr.ContratantesContrato__r) 
                // {
                //     String chaveParc = String.valueOf(cttCtr.QuantidadeParcelas__c) + fpgFrac; // RVI-171-FIX01-INICIO/FIM     
                //     cttCtr.FormaPagamento__r.Name = mpPlanParc.get(chaveParc).FormaPagamento__r.Name;
                //     cttCtr.FormaPagamento__c = mpPlanParc.get(chaveParc).FormaPagamento__c;
                //     cttCtr.PlanoParcelamento__c = mpPlanParc.get(chaveParc).Id;
                //     lstCctUpd.add(cttCtr);
                // }   
                // RVI-275 - FIM  
            }

            if(lstCctUpd.size() > 0)
            {
                update lstCctUpd;
            }

            if(lstCtUpd.size() > 0)
            {
                update lstCtUpd;
            }
        }
        return resUpdOk;
    }   
}