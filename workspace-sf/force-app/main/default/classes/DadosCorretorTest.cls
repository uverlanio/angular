/**
 * InformacaoBancariaTest
 * @author; Iskander Bittencourt @ 27/03/2020
 * PLV-3667
 **/
@isTest
public class DadosCorretorTest {

    @isTest
    public static void testDadosCorretor(){
        Account contaJuridica = (Account) new AccountFactory.PessoaJuridica().createRecord();
        DadosCorretorFactory dados = new DadosCorretorFactory(contaJuridica);
		
        Set<String> lNames = new Set<String>();
        lNames.add('001');

        Test.startTest();
        List<DadosCorretor__c> lDadosCorretorPorCod = new List<DadosCorretor__c>();
        List<DadosCorretor__c> lDadosCorretorPorSusep = new List<DadosCorretor__c>();
		
        
        lDadosCorretorPorCod = DadosCorretorDAO.getInstance().listarDadosCorretorPorCodigo(lNames);
        lDadosCorretorPorSusep = DadosCorretorDAO.getInstance().buscarCorretorPorSusep(lNames);
		
        Test.stopTest();
    }
	//PLV-4921 INICIO
	@isTest
    public static void TestCorretorBO(){

       	Account contaTeste = TestDataFactory.gerarConta();
		DadosCorretor__c dadosCorretor = TestDataFactory.gerarDadosCorretor(contaTeste);
		StageDadosCorretor__c stageDadosCorretor1 = new StageDadosCorretor__c();
       	stageDadosCorretor1.Name = dadosCorretor.Name;
		insert stageDadosCorretor1;
		StageDadosCorretor__c stageDadosCorretor2= new StageDadosCorretor__c();
		stageDadosCorretor2.Name = dadosCorretor.Name;
		insert stageDadosCorretor2;
		StageDadosCorretor__c stageDadosCorretor3= new StageDadosCorretor__c();
		insert stageDadosCorretor3;

		List<StageDadosCorretor__c> listStageCorretor = new List<StageDadosCorretor__c>();
        listStageCorretor.add(stageDadosCorretor1);
		listStageCorretor.add(stageDadosCorretor2);
		listStageCorretor.add(stageDadosCorretor3);

		Test.startTest();
			DadosCorretorBO.getInstance().removeRegistrosDuplicados(listStageCorretor);
        Test.stopTest();

    }
	//PLV-4921 FIM
}