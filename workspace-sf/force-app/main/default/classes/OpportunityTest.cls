//PLV-2673- Inicio
/**
 * @author AVX - Matheus Gomes
 * @date 2019-09-11
 * @description Classe de teste Opportunity - PLV-2673
 */
@isTest
public class OpportunityTest {
    
    @isTest
    public static void testVencimentoOrcamento() {
        //Criar registros para a validação
        ContadorCodigo__c contCodigoTec = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoTecnico().createRecord();
        ContadorCodigo__c contCodigoCom = (ContadorCodigo__c) new ContadorCodigoFactory.ProdutoComercial().createRecord();
        Product2 produtoTecnico = (Product2) new ProdutoFactory.ProdutoTecnico().createRecord();
        produtoTecnico.Status__c = 'Em ativação';
        produtoTecnico.NumeroSusep__c = '123';
        produtoTecnico.VersaoRenovacao__c = 'Versão atual';
        update produtoTecnico;
        produtoTecnico.Status__c = 'Ativo';
        update produtoTecnico;
		Product2 produtoComercial = (Product2) new ProdutoFactory.ProdutoComercial(produtoTecnico).createRecord();
        
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        //PLV-3460 Fix 5 - INICIO - Ajuste na factory
        ParametroVigencia__c parametroV = (ParametroVigencia__c) new ParametroVigenciaFactory.ParametroVigenciaComercial(produtoComercial).createRecord();
        //PLV-3460 Fix 5 O- FIM
        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual(produtoComercial, conta).createRecord();
        update orcamento;
    }
}
//PLV-2673- Fim