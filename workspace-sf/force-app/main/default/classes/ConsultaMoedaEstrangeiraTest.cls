//PLV-3854 INICIO

@isTest
global class  ConsultaMoedaEstrangeiraTest {
    @testSetup static void setup() {
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica.Id];
        
        case caso = new case();
        caso.AccountId = contaFisica.Id;
        caso.ContactId = contato.Id;
        caso.Status_Dependente__c = 'Aberto';

        caso.Data_Aviso_Cliente__c = system.today();
        caso.Dataocorrencia__c = system.today().addDays(-30);
        caso.CurrencyIsoCode = 'USD';
		//PLV-4176 Inicio
		caso.Origin = 'Backoffice';
		//PLV-4176 Fim
        insert caso;
        
        PagamentoGarantia__c pg = new PagamentoGarantia__c();
        
        pg.Caso__c = caso.Id;
        pg.CurrencyIsoCode = 'USD';
        insert pg;    
    }
   
    //MGRC-1657 - INICIO
    @isTest
    static void ConsultaMoedaSucesso(){
        
        List<Id> lPagamentoGarantia = new List<Id>();
        PagamentoGarantia__c pg  = [SELECT Id, CurrencyIsoCode, Caso__r.Dataocorrencia__c, Caso__r.CurrencyIsoCode FROM PagamentoGarantia__c];
        lPagamentoGarantia.add(pg.Id);    
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ConsultaMoedaEstrangeiraTestMock());
        ConsultaMoedaEstrangeira.ConsultaMoeda(lPagamentoGarantia);
        test.stopTest();

        
    }
    @isTest
    static void ConsultaMoedaErro(){
        
        List<Id> lPagamentoGarantia = new List<Id>();
        PagamentoGarantia__c pg  = [SELECT Id, CurrencyIsoCode, Caso__r.Dataocorrencia__c, Caso__r.CurrencyIsoCode FROM PagamentoGarantia__c];
        lPagamentoGarantia.add(pg.Id);    
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ConsultaMoedaEstrangeiraTestMock.ConsultaMoedaEstrangeiraTestErroMock());
        ConsultaMoedaEstrangeira.ConsultaMoeda(lPagamentoGarantia);
        test.stopTest();

        
    }
    //MGRC-1657 - FIM
    
	@isTest
    static void ConsultaMoedaToken(){

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ConsultaMoedaEstrangeiraTestMock.ConsultaMoedaEstrangeiraToken());
        ConsultaMoedaEstrangeira.getTokenCIV();
        test.stopTest();

        
    }    
}
//PLV-3854 FIM