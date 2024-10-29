/********************************************************************************************************************
* Proposta de Seguro Viagem Controler Test Class
* @author Edgar Peralta - Globant
* @date 10/09/2020
* Classe criada por conta da história PLV-4345
*********************************************************************************************************************/
@isTest
global with sharing class PropostaSeguroViagemControllerTest {
	
    @testSetup static void setup(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        ContadorCodigo__c contCodigoTec3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom3 = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        produtoTecnico.Segmento__c = 'Viagem';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
         produtoComercial.Segmento__c = 'Viagem';
        update produtoComercial;
        
        RamoSeguro__c ramoSeguro = (RamoSeguro__c) new RamoSeguroFactory(conta).createRecord();
        DadosCorretor__c dadosCorretor = (DadosCorretor__c) new DadosCorretorFactory(conta).createRecord();
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        Modalidade__c modalidade = (Modalidade__c) new ModalidadeFactory(ramoSeguro).createRecord();    
        
        Quote proposta = (Quote) new PropostaFactory(produtoComercial, ramoSeguro, conta, dadosCorretor, orcamento, modalidade).createRecord();


    }
    
    @IsTest
    static void testViagem(){
        Quote quote = [SELECT Id, Name FROM Quote];
        
        Test.StartTest();
        PageReference pageRef = Page.PropostaSeguroViagem;
        pageRef.getParameters().put('numProposta', String.valueOf(quote.Name));
        pageRef.getParameters().put('token', '9823');
        Test.setCurrentPage(pageRef);
        new PropostaSeguroViagemController();
        Test.stopTest();
    }
    
    @IsTest
    static void testNonViagem(){
        Quote quote = [SELECT Id, Name FROM Quote];
        List<Product2> products = [SELECT Segmento__c from Product2];
        for(Product2 product:products){
            product.Segmento__c = 'Individual';
        	Update product;
        }
        
        Test.StartTest();
        PageReference pageRef = Page.PropostaSeguroViagem;
        pageRef.getParameters().put('numProposta', String.valueOf(quote.Name));
        pageRef.getParameters().put('token', '9823');
        Test.setCurrentPage(pageRef);
        try{
            new PropostaSeguroViagemController();
        } catch(Exception e){
            System.assertEquals('Proposta informada não pertence ao segmento Viagem!', e.getMessage());
        }
        Test.stopTest();
    }
}