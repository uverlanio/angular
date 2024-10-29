/*******************************************************************************************************************************
* Consulta dados Básicos de Apólice/Contrato
* @author Gabriel Roetger- Globant
* @date 20/07/2020
* Classe criada por conta da história PLV-3967
******************************************************************************************************************************/
@isTest
public class ConsultaSinistroTest  {
    public static RestRequest request = new RestRequest();
    
    
    @testSetup
    static void makeData(){        
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();

        Contract contrato = (Contract) new ContratoFactory.ContratoFactorySemParam(conta).createRecord();
        contrato.IdExterno__c = '1-1-9999-999999999-0';
        update contrato;
        
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case casoSinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, conta).createRecord();
        casoSinistro.Contrato__c = contrato.id;
        casoSinistro.NumeroSinistro__c = '123456-teste';
        casoSinistro.Type = 'Sinistro';
        update casoSinistro;
        
        insert new CaseComment(CommentBody = 'test',ParentId = casoSinistro.id);
        
        GarantiaSeguradoContrato__c garantiaSeguradoContrato = (GarantiaSeguradoContrato__c) new GarantiaSeguradoContratoFactory().createRecord();

        PagamentoGarantia__c pagamentoGarantia = (PagamentoGarantia__c) new PagamentoGarantiaFactory(casoSinistro, garantiaSeguradoContrato).createRecord();
        PagamentoGarantia__c pagamentoGarantiaClone = pagamentoGarantia.clone(false, false, false, false);
       	insert pagamentoGarantiaClone;
        
        //PLV-4363 - INICIO
        Banco__c banconew = new Banco__c();
        banconew.CodigoBanco__c = '341';
        banconew.ConveniadoADC__c  = false;
        banconew.Name = 'BANCO ITAU S/A';
        banconew.Ativo__c = true;
        insert banconew; 
        //PLV-4363 - FIM
        
        InformacaoBancaria__c beneConta = new InformacaoBancaria__c(
            Papel__c = 'Parceiro', 
            Banco__c = '341',
            Agencia__c = '2332', 
            NumeroConta__c = '1234545',
            BancoNew__c = banconew.Id, //PLV-4363 - INICIO/FIM
            Conta__c = conta.Id
        );
        
        insert beneConta;
        Pagamento_de_sinistro__c pagSinistro = new Pagamento_de_sinistro__c();
       
        pagSinistro.Caso_de_Sinistro__c = casoSinistro.Id;
        pagSinistro.Dados_Bancarios__c = beneConta.Id;       
        pagSinistro.Data_Programada_de_Pagamento__c = Date.today();
        
		insert pagSinistro; 
        
        BeneficiarioGarantia__c beneficiario = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica(conta, beneConta, pagamentoGarantia).createRecord();
        beneficiario.Pagamento_de_Sinistro__c = pagSinistro.Id; 
        update beneficiario;
    }
    
    @isTest 
    public static void consultarTest_semParam(){        
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        Test.startTest();
        
        ConsultaSinistroRest.consultar();
        
        Test.stopTest();
    } //ok
    
    @isTest 
    public static void consultarTest_paramInexistente(){
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm().toLowercase() + '/services/apexrest/sinistro/buscar';   
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        request.params.put('apolice', '123');
        request.params.put('sinistro', '123');
        
        
        Test.startTest();
        
        ConsultaSinistroRest.consultar();
        
        Test.stopTest();
    } 
    
    @isTest
    public static void consultarTest_Apolice(){
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm().toLowercase() + '/services/apexrest/sinistro/buscar';
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        request.params.put('apolice', '1-1-9999-999999999-0');
        
        Test.startTest();
        
        ConsultaSinistroRest.consultar();
        
        Test.stopTest();
    }
    
    @isTest
    public static void consultarTest_Sinistro(){
        request.requestUri = URL.getSalesforceBaseUrl().toExternalForm().toLowercase() + '/services/apexrest/sinistro/buscar';
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        request.params.put('sinistro', '123456-teste');
        
        Test.startTest();
        
        ConsultaSinistroRest.consultar();
        
        Test.stopTest();
    }
    @isTest
    public static void getBeneficiariosTest(){
        Test.startTest();
        new ConsultaSinistroService('','').getBeneficiarios(new Set<Id>());
        Test.stopTest();
    }
}