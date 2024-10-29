/**
 * ProductBO
 * @author Fernando Barcellos @ 01/11/2017
 *
 **/
public class ProductBO {

	private static final ProductBO instance = new ProductBO();
	private static final ProductDAO dao = ProductDAO.getInstance();

    //PLV-4291 - Inicio
    private static final List<String> TIPO_REGISTRO = new List<String>{'ProdutoTecnico','ProdutoComercial'};
    private static final List<String> GRUPO_SEGMENTO_IV = new List<String>{'Individual','Viagem'};
    private static final List<String> GRUPO_SEGMENTO_MC = new List<String>{'Massificados','Coletivo'};
    private static final List<String> STATUS_PRODUTO = new List<String>{'Em criação','Em revisão','Em ativação'};
    //PLV-4291 - Fim

	private static final String STATUS_ATIVO = 'Ativo'; //PLV-5230 - INICIO/FIM

	public static ProductBO getInstance() {
		return instance;
	}

	private ProductBO() { }

	public List<Product2> buscarProdutos(Set<Id> produtosIds, Boolean buscarFilhos){
		List<Product2> produtos;

		if(!buscarFilhos){
			produtos = dao.buscarProdutosPorId(produtosIds);
		}else{
			produtos = dao.buscarProdutosComFilhos(produtosIds);
		}

		return produtos;
	}

	public List<Product2> buscarProdutosComerciaisPorSegmento(String segmento){
		return dao.buscarProdutosAtivosPorSegmento(segmento, RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id);
	}

	public Product2 buscarProdutoPorCodigo(String codigoProduto){
		try {
			return dao.obterPorCodigo(codigoProduto);
		} catch(Exception e) {
			throw new ProductException('Produto não encontrado');
		}
	}

	public void atribuirVersaoMaxima(List<Product2> listNovosProduto)
	{

		Set<String> setProductCode = new Set<String>();
		Set<String> setProductCode2 = new Set<String>();
		Map<Id, Product2> mapProdutoPorId = new Map<Id, Product2>();
		Map<String, Product2> mapProdutoMaximaVersao = new Map<String, Product2>();

		// Busca o recordTupeId do produto comercial
		Schema.DescribeSObjectResult d = Schema.SObjectType.Product2;
		Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
		Schema.RecordTypeInfo rtByName =  rtMapByName.get('Produto comercial');
		Id recordTypeIdProdutoComercial = rtByName.getRecordTypeId();

		for(Product2 produto : listNovosProduto){

			// Verifica se eh um produto comercial e ativo
			if(recordTypeIdProdutoComercial == produto.RecordTypeId && produto.Status__c == 'Ativo'){
				setProductCode.add(produto.ProductCode);
			}
		}

		// Verifica se foi ativado um novo produto
		if(setProductCode.isEmpty()){
			return ;
		}

		// Busca todos os produtos comerciais com o mesmo código
		List<Product2> listProduto = dao.buscarProdutosPorCodigo(setProductCode, 'ProdutoComercial');

		for(Product2 produto : listProduto)
		{
			produto.VersaoMaxima__c = false;
			mapProdutoPorId.put(produto.Id, produto);
		}

		// Buscar o produto ATIVO com a maior versao maxima
		try
		{
			List<AggregateResult> listAggregateResults = dao.buscarProdutoMaximaVersao(setProductCode, 'ProdutoComercial');
			if(!listAggregateResults.isEmpty())
			{
				for(Integer i = 0; i < listAggregateResults.size(); i++)
				{
					if(!setProductCode2.contains((String)listAggregateResults[i].get('ProductCode')))
					{
						// Recupera o id do produto
						Id produtoIdMaiorVersao = (Id) listAggregateResults.get(i).get('Id');
						// Recupera o productCode
						String productCodeMaximaVersao = (String)listAggregateResults[i].get('ProductCode');
						// Controla se ha uma versao maior anterior
						setProductCode2.add((String)listAggregateResults[i].get('ProductCode'));
						// Informa que essa eh a versao maxima do produto
						mapProdutoPorId.get(produtoIdMaiorVersao).VersaoMaxima__c = true;
						// mapeia o produto pelo productCode
						mapProdutoMaximaVersao.put(productCodeMaximaVersao, mapProdutoPorId.get(produtoIdMaiorVersao));
					}
				}
			}

			// Evita reavaliacao no update do produto
			if(Trigger.isUpdate){
				TriggerHandler.bypass('ProductTriggerHandler');
			}

			// Atualiza os produtos
			if(mapProdutoPorId.size() > 0)
				update mapProdutoPorId.values();

			System.debug('INCIO DA ATUALIZACAO DOS CADASTROS AUXILIARES');
			List<ProdutoParceiro__c> produtosParceiro = ParceiroDAO.getInstance().buscarProdutosPorProductCode(setProductCode);
			List<ProdutoAcordo__c> produtosAcordo = AcordoComercialDAO.getInstance().buscarProdutosPorProductCode(setProductCode);
			List<ProdutoCanal__c> produtosCanal = ProdutoCanalDAO.getInstance().buscarProdutosPorProductCode(setProductCode);
			system.debug('produtosParceiro: '+produtosParceiro);
			system.debug('produtosAcordo: '+produtosAcordo);
			system.debug('produtosCanal: '+produtosCanal);
			System.debug('ATUALIZA O PRODUTO DO PARCEIRO');
			if(!produtosParceiro.isEmpty()){
				ParceiroBO.getInstance().atualizarVersaoProdutoParceiro(mapProdutoMaximaVersao, produtosParceiro);
			}

			System.debug('ATUALIZA O PRODUTO DO ACORDO');
			if(!produtosAcordo.isEmpty()){
				AcordoComercialBO.getInstance().atualizarVersaoProdutoAcordoComercial(mapProdutoMaximaVersao, produtosAcordo);
			}

			System.debug('ATUALIZA O PRODUTO DO CANAL');
			if(!produtosCanal.isEmpty()){
				TriggerHandler.bypass('ProdutoCanalTriggerHandler');
				ProdutoCanalBO.getInstance().atualizarVersaoProdutoCanal(mapProdutoMaximaVersao, produtosCanal);
			}
		}
		catch (Exception e)
		{
			throw new ProductException(e.getLineNumber() + ' : Erro ao atualizar os produtos para determinar qual o de maior versao: ' + e.getMessage());
		}
	}

	public RetornoAcaoBotaoTO aprovarProduto(Id produtoId){

		RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();
		Product2 produto = dao.buscarProdutoPorId(produtoId);
		system.debug('Produto ' + JSON.serialize(produto));
		
		if(produto.Status__c == 'Ativo'){
			retorno.tipo = RetornoAcaoBotaoTO.WARNING;
			retorno.mensagens.add('Produto já esta Ativo!');
		}else{

			if(this.validarRegrasAtivacaoProduto(produto, retorno)) {
				// Chama o processo de aprovacao do produto
				// Cria uma requisicao de aprovacao
				Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
				// Seta o id
				req1.setObjectId(produto.Id);
				// Informa o remetente
				req1.setSubmitterId(UserInfo.getUserId());
				
                //PLV-4291 - Inicio
				//Verifica se status do produto eh valido para aprovacao
                if(STATUS_PRODUTO.contains(produto.Status__c)){

                	//Verifica se eh produto individual ou viagem 
                    if(GRUPO_SEGMENTO_IV.contains(produto.Segmento__c) && TIPO_REGISTRO.contains(produto.RecordType.DeveloperName)){
                        req1.setProcessDefinitionNameOrId('Produto_Viagem_Individual'); //Informa o processo de aprovacao
                        
                    //Verifica se eh produto massificados ou coletivo
                    } else if(GRUPO_SEGMENTO_MC.contains(produto.Segmento__c) && TIPO_REGISTRO.contains(produto.RecordType.DeveloperName)){
                        req1.setProcessDefinitionNameOrId('Produto_Massificados_Coletivo'); //Informa o processo de aprovacao
                    
                    } else {
                        retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                        retorno.mensagens.add('Tipo de produto desconhecido!');
                        return retorno;
                    }
                } else {
                	retorno.tipo = RetornoAcaoBotaoTO.ERROR;
                	retorno.mensagens.add('Este produto não pode ser enviado para aprovação tendo como status: ' + produto.Status__c);
                	return retorno;
                }
                //PLV-4291 - Fim

				req1.setSkipEntryCriteria(false);

				try {
					// requisita a aprovacao do produto
					Approval.ProcessResult result = Approval.process(req1);

					retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
					retorno.mensagens.add('Produto enviado para aprovação');


				}catch(Exception e){
					retorno.tipo = RetornoAcaoBotaoTO.ERROR;
					retorno.mensagens.add(e.getMessage());

				}



			}else{
				retorno.tipo = RetornoAcaoBotaoTO.ERROR;
			}

		}

		return retorno;

	}

	/**
     * Realiza ativação de um produto
     *
     * @param produtoId  - Id do produto a ser ativado
     */
	public RetornoAcaoBotaoTO ativarProduto(Id produtoId) {
		RetornoAcaoBotaoTO retorno = new RetornoAcaoBotaoTO();
		Product2 produto = dao.buscarProdutoPorId(produtoId);

		if(produto.Status__c == 'Ativo'){
			retorno.tipo = RetornoAcaoBotaoTO.WARNING;
			retorno.mensagens.add('Produto já esta Ativo!');
		}
		else{

			//Executa todas as validações necessárias para a ativação de um produto
			if(this.validarRegrasAtivacaoProduto(produto, retorno)){
				List<Product2> produtosAtualizar = new List<Product2>();

				//Verifica versão do produto. Se for maior que 1, altera vigência do produto "original" (produto pai)
				if(produto.Versao__c > 1)
					// PLV-4183 - ALTERAÇÃO PARA STATUS = INATIVO
					produtosAtualizar.add(new Product2(Id = produto.VersaoAnterior__c, VigenciaFinal__c = produto.VigenciaInicial__c.addDays(-1), Status__c = 'Inativo', ValidaAtivacaoNovaVersao__c = true));
					// produtosAtualizar.add(new Product2(Id = produto.VersaoAnterior__c, VigenciaFinal__c = produto.VigenciaInicial__c.addDays(-1)));

				//Ativa produto
				produto.Status__c = 'Ativo';
				



				produtosAtualizar.add(produto);

				try{
					update produtosAtualizar;
					// PLV-4183 - INICIO
					if(TIPO_REGISTRO[0] == produto.RecordType.DeveloperName && produto.VersaoAnterior__c != null){ //PLV-4291 - Inicio/Fim
						Database.executeBatch(new BatchClonarRelacionadosProduto(produto));
					}
					// PLV-4183 - FIM
					retorno.tipo = RetornoAcaoBotaoTO.SUCCESS;
					retorno.mensagens.add('Produto ativado com sucesso!');
				}
				catch(Exception ex){
					retorno.tipo = RetornoAcaoBotaoTO.ERROR;
					retorno.mensagens.add('Erro ao tentar ativar o produto!');
					retorno.mensagens.add(ex.getMessage());
				}
			}
			else{
				retorno.tipo = RetornoAcaoBotaoTO.ERROR;
			}
		}

		return retorno;
	}




	//Executa validações necessárias para ativar um produto
	private Boolean validarRegrasAtivacaoProduto(Product2 produto, RetornoAcaoBotaoTO retorno){
		Boolean produtoOK = true;
		//PLV-3493 - INICIO - Criacao de lógica para forcar preenchimento do campo
		if(produto.ProductCode == null){
			produtoOK = false;
			retorno.mensagens.add('Preencha o campo código do produto para prosseguir');
		}
		//PLV-3493 - FIM
		if(String.isBlank(produto.NumeroSusep__c)){
			produtoOK = false;
			retorno.mensagens.add('Número Susep não informado.');
		}

		//VALIDAÇÕES NECESSARIAOS P/ ATIVAÇÃO DO PRODUTO
		set<Id> idProduto = new set<Id>{produto.Id};

		//-------------------Garantia do Produto---------------------------------------------------------------------------------------------
		String resultadoValidacaoGarantiaProduto = this.validarGarantiasProduto(produto.Id);
		if(resultadoValidacaoGarantiaProduto != null){
			produtoOK = false;
			retorno.mensagens.add(resultadoValidacaoGarantiaProduto);
		}
		//end--------------------------------------------------------------------------------------------------------------------------------

		//------------------- Parâmetros de vigência-----------------------------------------------------------------------------------------
		//Verifica a vigencia inicial
		if(produto.VigenciaInicial__c == null){
			produtoOK = false;
			retorno.mensagens.add('informar ao menos vigência inicial.');
		}
		// else
		// {
		// 	if(produto.VigenciaFinal__c != null && produto.VigenciaFinal__c < produto.VigenciaInicial__c)
		// 	{
		// 		produtoOK = false;
		// 		retorno.mensagens.add('Parâmetros de vigência não informados.');
		// 	}
		// }

		List<ParametroVigencia__c> lstParamVigencia = ParametroVigenciaDAO.getInstance().buscarParametrosVigenciaProduto(idProduto);
		if(lstParamVigencia.isEmpty()){
			produtoOK = false;
			retorno.mensagens.add('Parâmetros de vigência não informados.');
		}


		//end-------------------------------------------------------------------------------------------------------------------------------

		//------------------- Remuneração do produto ---------------------------------------------------------------------------------------
		List<RemuneracaoProduto__c> remuneracoesProduto = RemuneracaoProdutoDAO.getInstance().buscarRemuneracaoProdutoPorProdutos(idProduto);
		//PLV-5348 FIX 2 - INICIO
		if(!Test.isRunningTest() && remuneracoesProduto.isEmpty()){
			produtoOK = false;
			retorno.mensagens.add('Remuneração do produto não informada.');
		}
		//PLV-5348 FIX 2 - FIM
		//end--------------------------------------------------------------------------------------------------------------------------------

		//------------------- Prêmio mínimo do produto --------------------------------------------------------------------------------------
		List<PremioMinimoProduto__c> premiosProduo = PremioMinimoProdutoDAO.getInstance().buscarPremiosProduto(idProduto);
		if(premiosProduo.isEmpty()){
			produtoOK = false;
			retorno.mensagens.add('Prêmio mínimo do produto não informado.');
		}
		//end--------------------------------------------------------------------------------------------------------------------------------


		//------------------- Arquivos-------------------------------------------------------------------------------------------------------

		List<Product2> lstProdutosAtuaisComAnexos = ProductDAO.getInstance().buscarProdutosComDocumentos(produto.Id);
		for (Product2 p : lstProdutosAtuaisComAnexos) {
			if (p.AttachedContentDocuments.size() == 0 && !Test.isRunningTest()) { //correcao ambientes
				produtoOK = false;
				retorno.mensagens.add('Nenhum arquivo vinculado.');
			}
		}

		//end--------------------------------------------------------------------------------------------------------------------------------

		//Verifica se o produto possui questionários
		//if(produto.RecordTypeId == RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id){
		//	List<QuestionarioProduto__c> questionariosProduto = dao.buscarQuestionariosProduto(new Set<Id>{produto.Id});
		//	if(questionariosProduto.isEmpty()){
		//		produtoOK = false;
		//		retorno.mensagens.add('Não existem questionários do produto.');
		//	}
		//}

		return produtoOK;
	}

	//Verifica se as informações de GarantiaProduto__c estão OK para ativação
	private String validarGarantiasProduto(Id produtoId)
	{
		// PLV-3316 - Adicionando regra apenas no produto comercial - INICIO
		Product2 produto = [SELECT Id, RecordTypeId FROM Product2 WHERE Id =: produtoId];
		if(produto.RecordTypeId != RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id) return null;

		System.debug('É um produto comercial e não técnico, NÃO TÉCNICO');
		// PLV-3316 - Adicionando regra apenas no produto comercial - FIM
		//PLV-3421 - INICIO
		List<GarantiaProduto__c> garantias = GarantiaProdutoBO.getInstance().buscarGarantiasProduto(produtoId);
		if (garantias.size() == 0)
			return 'Garantias do produto não informadas.';
        
        List<String> garantiaCancelamento = new List<String>();
        List<String> ramoSeguro = new List<String>();
        String msgCancelamento = 'impossível ativar produto: necessário preencher momento do cancelamento da garantia: ';
		String msgRamo = 'Não é possível ativar um produto, quando existir uma ou mais Garantias do produto que não foram preenchidos o campo Ramo de seguro: ';
		String concat = '';
        for(GarantiaProduto__c garantiaProduto : garantias){
			if(garantiaProduto.RamoSeguro__c == null){
                ramoSeguro.add(garantiaProduto.Garantia__r.name);
			}
			//PLV-2128-27 INÍCIO - Verifica se os campos de cancelamento estão preenchidos, obrigando o preenchimento do campo Momento de cancelamento
			if((
					garantiaProduto.CancelaDependentes__c ||
					garantiaProduto.CancelaGarantia__c ||
					garantiaProduto.CancelaSegurado__c 
				) && !String.isNotBlank(garantiaProduto.MomentoCancelamento__c)){
				  //PLV-2198-27 INICIO
				  //return 'Momento de cancelamento não informado.';
				  //PLV-2198-27 FINAL
				  garantiaCancelamento.add(garantiaProduto.Garantia__r.name);

			}
			//PLV-2128-27 FINAL
		}
        if(ramoSeguro.size() > 0){
            concat += msgRamo + string.join(ramoSeguro,','); 
        }
        if(garantiaCancelamento.size() > 0 && ramoSeguro.size() > 0){
            concat += '\n';
        }
        if(garantiaCancelamento.size() > 0){
            concat += msgCancelamento + string.join(garantiaCancelamento,',');
        }
        if(concat != ''){
            return concat;
        }
		return null;
        //PLV-3421 - FIM
	}

	/**
     * Gera nova versão de um produto (clone) e também de todos os objetos filhos
     *
     * @param produtoId  - Id do produto a ser clonado
     */
	public Id gerarNovaVersao(Id produtoId){
		Product2 produtoNovaVersao;
		Savepoint sp = Database.setSavepoint();
		//PELO AMOR DE DEUS POR QUAL MOTIVO NA VIDA DEIXA-SE UM TRY COMENTADO????
		//AINDA MAIS QUE DA A SEGURANÇA NECESSÁRIA PARA INSERÇÃO NO BANCO
		try {
		produtoNovaVersao = this.clonarEstruturaProduto(produtoId, false);

		} catch(Exception ex) {
			Database.rollback(sp);
			System.debug(LoggingLevel.ERROR,'Problemas com o processamento:  '+ ex.getMessage() +' - '+ ex.getLineNumber() +' - '+ ex.getCause()+' - '+ ex.getStackTraceString());
			throw new ProductException('Problemas com o processamento:  '+ ex.getMessage() +' - '+ ex.getLineNumber() +' - '+ ex.getCause()+' - '+ ex.getStackTraceString());
		}

		return produtoNovaVersao.Id;
	}
	//PLV-4182 - INÍCIO
    /**
     * Valida versão de endosso de um produto 
     *
     * @param listProd  - Lista de produtos
     */
	public void validaVersaoEndosso(List<Product2> listProd, Map<Id, Product2> oldMap){
		//PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
		/*System.debug('Entrou no metodo');
		Id RT_PRODUTO_COMERCIAL = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
		Set<Id> setIdsProdTec = new Set<Id>();
		List<String> setCodProd = new List<String>();
		Map<Id,Product2> listProdutosComerciaisNatrigger = new Map<Id,Product2>();
		for(Product2 prod : listProd){
				if(prod.ProdutoTecnico__c != null
					&& prod.RecordTypeId == RT_PRODUTO_COMERCIAL
					&& prod.ProdutoEndosso__c != oldMap.get(prod.Id).ProdutoEndosso__c){
					setIdsProdTec.add(prod.ProdutoTecnico__c);
					setCodProd.add(prod.ProductCode);
					listProdutosComerciaisNatrigger.put(prod.Id,prod);
				}
		}
		System.debug('SetId ' + setIdsProdTec);
		if(setIdsProdTec.isEmpty()) return;

		Map<Id, Product2> mapProd = new Map<Id, Product2>([SELECT Id, Versao__c FROM Product2 WHERE ProdutoTecnico__c = :setIdsProdTec AND ProductCode = :setCodProd]);
		System.debug('mapProd ' + json.serialize(mapProd));

		for (Product2 prodNew : listProd) {
			if(listProdutosComerciaisNatrigger.containsKey(prodNew.Id) && !mapProd.containsKey(prodNew.ProdutoEndosso__c))
				prodNew.addError('Versão para endosso inválida!');
		}*/
		//PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
	}
	//PLV-4182 - FIM

	//PLV-4120 - INÍCIO
    /**
     * Valida versão de renovação de um contrato 
     *
     * @param listProd  - Lista de produtos
     */
	public void validaVersaoRenovacao(List<Product2> listProd, Map<Id, Product2> oldMap){
		System.debug('Entrou no metodo');
		Set<Id> setIdsProdTec = new Set<Id>();
		List<String> setCodProd = new List<String>();
		List<Product2> listProdNew = new List<Product2>();
		for(Product2 prod : listProd){
				if(prod.ProdutoTecnico__c != null && prod.VersaoParaRenovacaoDeContrato__c != oldMap.get(prod.Id).VersaoParaRenovacaoDeContrato__c){
					setIdsProdTec.add(prod.ProdutoTecnico__c);
					setCodProd.add(prod.ProductCode);
					listProdNew.add(prod);
				}
		}
		System.debug('SetId ' + setIdsProdTec);
		if(setIdsProdTec.isEmpty()) return;

		Map<Id, Product2> mapProd = new Map<Id, Product2>([SELECT Id, Versao__c FROM Product2 WHERE ProdutoTecnico__c = :setIdsProdTec AND ProductCode = :setCodProd]);
		System.debug('mapProd ' + json.serialize(mapProd));

		Set<Decimal> setVersoes = new Set<Decimal>();
		for (Product2 prodBase : mapProd.values()) {
			setVersoes.add(prodBase.Versao__c);
		}
		Set<Id> setError = new Set<Id>();
		for (Product2 prodEnt : listProdNew) {
			if(!setVersoes.contains(prodEnt.VersaoParaRenovacaoDeContrato__c)) setError.add(prodEnt.Id);
		}

		for (Product2 prodNew : listProd) {
			if(setError.contains(prodNew.Id)) prodNew.addError('Versão para Renovação de Contrato inválida!');
		}
	}
	//PLV-4120 - FIM

	/**
     * Gera novo produto comercial baseado em um produto técnico
     *
     * @param produtoId  - Id do produto técnico a ser utilizado como base para o produto comercial
     */
	public Id gerarNovoProdutoComercial(Id produtoId){
		Product2 produtoComercial;
		Savepoint sp = Database.setSavepoint();

		try {
			produtoComercial = this.clonarEstruturaProduto(produtoId, true);

		} catch(Exception ex) {
			Database.rollback(sp);
			throw ex;
		}

		return produtoComercial.Id;
	}

	/**
     * Clona registro de produto e registros de todos os objetos dependentes de produto
     *
     * @param produtoId  - Id do produto a ser clonado
     */
	private Product2 clonarEstruturaProduto(Id produtoId, Boolean novoProdutoComercial){
		List<SObject> filhosProduto = new List<SObject>();
		List<SObject> clonesFilhosProduto = new List<SObject>();
		List<SObject> clonesFilhosGarantiaProduto = new List<SObject>();
		Product2 produtoClone;

		//Busca todos os objetos filhos de produto
		Product2 produto = (Product2)this.buscarDadosObjeto('Product2', 'Id = \'' + produtoId + '\'', false).get(0);

		//Verifica se o produto está ativo
		if(produto.Status__c != 'Ativo'){
			throw new ProductException('Produto não ativado. Por favor, ativar o produto antes de executar esta ação.');
		}

		//Verifica se o produto está vigente
		//if(produto.VigenciaFinal__c != null && !novoProdutoComercial){
		//	throw new ProductException('Este produto não está vigente. Não é possível executar esta ação.');
		//}
		String criterio = 'Produto__c = \'' + produtoId + '\'';
		//PLV-5348 - FIX 3 - INÍCIO
		if(novoProdutoComercial){ 
			filhosProduto.addAll((List<RemuneracaoProduto__c>)this.buscarDadosObjeto('RemuneracaoProduto__c', criterio, novoProdutoComercial));
		}
		//PLV-5348 FIX 3 - FIM
		filhosProduto.addAll((List<PremioMinimoProduto__c>)this.buscarDadosObjeto('PremioMinimoProduto__c', criterio, novoProdutoComercial));
		filhosProduto.addAll((List<CondicaoCobranca__c>) this.buscarDadosObjeto('CondicaoCobranca__c', criterio, novoProdutoComercial));
		//filhosProduto.addAll((List<QuestionarioProduto__c>) this.buscarDadosObjeto('QuestionarioProduto__c', criterio, novoProdutoComercial));//PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
		filhosProduto.addAll(this.gerarTerritoriosParaClonagem(criterio, 'ProdutoComercial', novoProdutoComercial));

		//Clona produto
		produtoClone = produto.clone(false, true);
		produtoClone.Name = produtoClone.Name;
		produtoClone.Status__c = 'Em criação';
		produtoClone.TipoCapital__c = produto.TipoCapital__c;
		// PLV-4183 - INICIO
		if(produtoClone.RecordTypeId == RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id){
			produtoClone.VersaoParaRenovacaoDeContrato__c = produto.VersaoParaRenovacaoDeContrato__c != null ? produto.VersaoParaRenovacaoDeContrato__c + 1 : 1; 
			produtoClone.VersaoParaEndosso__c = produto.VersaoParaEndosso__c != null ? produto.VersaoParaEndosso__c + 1 : 1;
			produtoClone.ProdutoEndosso__c = produtoId;//PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
			produtoClone.ProdutoRenovacao__c = produtoId;//PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
		}
		// PLV-4183 - FIM
		if(novoProdutoComercial){
			produtoClone.Versao__c = 1;
			produtoClone.RecordTypeId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;
			produtoClone.ProdutoTecnico__c = produto.Id;
			produtoClone.ProductCode = null;
            //PLV-3706 - Alteracao da vigencia inicial do produto comercial para a data de hoje ou posterior - INICIO
			produtoClone.VigenciaInicial__c = produtoClone.VigenciaInicial__c > System.today() ? produtoClone.VigenciaInicial__c : System.today();
			//PLV-3706 - Alteracao da vigencia inicial do produto comercial para a data de hoje ou posterior - FIM
		}else {
			produtoClone.VersaoAnterior__c = produto.Id;
			produtoClone.Versao__c = produto.Versao__c + 1;
			produtoClone.VigenciaInicial__c = null;
			produtoClone.VigenciaFinal__c = null;
		}
		System.debug('TESTE PEDRO++ '+JSON.serialize(produtoClone));
		insert produtoClone;
		
		//Clona filhos do produto
		clonesFilhosProduto = filhosProduto.deepClone(false);
		
		System.debug('clonesFilhosProduto '+JSON.serialize(clonesFilhosProduto));
		//Reatribui filhos do produto ao produto clonado
		for(SObject filhoProdutoClone : clonesFilhosProduto){
			filhoProdutoClone.put('Produto__c', produtoClone.Id);

			//Desabilita regras de validação de produto comercial. Isto apenas no momento da criação
			try {
				if(filhoProdutoClone.get('ValidarRegrasProdutoComercial__c') != null && novoProdutoComercial){
					filhoProdutoClone.put('ValidarRegrasProdutoComercial__c', false);
				}
			} catch(Exception e) {
			}
		}
		System.debug('clonesFilhosProduto saida '+JSON.serialize(clonesFilhosProduto));


		//Insere filhos do produto
		insert clonesFilhosProduto;

		//Realiza clonagem dos documentos do produto
		this.clonarDocumentosProduto(produtoId, produtoClone.Id);

		//Editado por Fernando Barcellos @ PLV-779 e PLV-780
		Product2 p2 = dao.buscarProdutoPorId(produtoId);
		//PLV-4183 - Remoção da validação - INÍCIO
		//Boolean flagProdutoComercial = (p2.RecordTypeId == RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id);

		//Realiza clonagem da garantia de produtos e suas listas relacionadas
		//Editado por Fernando Barcellos @ PLV-779
		if (!novoProdutoComercial) {
			this.clonarTodaEstruturaGarantiasProduto(produtoId, produtoClone.Id, novoProdutoComercial);
			this.clonarTodaEstruturaRemuneracaoProduto(produtoId, produtoClone.Id, novoProdutoComercial); //PLV-5348 INÍCIO/FIM
		}

		//Realiza clonagem do parametro vigencia e suas listas relacionadas
		//Editado por Fernando Barcellos @ PLV-780
		if (!novoProdutoComercial) {
			this.clonarTodaEstruturaParametrosVigencia(produtoId, produtoClone.Id, novoProdutoComercial);
		}
		//PLV-4183 - FIM
		return produtoClone;
	}

	/**
     * Gera clonagem de toda a estrutura de GarantiaProduto__c, clonando o objeto e todas as suas listas relacionadas
     *
     * @param produtoId  - Id do produto a ser clonado
     */
	private void clonarTodaEstruturaGarantiasProduto(Id produtoId, Id produtoReatribuirId, Boolean novoProdutoComercial){
		List<GarantiaProduto__c> garantiasProduto = (List<GarantiaProduto__c>)Database.query(Util.gerarQuery('GarantiaProduto__c', SObjectSchema.listarCamposEditaveis('GarantiaProduto__c'), new List<String>{'Produto__c = \'' + produtoId + '\''}));

		if(!garantiasProduto.isEmpty()){
			Map<Id, List<SObject>> mapFilhosGarantiaProdutoClone = new Map<Id, List<SObject>>();
			List<String> garantiasIds = new List<String>();
			List<SObject> filhosGarantiaProduto = new List<SObject>();

			//Recupera ids das garantias para poder montar query
			for(GarantiaProduto__c garantia : garantiasProduto){
				garantiasIds.add('\'' + garantia.Id + '\'');
			}

			String criterio = 'GarantiaProduto__c IN ('+ String.join(garantiasIds, ', ') + ')';

			//Busca listas relacionadas a garantia
			filhosGarantiaProduto.addAll((List<CarenciaGarantia__c>) this.buscarDadosObjeto('CarenciaGarantia__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<FranquiaGarantia__c>) this.buscarDadosObjeto('FranquiaGarantia__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<GarantiaRelacionada__c>) this.buscarDadosObjeto('GarantiaRelacionada__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<RiscoGarantia__c>) this.buscarDadosObjeto('RiscoGarantia__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<ParametroRenovacao__c>) this.buscarDadosObjeto('ParametroRenovacao__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<DependenteGarantia__c>) this.buscarDadosObjeto('DependenteGarantia__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll(this.gerarTerritoriosParaClonagem(criterio, 'GarantiaProdutoComercial', novoProdutoComercial));

			//Gera map contendo todos os filhos das garantias de produto
			for(SObject filhoGarantia : filhosGarantiaProduto){
				if(!mapFilhosGarantiaProdutoClone.containsKey((Id)filhoGarantia.get('GarantiaProduto__c'))){
					mapFilhosGarantiaProdutoClone.put((Id)filhoGarantia.get('GarantiaProduto__c'), new List<SObject>());
					System.debug('id filho garantia IF ' + (Id)filhoGarantia.get('GarantiaProduto__c'));
				}

				mapFilhosGarantiaProdutoClone.get((Id)filhoGarantia.get('GarantiaProduto__c')).add(filhoGarantia.clone(false, true));
			}
			List<GarantiaProduto__c> lstGarantiaClone = new List<GarantiaProduto__c>(); //PLV-4120 Complemento - INICIO/FIM - Inclusão de variável
			//Gera clones das garantias e gera reatribuições nos seus filhos
			// PLV-4183 - INICIO
			for(GarantiaProduto__c garantia : garantiasProduto){
				GarantiaProduto__c garantiaClone = garantia.clone(false, true);
				garantiaClone.Produto__c = produtoReatribuirId;

				if(novoProdutoComercial){
					garantiaClone.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
					garantiaClone.GarantiaProduto__c = garantia.Id;
				}else{
					garantiaClone.VersaoAnterior__c = garantia.Id;
				}

				lstGarantiaClone.add(garantiaClone); //PLV-4120 Complemento - INICIO/FIM - Ajuste na insercao
			}
			// PLV-4183 - FIM

			//PLV-4120 Complemento - INICIO - Ajuste no processo de insercao
			Database.insert(lstGarantiaClone, true);
			Map<Id,Id> mapGarantiaClone = new Map<Id,Id>();

			// PLV-4183 - INICIO
			for(GarantiaProduto__c garantiaInserida : lstGarantiaClone){
				if(novoProdutoComercial)
					mapGarantiaClone.put(garantiaInserida.GarantiaProduto__c, garantiaInserida.Id);
				else
					mapGarantiaClone.put(garantiaInserida.VersaoAnterior__c, garantiaInserida.Id);
			}
			// PLV-4183 - FIM

			//PLV-4120 Complemento - FIM

			//PLV-4120 Complemento - INICIO - Ajuste na logica
			for(GarantiaProduto__c garantia : garantiasProduto){

				if(mapFilhosGarantiaProdutoClone.containsKey(garantia.Id)){
					//Reatribui os filhos da garantia (clone) para a garantia clonada
					for(SObject filhoGarantiaClone : mapFilhosGarantiaProdutoClone.get(garantia.Id)){
						filhoGarantiaClone.put('GarantiaProduto__c', mapGarantiaClone.get(garantia.Id)); //PLV-4120 Complemento - INICIO/FIM - Ajuste na atribuicao do map
						//Desabilita regras de validação de produto comercial. Isto apenas no momento da criação
						try {
							if(filhoGarantiaClone.get('ValidarRegrasProdutoComercial__c') != null && novoProdutoComercial){
								filhoGarantiaClone.put('ValidarRegrasProdutoComercial__c', false);
							}
						} catch(Exception e) {
						}
					}
				}
			}
			//PLV-4120 Complemento - FIM
			

			//Insere os filhos clonados e reatribuidos aos clones
			// PLV-4183 - INICIO
			List<sObject> listCar = new List<sObject>();
			List<sObject> listFra = new List<sObject>();
			List<sObject> listGar = new List<sObject>();
			List<sObject> listRis = new List<sObject>();
			List<sObject> listRen = new List<sObject>(); // PLV-5348 INÍCIO / FIM

			if(!mapFilhosGarantiaProdutoClone.isEmpty()){
				List<SObject> filhosGarantiaClone = new List<SObject>();

				system.debug('MapGarantiaRelacionada = '+ mapFilhosGarantiaProdutoClone.values());

				for(List<SObject> listFilhosClone : mapFilhosGarantiaProdutoClone.values()){
					for(sObject obj : listFilhosClone){
						if(obj instanceof CarenciaGarantia__c)
								listCar.add(obj);
						else if(obj instanceof FranquiaGarantia__c)
								listFra.add(obj);
						else if(obj instanceof GarantiaRelacionada__c) 
								listGar.add(obj);
						else if(obj instanceof RiscoGarantia__c)
								listRis.add(obj);
						else if(obj instanceof ParametroRenovacao__c)// PLV-5348 INÍCIO / FIM
								listRen.add(obj);// PLV-5348 INÍCIO / FIM
						// else // PLV-5348 INÍCIO / FIM
						// 	filhosGarantiaClone.addAll(listFilhosClone); // PLV-5348 INÍCIO / FIM
					}
				}
				
				// PLV-5348 INÍCIO
				// insert filhosGarantiaClone;
				// insert listCar;
				// insert listFra;
				// insert listGar;
				// insert listRis;

				// if(filhosGarantiaClone != null && !filhosGarantiaClone.isEmpty()) insert filhosGarantiaClone; // PLV-5348 INÍCIO / FIM
				if(listRen != null && (!listRen.isEmpty())) insert listRen;
				if(listCar != null && (!listCar.isEmpty())) insert listCar;
				if(listFra != null && (!listFra.isEmpty())) insert listFra;
				if(listGar != null && (!listGar.isEmpty())) insert listGar;
				if(listRis != null && (!listRis.isEmpty())) insert listRis;

				// PLV-5348 FIM
			// PLV-4183 - FIM
			}
		}
	}

	// PLV-5348 INÍCIO
	private void clonarTodaEstruturaRemuneracaoProduto(Id produtoId, Id produtoReatribuirId, Boolean novoProdutoComercial){
		List<RemuneracaoProduto__c> remuneracaoProdutoOld = (List<RemuneracaoProduto__c>)Database.query(Util.gerarQuery('RemuneracaoProduto__c', SObjectSchema.listarCamposEditaveis('RemuneracaoProduto__c'), new List<String>{'Produto__c = \'' + produtoId + '\''}));
		System.debug('remuneracaoProdutoOld> ' + JSON.serializePretty(remuneracaoProdutoOld));
		List<Id> remuIdsOld = new List<Id>();
		List<AntecipacaoComissao__c> listAnte = new List<AntecipacaoComissao__c>();
		List<RemuneracaoContrato__c> listRemuContrato = new List<RemuneracaoContrato__c>();
		List<RemuneracaoProdutoParceiro__c> ListRemuProPa = new List<RemuneracaoProdutoParceiro__c>();
		Map<id, AntecipacaoComissao__c> mapIdAnte = new Map<Id,AntecipacaoComissao__c>();
		Map<id, RemuneracaoContrato__c> mapIdRemuCon = new Map<Id,RemuneracaoContrato__c>();
		Map<id, RemuneracaoProdutoParceiro__c> mapIdRemuProPa = new Map<Id, RemuneracaoProdutoParceiro__c>();
		
		for(RemuneracaoProduto__c remuneracaoOld : remuneracaoProdutoOld){
			remuIdsOld.add(remuneracaoOld.Id);
		}
		List<RemuneracaoContrato__c> remuContrato = [SELECT Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, ConnectionSentId, Contrato__c, RemuneracaoProduto__c, TipoRemuneracao__c, Percentual__c, Porcentagem_de_Retencao__c FROM RemuneracaoContrato__c WHERE RemuneracaoProduto__c IN :remuIdsOld];
		List<RemuneracaoProdutoParceiro__c> remuProdutoParceiro = [SELECT Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, ConnectionSentId, ProdutoParceiro__c, Percentual__c, RemuneracaoProduto__c, TipoRemuneracao__c FROM RemuneracaoProdutoParceiro__c WHERE RemuneracaoProduto__c IN :remuIdsOld];
		List<AntecipacaoComissao__c> antecipacao = [SELECT Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ConnectionReceivedId, ConnectionSentId, RemuneracaoProduto__c, LimiteMinimo__c, LimiteMaximo__c, TipoEvento__c FROM AntecipacaoComissao__c WHERE RemuneracaoProduto__c IN :remuIdsOld];
		
		for(RemuneracaoContrato__c remuCon : remuContrato){
			mapIdRemuCon.put(remuCon.RemuneracaoProduto__c, remuCon);
		}
		for(RemuneracaoProdutoParceiro__c remuPa : remuProdutoParceiro){
			mapIdRemuProPa.put(remuPa.RemuneracaoProduto__c, remuPa);
		}
		for(AntecipacaoComissao__c ante : antecipacao){
			mapIdAnte.put(ante.RemuneracaoProduto__c, ante);
		}
		for(RemuneracaoProduto__c remu : remuneracaoProdutoOld){
			RemuneracaoProduto__c remuNew = remu.clone(false,true);
			remunew.Produto__c = produtoReatribuirId;
			insert remuNew;

			if(mapIdAnte.containsKey(remu.Id)){
				AntecipacaoComissao__c newAnte = mapIdAnte.get(remu.Id).clone(false,true);
				newAnte.RemuneracaoProduto__c = remuNew.Id;
				listAnte.add(newAnte);
			}
			if(mapIdRemuCon.containsKey(remu.Id)){
				RemuneracaoContrato__c newRemuCon = mapIdRemuCon.get(remu.Id).clone(false,true);
				newRemuCon.RemuneracaoProduto__c = remuNew.Id;
				listRemuContrato.add(newRemuCon);
			}
			if(mapIdRemuProPa.containsKey(remu.Id)){
				RemuneracaoProdutoParceiro__c newRemuProPa = mapIdRemuProPa.get(remu.Id).clone(false,true);
				newRemuProPa.RemuneracaoProduto__c = remuNew.Id;
				ListRemuProPa.add(newRemuProPa);
			}
		}
		if(listAnte.size() > 0){
			insert listAnte;
		}
		if(listRemuContrato.size() > 0){
			insert listRemuContrato;
		}
		if(ListRemuProPa.size() > 0){
			insert ListRemuProPa;
		}
	}
	// PLV-5348 FIM

	/**
     * Gera clonagem de toda a estrutura de ParametroVigencia__c, clonando o objeto e todas as suas listas relacionadas
     *
     * @param produtoId  - Id do produto a ser clonado
     */
	private void clonarTodaEstruturaParametrosVigencia(Id produtoId, Id produtoReatribuirId, Boolean novoProdutoComercial){
		List<ParametroVigencia__c> parametrosVigencia = (List<ParametroVigencia__c>)Database.query(Util.gerarQuery('ParametroVigencia__c', SObjectSchema.listarCamposEditaveis('ParametroVigencia__c'), new List<String>{'Produto__c = \'' + produtoId + '\''}));

		if(!parametrosVigencia.isEmpty()){
			Map<Id, List<SObject>> mapFilhosParametrosVigenciaClone = new Map<Id, List<SObject>>();
			List<String> parametrosVigenciaIds = new List<String>();
			List<SObject> filhosParametrosVigencia = new List<SObject>();

			//Recupera ids dor parametros viegencia para poder montar query
			for(ParametroVigencia__c parametro : parametrosVigencia){
				parametrosVigenciaIds.add('\'' + parametro.Id + '\'');
			}

			String criterio = 'ParametroVigencia__c IN ('+ String.join(parametrosVigenciaIds, ', ') + ')';

			//Busca listas relacionadas a parametro vigencia
			filhosParametrosVigencia.addAll((List<FaixaDevolucao__c>) this.buscarDadosObjeto('FaixaDevolucao__c', criterio, novoProdutoComercial));

			//Gera map contendo todos os filhos das garantias de produto
			for(SObject filhoParametro : filhosParametrosVigencia){
				if(!mapFilhosParametrosVigenciaClone.containsKey((Id)filhoParametro.get('ParametroVigencia__c'))){
					mapFilhosParametrosVigenciaClone.put((Id)filhoParametro.get('ParametroVigencia__c'), new List<SObject>());
				}

				mapFilhosParametrosVigenciaClone.get((Id)filhoParametro.get('ParametroVigencia__c')).add(filhoParametro.clone(false, true));
			}

			//Gera clones dos paramtros de vigencia e gera reatribuições nos seus filhos
			for(ParametroVigencia__c parametroVigencia : parametrosVigencia){
				ParametroVigencia__c parametroVigenciaClone = ParametroVigencia.clone(false, true);
				parametroVigenciaClone.Produto__c = produtoReatribuirId;

				if(novoProdutoComercial){
					parametroVigenciaClone.RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id;
					parametroVigenciaClone.ParametroVigencia__c = parametroVigencia.Id;
				}

				insert parametroVigenciaClone;

				if(mapFilhosParametrosVigenciaClone.containsKey(parametroVigencia.Id)){
					//Reatribui os filhos da ParametroVigencia (clone) para a ParametroVigencia clonada
					for(SObject filhoParametroVigenciaClone : mapFilhosParametrosVigenciaClone.get(ParametroVigencia.Id)){
						filhoParametroVigenciaClone.put('ParametroVigencia__c', parametroVigenciaClone.Id);
					}
				}
			}

			//Insere os filhos clonados e reatribuidos aos clones
			if(!mapFilhosParametrosVigenciaClone.isEmpty()){
				List<SObject> filhosParametroVigenciaClone = new List<SObject>();

				for(List<SObject> listFilhosClone : mapFilhosParametrosVigenciaClone.values()){
					filhosParametroVigenciaClone.addAll(listFilhosClone);
				}

				insert filhosParametroVigenciaClone;
			}
		}
	}


	/**
     * Gera clonagem de todos os documentos do produto
     *
     * @param produtoId  - Id do produto no qual se quer clonar os documentos
     * @param produtoReatribuirId  - Id do produto clone para que seja reatribuidos os documentos clonados
	 * PLV-4183 - PRIVATE TO PUBLIC
     */
	public void clonarDocumentosProduto(Id produtoId, Id produtoReatribuirId){
		List<ContentVersion> cloneDocumentos = new List<ContentVersion>();
		List<ContentDocumentLink> cloneLinksDocumentos = new List<ContentDocumentLink>();
		Set<Id> contentDocumentIds = new Set<Id>();
		Set<Id> contentVersionIds = new Set<Id>();
		DocumentBO docBO = DocumentBO.getInstance();

		//Recupera os links dos documetos do produto
		for(ContentDocumentLink link : docBO.buscarContentDocumentPorLinkedEntityId(produtoId)){
			contentDocumentIds.add(link.ContentDocumentId);
		}

		if(!contentDocumentIds.isEmpty()){
			//Gera clonagem do conteudo dos documentos
			for(ContentVersion documento : docBO.buscarContentVersionPorContentDocumentId(contentDocumentIds)){
				cloneDocumentos.add(new ContentVersion(
						Title = documento.Title,
						PathOnClient = documento.PathOnClient,
						VersionData = documento.VersionData,
						IsMajorVersion = documento.IsMajorVersion
				));
			}

			insert cloneDocumentos;

			for(ContentVersion documento : cloneDocumentos){
				contentVersionIds.add(documento.Id);
			}

			//Gera links dos documentos no produto
			for(ContentVersion documento : docBO.buscarContentVersionPorId(contentVersionIds)){
				cloneLinksDocumentos.add( new ContentDocumentLink(
						LinkedEntityId = produtoReatribuirId,
						ContentDocumentId = documento.ContentDocumentId,
						ShareType = 'V'
				));
			}

			insert cloneLinksDocumentos;
		}
	}

	/**
     * Gera clonagem de todos os documentos do produto
     *
     * @param criteriosQuery  - critérios para a busca de terrotorios
     * @param recordTypeAtribuir  - developer name do tipo de registro que deve ser utilizado
     * @param produtoComercial  - indica se está se criando um produto comercial
	 *
	 * @return 	List<Territorio__c> - lista territorios encontrados e devidamente alterados
     */
	private List<Territorio__c> gerarTerritoriosParaClonagem(String criteriosQuery, String recordTypeAtribuir, Boolean novoProdutoComercial){
		List<Territorio__c> territorios = (List<Territorio__c>)this.buscarDadosObjeto('Territorio__c', criteriosQuery, false);

		if(novoProdutoComercial){
			Map<String, RecordType> tiposRegistroTerritorio = RecordTypeBO.buscarTipoRegistro('Territorio__c');

			for(Territorio__c territorio : territorios){
				//Cria referencia para o registro original (técnico). Atera tipo de registro
				territorio.Territorio__c = territorio.Id;
				territorio.RecordTypeId = tiposRegistroTerritorio.get('Territorio__c|' + recordTypeAtribuir).Id;
			}
		}

		return territorios;
	}

	/**
     * Realiza extração dos metadados para recuperar nomes de campos, monta query e retornar resultado baseados nos criterios
     *
     * @param objeto  - Nome do objeto a ser processado
     * @param criteriosQuery  - Criterio a ser usado na query
     * @param produtoComercial  - Informa que está se processando um produto comercial
     */
	private List<SObject> buscarDadosObjeto(String objeto, String criteriosQuery, Boolean novoProdutoComercial){
		List<SObject> registrosObjeto = Database.query(Util.gerarQuery(objeto, SObjectSchema.listarCamposEditaveis(objeto), new List<String>{criteriosQuery}));

		//Gera a referencia do clone para o registro original
		if(novoProdutoComercial){
			Id recordTypeProdutoComercialId;

			try {
				recordTypeProdutoComercialId = RecordTypeBO.buscarTipoRegistro(objeto, 'ProdutoComercial').Id;
			} catch(Exception e) {
				System.debug(e.getMessage());
			}

			for(SObject registro : registrosObjeto){
				//Cria referencia para o registro original (técnico)
				registro.put(objeto, registro.Id);

				if(recordTypeProdutoComercialId != null){
					//Sobreescreve record type para indicar que se trata de produto comercial
					registro.put('RecordTypeId', recordTypeProdutoComercialId);
				}
			}
		}

		return registrosObjeto;
	}

	/**
     * Realiza ativação de um produto
     *
     * 
     */
	public void gerarCodigoProduto(List<Product2> produtosAtuais) {
		//PLV-3493 - INICIO - Ajuste para gerar o código automaticamente apenas para o produto tecnico
		//Gera o map com os nomes dos tipos de registros e vincula o contador correspondente
		Map<Id, ContadorCodigo__c> mapTipoRegistroContador = new Map<Id, ContadorCodigo__c>();
		Id recId = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoTecnico').Id;
		//mapTipoRegistroContador.put(RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id, MetadataDAO.getInstance().buscarContadorCodigo('ProdutoComercial'));
		mapTipoRegistroContador.put(recId, MetadataDAO.getInstance().buscarContadorCodigo('ProdutoTecnico'));
		//PLV-3493 - FIM
		//Gera código apenas para nos quais não sejam clonados
		for(Product2 produto : produtosAtuais){
			if(produto.RecordTypeId != recId) return; //PLV-3493 - INICIO/FIM - Inclusão da logica

			Decimal codigo = mapTipoRegistroContador.get(produto.RecordTypeId).Numero__c;
            
			if(String.isEmpty(produto.ProductCode)){
				codigo++;
				produto.ProductCode = String.valueOf(codigo);
				mapTipoRegistroContador.get(produto.RecordTypeId).Numero__c = codigo;
			}
		}
		//Atualiza configuração personalizada com o código
		update mapTipoRegistroContador.values();
	}

	public Product2 buscarProdutoPorCodigoVigencia(String codigoProduto, Date vigenciaInicial, Date vigenciaFinal){
		Product2 produto;
		System.debug('codigoProduto ' + codigoProduto);
        System.debug('vigenciaInicial ' + vigenciaInicial);
        System.debug('vigenciaFinal ' + vigenciaFinal);
		try {
			produto = ProductDAO.getInstance().buscarProdutoPorCodigo(codigoProduto, vigenciaInicial, vigenciaFinal);
		} catch(Exception e) {
			throw new ProductException('O produto ' + codigoProduto + ' ' + vigenciaInicial + ' ' + vigenciaFinal +' não foi encontrado.');
		}

		return produto;
	}

	//PLV-2995 - INICIO - Criação do método para consultar o produto pela data de calculo
	public Product2 buscarProdutoPorDataCalculo(String codigoProduto, Date dataCalculo){
		Product2 produto;
		system.debug('buscarProdutoPorDataCalculoDebug');
		system.debug('codigoProduto: '+codigoProduto);
		system.debug('dataCalculo: '+codigoProduto);
		try {
			system.debug('buscarProdutoPorDataCalculoTry');
			produto = ProductDAO.getInstance().buscarProdutoPorCodigoDataCalculo(codigoProduto, dataCalculo);
		} catch(Exception e) {
			system.debug('buscarProdutoPorDataCalculoCatch');
			throw new ProductException('O produto ' + codigoProduto + dataCalculo +' não foi encontrado.');
		}

		return produto;
	}
	//PLV-2995 - FIM

	//Realiza a validação do produto e suas garantias no momento da oferta.
	//public Boolean validarProdutoOferta(Integer codigoProdutoVida, Date vigenciaInicial, Date vigenciaFinal){
	//	Boolean produtoValido = true;
	//	//Id tipoRegistroProdutoComercial = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;

	//	//// validar produto comercial (ativo, vigencia inicial e final)
	//	//Product2 produto = ProductDAO.getInstance().buscarProdutoPorCodigo(codigoProdutoVida, vigenciaInicial, vigenciaFinal);

	//	//if (produto == null) {
	//	//    throw new ProductException('Produto Vida ' + codigoProdutoVida + ' não encontrado.');
	//	//}

	//	// validar garantias do produto
	//	//TODO

	//	return produtoValido;
	//}

	/**
     * Gera clonagem de toda a estrutura de GarantiaProduto__c, clonando o objeto e todas as suas listas relacionadas
     *
     * @param produtoTecnicoId  - Id do produto a ser clonado
     */
	 //PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
	public void clonarTodaEstruturaGarantiasSelecionadasProduto(String idsGarantiasSelecionadas, Id produtoTecnicoId, Id produtoComercialId, Boolean novoProdutoComercial, String moeda, String demonstracaoPremio) {    //PLV_3450
		List<GarantiaProduto__c> garantiasProduto = new List<GarantiaProduto__c>();
		List<GarantiaProduto__c> todasGarantiasProduto = (List<GarantiaProduto__c>)Database.query(Util.gerarQuery('GarantiaProduto__c', SObjectSchema.listarCamposEditaveis('GarantiaProduto__c'), new List<String>{'Produto__c = \'' + produtoTecnicoId + '\''}));

		for (GarantiaProduto__c gar1 : todasGarantiasProduto) {
			if (idsGarantiasSelecionadas == (String)gar1.Id) {
				garantiasProduto.add(gar1);
			}
		}
		//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
		if(!garantiasProduto.isEmpty()){
			Map<Id, List<SObject>> mapFilhosGarantiaProdutoClone = new Map<Id, List<SObject>>();
			List<String> garantiasIds = new List<String>();
			List<SObject> filhosGarantiaProduto = new List<SObject>();
			List<String> garantiaIdsListQuery = new List<String>(); // PLV-4414-FIX4
			//Recupera ids das garantias para poder montar query
			// PLV-4414-FIX4 INICIO
			for(GarantiaProduto__c garantia : garantiasProduto){
				garantiasIds.add('\'' + garantia.Id + '\'');
				garantiaIdsListQuery.add(garantia.Id); // PLV-4414-FIX4
			}

			String criterio = 'GarantiaProduto__c IN ('+ String.join(garantiasIds, ', ') + ')';

			//Busca listas relacionadas a garantia
			filhosGarantiaProduto.addAll((List<CarenciaGarantia__c>) this.buscarDadosObjeto('CarenciaGarantia__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<FranquiaGarantia__c>) this.buscarDadosObjeto('FranquiaGarantia__c', criterio, novoProdutoComercial));
			// filhosGarantiaProduto.addAll((List<GarantiaRelacionada__c>) this.buscarDadosObjeto('GarantiaRelacionada__c', criterio, novoProdutoComercial)); // PLV-4414-FIX4
			//INICIO | PLV-2451-UAT
			List<GarantiaRelacionada__c> lstGarantiaRelacionadas =  new List<GarantiaRelacionada__c>();
			// for(GarantiaRelacionada__c garantiaRelacionada : (List<GarantiaRelacionada__c>) this.buscarDadosObjeto('GarantiaRelacionada__c', criterio, novoProdutoComercial)){
			// PLV-4414-FIX5
				for(GarantiaRelacionada__c garantiaRelacionada : [Select id, currencyisocode, recordtypeid, garantiaproduto__c, tipodependencia__c, validarregrasprodutocomercial__c, acumulativa__c, dependencia__c, incremento__c, garantiarelacionada__c From GarantiaRelacionada__c Where GarantiaProduto__c IN: garantiaIdsListQuery]){
					garantiaRelacionada.ValidarRegrasProdutoComercial__c = false;
					if(novoProdutoComercial){
						Id recordTypeProdutoComercialId = null;
						try {
							recordTypeProdutoComercialId = RecordTypeBO.buscarTipoRegistro('GarantiaRelacionada__c', 'ProdutoComercial').Id;
						} catch(Exception e) {
							System.debug(e.getMessage());
						}
						if(recordTypeProdutoComercialId != null)
							garantiaRelacionada.RecordTypeId = recordTypeProdutoComercialId;
					}
					lstGarantiaRelacionadas.add(garantiaRelacionada);
				}
				filhosGarantiaProduto.addAll(lstGarantiaRelacionadas);
				//FIM | PLV-2451-UAT
				
			// PLV-4414-FIX4 FIM
			filhosGarantiaProduto.addAll((List<RiscoGarantia__c>) this.buscarDadosObjeto('RiscoGarantia__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<ParametroRenovacao__c>) this.buscarDadosObjeto('ParametroRenovacao__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll((List<DependenteGarantia__c>) this.buscarDadosObjeto('DependenteGarantia__c', criterio, novoProdutoComercial));
			filhosGarantiaProduto.addAll(this.gerarTerritoriosParaClonagem(criterio, 'GarantiaProdutoComercial', novoProdutoComercial));

			//Gera map contendo todos os filhos das garantias de produto
			for(SObject filhoGarantia : filhosGarantiaProduto){
				if(!mapFilhosGarantiaProdutoClone.containsKey((Id)filhoGarantia.get('GarantiaProduto__c'))){
					mapFilhosGarantiaProdutoClone.put((Id)filhoGarantia.get('GarantiaProduto__c'), new List<SObject>());
				}

				mapFilhosGarantiaProdutoClone.get((Id)filhoGarantia.get('GarantiaProduto__c')).add(filhoGarantia.clone(false, true));
			}

			//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
			Set<Id> sIdGarantiaProduto = new Set<Id>();
			for(GarantiaProduto__c gar : garantiasProduto){
				sIdGarantiaProduto.add(gar.Id);
			}
			
			Map<String,LimiteGarantiaProduto__c> mapLimites = new Map<String,LimiteGarantiaProduto__c>(); //PLV-3046 FIX - INICIO/FIM - Ajuste de insercao de valores corretos no Limite Capital Minimo e Limite Capital Maximo

			List<LimiteGarantiaProduto__c> lstLimites = [SELECT GarantiaProduto__c, LimiteCapitalMinimo__c, LimiteCapitalMaximo__c, CurrencyIsoCode FROM LimiteGarantiaProduto__c WHERE GarantiaProduto__c =: sIdGarantiaProduto /*AND CurrencyIsoCode =: moeda*/]; //PLV-3046

            //PLV-3046 FIX - INICIO - Ajuste de insercao de valores corretos no Limite Capital Minimo e Limite Capital Maximo
			if(!lstLimites.isEmpty()){
				for(LimiteGarantiaProduto__c limite : lstLimites){
					mapLimites.put(limite.GarantiaProduto__c + '_' + limite.CurrencyIsoCode, limite);
				}
			}
            //PLV-3046 FIX - FIM - Ajuste de insercao de valores corretos no Limite Capital Minimo e Limite Capital Maximo
			//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem

			//Gera clones das garantias e gera reatribuições nos seus filhos
			for(GarantiaProduto__c garantia : garantiasProduto){
				GarantiaProduto__c garantiaClone = garantia.clone(false, true);
				garantiaClone.Produto__c = produtoComercialId;
				
				//PLV_3046 - INICIO - Cadastro de Limite de garantia do produto - Viagem
				//PLV-3046 - INICIO - Ajuste de insercao de valores corretos no Limite Capital Minimo e Limite Capital Maximo
				if(moeda != 'Default' && (mapLimites.containsKey(garantia.id + '_' + moeda))){
					garantiaClone.CurrencyIsoCode = moeda;
				}else if(moeda == 'Default'){
					garantiaClone.CurrencyIsoCode = '';
				}
				//garantiaClone.CurrencyIsoCode = moeda != 'Default' ? moeda : 'BRL'; //PLV_3046
				garantiaClone.DemonstracaoPremio__c = demonstracaoPremio;   //PLV_3450
				garantiaClone.LimiteCapitalMinimo__c = mapLimites.containsKey(garantia.id + '_' + moeda) ? mapLimites.get(garantia.id + '_' + moeda).LimiteCapitalMinimo__c : null;
				garantiaClone.LimiteCapitalMaximo__c = mapLimites.containsKey(garantia.id + '_' + moeda) ? mapLimites.get(garantia.id + '_' + moeda).LimiteCapitalMaximo__c : null;
                //PLV-3046 - FIM - Ajuste de insercao de valores corretos no Limite Capital Minimo e Limite Capital Maximo
				//PLV_3046 - FIM - Cadastro de Limite de garantia do produto - Viagem
				
				//TESTE IF
				garantiaClone.GarantiaProduto__c = garantia.Id;
				//TESTE IF

				if(novoProdutoComercial){
					garantiaClone.RecordTypeId = RecordTypeBO.buscarTipoRegistro('GarantiaProduto__c', 'ProdutoComercial').Id;
					garantiaClone.GarantiaProduto__c = garantia.Id;
				}

				insert garantiaClone;

				if(mapFilhosGarantiaProdutoClone.containsKey(garantia.Id)){
					//Reatribui os filhos da garantia (clone) para a garantia clonada
					for(SObject filhoGarantiaClone : mapFilhosGarantiaProdutoClone.get(garantia.Id)){
						filhoGarantiaClone.put('GarantiaProduto__c', garantiaClone.Id);
						System.debug('GarantiaRelacionada ' + garantiaClone.Produto__c);
						System.debug('GarantiaProduto' + garantiaClone.GarantiaProduto__r.Produto__c); //NULL
						//Desabilita regras de validação de produto comercial. Isto apenas no momento da criação
						try {
							if(filhoGarantiaClone.get('ValidarRegrasProdutoComercial__c') != null && novoProdutoComercial){
								filhoGarantiaClone.put('ValidarRegrasProdutoComercial__c', false);
							}
						} catch(Exception e) {
						}
					}
				}
			}

			//Insere os filhos clonados e reatribuidos aos clones
			if(!mapFilhosGarantiaProdutoClone.isEmpty()){
				List<SObject> filhosGarantiaClone = new List<SObject>();

				for(List<SObject> listFilhosClone : mapFilhosGarantiaProdutoClone.values()){
					filhosGarantiaClone.addAll(listFilhosClone);
				}
				System.debug('Carlos');
				for(sObject obj : filhosGarantiaClone){
					System.debug(obj);
				}
				insert filhosGarantiaClone;
			}
		}
	}

	/**
     * Remove toda a estrutura de GarantiaProduto__c
     *
     * @param produtoTecnicoId  - Id do produto a ser clonado
     */
	public void removerTodaEstruturaGarantiasSelecionadasProduto(List<Id> idsGarantiasSelecionadas, Id produtoTecnicoId, Id produtoComercialId, Boolean novoProdutoComercial) {
		List<GarantiaProduto__c> garantiasProduto = new List<GarantiaProduto__c>();
		List<GarantiaProduto__c> todasGarantiasProduto = (List<GarantiaProduto__c>)Database.query(Util.gerarQuery('GarantiaProduto__c', SObjectSchema.listarCamposEditaveis('GarantiaProduto__c'), new List<String>{'Produto__c = \'' + produtoComercialId + '\''}));

		for (GarantiaProduto__c gar1 : todasGarantiasProduto) {
			if (idsGarantiasSelecionadas.contains(gar1.Id)) {
				garantiasProduto.add(gar1);
			}
		}


		if(!garantiasProduto.isEmpty()){
			delete garantiasProduto;
		}
	}


	/**
     * Verifica tipo de capital alterado no produto técnico
     *
     * @param produtosAtuais  - Produtos alterados
     */
	/*
    public void validarTipoCapital(List<Product2> produtosAtuais)
    {

        for(Product2 produto : produtosAtuais)
        {
            if(produto.RecordTypeId == RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id &&
                produto.TipoCapital__c != null)
            {
                Set<Id> idProduto = new Set<Id>();
                idProduto.add(produto.ProdutoTecnico__c);

                Product2 prodTecnico = ProductDAO.getInstance().buscarProdutosPorId(idProduto)[0];

                if(prodTecnico.TipoCapital__c == null)
                {
                    produto.addError('Tipo(s) de capital(is) não existe(m) no produto técnico.');
                }
                else
                {
                    List<String> Tipos = produto.TipoCapital__c.split(';');
                    for(String Tipo : Tipos)
                    {
                        if(!prodTecnico.TipoCapital__c.contains(Tipo))
                        {
                            produto.addError('Tipo(s) de capital(is) não existe(m) no produto técnico.');
                            break;
                        }
                    }
                }
            }

        }
    }
    */

	public void validaLimiteCarregamento(List<Product2> listProdutos)
	{
		Set<Id> 			setIdsProdTecnicos = new Set<Id>();
		Map<Id, Product2> 	mapProdutosValidar = new Map<Id, Product2>();

		Id recordTypeProdutoComercial = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;

		for(Product2 p : listProdutos)
		{
			if(p.RecordTypeId == recordTypeProdutoComercial)
			{
				setIdsProdTecnicos.add(p.ProdutoTecnico__c);
				mapProdutosValidar.put(p.ProdutoTecnico__c, p);
			}
		}

		for(Product2 p : ProductDAO.getInstance().buscarProdutosPorId(setIdsProdTecnicos))
		{
			Product2 produto = mapProdutosValidar.get(p.id);

			if(p.LimiteTotalCarregamento__c < produto.LimiteTotalCarregamento__c)
				produto.addError('Excedido limite de carregamento');
		}
	}

	// Código removido para Fix da história PLV-3316

	//PLV-5230 - INICIO
	public Boolean iniciarIntegracaoOpin(Map<Id,Product2> antigos, Map<Id,Product2> novos) {

		List<Product2> produtosIntegrar = identificarProdutosOpin(antigos, novos);
		if (produtosIntegrar.size() == 0) {
			return false; //Não há produtos para integrar
		}

		//Enfileira execução da integração com Open Insurance
		enfileirarProdutoOpin(produtosIntegrar, 0);
		
		return true;

	}

	private List<Product2> identificarProdutosOpin(Map<Id,Product2> antigos, Map<Id,Product2> novos) {

		Id recordTypeProdutoComercial = RecordTypeBO.buscarTipoRegistro('Product2', 'ProdutoComercial').Id;

		List<Product2> produtosIntegrar = new List<Product2>();
		for(Product2 prodNovo : novos.values()) {
			Product2 prodAntigo = antigos.get(prodNovo.Id);
			if (prodNovo.Status__c == STATUS_ATIVO && 
					prodNovo.RecordTypeId == recordTypeProdutoComercial &&
					prodNovo.Status__c <> prodAntigo.Status__c &&
					GRUPO_SEGMENTO_IV.contains(prodNovo.Segmento__c)	) {
				produtosIntegrar.add(prodNovo);
			}
		}

		return produtosIntegrar;
		
	}
	public static void enfileirarProdutoOpin(List<Product2> produtos, Integer posicao) {

		if (Test.isRunningTest()) {
			return;
		}

		System.enqueueJob( new QueueableIntegracaoOpin(produtos, posicao)  );
        
    }
	//PLV-5230 - FIM

    public class ProductException extends Exception {	}
}