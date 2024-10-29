// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
@isTest
public class RequisicaoPagamentoTriggerHandlerTest {
    //PLV-3918-FIX3 - INICIO
    private static Integer idPagamento;
   //PLV-3918-FIX3 - FIM
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
        
		//PLV-4148 - INICIO
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
        
		//PLV-4148 - FIM        
        
        
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
        //PLV-3918-FIX3 - INICIO
        casoFilho.Contrato__c = contrato.Id;
        //PLV-3918-FIX3 - FIM
        insert casoFilho;
        
        //PLV-3918-FIX3 - INICIO
       	Pagamento__x pgto = TestDataFactory.mapeiaPagamento(contaFisica, 'PAGAMENTO EM APROVAÇÃO');
        idPagamento = Integer.valueOf(pgto.Id__c);
        PagamentoDAO.mockedPagamentos.add(pgto);
        system.debug('pgto'+pgto); 
        NotaFiscal__c nf = TestDataFactory.mapeiaNotaFiscal(idPagamento, 'Pendente');
        insert nf;
      	//PLV-3918-FIX3 - FIM
      
        
        Requisicao_de_Pagamento__c rq = new Requisicao_de_Pagamento__c();
        rq.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 4;
        rq.Valor_Total_Prestadora__c = 100;
        rq.Data_de_Final_de_Periodo__c = Date.today().addDays(20);
        rq.Data_de_Inicio_de_Periodo__c = Date.today().addDays(-10);
        rq.Contas_de_Parceiro__c = contaFisica.Id;
        rq.Status__c = 'Pendente';
        //PLV-4148 - INICIO
        rq.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Requisicao_de_Pagamento__c', 'Operacional_de_sinistros').Id;
        //PLV-4148 - FIM
        //PLV-3918-FIX3 - INICIO
        rq.Nota_fiscal__c = nf.Id;
        //PLV-3918-FIX3 - FIM
        
        insert rq;  
        
        Pagamento_de_Sinistro__c ps = new Pagamento_de_Sinistro__c();
        ps.Beneficiario_da_Garantia__c = contaFisica.Id;
        ps.Requisicao_de_Pagamento__c = rq.Id;
        ps.Caso_de_Sinistro__c = casoFilho.Id;
        //PLV-4148-FIX1 - INICIO
        ps.Valor_total_a_ser_indenizado__c = 100;
        //PLV-4148-FIX1 - FIM
        insert ps;
        //PLV-4148 - INICIO
        TestDataFactory.gerarFatura();
        //PLV-4148 - FIM
        
    }
    @isTest
    public static void enviarParaFinanceiro(){
 			
       //PLV-3918-FIX3 - INICIO 	
       Test.startTest();
       
       Requisicao_de_Pagamento__c lrp = [SELECT Id, Status__c FROM Requisicao_de_Pagamento__c limit 1];
       
       Modalidade__c modalidade = new Modalidade__c(); 
       modalidade.Codigo__c = '0';
       insert modalidade;
        
       Contract contra = [SELECT CodigoRamo__c, CodigoModalidade__c FROM Contract limit 1];
       contra.CodigoRamo__c = '1369';
       contra.ModalidadeSeguro__c = modalidade.Id;
       update contra;
       
       List<Pagamento_de_Sinistro__c> lPagSinistrotest = [SELECT  Caso_de_Sinistro__r.Contrato__r.CodigoRamo__c, Caso_de_Sinistro__r.Contrato__r.CodigoModalidade__c, Requisicao_de_Pagamento__c
                                       FROM Pagamento_de_Sinistro__c LIMIT 1];
       
       lrp.Status__c = 'Enviar p/ Financeiro';
       //PLV-4148-FIX5 - INICIO
       lrp.Data_Programada_de_Pagamento__c = Date.today()+3;
       //PLV-4148-FIX5 - FIM
       update lrp;
       
       //PLV-4148-FIX5 - INICIO
       Requisicao_de_Pagamento__c lrp1 = [SELECT Id, Status__c FROM Requisicao_de_Pagamento__c limit 1];
       lrp1.Status__c = 'Enviado p/ Financeiro';
       update lrp1;

        try{
            Requisicao_de_Pagamento__c lrp2 = [SELECT Id, Status__c FROM Requisicao_de_Pagamento__c limit 1];
            lrp2.Status__c = 'Cancelado';
            lrp2.Motivo_Cancelamento__c = 'teste';
            lrp2.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 20.13;
            update lrp2; 
        }catch(DmlException e){
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , 
                                e.getDmlStatusCode(0) );
        }     
      
       //PLV-4148-FIX5 - FIM
        
       Test.stoptest();
       //PLV-3918-FIX3 - FIM
         
    }
    
    @isTest
    public static void cancelarPagamentoSinistro(){
       //PLV-3918-FIX3 - INICIO
       Test.startTest();
       Requisicao_de_Pagamento__c lrp = [SELECT Id, Status__c  FROM Requisicao_de_Pagamento__c limit 1];
       lrp.Motivo_Cancelamento__c = 'motivo cancelado....';
       //PLV-4148-FIX1 - INICIO
       lrp.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 1;
       //PLV-4148-FIX1 - FIM
       lrp.Status__c = 'Cancelado';
       update lrp;
     
       Test.stoptest();
       //PLV-3918-FIX3 - FIM
        
              
         
    }
    //PLV-4148 - INICIO
     @isTest
    public static void enviaRequsicaopagamentoSAP(){
       //PLV-3918-FIX3 - INICIO
       Fatura__c fatura = [SELECT Id FROM Fatura__c LIMIT 1];
       Modalidade__c modalidade = [SELECT Id FROM Modalidade__c LIMIT 1];
       Contract contrato = [SELECT Id FROM Contract LIMIT 1];
       contrato.Origem__c = '018';
       contrato.ModalidadeSeguro__c = modalidade.Id;
       //contrato.Sucursal__c = '';
       update contrato;
       Account conta = [SELECT Id FROM Account LIMIT 1];
       Endereco__c endereco = new Endereco__c();
       endereco.Pais__c = 'BR';
       endereco.Estado__c = 'SP';
       endereco.Logradouro__c = 'rua nossa';
       endereco.CEP__c = '06414-000';
       endereco.Cidade__c = 'Barueri';
       endereco.Conta__c = conta.Id;
       insert endereco;
       
        
        
       Test.startTest();
       Requisicao_de_Pagamento__c r = [SELECT Id, Status__c  FROM Requisicao_de_Pagamento__c limit 1];
       r.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 1;
       r.Status__c = 'Enviar p/ Tesouraria';
       r.Fatura__c = fatura.Id;
       r.Nota_fiscal__c = null;
       r.Valor_Total_Prestadora__c = 10;
       r.Tipo_moeda__c = 'USD';
       r.Numero_OP_SAP__c = null;
       r.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Requisicao_de_Pagamento__c', 'Indenizacao_de_sinistros').Id;
       update r;
        
     
        
       Requisicao_de_Pagamento__c lrp = [SELECT Id, Status__c  FROM Requisicao_de_Pagamento__c limit 1];
       lrp.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 1;
       lrp.Status__c = 'Enviar para Registro Financeiro';
       lrp.Fatura__c = fatura.Id;
       lrp.Nota_fiscal__c = null;
       lrp.Valor_Total_Prestadora__c = 10;
       lrp.Tipo_moeda__c = 'USD';
       lrp.Numero_OP_SAP__c = null;
       lrp.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Requisicao_de_Pagamento__c', 'Indenizacao_de_sinistros').Id;
       update lrp;
     
       Test.stoptest();
       //PLV-3918-FIX3 - FIM
        
              
         
    }
    //PLV-4148-FIM
    
    //PLV-4148-FI2 - INICIO
    public static testMethod void enviaRequsicaoCriacao(){
        
        //PLV-4148-FIX4 - INICIO
        //User u3 = [SELECT Id FROM User WHERE Name='Integração Porto Seguro'];
        //System.RunAs(u3){
            
            try{
                Requisicao_de_Pagamento__c r = [SELECT Id, Status__c  FROM Requisicao_de_Pagamento__c limit 1];
                r.Valor_da_Cotacao_de_Moeda_Estrangeira__c = 1;
                r.Status__c = 'OP Em criação';
               
                update r;
            }catch(DmlException e){
                  System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , 
                                 e.getDmlStatusCode(0) );
            }
            
          
        //}
        //PLV-4148-FIX4 - FIM
                  
         
    }
    //PLV-4148-FIX2 - FIM
    
    //PLV-4604 - INICIO
    @isTest
    public static void despesasSinistrosNaoTributaveis(){
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
        String mock = '[{"idconta": "0011F000009D3eOQAS", "cnpjcpf": null, "tipoconta": null,'+
        '"valorpagamento": "2000.00000", "status": "PENDENTE", "datapagamento": "2019-01-24T00:00:00.000Z",'+
        '"dataprogramadapagamento": "2019-01-25T00:00:00.000Z","tipopagamento": "SINISTRO",'+
        '"idobjeto": "5003F000004yoRmQAI","matricula": null,"codigoexcecao": null,"descricaoexcecao": null,'+
        '"valorbruto": null,"tributacao": null,"tiporemuneracao": null,"datacancelamento": null,'+
        '"motivo": "pagou atrasado","descricao": null,"susepcorretor": null,'+
        '"dataatualizacao": "2019-01-31T00:00:00.000Z"}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 200, 'OK'));
        Test.startTest();
        insert requisicao;
        requisicao.Valor_Total_Prestadora__c = 17000;
        update requisicao;
        List<MovimentoSinistro__c> lstMovimento = [SELECT Id FROM MovimentoSinistro__c WHERE Caso__c =: caso.Id];
        System.assertEquals(lstMovimento.size(), 2);
        requisicao.Data_Programada_de_Pagamento__c = Date.today().addDays(2);
        requisicao.Status__c = 'Enviar p/ Financeiro';
        update requisicao;
        Pagamento_de_Sinistro__c pagamento = [SELECT Id, Status__c FROM Pagamento_de_Sinistro__c WHERE Requisicao_de_Pagamento__c =: requisicao.Id];
        pagamento.OP_SAP__c = '1234';
        update pagamento;
        requisicao = [SELECT Id, Name, Numero_OP_SAP__c FROM Requisicao_de_Pagamento__c WHERE Id =: requisicao.Id];
        System.assertEquals(requisicao.Numero_OP_SAP__c, pagamento.OP_SAP__c);
        Test.stopTest();
    }

    @isTest
    public static void despesasSinistrosNaoTributaveisCancelamento(){
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
        insert requisicao;
        requisicao.Status__c = 'Cancelado';
        requisicao.Motivo_Cancelamento__c = 'Teste';
        update requisicao;
        List<MovimentoSinistro__c> lstMovimento = [SELECT Id FROM MovimentoSinistro__c WHERE Caso__c =: caso.Id];
        System.assertEquals(lstMovimento.size(), 2);
        Test.stopTest();
    }

    @isTest
    public static void despesasSinistrosTributaveis(){
        Case caso = [SELECT Id FROM Case WHERE RecordType.Name = 'Sinistro' LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Requisicao_de_Pagamento__c requisicao = new Requisicao_de_Pagamento__c(
            Contas_de_Parceiro__c = conta.Id,
            Numero_do_Sinistro__c = caso.Id,
            RecordTypeId = Schema.SObjectType.Requisicao_de_Pagamento__c.getRecordTypeInfosByDeveloperName().get('Despesas_com_Sinistros_Tributaveis').getRecordTypeId(),
            Status__c = 'Pendente',
            Valor_Total_Prestadora__c = 16000,
            Tipo_de_pagamento__c = 'Honorários com Perito (OP Tributável)'
        );
        NotaFiscal__c nota = [SELECT Id, Name FROM NotaFiscal__c LIMIT 1];
        String mock = '[{"idconta": "0011F000009D3eOQAS", "cnpjcpf": null, "tipoconta": null,'+
        '"valorpagamento": "2000.00000", "status": "PENDENTE", "datapagamento": "2019-01-24T00:00:00.000Z",'+
        '"dataprogramadapagamento": "2019-01-25T00:00:00.000Z","tipopagamento": "SINISTRO",'+
        '"idobjeto": "5003F000004yoRmQAI","matricula": null,"codigoexcecao": null,"descricaoexcecao": null,'+
        '"valorbruto": null,"tributacao": null,"tiporemuneracao": null,"datacancelamento": null,'+
        '"motivo": "pagou atrasado","descricao": null,"susepcorretor": null,'+
        '"dataatualizacao": "2019-01-31T00:00:00.000Z"}]';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(mock), 200, 'OK'));
        Test.startTest();
        insert requisicao;
        requisicao.Nota_Fiscal__c = nota.Id;
        requisicao.Data_Programada_de_Pagamento__c = Date.today().addDays(2);
        requisicao.Status__c = 'Enviar p/ Financeiro';
        update requisicao;
        Test.stopTest();
    }
    //PLV-4604 - FIM
}