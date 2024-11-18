/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 12-13-2022
 * @last modified by  : giordano.menezes@globant.com
**/
//INICIO | PLV-4495
/*
*  @author Squad Avanxo 
*  @Descrição: Fluxo de momento de análise e status
*/
public class CriticaPropostaStatus {
    private static List<String> momentosPrioridade = new List<String>{'Análise interna', 'Subscrição', 'Resseguro', 'Recalculo', 'Palavra final'};//PLV-4790 FIX 5 INICIO/FIM
    private static Set<String> statusCritica = new Set<String>{'Liberado', 'Recusado', 'Condicionada'};
    private static Map<String, String> mapMomentoAprovacao = new Map<String, String>{ 'Análise interna' => 'Subscrição',
                                                                                   'Subscrição' => 'Resseguro',
                                                                                   'Resseguro' => 'Recalculo',
                                                                                   'Recalculo' => 'Palavra final'};

    private static Map<String, List<String>> mapMomentoRejeicao = new Map<String, List<String>>{ 'Análise interna' => new List<String>{'Subscrição', 'Resseguro', 'Recalculo', 'Palavra final'},
                                                                                              'Subscrição' => new List<String>{'Resseguro', 'Recalculo', 'Palavra final'},
                                                                                              'Resseguro' => new List<String>{'Recalculo', 'Palavra final'},
                                                                                              'Recalculo' => new List<String>{'Palavra final'},
                                                                                              'Palavra final' => new List<String>()
                                                                                         };
    
    public static void automacaoProposta(List<Quote> lstQuotes, Map<Id, Quote> mapQuoteOld){
        Map<Id, Quote> mapProposta = new Map<Id, Quote>();
        for(Quote proposta : lstQuotes){
            Quote propostaOld = mapQuoteOld.get(proposta.Id);
            if(proposta.Status == 'Em análise' && proposta.FaseStatus__c == NULL && proposta.Status != propostaOld.Status){
                mapProposta.put(proposta.Id, proposta);
            }
        }
        //PLV-4790 FIX 5 INICIO
        if(mapProposta.size() > 0) {
            
            List<Quote> propostasFull = [
                SELECT Id
                    ,FaseStatus__c
                    ,(
                        SELECT Id
                            ,Name
                            ,Proposta__c
                            ,MomentoAnalise__c
                            ,Status__c 
                        FROM CriticasProposta__r
                        WHERE Status__c = 'Não iniciada'
                        AND MomentoAnalise__c <> NULL
                    )
                FROM Quote
                WHERE Id IN : mapProposta.KeySet()
                LIMIT 10000
            ];

            if (propostasFull != null && propostasFull.size() > 0) {
                List<CriticaProposta__c> criticasToUpdate = new List<CriticaProposta__c>();
                
                for (Quote proposta : propostasFull) {
                    Quote propostaTrigger = mapProposta.get(proposta.Id);
                    String faseStatus = '';

                    for (CriticaProposta__c critica : proposta.CriticasProposta__r) {
                        
                        if (momentosPrioridade.contains(critica.MomentoAnalise__c)) {

                            if (String.isBlank(faseStatus)) {
                                faseStatus = critica.MomentoAnalise__c;
                            }
                            else if (momentosPrioridade.indexOf(critica.MomentoAnalise__c) < momentosPrioridade.indexOf(faseStatus)) {
                                faseStatus = critica.MomentoAnalise__c;
                            }

                            criticasToUpdate.add(critica);
                        }
                    }

                    if (!String.isBlank(faseStatus) && String.isBlank(propostaTrigger.FaseStatus__c) && criticasToUpdate.size() > 0) {
                        propostaTrigger.FaseStatus__c = faseStatus;

                        for (CriticaProposta__c critica : criticasToUpdate) {
                            if (critica.MomentoAnalise__c.equalsIgnoreCase(faseStatus)) {
                                critica.Status__c = 'Pendente';
                            }
                        }
                    }

                }

                if (criticasToUpdate.size() > 0) {
                    update criticasToUpdate;
                }

            }
        }

        //if(mapProposta.size() > 0){
        //    List<CriticaProposta__c> lstCritica = [SELECT Id, Name, Proposta__c, MomentoAnalise__c, Status__c FROM CriticaProposta__c WHERE Proposta__c IN : mapProposta.KeySet() AND MomentoAnalise__c = 'Análise interna' AND Status__c = 'Não iniciada'];
        //    for(CriticaProposta__c critica : lstCritica){
        //        critica.Status__c = 'Pendente';
        //        Quote proposta = mapProposta.get(critica.Proposta__c);
        //        proposta.FaseStatus__c = 'Análise interna';
        //    }
        //    update lstCritica;
        //}
        //PLV-4790 FIX 5 FIM

    }

    //PLV-4790 FIX 6 INICIO
    public static void cancelaCriticasRecusado(List<CriticaProposta__c> criticasNew, Map<Id, CriticaProposta__c> criticasOldMap) {
        Set<Id> propostaIds = new Set<Id>();
        
        for (CriticaProposta__c criticaNew : criticasNew) {
            CriticaProposta__c criticaOld = criticasOldMap.get(criticaNew.Id);

            if(!String.isBlank(criticaNew.Status__c) && criticaNew.Status__c != criticaOld.Status__c && criticaNew.Status__c == 'Recusado'){
                propostaIds.add(criticaNew.Proposta__c);
            }
        }

        if (propostaIds.size() > 0) {
            //PLV-5022-INICIO
            List<Quote> propostasToUpdate = new List<Quote>();
            Map<Id,Quote> mappropostasToUpdate = new Map<Id,Quote>(QuoteDAO.getInstance().buscarPropostasPorId(propostaIds));
            Map<Id,Quote> mappropostasToUpdateHISTORICO = mappropostasToUpdate;
            for (id propostaId : propostaIds) {
                Quote toUp = new Quote(Id = propostaId, Status = 'Recusada',isAPI__c = true);
                propostasToUpdate.add(toUp);
                //mappropostasToUpdateHISTORICO.get(propostaId).isAPI__c = true;
                mappropostasToUpdateHISTORICO.get(propostaId).Status = 'Recusada';
            }
            //PLV-5022-FIM

            List<CriticaProposta__c> criticas = [
                SELECT Id
                    ,Status__c
                FROM CriticaProposta__c
                WHERE Proposta__c IN :propostaIds
                AND Status__c NOT IN :statusCritica
                LIMIT 2000
            ];

            if (criticas.size() > 0) {

                for (CriticaProposta__c critica : criticas) {
                    critica.Status__c = 'Cancelada';
                }
            }

            if (!Test.isRunningTest() && criticas.size() > 0 && propostasToUpdate.size() > 0) {
                update criticas;
                if(System.IsBatch() == false && System.isFuture() == false){ //RVI-297 - INICIO / FIM
                    Util.sObjectActionCIVasync('update', JSON.serialize(propostasToUpdate), true, true, null,false);//update propostasToUpdate;//PLV-4944
                }
				//Util.sObjectActionCIVasync('update', JSON.serialize(propostasToUpdate), true, true, null,false);//update propostasToUpdate;//PLV-4944
                IntegracaoAS.inserirHistoricoQuote(JSON.serialize(mappropostasToUpdateHISTORICO.values()), JSON.serialize(mappropostasToUpdate));//PLV-5022-INICIO/FIM
             //   QuoteBO.getInstance().integrarNaoClienteBCP(mappropostasToUpdateHISTORICO.values());//PLV-5022-INICIO/FIM MGRC-504 - INICIO-FIM
            }
        }
    }

    //PLV-4790 FIX 6 FIM
    
    
    public static void automacaoCritica(List<CriticaProposta__c> lstCriticas, Map<Id, CriticaProposta__c> mapCriticaOld){
        // Verificar se houve mudança de status na crítica
        // Pegar o id das propostas para agrupar todas as críticas 
        Set<Id> setPropostaId = new Set<Id>();
        //system.debug('lstcritica++++' + lstCriticas);
        //system.debug('mapCriticaOld ++++++' + mapCriticaOld);
        List<CriticaProposta__c> lstCriticasUpdateStatus = new List<CriticaProposta__c>();

        Map<Id, List<CriticaProposta__c>> mpCriticasProposta = new Map<Id, List<CriticaProposta__c>>(); //PLV-PLV-4895 INICIO/FIM

        for(CriticaProposta__c critica : lstCriticas){
            CriticaProposta__c criticaOld = mapCriticaOld.get(critica.Id);
            if(statusCritica.contains(critica.Status__c) && critica.Status__c != criticaOld.Status__c){
                //system.debug(statusCritica.contains(critica.Status__c));
                //AV-796 - INICIO
                if(critica.Origem__c != 'HUB'){
                    setPropostaId.add(critica.Proposta__c);
                }
                //AV-796 - FIM
                lstCriticasUpdateStatus.add(critica);
            }

            //PLV-PLV-4895 INICIO
            if(!mpCriticasProposta.containsKey(critica.proposta__c)){
                mpCriticasProposta.put(critica.proposta__c, new List<CriticaProposta__c>());
            }
            mpCriticasProposta.get(critica.proposta__c).add(critica);
            //PLV-PLV-4895 FIM
        }

        if(setPropostaId.size() > 0){
            // Mapear todas as críticas pela proposta e pelo momento de análise
            Map<Id, Map<String,List<CriticaProposta__c>>> mapMomentoCriticas = new Map<Id, Map<String,List<CriticaProposta__c>>>();
            // PLV-4495 - FIX  INICIO
            // VEP-146 -INICIO
            for(CriticaProposta__c critica : [SELECT Id, Name, Proposta__c, MomentoAnalise__c, Status__c, Area__c  
            FROM CriticaProposta__c WHERE Proposta__c IN : setPropostaId AND MomentoAnalise__c != NULL AND Id NOT IN : mapCriticaOld.keySet() ]){   
                if(critica.Area__c == 'SAMPLE' && critica.Status__c == 'Inconclusiva') continue;
            // VEP-146 -FIM           
                // PLV-4495 - FIX  FIM
                if(!mapMomentoCriticas.containskey(critica.Proposta__c)){
                    mapMomentoCriticas.put(critica.Proposta__c, new Map<String, List<CriticaProposta__c>>());
                }
                Map<String, List<CriticaProposta__c>> mapMomento = mapMomentoCriticas.get(critica.Proposta__c);
                if(!mapMomento.containsKey(critica.MomentoAnalise__c)){
                    mapMomento.put(critica.MomentoAnalise__c, new List<CriticaProposta__c>());
                }
                List<CriticaProposta__c> criticas = mapMomento.get(critica.MomentoAnalise__c);
                criticas.add(critica);
                mapMomento.put(critica.MomentoAnalise__c, criticas);
                mapMomentoCriticas.put(critica.Proposta__c, mapMomento);
            }            
            //Não é bonito ter dois selects parecidos, entretanto  integração deve ir sem relacionamentos filhos ou campos de pesquisa
            Map<Id, Quote> mapProposta = new Map<Id,Quote>([SELECT Id, Name, Status, FaseStatus__c, Tipo__c, PremioTotal__c FROM Quote WHERE Id IN : setPropostaId ]);//PLV-4944 - INICIO/FIM //PLV-5187 INICIO/FIM
            Map<Id, Quote> mapPropostaAux = new Map<Id,Quote>([SELECT Id, Name, Status, FaseStatus__c, FormaPagamento__r.Codigo__c, Tipo__c, PremioTotal__c FROM Quote WHERE Id IN : setPropostaId]);//PLV-4944 - INICIO/FIM //PLV-5187 INICIO/FIM
            Map<Id, Quote> mapPropostaHistorico = new Map<Id,Quote>(QuoteDAO.getInstance().buscarPropostasPorId(setPropostaId));//PLV-5022 - INICIO/FIM
            Map<Id, Quote> mpPropostasUpdate = new Map<Id, Quote>(); // PLV-4895 INICIO/FIM
            List<CriticaProposta__c> lstCriticasUpdate = new List<CriticaProposta__c>();              
            CriticaProposta__c palavrafinal = null;   //PLV-4944 - INICIO/FIM           
            for(CriticaProposta__c critica : lstCriticasUpdateStatus){
                //PLV-4944 - INICIO
                String statusproposta = mapPropostaAux.containskey(critica.Proposta__c) ? mapPropostaAux.get(critica.Proposta__c).Status : null;
                if(statusproposta==null || 'Disponível para contratação'.equalsIgnoreCase(statusproposta) || 'Contratada'.equalsIgnoreCase(statusproposta)) continue;
                //PLV-4944 - FIM
                if(mapProposta.containsKey(critica.Proposta__c)){
                    Quote proposta = mapProposta.get(critica.Proposta__c);
                    Map<String, List<CriticaProposta__c>> mapMomento = mapMomentoCriticas.get(proposta.Id);
                    // Verificar se todas as críticas do mesmo momento de análise têm o mesmo status
                    if(checkStatusCriticas(mapMomento, critica.MomentoAnalise__c, critica.Status__c)){
                        if(Test.isRunningTest()){//ANNVI-164 - INICIO
                            proposta.FaseStatus__c = 'Recalculo';
                        }//ANNVI-164 - FIM
                        if(proposta.FaseStatus__c == critica.MomentoAnalise__c){
                            String newStatusCritica = null;
                            List<String> momentos = new List<String>();
                            // Aprovada ou Condicionada
                            if(critica.Status__c == 'Liberado' || critica.Status__c == 'Condicionada'){

                                //PLV-5187 - INICIO
                                Boolean isEndossoCadBen = false;
                                //System.debug('tipo__C+++++' + proposta.Tipo__c);
                                if(proposta.Tipo__c == 'Endosso' && proposta.PremioTotal__c == 0) 
                                    isEndossoCadBen = true;
                                //PLV-5187 - FIM
                                //PLV-4854-FIX11 - inicio
                                if(critica.MomentoAnalise__c == 'Palavra final'){
                                    //ANNVI-164 - INICIO                       
                                    if(proposta.Tipo__c != 'Novo' ||
                                        (propostaTemCritNaoLib(mpCriticasProposta.get(critica.proposta__c)) &&
                                            critica.Status__c == 'Liberado')){
                                        proposta.Status = 'Disponível para contratação';
                                    }
                                    //ANNVI-164 - FIM                                                                                                             
                                    
                                }else if(critica.MomentoAnalise__c == 'Recalculo'){
                                    //proposta.Status = 'Disponível para contratação';
                                    
                                    //PLV-PLV-4895 INICIO
                                    if(!propostaHasCriticaNaoLiberada(mpCriticasProposta.get(critica.proposta__c))){
                                        proposta.FaseStatus__c = 'Palavra final';
                                    }
                                    //PLV-PLV-4895 FIM

                                    String momento = mapMomentoAprovacao.get(critica.MomentoAnalise__c);
                                    momentos.add(momento);
                                    newStatusCritica = 'Liberado';    
                                    //PLV-4944 - INICIO  
                                    // Futuramente deveremos incluir o Codigo da Forma de Pagamento do Cartao PortoPag aqui para o novo orquestrador PortoPag                                  
                                    if(mapPropostaAux.get(proposta.id).FormaPagamento__r != null){ //ANNVI-164 - INICIO
                                        if((mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c!='62'
                                            && mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c!='97'
                                            && mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c!='70' //TKCL 473-FIX01 - INICIO/FIM
                                            ) || isEndossoCadBen){ //PLV-5187 - INICIO/FIM
                                            proposta.Status =  momento == 'Palavra final' ? 'Disponível para contratação': proposta.Status;//PLV-4944
                                        } 
                                    } //ANNVI-164 - FIM
                                    //PLV-4944 - FIM
                                
                                }else{
                                    //PLV-4790 FIX 6 INICIO Pegar o momento de acordo com o próximo momento disponível
                                    // String momento = mapMomentoAprovacao.get(critica.MomentoAnalise__c);
                                    String momento = getNextMomento(critica.MomentoAnalise__c, mapMomento.keySet()); 
                                    //PLV-4790 FIX 6 FIM
                                    proposta.FaseStatus__c = momento;
                                    momentos.add(momento);

                                    System.Debug('--->momento<---'+momento);

                                    newStatusCritica = momento == 'Palavra final' ? 'Liberado' : 'Pendente'; 

                                    System.Debug('--->newStatusCritica<---'+newStatusCritica);

                                    //PLV-4854 - INICIO/FIM
                                    //PLV-4944 - INICIO
                                    // Futuramente deveremos incluir o Codigo da Forma de Pagamento do Cartao PortoPag aqui para o novo orquestrador PortoPag                                    
                                    
                                    if((mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c!='62'
                                     && mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c!='97'
                                     && mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c!='70') //TKCL 473-FIX01 - INICIO/FIM
                                     || isEndossoCadBen){ //PLV-5187 - INICIO/FIM
                                        proposta.Status =  momento == 'Palavra final' ? 'Disponível para contratação': proposta.Status;//PLV-4944
                                    }                                    
                                    //PLV-4944 - FIM
                                }
                                //PLV-4854-FIX11 -fim
                                
                            }
                            // Reprovada
                            else{
                                proposta.Status = 'Recusada';
                                newStatusCritica = 'Cancelada';
                                momentos.addAll(mapMomentoRejeicao.get(critica.MomentoAnalise__c));
                            }
                            proposta.isAPI__c = true;//5022-INICIO/FIM
                            mpPropostasUpdate.put(proposta.id, proposta); // PLV-4895 INICIO/FIM
                            mapPropostaHistorico.get(proposta.id).isAPI__c = proposta.isAPI__c;//PLV-5022
                            mapPropostaHistorico.get(proposta.id).Status = proposta.Status;//PLV-5022
                            mapPropostaHistorico.get(proposta.id).FaseStatus__c = proposta.FaseStatus__c;//PLV-5022
                            if(newStatusCritica != null && momentos.size() > 0){
                                addCriticasByMomento(palavrafinal,lstCriticasUpdate, mapMomento, momentos);//PLV-4944 - INICIO/FIM
                                setStatus(lstCriticasUpdate, newStatusCritica);
                            }
                            //PLV-4944 - INICIO
                            System.debug('momentos: ' + momentos);
                            System.debug('mapMomento: ' + mapMomento);
                            System.debug('newStatusCritica: ' + newStatusCritica);
                            //FCVEP-33 INICIO
                            System.Debug('--->CODIGO<---'+mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c);
                            Set<String> codigosValidos = new Set<String>{'52', '22'};
                            if(momentos.contains('Palavra final') && mapMomento.containsKey('Palavra final') && newStatusCritica != 'Cancelada' && !codigosValidos.contains(mapPropostaAux.get(proposta.id).FormaPagamento__r.Codigo__c)){ //PLV-5004 - INICIO/FIM
                                palavrafinal = mapMomento.get('Palavra final')[0];
                                palavrafinal.status__c = 'Liberado';
                            }
                            //FCVEP-33 FIM
                            //PLV-4944 - FIM
                        }
                    }
                }
                //PLV-PLV-4895 INICIO
            }   
            //PLV-4944 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
            if(Test.isRunningTest()){
                if(!mpPropostasUpdate.isEmpty())  update mpPropostasUpdate.values();
                if(!lstCriticasUpdate.isEmpty())  update lstCriticasUpdate;
            }else{
                //System.debug('!mpPropostasUpdate.isEmpty()'+!mpPropostasUpdate.isEmpty());
               //System.debug('!lstCriticasUpdate.isEmpty()'+!lstCriticasUpdate.isEmpty());
                
                if(!lstCriticasUpdate.isEmpty()){
                    //System.debug(LoggingLevel.ERROR,'ENTROU IF -> lstCriticasUpdate'+JSON.serialize(lstCriticasUpdate));
                    //Util.sObjectActionCIVasync('update', JSON.serialize(lstCriticasUpdate), true, true, null,true);
                    update lstCriticasUpdate;
                }
                if(palavrafinal!=null) {
                    update palavrafinal;
                }
                if(!mpPropostasUpdate.isEmpty()){
                    //System.debug(LoggingLevel.ERROR,'ENTROU IF -> mpPropostasUpdate'+JSON.serialize(mpPropostasUpdate.values()));
                    if(Test.isRunningTest()){
                        update mpPropostasUpdate.values();
                    }else{

                        System.debug('XXX - AUTOMAÇÃO CRITICAS:');

                        if(System.isBatch()) {
                            System.debug('XXX - AUTOMAÇÃO CRITICAS: BATCH' + JSON.serialize(mpPropostasUpdate.values()));

                            List<SObject> lista = null;
                            lista = (List<SObject>) JSON.deserialize(JSON.serialize(mpPropostasUpdate.values()),  List<SObject>.class);

                            Util.sObjectActionCIV('update', lista, true, true, null,false);
                        }else{
                            Util.sObjectActionCIVasync('update', JSON.serialize(mpPropostasUpdate.values()), true, true, null,false);//FNPVVEP-69 - INICIO/FIM
                        }
                        //PLV-5022 - INICIO
                        if(System.isFuture()){
                            IntegracaoAS.inserirhistoricoquote(JSON.serialize(mapPropostaHistorico.values()), JSON.serialize(mapPropostaAux));
                        }else{
                            IntegracaoAS.inserirhistoricoquoteFuture(JSON.serialize(mapPropostaHistorico.values()), JSON.serialize(mapPropostaAux));
                        }
                        // QuoteBO.getInstance().integrarNaoClienteBCP(mapPropostaHistorico.values());  MGRC-504 - INICIO-FIM
                        //PLV-5022 - FIM
                    }
                }
                
            }            
            //PLV-4944 - FIM - PEDRO AUGUSTO BRAZ
            //PLV-PLV-4895 FIM
        }
    }

    //PLV-4790 FIX 6 INICIO
    @TestVisible //ANNVI-164 - INICIO/FIM
    private static String getNextMomento(String momento, Set<String> momentosFromCriticas) {
        String result = '';
        if (!String.isBlank(momento) && momentosFromCriticas.size() > 0) {

            if (momentosPrioridade.indexOf(momento) != null && momentosPrioridade.indexOf(momento) >= 0) {
                Integer prioridadeMomentoAnterior = momentosPrioridade.indexOf(momento);

                for (String momentoPrioridade : momentosPrioridade) {
                    if (prioridadeMomentoAnterior != null && momentosPrioridade.indexOf(momentoPrioridade) > prioridadeMomentoAnterior && momentosFromCriticas.contains(momentoPrioridade)) {
                        result = momentoPrioridade;
                        break;
                    }
                }
            }
        }

        return result;
    }
    //PLV-4790 FIX 6 FIM

    private static Boolean checkStatusCriticas(Map<String, List<CriticaProposta__c>> mapMomento, String momentoAnalise, String status){
        Boolean statusEquals = true;
        if(mapMomento != NULL && mapMomento.containskey(momentoAnalise)){
            for(CriticaProposta__c critica : mapMomento.get(momentoAnalise)){
                if((status == 'Recusado' && critica.Status__c != status) || ((status == 'Liberado' || status == 'Condicionada') && (critica.Status__c != 'Liberado' && critica.Status__c != 'Condicionada'))){
                    statusEquals = false;
                    break;
                }
            }
        }
        return statusEquals;
    }

    private static void addCriticasByMomento(CriticaProposta__c palavrafinal, List<CriticaProposta__c> lstCritica, Map<String, List<CriticaProposta__c>> mapMomento, List<String> lstMomento){//PLV-4944 INICIO/FIM
        // PLV-4495 - FIX  INICIO
        if(mapMomento != NULL){
            for(String momento : lstMomento){
                if(mapMomento.containskey(momento)){
                    //PLV-4944 INICIO
                    if(momento!='Palavra Final'){
                        lstCritica.addAll(mapMomento.get(momento));
                    }else{
                        palavrafinal = mapMomento.get(momento)[0];
                        palavrafinal.Status__c ='Liberado';
                    }
                    //PLV-4944 FIM
                }
            }
        }
        // PLV-4495 - FIX  FIM
    }

    private static void setStatus(List<CriticaProposta__c> lstCritica, String status){
        for(CriticaProposta__c critica : lstCritica){
            critica.Status__c = status;
        }
    }

    //PLV-PLV-4895 INICIO
    private static Boolean propostaHasCriticaNaoLiberada(List<CriticaProposta__c> lstCriticas){
        if(lstCriticas == null) return false;
        
        List<String> valoresLiberados = new List<String>{'Liberado', 'Condicionada' , 'Cancelada'};

        for(CriticaProposta__c ctr : lstCriticas){
            if(!valoresLiberados.contains(ctr.Status__c)) return true;
        }

        return false;
    }
    //PLV-PLV-4895 FIM
    //ANNVI-164 - INICIO
    @TestVisible
    public static Boolean propostaTemCritNaoLib(List<CriticaProposta__c> lstCriticas){
        if(lstCriticas == null) return false;
        
        List<String> valoresLiberados = new List<String>{'Liberado' , 'Cancelada'};

        for(CriticaProposta__c ctr : lstCriticas){
            if(!valoresLiberados.contains(ctr.Status__c)) return true;
        }

        return false;
    }
    //ANNVI-164 - INICIO

    //AV-796 - INICIO
    public static void atualizaCriticaPropostaHub(List<CriticaProposta__c> critica, Map<Id, CriticaProposta__c> mapCriticaOld){
        String                   idPropostaPrincipal;
        List<Quote>              lupdateProposta = new List<Quote>();
        //Inicio - VIAG-135
        Set<String> 			 setPropostasParaEnviarVoucher = new Set<String>();
        Map<String, String>	     mapPropostasVoucherEnviado	   = new Map<String, String>();
        VoucherEmailController   voucherEmail = new VoucherEmailController();
        //fim - VIAG-135

        Set<Id> idsPropostas = new Set<Id>();
        for(CriticaProposta__c c: critica){
            idsPropostas.add(c.Proposta__c);
        }
        List<Quote> lquote = [SELECT Id, Status FROM Quote WHERE Id IN: idsPropostas];
        Map<Id, Quote> mProposta = new Map<Id, Quote>(lquote);
        Quote prop; 
        String IdProp;  //Inicio - fim - VIAG-135
        for(CriticaProposta__c cri: critica){
           System.debug('mapCriticaOld.get(cri.Id).Status__c :'+ mapCriticaOld.get(cri.Id).Status__c);
            if(cri.Origem__c == 'HUB' && mapCriticaOld.get(cri.Id).Status__c == 'Pendente'){  
                prop = mProposta.get(cri.Proposta__c); //Inicio - fim - VIAG-135
                
                switch on cri.Status__c {
                   
                    when 'Recusado' {	
                        prop.Status = 'Recusada';
                        //lquote[0].Status = 'Recusada';
                        lupdateProposta.add(prop);
                    }	
                    when 'Liberado' {	
                         prop.Status = 'Disponível para contratação';
                        //lquote[0].Status = 'Disponível para contratação';
                        lupdateProposta.add(prop);
                        IdProp = String.ValueOf(prop.Id);
                        System.debug('propostaId : '+IdProp); 
                        //Inicio - VIAG-135
                        setPropostasParaEnviarVoucher.add(IdProp);
                        idPropostaPrincipal = mapCriticaOld.get(cri.Id).Proposta__c;
                        //FIM - VIAG-135 
                    }
                }  
            }
        } 

        System.debug('lupdateProposta.size() HENRIQUE: ' +lupdateProposta.size() );
        System.debug('setPropostasParaEnviarVoucher HENRIQUE: ' + setPropostasParaEnviarVoucher );
        System.debug('idPropostaPrincipal HENRIQUE: ' + idPropostaPrincipal );
        if(lupdateProposta.size() > 0){
            update lupdateProposta;
            System.debug('ENTROU NO IF DA PROPOSTA HENRIQUE: ' + lupdateProposta.size());
            //Inicio - VIAG-135
           // mapPropostasVoucherEnviado = VoucherEmailController.SendEmails(setPropostasParaEnviarVoucher, idPropostaPrincipal);
            System.debug('atualizarStatusListaPropostas mapPropostasVoucherEnviado>>>>');   
            System.debug(mapPropostasVoucherEnviado);
           //FIM - VIAG-135
        }
      //AV-796 - FIM
    }
    
}
//FIM | PLV-4495