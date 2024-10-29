/*
@Author: Pedro Augusto Braz - SYS4B
@Date: 21/01/2021
@Description: CLASSE CRIADA PARA APAGAR ARQUIVOS E REGISTROS DA ORG
GENTILEZA IR ATÉ O USUÁRIO DE INTEGRAÇÃO, LOGAR COMO ELE E RODAR O MÉTODO INICIAR DA CLASSE COMO ELE


★★★★★★★★★★★★★★★
UPDATE 22/03/2021
Foi criado um componente para deleção dos registros
★★★★★★★★★★★★★★★

*********************************
COMO FUNCIONA A CLASSE?
Rode ela até a org estar limpa!

Execute no Developer Console:
LimparUsuario.iniciar(-2,true,true,false);
LimparUsuario.iniciar(0,true,true,false); para apagar a partir de ontem
1 - Quantidade de Dias em relação a hoje
2 - Limpar arquivos
3 - Limpar registros
4 - Rodar metodos em modo futuro (dobrando o limite)





*/
public class LimparUsuario {
    
    public static void iniciar(Integer dias,Boolean arquivos,Boolean registros,Boolean futuro){
        if(!futuro){
            if(arquivos){limparArquivos(dias,futuro);}
            if(registros){limparRegistros(dias,futuro);}
        }else{
            limparFuturo(dias,arquivos,registros,futuro);
        }
    }
    @future(callout=true)
    public static void limparFuturo(Integer dias,Boolean arquivos,Boolean registros,Boolean futuro){
         if(arquivos){limparArquivos(dias,futuro);}
         if(registros){limparRegistros(dias,futuro);}
    }
    public static void limparArquivos(Integer dias,Boolean futuro){
        Date  datafim = System.today().addDays(dias);
        Date  datainit = datafim.addMonths(-10);
        
        List<sObject> toDel = [SELECT Id from ContentDocument where title like '%servico%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Servico%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Endosso%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%endosso%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%voucher%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%storage%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Apolice%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Pedro%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%Proposta%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%CO2%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%BAK%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%CO2-%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
        
        toDel = [SELECT Id from ContentDocument where title like '%BAK-%' AND lastmodifieddate > :datainit AND lastmodifieddate < :datafim];
        System.debug('Apagando arquivos: '+toDel.size());
        delete toDel;
    }
    public static void limparRegistros(Integer dias,Boolean futuro){
        //CONFIGURAR PERIODO
        Date  datafim = System.today().addDays(dias);
        Date  datainit = datafim.addMonths(-10);
        Integer total = 0;
        Integer limite = futuro ? 20000 : 10000;
        
        List<String> objetosToDel = objetos().values();
         
        for(String obj : objetosToDel){
            if(obj=='' || total>limite)continue;
            List<sObject> lista = Database.query('SELECT Id FROM '+obj+' WHERE lastmodifieddate > :datainit AND lastmodifieddate < :datafim LIMIT 10000');
            if(lista==null || !lista.isEmpty()){
                System.debug('Objeto: '+ obj +' - Apagando Registros : '+ lista.size());
                total =total+ lista.size();
                if(total<limite)
                Database.delete(lista,false);
            }else{
                System.debug('Objeto: '+ obj +' VAZIO');
            }
        }
        System.debug('Total Apagado: '+ total);

    }

/*
    ██╗███╗░░██╗██╗░█████╗░██╗░█████╗░
    ██║████╗░██║██║██╔══██╗██║██╔══██╗
    ██║██╔██╗██║██║██║░░╚═╝██║██║░░██║
    ██║██║╚████║██║██║░░██╗██║██║░░██║
    ██║██║░╚███║██║╚█████╔╝██║╚█████╔╝
    ╚═╝╚═╝░░╚══╝╚═╝░╚════╝░╚═╝░╚════╝░

    ░█████╗░░█████╗░███╗░░░███╗██████╗░░█████╗░███╗░░██╗███████╗███╗░░██╗████████╗███████╗
    ██╔══██╗██╔══██╗████╗░████║██╔══██╗██╔══██╗████╗░██║██╔════╝████╗░██║╚══██╔══╝██╔════╝
    ██║░░╚═╝██║░░██║██╔████╔██║██████╔╝██║░░██║██╔██╗██║█████╗░░██╔██╗██║░░░██║░░░█████╗░░
    ██║░░██╗██║░░██║██║╚██╔╝██║██╔═══╝░██║░░██║██║╚████║██╔══╝░░██║╚████║░░░██║░░░██╔══╝░░
    ╚█████╔╝╚█████╔╝██║░╚═╝░██║██║░░░░░╚█████╔╝██║░╚███║███████╗██║░╚███║░░░██║░░░███████╗
    ░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚═╝░░░░░░╚════╝░╚═╝░░╚══╝╚══════╝╚═╝░░╚══╝░░░╚═╝░░░╚══════╝
*/
    public static final String DEF_REGISTROS = 'opcoesRegistro';
    public static final String DEF_DOCUMENTOS = 'opcoesDocumento';
    public static final String DEF_DATA_INICIAL = 'dataInicial';
    public static final String DEF_DATA_INICIAL_LIMITE = 'dataLimite';
    public static final String DEF_DATA_FINAL = 'dataFinal';
    public static final String DEF_TOTAL_APAGADO = 'totalApagado';
    public static final String DEF_MENSAGEM = 'resultadoMensagem';
    public static final String DEF_LOGS = 'log';
    public static final String DEF_SIMULAR = 'simular';
    public static final String DEF_PERMISSOES = 'permissoes';
    public static final String DEF_canUSE = 'canUse';
    public static final String DEF_canFILES = 'canFiles';
    public static final String DEF_canRECORDS = 'canRecords';
    public static final String DEF_canPERIOD = 'canPeriod';
    public static final String DEF_ORG = 'org';
    
    @AuraEnabled
    public static Map<String,Object> apagarItens(String retorno){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        String mensagemToReturn = '****** INICIO LOG ******<br/>';
        System.debug(LoggingLevel.Error,'entrada apagar'+retorno);
        try {
            
        
            Map<String, Object> m =  (Map<String, Object>) JSON.deserializeUntyped(retorno);
            
            List<Objeto> Registros = (List<Objeto>)  JSON.deserialize(JSON.serialize(m.get(DEF_REGISTROS)), List<Objeto>.class);
            List<Objeto> documentos = (List<Objeto>)  JSON.deserialize(JSON.serialize(m.get(DEF_DOCUMENTOS)), List<Objeto>.class);
            String[] dtInicial = (String)m.get(DEF_DATA_INICIAL) !=null ? String.valueOf(m.get(DEF_DATA_INICIAL)).split('-'): null;
            String[] dtLimite = (String)m.get(DEF_DATA_INICIAL_LIMITE) !=null ? String.valueOf(m.get(DEF_DATA_INICIAL_LIMITE)).split('-'): null;
            String[] dtFinal = (String)m.get(DEF_DATA_FINAL) !=null ? String.valueOf(m.get(DEF_DATA_FINAL)).split('-'): null;
            Datetime dataInicial =  Datetime.newInstance(Integer.valueOf(dtInicial[0]), Integer.valueOf(dtInicial[1]),Integer.valueOf(dtInicial[2]));
            Datetime dataLimite = Datetime.newInstance(Integer.valueOf(dtLimite[0]), Integer.valueOf(dtLimite[1]),Integer.valueOf(dtLimite[2]));
            Datetime dataFinal = Datetime.newInstance(Integer.valueOf(dtFinal[0]), Integer.valueOf(dtFinal[1]),Integer.valueOf(dtFinal[2]));
            mapToReturn.put(DEF_REGISTROS,Registros);
            mapToReturn.put(DEF_DOCUMENTOS,documentos);
            mapToReturn.put(DEF_DATA_INICIAL_LIMITE,m.get(DEF_DATA_INICIAL_LIMITE));
            mapToReturn.put(DEF_DATA_INICIAL,m.get(DEF_DATA_INICIAL));
            mapToReturn.put(DEF_DATA_FINAL,m.get(DEF_DATA_FINAL));
            mapToReturn.put(DEF_SIMULAR,(Boolean)m.get(DEF_SIMULAR));
            mapToReturn.put(DEF_PERMISSOES,m.get(DEF_PERMISSOES));
            mapToReturn.put(DEF_ORG,m.get(DEF_ORG));

            Boolean simular = (Boolean) m.get(DEF_SIMULAR);
            if(simular) mensagemToReturn += '★━━━━━━━━━━ SIMULADO ━━━━━━━━━━★<br/>';
            
            if(dataInicial==null || dataLimite==null || dataFinal==null){
                mapToReturn.put(DEF_MENSAGEM,'Datas inválidas');
                return mapToReturn;
            }
            Integer Limite = 10000;
            Integer TotalApagado = 0;


            //APAGANDO REGISTROS
            m = limparRegistrosComponente(Registros, dataFinal, dataInicial, Limite, simular);
            Registros = (List<Objeto>)  JSON.deserialize(JSON.serialize(m.get(DEF_REGISTROS)), List<Objeto>.class);
            mapToReturn.put(DEF_REGISTROS,Registros);
            TotalApagado = (Integer) m.get(DEF_TOTAL_APAGADO);
            mensagemToReturn += '<br/>'+(String) m.get(DEF_LOGS);
            Limite = Limite - TotalApagado;
            if(Limite < 0){
                mensagemToReturn += ' <br/>Limite de deleção atingido - Registros - '+Limite;
                
            }else{
            //APAGANDO ARQUIVOS
                m = limparArquivosComponente(documentos, dataFinal, dataInicial, Limite, simular);
                documentos = (List<Objeto>)  JSON.deserialize(JSON.serialize(m.get(DEF_DOCUMENTOS)), List<Objeto>.class);
                mapToReturn.put(DEF_DOCUMENTOS,documentos);
                TotalApagado = TotalApagado + (Integer) m.get(DEF_TOTAL_APAGADO);
                Limite = Limite - TotalApagado;
                mensagemToReturn += '<br/>'+(String) m.get(DEF_LOGS);
            }

            mensagemToReturn +='<br/>Total Apagado: ' +TotalApagado;
            



            mapToReturn.put(DEF_MENSAGEM,mensagemToReturn);
        } catch (Exception e) {
            mapToReturn.put(DEF_MENSAGEM,e.getLineNumber() +' - '+ e.getMessage());
            return mapToReturn;
        }
        return mapToReturn;
        
    }

    @AuraEnabled
    public static Map<String,Object> limparArquivosComponente(List<Objeto> objetosToDel, Datetime datafim, Datetime datainit, Integer limite,Boolean simular){
        Integer total = 0;
        String log = '';
        Map<String,Object> mapToReturn = new Map<String,Object>();
        mapToReturn.put(DEF_DOCUMENTOS, new List<Objeto>());
        for(Objeto obj : objetosToDel){
            if(obj.selected==false || total>limite){log += '<br/>Objeto: '+obj.api + ' - Buscar: '+obj.name+' - SKIP >>';continue;}
            log += '<br/>Objeto: '+obj.api + ' - Buscar: '+obj.name+' - SELECTED';
            List<sObject> toDel = [SELECT Id FROM ContentDocument WHERE title like :obj.name AND lastmodifieddate >= :datafim AND lastmodifieddate <= :datainit LIMIT :limite];
            if(toDel==null || !toDel.isEmpty()){
                System.debug('Objeto: '+ obj +' - Buscar: '+obj.name+' - Apagando Registros : '+ toDel.size());
                log += '<br/>Objeto: '+obj.api +' - Buscar: '+obj.name+ ' - RECORDS: '+toDel.size();
                total =total+ toDel.size();
                if(total<limite){
                    try {
                        if(!simular)Database.delete(toDel,false);
                        obj.deleted = toDel.size();
                        log += '<br/>Objeto: '+obj.api + ' - Buscar: '+obj.name+' - APAGADOS: '+toDel.size();
                        limite = limite - toDel.size();
                    } catch (Exception e) {
                        log += '<br/>Objeto: '+obj.api + ' - Buscar: '+obj.name+' - ERRO: '+e.getMessage() +' - '+e.getCause();
                        System.debug(e.getMessage());
                    }
                }
            }else{
                log += '<br/>Objeto: '+obj.api +' - Buscar: '+obj.name+ ' - RECORDS: 0';
            }
        }
        mapToReturn.put(DEF_DOCUMENTOS, objetosToDel);
        mapToReturn.put(DEF_TOTAL_APAGADO, total);
        mapToReturn.put(DEF_LOGS, log);
        return mapToReturn;
    }

    @AuraEnabled
    public static Map<String,Object> limparRegistrosComponente(List<Objeto> objetosToDel, Datetime datafim, Datetime datainit, Integer limite,Boolean simular){
        System.debug(LoggingLevel.Error,'limparRegistrosComponente INICIO');
        Integer total = 0;
        String log = '';
        Map<String,Object> mapToReturn = new Map<String,Object>();
        mapToReturn.put(DEF_REGISTROS, new List<Objeto>());
        for(Objeto obj : objetosToDel){
            //System.debug(LoggingLevel.Error,'limparRegistrosComponente obj'+obj);
            if(obj.selected==false || total>limite){log += '<br/>Objeto: '+obj.api + ' - SKIP >>';continue;}
            log += '<br/>Objeto: '+obj.api + ' - SELECTED';
            List<sObject> toDel = Database.query('SELECT Id FROM '+obj.api+' WHERE lastmodifieddate >= :datafim AND lastmodifieddate <= :datainit LIMIT '+limite);
            if(toDel==null || !toDel.isEmpty()){
                //System.debug(LoggingLevel.Error,'Objeto: '+ obj +' - Apagando Registros : '+ toDel.size());
                log += '<br/>Objeto: '+obj.api + ' - RECORDS: '+toDel.size();
                total =total+ toDel.size();
                if(total<limite){
                    try {
                        if(!simular)Database.delete(toDel,false);
                        obj.deleted = toDel.size();
                        log += '<br/>Objeto: '+obj.api + ' - APAGADOS: '+toDel.size();
                        limite = limite - toDel.size();
                    } catch (Exception e) {
                        log += '<br/>Objeto: '+obj.api + ' - ERRO: '+e.getMessage() +' - '+e.getCause();
                        System.debug(e.getMessage());
                    }
                }
            }else{
                log += '<br/>Objeto: '+obj.api +' - RECORDS: 0';
            }
        }
        mapToReturn.put(DEF_REGISTROS, objetosToDel);
        mapToReturn.put(DEF_TOTAL_APAGADO, total);
        mapToReturn.put(DEF_LOGS, log);
        return mapToReturn;
    }



    @AuraEnabled
	public static Map<String,Object> getPermissions(){
        Map<String,Object> mapToReturn = new Map<String,Object>();
		
        String perfilAtual = [SELECT Id, Name FROM Profile WHERE Id=:Userinfo.getProfileId()].Name;
		
        LUPermissoes__mdt permissoes = [SELECT Id
                                                , ProfileName__c
                                                , Use__c
                                                , Files__c
                                                , Objects__c
                                                , Period__c
                                                FROM LUPermissoes__mdt
                                                WHERE ProfileName__c=:perfilAtual
                                                LIMIT 1];		
        if(permissoes!=null){
            mapToReturn.put(DEF_canUSE,permissoes.Use__c);
            mapToReturn.put(DEF_canFILES,permissoes.Files__c);
            mapToReturn.put(DEF_canRECORDS,permissoes.Objects__c);
            mapToReturn.put(DEF_canPERIOD,permissoes.Period__c);
        }else{
            mapToReturn.put(DEF_canUSE,false);
        }
        return mapToReturn;
	}

    @AuraEnabled
    public static Map<String,String> objetos(){
        Map<String,String> mapOrdem = new Map<String,String>();
        mapOrdem.put('1','CriticaOrcamento__c');
        mapOrdem.put('2','ControleIntegracao__c');
        mapOrdem.put('3','Contract');
        mapOrdem.put('4','Quote');
        mapOrdem.put('5','Opportunity');
        mapOrdem.put('6','BeneficiarioSeguradoProposta__c');
        mapOrdem.put('7','BeneficiarioSeguradoContrato__c');
        mapOrdem.put('8','GarantiaSeguradoProposta__c');
        mapOrdem.put('9','GarantiaSeguradoContrato__c');
        mapOrdem.put('10','GarantiaSeguradoOrcamento__c');
        mapOrdem.put('11','SeguradoProposta__c');
        mapOrdem.put('12','SeguradoContrato__c');
        mapOrdem.put('13','SeguradoOrcamento__c');
        mapOrdem.put('14','ContratanteProposta__c');
        mapOrdem.put('15','ContratanteContrato__c');
        mapOrdem.put('16','ContratanteOrcamento__c');
        mapOrdem.put('17','FavorecidoRemuneracaoContrato__c');
        mapOrdem.put('18','GarantiaContratanteProposta__c');
        mapOrdem.put('19','GarantiaContratanteContrato__c');
        mapOrdem.put('20','GarantiaContratanteOrcamento__c');
        mapOrdem.put('21','GarantiaContrato__c');
        mapOrdem.put('22','GarantiaGrupoContrato__c');
        mapOrdem.put('23','GarantiaSeguradoContrato__c');
        mapOrdem.put('24','GrupoContrato__c');
        mapOrdem.put('25','GrupoProposta__c');
        mapOrdem.put('26','GrupoOrcamento__c');
        mapOrdem.put('27','RemuneracaoContrato__c');
        mapOrdem.put('28','GarantiaGrupoOrcamento__c');
        mapOrdem.put('29','GarantiaGrupoContrato__c');
        mapOrdem.put('30','GarantiasGrupoProposta__c');
        mapOrdem.put('31','CriticaProposta__c');
        //Necessário remover manualmente via Inspector Inicio
        //EmailMessage     
        //DeclaracaoSaude__c   
        //RespostaDeclaracaoSaude__c
        //MovimentoSinistro__c
        //BCP_Log__c 
        //Endereco__c   
        //Case  
        //Necessário remover manualmente via Inspector Fim
        return mapOrdem;
        //FAZER UM METADADO PARA PEGAR TODOS ESSES REGISTROS
    }
    @AuraEnabled
    public static Map<String,String> arquivos(){
        Map<String,String> mapOrdem = new Map<String,String>();
        mapOrdem.put('1','%Servico%');
        mapOrdem.put('2','%Endosso%');
        mapOrdem.put('4','%voucher%');
        mapOrdem.put('5','%storage%');
        mapOrdem.put('6','%Apolice%');
        mapOrdem.put('7','%Proposta%');
        mapOrdem.put('8','%CO2%');
        mapOrdem.put('9','%BAK%');
        mapOrdem.put('10','%CO2%');
        return mapOrdem;
        //FAZER UM METADADO PARA PEGAR TODOS ESSES REGISTROS
    }

    @AuraEnabled
    public static Map<String,Object> Inicializar(){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        
        //RETORNOS OBRIGATÓRIOS PARA UTILIZAÇÃO DO FRONT
        Map<String,Object> permissoes = getPermissions();
        mapToReturn.put(DEF_PERMISSOES,permissoes);
        Organization org = [SELECT Id, Name, Division, Street, City, State, PostalCode, Country, Latitude, Longitude, GeocodeAccuracy, Address, Phone, Fax, PrimaryContact, DefaultLocaleSidKey, TimeZoneSidKey, LanguageLocaleKey, ReceivesInfoEmails, ReceivesAdminInfoEmails, PreferencesRequireOpportunityProducts, PreferencesTransactionSecurityPolicy/*, PreferencesTerminateOldestSession*/, PreferencesConsentManagementEnabled, PreferencesAutoSelectIndividualOnMerge, PreferencesLightningLoginEnabled, PreferencesOnlyLLPermUserAllowed, FiscalYearStartMonth, UsesStartDateAsFiscalYearName, DefaultAccountAccess, DefaultContactAccess, DefaultOpportunityAccess, DefaultLeadAccess, DefaultCaseAccess, DefaultCalendarAccess, DefaultPricebookAccess, DefaultCampaignAccess, SystemModstamp, ComplianceBccEmail, UiSkin, SignupCountryIsoCode, TrialExpirationDate, NumKnowledgeService, OrganizationType, NamespacePrefix, InstanceName, IsSandbox, WebToCaseDefaultOrigin, MonthlyPageViewsUsed, MonthlyPageViewsEntitlement, IsReadOnly, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById FROM Organization];
        mapToReturn.put(DEF_ORG,org);


        if((Boolean)permissoes.get(DEF_canUSE)==false){
            return mapToReturn;
        }

        //VARIAVEIS A SEREM RETORNADAS CASO POSSA UTILIZAR O COMPONENTE
        Map<String,String> mapOrdem = objetos();
        List<Objeto> listObjeto = new List<Objeto>();
        mapToReturn.put(DEF_REGISTROS,listObjeto);
        mapToReturn.put(DEF_DOCUMENTOS,listObjeto);
        mapToReturn.put(DEF_DATA_INICIAL_LIMITE,System.today());
        mapToReturn.put(DEF_DATA_INICIAL,System.today().addDays(-1));
        mapToReturn.put(DEF_DATA_FINAL,System.today().addDays(-1).addYears(-1));
        mapToReturn.put(DEF_SIMULAR,true);
        
        //BUSCA A OBJETOS DISPONIVEIS
        
        
        Map<String, Objeto> quantidades = new Map<String, Objeto>();
        if(!Test.isRunningTest())  quantidades = buscarQuantidade(mapOrdem.values());

        if(quantidades.isEmpty()){
            for(String objName : mapOrdem.values()){
                listObjeto.add(new Objeto().dtoObjeto(null,objName,null));
            }
            mapToReturn.put(DEF_REGISTROS,listObjeto);
        }else{
            mapToReturn.put(DEF_REGISTROS,quantidades.values());
        }

        mapOrdem = arquivos();
        listObjeto = new List<Objeto>();
        for(String objName : mapOrdem.values()){
            Objeto objs = new objeto();
            objs.name = objName;
            listObjeto.add(new Objeto().dtoObjeto(objs,'ContentDocument',null));
        }
        mapToReturn.put(DEF_DOCUMENTOS,listObjeto);

        return mapToReturn;
    }
    

    @AuraEnabled
    public static Map<String, Objeto> buscarQuantidade(List<String> objetos){
        CIVServices CIV = CIVServices.getInstance();
        Map<String, Objeto> mapToReturn = new Map<String, Objeto>();
        System.debug('buscarQuantidade |INICIO :  '+String.join(objetos, ','));
        String nomeEndPoint = 'Consultar_Registros';
        HttpResponse resp;
        resp = Util.executarHttpRequest(CIV.gerarEndpoint(nomeEndpoint)+'?sObjects='+String.join(objetos, ','), 'GET', CIV.gerarHeaderOAuth2(CIV.gerarTokenOAuth2('CIV')), null, 120000);

        String jsonReturn = '';
        if(resp.getStatusCode() == 200){
            System.debug('buscarQuantidade | 200');
            jsonReturn = resp.getBody();
            Map<String, Object> m =  (Map<String, Object>) JSON.deserializeUntyped(jsonReturn);
            
            for(Objeto obj : (List<Objeto>) JSON.deserialize(JSON.serialize(m.get('sObjects')), List<Objeto>.class)){
                mapToReturn.put(obj.name, new Objeto().dtoObjeto(obj,obj.name,null));
            }
        }else{
            System.debug('buscarQuantidade | ERRO: '+resp.getStatusCode());
        }


        return mapToReturn;
    }

    public class Objeto{
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String api {get;set;}
        @AuraEnabled public Integer count {get;set;}
        @AuraEnabled public Integer deleted {get;set;}
        @AuraEnabled public Boolean selected {get;set;}
        @AuraEnabled public Boolean success {get;set;}

        public void objeto (){}
        public Objeto dtoObjeto(Objeto obj, String objName, Integer apagado){
            Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(objName).getDescribe();
            this.name = obj!=null && obj.name!=null ? obj.name : result.getLabel();
            this.api = objName;
            this.selected = false;
            this.success = false;
            this.count = obj!=null && obj.count!=null ? obj.count : null;
            this.deleted = obj!=null && obj.deleted!=null? obj.deleted : apagado!=null ? apagado : null;
            return this;
        }
    }
        

}