@isTest 
private class CriarPagamentoSinistroTest {

	@testSetup static void setup() {
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica.Id];
		
        FormaPagamento__c formaPG = new FormaPagamento__c();
        formaPG.Codigo__c = '1234';
        FormaPG.Name = '3X';
        insert formaPG;
        
        Parceiro__c parceiro = new Parceiro__c();
        parceiro.DiaFaturamento__c = '10';
        parceiro.DiaPreFaturamento__c = '08';
        parceiro.PrazoVencimento__c = '30';
        parceiro.Conta__c = contaFisica.Id;
        parceiro.FaturaProdutosSeparados__c = 'Não';  
        parceiro.FormaPagamento__c = formaPG.Id;
        parceiro.PossuiAnexoFatura__c = 'Sim';
        parceiro.SiglaParceiro__c = 'PSEG';
        parceiro.Empresa__c = '1';
        parceiro.Sucursal__c = '1';
        parceiro.Ramo__c = '1377';
        
        
        insert parceiro;
        
        case caso = new case();
        
        Id IdRegistro = [SELECT Id, Name, DeveloperName, SobjectType	FROM RecordType where Name = 'Atendimento'].Id;
        //Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        caso.RecordTypeId = IdRegistro;
        caso.AccountId = contaFisica.Id;
        caso.ContactId = contato.Id;
        caso.Status_Dependente__c = 'Avisado';
		caso.Parceiro__c = parceiro.Id;
		caso.Nome_Segurado__c = 'Teste';
		caso.Cpf_Segurado__c = '075.487.587-87';
		//caso.digitoCpfSegurado = casoObj.Cpf_Segurado__c.substring(12, 14); //Digito CPF
		//caso.Dataocorrencia__c = Date.valueOf('2005-10-10');
		caso.Subject = 'Teste';
		caso.Description = 'Teste';			
		caso.Origin = 'Prestadora';
		caso.Numero_titulo__c = '14587452';
		caso.Vitima__c = 'Segurado';
		caso.IdPrestadora__c = 'Teste';
		//caso.Id = '254785478';
		caso.TipoEvento__c = 'Acidente';
		//caso.avisado = 'true';
		//caso.EmpresaSplit__c = 52.5;
		//caso.sucursal__c = 'Teste';
		caso.RamoSplit__c = 54.5;
		caso.Numero_Apolice__c  = '102458798754';
		//caso.endosso = objCasoSinistro.apolice.substring(10, 11);
		caso.SinistroPrioritario__c = True;
		//caso.edsTip = '2';
		caso.Type = 'Padrão';

        caso.Data_Aviso_Cliente__c = system.today();
        caso.Dataocorrencia__c = system.today();
        //caso.CurrencyIsoCode = 'USD';
        System.debug('casoPai = ' + caso);
        insert caso;
          
    }

	@isTest
    static void Sucesso(){
        Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica'); 
        Date datePersonBirthdate = Date.newInstance(1984, 02, 02);
        Account contaFisica2 =  new Account(RecordtypeId = REC_ID_PERSONACCOUNT.Id,
				FirstName = 'PessoaFisica',
				LastName = 'PessoaFisica',
				Cpf__c = '075.517.654-50',
				Pep__c = 'Não',
				Nacionalidade__c = 'Brasileira',
				Phone = '(00) 0000-0000', // ANNVI-55 - INICIO/FIM
				PersonBirthdate = datePersonBirthdate);
        
        insert contaFisica2;
        
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica2.Id];
		
        FormaPagamento__c formaPG = new FormaPagamento__c();
        formaPG.Codigo__c = '987654';
        FormaPG.Name = '5X';
        insert formaPG;
        
        Parceiro__c parceiro = new Parceiro__c();
        parceiro.DiaFaturamento__c = '10';
        parceiro.DiaPreFaturamento__c = '08';
        parceiro.PrazoVencimento__c = '30';
        parceiro.Conta__c = contaFisica2.Id;
        parceiro.FaturaProdutosSeparados__c = 'Não';  
        parceiro.FormaPagamento__c = formaPG.Id;
        parceiro.PossuiAnexoFatura__c = 'Sim';
        parceiro.SiglaParceiro__c = 'PSEG';
        parceiro.Empresa__c = '1';
        parceiro.Sucursal__c = '1';
        parceiro.Ramo__c = '1377';
        
        
        insert parceiro;
        
        Case caso  = [select Id from Case ];        
        
       	case casoFilho = new case();
        
        Id IdRegistro = [SELECT Id, Name, DeveloperName, SobjectType	FROM RecordType where Name = 'Sinistro'].Id;
        //Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        //casoFilho.ParentId = caso.Id;
        casoFilho.RecordTypeId = IdRegistro;
        casoFilho.ParentId = caso.Id;
        casoFilho.AccountId = contaFisica2.Id;
        casoFilho.ContactId = contato.Id;
        casoFilho.Status_Dependente__c = 'Aberto';

        casoFilho.Data_Aviso_Cliente__c = system.today();
        casoFilho.Dataocorrencia__c = system.today().addDays(-30);
        casoFilho.CurrencyIsoCode = 'USD';
        casoFilho.Parceiro__c = parceiro.Id;
        insert casoFilho; 
        
        
        Set<Id> lcasos = new Set<Id>();
        Case pg  = [select Id, Parceiro__r.conta__c, Parceiro__c, ProdutoContratoFormula__c, Nome_Segurado__c, Cpf_Segurado__c, Dataocorrencia__c, Subject, Description, Numero_titulo__c,
		Vitima__c, IdPrestadora__c, TipoEvento__c, EmpresaSplit__c, sucursal__c, RamoSplit__c, Numero_Apolice__c, SinistroPrioritario__c from Case where Id =: casoFilho.Id ];
        lcasos.add(pg.Id);
		
		ProdutoParceiro__c pp = new ProdutoParceiro__c();

		pp.CodigoProdutoParceiro__c  = pg.ProdutoContratoFormula__c;
		pp.Parceiro__c = pg.Parceiro__c;

		insert pp;
		
        //PLV-4363 - INICIO
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '246';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'A B C ROMA S/A';
        banconew.Ativo__c = true;
        insert banconew; 
        //PLV-4363 - FIM

        
		InformacaoBancaria__c banco = new InformacaoBancaria__c();
        
        banco.Banco__c = '246';
		banco.Agencia__c = '3758';
		banco.NumeroConta__c = '35958';
        //PLV-3918-FIX6 - INICIO
        //PLV-3918-FIX7 - INICIO
		banco.Digito__c = '6';
		//PLV-3918-FIX7 - FIM
        //PLV-3918-FIX6 - FIM
        banco.StatusIntegracao__c = 'Validada';
		banco.Conta__c = pg.Parceiro__r.conta__c;
        banco.Principal__c = true;
        banco.BancoNew__c = banconew.Id; //PLV-4363 - INICIO/FIM

		insert banco;
        
        test.startTest();
        CriarPagamentoSinistro.inserirPagamentoSinistro(lcasos);
        test.stopTest();

        
    }
}