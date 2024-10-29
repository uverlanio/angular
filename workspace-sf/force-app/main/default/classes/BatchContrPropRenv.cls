/****************************************************************************************************************************
 * Classe de Negocio implementada para o processo automático de liberação automática de Propostas do tipo Renovação         *
 * @author : Globant                                                                                                        *
 * @date 22/09/2023                                                                                                         *
 * Classe implementada tendo como origem a história RVI-297                                                                 *
 * Disparada através do script BatchContrPropRenvBO                                                                         *
 * **************************************************************************************************************************/
global class BatchContrPropRenv implements Database.Batchable<sObject>, Database.StateFul, Database.AllowsCallouts, Schedulable{

    static List<AsyncApexJob> jobs = AsyncApexJobDao.getInstancia().buscarClasses(
        new Set<String> { 'BatchContrPropRenv' }
    );
    
    private Set<Id> setIdPropostaArquivo = new Set<Id>(); //RVI-311 INICIO/FIM

    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
            [SELECT Id, Codigo__c, Status__c, MensagemInterna__c, Proposta__r.Id, Proposta__r.Status, Proposta__r.Tipo__c FROM CriticaProposta__c WHERE Proposta__r.Status = 'Em análise' AND Proposta__r.Tipo__c = 'Renovacao' AND Proposta__r.LiberarContratoRenovacao__c = true AND Status__c = 'Pendente' AND Codigo__c = '154' ] //FNPVVEP-117 INICIO/FIM
        );
    }

    global void execute(Database.BatchableContext batchableContext, List<CriticaProposta__c> records){
        //UptFormPagPropRen.altFPgt(); //FNPVVEP-117 INICIO/FIM
        prepararLiberacaoCriticas(records);
    }

    global void execute(SchedulableContext schedulableContext){
        Database.executeBatch(this, 3);
        System.abortJob(schedulableContext.getTriggerId());
    }

    global void finish(Database.BatchableContext batchableContext){

        // RVI-297-FIX01 - INICIO 
        // String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().addMinutes(4).minute()); //FNPVVEP-117 FIX01 INICIO/FIM
        String ss = String.valueOf(Datetime.now().second());
        // String day = String.valueOf(Datetime.now().day());
        // String month = String.valueOf(Datetime.now().month());
        // String cron = ss + ' ' + min + ' ' + '*' + ' ' + day + ' '+ month + ' *';
        String cron = ss + ' ' + min + ' * * * ? *';
        // RVI-297-FIX01 - FIM 

        try{
            //RVI-311 INICIO
            if(!setIdPropostaArquivo.isEmpty()){ //FNPVVEP-117 FIX01 INICIO/FIM
                List<Id> listIdPropostaArquivoNew = new List<Id>(setIdPropostaArquivo);
                System.debug('XXX - listIdPropostaArquivoNew' + listIdPropostaArquivoNew);
                System.debug('XXX - setIdPropostaArquivo' + setIdPropostaArquivo);
                callGerarPDFPropostaSync(listIdPropostaArquivoNew);
            }
            //RVI-311 FIM
            //FNPVVEP-57 - INICIO
            if (Datetime.now().hour() > 0 || (Datetime.now().hour() == 0 && Datetime.now().minute() > 10)) {
                System.schedule('BatchContrPropRenvJob', cron, new BatchContrPropRenv());
            }
            //FNPVVEP-57 - FIM
        }catch(System.AsyncException e){            
            if(!jobs.isEmpty() && String.isNotBlank(jobs[0].Id)){
                System.abortJob(jobs[0].Id);
            }
        }

    }

    global void prepararLiberacaoCriticas(List<CriticaProposta__c> records){
        List<CriticaProposta__c> lstUpd = new List<CriticaProposta__c>(); 
        List<CriticaProposta__c> lstUpdFn = new List<CriticaProposta__c>();  
        Map<Id, List<CriticaProposta__c>> mpProp = new Map<Id, List<CriticaProposta__c>>();
        Set<Id> propIds = new Set<Id>();
        //FNPVVEP-117 FIX01 INICIO
        List<CriticaProposta__c> lstUpdPalavraFinal = new List<CriticaProposta__c>(); 
        List<CriticaProposta__c> lstCtrPalavraFinal = new List<CriticaProposta__c>(); 
        
        for(CriticaProposta__c  critica : records){
            propIds.add(critica.Proposta__r.Id);
        }

        for(Id idprop : propIds){
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
            //lstCtrPalavraFinal = liberarPalvraFinal(idprop);
            lstUpdFn.addAll(lstUpd);
        }

        try{
            liberarCriticaRenovacao();
            update lstUpd;
            for(Id idprop : PropIds){
                lstCtrPalavraFinal = liberarPalvraFinal(idprop);
                lstUpdPalavraFinal.addAll(lstCtrPalavraFinal);
            }
            //update lstUpdPalavraFinal;
            BatchContrPropRenvJob jobClass = new BatchContrPropRenvJob();

            Integer scheduledJobCount = [SELECT COUNT() FROM CronJobDetail WHERE JobType = '7'];

            Integer controleRegistrosCrt = 100 - scheduledJobCount;  
            Integer count = 1;

            if(!lstUpdPalavraFinal.isEmpty()){
                for(CriticaProposta__c critica : lstUpdPalavraFinal){
                    if(count <= controleRegistrosCrt){
                        
                        String minute = string.valueOf(system.now().minute() +1);      
                        String second = string.valueOf(count); 
                        String jobName = 'Job_PalvraFinal' + string.valueOf(critica.id);
                        String cronTime = second+' '+minute+' * * * ?';
        
                        jobClass.criticaToUpdate = critica;
                        if(!Test.isRunningTest()) System.schedule(jobName, cronTime, jobClass);
                    }
                    count++;
                }
            }
        }catch (Exception e){
            System.debug('Erro ao tentar liberar as criticas: ' + e.getMessage() + ' na linha: ' + e.getLineNumber());
        }
    }

    private static List<CriticaProposta__c> liberarPalvraFinal(Id idPropostas){
        System.debug('XXX - idPropostas' + idPropostas);
        List<CriticaProposta__c> criticas = [SELECT Id, Codigo__c, Status__c FROM CriticaProposta__c WHERE Proposta__c =: idPropostas AND Status__c != 'Cancelada']; 
        Boolean liberarCritica = true;
        List<CriticaProposta__c> lstUpd = new List<CriticaProposta__c>(); 
        System.debug('XXX - criticas' + criticas);
        for(CriticaProposta__c  critica : criticas){
            if(critica.Codigo__c == '0' && critica.Status__c != 'Liberado'){
                critica.Status__c = 'Liberado';
                lstUpd.add(critica);
            }else if(critica.Status__c != 'Liberado'){
                liberarCritica = false;
            }
        }
        System.debug('XXX - liberarCritica' + liberarCritica);
        return liberarCritica ? lstUpd : new List<CriticaProposta__c>();
    }
	//FNPVVEP-117 FIX01 FIM
    public static List<CriticaProposta__c> motorRegraRen(List<CriticaProposta__c> criticas, String propostaId){
        
        Boolean libCrit = true; 
        String idCriticaRenovacao = '';
        String idCriticaPalavraFinal = '';
        List<CriticaProposta__c> lstCrit = new List<CriticaProposta__c>();

        for (CriticaProposta__c critica : criticas){ 
            if ((critica.Status__c == 'Pendente' || critica.Status__c == 'Recusado') && (critica.Codigo__c <> '0' && critica.Codigo__c <> '154')){
                libCrit = false;
            }                   
            if (critica.Codigo__c == '154'){
                idCriticaRenovacao = critica.Id;
            }
            if (critica.Codigo__c == '0'){
                idCriticaPalavraFinal = critica.Id;
            }
            if ((critica.Codigo__c != '0' && critica.Codigo__c != '154') && critica.Status__c == 'Liberado'){
                lstCrit.add(critica);
               }
            if (critica.Codigo__c == '0'  && (critica.Status__c == 'Falha na Integração' && critica.MensagemInterna__c == 'REJEITADO')){
                libCrit = false;
            }            
        }

        System.debug('XXX - idCriticaRenovacao' + idCriticaRenovacao);
        System.debug('XXX - idCriticaPalavraFinal' + idCriticaPalavraFinal);

        //FNPVVEP-69 - INICIO
        if (libCrit){
            lstCrit = idCriticaRenovacao != '' ? liberarCritica(lstCrit, idCriticaRenovacao, propostaId) : lstCrit;
            //lstCrit = idCriticaPalavraFinal != '' ? liberarCritica(lstCrit, idCriticaPalavraFinal, propostaId) : lstCrit; //FNPVVEP-69
        }
        //FNPVVEP-69 - FIM

        System.debug('XXX - lstCrit' + JSON.serialize(lstCrit));

        return lstCrit;
    }

    //FNPVVEP-69 - INICIO
    private static List<CriticaProposta__c> liberarCritica(List<CriticaProposta__c> criticas, String idCritica, String idProposta){

        if(idCritica != ''){
            CriticaProposta__c critica = new CriticaProposta__c(
                Id = idCritica,
                Proposta__c = idProposta,
                Status__c = 'Liberado'
            );

            criticas.add(critica);
        }

        return criticas;
    }
    //FNPVVEP-69 - FIM

    

    global void liberarCriticaRenovacao() {
        //RVI-310 - INICIO
        Boolean renova; 
        List<CriticaProposta__c> lstUpd = new List<CriticaProposta__c>(); 
        List<CriticaProposta__c> lstUpdFn = new List<CriticaProposta__c>();  
        List<Quote> lstQt = new List<Quote>();  
        
        Map<Id, Quote> mpQt = new Map<Id, Quote>(
                                                [
                                                    SELECT Id, Status, Tipo__c, ContratoRenovado__c, OpportunityId, CodigoCorretor__r.Name,
                                                        (SELECT Id, Codigo__c, Status__c, MensagemInterna__c FROM CriticasProposta__r)
                                                    FROM Quote 
										            WHERE LiberarContratoRenovacao__c = true 
                                                    AND Status = 'Em análise' 
                                                    AND Tipo__c = 'Renovacao'
                                                ]); 

        if (mpQt.size() == 0){
            return;
        }

        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> ctrNovo = new Set<Id>();
        for(Quote qt : mpQt.values()){
            opportunityIds.add(qt.OpportunityId);
            ctrNovo.add(qt.ContratoRenovado__c);
        }
        List<Opportunity> orcamento = [SELECT Id, CodigoCorretor__c FROM Opportunity WHERE Id IN :opportunityIds];
        //List<Contract> contratoNovo = [SELECT Id FROM Contract WHERE Id IN :ctrNovo];
        List<String> listaSUSEP = new List<String>();
        // List<String> idCtrNovo = new List<String>();

        // for(Contract ctr : contratoNovo){
        //     idCtrNovo.add(ctr.Id);
        // }

        List<FavorecidoRemuneracaoContrato__c> listaFavCtr = buscarFavRemCtr(ctrNovo);
        System.debug('XXX - listaFavCtr: ' + JSON.serialize(listaFavCtr));

        for(FavorecidoRemuneracaoContrato__c fvc : listaFavCtr){    
            if(fvc.CorretorLider__c){
                listaSUSEP.add(fvc.Susep__c);
            }          
            System.debug('***listaSUSEP: ' + listaSUSEP);
        }

        List<FavorecidoRemuneracaoProposta__c> listaFVP = buscarFavRemProp();
        System.debug('XXX - listaFVP: ' + JSON.serialize(listaFVP));


        

        List<TransferenciaCorretagem__c> listaTC = buscarTransfCor(listaSUSEP);
        System.debug('***listaTC: ' + listaTC);

        List<TransferenciaCorretagem__c> listaTCCart = new List<TransferenciaCorretagem__c>();
        List<TransferenciaCorretagem__c> listaTCInd = new List<TransferenciaCorretagem__c>();
                
        for(TransferenciaCorretagem__c tc : listaTC){
            if(tc.TransferirCarteira__c){
                listaTCCart.add(tc);
            }else{
                listaTCInd.add(tc);
            }
        }
        System.debug('***listaTCind: ' + listaTCInd);
        System.debug('***listaTCart: ' + listaTCCart);
 

        if(listaTCInd != null && !listaTCInd.isEmpty()){
            List<FavorecidoRemuneracaoProposta__c> favToUpdate = new List<FavorecidoRemuneracaoProposta__c>();
            Set<FavorecidoRemuneracaoProposta__c> favToDelete = new Set<FavorecidoRemuneracaoProposta__c>();
            Set<Opportunity> orcToUpdate = new Set<Opportunity>();
            List<Quote> quoteToUpdate = new List<Quote>();
            for(TransferenciaCorretagem__c lstTc : listaTCInd){
                for (Id quoteId : mpQt.keySet()) {
                    Quote quote = mpQt.get(quoteId);
                    if(lstTc.ContratoTransferido__c == quote.ContratoRenovado__c){
                        for(Opportunity orc : orcamento){
                            if(orc.id == quote.OpportunityId){
                                if(!listaFVP.isEmpty() && listaFVP != null){
                                    Boolean hasLider = false;
                                    Boolean hasPri = false;
                                    Boolean hasSeg = false;
                                    Boolean hasTer = false;
                                    Boolean hasQua = false;
                                    Boolean hasQui = false;
                                    List<FavorecidoRemuneracaoProposta__c> favListByProRen = new List<FavorecidoRemuneracaoProposta__c>();
                                    System.debug('listaFVP: ' + listaFVP);
                                    for(FavorecidoRemuneracaoProposta__c favRemProp : listaFVP){
                                        if(favRemProp.RemuneracaoProposta__r.Proposta__r.ContratoRenovado__c == quote.ContratoRenovado__c){
                                         favListByProRen.add(favRemProp);
                                        }
                                    }
                                    System.debug('favListByProRen: ' + favListByProRen);
                                    for(FavorecidoRemuneracaoProposta__c favLstCtr : favListByProRen){
                                        Integer sizeLst = favListByProRen.size();
                                        System.debug('sizeLst: ' + sizeLst);

                                        System.debug('XXX - favLstCtr: ' + JSON.serialize(favLstCtr));
                                        System.debug('XXX - lstTc: ' + JSON.serialize(lstTc));

                                        if(favLstCtr.CorretorLider__c){
                                            favLstCtr.Susep__c = lstTc.SusepAtual__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepAtual__c;
                                            favLstCtr.Conta__c = lstTC.SusepAtual__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercSusepLider__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            orc.CodigoCorretor__c = lstTc.SusepAtual__c;
                                            quote.CodigoCorretor__c = lstTc.SusepAtual__c;
                                            hasLider = true;
                                            if(!favToUpdate.contains(favLstCtr)){
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(!quoteToUpdate.contains(quote)){
                                                quoteToUpdate.add(quote);
                                            }
                                            orcToUpdate.add(orc);

                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepPriCoCorretagem__c != null && sizeLst >= 2 && !hasPri){
                                            favLstCtr.Susep__c = lstTc.SusepPriCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepPriCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepPriCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercPriCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasPri = true;
                                            if(!favToUpdate.contains(favLstCtr)){
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 2){
                                                continue;
                                            }
                                        }else if(lstTC.SusepPriCoCorretagem__c != null && sizeLst < 2 && !hasPri){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepPriCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepPriCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepPriCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercPriCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasPri = true;
                                            if(!favToUpdate.contains(newFav)){
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepPriCoCorretagem__r == null && sizeLst >= 2 && !hasPri){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepSegCoCorretagem__c != null && sizeLst >= 3 && hasPri && !hasSeg){
                                            favLstCtr.Susep__c = lstTc.SusepSegCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepSegCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepSegCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercSegCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasSeg = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 3){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepSegCoCorretagem__c != null && sizeLst < 3 && hasPri && !hasSeg){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepSegCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepSegCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepSegCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercSegCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasSeg = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepSegCoCorretagem__c == null && sizeLst >= 3 && hasPri && !hasSeg){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepTerCoCorretagem__c != null && sizeLst >= 4 && hasPri && hasSeg && !hasTer){
                                            favLstCtr.Susep__c = lstTc.SusepTerCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepTerCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepTerCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercTerCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasTer = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 4){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepTerCoCorretagem__c != null && sizeLst < 4 && hasPri && hasSeg && !hasTer){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepTerCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepTerCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepTerCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercTerCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasTer = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepTerCoCorretagem__c == null && sizeLst >= 4 && hasPri && hasSeg && !hasTer){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepQuaCoCorretagem__c != null && sizeLst >= 5 && hasPri && hasSeg && hasTer && !hasQua){
                                            favLstCtr.Susep__c = lstTc.SusepQuaCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepQuaCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepQuaCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercQuaCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasQua = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 5){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuaCoCorretagem__c != null && sizeLst < 5 && hasPri && hasSeg && hasTer && !hasQua){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepQuaCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepQuaCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepQuaCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercQuaCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasQua = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuaCoCorretagem__c == null && sizeLst >= 5 && hasPri && hasSeg && hasTer && !hasQua){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepQuiCoCorretagem__c != null && sizeLst >= 6 && hasPri && hasSeg && hasTer && hasQua && !hasQui){
                                            favLstCtr.Susep__c = lstTc.SusepQuiCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepQuiCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepQuiCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercQuiCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasQui = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 6){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuiCoCorretagem__c != null && sizeLst < 6 && hasPri && hasSeg && hasTer && hasQua && !hasQui){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepQuiCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepQuiCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepQuiCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercQuiCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasQui = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuiCoCorretagem__c == null && sizeLst >= 6 && hasPri && hasSeg && hasTer && hasQua && !hasQui){
                                            favToDelete.add(favLstCtr);
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
            //RVI-311 INICIO
            List<Id> idPropostaArquivo = new List<Id>();
            for(Quote proposta : quoteToUpdate){
                idPropostaArquivo.add(proposta.Id);
            }
            System.debug('idPropostaArquivo ><' + idPropostaArquivo);
            //FNPVVEP-69 - INICIO
            if(!Test.isRunningTest()){
                if(!idPropostaArquivo.isEmpty()){
                    List<ContentDocumentLink > arquivoPdfProp = [SELECT Id FROM ContentDocumentLink  WHERE LinkedEntityId IN :idPropostaArquivo];            
                    delete arquivoPdfProp;

                    QuoteBO.gerarPDFPropostaSync(idPropostaArquivo);
                }
            }
            //FNPVVEP-69 - FIM


            List<Opportunity> orcToUpdateList = new List<Opportunity>(orcToUpdate);

            System.debug('XXX - favToDelete: ' + JSON.serialize(favToDelete));

            List<FavorecidoRemuneracaoProposta__c> FavToDeleteList = new List<FavorecidoRemuneracaoProposta__c>(favToDelete);
            System.debug('FavToDeleteList: ' + FavToDeleteList);

            System.debug('XXX - favToUpdate: ' + JSON.serialize(favToUpdate));
            upsert favToUpdate;
            update quoteToUpdate;
            System.debug('orcToUpdate: ' + orcToUpdateList);
            update orcToUpdateList;
            delete FavToDeleteList;
        }
        //RVI-311 FIM
        List<FavorecidoRemuneracaoProposta__c> listaFVPCart = buscarFavRemProp();
        List<Id> listIdPropostaArquivo = new List<Id>(); //RVI-311 INICIO/FIM 
        if(listaTCCart != null && !listaTCCart.isEmpty()){
            List<FavorecidoRemuneracaoProposta__c> favToUpdate = new List<FavorecidoRemuneracaoProposta__c>();
            Set<Opportunity> orcToUpdate2 = new Set<Opportunity>();
            Set<FavorecidoRemuneracaoProposta__c> favToDelete = new Set<FavorecidoRemuneracaoProposta__c>();
            List<Quote> quoteToUpdate = new List<Quote>();
            for(TransferenciaCorretagem__c lstTc : listaTCCart){
                for (Id quoteId : mpQt.keySet()) {
                    Quote quote = mpQt.get(quoteId);
                    if(lstTc.CodCor__c == quote.CodigoCorretor__r.Name){
                        for(Opportunity orc : orcamento){
                            if(orc.id == quote.OpportunityId){
                                if(!listaFVPCart.isEmpty() && listaFVPCart != null){
                                    Boolean hasLider = false;
                                    Boolean hasPri = false;
                                    Boolean hasSeg = false;
                                    Boolean hasTer = false;
                                    Boolean hasQua = false;
                                    Boolean hasQui = false;
                                    List<FavorecidoRemuneracaoProposta__c> favListByProRen = new List<FavorecidoRemuneracaoProposta__c>();
                                    for(FavorecidoRemuneracaoProposta__c favRemProp : listaFVPCart){
                                        if(favRemProp.RemuneracaoProposta__r.Proposta__r.ContratoRenovado__c == quote.ContratoRenovado__c){
                                            favListByProRen.add(favRemProp);
                                        }
                                    }
                                    for(FavorecidoRemuneracaoProposta__c favLstCtr : favListByProRen){
                                        Integer sizeLst = favListByProRen.size();
                                        System.debug('sizeLst: ' + sizeLst);
                                        if(favLstCtr.CorretorLider__c){
                                            favLstCtr.Susep__c = lstTc.SusepAtual__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepAtual__c;
                                            favLstCtr.Conta__c = lstTC.SusepAtual__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercSusepLider__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            orc.CodigoCorretor__c = lstTc.SusepAtual__c;
                                            quote.CodigoCorretor__c = lstTc.SusepAtual__c;
                                            hasLider = true;
                                            if(!favToUpdate.contains(favLstCtr)){
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(!quoteToUpdate.contains(quote)){
                                                System.debug('preencheQuote: ' + quote);
                                                quoteToUpdate.add(quote);
                                            }
                                            orcToUpdate2.add(orc);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepPriCoCorretagem__c != null && sizeLst >= 2 && !hasPri){
                                            favLstCtr.Susep__c = lstTc.SusepPriCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepPriCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepPriCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercPriCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasPri = true;
                                            if(!favToUpdate.contains(favLstCtr)){
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 2){
                                                continue;
                                            }
                                        }else if(lstTC.SusepPriCoCorretagem__c != null && sizeLst < 2 && !hasPri){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepPriCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepPriCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepPriCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercPriCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasPri = true;
                                            if(!favToUpdate.contains(newFav)){
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepPriCoCorretagem__r == null && sizeLst >= 2 && !hasPri){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepSegCoCorretagem__c != null && sizeLst >= 3 && hasPri && !hasSeg){
                                            favLstCtr.Susep__c = lstTc.SusepSegCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepSegCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepSegCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercSegCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasSeg = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 3){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepSegCoCorretagem__c != null && sizeLst < 3 && hasPri && !hasSeg){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepSegCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepSegCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepSegCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercSegCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasSeg = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepSegCoCorretagem__c == null && sizeLst >= 3 && hasPri && !hasSeg){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepTerCoCorretagem__c != null && sizeLst >= 4 && hasPri && hasSeg && !hasTer){
                                            favLstCtr.Susep__c = lstTc.SusepTerCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepTerCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepTerCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercTerCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasTer = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 4){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepTerCoCorretagem__c != null && sizeLst < 4 && hasPri && hasSeg && !hasTer){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepTerCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepTerCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepTerCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercTerCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasTer = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepTerCoCorretagem__c == null && sizeLst >= 4 && hasPri && hasSeg && !hasTer){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepQuaCoCorretagem__c != null && sizeLst >= 5 && hasPri && hasSeg && hasTer && !hasQua){
                                            favLstCtr.Susep__c = lstTc.SusepQuaCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepQuaCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepQuaCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercQuaCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasQua = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 5){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuaCoCorretagem__c != null && sizeLst < 5 && hasPri && hasSeg && hasTer && !hasQua){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepQuaCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepQuaCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepQuaCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercQuaCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasQua = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuaCoCorretagem__c == null && sizeLst >= 5 && hasPri && hasSeg && hasTer && !hasQua){
                                            favToDelete.add(favLstCtr);
                                        }
                                        if(!favLstCtr.CorretorLider__c && lstTC.SusepQuiCoCorretagem__c != null && sizeLst >= 6 && hasPri && hasSeg && hasTer && hasQua && !hasQui){
                                            favLstCtr.Susep__c = lstTc.SusepQuiCoCorretagem__r.Name;
                                            favLstCtr.DadosCorretor__c = lstTc.SusepQuiCoCorretagem__c;
                                            favLstCtr.Conta__c = lstTC.SusepQuiCoCorretagem__r.NomeCorretor__c;
                                            favLstCtr.Participacao__c = lstTC.PercQuiCoCorretor__c;
                                            favLstCtr.Papel__c = 'Corretor';
                                            hasQui = true;
                                            if(!favToUpdate.contains(favLstCtr)) {
                                                favToUpdate.add(favLstCtr);
                                            }
                                            if(sizeLst > 6){
                                                continue;
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuiCoCorretagem__c != null && sizeLst < 6 && hasPri && hasSeg && hasTer && hasQua && !hasQui){
                                            FavorecidoRemuneracaoProposta__c newFav = new FavorecidoRemuneracaoProposta__c();
                                            newFav.Susep__c = lstTc.SusepQuiCoCorretagem__r.Name;
                                            newFav.DadosCorretor__c = lstTc.SusepQuiCoCorretagem__c;
                                            newFav.Conta__c = lstTC.SusepQuiCoCorretagem__r.NomeCorretor__c;
                                            newFav.Participacao__c = lstTC.PercQuiCoCorretor__c;
                                            newFav.Papel__c = 'Corretor';
                                            newFav.RemuneracaoProposta__c = favLstCtr.RemuneracaoProposta__c;
                                            hasQui = true;
                                            if(!favToUpdate.contains(newFav)) {
                                                favToUpdate.add(newFav);
                                            }
                                        }else if(!favLstCtr.CorretorLider__c && lstTC.SusepQuiCoCorretagem__c == null && sizeLst >= 6 && hasPri && hasSeg && hasTer && hasQua && !hasQui){
                                            favToDelete.add(favLstCtr);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            //RVI-311 INICIO
            update quoteToUpdate;
            System.debug('quoteToUpdate: ' + quoteToUpdate);
            System.debug('quoteToUpdateSize: ' + quoteToUpdate.size());
            for(Quote proposta : quoteToUpdate){
                System.debug('proposta: ' + proposta);
                System.debug('proposta.Id: ' + proposta.Id);
                System.debug('corretor da proposta: ' + proposta.CodigoCorretor__r.Name);
                listIdPropostaArquivo.add(proposta.Id);
            }
            this.setIdPropostaArquivo.addAll(listIdPropostaArquivo);
            //FNPVVEP-117 FIX02 INICIO
            if(!setIdPropostaArquivo.isEmpty()){
                List<ContentDocumentLink > arquivoPdfProp = [SELECT Id FROM ContentDocumentLink  WHERE LinkedEntityId IN :setIdPropostaArquivo];  
                System.debug('arquivoPdfPropCart: ' + arquivoPdfProp);
                delete arquivoPdfProp;
            }

            List<Opportunity> orcToUpdateListCart = new List<Opportunity>();
                for(Opportunity orcamento2 : orcToUpdate2){
                    orcToUpdateListCart.add(orcamento2);
                }
            List<FavorecidoRemuneracaoProposta__c> FavToDeleteList = new List<FavorecidoRemuneracaoProposta__c>(favToDelete);
            //FNPVVEP-117 FIX02 FIM
            upsert favToUpdate;
            System.debug('FavToDeleteList: ' + FavToDeleteList);
            delete FavToDeleteList;
            update orcToUpdateListCart;
            System.debug('queryProp: ' + [SELECT Id, CodigoCorretor__r.Name FROM Quote WHERE Id in :listIdPropostaArquivo]);
            System.debug('idPropostaArquivo: ' + listIdPropostaArquivo);
            // QuoteBO.gerarPDFPropostaSync(listIdPropostaArquivo);
        }
        //RVI-311 FIM
        // RVI-310 - FIM
        
        for(Id propostaId : mpQt.keyset()){
            lstUpd = motorRegraRen(mpQt.get(propostaId).CriticasProposta__r, propostaId);
            if (lstUpd.size() > 0){
                if (lstQt.size() <= 2){
                    lstQt.add(mpQt.get(propostaId));
                    lstUpdFn.addAll(lstUpd);                    
                }else{ 
                    break; 
                }                    
            }         
        }
      
        if (lstUpdFn.size() > 0){
            update lstUpdFn;
        }       
        return;
    }

    //RVI-310 - INICIO
    public List<FavorecidoRemuneracaoContrato__c> buscarFavRemCtr(Set<Id> ctrNovo){
        
        return [
            SELECT 
                id,
                Susep__c,
                DadosCorretor__c,
                DadosCorretor__r.Name,
                Participacao__c,
                Conta__c,
                CorretorLider__c
            FROM
                FavorecidoRemuneracaoContrato__c 
            WHERE
                RemuneracaoContrato__r.Contrato__c in: ctrNovo
            ];
    }

    public List<FavorecidoRemuneracaoProposta__c> buscarFavRemProp(){
        
        return [
            SELECT 
                id,
                Susep__c,
                DadosCorretor__c,
                DadosCorretor__r.Name,
                RemuneracaoProposta__r.Proposta__r.ContratoRenovado__c,
                Participacao__c,
                Conta__c,
                CorretorLider__c,
                RemuneracaoProposta__c
            FROM
                FavorecidoRemuneracaoProposta__c 
            WHERE
                RemuneracaoProposta__r.Proposta__r.LiberarContratoRenovacao__c = true AND
                RemuneracaoProposta__r.Proposta__r.Status = 'Em análise' AND
                RemuneracaoProposta__r.Proposta__r.Tipo__c = 'Renovacao' AND     
                papel__c = 'Corretor'
            ];
    }

    public List<TransferenciaCorretagem__c> buscarTransfCor(List<String> listaSUSEP){
        return [
            SELECT 
                id,
                CodCor__c,
                TransferirCarteira__c,
                SusepAtual__c,
                SusepAtual__r.name,
                SusepAtual__r.NomeCorretor__c,
                ContratoTransferido__c,
                ChaveContrato__c, 
                Name, 
                PercSusepLider__c,
                PercPriCoCorretor__c,
                PercSegCoCorretor__c,
                PercTerCoCorretor__c,
                PercQuaCoCorretor__c,
                PercQuiCoCorretor__c,
                SusepOriginal__c,
                SusepPriCoCorretagem__c,
                SusepPriCoCorretagem__r.Name,
                SusepPriCoCorretagem__r.NomeCorretor__c,
                SusepSegCoCorretagem__c,
                SusepSegCoCorretagem__r.Name,
                SusepSegCoCorretagem__r.NomeCorretor__c,
                SusepTerCoCorretagem__c,
                SusepTerCoCorretagem__r.Name,
                SusepTerCoCorretagem__r.NomeCorretor__c,
                SusepQuaCoCorretagem__c,
                SusepQuaCoCorretagem__r.Name,
                SusepQuaCoCorretagem__r.NomeCorretor__c,
                SusepQuiCoCorretagem__c,
                SusepQuiCoCorretagem__r.Name,
                SusepQuiCoCorretagem__r.NomeCorretor__c,
                ValidoAte__c 
            FROM 
                TransferenciaCorretagem__c 
            WHERE 
                CodCor__c in :listaSUSEP AND
                ValidoAte__c >= TODAY
            ];
    }
    //RVI-311 INICIO
    //Função criada para chamar a geração do pdf por fora do processo para que quando atualize o pdf todas as informações na proposta já tenham sido atualizadas 
    public void callGerarPDFPropostaSync(List<Id> listIdPropostaArquivo){
        QuoteBO.gerarPDFPropostaSync(listIdPropostaArquivo);
    }
    //RVI-311 FIM
    //RVI-310 - FIM
}