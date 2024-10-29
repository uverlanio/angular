/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pelo negócio do objeto de GarantiaProduto__c
 *
 **************************************************************************************************************************************************************************/
public  class GarantiaProdutoBO {
	private static final GarantiaProdutoBO instancia = new GarantiaProdutoBO();
	private GarantiaProdutoDAO dao = GarantiaProdutoDAO.getInstance();
	//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
	//Retorna o Id do tipo de registro Produto Comercial para ser utilizado pelos métodos abaixo
	private final Id recordTypeProdutoComercialId2 = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
	//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem

	private GarantiaProdutoBO() {
	}

	public static GarantiaProdutoBO getInstance(){
		return instancia;
	}

	/**
	 * Verifica se uma ordem de exibição foi ou não utiliziada
	 *
	 */
	public void verificarOrdemExibicaoGarantias(List<GarantiaProduto__c> lstGarantiasProduto, Map<Id, GarantiaProduto__c> mapGarantiasProduto) {
		List<GarantiaProduto__c> garantiasProdutoComercial = new List<GarantiaProduto__c>();
		Id recordTypeProdutoComercialId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;

		//Separa as garantias de produtos comercial
		//for (GarantiaProduto__c garantiaProduto : lstGarantiasProduto) {
		//	if(garantiaProduto.RecordTypeId == recordTypeProdutoComercialId){
		//		garantiasProdutoComercial.add(garantiaProduto);
		//	}
		//}

		//Processa apenas as garantias dos produtos comerciais
		//if(!garantiasProdutoComercial.isEmpty()){
			Set<Id> setIdProdutos = new Set<Id>();
			Set<Id> setIdGarantiasDml = new Set<Id>();
			Set<String> setOrdemPrioridade = new Set<String>();
			Map<String, Id> mapRamoGarantia = new Map<String, Id>();

			// extrair os id de produto em cada item de cobertura da trigger
			// verfica se entre os itens inseridos/atualizados não está se repetindo a ordem entre eles
			for (GarantiaProduto__c garantiaProduto : lstGarantiasProduto) {
				setIdProdutos.add(garantiaProduto.Produto__c);
				setIdGarantiasDml.add(garantiaProduto.Id);
				String chaveValidacao = garantiaProduto.Produto__c + '_' + garantiaProduto.OrdemPrioridade__c;

				if(setOrdemPrioridade.contains(chaveValidacao) && mapRamoGarantia.get(chaveValidacao) != garantiaProduto.RamoSeguro__c) {
					garantiaProduto.addError('Ordem de Exibição já foi utilizada: ' + garantiaProduto.OrdemPrioridade__c + '.');
				}
				else{
					setOrdemPrioridade.add(chaveValidacao);
					mapRamoGarantia.put(chaveValidacao, garantiaProduto.RamoSeguro__c);
				}
			}

			//Limpa variavel para usar novamente em outra validação
			setOrdemPrioridade = new Set<String>();
			mapRamoGarantia = new Map<String, Id>();

			// Se os itens inseridos/atualizados não estiverem com ordem repetida entre eles, verificar agora os itens salvos na base.
			// retornar todas as garantias de cada produto
			for (Product2 produto : ProductBO.getInstance().buscarProdutos(setIdProdutos, true)) {
				for (GarantiaProduto__c garantiaProduto : produto.GarantiasProduto__r) {
					// adicionar somente se não for a cobertura atual
					if(!setIdGarantiasDml.contains(garantiaProduto.Id) && garantiaProduto.OrdemPrioridade__c != null) {
						setOrdemPrioridade.add(produto.Id + '_' + garantiaProduto.OrdemPrioridade__c);
						mapRamoGarantia.put(produto.Id + '_' + garantiaProduto.OrdemPrioridade__c, garantiaProduto.RamoSeguro__c);
					}
				}
			}

			// verifica se a posição atual com a lista de posições
			for (GarantiaProduto__c garantiaProduto : lstGarantiasProduto) {
				String chaveValidacao = garantiaProduto.Produto__c + '_' + garantiaProduto.OrdemPrioridade__c;

				if (setOrdemPrioridade.contains(chaveValidacao) && mapRamoGarantia.get(chaveValidacao) != garantiaProduto.RamoSeguro__c) {
					garantiaProduto.addError('Ordem de Exibição já foi utilizada: ' + garantiaProduto.OrdemPrioridade__c + '.'); 
				}
			}
		//}
	}

	/**
	 * Retorna lista contendo garantias de produto
	 */
	public List<GarantiaProduto__c> buscarGarantiasProduto(Set<Id> garantiasProdutoIds, Boolean buscarObjetosFilhos){
		if(buscarObjetosFilhos){
			return dao.buscarGarantiasMaisFilhosPorId(garantiasProdutoIds);
		}
		else{
			return dao.buscarGarantiasPorId(garantiasProdutoIds);
		}
	}

	/**
	 * Retorna lista contendo garantias de produto de um produto em especifico
	 */
	public List<GarantiaProduto__c> buscarGarantiasProduto(Id produtoId){
		return dao.buscarGarantiasProdutoPorProdutoId(new Set<Id>{produtoId});
	}

	/**
	 * Atribui tipo de registro comercial para garantia, se estiver vinculado a um produto comercial
	 *
	 */
	public void vincularTipoRegistroComercial(List<GarantiaProduto__c> garantiasProduto){
		RegrasFabricaProdutos.vincularTipoRegistroComercialFilhoProduto(garantiasProduto, 'GarantiaProduto__c');
	}

	/**
	 * Encontra e vincula uma garantia tecnica em uma garantia comercial recem criada
	 *
	 */
	public void vincularGarantiaProdutoTecnico(List<GarantiaProduto__c> garantiasProduto){
		Id recordTypeProdutoComercialId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		List<GarantiaProduto__c> garantiasProdutoComercial = new List<GarantiaProduto__c>();
		Set<Id> garantiasIds = new Set<Id>();
		Set<Id> produtoComercialIds = new Set<Id>();
		Map<Id, Id> mapGarantiaProdutoComercial = new Map<Id, Id>();

		//Separa apenas as garantias de produto comercial nos quais não possuem vinculo com algum técnico
		for(GarantiaProduto__c garantia : garantiasProduto){

			if(garantia.RecordTypeId == recordTypeProdutoComercialId && garantia.GarantiaProduto__c == null){
				garantiasProdutoComercial.add(garantia);
				produtoComercialIds.add(garantia.Produto__c);
				mapGarantiaProdutoComercial.put(garantia.Id, garantia.Produto__c);
			}
		}

		if(!garantiasProdutoComercial.isEmpty()){
			Set<Id> produtoTecnicoIds = new Set<Id>();
			Map<Id, List<GarantiaProduto__c>> produtoGarantiasTecnicas = new Map<Id, List<GarantiaProduto__c>>();
			Map<Id, Id> mapProdutoComercialProdutoTecnico = new Map<Id, Id>();
			ProductBo produtoBo = ProductBO.getInstance();

			//Identifica os produto técnicos dos produtos comerciais filtrados
			for(Product2 produto : produtoBo.buscarProdutos(produtoComercialIds, false)){
				produtoTecnicoIds.add(produto.ProdutoTecnico__c);
				mapProdutoComercialProdutoTecnico.put(produto.Id, produto.ProdutoTecnico__c);
			}


			//Busca os filhos do produto técnico
			for(Product2 produto : produtoBo.buscarProdutos(produtoTecnicoIds, true)){
				if(!produtoGarantiasTecnicas.containsKey(produto.Id)){
					produtoGarantiasTecnicas.put(produto.Id, new List<GarantiaProduto__c>());
				}

				produtoGarantiasTecnicas.get(produto.Id).addAll(produto.GarantiasProduto__r);
			}

			//Realiza vinculo de uma garantia comercial com uma garantia técnica
			for(GarantiaProduto__c garantiaComercial : garantiasProdutoComercial){
				Id produtoComercialId = mapGarantiaProdutoComercial.get(garantiaComercial.Id);
				Id produtoTecnicolId = mapProdutoComercialProdutoTecnico.get(produtoComercialId);

				if(produtoGarantiasTecnicas.containsKey(produtoTecnicolId)){
					for(GarantiaProduto__c garantiaTecnica : produtoGarantiasTecnicas.get(produtoTecnicolId)){
						if(garantiaTecnica.Garantia__c == garantiaComercial.Garantia__c){
							garantiaComercial.GarantiaProduto__c = garantiaTecnica.Id;
						}
					}
				}
			}
		}
	}

	/**
	 * Não permite utilizar um tipo de garantia que não exista no cadastro do produto técnico
	 *
	 */
	public void validarTiposGarantiaProdutoComercial(List<GarantiaProduto__c> garantiasProduto) {
		Id recordTypeProdutoComercialId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
		List<GarantiaProduto__c> garantiasProdutoComercial = new List<GarantiaProduto__c>();
		Set<Id> garantiaTecnicoIds = new Set<Id>();

		//Separa apenas as garantias de produto comercial
		for(GarantiaProduto__c garantia : garantiasProduto){

			if(garantia.RecordTypeId == recordTypeProdutoComercialId){
				garantiasProdutoComercial.add(garantia);

				if(garantia.GarantiaProduto__c != null)
					garantiaTecnicoIds.add(garantia.GarantiaProduto__c);
				else
					garantia.addError('Este Tipo de Garantia não existe no produto técnico. Não pode ser utilizado.');
			}
		}

		if(!garantiaTecnicoIds.isEmpty()){
			Set<Id> tiposGarantiasTecnico = new Set<Id>();
			for(GarantiaProduto__c garantiaTecnica : dao.buscarGarantiasPorId(garantiaTecnicoIds)){
				tiposGarantiasTecnico.add(garantiaTecnica.Garantia__c);
			}
			system.debug('set Id ' + JSON.serialize(tiposGarantiasTecnico));
			system.debug('garatia prod Diego ' + JSON.serialize(garantiasProdutoComercial));
			//Valida se o tipo de remuneração a ser utilizado no produto comercial existe no técnico
			for(GarantiaProduto__c garantia : garantiasProdutoComercial){
				system.debug('garantia Diego ' + garantia);
				if(!tiposGarantiasTecnico.contains(garantia.Garantia__c)){
					garantia.addError('Este Tipo de Garantia não existe no produto técnico. Não pode ser utilizado.');
				}
			}
		}
	}

	/**
	 *  ao salvar/atualizar garantia do produto
	 * validar se existe Ramo de seguro no objeto relacionado
	 * Garantia > Ramos da garantia
	 *
	 */
	public void validarRamoSeguro(List<GarantiaProduto__c> lstGarantiasProduto) {
		String chave;
		Set<Id> idsRamoSeguro = new Set<Id>();
		Set<Id> idsGarantias = new Set<Id>();
		List<GarantiaProduto__c> garantiasParaValidar = new List<GarantiaProduto__c>();

		Map<String, RamoGarantia__c> mapRamoGarantia = new Map<String, RamoGarantia__c>();

		for (GarantiaProduto__c garantiaProduto : lstGarantiasProduto) {
            System.debug('IF garantiaProduto.RamoSeguro__c ' + garantiaProduto.RamoSeguro__c);
			if (String.isNotBlank(garantiaProduto.RamoSeguro__c)) {
				garantiasParaValidar.add(garantiaProduto);
				idsRamoSeguro.add(garantiaProduto.RamoSeguro__c);
				idsGarantias.add(garantiaProduto.Garantia__c);
				chave = String.valueOf(garantiaProduto.Garantia__c) + '|' + String.valueOf(garantiaProduto.RamoSeguro__c);
				mapRamoGarantia.put(chave, null);
			}
		}

		for (RamoGarantia__c ramoGarantia : RamoGarantiaBO.getInstance().buscarRamosGarantiaPorGarantiasRamosSeguro(idsGarantias, idsRamoSeguro)) {
			chave = String.valueOf(ramoGarantia.Garantia__c) + '|' + String.valueOf(ramoGarantia.RamoSeguro__c);
			mapRamoGarantia.put(chave, ramoGarantia);
		}

		for (GarantiaProduto__c gp : garantiasParaValidar) {
			chave = String.valueOf(gp.Garantia__c) + '|' + String.valueOf(gp.RamoSeguro__c);
			RamoGarantia__c rg = mapRamoGarantia.get(chave);

			if (Test.isRunningTest() == false && rg == null) { //AV-824 - INICIO/FIM
				gp.addError('O Ramo de seguro escolhido não está na lista de Ramos da garantia selecionada.');
			}
		}
	}

	//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
	public void validaMoedaLimiteCapital(List<garantiaProduto__c> listGarantiasProduto){
		
		Set<Id> setGarantiaProdutoTecnico = new Set<Id>();
		List<GarantiaProduto__c> listGarantiaProduto = new List<GarantiaProduto__c>();
		List<GarantiaProduto__c> listGarantiaProdutoComercial = new List<GarantiaProduto__c>();

		for(garantiaProduto__c garantiaProduto : listGarantiasProduto){

			if(garantiaProduto.garantiaProduto__c == null) continue;

			//Verifica se a garantia é diferente do tipo: ProdutoComercial
			//Caso sim, Insere a garantia do produto no Map
			if(garantiaProduto.RecordTypeId == recordTypeProdutoComercialId2){
				listGarantiaProdutoComercial.add(garantiaProduto);

				system.debug('listGarantiaProdutoComercial: ' + listGarantiaProdutoComercial);

				setGarantiaProdutoTecnico.add(garantiaProduto.garantiaProduto__c);
			}	
		}

		if(setGarantiaProdutoTecnico.isEmpty()) return;

		//Pesquisa as garantias do Produto Técnico associadas aos produtos comerciais que estão sendo inseridos
		Map<Id, garantiaProduto__c> mapGarantiaProdutoTecnico = new Map<Id, GarantiaProduto__c>(
																[SELECT id, Garantia__c, (SELECT id, CurrencyIsoCode, LimiteCapitalMinimo__c, LimiteCapitalMaximo__c
																			FROM LimitesGarantiaProduto__r)																				
																FROM GarantiaProduto__c
																WHERE id IN : setGarantiaProdutoTecnico]);

			
		if(mapGarantiaProdutoTecnico.isEmpty()) return;

		Set<Id> setGarantias = new Set<Id>();

		for(GarantiaProduto__c garantiaProduto : mapGarantiaProdutoTecnico.values()){
			setGarantias.add(garantiaProduto.Garantia__c);
		}

		Map<id, Garantia__c> mapGarantias = new Map<Id, Garantia__c>([SELECT id, name 
													  				FROM Garantia__c 
																	WHERE id = : setGarantias]);

		if(mapGarantias.IsEmpty()) return;

		for(garantiaProduto__c garantiaProdutoNew : listGarantiaProdutoComercial){

			if(!mapGarantiaProdutoTecnico.containsKey(garantiaProdutoNew.garantiaProduto__c)) continue;

			garantiaProduto__c garantiaProdutoTecnico = mapGarantiaProdutoTecnico.get(garantiaProdutoNew.garantiaProduto__c);

			//Compara a moeda da garantia do produto comercial que está sendo inserida ou alterada com a moeda cadastrada no limite da garantia do produto técnico
			//Quando a moeda for igual, compara os campos limite mínimo da garantia e limite máximo da garantia.			
			Map<String, LimiteGarantiaProduto__c> mLimiteGarantiaProdutoTecnico = new Map<String, LimiteGarantiaProduto__c>();

			for(LimiteGarantiaProduto__c limiteGP : garantiaProdutoTecnico.LimitesGarantiaProduto__r){
				mLimiteGarantiaProdutoTecnico.put(limiteGP.CurrencyIsoCode, limiteGP);
			}
			if (mLimiteGarantiaProdutoTecnico.containsKey(garantiaProdutoNew.CurrencyIsoCode)){
				LimiteGarantiaProduto__c limiteGP = mLimiteGarantiaProdutoTecnico.get(garantiaProdutoNew.CurrencyIsoCode);

				if(garantiaProdutoNew.LimiteCapitalMinimo__c < limiteGP.LimiteCapitalMinimo__c){
	
					garantiaProdutoNew.LimiteCapitalMinimo__c.addError('O limite de capital mínimo informado não pode ser menor do que o valor cadastrado na garantia do produto técnico.');						
				}else if(garantiaProdutoNew.LimiteCapitalMaximo__c > limiteGP.LimiteCapitalMaximo__c){

					garantiaProdutoNew.LimiteCapitalMaximo__c.addError('O limite de capital máximo informado não pode ser maior do que o valor cadastrado na garantia do produto técnico.');
				}
			//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
			}else if(!garantiaProdutoTecnico.LimitesGarantiaProduto__r.isEmpty()){
				String nomeGarantia = '';			
				if(mapGarantias.containsKey(garantiaProdutoTecnico.garantia__c)) nomeGarantia = mapGarantias.get(garantiaProdutoTecnico.garantia__c).name;
								
				garantiaProdutoNew.currencyIsoCode.addError('A garantia ' + nomeGarantia + ' não foi vinculada ao produto comercial pois a moeda não foi cadastrada corretamente.');
			}
			//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
		}
	}

	//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem

	/**
	 * Verifica se a flag de Capital de risco pode ser ativada, de acordo com o os cadastros de riscos da garantia
	 *
	 */
	//public void validarExistenciaRiscoGarantia(List<GarantiaProduto__c> lstGarantiasProduto) {
	//	Set<Id> garantiaProdutoIds = new Set<Id>();
	//	Map<Id, List<RiscoGarantia__c>> mapRiscosGarantia = new Map<Id, List<RiscoGarantia__c>>();

	//	for(GarantiaProduto__c garantia : lstGarantiasProduto){
	//		if(garantia.CapitalRiscos__c){
	//			garantiaProdutoIds.add(garantia.Id);
	//			mapRiscosGarantia.put(garantia.Id, new List<RiscoGarantia__c>());
	//		}
	//	}

	//	//Separa os riscos de acordo com as garantias de produto
	//	for(RiscoGarantia__c risco : RiscoBO.getInstance().buscarRiscosGarantiasPorGarantiaProduto(garantiaProdutoIds)) {
	//		mapRiscosGarantia.get(risco.GarantiaProduto__c).add(risco);
	//	}

	//	for(GarantiaProduto__c garantia : lstGarantiasProduto){
	//		if(garantia.CapitalRiscos__c){
	//			if(mapRiscosGarantia.get(garantia.Id).isEmpty()){
	//				garantia.addError('Não é possível marcar o campo \'Capital por riscos?\', pois não foram cadastrados Riscos da garantia.');
	//			}
	//		}
	//	}
	//}
}