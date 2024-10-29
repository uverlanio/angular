@isTest
private class GerenciamentoTerritoriosTest {
	
	@isTest 
	static void testarChamadasComponentePrincipal() {
		Municipio__c municipio = new Municipio__c(
			Name = 'São Paulo',
			Uf__c = 'SP'
		);

		insert municipio;


		//Teste busca de tipos
		Map<String, String> mapPrefixos = (Map<String, String>)JSON.deserialize(GerenciamentoTerritoriosController.buscarPrefixosSObjects(), Map<String, String>.class);
		System.assert(!mapPrefixos.isEmpty());

		//Teste busca de tipos
		List<CustomPickListOptionTO> opcoesTipo = (List<CustomPickListOptionTO>)JSON.deserialize(GerenciamentoTerritoriosController.buscarTipos(), List<CustomPickListOptionTO>.class);
		System.assert(!opcoesTipo.isEmpty());

		//Teste busca de continentes
		List<CustomPickListOptionTO> opcoesContinentes = (List<CustomPickListOptionTO>)JSON.deserialize(GerenciamentoTerritoriosController.buscarContinentes(), List<CustomPickListOptionTO>.class);
		System.assert(!opcoesContinentes.isEmpty());

		//Teste busca de estado
		List<CustomPickListOptionTO> opcoesEstado = (List<CustomPickListOptionTO>)JSON.deserialize(GerenciamentoTerritoriosController.buscarEstados(), List<CustomPickListOptionTO>.class);
		System.assert(!opcoesEstado.isEmpty());

		//Teste busca de municipios
		List<CustomPickListOptionTO> opcoesMunicipios = (List<CustomPickListOptionTO>)JSON.deserialize(GerenciamentoTerritoriosController.buscarMunicipios('SP;'), List<CustomPickListOptionTO>.class);
		System.assert(!opcoesMunicipios.isEmpty());

		//Teste busca de paises
		List<CustomPickListOptionTO> opcoesPais = (List<CustomPickListOptionTO>)JSON.deserialize(GerenciamentoTerritoriosController.buscarPaises('América do Sul'), List<CustomPickListOptionTO>.class);
		System.assert(!opcoesPais.isEmpty());

		//Teste busca de map de paises
		Map<String, List<CustomPickListOptionTO>> mapOpcoesPaises = (Map<String, List<CustomPickListOptionTO>>)JSON.deserialize(GerenciamentoTerritoriosController.buscarTodosPaises(), Map<String, List<CustomPickListOptionTO>>.class);
		System.assert(!mapOpcoesPaises.isEmpty());

		//Teste salvar um territorio
		GarantiaProduto__c garantiaProduto = criarGarantiaProduto();

		Territorio__c territorioGarantia = new Territorio__c(
				Tipo__c = 'Estado',
				Continente__c = 'América do Sul',
				Pais__c = 'Brasil',
				Estado__c = 'SP',
				GarantiaProduto__c = garantiaProduto.Id			
		);

		GerenciamentoTerritoriosController.salvarTerritorios(new List<Territorio__c>{territorioGarantia});

		//Teste buscar um territorio garantia salvo
		List<Territorio__c> territorios = GerenciamentoTerritoriosController.buscarTerritorios(garantiaProduto.Id, 'GarantiaProduto__c');
		System.assert(!territorios.isEmpty());

		//Teste exclusão de um territorio garantia
		GerenciamentoTerritoriosController.excluir(territorios[0].Id);
		territorios = GerenciamentoTerritoriosController.buscarTerritorios(garantiaProduto.Id, 'GarantiaProduto__c');
		System.assert(territorios.isEmpty());

		//todo
		territorios = GerenciamentoTerritoriosController.buscarTerritorios(null, 'Product2');
		System.assert(territorios.isEmpty());
	}

	//Cria estrutura de dados necessária
	static GarantiaProduto__c criarGarantiaProduto(){
		Garantia__c garantia = new Garantia__c(
			Name = 'Garantia 1',
			Tipo__c = 'Cobertura'
		);

		insert garantia;

		GarantiaProduto__c garantiaProduto = new GarantiaProduto__c(
			Garantia__c = garantia.Id,
			TipoGarantia__c = 'Cobertura'
		);

		insert garantiaProduto;

		return garantiaProduto;
	}
}