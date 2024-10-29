/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de Configuracao__c
 *
 **************************************************************************************************************************************************************************/
public  class ConfiguracaoBO {
	private static final ConfiguracaoBO instancia = new ConfiguracaoBO();
	private ConfiguracaoDAO dao = ConfiguracaoDAO.getInstance();

	private ConfiguracaoBO() {	
	}

	//Configurador_VidaGrupo
	//Configurador_VidaIndividual

	//Configurador_VidaGrupo
	//Configurador_VidaIndividual	

	public static ConfiguracaoBO getInstance(){
		return instancia;
	}

	//Retorna uma configuração e os seus registros filhos
	public Configuracao__c buscarConfiguracao(Id configuracaoId){
		return dao.buscarConfiguracao(configuracaoId);
	}

	//Retorna toda as garantias da configuração de um produto
	public List<GarantiaProdutoConfiguracao__c> buscarGarantiasProdutosConfiguracao(Id produtoConfiguracaoId){
		return dao.buscarGarantiasProdutosConfiguracao(produtoConfiguracaoId);
	}

	//Realiza upsert de um produto da configuração
	public Id salvarProdutosConfiguracao(ProdutoConfiguracao__c produtoConfiguracao){
		upsert produtoConfiguracao;
    	return produtoConfiguracao.Id;
	}

	//Realiza upsert de uma lista garantia de produto da configuração
	public void salvarGarantiasProdutosConfiguracao(List<GarantiaProdutoConfiguracao__c> garantiasProdutosConf){
        upsert garantiasProdutosConf;
    }

    //Realiza upsert de uma lista garantia de produto da configuração
	public void salvarCriteriosConfiguracao(List<CriterioConfiguracao__c> criteriosConfiguracao){
        upsert criteriosConfiguracao;
    }    

    //Realiza delete de uma lista garantia de produto da configuração
	public void excluirGarantiasProdutosConfiguracao(List<GarantiaProdutoConfiguracao__c> garantiasProdutosConf){
        delete garantiasProdutosConf;
    }

    //Deleta um produto da configuraçãp
	public void excluirProdutoConfiguracao(Id produtoConfiguracaoId){
		ProdutoConfiguracao__c produtoConfiguracao = new ProdutoConfiguracao__c(Id = produtoConfiguracaoId);
        delete produtoConfiguracao;
	}

	//Deleta um criterio da configuração
	public void excluirCriterioConfiguracao(Id criterioConfiguracaoId){
		CriterioConfiguracao__c criterioConfiguracao = new CriterioConfiguracao__c(Id = criterioConfiguracaoId);
        delete criterioConfiguracao;
	}

	//Busca os valores da combo de Campos do criterio da configuração
	public List<CustomPickListOptionTO> buscarOpcoesCamposCriterio(List<String> nomesObjeto, String segmento, String tipoComponente){
		List<CustomPickListOptionTO> opcoes = new List<CustomPickListOptionTO>();

		//ALTERAR ESTE PARTE QUANDO CRIAR OUTROS COMPONENTES DE CONFIGURACAO
		Map<String, String> mapNomeFieldSet = new Map<String, String>();
		mapNomeFieldSet.put('ConfiguradorOferta_Individual', 'Configurador_VidaIndividual');
		mapNomeFieldSet.put('ConfiguradorOferta_Coletivo', 'Configurador_VidaGrupo');

		for(String nomeObjeto : nomesObjeto){
			for(Schema.FieldSetMember campo : SObjectSchema.recuperarCamposFieldSet(nomeObjeto, mapNomeFieldSet.get(tipoComponente + '_' + segmento))){
				opcoes.add(new CustomPickListOptionTO(campo.getLabel(), nomeObjeto + '.' + campo.getFieldPath()));
			}
		}	

		return opcoes;
	}

	//Busca os valores da combo de Campos do criterio da configuração
	//USADA
	public Map<String, Schema.FieldSetMember> buscarMapInformacoesCamposCriterio(List<String> nomesObjeto, String segmento, String tipoComponente){
		Map<String, Schema.FieldSetMember> mapInfo = new Map<String, Schema.FieldSetMember>();

		//ALTERAR ESTE PARTE QUANDO CRIAR OUTROS COMPONENTES DE CONFIGURACAO
		Map<String, String> mapNomeFieldSet = new Map<String, String>();
		mapNomeFieldSet.put('ConfiguradorOferta_Individual', 'Configurador_VidaIndividual');
		mapNomeFieldSet.put('ConfiguradorOferta_Coletivo', 'Configurador_VidaGrupo');

		for(String nomeObjeto : nomesObjeto){
			for(Schema.FieldSetMember campo : SObjectSchema.recuperarCamposFieldSet(nomeObjeto, mapNomeFieldSet.get(tipoComponente + '_' + segmento))){
				mapInfo.put(nomeObjeto + '.' + campo.getFieldPath(), campo);
			}
		}	

		return mapInfo;
	}

	//Realiza a busca do produtos que deverão serem encontrados através das configurações
	//USADA
	public List<ProdutoConfiguracao__c> buscarProdutosConfigurados(Map<String, String> mapCamposValores, String segmento){
		if(String.isBlank(segmento) || (segmento.equalsIgnoreCase('coletivo') == false && segmento.equalsIgnoreCase('individual') == false)){
			throw new ConfiguracaoException('Segmento inválido. O segmento deve ser \'Coletivo\' ou \'Individual\'');	
		}

		Map<String, Schema.FieldSetMember> mapCamposObjetos = this.buscarMapInformacoesCamposCriterio(new List<String>{'Account', 'Opportunity'}, segmento, 'ConfiguradorOferta');
		Set<Id> configuracoesIds = new Set<Id>();

		//Busca todas as configurações de um segmento e verifica se elas estão de acordo com os valores do map
		for(Configuracao__c config : dao.buscarConfiguracoesVigentesPorSegmento(segmento)){
			if(this.validarCriteriosConfiguracao(mapCamposValores, config, mapCamposObjetos)){

				//Separa todas as configurações com os critérios aceitos pelos parametros recebidos
				configuracoesIds.add(config.Id);
			}
		}

		//Retorna produtos da configurações aprovadas
		return dao.buscarProdutosConfiguracaoPorConfIds(configuracoesIds);
	}

	//Verifica se os critérios de uma configuração estão de acordo com os valores vindos do map
	//USADA
	private Boolean validarCriteriosConfiguracao(Map<String, String> mapCamposValores, Configuracao__c configuracao, Map<String, Schema.FieldSetMember> mapCamposObjetos) {
		List<CriterioConfiguracao__c> criterios = configuracao.CriteriosConfiguracao__r;
		Map<String, CriterioConfiguracao__c> mapCriterios = new Map<String, CriterioConfiguracao__c>();
		Boolean configuracaoOK = true;

		if(criterios.isEmpty()){
			configuracaoOK = false;
		}

		if(configuracaoOK){
			//Gera mapa contendo o mapeamento do critérios pelo os seus campos
			for(CriterioConfiguracao__c criterio : criterios){
				mapCriterios.put(criterio.Campo__c, criterio);
			}

			//Realiza validação dos valores
			configuracaoOK = this.validarCriterios(mapCamposValores, mapCriterios, mapCamposObjetos);
		}

		return configuracaoOK;
	}

	//Realiza validação de um critério com realação aos valores do map
	//USADA
	private Boolean validarCriterios(Map<String, String> mapCamposValores, Map<String, CriterioConfiguracao__c> mapCriterios, Map<String, Schema.FieldSetMember> mapCamposObjetos){
		Boolean criterioOK = true;

		//Verifica se todos os campos de valores existem nos criterios
		//for(String campo : mapCamposValores.keySet()){
		//	if(!mapCriterios.containsKey(campo)){
		//		criterioOK = false;	
		//		break;
		//	}
		//}

		//Verifica se todos os criterios existem nos campos de valores
		if(criterioOK){
			for(String campoCriterio : mapCriterios.keySet()){
				if(!mapCamposValores.containsKey(campoCriterio)){
					criterioOK = false;	
					break;
				}
			}
		}

		//Verifica se todos so valores estão de acordo com os critérios
		if(criterioOK){
			criterioOK = this.validarValoresCriterios(mapCamposValores, mapCriterios, mapCamposObjetos);
		}

		return criterioOK;
	}


	//Realiza validação dos valores dos critérios
	@TestVisible
	private Boolean validarValoresCriterios(Map<String, String> mapCamposValores, Map<String, CriterioConfiguracao__c> mapCriterios, Map<String, Schema.FieldSetMember> mapCamposObjetos){
		Boolean valoresOK = true;
		
		for(String campo : mapCamposValores.keySet()){
			if(mapCamposObjetos.get(campo) == null)	{
				throw new ConfiguracaoException('O campo ' + campo + ' não foi mapeado em FieldSet');
			}

			//Caso algum campo não esteja de acordo com os critérios, invalidar toda validação
			if(!this.validarValor(mapCamposValores.get(campo), mapCriterios.get(campo), mapCamposObjetos.get(campo).getType())){
				valoresOK = false;
				break;
			}
		}

		return valoresOK;
	}

	//Reliza validação de valor de um critério
	private Boolean validarValor(String valor, CriterioConfiguracao__c criterio, Schema.DisplayType tipoCampo){
		if(criterio == null) return true;

		Object valorBuscado;
		Object valorCriterio;
		Set<Object> valoresCriterio;
		Boolean unicoValorCriterio = criterio.Operador__c != 'Contém' && criterio.Operador__c != 'Não contém' ? true : false;

		if(tipoCampo.name() == Schema.DisplayType.DOUBLE.name() || tipoCampo.name() == Schema.DisplayType.PERCENT.name() || tipoCampo.name() == Schema.DisplayType.CURRENCY.name()){
			valorBuscado = Decimal.valueOf(valor);
			valorCriterio = unicoValorCriterio ? Decimal.valueOf(criterio.Valor__c) : null;
		}
		else if(tipoCampo.name() == Schema.DisplayType.BOOLEAN.name()){
			valorBuscado = Boolean.valueOf(valor);
			valorCriterio = unicoValorCriterio ? Boolean.valueOf(criterio.Valor__c) : null;
		}
		else if(tipoCampo.name() == Schema.DisplayType.INTEGER.name()){
			valorBuscado = Integer.valueOf(valor);
			valorCriterio = unicoValorCriterio ? Integer.valueOf(criterio.Valor__c) : null;
		}
		else if(tipoCampo.name() == Schema.DisplayType.DATE.name()){
			valorBuscado = Date.valueOf(valor);
			valorCriterio = unicoValorCriterio ? Date.valueOf(criterio.Valor__c) : null;
		}
		else {
			valorBuscado = String.valueOf(valor);
			valorCriterio = unicoValorCriterio ? String.valueOf(criterio.Valor__c) : null;
		}

		valoresCriterio = !unicoValorCriterio ? this.splitVariosValoresCriterio(criterio.Valor__c, tipoCampo) : null;
		
		return this.compararValores(valorBuscado, valorCriterio, valoresCriterio, criterio.Operador__c, tipoCampo);
	}

	//Realiza comparação dos valores
	private Boolean compararValores(Object valorBuscado, Object valorCriterio, Set<Object> valoresCriterio, String operador, Schema.DisplayType tipoCampo){
		Boolean resultadoComparacao;
		Decimal decValorBuscado;
		Decimal decValorCriterio;
		Date dtValorBuscado;
		Date dtValorCriterio;
		Boolean tipoData = tipoCampo.name() == Schema.DisplayType.DATE.name();

		//Esses operadores não podem ser utilizados com o tipo Object, então é necessario tranformar em um tipo valido
		if(operador.indexOf('Menor') > -1 || operador.indexOf('Maior') > -1){
			if(tipoData){
				dtValorBuscado = Date.valueOf(valorBuscado);
				dtValorCriterio = Date.valueOf(valorCriterio);
			}else{
				decValorBuscado = Decimal.valueOf(String.valueOf(valorBuscado));
				decValorCriterio = Decimal.valueOf(String.valueOf(valorCriterio));
			}
		}

		if(operador == 'Igual'){ 
			resultadoComparacao = valorBuscado == valorCriterio;
		}
		else if(operador == 'Diferente'){ 
			resultadoComparacao = valorBuscado != valorCriterio;
		}
		else if(operador == 'Menor'){ 
			if(tipoData)
				resultadoComparacao = dtValorBuscado < dtValorCriterio;
			else
				resultadoComparacao = decValorBuscado < decValorCriterio;
		}
		else if(operador == 'Menor ou igual'){ 
			if(tipoData)
				resultadoComparacao = dtValorBuscado <= dtValorCriterio;
			else
				resultadoComparacao = decValorBuscado <= decValorCriterio;
		}
		else if(operador == 'Maior'){ 
			if(tipoData)
				resultadoComparacao = dtValorBuscado > dtValorCriterio;
			else
				resultadoComparacao = decValorBuscado > decValorCriterio;
		}
		else if(operador == 'Maior ou igual'){ 
			if(tipoData)
				resultadoComparacao = dtValorBuscado >= dtValorCriterio;
			else
				resultadoComparacao = decValorBuscado >= decValorCriterio;
		}
		else if(operador == 'Contém' || operador == 'Não contém'){ 
			String strValorBuscado = String.valueOf(valorBuscado);
			Set<Object> valoresBuscado = new Set<Object>();

			for(String valor : strValorBuscado.split(';')){
				valoresBuscado.add(valor);
			}
			
			resultadoComparacao = true;

			for(Object valor : valoresBuscado){
				if(!valoresCriterio.contains(valor)){
					resultadoComparacao = false;
					break;
				}
			}

			if(operador == 'Não contém'){
				resultadoComparacao = !resultadoComparacao;				
			}
		}

		return resultadoComparacao;
	}

	//Quebra os varios valores que um valor de criterio pode ter, em um SET
	private Set<Object> splitVariosValoresCriterio(String valores, Schema.DisplayType tipoCampo){
		List<String> valoresSplit = valores.split(';');
		Set<Object> valoresCriterio = new Set<Object>();

		if(tipoCampo.name() == Schema.DisplayType.DOUBLE.name() || tipoCampo.name() == Schema.DisplayType.PERCENT.name() || tipoCampo.name() == Schema.DisplayType.CURRENCY.name()){
			for(String valor : valoresSplit){
				valoresCriterio.add(Decimal.valueOf(valor));
			}				
		}
		else if(tipoCampo.name() == Schema.DisplayType.BOOLEAN.name()){
			for(String valor : valoresSplit){
				valoresCriterio.add(Boolean.valueOf(valor));
			}
		}
		else if(tipoCampo.name() == Schema.DisplayType.INTEGER.name()){
			for(String valor : valoresSplit){
				valoresCriterio.add(Integer.valueOf(valor));
			}
		}
		else if(tipoCampo.name() == Schema.DisplayType.DATE.name()){
			for(String valor : valoresSplit){
				valoresCriterio.add(Date.valueOf(valor));
			}
		}
		else {
			for(String valor : valoresSplit){
				valoresCriterio.add(String.valueOf(valor.trim()));
			}
		}

		return valoresCriterio;
	}

	public class ConfiguracaoException extends Exception { }
}