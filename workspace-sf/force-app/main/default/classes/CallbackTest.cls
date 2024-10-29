// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
@isTest
public class CallbackTest {
    //PLV-3918-FIX3 - INICIO
    private static Integer idPagamento;
    //PLV-3918-FIX3 - FIM
	@isTest
    public static void executar(){
          Database.SaveResult sr = (Database.SaveResult) JSON.deserialize('{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);
          
			           
         
        //PLV-3918 - FIX1 - INICIO
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
        
         //PLV-4148-FIX1 - INICIO
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
           
        Contract contra = [SELECT CodigoRamo__c, CodigoModalidade__c FROM Contract limit 1];
        contra.CodigoRamo__c = '1369';
        contra.ModalidadeSeguro__c = modalidade.Id;
        update contra;
        //PLV-4148-FIX1 - FIM        
        
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
        //PLV-4148-FIX1 - INICIO
        casoFilho.Contrato__c = contra.Id;
        //PLV-4148-FIX1 - FIM
        insert casoFilho;
        
        //PLV-3918-FIX3 - INICIO
       	Pagamento__x pgto = TestDataFactory.mapeiaPagamento(contaFisica, 'PAGAMENTO EM APROVAÇÃO');
        idPagamento = Integer.valueOf(pgto.Id__c);
        PagamentoDAO.mockedPagamentos.add(pgto);
        
        NotaFiscal__c nf = TestDataFactory.mapeiaNotaFiscal(idPagamento, 'Pendente');
        insert nf;
      	//PLV-3918-FIX3 - FIM
        //PLV-3918-FIX3 - INICIO
        
       
        
        Test.startTest();
        //PLV-3918-FIX3 - FIM
        Requisicao_de_Pagamento__c rq = new Requisicao_de_Pagamento__c();
        rq.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 4;
        rq.Valor_Total_Prestadora__c = 100;
        rq.Data_de_Final_de_Periodo__c = Date.today().addDays(20);
        rq.Data_de_Inicio_de_Periodo__c = Date.today().addDays(-10);
        rq.Contas_de_Parceiro__c = contaFisica.Id;
        rq.Status__c = 'Pendente';
        //PLV-3918-FIX3 - INICIO
        rq.Nota_fiscal__c = nf.Id;
        //PLV-3918-FIX3 - FIM
        //PLV-4148-FIX5 - INICIO
        rq.Data_Programada_de_Pagamento__c = Date.today()+3;
        //PLV-4148-FIX5 - FIM
        insert rq;  
            
        
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
        ps.Beneficiario_da_Garantia__c = contaFisica.Id;
        ps.Requisicao_de_Pagamento__c = rq.Id;
        ps.Caso_de_Sinistro__c = casoFilho.Id;
        //PLV-4148-FIX1 - INICIO
        PS.Valor_total_a_ser_indenizado__c = 10;
        //PLV-4148-FIX1 - FIM
        insert ps;
        //PLV-3918 - FIX1 -FIM
        //PLV-4148-FIX1 - INICIO
        Requisicao_de_Pagamento__c rnew = [select Status__c from Requisicao_de_Pagamento__c limit 1];
        rnew.Status__c = 'Enviar p/ Financeiro';
        update rnew;
        //PLV-4148-FIX1 - FIM
			Callback c = new Callback();
        	//PLV-4148-FIX5 - INICIO
        	c.lpgtest = [SELECT Id, Requisicao_de_Pagamento__c, Data_Programada_de_Pagamento__c FROM Pagamento_de_Sinistro__c limit 1];
        	//PLV-4148-FIX5 - FIM
        	c.processSave(sr);
        Test.stoptest();
        
        
    }
}