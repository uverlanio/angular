/**************************************************************************************************************************************************************************
 * 
 *  Classe utilitária de uso geral
 *
 **************************************************************************************************************************************************************************/
public class Util {

    /**
     * Realiza uma requisição HTTP Request
     *
     * @param   endPoint  - url da requisição
     * @param   method  - método HTTP
     * @param   headers  - cabeçalhos da chamada 
     * @param   body  - corpo da requisição
     * @param   timeout  - tempo de timeout
     * @return  HttpResponse - Objeto HTTP Response
     */    
    public static HttpResponse executarHttpRequest(String endPoint, String method, Map<String, String> headers, String body, Integer timeout){
        HttpRequest request = new HttpRequest();
        Http h = new Http();

		//System.debug('executarHttpRequest.endPoint = ' + endPoint);
        request.setEndpoint(endPoint);
        request.setMethod(method);
        request.setTimeout(timeout);

        //Gera body = '' apenas para o método POST
        if(method == 'POST' || method == 'PUT')
            request.setBody(body != null ? body : '');
        else if(body != null) 
            request.setBody(body);
        
        //System.debug('>>>> Request ' + request);
        //System.debug('>>>> Request Body ' + body);
        //INICIO - LECVPV-218
        for(String nomeHeader : headers.keySet()){
            if(endPoint.contains('/v1/pep/busca-pessoa-exposta') && nomeHeader == 'Content-Type'){
                request.setHeader(nomeHeader, 'text/xml');
            }else{
                request.setHeader(nomeHeader, headers.get(nomeHeader));
            }
            
        }
        //FIM - LECVPV-218
        //system.debug('headers '+headers);
        //system.debug('execução request '+ request);

        System.debug('XXX - request'+ request);
    
            return h.send(request);
       
        
    }

    /**
     * Realiza uma requisição HTTP Request
     *
     * @param   endPoint  - url da requisição
     * @param   method  - método HTTP
     * @param   headers  - cabeçalhos da chamada 
     * @param   body  - corpo da requisição
     * @param   timeout  - tempo de timeout
     * @param   nomeServico  - nome do serviço para autenticar
     * @return  HttpResponse - Objeto HTTP Response
     */
    public static HttpResponse executarHttpRequest(String endPoint, String method, Map<String, String> headers, String body, Integer timeout, String nomeServico){
        headers = gerarHeaderAutenticacao(nomeServico, headers);
        return executarHttpRequest(endPoint, method, headers, body, timeout);
    }

    public static Map<String, String> gerarHeaderAutenticacao2(String nomeServico, Map<String, String> headers) {
        if(Test.isRunningTest()){
            headers.put('Authorization', 'Bearer xpto');
            return headers;
        }

        try {
            Servico__mdt servico = MetadataDAO.getInstance().buscarServico(nomeServico);

            if (servico.NomeToken__c == null) return headers;

            Servico__mdt servicoToken = MetadataDAO.getInstance().buscarServico(servico.NomeToken__c);

            system.debug('servicoToken: '+ servicoToken);

            String path =  String.isNotBlank(servicoToken.Endpoint__c) ? servicoToken.Endpoint__c : '';

            system.debug('path: '+ path);

            String endpoint = Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint' : servicoToken.NomeCredencial__c + path;

            system.debug('endpoint: '+ endpoint);
        }
        catch(Exception e) {
            System.debug('################################################## ERRO TOKEN');
            System.debug('::: ERRO: ' + e.getLineNumber() + ': ' + e.getMessage());
        }

        // devolve o header com a autorização
        return headers;
    }	


    


    /**
     * Gera string a ser usada em uma query de acordo com os parametros passados
     *
     * @param   nomeSobject  - nome do objeto salesforce
     * @param   campos  - lista contendo os campos a serem retornados no select
     * @param   criterios  - filtros a serem utilizados na query
     * @return  String - query
     */
    public static String gerarQuery(String nomeSobject, List<String> campos, List<String> criterios){  
        String strWhere = !criterios.isEmpty() ? 'Where' : '';
        return String.format('Select {0} From {1} {2} {3}', new List<String>{String.join(campos, ', '), nomeSobject, strWhere, String.join(criterios, ' AND ')}); 
    }


    public static String gerarQuery(String nomeSobject, List<String> campos, String criterios){  
        String strWhere = String.isNotEmpty(criterios) ? 'Where' : '';
        return String.format('Select {0} From {1} {2} {3}', new List<String>{String.join(campos, ', '), nomeSobject, strWhere, ' ' + criterios}); 
    }

    /**
     * Função utilitária para exibir os limites
     *
     * @param  descricao    Descrição identificação no log
     * @see                 Limits
     * @since               Sprint 12
     */
    public static void printLimits(String descricao) {
        System.debug('');
        System.debug('////////////////////////////////////////////////');
        System.debug('/// LIMITS: ' + descricao);
        System.debug('////////////////////////////////////////////////');
        System.debug('///  CPU Time (milliseconds): ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime());
        System.debug('///        Heap Size (bytes): ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        System.debug('///                 DML Rows: ' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows());
        System.debug('///           DML Statements: ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements());
        System.debug('///                  Queries: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        System.debug('///               Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
        System.debug('///        Query LocatorRows: ' + Limits.getQueryLocatorRows() + '/' + Limits.getLimitQueryLocatorRows());
        System.debug('///             SOSL Queries: ' + Limits.getSoslQueries() + '/' + Limits.getLimitSoslQueries());
        System.debug('///        Aggregate Queries: ' + Limits.getAggregateQueries() + '/' + Limits.getLimitAggregateQueries());
        System.debug('///             Future Calls: ' + Limits.getFutureCalls() + '/' + Limits.getLimitFutureCalls());
        System.debug('///           Queueable Jobs: ' + Limits.getQueueableJobs() + '/' + Limits.getLimitQueueableJobs());
        System.debug('///   Mobile Push Apex Calls: ' + Limits.getMobilePushApexCalls() + '/' + Limits.getLimitMobilePushApexCalls());
        System.debug('///        Email Invocations: ' + Limits.getEmailInvocations() + '/' + Limits.getLimitEmailInvocations());
        System.debug('////////////////////////////////////////////////');
        System.debug('');
    }

    /**
     * Gerar Header Autenticação
     *
     * @param   nomeServico  - Nome do serviço no qual se quer o token
     * @return  String - 
     */
    public static Map<String, String> gerarHeaderAutenticacao(String nomeServico, Map<String, String> headers) {
        if(Test.isRunningTest()){
            headers.put('Authorization', 'Bearer xpto');
            return headers;
        }

        try {
            // metadado do serviço solicitado
            Servico__mdt servico = MetadataDAO.getInstance().buscarServico(nomeServico);

            // não tem token definido, devolve o header enviado
            if (servico.NomeToken__c == null) return headers;

            // metadado do token 
            Servico__mdt servicoToken = MetadataDAO.getInstance().buscarServico(servico.NomeToken__c);

            // path do token
            String path =  String.isNotBlank(servicoToken.Endpoint__c) ? servicoToken.Endpoint__c : '';

            // callout:{{CREDENCIAL_NOMEADA}}/{{ENDPOINT}}
            String endpoint = Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint' : 'callout:' + servicoToken.NomeCredencial__c + path;

            // recupera o token
			System.debug('endpoint = ' + endpoint);
            HttpResponse payload = executarHttpRequest(endpoint, 'GET', new Map<String, String>{'Accept' => 'application/json'}, null, 60000);
			//HttpResponse payload = executarHttpRequest(path, 'GET', new Map<String, String>{'Accept' => 'application/json'}, null, 60000);
    
            // json > untyped map object
            Map<String, Object> objToken = (Map<String, Object>) JSON.deserializeUntyped(payload.getBody());

            // Bearer
            String tipoToken = (String) objToken.get('tipo');

            // 00000000-0000-0000-0000-000000000000
            String valorToken = (String) objToken.get('valor');

            // Bearer 00000000-0000-0000-0000-000000000000
            String autorizacao = tipoToken + ' ' + valorToken;
            
			//PLV 4518
			System.debug('gerarHeaderAutenticacao.autorizacao = ' + autorizacao);

            // adiciona o header
            headers.put('Authorization', autorizacao);
        }
        catch(Exception e) {
            System.debug('################################################## ERRO TOKEN');
            System.debug('::: ERRO: ' + e.getLineNumber() + ': ' + e.getMessage());
        }

        // devolve o header com a autorização
        return headers;
    }	

    //Gera uma string aleatória
    public static String gerarStringRandomica(Integer tamanho){
        String randStr = '';
        String caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz#$%&*=-.';
        
        while (randStr.length() < tamanho) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), caracteres.length());
           randStr += caracteres.substring(idx, idx+1);
        }

        return randStr;
    }
    //Gera uma string aleatória
    public static String gerarStringRandomicaAlpha(Integer tamanho){
        String randStr = '';
        String caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        
        while (randStr.length() < tamanho) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), caracteres.length());
           randStr += caracteres.substring(idx, idx+1);
        }

        return randStr;
    }

    public static boolean isCPF(String CPF) {

        CPF = CPF.replace('.', '');
        CPF = CPF.replace('.', '');
        CPF = CPF.replace('.', '');
        CPF = CPF.replace('-', '');
        //INICIO -Remove caracteres especiais - Correcao INCIDENTE 4915183
        CPF = CPF.replace('*', '');
        CPF = CPF.replace('@', '');
        CPF = CPF.replace('#', '');
        //FIM -Remove caracteres especiais - Correcao INCIDENTE 4915183 

        if (CPF.equals('00000000000') || CPF.equals('11111111111') ||
            CPF.equals('22222222222') || CPF.equals('33333333333') ||
            CPF.equals('44444444444') || CPF.equals('55555555555') ||
            CPF.equals('66666666666') || CPF.equals('77777777777') ||
            CPF.equals('88888888888') || CPF.equals('99999999999') ||
            (CPF.length() != 11))
        return(false);

        Integer dig10, dig11, sm, i, r, num, peso;


        sm = 0;
        peso = 10;
        List<String> cpfString = cpf.split('');
        for (i=0; i<9; i++) {
            num = Integer.valueOf(cpfString[i]); 
            sm = sm + (num * peso);
            peso = peso - 1;
        }

        r = 11 - (math.mod(sm,11));
        if ((r == 10) || (r == 11))
        dig10 = 0;
        else dig10 = r;

// Calculo do 2o. Digito Verificador
sm = 0;
peso = 11;
for(i=0; i<10; i++) {
    num = Integer.valueOf(cpfString[i]);
    sm = sm + (num * peso);
    peso = peso - 1;
}

r = 11 - (math.mod(sm,11));
if ((r == 10) || (r == 11))
dig11 = 0;
else dig11 = r;

// Verifica se os digitos calculados conferem com os digitos informados.
if (dig10 == Integer.valueOf(cpfString[9]) && dig11 == Integer.ValueOf(cpfString[10]))
return true;
else return false;
}

public static String imprimeCPF(String CPF) {
    return(CPF.substring(0, 3) + '.' + CPF.substring(3, 6) + '.' +
      CPF.substring(6, 9) + '-' + CPF.substring(9, 11));
}

public static boolean isCNPJ(String CNPJ) {

CNPJ = CNPJ.replace('.', '');
CNPJ = CNPJ.replace('.', '');
CNPJ = CNPJ.replace('.', '');
CNPJ = CNPJ.replace('/', '');
CNPJ = CNPJ.replace('-', '');
//INICIO -Remove caracteres especiais - Correcao INCIDENTE 4915183 
CNPJ = CNPJ.replace('*', '');
CNPJ = CNPJ.replace('@', '');
CNPJ = CNPJ.replace('&', '');    
//FIM -Remove caracteres especiais - Correcao INCIDENTE 4915183 
    
// considera-se erro CNPJ's formados por uma sequencia de numeros iguais
if (CNPJ.equals('00000000000000') || CNPJ.equals('11111111111111') ||
    CNPJ.equals('22222222222222') || CNPJ.equals('33333333333333') ||
    CNPJ.equals('44444444444444') || CNPJ.equals('55555555555555') ||
    CNPJ.equals('66666666666666') || CNPJ.equals('77777777777777') ||
    CNPJ.equals('88888888888888') || CNPJ.equals('99999999999999') ||
    (CNPJ.length() != 14))
return false;

Integer sm, i, r, num, peso, dig13, dig14;
List<String> cnpjString = CNPJ.split('');
sm = 0;
peso = 2;
for (i=11; i>=0; i--) {
    num = Integer.valueOf(cnpjString[i]);
    sm = sm + (num * peso);
    peso = peso + 1;
    if (peso == 10)
    peso = 2;
}

r = math.mod(sm, 11);
if ((r == 0) || (r == 1))
dig13 = 0;
else dig13 = Integer.valueOf(11-r);

// Calculo do 2o. Digito Verificador
sm = 0;
peso = 2;
for (i=12; i>=0; i--) {
    num = Integer.valueOf(cnpjString[i]);
    sm = sm + (num * peso);
    peso = peso + 1;
    if (peso == 10)
    peso = 2;
}

r = math.mod(sm, 11);
if ((r == 0) || (r == 1))
dig14 = 0;
else dig14 = Integer.valueOf(11-r);

// Verifica se os dígitos calculados conferem com os dígitos informados.
if (dig13 == Integer.valueOf(cnpjString[12]) && dig14 == Integer.valueOf(cnpjString[13]))

return true;
else return false ;
}

public static String imprimeCNPJ(String CNPJ) {
    return(CNPJ.substring(0, 2) + '.' + CNPJ.substring(2, 5) + '.' +
      CNPJ.substring(5, 8) + '.' + CNPJ.substring(8, 12) + '-' +
      CNPJ.substring(12, 14));
}
// PLV-5098 INICIO
public static String imprimeCNPJ(String CNPJ, String separadorDigito) {
    return(CNPJ.substring(0, 2) + '.' + CNPJ.substring(2, 5) + '.' +
      CNPJ.substring(5, 8) + separadorDigito + CNPJ.substring(8, 12) + '-' +
      CNPJ.substring(12, 14));
}
// PLV-5230-INICIO-FIX 04 
public static Long imprimeCNPJINT(String CNPJ) {
    Long cnpjRemove = Long.valueOf(CNPJ.remove('.').remove('-').remove('/'));
    return cnpjRemove;
}
// PLV-5230-FIM-FIX 04

// PLV-5098 FIM
//PLV-2666 - Inicio - Criado a mascara para telefone
public static String getMascaraTelefone(String pNumero, String pDDD) {

    String numeroCompleto = '('+pDDD+') ';
    numeroCompleto += pNumero.left(pNumero.length() - 4) +'-'+pNumero.right(4);

    return numeroCompleto;
}
//PLV-2666 - Fim

    //PLV-3285 - Inicio
    public static List<SObject> getLockListSObject(List<SObject> plSObject, String keyField) {

        List<SObject> lSObjectRet = new List<SObject>();
    
        Set<String> sFieldValue = new Set<String>();
    
        for (SObject record : plSObject) {
            String fieldValue = (String) record.get(keyField); 
            if (fieldValue != null)
                sFieldValue.add(fieldValue);
        }
    
        Map<String, SObject> mSObjectDB = new Map<String, SObject>();
    
        String soql = 'SELECT Id, {0} FROM {1} WHERE {0} IN :sFieldValue FOR UPDATE';
        String soqlFormatted = String.format(soql, new List<Object>{keyField, plSObject.get(0).getSObjectType()});
    
        for (SObject recordDB : Database.query(soqlFormatted)) {
            mSObjectDB.put(keyField, recordDB);
        }
    
        for (SObject record : plSObject) {
    
            if (mSObjectDB.containsKey((String) record.get(keyField))) {
                SObject recordDB = mSObjectDB.get(keyField);
                Map<String,Object> mRecordField = record.getPopulatedFieldsAsMap();
                for (String field : mRecordField.keySet()) {
                    recordDB.put(field, mRecordField.get(field));    
                }
                lSObjectRet.add(recordDB);
            } else {
                lSObjectRet.add(record);
            }
        }
        
        return lSObjectRet;
    }
    //PLV-3285 - Fim

    
    //PLV-3744 - INICIO
    public static String encryptDocPublicURL(String docId, String docTitle){
        
        String tokenToReturn ='';
        
        if(String.isNotBlank(docId) && String.isNotBlank(docTitle)){
            CryptoToken c = new CryptoToken();
            tokenToReturn = c.encrypt(docId+'|'+docTitle);
        }
        
        return tokenToReturn;
    }
    //PLV-3744 - FIM

    //PLV-3755 - INICIO
    public static Map<String,Object> enviarEmail(String pBodyToSend, List<String> pRecipients, String pSubject ){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setHtmlBody(pBodyToSend);
        email.setToAddresses(pRecipients);
        email.setSubject(pSubject);
        email.setCharset('UTF-8');


        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email},true);
        } catch (Exception e) {
            System.debug('e.getMessage(): ' + e.getMessage());
            System.debug('e.getStackTraceString(): ' + e.getStackTraceString());
            throw new AuraHandledException('e.getMessage(): ' + e.getMessage());

        }
        mapToReturn.put('Sucesso',true);
        return mapToReturn;
    }


    //PLV-3755 - FIM
    
    //PLV-4438 - Inicio
    //ANNVI-201 - INICIO
    public static Date calculaDataFinalPorDiasUteis(BusinessHours horarioComercial, Date dataInicio, Integer quantidadeDiasUteis){
        Datetime dataHoraInicio = DateTime.newInstance(dataInicio, horarioComercial.MondayEndTime);
        Long diaUtilMS = 0;
        Integer daysToAdd = quantidadeDiasUteis >= 0 ? 1 : -1;
    
        while(quantidadeDiasUteis != 0){
            diaUtilMS = Util.getDiaUtilEmMilisegundos(horarioComercial, daysToAdd, dataInicio);
            daysToAdd = quantidadeDiasUteis >= 0 ? daysToAdd + 1 : daysToAdd - 1;
            quantidadeDiasUteis -= Integer.valueOf(Math.signum(quantidadeDiasUteis));
        }
    
        Long diasUteisEmMilisegundos = Math.abs(quantidadeDiasUteis) * diaUtilMS;
        Datetime dataHoraFinal = BusinessHours.add(horarioComercial.Id, dataHoraInicio, diasUteisEmMilisegundos);
        Date dataFinal = dataHoraFinal.date();
    
        if(quantidadeDiasUteis < 0) {
            dataFinal = dataFinal.addDays(-1);
        }
    
        return dataFinal;
    }
    //ANNVI-201 - FIM

	public static Long getDiaUtilEmMilisegundos(BusinessHours horarioComercial, Integer daysToAdd, Date dataParam){

		Long diaUtilEmMilisegundos;
		Datetime dataHoraInicio = DateTime.newInstance(dataParam.addDays(daysToAdd), horarioComercial.MondayStartTime);
		Datetime dataHoraFim = DateTime.newInstance(dataParam.addDays(daysToAdd), horarioComercial.MondayEndTime);

		diaUtilEmMilisegundos = BusinessHours.diff(horarioComercial.Id, dataHoraInicio, dataHoraFim);
		
		return diaUtilEmMilisegundos;
	}
    //PLV-4438 - Fim
    //
    public static list<String> retornaValorPicklist(String objeto, String campo){
        Schema.DescribeSObjectResult objSchema = Account.sObjectType.getDescribe();
        List<Schema.PicklistEntry> PicklistValues  = Schema.getGlobalDescribe().get(objeto).getDescribe().fields.getMap().get(campo).getDescribe().getPicklistValues();               
        List<String> pickList = new List<String>();
        
        for(Schema.Picklistentry pl : PicklistValues)
        {
            pickList.add(pl.getValue());
        }
        
        return pickList;
    }
    
    public static ContentWorkspace retornarBibliotecaPadrao(){
        return [SELECT Id, Name, Description, TagModel, CreatedById, CreatedDate, LastModifiedById, SystemModstamp, LastModifiedDate, DefaultRecordTypeId, IsRestrictContentTypes, IsRestrictLinkedContentTypes, WorkspaceType, ShouldAddCreatorMembership, LastWorkspaceActivityDate, RootContentFolderId, NamespacePrefix, DeveloperName FROM ContentWorkspace WHERE NAME = 'Asset Library'];
    }
    public static ContentWorkspace retornarPastaPadrao(){
        return [SELECT Id, Name  FROM ContentWorkspace WHERE NAME = 'arquivos publicos'];
    }

    //PLV-4944 - INICIO - PEDRO AUGUSTO BRAZ
    /* Actions on CIV
    // OBRIGATÓRIO QUE O SOBJECT VENHA COM O ID DO REGISTRO QUANDO FOR PARA ATUALIZAR
    // DURANTE O UPSERT É OBRIGATÓRIO QUE SEJA UMA LISTA APENAS DO MESMO SOBJECT
    */
    @future(Callout=true)
    public static void sObjectActionCIVasync(String pAcion, String pListToSend, Boolean pAppOrNone,Boolean pStripNull,String pExternal,Boolean nullName){
        System.debug('sObjectActionCIVasync ::: pAcion'+pAcion);
        System.debug('sObjectActionCIVasync ::: pListToSend'+pListToSend);
        System.debug('sObjectActionCIVasync ::: pAppOrNone'+pAppOrNone);
        System.debug('sObjectActionCIVasync ::: pStripNull'+pStripNull);
        System.debug('sObjectActionCIVasync ::: pExternal'+pExternal);
        List<SObject> lista = null;
        try {
            lista = (List<SObject>) JSON.deserialize(pListToSend,  List<SObject>.class);
        } catch (Exception e) {
            lista = new List<SObject>{(SObject) JSON.deserialize(pListToSend,  SObject.class)};
        }
        
        Map<String,Object> teste = sObjectActionCIV(pAcion,lista, pAppOrNone, pStripNull,pExternal,nullName); 
        System.debug('RETORNO teste'+JSON.serialize(teste));
        /*if(true)
                throw new GenericException('EXCEPTIOOOOO DO PEDRAO');*/
    }
    //CASO SEJA SOBJECT coloca numa lista e repassa
    public static Map<String,Object> sObjectActionCIV(String pAcion, SObject pListToSend, Boolean pAppOrNone,Boolean pStripNull,String pExternal,Boolean nullName){
        List<SObject> lista = new List<SObject>{pListToSend};
        return sObjectActionCIV(pAcion,lista, pAppOrNone, pStripNull,pExternal,nullName);
    }
    public static Map<String,Object> sObjectActionCIV(String pAcion, List<SObject> pListToSend, Boolean pAppOrNone,Boolean pStripNull,String pExternal,Boolean nullName){
        pAppOrNone = pAppOrNone==null? false : pAppOrNone;
        pStripNull = pStripNull==null? false : pStripNull;
        System.debug('sObjectActionCIV ::: pAcion'+pAcion);
        System.debug('sObjectActionCIV ::: pListToSend'+pListToSend);
        System.debug('sObjectActionCIV ::: pAppOrNone'+pAppOrNone);
        System.debug('sObjectActionCIV ::: pStripNull'+pStripNull);
        System.debug('sObjectActionCIV ::: pExternal'+pExternal);
        System.debug('sObjectActionCIV ::: 1'+(pListToSend==null || pListToSend.isEmpty() || String.isBlank(pAcion)));
        System.debug('sObjectActionCIV ::: 2'+(pAcion=='upsert' && String.isBlank(pExternal)));
        if(pListToSend==null || pListToSend.isEmpty() || String.isBlank(pAcion)) return null;
        if(pAcion=='upsert' && String.isBlank(pExternal)) return null;
        if(nullName){
            List<SObject> temppListToSend = new List<SObject>();
            for(SObject it :  pListToSend){
                SObject newitem = Schema.getGlobalDescribe().get(''+it.getSObjectType()).newSObject();
                Map<String, Object> fieldsToValue = it.getPopulatedFieldsAsMap();
                for(String key : fieldsToValue.keySet()){
                    if(!'name'.equalsIgnoreCase(key)) newitem.put(key,fieldsToValue.get(key));
                }
                
                temppListToSend.add(newitem);
            }
            pListToSend = temppListToSend;
        }
        Map<String,Object> mapToReturn = new Map<String,Object>();
        Map<String,Object> mapToSend = new Map<String,Object>();
        Map<String,Object> payload = new Map<String,Object>();

        payload.put('records',pListToSend);
        payload.put('allOrNone',pAppOrNone);
        String api ='/services/data/v50.0/composite/sobjects';
        
        if('update'.equalsIgnoreCase(pAcion) || 'upsert'.equalsIgnoreCase(pAcion)) mapToSend.put('metodo','PATCH');
        if('insert'.equalsIgnoreCase(pAcion)) mapToSend.put('metodo','POST');
        if('upsert'.equalsIgnoreCase(pAcion)) api='/services/data/v50.0/composite/sobjects/'+pListToSend[0].getSObjectType()+'/'+pExternal;
        
        mapToSend.put('payload',payload);
        mapToSend.put('stripnull',pStripNull);
        mapToSend.put('api',api);
                
        mapToReturn = compositeResponseToMap(pListToSend,SensediaServices.getInstance().proxyAutomacao(JSON.serialize(mapToSend)),pAppOrNone);//MGRC-1250 - INICIO/FIM
        System.debug('RETORNO DA API'+JSON.serialize(mapToReturn));
        return mapToReturn;
    }


    public static Map<String,Object> compositeResponseToMap(List<SObject> pListToSend,String responseBody,Boolean pAppOrNone){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        System.debug('response.body >>' + responseBody);
        retornoComposite responseMap = (retornoComposite) JSON.deserialize(responseBody,retornoComposite.class);
        if(responseMap.responsebody!=null){
            Integer sucesso = 0;
            Integer erro = 0;
            List<String> mensagem = new List<String>();
            for (itemComposite item : responseMap.responsebody) {
                if(item.success==true){sucesso=sucesso+1;}
                else if(item.success==false || String.isNotBlank(item.errorCode)){
                    erro=erro+1;
                    mensagem.add('['+item.errorCode+'] - '+item.message);                }
            }
                
            String sucessogeral = (pAppOrNone && erro>0 || !pAppOrNone && sucesso==0) ? 'NAO'
                                : !pAppOrNone && sucesso>0 && erro>0 ? 'PARCIAL'
                                : 'SIM';
            mapToReturn.put('mensagem',String.join(mensagem, ','));
            mapToReturn.put('countsucesso',sucesso);
            mapToReturn.put('counterro',erro);
            mapToReturn.put('sucesso',sucessogeral);
            mapToReturn.put('itens',responseMap.responsebody);
        }else {
            throw new GenericException ('Sem resposta do serviço!');
        }
        return mapToReturn;
    }

    //PLV-5066 INICIO
    public static String getNumCPF(String cpf){
        cpf = cpf.replace('.','').replace('-','');

        return cpf.substring(0, 9);
    }

    public static String getDigitoCPF(String cpf){
        cpf = cpf.replace('.','').replace('-','');

        return cpf.substring(9, 11);
    }

    public static String getPhoneDDD(String phone){
        phone = sanitizePhoneNumber(phone);

        return phone.substring(0, 2);
    }

    public static String getPhoneNumber(String phone){
        phone = sanitizePhoneNumber(phone);

        return phone.substring(2, phone.length());
    }

    public static String sanitizePhoneNumber(String phone){
        if(phone.indexOf('(') > 0){//ANNVI-201 - INICIO
            phone = phone.substring(phone.indexOf('('), phone.length());
        }//ANNVI-201 - FIM
        return phone.replace('.','').replace('-','').replace('(','').replace(')','').replace('+','').replace(' ','');
    }

    public static String getNumCep(String cep){
        cep = cep.replace('.','').replace('-','');

        return cep.substring(0, 5);
    }

    public static String getDigitoCep(String cep){
        cep = cep.replace('.','').replace('-','');

        return cep.substring(5, cep.length());
    }

    //PLV-5066 FIM

    //PLV-5241 - INICIO
    public static String limparNome(String nome) {
        return nome.trim().replaceAll('\t', ' ').replaceAll('\n', ' ');
    }
    public static String getPrimeironome(String nome) {
        nome = limparNome(nome);
        if (getSobrenome(nome) == '') {
            return ''; // caso não haja um segundo nome, retorna vazio no primeiro nome
        } 
        else {
            return nome.substringBefore(' ').trim();
        }
    }
    public static String getSobrenome(String nome) {
        nome = limparNome(nome);
        String sobreNome  = nome.substringAfter(' ').trim();
        if (sobreNome == '') {
            return nome.substringBefore(' ').trim(); //caso não exista um 2o nome, retorna o 1o nome como Sobrenome
        }
        else {
            return sobreNome;
        }
    }
    //PLV-5241 - FIM


    public class retornoComposite{
        public Integer code;
        public String body;
        public Map<String,String> headers;
        public List<itemComposite> responsebody;
    }
    public class itemComposite{
        public String id;
        public Boolean success;
        public List<Errors> errors;
        public String errorCode;
        public String message;
    }
    public class Errors {
		public String statusCode;
		public String message;
		public List<String> fields;
	}
    /*public static string getType(Object o) {
        if(o==null) return '';              // NULL É NULL NÉ JOVEM, NÃO SE HUMILHE!
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // Não conseguimos distinguir decimal ou double, na dívida vaí o primeiro
        if(o instanceof Double)             return 'Double';   // Não conseguimos distinguir decimal ou double, na dívida vaí o primeiro
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }*/
    public class GenericException extends Exception {}
    //PLV-4944 - FIM - PEDRO AUGUSTO BRAZ

    //PLV-5314 INICIO
    public static Decimal truncateNumber(Decimal notTruncatedNumber){
        if(String.valueOf(notTruncatedNumber).contains('.')){
            String sNumber = String.valueOf(notTruncatedNumber);
            String sLength = sNumber.subStringAfter('.');
            Integer dNumber = sLength.length();

            if(dNumber > 2){
                String myTruncatedNumber = sNumber.subString(0, sNumber.indexOf('.') + 3);
                Decimal truncatedNumber = Decimal.valueOf(myTruncatedNumber);
                return truncatedNumber;
            }else{
                return notTruncatedNumber;
            }
        }else{
            return notTruncatedNumber;
        }
    }
    //PLV-5314 FIM

    // POR062-1 - INICIO
    public static Set<Id> recuperarIdsPorCampoDeSObject(List<SObject> sobjectLista, Schema.SObjectField campo)
    {
        Set<Id> ids = new Set<Id>();
        if(
            campo != null && sobjectLista != null &&
            (
                campo.getDescribe().getType() == Schema.DisplayType.ID ||
                campo.getDescribe().getType() == Schema.DisplayType.REFERENCE
            )
        ) {
            for(SObject registro : sobjectLista)
            {
                Id valor = String.valueOf(registro.get(campo));
                if(String.isNotBlank(valor))
                {
                    ids.add(valor);
                }
            }
        }
        return ids;
    }

    public static Set<String> recuperarStringsPorCampoDeSObject(List<SObject> sobjectLista, Schema.SObjectField campo)
    {
        Set<String> stringLista = new Set<String>();
        if(campo != null && sobjectLista != null)
        {
            for(SObject registro : sobjectLista)
            {
                String valor = String.valueOf(registro.get(campo));
                if(String.isNotBlank(valor))
                {
                    stringLista.add(valor);
                }
            }
        }
        return stringLista;
    }

    public static Map<String, SObject> mapearValorPorCampoDeSObject(List<SObject> sobjectLista, Schema.SObjectField campo)
    {
        Map<String, SObject> mapaRegistroPorCampo = new Map<String, SObject>();
        if(campo != null && sobjectLista != null)
        {
            for(SObject registro : sobjectLista)
            {
                if(registro != null)
                {
                    String chave = String.valueOf(registro.get(campo));
                    mapaRegistroPorCampo.put(chave, registro);
                }
            }
        }
        return mapaRegistroPorCampo;
    }

    public static Boolean contemApenasNumeros(String texto)
    {
        Boolean contemApenasNumeros =
            String.isNotBlank(texto) &&
            Pattern.compile('[0-9]*').matcher(texto).matches();
        return contemApenasNumeros;
    }

    /* Método para classe de teste */
    public static Id gerarIdFalso(Schema.SObjectType sobj)
    {
        Id fakeId = null;
        if(sobj != null)
        {
            fakeId = String.format(
                '{0}{1}{2}{3}',
                new String[]
                {
                    sobj.getDescribe().getKeyPrefix(),
                    '00',
                    '00',
                    String.valueOf(System.now().getTime()).substring(0, 8)
                }
            );
        }
        return fakeId;
    }
    // POR062-1 - FIM
      //PLV-5678 - INICIO
      public static Double buscaPeriodoInadimplenciaProd(String idProduto){
        List<ParametroVigencia__c> parametroVigencia = [SELECT id, PeriodoMaximoInadimplencia__c FROM ParametroVigencia__c WHERE Produto__r.id =: idProduto ];       
        return parametroVigencia[0].PeriodoMaximoInadimplencia__c;
    }
    //PLV-5678 - FIM

    //LECVP-72 - INICIO
    public static Datetime montarDataHoraComGMT(Datetime dataHora){
        String dtFormat = dataHora.format('yyyy-MM-dd\'T\'HH:mm:ss','America/Sao_Paulo');
        dataHora = Datetime.valueOfGmt(dtFormat.replace('T', ' '));

        return dataHora;
    }
    //LECVP-72 - FIM
}