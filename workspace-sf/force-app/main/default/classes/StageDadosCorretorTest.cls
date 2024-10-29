//INICIO | PLV-2179-27- remover duplicidade
@isTest
private class StageDadosCorretorTest {
	@testSetup
	private static void setup() {
		TestDataFactory.gerarDadosSetup();
	}

	@isTest
	private static void testarBatch() 
	{
		Database.executeBatch(new StageDadosCorretorBatch());
	}
}
//FIM | PLV-2179-27- remover duplicidade