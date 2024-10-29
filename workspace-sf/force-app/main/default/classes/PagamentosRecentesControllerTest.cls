@isTest
public class PagamentosRecentesControllerTest {
     @isTest static void testCallout() {
        PagamentoGarantia__c pag = (PagamentoGarantia__c) new PagamentoGarantiaFactory().createRecord();
        BeneficiarioGarantia__c bene = (BeneficiarioGarantia__c) new BeneficiarioGarantiaFactory.BenePessoaFisica().createRecord();

        Account conta = (Account) new AccountFactory.PessoaJuridica().createRecord();
        String[] contas = new List<String>{conta.id};
        String resConsultaPagamento = pagamentosrecentescontroller.consultapagamentos(pag.Id);
        String resCancelaPagamento = pagamentosrecentescontroller.cancelapagamentos(75);
        Map<Id,Account> mapResConsultaConta = pagamentosrecentescontroller.retornanomeConta(contas);
        pagamentosrecentescontroller.mudastatusbeneficiario(bene.Id);
    }
}