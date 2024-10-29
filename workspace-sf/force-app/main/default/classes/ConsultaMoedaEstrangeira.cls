//PLV-3854 INICIO

public class ConsultaMoedaEstrangeira{
    
    public class cotacaoMoeda{
        
        private String moedaOrigem; // CurrencyIsoCode
        private String moedaDestino; // PagamentoGarantia__c.CurrencyIsoCode
        private String dataFinalValidade; // Dataocorrencia__c
        private String dataInicioValidade; // Dataocorrencia__c -6        
        
        public String parseToJson() 
        {
            return System.JSON.serialize(this);
        }
    }
  
    //MGRC-1657 - INICIO
    @Future(callout = true)
    public static void ConsultaMoeda(List<Id> listIds){
        //public static String ConsultaMoeda(){
        
        List<PagamentoGarantia__c> listSinistros = [select Id, CurrencyIsoCode, Caso__r.Dataocorrencia__c, Caso__r.CurrencyIsoCode from PagamentoGarantia__c where Id =: listIds];
        
        /*cotacaoMoeda entityObj = new cotacaoMoeda();

entityObj.moedaOrigem = String.valueOf(listSinistros[0].CurrencyIsoCode);
entityObj.moedaDestino = 'BRL';

String dataFinalValidade  = Date.valueOf(listSinistros[0].Caso__r.Dataocorrencia__c).format();
entityObj.dataFinalValidade = '22052020';//dataFinalValidade.replace('/','');

String dataInicioValidade = Date.valueOf(listSinistros[0].Caso__r.Dataocorrencia__c).format();
entityObj.dataInicioValidade = '22052020';//dataInicioValidade.replace('/','');

System.debug('moedaOrigem do registro = ' + entityObj.moedaOrigem);
System.debug('moedaDestino do registro = ' + entityObj.moedaDestino);
System.debug('dataFinalValidade do registro = ' + entityObj.dataFinalValidade);
System.debug('dataInicioValidade do registro = ' + entityObj.dataInicioValidade);*/
        
        List<cotacaoMoeda> entity = new List<cotacaoMoeda>();
        Set<String> origensSet = new Set<String>();
        Map<String, List<PagamentoGarantia__c>> mapOrigens = new Map<String, List<PagamentoGarantia__c>>();
        
        System.debug('listSinistros = '+ listSinistros);
        for(PagamentoGarantia__c pag : listSinistros){
            //cotacaoMoeda entityObj = new cotacaoMoeda();					
            
            origensSet.add(pag.CurrencyIsoCode);						   				
            
            /*entityObj.moedaOrigem = String.valueOf(pag.CurrencyIsoCode);
entityObj.moedaDestino = 'BRL';

String dataFinalValidade  = Date.valueOf(pag.Caso__r.Dataocorrencia__c).format();			
entityObj.dataFinalValidade = dataFinalValidade.replace('/','');

String dataInicioValidade = Date.valueOf(pag.Caso__r.Dataocorrencia__c).format();
entityObj.dataInicioValidade = dataInicioValidade.replace('/','');

entity.add(entityObj);
System.debug('moedaOrigem do registro = ' + entityObj.moedaOrigem);
System.debug('moedaDestino do registro = ' + entityObj.moedaDestino);
System.debug('dataFinalValidade do registro = ' + entityObj.dataFinalValidade);
System.debug('dataInicioValidade do registro = ' + entityObj.dataInicioValidade);*/		
        }
        
        for(String origen : origensSet){
            String token = '';
            
            if(!test.isRunningTest())
                token = getTokenCIV();
            
			String nomeServico = 'Consulta_CIV_Cotacao_Moeda_Estrangeira';
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint(gerarEndpoint(nomeServico));
            request.setMethod('PUT');
            request.setHeader('Authorization', 'Bearer '+token);
            request.setHeader('Content-Type', 'application/json');
            
            cotacaoMoeda objCot = new cotacaoMoeda();		
            
            String dataFinalValidade  = Date.valueOf(listSinistros[0].Caso__r.Dataocorrencia__c).format();
            objCot.dataFinalValidade = dataFinalValidade.replace('/','');
            
            String dataInicioValidade = Date.valueOf(listSinistros[0].Caso__r.Dataocorrencia__c.addDays(-6)).format();
            objCot.dataInicioValidade = dataInicioValidade.replace('/','');
            
            objCot.moedaOrigem		= origen;
            objCot.moedaDestino		= 'BRL';
            
            request.setBody(System.JSON.serialize(objCot));
            
            //System.debug('Body = ' + entity.parseToJson());
            System.debug('Lista = ' + System.JSON.serialize(objCot));
            
            HttpResponse response = http.send(request);
            
            if( response.getStatusCode() == 200 ){
                
                System.debug('Ok');
                System.debug(response.getBody());
                String response2 = response.getBody();
                JsonCIVConsultaMoeda retorno = JsonCIVConsultaMoeda.parse(response2);
                
                for(PagamentoGarantia__c pag : listSinistros){
                    
                    if(pag.CurrencyIsoCode == origen){
                        System.debug('Data de retorno = ' + retorno.ItensCotacao.ItemCotacao.dataCotacao);
                        String  data = String.valueOf(retorno.ItensCotacao.ItemCotacao.dataCotacao);
                        String ano = data.substring(4, 8);
                        System.debug('Ano = '+ ano);
                        String mes = data.substring(2, 4);
                        System.debug('Mes = '+ mes);
                        String dia = data.substring(0, 2);
                        System.debug('Dia = '+ dia);
                        
                        String dataFormatada = ano+'-'+mes+'-'+dia; 
                        pag.Data_da_cotacao_da_moeda_estrangeira__c = Date.valueOf(dataFormatada);
                        pag.Valor_da_cotacao_em_reais__c = Decimal.valueOf(retorno.ItensCotacao.ItemCotacao.cotacao);
                    }								
                }
                
                System.debug('listSinistros = '+ listSinistros);
                
                update listSinistros;
                system.debug('retorno moeda = '+retorno.ItensCotacao.ItemCotacao.moedaOrigem);   
                
            }else{
                System.debug('Erro');
                System.debug('Erro serviço = ' + response.getBody());               
				
                String response2 = response.getBody();
                //JsonCIVConsultaMoeda retorno = JsonCIVConsultaMoeda.parseErro(response2);
                erroRetorno erroRetornoObj = (erroRetorno) System.JSON.deserialize(response2, erroRetorno.class);
                System.debug('erroRetornoObj = ' + erroRetornoObj);
				System.debug('erroRetornoObj.mensagem = ' + erroRetornoObj.mensagem);
				for(PagamentoGarantia__c pag : listSinistros){
                    
                    if(pag.CurrencyIsoCode == origen){
                        /*System.debug('Data de retorno = ' + retorno.ItensCotacao.ItemCotacao.dataCotacao);
                        String  data = String.valueOf(retorno.ItensCotacao.ItemCotacao.dataCotacao);
                        String ano = data.substring(4, 8);
                        System.debug('Ano = '+ ano);
                        String mes = data.substring(2, 4);
                        System.debug('Mes = '+ mes);
                        String dia = data.substring(0, 2);
                        System.debug('Dia = '+ dia);*/
                        
                        //String dataFormatada = ano+'-'+mes+'-'+dia; 
                        pag.msg_erro_log__c = erroRetornoObj.mensagem;
                        //pag.Valor_da_cotacao_em_reais__c = Decimal.valueOf(retorno.ItensCotacao.ItemCotacao.cotacao);
                    }								
                }
                update listSinistros;
            }
        }		        		
        
    }
    //MGRC-1657 - FIM
    
    public static String getTokenCIV(){
        
        String token;
        
        // Buscar a credencial oauth2 do Auth0
        CredencialOAuth2__mdt credencialOAuth2 = 
            [SELECT Id, ClientId__c, ClientSecret__c, 
             GrantType__c, Audience__c, Status__c 
             FROM CredencialOAuth2__mdt 
             WHERE DeveloperName = 'CIV'
            ];
        
        if (!credencialOAuth2.Status__c) {
            return '';
        }
        String nomeServico = 'GerarTokenCIV';	
        system.debug('token: '+ credencialOAuth2);
        
        String client_Id = credencialOAuth2.ClientId__c;
        String client_secret = credencialOAuth2.ClientSecret__c;
        String grant_type = credencialOAuth2.GrantType__c;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(gerarEndpoint(nomeServico));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String payload = 'client_id='+EncodingUtil.urlEncode(client_id,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(client_secret,'UTF-8')+'&grant_type='+grant_type;
        
        System.debug('payload = ' + payload);    
        request.setBody(payload);
        
        System.debug('request = ' + request);
        
        HttpResponse response = http.send(request);
        
        if( response.getStatusCode() == 200 ){
            
            System.debug('Ok');
            
            String response2 = response.getBody();
            system.debug(response.getBody());
            jsonTokenConsultaMoeda retorno = jsonTokenConsultaMoeda.parse(response2);
            
            token = retorno.access_token;
            
        }else{
            System.debug('Erro');
        }               
        
        system.debug('token: '+token);
        return token;
    }
    
    public static String gerarEndpoint(String nomeServico) {
        Servico__mdt servico =  buscarMetadadoServico(nomeServico);
        String endpoint =  String.isNotBlank(servico.Endpoint__c) ? servico.Endpoint__c : '';
        return Test.isRunningTest() ? 'http://testes.portoseguro.com.br/fake-endpoint' : 'callout:' + servico.NomeCredencial__c + endpoint;
    }
    
    public static Servico__mdt buscarMetadadoServico(String nomeServico) {
        system.debug('Nome '+nomeServico);
        return MetadataDAO.getInstance().buscarServico(nomeServico);
    }
    
    public class erroRetorno{
        public Integer codigo;
		public String mensagem;
		public String dataOcorrencia;
		public String fonte;
		public String tipo;
		public String additionalInfo;                
    }
}
//PLV-3854 FIM