@isTest
public class ApoliceVigenteTest {
    @testSetup
    public static void setupUnit(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
	    ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
	    Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(conta, formaPagamento).createRecord();
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(conta, produtoComercial, parceiro).createRecord();
        
        ProdutoParceiro__c produtoParceiro = TestDataFactory.gerarProdutoParceiro(parceiro, produtoComercial);
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        contratante.Numero__c = 123;
        //PLV-3392 - INICIO
        contratante.IOF__c = 10;
        contratante.Contrato__c = contrato.Id;
        //PLV-3392 - FIM
        update contratante;
        
	    GrupoContrato__c grupo = (GrupoContrato__c) new GrupoFactory(contratante).createRecord();
        grupo.Numero__c = 123;
        update grupo;
        
	    SeguradoContrato__c segurado = (SeguradoContrato__c) new SeguradoContratoFactory(conta, grupo).createRecord();
        segurado.Numero__c = 123;
        update segurado;
        
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();
     	
       	contrato.Empresa__c = '1';
        contrato.Sucursal__c = '1';
        contrato.NumeroApolice__c = '12345';
        contrato.Endosso__c = '0';
        contrato.VigenciaFinal__c = contrato.StartDate.addMonths(3);  
        contrato.MeioComercializacao__c = 'ARQ';
        contrato.Proposta__c = proposta.Id;
        contrato.RamoSeguro__c = ramoSeguro.Id;
        contrato.Status = 'Emitido';
        contrato.PremioTotal__c = -600; //PLV-4588 INICIO/FIM
        update contrato;
    }
    
	@isTest
    public static void testUnitSuccess(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta sucesso ----> ' + jsonResposta);
    }

	//PLV-3866 - INICIO
	@isTest
    public static void testUnitErroData(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        busca.buscaSegurados.dataOcorrencia = '02-02-2020';

        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta sucesso ----> ' + jsonResposta);
    }
	//PLV-3866 - FIM

	//PLV-3866 - INICIO
	@isTest
    public static void testUnitSuccessSeguradoNaoEncontrado(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        //PLV-3866 - INICIO FIX1
        busca.buscaSegurados.dataOcorrencia = '2018-01-01';
		//PLV-3866 - FIM FIX1
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta sucesso ----> ' + jsonResposta);
    }
	//PLV-3866 - FIM
	
    //PLV-3866 - INICIO FIX1
	@isTest
    public static void testUnitSuccessDataFutura(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        //PLV-3866 - INICIO FIX1
        date dtfutura = system.today().addDays(1);
        busca.buscaSegurados.dataOcorrencia = String.valueOf(dtfutura);
		//PLV-3866 - FIM FIX1
        String jsonParam = JSON.serializePretty(busca);
        System.debug('testUnitSuccessDataFutura param ' + jsonParam);
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('testUnitSuccessDataFutura ----> ' + jsonResposta);
    }
    @isTest
    public static void testUnitError4(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        
        //Deixar atributos estratégicos vazios para aumentar cobertura da classe
        busca.buscaSegurados.idSeguro = '';
        busca.buscaSegurados.empresa = '';
        busca.buscaSegurados.origem = '';
        busca.buscaSegurados.numeroCpf = '123456789';
        busca.buscaSegurados.digitoCpf = '10';
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta erro ----> ' + jsonResposta);
    }
    @isTest
    public static void nomeClinte(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        
        //Deixar atributos estratégicos vazios para aumentar cobertura da classe
        busca.buscaSegurados.idSeguro = '';
        busca.buscaSegurados.empresa = '';
        busca.buscaSegurados.origem = '';
        busca.buscaSegurados.numeroCpf = '';
        busca.buscaSegurados.digitoCpf = '';
        busca.buscaSegurados.nome = 'santos';
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta erro ----> ' + jsonResposta);
    }
     @isTest
    public static void prestadorProduto(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        
        //Deixar atributos estratégicos vazios para aumentar cobertura da classe
        busca.buscaSegurados.idSeguro = '';
        busca.buscaSegurados.empresa = '';
        busca.buscaSegurados.origem = '';
        busca.buscaSegurados.numeroCpf = '';
        busca.buscaSegurados.digitoCpf = '';
        busca.buscaSegurados.nome = '';
        busca.buscaSegurados.prestador = 'ASSISTCARD';
        busca.buscaSegurados.produto = 'VIAGEM';
        busca.buscaSegurados.plano = '';
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta erro ----> ' + jsonResposta);
    }
    //PLV-3866 - FIM FIX1
    
    
    //PLV-3392 - INICIO
    @isTest
    public static void testCreatIntegration82(){
        Contract contratoTest = [SELECT Id, NumeroApolice__c, PremioTotal__c FROM Contract WHERE NumeroApolice__c = '12345' LIMIT 1]; //PLV-4588 INICIO/FIM
        List<ControleIntegracao__c> lstControleIntegracao = [
			SELECT Id, CodigoIntegracao__c, IdObjeto__c 
			FROM ControleIntegracao__c 
			WHERE IdObjeto__c =: contratoTest.Id 
			AND CodigoIntegracao__c = '82'];
		System.assert(!lstControleIntegracao.isEmpty());
    }

    //PLV-3392-FIX2 - Trecho removido
    /*@isTest
    public static void testUpdateIOF(){
        Contract contratoTest = [SELECT Id, ValorIOF__c FROM Contract WHERE NumeroApolice__c = '12345' LIMIT 1];
        System.assert(contratoTest.ValorIOF__c == 10);

    }*/
    //PLV-3392 - FIM
    
    @isTest
    public static void testUnitError(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        
        //Deixar atributos estratégicos vazios para aumentar cobertura da classe
        busca.buscaSegurados.empresa = '';
        busca.buscaSegurados.origem = '';
        busca.buscaSegurados.numeroCpf = '';
        busca.buscaSegurados.nome = '';
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta erro ----> ' + jsonResposta);
    }
    @isTest
    public static void testUnitError2(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        
        //Alterar valor de atributo "prestador" para aumentar cobertura da classe
        busca.buscaSegurados.prestador = '';
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta erro ----> ' + jsonResposta);
    }
    
    @isTest
    public static void testUnitError3(){
        ApoliceVigente.BuscaRequest busca = setJsonObject();
        
        //Deixar atributos estratégicos vazios para aumentar cobertura da classe
        busca.buscaSegurados.idSeguro = 
        busca.buscaSegurados.empresa = '';
        busca.buscaSegurados.origem = '';
        busca.buscaSegurados.numeroCpf = '';
        busca.buscaSegurados.nome = '';
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta erro ----> ' + jsonResposta);
    }
    
    
    
    public static ApoliceVigente.BuscaRequest setJsonObject(){
		Account conta = [SELECT Cpf__c, Name FROM Account Limit 1];
        Contract contrato = [SELECT Produto__r.ProductCode,
                             		Parceria__r.SiglaParceiro__c,
                             		Produto__r.ProdutoTecnico__r.ProductCode,
                             		Empresa__c,
                             		Sucursal__c,
                             		Endosso__c,
                             		Proposta__r.Origem__c,
                             		Proposta__r.NumeroProposta__c,
                             		NumeroApolice__c,
                             		StartDate,
                             		VigenciaFinal__c,
                             		RamoSeguro__r.Codigo__c
                             FROM Contract LIMIT 1];
        
        ApoliceVigente.BuscaRequest busca = new ApoliceVigente.BuscaRequest();
       	busca.buscaSegurados = new ApoliceVigente.BuscaSegurado();
        
        busca.buscaSegurados.prestador = contrato.Parceria__r.SiglaParceiro__c;
        busca.buscaSegurados.idSeguro = contrato.Empresa__c + '-' +
            							contrato.Sucursal__c + '-' +
            							contrato.RamoSeguro__r.Codigo__c + '-' +
            							contrato.Numeroapolice__c + '-' +
                            			contrato.Endosso__c;
        busca.buscaSegurados.produto = contrato.Produto__r.ProdutoTecnico__r.ProductCode;
        busca.buscaSegurados.ramo = contrato.RamoSeguro__r.Codigo__c;
        busca.buscaSegurados.empresa = contrato.Empresa__c;
        busca.buscaSegurados.apolice = contrato.NumeroApolice__c;
        busca.buscaSegurados.sucursal = contrato.Sucursal__c;
        busca.buscaSegurados.endosso = contrato.Endosso__c;
        busca.buscaSegurados.proposta = contrato.Proposta__r.NumeroProposta__c;
        busca.buscaSegurados.origem = contrato.Proposta__r.Origem__c;
        busca.buscaSegurados.dataOcorrencia = String.valueOf(contrato.StartDate.addDays(10));
        busca.buscaSegurados.plano = contrato.Produto__r.ProductCode;
        busca.buscaSegurados.nome = conta.Name;
        busca.buscaSegurados.numerocpf = conta.Cpf__c.remove('.').remove('-').left(9);
        busca.buscaSegurados.digitocpf = conta.Cpf__c.remove('.').remove('-').right(2);
        return busca;
    }
    // PLV-3740	#Inicio - Responsável pelo teste da classe ApoliceVigente
    @isTest
    public static void testUnitSuccess2(){
        Contract contrato = [Select Id, VigenciaFinal__c FROM Contract LIMIT 1];             	
        contrato.VigenciaFinal__c = System.today(); 
        ProdutoParceiro__c prodParceiro = [Select Id, Parceiro__c, Produto__c, CodigoProdutoParceiro__c FROM ProdutoParceiro__c limit 1];
        Parceiro__c parceiro = [Select Id, Name, SiglaParceiro__c FROM Parceiro__c WHERE id =: prodParceiro.Parceiro__c];
        Product2 produto = [Select Id, Name, ProductCode, ProdutoTecnico__c FROM Product2 WHERE id =: prodParceiro.Produto__c];
        Product2 produtotecnico = [Select Id, Name, ProductCode FROM Product2 WHERE id =: produto.ProdutoTecnico__c];
        parceiro.SiglaParceiro__c = 'ASSISTCARD';
        update parceiro;
        insert new Prestadores__c(Name= 'ASSISTCARD');
        System.debug('prestador ' + Prestadores__c.getAll());
        // contrato.Empresa__c = '1';
        // contrato.Sucursal__c = '1';
        // contrato.NumeroApolice__c = '12345';
        // contrato.Endosso__c = '0';
        // contrato.MeioComercializacao__c = 'ARQ';
        // contrato.Proposta__c = proposta.Id;
        // contrato.RamoSeguro__c = ramoSeguro.Id;
        // contrato.Status = 'Emitido';
        update contrato;

        ApoliceVigente.BuscaRequest busca = setJsonObject2();
        
        String jsonParam = JSON.serializePretty(busca);
        
        RestResponse res = new RestResponse();
	    RestRequest request = new RestRequest();
	    request.requestUri ='/services/apexrest/consultaseguros/';
	    request.httpMethod = 'POST';
	    request.requestBody = Blob.valueOf(jsonParam);
	    RestContext.response = res;
	    RestContext.request = request;

	    Test.startTest();
	    	ApoliceVigente.apoliceVigente();
	    Test.stopTest();

		String jsonResposta = RestContext.response.responseBody.toString();
	    System.debug('jsonResposta sucesso ----> ' + jsonResposta);
    }
    
    public static ApoliceVigente.BuscaRequest setJsonObject2(){
		Account conta = [SELECT Cpf__c, Name FROM Account Limit 1];
        Contract contrato = [SELECT Produto__r.ProductCode,
                             		Parceria__r.SiglaParceiro__c,
                             		Produto__r.ProdutoTecnico__r.ProductCode,
                             		Empresa__c,
                             		Sucursal__c,
                             		Endosso__c,
                             		Proposta__r.Origem__c,
                             		Proposta__r.NumeroProposta__c,
                             		NumeroApolice__c,
                             		StartDate,
                             		VigenciaFinal__c,
                             		RamoSeguro__r.Codigo__c
                             FROM Contract LIMIT 1];
        
        ApoliceVigente.BuscaRequest busca = new ApoliceVigente.BuscaRequest();
       	busca.buscaSegurados = new ApoliceVigente.BuscaSegurado();
        
        busca.buscaSegurados.prestador = 'ASSISTCARD';
        busca.buscaSegurados.idSeguro = contrato.Empresa__c + '-' +
            							contrato.Sucursal__c + '-' +
            							contrato.RamoSeguro__r.Codigo__c + '-' +
            							contrato.Numeroapolice__c + '-' +
                            			contrato.Endosso__c;
        busca.buscaSegurados.produto = contrato.Produto__r.ProdutoTecnico__r.ProductCode;
        busca.buscaSegurados.ramo = contrato.RamoSeguro__r.Codigo__c;
        busca.buscaSegurados.empresa = contrato.Empresa__c;
        busca.buscaSegurados.apolice = contrato.NumeroApolice__c;
        busca.buscaSegurados.sucursal = contrato.Sucursal__c;
        busca.buscaSegurados.endosso = contrato.Endosso__c;
        busca.buscaSegurados.proposta = contrato.Proposta__r.NumeroProposta__c;
        busca.buscaSegurados.origem = contrato.Proposta__r.Origem__c;
        busca.buscaSegurados.dataOcorrencia = String.valueOf(System.today());
        busca.buscaSegurados.plano = contrato.Produto__r.ProductCode;
        busca.buscaSegurados.nome = conta.Name;
        busca.buscaSegurados.numerocpf = conta.Cpf__c.remove('.').remove('-').left(9);
        busca.buscaSegurados.digitocpf = conta.Cpf__c.remove('.').remove('-').right(2);
        return busca;
    }

    // PLV-3740	# Fim
    
  
}