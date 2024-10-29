/**
 * Created by Gabriel Loch 17/07/2020.
 */
// PLV-3910 - INICIO
@IsTest
public class ConsultaCorretorRestTest {
    public static RestRequest request {get; set;}
    public static String baseUrl {get; set;}
    
    @testSetup 
	static void setup(){
		TestDataFactory.gerarDadosSetup();
	}
    
    @isTest
    public static void makeData(){
        request = new RestRequest();
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm().toLowercase() + '/services/apexrest/corretor/apolice';
       // System.debug('>>>>>>>>>>' + baseUrl);
    }
    
    @isTest 
    public static void consultarTest_semApolice(){
        makeData();
        
        request.requestUri = baseUrl ;
        request.httpMethod = 'GET';
        RestContext.request = request;
            
        Test.startTest();
        
        ConsultaCorretorRest.consultar();
        
        Test.stopTest();
    } //ok
    
    
    
    @isTest 
    public static void consultarTest_apolieInexistente(){
        makeData();
        
        request.requestUri = baseUrl + '9-9-9999-999999999-9';
        request.httpMethod = 'GET';
        RestContext.request = request;
            
        Test.startTest();
        
        ConsultaCorretorRest.consultar();
        
        Test.stopTest();
    } //ok
    
    @isTest 
    public static void consultarTest_apolieValida(){
        
        Account corretor = (Account) new AccountFactory.PessoaFisica().createRecord();
        corretor.Email__c= 'e@mail.com';
        corretor.SusepPrincipal__c = '564/2017';
        update corretor;
        
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(corretor).createRecord();
        
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactorySemParam().createRecord();
        contrato.CodigoCorretor__c = dadosCorretor.id;
        contrato.name='8-8-8888-888888888-8';
        contrato.IdExterno__c = contrato.name;
        
        TipoRemuneracao__c tipoRemuneracao = (TipoRemuneracao__c) new TipoRemuneracaoFactory().createRecord();
        RemuneracaoContrato__c remCont = (RemuneracaoContrato__c) new RemuneracaoContratoFactory(tipoRemuneracao, contrato).createRecord();
        
        FavorecidoRemuneracaoContrato__c favRemCont = (FavorecidoRemuneracaoContrato__c) new FavorecidoRemuneracaoContratoFactory(remCont, dadosCorretor).createRecord();
        
        update contrato;     
        
        makeData();
        
        request.params.put('numeroApolice', contrato.name);
        //request.httpMethod = 'GET';
        RestContext.request = request;
        
        Test.startTest();
       	ConsultaCorretorRest.consultar();
      	dadosCorretor.NomeCorretor__c = null;
        update dadosCorretor;
        
        ConsultaCorretorRest.consultar();
        
        Test.stopTest();
    }
    
  
}
// PLV-3910 - FIM