//PLV-2673 - Início
/**
 * @author Daniel Zampieri
 * @version 1.0
 * @date 2019-09-10
 * @description Schedule Batch para vencer as oportunidades
 */
@isTest
public class OrcamentoVencimentoScheduleTest {

    @isTest
    public static void validarSchedule(){
        //Criar registros para a validação do Schedule
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

        Opportunity orcamento = (Opportunity) new OrcamentoFactory.VidaIndividual().createRecord();
        orcamento.DataVencimento__c = System.today() - 1;
        update orcamento;

        system.debug('Data vencimento: ' + orcamento.DataVencimento__c);
        //PLV-2673-Mochila - INICIO - Ajuste classe de teste
        Test.startTest();
        String sch = '0 0 23 * * ?';
        OrcamentoVencimentoSchedule classe = new OrcamentoVencimentoSchedule(sch, 'testSchedule');
        Test.stopTest();

        //PLV-2673-Mochila - FIM
    }

    @isTest
    public static void validarSubClasseError(){

        Database.Error databaseErro;
        Id id = '000000000000001';
        OrcamentoVencimentoSchedule.Error erro = new OrcamentoVencimentoSchedule.Error(id, new List<Database.Error> {databaseErro});

    }
    
}
//PLV-2673 - Fim