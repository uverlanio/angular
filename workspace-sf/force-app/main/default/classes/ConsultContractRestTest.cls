/*
* Classe consulta de contratos para sistemas externos
* @author Squad Globant
* @date 02/03/23
* Classe criada por conta da história PLV-5775
*/
@isTest
public class ConsultContractRestTest {

    @TestSetup
    static void createData(){

        Account conta = new Account(
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Account', 'PessoaFisica').Id,
            FirstName = 'FRANCIS',
            LastName = 'LIU',
            Nacionalidade__c = 'Brasileira',
            CPF__c = '518.179.180-87',
            Rg__c = '232323231',
            DataExpedicao__c = Date.today(),
            OrgaoExpedidor__c = '123132',
            PersonBirthDate = (Date.today()-7300),
            EstadoCivil__c = 'Solteiro (a)'
        );
        insert conta;

        DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(conta);
        
        RamoSeguro__c ramoSegurado = TestDataFactory.gerarRamoSeguro(conta);

        Modalidade__c modalidade = TestDataFactory.gerarModalidade(ramoSegurado);
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();

        Product2 produtoTec = new Product2(
            Name = 'Nome Produto Tecnico',
            Status__c = 'Em criação',
            ProductCode = '201700001',
            VigenciaInicial__c = System.today().addDays(3),
            TipoCapital__c = 'Capital uniforme',
            Segmento__c = 'Coletivo',
            TipoResponsavelPagamento__c = 'PAR',
            NumeroSusep__c = '12345',
            RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id,
            Versao__c = 1,
            VersaoMaxima__c = true,
            VersaoRenovacao__c= 'Versão atual'
        );
        insert produtoTec;
        produtoTec.Status__c = 'Ativo';
        update produtoTec;

        Product2 produtoCom = new Product2(
                ProdutoTecnico__c = produtoTec.Id,
                Name = 'Nome Produto Comercial',
                Status__c = 'Em criação',
            	ProductCode = '201700001',            	
                VigenciaInicial__c = System.today(),
                VigenciaFinal__c = System.today().addDays(1),
                TipoCapital__c = 'Capital uniforme',
                Segmento__c = 'Coletivo',
                TipoResponsavelPagamento__c = 'PAR',
                LimiteTotalCarregamento__c = 200,
                NumeroSusep__c = '12345',
                RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id,
                Versao__c = 1,
                VersaoMaxima__c = true,
                VersaoRenovacao__c = 'Versão atual'
        );
        insert produtoCom;
        produtoCom.Status__c = 'Ativo';
        update produtoCom;

        Garantia__c garantia = TestDataFactory.gerarGarantia();

        RamoGarantia__c ramoGarantia = TestDataFactory.gerarRamoGarantia(garantia, ramoSegurado);

        CanalDistribuicao__c canalDistribuicao = TestDataFactory.gerarCanalDistribuicao();
        canalDistribuicao.Status__c = 'Ativo';
        update canalDistribuicao;

        Opportunity opp = TestDataFactory.gerarOrcamentoObjeto(conta, produtoCom, canalDistribuicao);

        Quote cot = TestDataFactory.gerarPropostaObjeto(produtoCom, ramoSegurado, conta, dadosCorretor, opp, modalidade);

        Contract contrato = TestDataFactory.gerarContratoObjeto(produtoCom, ramoSegurado, conta, dadosCorretor, cot);
		contrato.Status = 'Emitido';
        contrato.Origem__c = '18';
        contrato.NumeroProposta__c = '00043752';
        update contrato;

        ContratanteContrato__c contratanteContrato = TestDataFactory.gerarContratanteContrato(contrato, conta, conta);
        GrupoContrato__c grupoContrato = TestDataFactory.gerarGrupoContrato(contratanteContrato);
        SeguradoContrato__c segurado = TestDataFactory.gerarSeguradoContrato(grupoContrato, conta);

        GarantiaProduto__c garantiaTecnica = TestDataFactory.gerarGarantiaProdutoTecnico(produtoTec, garantia, ramoSegurado);
        GarantiaProduto__c garantiaComercial = TestDataFactory.gerarGarantiaProdutoComercial(produtoCom, garantia, garantiaTecnica, ramoSegurado);
        GarantiaContrato__c garantiaContrato = TestDataFactory.gerarGarantiaContrato(contrato, garantiaComercial);

    }

    @isTest
    public static void consultContractWithStatusCanceled_codeErro_0() {


        Contract ctr = [SELECT Id, Status FROM Contract];
        ctr.Status = 'Cancelado';
        update ctr;

        String requestBody = '{'
        + '"nome": "FRANCIS LIU",'
        + '"dataNascimento":"1964-05-22",'
        + '"cpf": "518.179.180-87",'
        + '"cnpj": "",'
        + '"assistencia": "CAP"' 
        + '}';

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        Test.startTest();
        ContractService.Response result = ConsultContractRest.consultarContratosLocalizados();
        Test.stopTest();
       
    }

    @isTest
    public static void consultContractWithStatusIssued_codeErro_0() {

        String requestBody = '{'
        + '"nome": "FRANCIS LIU",'
        + '"dataNascimento":"1964-05-22",'
        + '"cpf": "518.179.180-87",'
        + '"cnpj": "",'
        + '"assistencia": "CAP"' 
        + '}';

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        Test.startTest();
        ContractService.Response result = ConsultContractRest.consultarContratosLocalizados();
        Test.stopTest();
       
    }

    @isTest
    public static void consultContract_codeErro_22() {

        String requestBody = '{'
        + '"nome": "",'
        + '"dataNascimento":"1964-05-22",'
        + '"cpf": "518.179.180-87",'
        + '"cnpj": "",'
        + '"assistencia": "CAP"' 
        + '}';

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        Test.startTest();
        // instanciar nosso response como variavel e chamar o método de dentro da service para realizar a consulta
        ContractService.Response result = ConsultContractRest.consultarContratosLocalizados();
        Test.stopTest();
       
    }

    @isTest
    public static void consultContract_codeErro_10() {

        String requestBody = '{'
        + '"nome": "FRANCIS LIU",'
        + '"dataNascimento":"1964-05-22",'
        + '"cpf": "",'
        + '"cnpj": "",'
        + '"assistencia": "CAP"' 
        + '}';

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        Test.startTest();
        ContractService.Response result = ConsultContractRest.consultarContratosLocalizados();
        Test.stopTest();
       
    }

}