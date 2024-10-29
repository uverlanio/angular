/********************************************************************************************************************
* OpinCIVTO (Open Insurance)
* @author Squad_VidaDoSeuJeito
* @date 10/10/2021
* Classe de teste para metadados criados para o depara criada por conta da história PLV-5230
*********************************************************************************************************************/

@isTest
public class MetadataOPINDAOTest {
    /*
    @TestSetup
    static void setupUnit(){
        
        Integracao_OPIN_Depara__mdt	metadado1 = new Integracao_OPIN_Depara__mdt(
            MasterLabel	= 'GARANTIAS',	
            DeveloperName = 'GARANTIAS_0001',
            Para__c = 'MORTE_ACIDENTAL',	 	 
            De__c = 'MAP'
        );	
        insert metadado1;

        Integracao_OPIN_Depara__mdt	metadado2 = new Integracao_OPIN_Depara__mdt(
            MasterLabel	= 'PAGAMENTOS',	
            DeveloperName = 'PAGAMENTOS_0001',
            Para__c = 'CARTAO_CREDITO',	 	 
            De__c = '97'
        );	
        insert metadado2;

        Integracao_OPIN_Depara__mdt	metadado3 = new Integracao_OPIN_Depara__mdt(
            MasterLabel	= 'PAGAMENTOS',	
            DeveloperName = 'PAGAMENTOS_0004',
            Para__c = 'CARTAO_CREDITO',	 	 
            De__c = '62'
        );	
        insert metadado3;
        
    }
    */

    @isTest
    public static void TesteDeparaBuscarPorRotuloDe() {

        MetadataDAO dao = MetadataDAO.getInstance();

        string rotulo = 'GARANTIAS';
        string de = 'MAP';
        Test.startTest();
        List<Integracao_OPIN_Depara__mdt> retorno = dao.buscarDeparaOpin(rotulo, de);
        System.assertEquals(retorno[0].Para__c, 'MORTE_ACIDENTAL');
        Test.stopTest();
    }

    @isTest
    public static void TesteDeparaBuscarPorRotulo() {

        MetadataDAO dao = MetadataDAO.getInstance();

        string rotulo = 'PAGAMENTOS';
        Test.startTest();
        List<Integracao_OPIN_Depara__mdt> retorno = dao.buscarDeparaOpinTodos(rotulo);
        Test.stopTest();

        System.Assert(retorno.size() > 1);
    }    

    @isTest
    public static void TesteConsultarDeparaComValor() {
    
        IntegracaoOpinDeparaBO bo = IntegracaoOpinDeparaBO.getInstance();
        string de = '97';
        string rotulo = 'PAGAMENTOS';

        Test.startTest();
        String retorno = bo.consultar(rotulo, de);
        Test.stopTest();        

        System.assertEquals(retorno, 'CARTAO_CREDITO');
        
    }

    @isTest
    public static void TesteConsultarDeparaSemValor() {
    
        IntegracaoOpinDeparaBO bo = IntegracaoOpinDeparaBO.getInstance();
        string de = '999';
        string rotulo = 'TESTENADA';

        Test.startTest();
        String retorno = bo.consultar(rotulo, de);
        List<String> retSemDepara = bo.consultarDeparasNaoEncontrados();
        Test.stopTest();        

        System.assertEquals(retorno, '');
        System.Assert(retSemDepara.size() == 1);

        
    }

}
//PLV-5230 - FIM