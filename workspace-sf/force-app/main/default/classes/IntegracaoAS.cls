//PLV-4179 and PLV-4239 - INICIO   
/*
/*  @author: Squad Avanxo 
/*  @description: Classe para integração AS
/*  @modifiedAt: 24/01/2021 PLV-4875
/*/
public class IntegracaoAS {
    //PLV-5111 - INICIO
    private static final String CLASS_NAME = 'IntegracaoAS';
    private static final string TASKNUMBER_EM_CRIACAO_127 = '127'; 
    private static final string TASKNUMBER_EM_ANALISE_84 = '84'; 
    private static final string TASKNUMBER_AGUARDANDO_QUESTIONARIO_162 = '162'; 
    private static final string TASKNUMBER_ASSINATURA_ELETRONICA_PENDENTE_68 = '68'; 
    private static final string TASKNUMBER_ASSINATURA_ELETRONICA_RECUSADA_168 = '168'; 
    private static final string TASKNUMBER_AGUARDA_TELESUBSCRICAO_163 = '163'; 
    private static final string TASKNUMBER_ASSINADA_169 = '169'; 
    private static final string TASKNUMBER_PROPOSTA_SUGESTAO_CALCULO_57 = '57'; 
    private static final string TASKNUMBER_PROPOSTA_EMITIDA_117 = '117'; 
    private static final string TASKNUMBER_PROPOSTA_RECUSADA_115 = '115';  
    private static final string TASKNUMBER_AGUARDANDO_PAGAMENTO = '122'; //FCVEP-33
    //PLV-5111 - FIM

    //PLV-4866 INICIO
    //PLV-4875 INICIO
    public static void execute(List<Quote> listPropostaNew, Map<Id, Quote> mapPropostaOld){
        String METHOD_NAME = 'execute - quotes';//PLV-5111 - INICIO/FIM
        Set<Id> setPropostasIds = (new Map<Id,Quote>(listPropostaNew)).keySet();
        Map<Id, String> mpPropostaOldStatus = new Map<Id, String>();

        for(Id quoteId : getKeySet(mapPropostaOld)) mpPropostaOldStatus.put(quoteId, mapPropostaOld.get(quoteId).status);

        if((System.isBatch() || System.isFuture()) && QuoteTriggerHandler.isAPI!=true ) {//PLV-5022
            inserirHistoricoQuote(setPropostasIds, mpPropostaOldStatus);
        }else if( QuoteTriggerHandler.isAPI!=true ) {//PLV-5022
                //PLV-5111 - INICIO - ajuste de debugs
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => setPropostasIds: ' + setPropostasIds);
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => mpPropostaOldStatus: ' + mpPropostaOldStatus);
                //PLV-5111 - FIM

            inserirHistoricoQuoteFuture(setPropostasIds, mpPropostaOldStatus);
            
        }
    }

    public static void execute(List<CriticaProposta__c> listCriticaNew, Map<Id, CriticaProposta__c> mpCriticaOld){
        String METHOD_NAME = 'execute - criticas';//PLV-5111 - INICIO/FIM

        Set<Id> setCriticasIds = (new Map<Id, CriticaProposta__c>(listCriticaNew)).keySet();
        
        Map<Id, String> mpCriticaOldStatus = new Map<Id, String>();

        for(Id criticaId : getKeySet(mpCriticaOld)) mpCriticaOldStatus.put(criticaId, mpCriticaOld.get(criticaId).Status__c);

        if((System.isBatch() || System.isFuture()) && QuoteTriggerHandler.isAPI!=true ) {//PLV-5022
            inserirHistoricoCritica(setCriticasIds, mpCriticaOldStatus);
        }else if( QuoteTriggerHandler.isAPI!=true ) {//PLV-5022
            inserirHistoricoCriticaFuture(setCriticasIds, mpCriticaOldStatus);
        }
    }
    //PLV-4875 FIM

    public static void inserirHistoricoAS(Set<Id> quoteId){ 
        String METHOD_NAME = 'inserirHistoricoAS';//PLV-5111 - INICIO/FIM
        // PLV-4866 FIM
        //PLV - 4726 Inicio
           Quote proposta = [  
                                SELECT id, MeioComercializacao__c,
                                    Modalidade__r.Codigo__c,RamoSeguro__r.Codigo__c,
                                    CodigoCorretor__r.CodigoSucursalVinculo__c,
                                    Nome_do_contratante__c,Origem__c,NumeroProposta__c, 
                                    CodigoCorretor__r.Name, Account.Cpf__c, Status, Produto__r.Segmento__c, 
                                    CodigoMotivoDevolucao__c, FormaPagamento__r.Codigo__c, Tipo__c, //FCVEP-33
                                    (   
                                        SELECT 
                                            Status__c, Proposta__c, Name, 
                                            MomentoAnalise__c, Integracao__c, 
                                            CreatedDate  
                                        FROM CriticasProposta__r
                                        WHERE MomentoAnalise__c = 'Crítica de Controle' 
                                        AND	  Integracao__c = 'DOCUSIGN'                                        
                                        AND   Status__c != null
                                        ORDER BY createddate 
                                        DESC limit 1
                                    ) 
                                FROM Quote
                                WHERE id In: quoteId  Limit 1
                            ];
        //PLV-5111 - INICIO
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => proposta.Produto__r.Segmento__c: ' + proposta.Produto__r.Segmento__c);
        if(proposta.Produto__r.Segmento__c != 'Individual') return;   					
        //PLV - 4726 FIM    
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => quoteId: ' + quoteId);
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => proposta.CriticasProposta__r: ' + proposta.CriticasProposta__r);
             
        CriticaProposta__c criticasProposta = proposta.CriticasProposta__r.isEmpty()  ? new CriticaProposta__c() : proposta.CriticasProposta__r;        
        
        String codigoTarefa = '';
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => criticasProposta: ' + criticasProposta);
        if (proposta.Status == 'Em criação') codigoTarefa = TASKNUMBER_EM_CRIACAO_127;
        if (proposta.Status == 'Contratada') codigoTarefa = TASKNUMBER_PROPOSTA_EMITIDA_117;
        if (proposta.Status == 'Recusada')   codigoTarefa = TASKNUMBER_PROPOSTA_RECUSADA_115;               
        if (proposta.Status == 'Em análise' && criticasProposta.Status__c == 'Pendente') codigoTarefa = TASKNUMBER_ASSINATURA_ELETRONICA_PENDENTE_68;
        if (proposta.Status == 'Em análise' && criticasProposta.Status__c == 'Recusado') codigoTarefa = TASKNUMBER_ASSINATURA_ELETRONICA_RECUSADA_168;
        if (proposta.Status == 'Em análise' && criticasProposta.Status__c == 'Liberado') codigoTarefa = TASKNUMBER_ASSINADA_169;    
        if (proposta.Tipo__c == 'Novo' && (proposta.FormaPagamento__r.Codigo__c == '21' || proposta.FormaPagamento__r.Codigo__c == '52')) codigoTarefa = TASKNUMBER_AGUARDANDO_PAGAMENTO; //FCVEP-33      

        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => proposta: ' + proposta);
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => proposta.Status: ' + proposta.Status);
                
        IntegracaoAS__mdt task = MetadataDAO.getInstance().buscarDadosIntegracaoAS(codigoTarefa);
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => task: ' + task);
        //PLV-5111 - FIM

        if(task == null) return;
        String resposta = '';
        DTO payload = new DTO(proposta, task);        
        // resposta = Test.isRunningTest() ? '':CIVServices.getInstance().integracaoAS(JSON.serialize(payload)); //ZSVEP-67 - INICIO / FIM
        System.debug('Sensedia');
        System.debug('Sensedia payload ' + payload);
    
        resposta = Test.isRunningTest() ? '':SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.INTEGRACAO_AS, JSON.serialize(payload)); //MGRC-1274 - INICIO / FIM
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => resposta: ' + resposta);//PLV-5111 - INICIO/FIM
     
        //idproposta, status resposta, mensagem resposta
   
    }

    //PLV-4365 INICIO
    public static void enviarSubscricao(Quote proposta, CriticaProposta__c critica, IntegracaoAS__mdt task) { //PLV-4644 INICIO/FIM 
        DTO payload = new DTO();

        //build payload
        payload.numeroOrigem = proposta.Origem__c;
        payload.numeroProposta = proposta.NumeroProposta__c;
        payload.susepCorretor = proposta.CodigoCorretor__r.Name;
    
        if (proposta.Account.Cpf__c != null) {
            String cpf = proposta.Account.Cpf__c.replace('.','').replace('-','');
            payload.digitoCGCCPF = cpf.right(2);
            payload.numeroCGCCPF = cpf.left(9);
        } 
        
        payload.nomeSegurado = proposta.Nome_do_contratante__c;
        payload.tipoPessoa = 'F';
        
        payload.codigoTarefa = task.Tarefa__c;
        payload.codigoUnidade = task.Unidade__c;
        payload.setor = task.Setor__c;
        
        System.debug('IntegracaoAS :: gerarTarefaTeleSubscricao :: payload : ' + JSON.serializePretty(payload, true)); 

        //send request
        // String resposta = CIVServices.getInstance().integracaoAS(JSON.serialize(payload)); //ZSVEP-67 - INICIO / FIM
        System.debug('Sensedia');
        System.debug('Sensedia payload ' + payload);
        String resposta = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.INTEGRACAO_AS, JSON.serialize(payload));//MGRC-1274 - INICIO / FIM

        System.debug('IntegracaoAS :: gerarTarefaTeleSubscricao :: resposta : ' + resposta); 

        if (!String.isBlank(resposta)) {

            //get response
            ResponseAS response = (ResponseAS) JSON.deserialize(resposta, ResponseAS.class);

            if (response.codigo != 0) {
                //PLV-4644 INICIO
                System.debug('Retorno Integração - Tarefa Subscrição AS-SampleMed : ' + JSON.serializePretty(response));
                //save error
                //notasDeErro.add(new Note(
                //    ParentId = critica.Id,
                //    Body = JSON.serializePretty(response),
                //    Title = 'Retorno Integração - Tarefa Subscrição AS-SampleMed'
                //));
                //PLV-4644 FIM
            }
        }
    }

    //PLV-4875 INICIO
    //PLV-5022 INICIO - PEDRO AUGUSTO BRAZ 
    public static Boolean inserirHistoricoQuote(Set<Id> setIdPropostaNew, Map<Id, String> mapPropostaOldStatus){

        List<Quote> listPropostaNew = QuoteDAO.getInstance().buscarPropostasPorId(setIdPropostaNew);
        System.debug('LISTPROPOSTANEW: ' + listPropostaNew[0].Tipo__c);
        Map<Id, Quote> mapPropostaOld = buildMpPropostaOld(mapPropostaOldStatus);
        return processar(listPropostaNew,mapPropostaOld);
           
    }
    @future(callout=true)
    public static void inserirHistoricoQuoteFuture(String plistPropostaNew, String pmapPropostaOldStatus){
        inserirHistoricoQuote(plistPropostaNew,pmapPropostaOldStatus);
    }
    
    public static Boolean inserirHistoricoQuote(String plistPropostaNew, String pmapPropostaOldStatus){

        List<Quote> listPropostaNew = (List<Quote>) JSON.deserialize(plistPropostaNew,List<Quote>.class);
        Map<Id, Quote> mapPropostaOld = (Map<Id, Quote>) JSON.deserialize(pmapPropostaOldStatus,Map<Id, Quote>.class);
        
        return processar(listPropostaNew,mapPropostaOld);
    }

    public static Boolean processar(List<Quote> listPropostaNew,Map<Id, Quote> mapPropostaOld){
        String METHOD_NAME = 'processar';
        
        // FNPVVEP-16 - INICIO
        List<DTO> lstIntegracoesAS = new List<DTO>();

        for(Quote listaDeProposta : listPropostaNew){
            if(listaDeProposta.Tipo__c != 'Renovacao' && listaDeProposta.Tipo__c != 'Endosso'){ // FNPVVEP-16-FIX01 - INICIO/FIM
                System.debug('DEBUG HENRIQUE ENTROU NO IF: ' + listaDeProposta.Tipo__c );
                lstIntegracoesAS = getIntegracoes(listPropostaNew, mapPropostaOld);
            }
        }
        // FNPVVEP-16 - FIM

        System.debug('LISTA DE INTEGRAÇÃO: ' + lstIntegracoesAS);
        if(lstIntegracoesAS.isEmpty())  return false;
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => lstIntegracoesAS: ' + lstIntegracoesAS);//PLV-5111 - INICIO/FIM
        System.debug('Danilo 2 lstIntegracoesAS ' + lstIntegracoesAS);
        for(DTO integracaoAs: lstIntegracoesAS){
            System.debug('Danilo 2 integracaoAs ' + integracaoAs);
            String payload = JSON.serialize(integracaoAs);
            System.debug('Danilo 2 payload ' + payload);
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => integracaoAs.codigoTarefa: ' + integracaoAs.codigoTarefa);//PLV-5111 - INICIO/FIM
            // String resposta =  Test.isRunningTest() ? '{}' : CIVServices.getInstance().integracaoAS(payload); //ZSVEP-67 - INICIO / FIM
            System.debug('Sensedia');
            System.debug('Sensedia payload ' + payload);
            String resposta =  Test.isRunningTest() ? '{}' : SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.INTEGRACAO_AS, payload); //MGRC-1274 - INICIO / FIM 
            System.debug('Danilo 2 resposta ' + resposta);
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => resposta: ' + resposta);//PLV-5111 - INICIO/FIM
        }

        return true;
    }
    //PLV-5022 FIM - PEDRO AUGUSTO BRAZ 

    @future(callout=true)
    public static void inserirHistoricoQuoteFuture(Set<Id> setIdPropostaNew, Map<Id, String> mapPropostaOld){
        inserirHistoricoQuote(setIdPropostaNew, mapPropostaOld);
    }

    public static Boolean inserirHistoricoCritica(Set<Id> setIdCriticaNew, Map<Id, String> mapCriticaOldStatus){
        String METHOD_NAME = 'inserirHistoricoCritica';//PLV-5111 - INICIO/FIM
        List<CriticaProposta__c> listCriticaNew = getCriticas(setIdCriticaNew);
        Map<Id, CriticaProposta__c> mapCriticaOld = buildMpCriticaOld(mapCriticaOldStatus);

        Set<Id> setPropostaIds = new Set<Id>();

        for(CriticaProposta__c criticaProposta : listCriticaNew) setPropostaIds.add(criticaProposta.Proposta__c);
        if(setPropostaIds.isEmpty()) return false;

        Map<Id, Quote> mpProposta = new Map<Id, Quote>(QuoteDAO.getInstance().buscarPropostasPorId(setPropostaIds));//PLV-5022-INICIO/FIM

        List<DTO> lstIntegracoesAS = getIntegracoes(listCriticaNew, mapCriticaOld, mpProposta);
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => lstIntegracoesAS: ' + JSON.serialize(lstIntegracoesAS));//PLV-5111 - INICIO/FIM

        if(lstIntegracoesAS.isEmpty()) return false;
        System.debug('lstIntegracoesAS Danilo: ' + lstIntegracoesAS);
        for(DTO integracaoAs: lstIntegracoesAS){
            String payload = JSON.serialize(integracaoAs);
            System.debug('payload Danilo: ' + payload);
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => tarefa enviada para o AS: ' + integracaoAs.codigoTarefa);//PLV-5111 - INICIO/FIM
            // String resposta =  Test.isRunningTest() ? '{}' : CIVServices.getInstance().integracaoAS(payload); //ZSVEP-67 - INICIO / FIM
            System.debug('Sensedia');
            System.debug('Sensedia payload ' + payload);
            String resposta =  Test.isRunningTest() ? '{}' : SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.INTEGRACAO_AS, payload);//MGRC-1274 - INICIO / FIM
            System.debug('resposta Danilo: ' + resposta);
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => resposta do AS: ' + resposta);//PLV-5111 - INICIO/FIM
        }

        return true;  
    }

    @future(callout=true)
    public static void inserirHistoricoCriticaFuture(Set<Id> setIdCriticaNew, Map<Id, String> mapCriticaOld){
        inserirHistoricoCritica(setIdCriticaNew, mapCriticaOld);
    }

    private static List<DTO> getIntegracoes(List<CriticaProposta__c> listCriticaNew, Map<Id, CriticaProposta__c> mapCriticaOld, Map<Id, Quote> mpProposta){
        String METHOD_NAME = 'getIntegracoes - Critica';
        List<DTO> lstIntegracoesAS = new List<DTO>();
        for(CriticaProposta__c criticaProposta : listCriticaNew){//dentro do for
            if(!mpProposta.containsKey(criticaProposta.Proposta__c)) continue;

            Quote proposta = mpProposta.get(criticaProposta.Proposta__c);
            if(proposta.Produto__r.Segmento__c == null || proposta.Produto__r.Segmento__c.toLowercase() != 'individual') continue;

            String taskNumber = getASTaskNumber(criticaProposta, mapCriticaOld.get(criticaProposta.id));
            if(taskNumber == '') continue;
            
            lstIntegracoesAS.add(new DTO(proposta, taskNumber));

            //PLV-5111 - FIX02 - INICIO
            if (taskNumber != TASKNUMBER_EM_ANALISE_84 &&
                criticaProposta.Setor__c == 'Emissão' && 
                (criticaProposta.MomentoAnalise__c == 'Análise interna' || 
                    criticaProposta.MomentoAnalise__c == 'Subscrição' || 
                    criticaProposta.MomentoAnalise__c == 'Resseguro' || 
                    criticaProposta.MomentoAnalise__c == 'Recálculo' || 
                    criticaProposta.MomentoAnalise__c == 'Palavra Final') )
            {
                lstIntegracoesAS.add(new DTO(proposta, TASKNUMBER_EM_ANALISE_84));
            }
            //PLV-5111 - FIX02 - FIM
            System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => lstIntegracoesAS: ' + lstIntegracoesAS);//PLV-5111 - INICIO/FIM
        }

        if(lstIntegracoesAS.isEmpty()) return lstIntegracoesAS;

        Map<String, IntegracaoAS__mdt> mpTasks = MetadataDAO.getInstance().buscarDadosIntegracaoAS(getTaskNumberList(lstIntegracoesAS));

        for (Integer i = lstIntegracoesAS.size() - 1 ; i >= 0 ; i--){
            DTO integracaoAs = lstIntegracoesAS[i];
            IntegracaoAS__mdt task = mpTasks.get(integracaoAs.codigoTarefa);

            if(task == null) lstIntegracoesAS.remove(i);
            else integracaoAs.setTask(task);
        } 
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => lstIntegracoesAS: ' + lstIntegracoesAS);//PLV-5111 - INICIO/FIM
        return lstIntegracoesAS;
    }

    private static List<DTO> getIntegracoes(List<Quote> listPropostaNew, Map<Id, Quote> mapPropostaOld){
        
        List<DTO> lstIntegracoesAS = new List<DTO>();
        
        Set<Id> setProductId = new Set<Id>();
        for(Quote proposta : listPropostaNew){
            if(proposta.Produto__r.Segmento__c == null)setProductId.add(proposta.Produto__c);
        }
        
        Map<Id, Product2> mpProduct = setProductId.isEmpty() ? new  Map<Id, Product2>() : getMpProduct(setProductId);

        for(Quote proposta : listPropostaNew){
            
            Product2 produto = proposta.produto__r != null ? proposta.produto__r : mpProduct.get(proposta.Produto__c);
            if(produto == null || produto.Segmento__c == null || produto.Segmento__c.toLowercase() != 'individual') continue;

            String taskNumber = getASTaskNumber(proposta, mapPropostaOld.get(proposta.id));
            if(taskNumber == '') continue; // para status "Em criação" ou para status não trabalhados
            //PLV-5111 - INICIO
            if (taskNumber == TASKNUMBER_EM_ANALISE_84) { //caso receba tarefa "Em análise", cria tarefa "Em criação" automaticamente
                lstIntegracoesAS.add(new DTO(proposta, TASKNUMBER_EM_CRIACAO_127));
            }
            //PLV-5111 - FIM
                
            lstIntegracoesAS.add(new DTO(proposta, taskNumber));
            //PLV-5750 INICIO
            if (taskNumber == TASKNUMBER_EM_CRIACAO_127) { 
                lstIntegracoesAS.add(new DTO(proposta, TASKNUMBER_PROPOSTA_EMITIDA_117));
            }
            //PLV-5750 FIM
        }

        if(lstIntegracoesAS.isEmpty()) return lstIntegracoesAS;

        Map<String, IntegracaoAS__mdt> mpTasks = MetadataDAO.getInstance().buscarDadosIntegracaoAS(getTaskNumberList(lstIntegracoesAS));
        for (Integer i = lstIntegracoesAS.size() - 1 ; i >= 0 ; i--){
            DTO integracaoAs = lstIntegracoesAS[i];
            IntegracaoAS__mdt task = mpTasks.get(integracaoAs.codigoTarefa);

            if(task == null) lstIntegracoesAS.remove(i);
            else integracaoAs.setTask(task);
        } 

        return lstIntegracoesAS;
    }

    @testVisible
    private static String getASTaskNumber(CriticaProposta__c criticaProposta, CriticaProposta__c criticaOld){
        //PLV-5111 - INICIO
        String METHOD_NAME = 'getASTaskNumber';
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => criticaProposta: ' + criticaProposta);
        System.debug(LoggingLevel.ERROR + ' - CLASS_NAME: '+ CLASS_NAME + ' => METHOD_NAME: '+ METHOD_NAME + ' => criticaOld: ' + criticaOld);
        //PLV-5111 - FIM
        String integracao = criticaProposta.Integracao__c;
        String status = criticaProposta.Status__c;
        String momentoAnalise = criticaProposta.MomentoAnalise__c;
        String acao = criticaProposta.Acao__c;
        
        if(criticaOld == null){
            return '';
        } else if(criticaProposta.Status__c != criticaOld.Status__c){
            if(integracao == 'DOCUSIGN'){
                //PLV-5111 - ajuste de variáveis de retorno
                if(momentoAnalise == 'Análise interna'){
                    if(status == 'Pendente') return TASKNUMBER_ASSINATURA_ELETRONICA_PENDENTE_68;
                    else if(status == 'Recusado') return TASKNUMBER_ASSINATURA_ELETRONICA_RECUSADA_168;
                    else if(status == 'Liberado') return TASKNUMBER_ASSINADA_169;
                }else if(momentoAnalise == 'Recalculo') {
                    if(status == 'Pendente') return TASKNUMBER_PROPOSTA_SUGESTAO_CALCULO_57;
                }
            }if(integracao == 'SAMPLE'){
                if(status == 'Pendente'){
                    if(acao == 'auto') return TASKNUMBER_AGUARDANDO_QUESTIONARIO_162;
                    else if(acao == 'tele' || acao == 'video') return TASKNUMBER_AGUARDA_TELESUBSCRICAO_163;
                }
                else if(status == 'Inconclusiva') return TASKNUMBER_EM_ANALISE_84;
                //PLV-5111 - FIM - ajuste de variáveis de retorno
            }
        }
        return '';
    }

    @testVisible
    private static String getASTaskNumber(Quote proposta, Quote propostaOld){
        String status = proposta.Status;
        //PLV-5750 INICIO
        List<CriticaProposta__c> listCriticas = [SELECT MomentoAnalise__c FROM CriticaProposta__c WHERE Proposta__c =: proposta.id];
        Boolean hasMomentoFinal = false;
        for(CriticaProposta__c critica : listCriticas){
            if(critica.MomentoAnalise__c == 'Palavra final') hasMomentoFinal = true;
        }
        //PLV-5750 FIM
        if(propostaOld == null){
            //PLV-5111 - INICIO
            // caso o status proposta seja "Em criação" a integração AS não é executada, sendo
            //  executada após o status chegar para "Em análise", realizando a integração do código
            //  referente ao status de "Em criação" e em seguida o "Em análise", tudo no mesmo contexto
            //  evitando a entrada em sequencia errada das integrações.
            //if(status == 'Em criação')                      return '127';
            if(status == 'Em criação')                      return ''; 
        }else if(proposta.status != propostaOld.status){
            String statusOld = propostaOld.Status; //PLV-5750 INICIO/FIM
            if(status == 'Em análise')                      return TASKNUMBER_EM_ANALISE_84;
            else if(status == 'Contratada'){
                if((statusOld == 'Disponível para contratação' || statusOld == 'Em criação') && !hasMomentoFinal) return TASKNUMBER_EM_CRIACAO_127; //PLV-5750 INICIO/FIM
                return TASKNUMBER_PROPOSTA_EMITIDA_117;
            }                 
            else if(status == 'Recusada')                   return TASKNUMBER_PROPOSTA_RECUSADA_115;
        }
        //PLV-5111 - FIM
        return '';
    }

    private static List<String> getTaskNumberList(List<DTO> lstDTO){
        List<String> lstTasks = new List<String>();

        for(DTO i : lstDTO) lstTasks.add(i.codigoTarefa);

        return lstTasks;
    }
    //PLV-5022- INICIO - TECHO REMOVIDO - PEDRO AUGUSTO BRAZ
    /*private static List<Quote> getPropostas(Set<Id> setPropostaIds){
        List<Quote> lstQuote = [
            SELECT 
            Status,
            Nome_do_contratante__c, 
            Origem__c, 
            NumeroProposta__c, 
            CodigoMotivoDevolucao__c, 
            
            Produto__r.Segmento__c, 
            Modalidade__r.Codigo__c, 
            RamoSeguro__r.Codigo__c, 
            
            CodigoCorretor__r.Name, 
            CodigoCorretor__r.CodigoSucursalVinculo__c,
            Account.Cpf__c
            
            FROM Quote
            WHERE Id IN: setPropostaIds
            ];
            
            return lstQuote;
    }*/
    //PLV-5022- FIM - TECHO REMOVIDO - PEDRO AUGUSTO BRAZ

    private static List<CriticaProposta__c> getCriticas(Set<Id> setCriticasIds){
        List<CriticaProposta__c> lstCritica = [
            SELECT 
                Proposta__c,
                Integracao__c,
                Status__c,
                MomentoAnalise__c,
                Setor__c, //PLV-5111 - FIX02 - INICIO/FIM
                Acao__c

                FROM CriticaProposta__c
            WHERE Id IN: setCriticasIds
        ];

        return lstCritica;
    }
    
    private static Map<Id, Product2> getMpProduct(Set<Id> setProIds){
        List<Product2> lstProduct = [ SELECT Segmento__c from Product2 where Id IN: setProIds ];
        
        return new Map<Id, Product2>(lstProduct);
    }

    private static Map<Id, Quote> buildMpPropostaOld(Map<Id, String> mapPropostaOld){
        Map<Id, Quote> response = new Map<Id, Quote>();

        for(Id quoteId : mapPropostaOld.keySet()) response.put(quoteId, new Quote(Status = mapPropostaOld.get(quoteId)));

        return response;
    }

    private static Map<Id, CriticaProposta__c> buildMpCriticaOld(Map<Id, String> mapCriticaOld){
        Map<Id, CriticaProposta__c> response = new Map<Id, CriticaProposta__c>();

        for(Id criticaId : mapCriticaOld.keySet()) response.put(criticaId, new CriticaProposta__c(Status__c = mapCriticaOld.get(criticaId)));

        return response;
    }

    private static Set<Id> getKeySet(Map<Id, sObject> mpSObject){
        if(mpSObject == null) mpSObject = new Map<Id, sObject>();

        return mpSObject.keySet();
    }
    //PLV-4875 FIM

    public class ResponseAS {
        public Integer codigo;
        public String mensagem;
    }
    //PLV-4365 FIM

    private class DTO {
        public String codigoCGC { get; set; }
        public String codigoModalidade { get; set; }
        public String codigoRamo { get; set; }
        public String codigoSucursal { get; set; }
        public String codigoTarefa { get; set; }
        public String codigoUnidade { get; set; }
        public String digitoCGCCPF { get; set; }
        public String nomeSegurado { get; set; }
        public String numeroCGCCPF { get; set; }
        public String numeroOrigem { get; set; }
        public String numeroProposta { get; set; }
        public String numeroSegurado { get; set; }
        public String setor { get; set; }
        public String susepCorretor { get; set; }
        public String tipoPessoa { get; set; }
        public String codigoConvenio  { get; set; }
        public String codigoMotivoDevolucao  { get; set; }

        //PLV-4365 INICIO
        public DTO() {

        }
        //PLV-4365 FIM
       
        public DTO(Quote proposta, IntegracaoAS__mdt task) {
            this.codigoCGC = '';
            this.numeroSegurado = '';
            this.tipoPessoa = 'F';
            this.codigoConvenio = '';            
            this.codigoMotivoDevolucao = proposta.CodigoMotivoDevolucao__c != '' ? proposta.CodigoMotivoDevolucao__c : '';             
            
            this.codigoModalidade = proposta.Modalidade__r.Codigo__c;
            this.codigoRamo = proposta.RamoSeguro__r.Codigo__c;
            this.codigoSucursal = proposta.CodigoCorretor__r.CodigoSucursalVinculo__c;
            this.nomeSegurado = proposta.Nome_do_contratante__c;
            this.numeroOrigem = proposta.Origem__c;
            this.numeroProposta = proposta.NumeroProposta__c;
            this.susepCorretor = proposta.CodigoCorretor__r.Name;

            this.codigoTarefa = task.Tarefa__c;
            this.codigoUnidade = task.Unidade__c;
            this.setor = task.Setor__c;

            this.setCpfData(proposta.Account.Cpf__c);
        }

         //PLV-4875 INICIO
        public DTO(Quote proposta, String task) {
            this.codigoCGC = '';
            this.numeroSegurado = '';
            this.tipoPessoa = 'F';
            this.codigoConvenio = '';            
            this.codigoMotivoDevolucao = proposta.CodigoMotivoDevolucao__c != '' ? proposta.CodigoMotivoDevolucao__c : '';
            
            //! Validação deve ser removida quando for automatizado o preenchimento do motivo da recusa
            if(task == TASKNUMBER_PROPOSTA_RECUSADA_115 && (proposta.CodigoMotivoDevolucao__c == '' || proposta.CodigoMotivoDevolucao__c == null)){
                this.codigoMotivoDevolucao = '449';
            }
            
            this.codigoModalidade = proposta.Modalidade__r.Codigo__c;
            this.codigoRamo = proposta.RamoSeguro__r.Codigo__c;
            this.codigoSucursal = proposta.CodigoCorretor__r.CodigoSucursalVinculo__c;
            this.nomeSegurado = proposta.Nome_do_contratante__c;
            this.numeroOrigem = proposta.Origem__c;
            this.numeroProposta = proposta.NumeroProposta__c;
            this.susepCorretor = proposta.CodigoCorretor__r.Name;

            this.setCpfData(proposta.Account.Cpf__c);

            this.codigoTarefa = task;
        }

        public void setTask(IntegracaoAS__mdt task){
            this.codigoTarefa = task.Tarefa__c;
            this.codigoUnidade = task.Unidade__c;
            this.setor = task.Setor__c;
        }
		
		
        private void setCpfData(String cpf){
            if(cpf != null){
                cpf = cpf.replace( '.', '' ).replace( '-', '' );
                
                this.digitoCGCCPF = cpf.right(2);
                this.numeroCGCCPF = cpf.left(9);
            }
        }
        //PLV-4875 FIM
    }

}
//PLV-4179 and PLV- 4239 - FIM