/**
 * Testes Orçamento
 * @author Fernando Barcellos @ 19/04/2018
 *
 **/
@isTest
private class OrcamentoTest {
	@testSetup
	static void testSetup() {
		TestDataFactory.gerarDadosSetup();
		// PLV-2312-28 INICIO
		TestDataFactory.gerarOrcamento(false);
		// PLV-2312-28 FIM
	}

	@isTest
	static void testBurcarOportunidadePorRoteamentoId() {
		Roteamento__c roteamento = [SELECT Id, Orcamento__c FROM Roteamento__c LIMIT 1];
		Test.startTest();
		Opportunity orcamento = BackgroundConsoleController.burcarOportunidadePorRoteamentoId(roteamento.Id);
		Test.stopTest();
		System.assert(orcamento != null);
	}

	@isTest
	static void testarComponenteInfoComplementares() {
		// Busca o orcamento para o teste
		Opportunity orcamento = [SELECT Id FROM Opportunity];
		orcamento.Name = 'Novo Orcamento';

		// Trabalha uma garantia do Grupo do orcamento para atualizar
		List<SObject> listSObjects = new List<SObject>();
		List<GarantiaGrupoOrcamento__c> listGarantiaGrupoOrcamento = [SELECT Id,Capital__c FROM GarantiaGrupoOrcamento__c];
		GarantiaGrupoOrcamento__c garantiaGrupoOrcamento = (GarantiaGrupoOrcamento__c) listGarantiaGrupoOrcamento[0];
		garantiaGrupoOrcamento.Capital__c = 9876.98;
		listSObjects.addAll(listGarantiaGrupoOrcamento);

		Test.startTest();

		// roda o buscarGarantiasOrcamento
		String jsonString = ComplementoOrcamentoController.buscarGarantiasOrcamento(orcamento.Id);
		OrcamentoTO orcamentoTO = (OrcamentoTO) JSON.deserialize(jsonString, OrcamentoTO.class);

		// Roda o atualizarGarantiasDoGrupoDoOrcamento
		ComplementoOrcamentoController.atualizarGarantiasDoGrupoDoOrcamento(listSObjects, orcamento.Id);
		GarantiaGrupoOrcamento__c garantiaGrupoOrcamento2 = [SELECT Id, Capital__c FROM GarantiaGrupoOrcamento__c WHERE Id =: listGarantiaGrupoOrcamento[0].Id LIMIT 1];

		// Roda o atualizaOportunidade
		OpportunityBO.getInstance().atualizaOportunidade(orcamento);

		// Valida buscarGarantiasOrcamento
		System.assert(orcamentoTO.oferta.calculo.precificacao.coberturas.size() > 0);
		// Valida atualizarGarantiasDoGrupoDoOrcamento
		System.assert(garantiaGrupoOrcamento2.Capital__c == 9876.98);

		Opportunity orcamento2 = [SELECT Id, DataCalculo__c FROM Opportunity WHERE Id =: orcamento.Id];
		System.assert(orcamento2.DataCalculo__c == System.today());
		// Valida atualizaOportunidade
		Opportunity orcamentoAtualizado = [SELECT Id,Name FROM Opportunity];
		System.assert(orcamentoAtualizado.Name == 'Novo Orcamento');

		Test.stopTest();
	}

	@isTest
	static void testValidarCalcularOrcamentoSemRemuneracaoOrcamentoObrigatoria() {
		Opportunity orcamento = [SELECT Id,Produto__c,(SELECT Id FROM RemuneracoesOrcamento__r) FROM Opportunity LIMIT 1];
		String mensagemEsperada = 'Remuneração obrigatória não informada no orçamento!';

		List<RemuneracaoOrcamento__c> listRemuneracaoOrcamento = orcamento.RemuneracoesOrcamento__r;
		delete listRemuneracaoOrcamento;

		TipoRemuneracao__c tipoRemuneracao = [SELECT Id FROM TipoRemuneracao__c WHERE Name ='COMISSÃO' LIMIT 1];
		RemuneracaoOrcamento__c remuneracaoOrcamento  = TestDataFactory.gerarRemuneracaoOrcamento(orcamento,tipoRemuneracao);

		Test.startTest();
		String msgRetorno = ComplementoOrcamentoController.validarCalcularOrcamento(orcamento.Id);
		Test.stopTest();

		// Valida se nao retornou mensagem de erro
		System.assertEquals(mensagemEsperada,msgRetorno);
	}

	@isTest
	static void testAtualizarOportunidade() {
		Opportunity orcamento = [SELECT Id, Name FROM Opportunity LIMIT 1];
		orcamento.Name = 'Novo nome';
		Test.startTest();
		BackgroundConsoleController.atualizarOportunidade(orcamento);
		Test.stopTest();
		Opportunity orcamentoAtualizado = [SELECT Id, Name FROM Opportunity LIMIT 1];
		System.assert(orcamentoAtualizado.Name == 'Novo nome');
	}
}