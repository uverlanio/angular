//PLV - 4572 GUSTAVO DA SILVA PEREIRA SYS4B - INICIO
@IsTest
public class BoletoComponenteControllerTest {
    
    @TestSetup
    static void setup(){
        
        
        Account contaPessoal = (Account) new AccountFactory.PessoaFisica().createRecord();
        
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        
        FormaPagamento__c formaPagamento = (FormaPagamento__c) new FormaPagamentoFactory().createRecord();
        Parceiro__c parceiro = (Parceiro__c) new ParceiroFactory(contaPessoal, formaPagamento).createRecord();
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Contract contrato = (Contract) new ContratoFactory.ContratoFactoryComParam(contaPessoal, produtoComercial, parceiro).createRecord();
        
        ContratanteContrato__c contratante = (ContratanteContrato__c) new ContratanteFactory(contrato).createRecord();
        
    }
    
    @IsTest
    static void TestPass(){
        
        ContratanteContrato__c contratanteContrato = [SELECT Id, Contrato__c FROM ContratanteContrato__c limit 1];
        
        Test.startTest();
        BoletoComponenteController.BoletoToComponent(contratanteContrato.Id);
        Test.stopTest();
        
    }
    
}
//PLV - 4572 GUSTAVO DA SILVA PEREIRA SYS4B - FIM