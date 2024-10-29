@isTest
public class RemuneracaoFacadeTest {
	@testSetup
    public static void setup(){
        
    }
    @isTest
    public static void testCriarRemuneracao(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        //correcao ambientes inicio
        ContadorCodigo__c cont = new ContadorCodigo__c();
        cont.Name = 'ProdutoTecnico';
        cont.Numero__c = 1000000000;
        insert cont;
        //correcao ambientes fim

        Map<String, Account> mapAccount = new Map<String, Account>();
        mapAccount.put('1', conta);
        
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
        
        Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        produtoComercial.Status__c = 'Ativo';
        update produtoComercial;
        
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        
        TipoRemuneracao__c newTipoRemuneracao = new TipoRemuneracao__c();
        Map<String, TipoRemuneracao__c> mapTipoRemuneracao = new Map<String, TipoRemuneracao__c>();
        mapTipoRemuneracao.put('1', newTipoRemuneracao);
        
        RemuneracaoProdutoParceiro__c newRemuneracao = new RemuneracaoProdutoParceiro__c();
        //newRemuneracao.TipoRemuneracao__c = newTipoRemuneracao.Id;
        List<RemuneracaoProdutoParceiro__c> lstRemuneracao = new List<RemuneracaoProdutoParceiro__c>();
        lstRemuneracao.add(newRemuneracao);
        EmissaoTO.RemuneracaoTO remuneracao = new EmissaoTO.RemuneracaoTO();
        //remuneracao.tipoRemuneracao = 'teste';
        List<EmissaoTO.RemuneracaoTO> lstRemuneracaoTO = new List<EmissaoTO.RemuneracaoTO>();
        
        //List<RemuneracaoOrcamento__c> newRemuneracaoOrcamento = RemuneracaoFacade.criaRemuneracaoOrcamento('', lstRemuneracaoTO, orcamento.Id, lstRemuneracao, mapAccount, mapTipoRemuneracao);
    }
}