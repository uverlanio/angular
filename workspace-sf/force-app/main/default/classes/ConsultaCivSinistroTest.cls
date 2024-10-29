//PLV-4096 - Inicio
@isTest 
private class ConsultaCivSinistroTest {

	@testSetup static void setup() {
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica.Id];
        
        case caso = new case();
        caso.AccountId = contaFisica.Id;
        caso.ContactId = contato.Id;
        caso.Status_Dependente__c = 'Aberto';

		caso.Nome_Segurado__c = 'Teste';
		caso.Cpf_Segurado__c = '075.487.587-87';
		//caso.digitoCpfSegurado = casoObj.Cpf_Segurado__c.substring(12, 14); //Digito CPF
		//caso.Dataocorrencia__c = Date.valueOf('2005-10-10');
		caso.Subject = 'Teste';
		caso.Description = 'Teste';			
		//caso.origem = 'SFDC';
		caso.Numero_titulo__c = '14587452';
		caso.Vitima__c = 'Segurado';
		caso.IdPrestadora__c = 'Teste';
		//caso.Id = '254785478';
		caso.TipoEvento__c = 'Acidente';
		//caso.avisado = 'true';
		caso.EmpresaSplit__c = 52.5;
		caso.sucursal__c = 'Teste';
		caso.RamoSplit__c = 54.5;
		caso.Numero_Apolice__c  = '102458798754';
		//caso.endosso = objCasoSinistro.apolice.substring(10, 11);
		caso.SinistroPrioritario__c = True;
		//caso.edsTip = '2';
		//PLV-4176 Inicio
		caso.Origin = 'Backoffice';
		//PLV-4176 Fim
        caso.Data_Aviso_Cliente__c = system.today();
        caso.Dataocorrencia__c = system.today();
        //caso.CurrencyIsoCode = 'USD';
        insert caso;
        
        /*PagamentoGarantia__c pg = new PagamentoGarantia__c();
        
        pg.Caso__c = caso.Id;
        pg.CurrencyIsoCode = 'USD';
        insert pg;*/    
    }
    //MGRC-1657 - INICIO
    // @isTest
    // static void ConsultaCivSucesso(){
        
    //     Set<Id> lcasos = new Set<Id>();
    //     Case pg  = [select Id, Nome_Segurado__c, Cpf_Segurado__c, Dataocorrencia__c, Subject, Description, Numero_titulo__c,
	// 	Vitima__c, IdPrestadora__c, TipoEvento__c, EmpresaSplit__c, sucursal__c, RamoSplit__c, Numero_Apolice__c, SinistroPrioritario__c from Case ];
    //     lcasos.add(pg.Id);    
        
    //     test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new ConsultaCivTestMock());
    //     ConsultaCivSinistro.ConsultaCivSinistroTicketBCPIntegracao(lcasos);
    //     test.stopTest();

        
    // }
    // @isTest
    // static void ConsultaCivErro(){
        
    //     Set<Id> lCasos = new Set<Id>();
    //     Case pg  = [select Id, Nome_Segurado__c, Cpf_Segurado__c, Dataocorrencia__c, Subject, Description, Numero_titulo__c,
	// 	Vitima__c, IdPrestadora__c, TipoEvento__c, EmpresaSplit__c, sucursal__c, RamoSplit__c, Numero_Apolice__c, SinistroPrioritario__c from Case ];
    //     lCasos.add(pg.Id);    
        
    //     test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new ConsultaCivTestMock.ConsultaMoedaEstrangeiraTestErroMock());
    //     ConsultaCivSinistro.ConsultaCivSinistroTicketBCPIntegracao(lCasos);
    //     test.stopTest();

        
    // }
    //MGRC-1657 - FIM
	@isTest
    static void ConsultaCivToken(){

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ConsultaCivTestMock.ConsultaMoedaEstrangeiraToken());
        ConsultaCivSinistro.getTokenCIV();
        test.stopTest();

        
    }
}
//PLV-4096 - Fim