// POR062-1 - INICIO
@isTest
class CaseDAOTest {
    private static final String EMPRESA = '1';
    private static final String RAMO = '1369';
    private static final String ANO = String.valueOf(System.now().year());
    
    @TestSetup
    static void setup()
    {
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case sinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, conta).createRecord();
        sinistro = [SELECT CaseNumber FROM Case ORDER By Id DESC LIMIT 1];
        sinistro.NumeroSinistro__c = String.format(
			'{0}.{1}.{2}.{3}',
			new String[] {
                CaseDAOTest.EMPRESA, CaseDAOTest.RAMO,
                CaseDAOTest.ANO, sinistro.CaseNumber
            }
		);
        update sinistro;
    }
    
    @isTest
    static void buscarPorNumeroDoSinistroTest()
    {
        Case caso = [SELECT CaseNumber FROM Case ORDER By Id DESC LIMIT 1];
        String numeroSinistro = String.format(
            '{0}.{1}.{2}.{3}',
			new String[] {
                CaseDAOTest.EMPRESA, CaseDAOTest.RAMO,
                CaseDAOTest.ANO, caso.CaseNumber
            }
        );
        Test.startTest();
        List<Case> casos = CaseDAO.getInstance().buscarPorNumeroDoSinistro(new Set<String> { numeroSinistro });
        Test.stopTest();
        System.assertEquals(1, casos.size());
    }
}
// POR062-1 - FIM