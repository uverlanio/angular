/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de liberação automática de Propostas do tipo Renovação         *
 * @author : Globant                                                                                                        *
 * @date 06/06/2022                                                                                                         *
 * Classe implementada tendo como origem a história RVI-104                                                                 *
 * Disparada através do Schedule Trggered Flow 'Liberar Contratação de Propostas de Renovação'                              *
 * **************************************************************************************************************************/
// RVI-221 - INICIO
//RVI-297 INICIO
global class ContratPropRenova implements Database.Batchable<SObject>, Schedulable
{
    //List<CriticaProposta__c> lstUpdFn = new List<CriticaProposta__c>();  
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Codigo__c, Status__c, MensagemInterna__c, Proposta__r.Id, Proposta__r.Status, Proposta__r.Tipo__c FROM CriticaProposta__c WHERE Proposta__r.Status = \'Em análise\' AND Proposta__r.Tipo__c = \'Renovacao\' AND Proposta__r.LiberarContratoRenovacao__c = true';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<CriticaProposta__c> records){
        List<CriticaProposta__c> lstUpd = new List<CriticaProposta__c>(); 
        List<CriticaProposta__c> lstUpdFn = new List<CriticaProposta__c>();  
        Map<Id, List<CriticaProposta__c>> mpProp = new Map<Id, List<CriticaProposta__c>>();
        Set<Id> PropIds = new Set<Id>();
        
        for(CriticaProposta__c  critica : records){
            PropIds.add(critica.Proposta__r.Id);
        }

        for(Id idprop : PropIds){
            List<CriticaProposta__c> lstCrit = new List<CriticaProposta__c>(); 
            for(CriticaProposta__c  critica : records){
                if(idprop == critica.Proposta__r.Id){
                    lstCrit.add(critica);
                }
            }
            mpProp.put(idprop, lstCrit);
        }

        for(Id idprop : PropIds){
            lstUpd = motorRegraRen(mpProp.get(idprop), idprop);
            lstUpdFn.addAll(lstUpd);
        }

        System.debug('JSON '  + JSON.serialize(lstUpdFn));
    
        Integer controleRegistrosCrt = 99;

        for(CriticaProposta__c criticaUpdate : lstUpdFn){
            if(lstUpdFn.size() <= controleRegistrosCrt){
                String hour = string.valueOf(system.now().hour());
                String minute = string.valueOf(system.now().minute());             
                String second = '14';
                String jobName = '15_Job_' + string.valueOf(criticaUpdate.id);
                String cronTime = second+' '+minute+' '+hour+' * * ?';
                ContratPropRenovaJob jobClass = new ContratPropRenovaJob();
                jobClass.criticaToUpdate = criticaUpdate;
                System.schedule(jobName, cronTime, jobClass);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext SC)
    {
        ContratPropRenova batchPropostas = new ContratPropRenova();
        Database.executeBatch(batchPropostas);
    }

    global void scheduleBatch() {
    
        /*
        String cron1 = '0 0 0 * * ?';
        String cron2 = '0 0 8 * * ?'; 
        String cron3 = '0 0 16 * * ?';
        system.schedule('ContratPropRenova1', cron1, this);
        system.schedule('ContratPropRenova2', cron2, this);
        system.schedule('ContratPropRenova3', cron3, this);
        */


        //Para testar:
        String cron1  = ' 0 29 2 * * ?';
        /*String cron2  = ' 0 51  * * * ?';
        String cron3  = ' 0 52  * * * ?';
        String cron4  = ' 0 53  * * * ?';
        String cron5  = ' 0 54  * * * ?';
        String cron6  = ' 0 55  * * * ?';
        String cron7  = ' 0 56  * * * ?';
        String cron8  = ' 0 57  * * * ?';
        String cron9  = ' 0 58  * * * ?';
        String cron10 = ' 0 59  * * * ?';
        String cron11 = ' 0 1 * * * ?';
        String cron12 = ' 0 2 * * * ?';*/
    
        system.schedule('ContratPropRenova1', cron1, this);
        /*system.schedule('ContratPropRenova2', cron2, this);
        system.schedule('ContratPropRenova3', cron3, this);
        system.schedule('ContratPropRenova4', cron4, this);
        system.schedule('ContratPropRenova5', cron5, this);
        system.schedule('ContratPropRenova6', cron6, this);
        system.schedule('ContratPropRenova7', cron7, this);
        system.schedule('ContratPropRenova8', cron8, this);
        system.schedule('ContratPropRenova9', cron9, this);
        system.schedule('ContratPropRenova10', cron10, this);
        system.schedule('ContratPropRenova11', cron11, this);
        system.schedule('ContratPropRenova12', cron12, this);*/
    }

    public static List<CriticaProposta__c> motorRegraRen(List<CriticaProposta__c> criticas, String propostaId) 
    {
        Boolean libCrit = true; 
        String idCriticaRenovacao = '';
        String idCriticaPalavraFinal = '';
        List<CriticaProposta__c> lstCrit = new List<CriticaProposta__c>();

        for (CriticaProposta__c critica : criticas) 
        { 
            if ((critica.Status__c == 'Pendente' || critica.Status__c == 'Recusado') && (critica.Codigo__c <> '0' && critica.Codigo__c <> '154')) 
            {
                libCrit = false;
                System.debug('if ((critica.Status__c == Pendente||');
                System.debug(libCrit);
            }                   
            if (critica.Codigo__c == '154') 
            {
                idCriticaRenovacao = critica.Id;
                System.debug('if (critica.Codigo__c == 154)');
                System.debug(idCriticaRenovacao);
            }
            if (critica.Codigo__c == '0') 
            {
                idCriticaPalavraFinal = critica.Id;
                System.debug('(critica.Codigo__c == ');
                System.debug(idCriticaPalavraFinal);
            }
            if ((critica.Codigo__c != '0' && critica.Codigo__c != '154') && critica.Status__c == 'Liberado') 
            {
                lstCrit.add(critica);
                System.debug('if ((critica.Codigo__c != 0 &&');
                System.debug(lstCrit);
            }
            if (critica.Codigo__c == '0'  && (critica.Status__c == 'Falha na Integração' && critica.MensagemInterna__c == 'REJEITADO')) 
            {
                libCrit = false;
                System.debug('if (critica.Codigo__c == 0 &&');
                System.debug(libCrit);
            }            
        }
        if (libCrit) 
        {
            CriticaProposta__c criticaRenovacao = new CriticaProposta__c();
            criticaRenovacao.Id          = idCriticaRenovacao;
            criticaRenovacao.Proposta__c = propostaId;
            criticaRenovacao.Status__c   = 'Liberado';
            lstCrit.add(criticaRenovacao);
        }
        return lstCrit;
    }

    public static void liberarCriticaRenovacao() 
    {
        Boolean renova; 
        List<CriticaProposta__c> lstUpd = new List<CriticaProposta__c>(); 
        List<CriticaProposta__c> lstUpdFn = new List<CriticaProposta__c>();  
        List<Quote> lstQt = new List<Quote>();  
        
        Map<Id, Quote> mpQt = new Map<Id, Quote>(
                                                [
                                                    SELECT Id, Status, Tipo__c, CodigoCorretor__c, OpportunityId, Opportunity.CodigoCorretor__c, //RVI-310 INICIO/FIM
                                                        (SELECT Id, Codigo__c, Status__c, MensagemInterna__c FROM CriticasProposta__r)
                                                    FROM Quote 
										            WHERE LiberarContratoRenovacao__c = true 
                                                    AND Status = 'Em análise' 
                                                    AND Tipo__c = 'Renovacao'
                                                ]); 

        if (mpQt.size() == 0) 
        {
            return;
        } 
        //RVI-310 INICIO
        //TODO Metodo pra atualizar os objetos ale RVI-265 RVI-310
        AtualizaObjetosTransfCor(mpQt);
        //todo update
        //todo pdf
        //RVI-310 FIM
        for(Id propostaId : mpQt.keyset()) 
        {
            lstUpd = motorRegraRen(mpQt.get(propostaId).CriticasProposta__r, propostaId);
            System.debug('lstUpd>>>>>>>>>>' + lstUpd);
            if (lstUpd.size() > 0) 
            {
                System.debug('Entrou no lstUpd.size() < 2 >>>>>>>>>>');
                System.debug('lstQt.size() >>>>>>>>>>' + lstQt.size());
                System.debug('lstQt >>>>>>>>>>' + lstQt);
                if (lstQt.size() <= 2) 
                {
                    lstQt.add(mpQt.get(propostaId));
                    lstUpdFn.addAll(lstUpd);                    
                } else 
                { 
                    break; 
                }                    
            }         
        }
        System.debug('lstUpdFn.size() >>>>>>>>>>' + lstUpdFn.size());
        System.debug('lstUpdFn >>>>>>>>>>' + lstUpdFn);
        if (lstUpdFn.size() > 0) 
        {
            update lstUpdFn;
        }
       
        return;
    }
    //RVI-310 INICIO
    public static void AtualizaObjetosTransfCor(Map<Id, Quote> mpQt) 
    {
        System.debug('mpQt ale: ' + mpQt);
    }
    //RVI-310 FIM
}
// RVI-297 - FIM
// RVI-221 - FIM