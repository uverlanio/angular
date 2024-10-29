/**
 * @author AVX - Tiago Fernandes
 * @date 2019-04-11
 * @description Classe de Teste para a classe CasoHistoricoMedicoTest
 */
@isTest
public class CasoHistoricoMedicoTest {
    @isTest
    static void consultaHistorico(){
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        
		Case caso = (Case) new CasoFactory.AtendimentoSinistro(conta).createRecord();
        List<Case> CasoHistorico = CasoHistoricoMedico.consultaHistorico(caso.Id);
        
        caso.CRM__c = '123';
        update caso;
        
        Case caso2 = (Case) new CasoFactory.AtendimentoSinistro(conta).createRecord();
        List<Case> CasoHistorico2 = CasoHistoricoMedico.consultaHistorico(caso2.Id);
        
        caso2.CRM__c = null;
        update caso2;
        
        system.debug('TF: '+caso);
    } 
}