/**
 * Teste ProfissaoDAO
 * @author Pedro Augusto Braz - Sys4b
 * @Date 24/04/2020
 **/
@isTest
private class ProfissaoDAOTest {
    @testSetup
	static void setup() {
        List<Profissao__c> profissoes = new List<Profissao__c>();
        List<String> lstatus = new List<String>{'Em análise','Ativo','Inativo'};
        Integer x = 0;
        for(integer i=0; i<100; i++){
            Profissao__c profissao = new Profissao__c(

                NomeOcupacao__c = null,
                Name = null,
                NomeFantasia__c = null,
                NomeFamilia__c = null,
                NomeSubGrupo__c = null,
                NomeSubGrupoPrincipal__c = null,
                NomeGrandeGrupo__c = 'teste',
                CodigoProfissao__c = null,
                Codigo__c = null,
                CodigoFamilia__c = null,
                CodigoSubGrupo__c = null,
                CodigoSubGrupoPrincipal__c = null,
                CodigoGrandeGrupo__c = '8'
            );
            profissao.name =' teste '+i;
            profissao.Status__c = lstatus[x];
            if(x<2) x=x+1; else x=0; //garanto que sempre terá ao menos uma de cada estado ao invés de deixar em modo rand
            profissao.Codigo__c = i+''+x+''+profissao.Status__c;//Fica único e exclusivo
            //profissao.CodigoProfissao__c = profissao.Codigo__c;//Fica único e exclusivo
            profissoes.add(profissao);
        }
        System.debug(logginglevel.ERROR,JSON.serialize(profissoes));
        insert profissoes;
    }
    
    @isTest static void testbuscarProfissoesPorStatusAtivo(){
        ProfissaoDAO dao = ProfissaoDAO.getInstance();
        Test.startTest();
            List<Profissao__c> listaProfissioes= dao.buscarProfissoesPorStatus('Ativo');
        Test.stopTest();
        System.assert(listaProfissioes.size() > 0);
    }
    @isTest static void testbuscarProfissoesPorStatusInativo(){
        ProfissaoDAO dao = ProfissaoDAO.getInstance();
        Test.startTest();
            List<Profissao__c> listaProfissioes= dao.buscarProfissoesPorStatus('Inativo');
        Test.stopTest();
        System.assert(listaProfissioes.size() > 0);
    }
    @isTest static void testbuscarProfissoesPorStatusEmanalise(){
        ProfissaoDAO dao = ProfissaoDAO.getInstance();
        Test.startTest();
            List<Profissao__c> listaProfissioes= dao.buscarProfissoesPorStatus('Em análise');
        Test.stopTest();
        System.assert(listaProfissioes.size() > 0);
    }
    @isTest static void testbuscarProfisoesAtivasPorCodigo(){
        ProfissaoDAO dao = ProfissaoDAO.getInstance();
        Test.startTest();
            List<Profissao__c> listaProfissioes= dao.buscarProfissoesPorStatus('Ativo');
            Set<String> cods = new Set<String>();
            for(Profissao__c pro : listaProfissioes){
                cods.add(pro.Codigo__c);
            }
            List<Profissao__c> listaProfissioesporcodigo= dao.buscarProfisoesAtivasPorCodigo(cods);
        Test.stopTest();
        System.assertEquals(listaProfissioes.size(),listaProfissioesporcodigo.size());
    }
    @isTest static void testbuscarProfissoesTodas(){
        ProfissaoDAO dao = ProfissaoDAO.getInstance();
        Test.startTest();
            List<Profissao__c> listaProfissioes= dao.buscarProfissoesTodas();

        Test.stopTest();
        System.assertEquals(100,listaProfissioes.size());
    }
}