//II-154 INICIO
@isTest
global class DocumentAPITest{
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
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            Contract contract = [SELECT Id from Contract LIMIT 1];
            
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Apolice',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            DocumentAPI.mockedRequests.add(mockedRequest); //MGRC-505 INICIO/FIM
            
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.mockjson = '{"ticket":"123456"}';  //MGRC-505 INICIO/FIM
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2/teste'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
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
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            Contract contract = [SELECT Id from Contract LIMIT 1];
            
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Boleto',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            DocumentAPI.mockedRequests.add(mockedRequest);//MGRC-505 INICIO/FIM
            
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.mockjson = '{"ticket":"123456"}';   //MGRC-505 INICIO/FIM
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
    }
    //II-154 INICIO/FIM
    @isTest
    static void buscaECMSucessoProposta (){
        Boolean success = true;
        try{
            Test.startTest();
            
            CryptoToken token = new CryptoToken();
            
            String identificador = token.encrypt(contract.Id+'|Proposta_');
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            Contract contract = [SELECT Id from Contract LIMIT 1];
            
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Proposta_',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            DocumentAPI.mockedRequests.add(mockedRequest); //MGRC-505 INICIO/FIM
            
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.mockjson = '{"ticket":"123456"}';  //MGRC-505 INICIO/FIM
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2/teste'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
    }
    //II-154 FIM

    @isTest
    static void buscaECMSucessoEndosso (){
        Boolean success = true;
        try{
            Test.startTest();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            CryptoToken token = new CryptoToken();
            
            String identificador = token.encrypt(contract.Id+'|Endosso');
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='Endosso',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            //DocumentAPI.mockedRequests.add(mockedRequest); //MGRC-505 INICIO/FIM
            
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.mockjson = '{"ticket":"123456"}';  //MGRC-505 INICIO/FIM
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
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
            
            DocumentAPI.validaToken tk = new DocumentAPI.validaToken(); //MGRC-505 INICIO/FIM
            tk.descript(identificador);
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
           
            public_arquivoecm__x mockedRequest = new public_arquivoecm__x(
                nomearquivo__c='TestFile',
                idecm__c='123',
                status__c='CRIADO',
                idsf__c=contract.Id
            );
            DocumentAPI.mockedRequests.add(mockedRequest); //MGRC-505 INICIO/FIM
            
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
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
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
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
            DocumentAPI.validaToken tk = new DocumentAPI.validaToken(); //MGRC-505 INICIO/FIM
            tk.descript(identificador);
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            DocumentAPI.mockedRequests = new List<public_arquivoecm__x>(); //MGRC-505 INICIO/FIM
            DocumentAPI.mockContrato =  [SELECT Id from Contract LIMIT 1]; //MGRC-505 INICIO/FIM
            
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());  
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
             
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
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
            DocumentAPI.validaToken tk = new DocumentAPI.validaToken(); //MGRC-505 INICIO/FIM
            tk.descript(identificador);
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            DocumentAPI.mockedRequests = new List<public_arquivoecm__x>(); //MGRC-505 INICIO/FIM
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
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
            
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
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
            DocumentAPI.validaToken tk = new DocumentAPI.validaToken(); //MGRC-505 INICIO/FIM
            tk.descript(identificador);
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            DocumentAPI.mockedRequests = new List<public_arquivoecm__x>(); //MGRC-505 INICIO/FIM
            //DocumentAPI.mockProposta =  [SELECT Id from Quote LIMIT 1]; //MGRC-505 INICIO/FIM
            
            DocumentAPI.retornoECMArquivo rt = new DocumentAPI.retornoECMArquivo(); //MGRC-505 INICIO/FIM
            rt.ticket = '123456';
            rt.error = 'arro';
            rt.sucesso = 'sucesso';
            
            DocumentAPI.returnHTML ht = new  DocumentAPI.returnHTML(); //MGRC-505 INICIO/FIM
            ht.htmlToken = 'teste koten';
            ht.htmlAuth = 'teste auth';
            ht.htmlFile = 'teste file';
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }    
        
    //II-154 INICIO
    }
    @isTest
    static void erroSFApoliceVoucherViagem(){
        boolean success = true;
        try{
            Test.startTest();
            CryptoToken token = new CryptoToken();
            Contract contract = [SELECT Id from Contract LIMIT 1];
            String identificador = token.encrypt(contract.Id+'|vouchera_police_VIAGEM_ORC');
            
            DocumentAPI.validaToken tk = new DocumentAPI.validaToken(); //MGRC-505 INICIO/FIM
            tk.descript(identificador);
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            DocumentAPI.mockedRequests = new List<public_arquivoecm__x>(); //MGRC-505 INICIO/FIM
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
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
            
            DocumentAPI.validaToken tk = new DocumentAPI.validaToken(); //MGRC-505 INICIO/FIM
            tk.descript(identificador);
            
            DocumentAPI.mockIdentificador = identificador; //MGRC-505 INICIO/FIM
            
            DocumentAPI.mockedRequests = new List<public_arquivoecm__x>(); //MGRC-505 INICIO/FIM
            
            
            Test.setMock(HttpCalloutMock.class, new ServiceRestTestMock.ServiceRestTestMockSF());
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/DocumentAPI/v2'; //MGRC-505 INICIO/FIM
            req.httpMethod = 'GET';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            DocumentAPI.doGet(); //MGRC-505 INICIO/FIM
            Test.stopTest();
        }catch(Exception e){
            success = false;
        }         
    }
    //II-154 FIM

}
//II-154 FIM