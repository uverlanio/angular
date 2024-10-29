// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
@isTest 
private class PagamentoPrestadorasTest {
    //PLV-4148 - INICIO
	 @testSetup 
    static void setup() {
        Account contaFisica = (Account) new AccountFactory.PessoaJuridica().createRecord();
        contact cont = new contact(
        	FirstName = 'santana',
            LastName = 'santana',
            AccountId  = contaFisica.Id
        );
        insert cont;
        contact contato = [SELECT Id FROM Contact WHERE AccountId =: contaFisica.Id];
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaFisica, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiro).createRecord();
        
		
		RamoSeguro__c ramo = new RamoSeguro__c();
        ramo.Name = 'Segurado';
        ramo.CodigoEmpresa__c = '214';
        ramo.Codigo__c = '1369';
        ramo.IdExterno__c = '214_9';
        ramo.Status__c = 'Ativo';
        ramo.CodigoOrigemDoMovimentoBCP__c = '32';
        insert ramo;
		
		Modalidade__c modalidade = new Modalidade__c();
        modalidade.RamoSeguro__c = ramo.Id;
        modalidade.Name = 'Factory';
        modalidade.Codigo__c = '0';
        insert modalidade;
        
	
        
        
        Recordtype casoAtendimento = RecordTypeBO.buscarTipoRegistro('Case', 'Atendimento');
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
        
        case casoFilho = new case();
        
        Id IdRegistro1 = [SELECT Id, Name, DeveloperName, SobjectType	FROM RecordType where Name = 'Sinistro'].Id;
        //Recordtype REC_ID_SINISTRO = RecordTypeBO.buscarTipoRegistro('Case', 'Sinistro');
        //casoFilho.ParentId = caso.Id;
        casoFilho.RecordTypeId = IdRegistro1;
        casoFilho.ParentId = caso.Id;
        casoFilho.AccountId = contaFisica.Id;
        casoFilho.ContactId = contato.Id;
        casoFilho.Status_Dependente__c = 'Aberto';

        casoFilho.Data_Aviso_Cliente__c = system.today();
        casoFilho.Dataocorrencia__c = system.today().addDays(-30);
        casoFilho.CurrencyIsoCode = 'USD';
        casoFilho.Parceiro__c = parceiro.Id;
      	casoFilho.Type = 'Sinistro';
        casoFilho.Contrato__c = contrato.Id;
      
        insert casoFilho;
        
        PagamentoGarantia__c garantiaPagamento = new PagamentoGarantia__c();
        garantiaPagamento.Caso__c = casoFilho.Id;
        garantiaPagamento.CurrencyIsoCode = 'USD';
        garantiaPagamento.Fase__c = 'Em Análise';
     
        insert garantiaPagamento;
          
        Requisicao_de_Pagamento__c rq = new Requisicao_de_Pagamento__c();
        rq.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 4;
        rq.Valor_Total_Prestadora__c = 100;
        rq.Data_de_Final_de_Periodo__c = Date.today().addDays(20);
        rq.Data_de_Inicio_de_Periodo__c = Date.today().addDays(-10);
        rq.Contas_de_Parceiro__c = contaFisica.Id;
        rq.Status__c = 'Pendente';
            
        insert rq;  
        
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
        ps.Beneficiario_da_Garantia__c = contaFisica.Id;
        ps.Requisicao_de_Pagamento__c = rq.Id;
        ps.Caso_de_Sinistro__c = casoFilho.Id;
        insert ps;
   
        TestDataFactory.gerarFatura();
     
        
    }
	@isTest
    //PLV-4148 - FIM
	private static void validaTipoRegistroSucesso() {
		Id recordTypeId = [select Id from RecordType where SobjectType  = 'Requisicao_de_Pagamento__c' and Name = 'Operacional de sinistros'].Id;
                                                    
		test.startTest();
        PagamentoPrestadoras.validaTipoRegistro(recordTypeId);
        //PLV-4148-FIX5 - INICIO
        recordTypeId = null;
        PagamentoPrestadoras.validaTipoRegistro(recordTypeId);
        //PLV-4148-FIX5 - FIM
        test.stopTest();
	}

	@isTest
	private static void buscarPagamentosSinistrosSucesso() {
		Recordtype REC_ID_PERSONACCOUNT = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica'); 
        Date datePersonBirthdate = Date.newInstance(1984, 02, 02);

		Date dtinicio = system.today().addDays(-20);
        Date dtfim = system.today().addDays(-10);

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

		Pagamento_de_Sinistro__c PgSinistro = new Pagamento_de_Sinistro__c();

		PgSinistro.Beneficiario_da_Garantia__c = parceiro.Id;
                                            
		test.startTest();
        PagamentoPrestadoras.buscarPagamentosSinistros(String.valueOf(dtinicio), String.valueOf(dtfim), String.valueOf(parceiro.Id));
      
        test.stopTest();
	}

	@isTest
	private static void atualizaPagamentoSinistroSucesso() {
		//PLV-4148 - INICIO
		Id req = [SELECT Id FROM Requisicao_de_Pagamento__c LIMIT 1].Id;
        List<String> pagamento = new List<String>();
        Pagamento_de_Sinistro__c pg = [SELECT Id, Requisicao_de_Pagamento__c FROM Pagamento_de_Sinistro__c LIMIT 1];
        pg.Requisicao_de_Pagamento__c = req;
        update pg;
        pagamento.add(pg.Id);
		test.startTest();
        PagamentoPrestadoras.atualizaPagamentoSinistro(req, pagamento);
        test.stopTest();
        //PLV-4148 - FIM
        
	}
    
    //PLV-4148 - INICIO
    @isTest
    public static void buscarGarantiasTest(){
        Date dtinicio = system.today().addDays(-40);
        Date dtfim = system.today().addDays(1);
        
        Account parceiro = [SELECT Id FROM Account LIMIT 1];        
        Id req = [SELECT Id FROM Requisicao_de_Pagamento__c LIMIT 1].Id;
        List<String> pagamentos = new List<String>();
        
        PagamentoGarantia__c pa = [SELECT Id FROM PagamentoGarantia__c limit 1];
       
        pagamentos.add(pa.Id);
        
     
        
        test.startTest();
     	  PagamentoPrestadoras.buscarGarantias(String.valueOf(dtinicio), String.valueOf(dtfim), String.valueOf(parceiro.Id), 'USD');
          PagamentoPrestadoras.createPagamentoSinistro(req,pagamentos);
          PagamentoPrestadoras.buscaMoedas();

        test.stopTest();
    }
     
    //PLV-4148 - FIM
    
    //PLV-4604 - INICIO
    @isTest
    public static void criarPagamentoDespesaTest_Success(){
        Case caso = [SELECT Id FROM Case WHERE RecordType.Name = 'Sinistro' LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Requisicao_de_Pagamento__c requisicao = new Requisicao_de_Pagamento__c(
            Contas_de_Parceiro__c = conta.Id,
            Numero_do_Sinistro__c = caso.Id,
            RecordTypeId = Schema.SObjectType.Requisicao_de_Pagamento__c.getRecordTypeInfosByDeveloperName().get('Despesas_com_Sinistros_Nao_Tributaveis').getRecordTypeId(),
            Status__c = 'Pendente',
            Valor_Total_Prestadora__c = 16000,
            Tipo_de_pagamento__c = 'Pagamento Segurado (OP não tributável)'
        );
        Test.startTest();
        PagamentoPrestadoras.criarPagamentoDespesa(requisicao);
        Test.stopTest();
        System.assertEquals(requisicao.Id != null, true);
    }
    @isTest
    public static void criarPagamentoDespesaTest_Error(){
        Case caso = [SELECT Id FROM Case WHERE RecordType.Name = 'Sinistro' LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Requisicao_de_Pagamento__c requisicao = new Requisicao_de_Pagamento__c(
            Contas_de_Parceiro__c = conta.Id,
            Numero_do_Sinistro__c = caso.Id,
            RecordTypeId = Schema.SObjectType.Requisicao_de_Pagamento__c.getRecordTypeInfosByDeveloperName().get('Despesas_com_Sinistros_Tributaveis').getRecordTypeId(),
            Status__c = 'Pendente',
            Valor_Total_Prestadora__c = 16000,
            Tipo_de_pagamento__c = 'Pagamento Segurado (OP não tributável)'
        );
        Test.startTest();
        String message = null;
        try {
            PagamentoPrestadoras.criarPagamentoDespesa(requisicao);
        }catch(AuraHandledException  e){
            message = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(message, 'Script-thrown exception');
    }
    //PLV-4604 - FIM
  	
}