//II-154 INICIO
@isTest
global class DocumentAPIV2Test{
    @testSetup static void setup() {
        Account contaFisica = (Account) new AccountFactory.PessoaFisica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaFisica, formaPagamento).createRecord();

        //ANNVI-118 INICIO
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, contaFisica).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(contaFisica).createRecord();
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(contaFisica).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, contaFisica, dadosCorretor, orcamento, modalidade).createRecord();
        //ANNVI-118 FIM

        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaFisica, produtoComercial, parceiro).createRecord();
        ContratanteContrato__c contratanteContrato = new ContratanteContrato__c(Contrato__c = contrato.Id, Conta__c = contaFisica.Id, Tipo__c = 'Principal'); 
        insert contratanteContrato;
        SenhaCriptografia__c sCripto = new SenhaCriptografia__c();
        sCripto.Name = 'Senha';
        sCripto.Senha__c = 'TesteCrypto';
        insert sCripto;
    }
    
    @isTest
    static void buscaECMSucessoApolice (){
        Boolean success = true;
        try{
            Test.startTest();
            
            CryptoToken token = new CryptoToken();
            
            String identificador = token.encrypt(contract.Id+'|Apolice');
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            Contract contract = [SELECT Id from Contract LIMIT 1];
            
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Apolice',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            DocumentAPIV2.mockedRequests.add(mockedRequest);  
            
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.mockjson = '{"ticket":"123456"}';   
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2/teste';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
    }
    
    @isTest
    static void buscaECMSucessoBoleto (){
        Boolean success = true;
        try{
            Test.startTest();
            
            CryptoToken token = new CryptoToken();
            
            String identificador = token.encrypt(contract.Id+'|Boleto');
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            Contract contract = [SELECT Id from Contract LIMIT 1];
            
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Boleto',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            DocumentAPIV2.mockedRequests.add(mockedRequest);//MGRC-505 INICIO/FIM
            
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.mockjson = '{"ticket":"123456"}';    
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
    }

    //ANNVI-118 INICIO
    @isTest
    static void buscaECMSucessoProposta (){
        Boolean success = true;
        try{
            Test.startTest();
            
            CryptoToken token = new CryptoToken();

            Quote proposta = [SELECT Id from Quote LIMIT 1];
            
            String identificador = token.encrypt(proposta.Id+'|Proposta_2021_3_3_17_32_36.pdf');
            
            DocumentAPIV2.mockIdentificador = identificador;  
                        
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Proposta_2021_3_3_17_32_36.pdf',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=proposta.Id
            );
            DocumentAPIV2.mockedRequests.add(mockedRequest);//MGRC-505 INICIO/FIM
            
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.mockjson = '{"ticket":"123456"}';    
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
    }

    @isTest
    static void erroSFApoliceVoucherVidaIndividual(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|vouchera_police_VI_ORC');
            
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            DocumentAPIV2.mockedRequests = new List<public_arquivoecm__x>();  
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }     
    }
    //ANNVI-118 FIM
    
    @isTest
    static void buscaECMSucessoEndosso (){
        Boolean success = true;
        try{
            Test.startTest();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            CryptoToken token = new CryptoToken();
            
            String identificador = token.encrypt(contract.Id+'|Endosso');
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Endosso',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            //DocumentAPIV2.mockedRequests.add(mockedRequest);  
            
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.mockjson = '{"ticket":"123456"}';   
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
    }
    
    @isTest
    static void buscaECMErro(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|Apolice_1_1_1369_000003402_0');
            
            //String identificador = 'cXvn9IzQVd192vaNKSqI0kWsD3CJTG8yrRVTLmu9EaZFAl9IuQFica+CsrK2ui9qYV/7er3MpF5Tdk5dLkc+mw==';
            
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
           
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='TestFile',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            DocumentAPIV2.mockedRequests.add(mockedRequest);  
            
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockECMErro());  
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }     
    }
    
    @isTest
    static void buscaSFSucesso(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            //String identificador = token.encrypt('800L0000002OlERIA0|Apolice_1_1_1369_000003402_0');
            String identificador = token.encrypt(contract.Id+'|Apolice_1-1-1369-002351106-0.pdf');
            
            //String identificador = 'cXvn9IzQVd192vaNKSqI0kWsD3CJTG8yrRVTLmu9EaZFAl9IuQFica+CsrK2ui9qYV/7er3MpF5Tdk5dLkc+mw==';
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            DocumentAPIV2.mockedRequests = new List<public_arquivoecm__x>();  
            DocumentAPIV2.mockContrato =  [SELECT Id from Contract LIMIT 1];  
            
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());  
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
             
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
    }
    
    @isTest
    static void buscaSFErro(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|Apolice_1_1_1369_000003402_0');
            //String identificador = 'cXvn9IzQVd192vaNKSqI0kWsD3CJTG8yrRVTLmu9EaZFAl9IuQFica+CsrK2ui9qYV/7er3MpF5Tdk5dLkc+mw==';
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            DocumentAPIV2.mockedRequests = new List<public_arquivoecm__x>();  
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSFErro()); 
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }     
    }
    
    @isTest
    static void buscaSFSucessoVoucher(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|Voucher_18_00022084');
            //String identificador = 'MprE8uOXOj7Hivlm3gwN23MIKZuyT9y1mIoXrnleVLxlKs6njeGc1bBOb8nuEpsI1lgQJrjQEtgL9pbyngdbZA==';
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            DocumentAPIV2.mockedRequests = new List<public_arquivoecm__x>();  
            //DocumentAPIV2.mockProposta =  [SELECT Id from Quote LIMIT 1];  
            
            DocumentAPIV2.retornoECMArquivo rt = new DocumentAPIV2.retornoECMArquivo();  
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPIV2.returnHTML ht = new  DocumentAPIV2.returnHTML();  
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }        
    }
    @isTest
    static void erroSFApoliceVoucher(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|voucherapolice');
            
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            DocumentAPIV2.mockedRequests = new List<public_arquivoecm__x>();  
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }      
    }

    @isTest
    static void erroSFApoliceVoucherViagem(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|vouchera_police_VIAGEM_ORC');
            
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            DocumentAPIV2.mockedRequests = new List<public_arquivoecm__x>();  
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPIV2.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }     
    }

    @isTest
    static void erroSFApoliceVoucherVI(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|vouchera_police_VI_ORC');
            
            DocumentAPIV2.validaToken tk = new DocumentAPIV2.validaToken();  
            tk.descript(identificador);
            
            DocumentAPIV2.mockIdentificador = identificador;  
            
            DocumentAPIV2.mockedRequests = new List<public_arquivoecm__x>();  
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2';  
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPI.doGet();  
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }     
    }
}
//II-154 FIM