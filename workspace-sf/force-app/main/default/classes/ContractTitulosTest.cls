@isTest
private class ContractTitulosTest {

	@testSetup 
	static void setup(){
        TestDataFactory.gerarDadosSetup();

        // Insercao de dados para o teste do servico de recompra de titulos
        dadosRecomprarTitulos();
	}

    public static void dadosRecomprarTitulos(){
    	// PLV-2312-28 INICIO
        TestDataFactory.gerarProposta(false);
	// PLV-2312-28 FIM
    }
}