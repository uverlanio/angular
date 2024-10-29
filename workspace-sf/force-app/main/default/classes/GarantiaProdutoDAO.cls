/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pela busca de dados do objeto de GarantiaProduto__c
 *
 **************************************************************************************************************************************************************************/
public  class GarantiaProdutoDAO {
	private static final GarantiaProdutoDAO instancia = new GarantiaProdutoDAO();

	private GarantiaProdutoDAO() {	}

	public static GarantiaProdutoDAO getInstance(){
		return instancia;
	}

	public List<GarantiaProduto__c> buscarGarantiasPorId(Set<Id> garantiaIds){
		return [
			Select 
				Id, 
                //PLV-4693 INICIO
                RamoSeguro__r.Codigo__c,
                //PLV-4693 FIM
				Garantia__c,
				Garantia__r.Tipo__c,
				GarantiaProduto__c,
				RecordTypeId,
				TipoCapital__c,
				LimiteCapitalMinimo__c,
				LimiteCapitalMaximo__c,
				LimiteIdadeMinimo__c,
				LimiteIdadeMaximo__c,
				OrdemPrioridade__c,
            	//PLV-3731 - INICIO
            	CurrencyIsoCode,
            	//PLV-3731 - FIM
            //PLV-2049 - Início
            	Descricao__c
            //PLV - 2049 - Fim
            
			From 
				GarantiaProduto__c 
			Where 
				Id IN: garantiaIds
		];
	}
	//PLV-2128-27 INÍCIO - Verifica se os campos de cancelamento estão preenchidos, obrigando o preenchimento do campo Momento de cancelamento
	public List<GarantiaProduto__c> buscarGarantiasProdutoPorProdutoId(Set<Id> produtoIds){
		return [
			Select 
				Id, 
				Garantia__c,
            	//PLV - 2703 INICIO
            	Garantia__r.Descricao__c,
            	//PLV -2703 FIM
				Garantia__r.Name,
				Garantia__r.Sigla__c,
				Produto__c,
				RamoSeguro__c,
				RamoSeguro__r.Codigo__c,
				RamoSeguro__r.Name,
				OrdemPrioridade__c,
				CancelaDependentes__c,
				CancelaGarantia__c,
				CancelaSegurado__c,
				MomentoCancelamento__c,
			    //--> PLV2427 INICIO
				CaracteristicaGarantia__c,
				Obrigatoria__c,
				TipoLimiteCapital__c,
				LimiteCapitalMinimo__c,
				LimiteCapitalMaximo__c
			    //--> PLV2427 FIM			   
			From 
				GarantiaProduto__c 
			Where 
				Produto__c IN: produtoIds
		];
	}
	//PLV-2128-27 FIM

   // VIAG-148 INICIO
	public List<GarantiaProduto__c> buscaGarantiasProdutosSemGrupoRisco(Set<String> codigosProduto){
		List<GarantiaProduto__c> garantiasFiltradas = new List<GarantiaProduto__c>();
		//Lógica para recuperar apenas as garantias que não possuem um relacionamento com grupos de risco
		List<GarantiaProduto__c> lstGarantiasSemGrupoRisco = [SELECT ID, Garantia__r.Name,
		LimiteIdadeMinimo__c,LimiteIdadeMaximo__c, //PLV-4840 INICIO/FIM
		(SELECT Id, Name, GarantiaProduto__c, GrupoRisco__r.Name FROM GruposRiscoGarantia__r)
		FROM GarantiaProduto__c
		WHERE Produto__r.ProductCode IN: codigosProduto];

		Set<Id> lstA = new Set<Id>();
		Set<Id> lstB = new Set<Id>();
		List<Id> lstC = new List<Id>();

		for(GarantiaProduto__c lst1 :lstGarantiasSemGrupoRisco){
		lstA.add(lst1.Id);
		For(GrupoRiscoGarantia__c lst2 : lst1.GruposRiscoGarantia__r){
		lstB.add(lst2.GarantiaProduto__c);
		}
		}

		for(ID garantiasSemGrupoRisco : lstA){
		if(!lstB.contains(garantiasSemGrupoRisco)){
		lstC.add(garantiasSemGrupoRisco);
		}
		}

		//Lógica para combinar as garantias filtradas por profissão com as garantias que não possuem grupos de risco
		
		List <GarantiaProduto__c> GarantiaProduto = new List <GarantiaProduto__c>();
		GarantiaProduto = [SELECT
		Id, 
		Garantia__c,
		Garantia__r.Descricao__c,
		Garantia__r.Name,
		Garantia__r.Sigla__c,
		Produto__c,
		RamoSeguro__c,
		RamoSeguro__r.Codigo__c,
		RamoSeguro__r.Name,
		OrdemPrioridade__c,
		AgrupamentoCoberturas__c, //VIAG-265 - INICIO/FIM
		CancelaDependentes__c,
		CancelaGarantia__c,
		CancelaSegurado__c,
		MomentoCancelamento__c,
		CaracteristicaGarantia__c,
		Obrigatoria__c,
		TipoGarantia__c,
		TipoLimiteCapital__c,
		LimiteCapitalMinimo__c,
		LimiteCapitalMaximo__c,
		LimiteMaximoCaracteristicaEspecial__c,
		LimiteMinimoCaracteristicaEspecial__c,
		TipoCaracteristicaEspecial__c,
		LimiteIdadeMinimo__c,LimiteIdadeMaximo__c, 
		Produto__r.Status__c
		FROM GarantiaProduto__c WHERE ID IN: lstC];

		for(GarantiaProduto__c garantiasFinais : GarantiaProduto) {
		garantiasFiltradas.add(garantiasFinais);
		}

		return garantiasFiltradas;


	}
    // VIAG-148 FIM
	//VIDA-175 - INICIO
	public List<GarantiaProduto__c> buscaGarantiasProdutos(Set<String> codigosProduto, Id profissaoId) {

		List<GarantiaProduto__c> garantiasProdutos = new List<GarantiaProduto__c>();
		
		Set<Id> grupoRiscoIds = new Set<Id>();
	
		if (profissaoId != null) {
			for (GrupoProfissoes__c grupoProfissao : [SELECT GrupoRisco__c FROM GrupoProfissoes__c WHERE profissao__c = :profissaoId]) {
				grupoRiscoIds.add(grupoProfissao.GrupoRisco__c);
			}
		}
	
		if (!grupoRiscoIds.isEmpty()) {
			Set<Id> idGarantias = new Set<Id>();
			for (GrupoRiscoGarantia__c grupoRiscoGarantia : [SELECT GarantiaProduto__c FROM GrupoRiscoGarantia__c WHERE GrupoRisco__c IN :grupoRiscoIds]) {
				idGarantias.add(grupoRiscoGarantia.GarantiaProduto__c);
				//garantiasProdutos.add(new GarantiaProduto__c(Garantia__c = grupoRiscoGarantia.GarantiaProduto__c));
			}
			List<GarantiaProduto__c> garantiasComGrupoRisco = [SELECT Id, 
																Garantia__c,
																Garantia__r.Descricao__c,
																Garantia__r.Name,
																Garantia__r.Sigla__c,
																FormaExibicaoCapital__c,
																Produto__c,
																RamoSeguro__c,
																RamoSeguro__r.Codigo__c,
																RamoSeguro__r.Name,
																OrdemPrioridade__c,
																AgrupamentoCoberturas__c, //VIAG-265 INICIO-FIM
																CancelaDependentes__c,
																CancelaGarantia__c,
																CancelaSegurado__c,
																MomentoCancelamento__c,
																CaracteristicaGarantia__c,
																Obrigatoria__c,
																TipoGarantia__c,
																TipoLimiteCapital__c,
																LimiteCapitalMinimo__c,
																LimiteCapitalMaximo__c,
																LimiteMaximoCaracteristicaEspecial__c,
																LimiteMinimoCaracteristicaEspecial__c,
																TipoCaracteristicaEspecial__c,
																Produto__r.Status__c,
																LimiteIdadeMinimo__c,
																LimiteIdadeMaximo__c, //PLV-4840 INICIO/FIM
																	(SELECT ID,
																			Name,
																			GarantiaProduto__c,
																			GrupoRisco__r.Name
																	FROM GruposRiscoGarantia__r)
																FROM GarantiaProduto__c
																WHERE Produto__r.ProductCode IN :codigosProduto AND id IN : idGarantias];
			garantiasProdutos.addAll(garantiasComGrupoRisco);
		}
		
		System.debug('LISTA HENRIQUE: ' + garantiasProdutos);
		List<GarantiaProduto__c> garantiasSemGrupoRisco = [SELECT Id, 
																Garantia__c,
																Garantia__r.Descricao__c,
																Garantia__r.Name,
																Garantia__r.Sigla__c,
																FormaExibicaoCapital__c,
																Produto__c,
																RamoSeguro__c,
																RamoSeguro__r.Codigo__c,
																RamoSeguro__r.Name,
																OrdemPrioridade__c,
																AgrupamentoCoberturas__c, //VIAG-265 - INICIO/FIM
																CancelaDependentes__c,
																CancelaGarantia__c,
																CancelaSegurado__c,
																MomentoCancelamento__c,
																CaracteristicaGarantia__c,
																Obrigatoria__c,
																TipoGarantia__c,
																TipoLimiteCapital__c,
																LimiteCapitalMinimo__c,
																LimiteCapitalMaximo__c,
																LimiteMaximoCaracteristicaEspecial__c,
																LimiteMinimoCaracteristicaEspecial__c,
																TipoCaracteristicaEspecial__c,
																Produto__r.Status__c,
																LimiteIdadeMinimo__c,
																LimiteIdadeMaximo__c, //PLV-4840 INICIO/FIM
																	(SELECT ID,
																			Name,
																			GarantiaProduto__c,
																			GrupoRisco__r.Name
																	FROM GruposRiscoGarantia__r)
																FROM GarantiaProduto__c
																WHERE Produto__r.ProductCode IN :codigosProduto
																AND Id NOT IN (SELECT GarantiaProduto__c FROM GrupoRiscoGarantia__c)];
		
		System.debug('HENRIQUE GARANTIA SEM GRUPO DE RISCO: ' + garantiasSemGrupoRisco);
		garantiasProdutos.addAll(garantiasSemGrupoRisco);

		System.debug('HENRIQUE GARANTIA PRODUTO: ' +garantiasProdutos );
		return garantiasProdutos;
	}
	//VIDA-175 - FIM

    // VIAG-148 FIM
   // VIAG-148 INICIO
   public List<FranquiaGarantia__c> buscarGarantiasProdutolistFranquiaGarantia(Set<Id> setIdGarantias){
		return [SELECT Id
		, GarantiaProduto__c
		, Franquia_padrao__c
		, Franquia__r.Descricao__c
		, Franquia__r.CodigoFranquia__c
		, Franquia__r.Name //II-73
	FROM FranquiaGarantia__c
	WHERE GarantiaProduto__c IN: setIdGarantias];
   }
   public List<CarenciaGarantia__c> buscarGarantiasProdutolistCarenciaGarantia(Set<Id> setIdGarantias){
	return [SELECT Id
	, GarantiaProduto__c
	, Carencia__r.Descricao__c
	, Carencia__r.CodigoCarencia__c
	FROM CarenciaGarantia__c
	WHERE GarantiaProduto__c IN: setIdGarantias];
	}
	public List<GarantiaRelacionada__c> buscarGarantiasProdutolistGarantiaRelacionada(Set<Id> setIdGarantias){
		return [SELECT
        Id,
        Name, 
        GarantiaProduto__r.Garantia__r.Name, 
        GarantiaProduto__r.Garantia__r.Sigla__c,
        TipoDependencia__c, 
        GarantiaProduto__c,
        GarantiaRelacionada__r.Garantia__r.Name,
        GarantiaRelacionada__r.Garantia__r.Sigla__c
        FROM GarantiaRelacionada__c
        WHERE GarantiaProduto__c IN: setIdGarantias];
		}

   // VIAG-148 FIM



    public List<GarantiaProduto__c> buscarGarantiasProdutoObrigatoriasPorProdutoId(Set<Id> produtoIds){
        return [
            Select
                Id,
                Garantia__c,
                Garantia__r.Name,
                Garantia__r.Sigla__c,
				Produto__c,
				CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Adicionado CurrencyIsoCode 
                RamoSeguro__c
            From
                GarantiaProduto__c
            Where
                Produto__c IN: produtoIds
            AND
                Obrigatoria__c = true
        ];
    }

	public List<GarantiaProduto__c> buscarGarantiasMaisFilhosPorId(Set<Id> garantiaIds){
		return [
			Select 
				Id, 
				GarantiaProduto__c,
				RecordTypeId,
				(Select Id, Dependente__c From DependentesGarantia__r),
				(Select Id From ParametrosRenovacao__r),
				(Select Id From GarantiasRelacionada__r)
			From 
				GarantiaProduto__c 
			Where 
				Id IN: garantiaIds
		];
	}

	public List<GarantiaProduto__c> buscarGarantiasProdutoPorProdutoCapId(List<String> codigosproduto){
		return [
			Select 
				Id, 
				Garantia__c,
				Garantia__r.Name,
				Garantia__r.Sigla__c,
				Produto__c,
				VersaoTitulo__c,
				ValorTitulo__c,
				CodigoPromocao__c,
				Produto__r.ProductCode
			From 
				GarantiaProduto__c 
			Where 
				Produto__r.ProductCode IN: codigosproduto
			AND Garantia__r.Sigla__c = 'CAP'	
		];
	}


	public AggregateResult[] buscarGarantiasProdutoPorProdutoCapByGroup(){
		return [
			Select 
				CodigoPromocao__c
			From 
				GarantiaProduto__c 
			Where Garantia__r.Sigla__c = 'CAP'
			  AND CodigoPromocao__c <> '' 
			GROUP BY CodigoPromocao__c	
		];
	}


	public List<GarantiaProduto__c> buscarGarantiasProdutoPorProdutoCap(Set<String> codPromocao){
		return [
			Select 
				Id, 
				CodigoPromocao__c,
				(
					select VersaoTitulo__c,
					DataSolicitacaoCapitalizacao__c
   					from Garantias_do_contrato__r
				)
			From 
				GarantiaProduto__c 
			Where Garantia__r.Sigla__c = 'CAP'
			  AND GarantiaProduto__c.CodigoPromocao__c IN: codPromocao
			ORDER BY CodigoPromocao__c	
		];
	}
    
    //--> PLV2502 INICIO
    	public List<GarantiaProduto__c> buscarGarantiasProdutoPorCodigoProduto(set<String> codigoProdutoVida){
		return [
			Select 
				Id, 
				Garantia__c,
				Garantia__r.Name,
				Garantia__r.Sigla__c,
				Produto__c,
				VersaoTitulo__c,
				ValorTitulo__c,
				CodigoPromocao__c,
				Produto__r.ProductCode, 
				Obrigatoria__c,    
                TipoLimiteCapital__c,
			    LimiteIdadeMinimo__c,
				LimiteIdadeMaximo__c,
                LimiteCapitalMaximo__c,
                LimiteCapitalMinimo__c,
                (select id,TipoDependencia__c,GarantiaRelacionada__r.Garantia__r.Sigla__c from GarantiasRelacionada__r where TipoDependencia__c in ('Includente','Excludente'))
			 
			From 
				GarantiaProduto__c 
			Where 
				Produto__r.ProductCode IN: codigoProdutoVida
		];
	}
   //--> PLV2502 FIM
	//PLV-3649 - INICIO - Método criado para ajustar a consulta da nova classe de gravar orcamento
	public List<GarantiaProduto__c> buscarGarantiasProdutoPorProdutoCode(Set<String> codigosProduto){
		return [
			Select 
				Id, 
				Garantia__c,
            	Garantia__r.Descricao__c,
				Garantia__r.Name,
				Garantia__r.Sigla__c,
				Produto__c,
				RamoSeguro__c,
				RamoSeguro__r.Codigo__c,
				RamoSeguro__r.Name,
				OrdemPrioridade__c,
				CancelaDependentes__c,
				CancelaGarantia__c,
				CancelaSegurado__c,
				MomentoCancelamento__c,
				CaracteristicaGarantia__c,
				Obrigatoria__c,
				TipoGarantia__c, //PLV-4325 - INICIO/FIM - Campo incluido
				TipoLimiteCapital__c,
				LimiteCapitalMinimo__c,
				LimiteCapitalMaximo__c,
				//PLV-4319 - INICIO - PEDRO AUGUSTO - SYS4B
				LimiteMaximoCaracteristicaEspecial__c,
				LimiteMinimoCaracteristicaEspecial__c,
				TipoCaracteristicaEspecial__c,
				Produto__r.Status__c
				//PLV-4319 - FIM  - PEDRO AUGUSTO - SYS4B
			    			   
			From 
				GarantiaProduto__c 
			Where 
				Produto__r.ProductCode IN: codigosProduto
		];
	}
	//PLV-3649 - FIM	


	//PLV-5230 - INICIO
	public List<GarantiaProduto__c> buscarGarantiasProdutoOpin(String produtoId) {
		return [
			SELECT Id, 
					Garantia__r.Name, 
					GarantiaProduto__c, 
					SiglaGarantia__c, 
					CurrencyIsoCode, 
					TipoPagamento__c, 
					LimiteCapitalMinimo__c,
					LimiteCapitalMaximo__c ,
					CaracteristicaGarantia__c,
					(	SELECT Carencia__r.PeriodoMaximoCarencia__c, 
								Carencia__r.TipoPeriodo__c
						FROM CarenciasGarantia__r),
					(	SELECT Franquia__r.Name
								, Franquia__r.LimiteMinimo__c
								, Franquia__r.LimiteMaximo__c
						FROM FranquiasGarantia__r)
			FROM GarantiaProduto__c 
			WHERE Produto__r.Id =: produtoId
					AND TipoGarantia__c = 'Cobertura'
		];
	}
	//PLV-5230 - FIM

}