public class pagamentosrecentescontroller {
    
@AuraEnabled
    public static String consultapagamentos(String recordId) 
    {
       List<Object> LstObject2Heroku = new List<Object>();
       LstObject2Heroku = [SELECT Id
       	  				   FROM BeneficiarioGarantia__c
                           WHERE Pagamento_de_garantia__r.Id =: recordId];

       Http h = new Http();
    
       String body = JSON.serialize(LstObject2Heroku);
       CredencialOAuth2__mdt  credencial = MetadataDAO.getInstance().buscarCredencial('VidaCloudApi');
       Servico__mdt servico = MetadataDAO.getInstance().buscarServico('Consulta_Pagamento');
       String Token;
        
       if(!test.isrunningtest()){ Token = HerokuService.getInstance().gerarTokenOAuth2('VidaCloudApi');
       }else{
          Token = 'faketesttoken';
       }
        
       // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
       HttpRequest req = new HttpRequest();
       req.setMethod('POST');
       req.setHeader('Content-Type', 'application/json');

       if(!Test.isRunningTest()){
       req.setHeader('Authorization', Token);
       req.setBody(body);
       req.setEndpoint(credencial.Audience__c + '/api/' + servico.Endpoint__c);

       
       		// Send the request, and return a response
       HttpResponse res = h.send(req); 
           
       system.debug('req '+ req); 
       system.debug('res '+ res);
       //PLV - 2336-28 - Inicio/Fim - Removido debug
       return res.getBody(); 
       }else{
            PagamentosRecentesControllerMock pagRecM = new PagamentosRecentesControllerMock();
           	HttpResponse resposta = pagRecM.respond(req);
           	return resposta.getBody(); 
           }
    }        
    
	@AuraEnabled
    public static String cancelapagamentos(Integer recordId) 
    {
       Http h = new Http();
    
       String body = '{"idpagamento" : '+recordId+'}'; 
       
       CredencialOAuth2__mdt  credencial = MetadataDAO.getInstance().buscarCredencial('VidaCloudApi');
       Servico__mdt servico = MetadataDAO.getInstance().buscarServico('Cancela_Pagamento');
       
       String Token;       
       if(!test.isrunningtest()){ Token = HerokuService.getInstance().gerarTokenOAuth2('VidaCloudApi');
        }else{
          Token = 'faketesttoken';
        }
        
       HttpRequest req = new HttpRequest();
       req.setMethod('POST');
       req.setHeader('Content-Type', 'application/json');
       req.setHeader('Authorization', Token);

       req.setBody(body);
       HttpResponse res;
       if(!Test.isRunningTest()){ req.setEndpoint(credencial.Audience__c + '/api/' + servico.Endpoint__c);
       res = h.send(req);
       }else{
            PagamentosRecentesControllerMock pagRecM = new PagamentosRecentesControllerMock();
           	res = pagRecM.respondCancelaPagamento(req);
       }
        return res.getBody(); 
    }            
    
    @AuraEnabled
    public static Map<Id, Account> retornanomeConta(String[] recordId) 
    {
        system.debug(recordId);
        Map<ID, Account> m = new Map<ID, Account>([SELECT Name FROM Account Where Id =: recordId LIMIT 10]);
        return m;          
    }
        
	@AuraEnabled
    public static void mudastatusbeneficiario(String recordId) 
    {
		List<BeneficiarioGarantia__c> Lstbene = [SELECT Id, Status__c
                                                 FROM BeneficiarioGarantia__c
                                                 WHERE Id =: recordId];
		if(Lstbene.size() == 0) return;
        
        LstBene[0].Status__c = 'Pendente';
        database.update(LstBene[0]);
    }        
}