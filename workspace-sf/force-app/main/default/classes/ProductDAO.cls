/**
 * ProductDAO
 * @author Fernando Barcellos @ 01/11/2017
 *
 **/
public class ProductDAO {

	private static final ProductDAO instance = new ProductDAO();

	public static ProductDAO getInstance() {
		return instance;
	}

	public Product2 buscarProdutoPorId(Id produtoId) {
		List<Product2> produtos = buscarProdutosPorId(new Set<Id> { produtoId });
		return !produtos.isEmpty() ? produtos.get(0) : null;
	}

	public List<Product2> buscarProdutosPorCodigo(Set<String> setProductCode, String developerName){
		return [
				SELECT
						Id,
						ProductCode,
						Versao__c,
						VersaoMaxima__c,
						Status__c,
						TipoResponsavelPagamento__c
				FROM
						Product2
				WHERE
						ProductCode IN: setProductCode
				AND
						RecordType.DeveloperName =: developerName
				AND
						Status__c = 'Ativo'
		];
	}

	public List<AggregateResult> buscarProdutoMaximaVersao(Set<String> setProductCode, String developerName){

		return [
				SELECT
						Id,
						ProductCode,
						MAX(Versao__c) Versao__c,
						VersaoMaxima__c
				FROM
						Product2
				WHERE
						ProductCode IN: setProductCode
				AND
						Status__c = 'Ativo'
				AND
						RecordType.DeveloperName =: developerName
				GROUP BY
								Id,
								ProductCode,
								VersaoMaxima__c
				ORDER BY MAX(Versao__c) DESC
		];

	}

	public List<Product2> buscarProdutoPorId (Set<Id> setProductId){
		return [
				SELECT
						Id,
						Name,
						Status__c,
						VigenciaInicial__c,
						VigenciaFinal__c,
						Versao__c,
						VersaoAnterior__c,
						ProdutoTecnico__c,
						RecordTypeId,
						RecordType.DeveloperName,
						ProductCode,
						Description,
						PercentualDescontoMaximo__c,
						PercentualAgravoMinimo__c,
						PercentualAgravoMaximo__c,
				(
						SELECT
								Id,
								Documento__c,
								Descricao__c,
								MeioEnvio__c,
								Papel__c,
								Tipo__c
						FROM
								DocumentosProduto__r
				),
				(
						SELECT
								Id,
								FormaPagamento__c,
								FormaPagamento__r.Codigo__c,
								FormaPagamento__r.RamoSeguro__r.Codigo__c,
								FormaPagamento__r.Name
						FROM
								CondicoesCobranca__r
				),
				(
						SELECT
								Id,
								Name,
								FormaPagamento__c,
								FormaPagamento__r.Name,
								Produto__c,
								OwnerId,
								PremioMinimoProduto__c,
								PremioMinimoParcela__c,
								TipoContratacao__c,
								PeriodicidadePagamento__c,
								RecordTypeId
						FROM
								PremiosMinimoProduto__r
				),
				(
						SELECT
								Id,
								Garantia__c,
								Garantia__r.Id,
								Garantia__r.Tipo__c,
								Garantia__r.Sigla__c,
								GarantiaProduto__c,
								RecordTypeId,
								TipoCapital__c,
								TipoLimiteCapital__c,
								LimiteCapitalMinimo__c,
								LimiteCapitalMaximo__c,
								LimiteIdadeMinimo__c,
								LimiteIdadeMaximo__c,
								CurrencyIsoCode, //PLV-3884 Fix - Retornando campo de moeda
								Obrigatoria__c
						FROM
								GarantiasProduto__r
				),
				(
						SELECT
								Id,
								Name,
								LimiteMaximo__c,
								LimiteMinimo__c,
								Obrigatoria__c,
								Produto__c,
								TipoRemuneracao__c,
								TipoRemuneracao__r.Name,
								TipoRemuneracao__r.LimiteMinimo__c,
								TipoRemuneracao__r.LimiteMaximo__c,
								TipoRemuneracao__r.Codigo__c
						FROM
								RemuneracoesProduto__r
				)
				FROM
						Product2
				WHERE
				Id IN: setProductId
				AND RecordType.DeveloperName = 'ProdutoComercial'
		];
	}

	public Product2 obterPorCodigo (String codigo)
	{
		List<Product2> l =
		[
				SELECT
						Id,
						Name,
						Status__c,
						VigenciaInicial__c,
						VigenciaFinal__c,
						Versao__c,
						VersaoAnterior__c,
						ProdutoTecnico__c,
						RecordTypeId,
						RecordType.DeveloperName,
						ProductCode,
						Description,
						PercentualDescontoMaximo__c,
						PercentualAgravoMinimo__c,
						PercentualAgravoMaximo__c,
				(
						SELECT
								Id,
								Documento__c,
								Descricao__c,
								MeioEnvio__c,
								Papel__c,
								Tipo__c
						FROM
								DocumentosProduto__r
				),
				(
						SELECT
								Id,
								FormaPagamento__c,
								FormaPagamento__r.Codigo__c,
								FormaPagamento__r.RamoSeguro__r.Codigo__c,
								FormaPagamento__r.Name
						FROM
								CondicoesCobranca__r
				),
				(
						SELECT
								Id,
								Name,
								FormaPagamento__c,
								FormaPagamento__r.Name,
								Produto__c,
								OwnerId,
								PremioMinimoProduto__c,
								PremioMinimoParcela__c,
								TipoContratacao__c,
								PeriodicidadePagamento__c,
								RecordTypeId
						FROM
								PremiosMinimoProduto__r
				),
				(
						SELECT
								Id,
								Garantia__c,
								Garantia__r.Id,
								Garantia__r.Tipo__c,
								Garantia__r.Sigla__c,
								GarantiaProduto__c,
								RecordTypeId,
								TipoCapital__c,
								TipoLimiteCapital__c,
								LimiteCapitalMinimo__c,
								LimiteCapitalMaximo__c,
								LimiteIdadeMinimo__c,
								LimiteIdadeMaximo__c,
								CurrencyIsoCode, //PLV-3884 Fix - Retornando campo de moeda
								Obrigatoria__c
						FROM
								GarantiasProduto__r
				),
				(
						SELECT
								Id,
								Name,
								LimiteMaximo__c,
								LimiteMinimo__c,
								Obrigatoria__c,
								Produto__c,
								TipoRemuneracao__c,
								TipoRemuneracao__r.Name,
								TipoRemuneracao__r.LimiteMinimo__c,
								TipoRemuneracao__r.LimiteMaximo__c,
								TipoRemuneracao__r.Codigo__c
						FROM
								RemuneracoesProduto__r
				)
				FROM
						Product2
				WHERE
				ProductCode = :codigo
				AND Status__c = 'Ativo'
				AND VersaoMaxima__c = true
				AND RecordType.DeveloperName = 'ProdutoComercial'
				LIMIT 1
		];

		if(l.isEmpty())
			return null;
		return
				l[0];
	}

	public List<Product2> buscarProdutosPorId(Set<Id> setIds) {
		return [
				SELECT
						Id,
						Name,
						ProductCode, //PLV-3493 - INICIO/FIM - Inclusao do campo na query
						Status__c,
						VigenciaInicial__c,
						VigenciaFinal__c,
						Versao__c,
						VersaoAnterior__c,
						ProdutoTecnico__c,
						RecordTypeId,
						RecordType.DeveloperName,
						TipoCapital__c,
						NumeroSusep__c,
						// PLV-4290 - INICIO
						Segmento__c,
						// PLV-4290 - FIM
						LimiteTotalCarregamento__c,
						// PLV-4183 - INICIO
						GerarVoucher__c,
						TipoResponsavelPagamento__c,
						ValidaAtivacaoNovaVersao__c,
						// PLV-4183 - FIM
						
				(
						SELECT
								Id,
								FormaPagamento__c,
								FormaPagamento__r.Codigo__c,
								FormaPagamento__r.RamoSeguro__r.Codigo__c,
								FormaPagamento__r.Name
						FROM
								CondicoesCobranca__r
				)
				FROM
						Product2
				WHERE
						Id IN: setIds
		];
	}

	public List<Product2> buscarProdutosAtivosPorSegmento(String segmento, Id tipoRegistro) {
		return [SELECT
				Id,
				Name,
				Description,
				ProductCode,
				VigenciaInicial__c,
				VigenciaFinal__c,
				Versao__c,
				VersaoAnterior__c,
				ProdutoTecnico__c,
		(
				SELECT
						Id,
						Documento__c,
						Descricao__c,
						MeioEnvio__c,
						Papel__c,
						Tipo__c
				FROM
						DocumentosProduto__r
		),
		(
				SELECT
						Id,
						Name,
						CanalDistribuicao__c,
						MeioComercializacao__c,
						DocumentosNaoNecessariosEntrada__c,
						DocumentosNaoNecessariosSaida__c
				FROM
						ProdutosCanal__r
		),
		(
				SELECT
						Id,
						FormaPagamento__c,
						FormaPagamento__r.Codigo__c,
						FormaPagamento__r.RamoSeguro__r.Codigo__c,
						FormaPagamento__r.Name
				FROM
						CondicoesCobranca__r
		)
		FROM
				Product2
		WHERE
		RecordTypeId = :tipoRegistro
		And Status__c = 'Ativo'
		And Segmento__c = :segmento
		];
	}

	public List<Product2> buscarProdutosComDocumentos(Id produtoId) {
		return buscarProdutosComDocumentos(new Set<Id> { produtoId });
	}

	public List<Product2> buscarProdutosComDocumentos(Set<Id> setIds) {
		return
		[
				SELECT
						Id,
						Name,
						Status__c,
				(SELECT Id FROM AttachedContentDocuments)
				FROM
						Product2
				WHERE
						Id IN : setIds
		];
	}

	public List<Product2> buscarProdutosComFilhos(Set<Id> setIds) {
		return [
				SELECT
						Id,
						Name,
						ProductCode,
						Status__c,
						Versao__c,
						VigenciaFinal__c,
						VigenciaInicial__c,
						RelacaoVidas__c,
				(SELECT
						Id,
						Name,
						CapitalRiscos__c,
						Produto__c,
						OrdemPrioridade__c,
						Garantia__c,
						Garantia__r.Name,
						GarantiaProduto__c,
						TipoCapital__c,
						ValorInicial__c,
						ValorFinal__c,
						PercentualAgravoMinimo__c,
						PercentualAgravoMaximo__c,
						PercentualDescontoMinimo__c,
						PercentualDescontoMaximo__c,
						CurrencyIsoCode,
						Garantia__r.Sigla__c,
						RamoSeguro__c
				FROM
						GarantiasProduto__r
				ORDER BY
						OrdemPrioridade__c ASC),
				(SELECT
						Id,
						Name,
						FormaPagamento__c,
						FormaPagamento__r.Name,
						Produto__c,
						OwnerId,
						PremioMinimoProduto__c,
						PremioMinimoParcela__c,
						TipoContratacao__c,
						PeriodicidadePagamento__c,
						RecordTypeId
				FROM
						PremiosMinimoProduto__r),
				(SELECT
						Id,
						Name,
						FormaPagamento__c,
						FormaPagamento__r.Name,
						PercentualMaximo__c,
						PercentualMinimo__c,
						Produto__c,
						OwnerId,
						QuantidadeParcelas__c,
						RegiaoRestricao__c,
						RecordTypeId
				FROM
						CondicoesCobranca__r)
				FROM
						Product2
				WHERE
						Id IN :setIds
		];
	}

	public List<Product2> buscarProdutosComCondicoesCobranca(Set<Id> setIds) {
		return [
				SELECT
						Id,
				(
						SELECT
								Id,
								FormaPagamento__c,
								FormaPagamento__r.Name
						FROM
								CondicoesCobranca__r
				)
				FROM
						Product2
				WHERE
						Id IN : setIds
		];
	}

	public Product2 buscarProdutoPorCodigo(String codigoProduto, Date vigenciaInicial, Date vigenciaFinal) {
		return [
				SELECT
						ID,
						Name,
						Status__c,
				//PLV-2932 Fix2 - Inicio - Adição de parametro no SELECT
				(SELECT Garantia__r.Sigla__c, CurrencyIsoCode, Id FROM GarantiasProduto__r), //PLV-3884 Fix - Retornando campo de moeda
				//PLV-2932 Fix2 - Fim - Adição de parametro no SELECT
				(SELECT Id, Name, FormaPagamento__c, QuantidadeParcelas__c FROM CondicoesCobranca__r)
				FROM
						Product2
				WHERE
				RecordType.DeveloperName = 'ProdutoComercial'
				AND Status__c = 'Ativo'
				AND ProductCode =: codigoProduto
				AND VigenciaInicial__c <=: vigenciaInicial
				AND (VigenciaFinal__c >=: vigenciaFinal OR VigenciaFinal__c = null)
				LIMIT 1
		];
	}

	//PLV-2995 - INICIO - Criação do método para consultar o produto pela data de calculo
	public Product2 buscarProdutoPorCodigoDataCalculo(String codigoProduto, Date dataCalculo) {
		return [
				SELECT
						ID,
						Name,
						Status__c,
						PremioMinimo__c, //PLV-4168 - V.I - INICIO
						Segmento__c, //PLV-4168 - V.I - INICIO
				(SELECT Garantia__r.Sigla__c, Id, CurrencyIsoCode FROM GarantiasProduto__r), //PLV-3729 - INICIO/FIM - Índice monetário
				//PLV-2146 - Início
				(SELECT Id, Name, FormaPagamento__c, QuantidadeParcelas__c, TipoPagamento__c, PercentualDescontoAgravo__c FROM CondicoesCobranca__r)
				//PLV-2146 - Fim     
				//PLV-4403 INICIO
				,(SELECT ID, Tipo__c, PeriodoCoberturaMinimo__c, PeriodoCoberturaMaximo__c FROM ParametrosVigencia__r)     	
				//PLV-4403 FIM

				FROM
						Product2
				WHERE
				RecordType.DeveloperName = 'ProdutoComercial'
				AND Status__c = 'Ativo'				
				AND ProductCode =: codigoProduto
				AND VigenciaInicial__c <=: dataCalculo
				AND (VigenciaFinal__c >=: dataCalculo OR VigenciaFinal__c = null)
				LIMIT 1
		];
	}

	//PLV-2995 - FIM	

	/**
	 * Componente Parametro de vigências - Produto Comercial
	 * @author Fernando Barcellos @ 17/05/2018
	 *
	 */
	public List<ParametroVigencia__c> buscarParametrosVigencia(Id produtoTecnico) {
		return [
				SELECT
						Id,
						Name,
						Tipo__c,
						RecordTypeId,
						RecordType.Name,
						ParametroVigencia__c,
						Produto__c,
						IdadeMaximaRenovacao__c,
						IndiceReajuste__c,
						ModeloResgate__c,
						Periodicidade__c,
						PeriodoCoberturaMinimo__c,
						PeriodoCoberturaMaximo__c,
						PeriodoMaximoInadimplenciaPeriodica__c,
						PeriodoMaximoVigencia__c,
						PeriodoMinimoVigencia__c,
						PrazoAplicacaoReajuste__c,
						PrazoAvisarRenovacao__c,
						PrazoDesistenciaRenovacao__c,
						PrazoMinimoCancelamento__c,
						PrazoRetornoAviso__c,
						ProdutoRenovavel__c,
						QuantidadeRenovacaoesAnuencia__c,
						RenovaEsgotamentoIndenizacao__c,
						TipoPeriodo__c,
						VigenciaMinimaRenovacao__c
				FROM
						ParametroVigencia__c
				WHERE
						Produto__c =: produtoTecnico
				ORDER BY
						Tipo__c ASC
		];
	}

	public List<QuestionarioProduto__c> buscarQuestionariosProduto(Set<Id> produtoIds){
		return [
				SELECT
						Id,
						Produto__c,
						Prioridade__c,
						GarantiaProduto__c,
						LimiteCapitalMaximo__c,
						LimiteCapitalMinimo__c
				FROM
						QuestionarioProduto__c
				WHERE
						Produto__c IN :produtoIds
		];
	}


	public Product2 buscarProdutoGarantiasPorProduto(Id produtoId){
		return [
				SELECT
						id,
						name,
				(
						SELECT id,
								OrdemPrioridade__c,
								RamoSeguro__c,
								CurrencyIsoCode, //PLV-3884 Fix - Retornando campo de moeda
								RamoSeguro__r.Codigo__c
						FROM garantiasproduto__r
						ORDER BY OrdemPrioridade__c
				)
				FROM
						product2
				WHERE
						Id = :produtoId
		];
	}

	public List<RecordType> buscarTiposProdutos(){
		return [
				SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Product2'
		];
	}


	//PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
	public Product2 buscarProdutoEndosso(String produtoId) {
		return [
				SELECT
						ID,
						Name,
						Status__c,
						PremioMinimo__c, //PLV-4168 - V.I - INICIO
						Segmento__c, //PLV-4168 - V.I - INICIO
						ProdutoEndosso__c, //PLV-4666 - INICIO/FIM
						ProdutoRenovacao__c,//PLV-4666 - INICIO/FIM
				(SELECT Garantia__r.Sigla__c, Id, CurrencyIsoCode FROM GarantiasProduto__r), //PLV-3729 - INICIO/FIM - Índice monetário
				//PLV-2146 - Início
				(SELECT Id, Name, FormaPagamento__c, QuantidadeParcelas__c, TipoPagamento__c, PercentualDescontoAgravo__c FROM CondicoesCobranca__r)
				//PLV-2146 - Fim     
				//PLV-4403 INICIO
				,(SELECT ID, Tipo__c, PeriodoCoberturaMinimo__c, PeriodoCoberturaMaximo__c FROM ParametrosVigencia__r)     	
				//PLV-4403 FIM

				FROM
						Product2
				WHERE
				RecordType.DeveloperName = 'ProdutoComercial'
				AND Id =: produtoId
				LIMIT 1
		];
	}
	//PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

	//PLV-5230 - INICIO
	public Product2 buscarProdutoOpin(String produtoId) {
		return [
			SELECT Id, 
					Name,
					NumeroSusep__c,
					ProductCode, 
					Segmento__c, 
					Empresa__r.Name, 
					Empresa__r.Cnpj__c,
				(
					SELECT Id, 
							Name, 
							PeriodicidadePagamento__c, 
							PremioMinimoParcela__c,
							FormaPagamento__r.Id,
							FormaPagamento__r.Name, 
							FormaPagamento__r.Codigo__c 
					FROM PremiosMinimoProduto__r 
					WHERE  TipoContratacao__c = 'Novo' AND
							FormaPagamento__r.Codigo__c <> ''
				) FormasPagamentoPremio,
				(
					SELECT Id, 
							Name, 
							QuantidadeParcelas__c,
							PercentualDescontoAgravo__c,
							FormaPagamento__c 
					FROM CondicoesCobranca__r
				) CondicoesCobranca
			FROM Product2 
			WHERE ID =: produtoId
			LIMIT 1
		];
	}

	public List<Product2> buscarProdutosParaOpin() {
		return [
			SELECT Id, 
					Name
			FROM Product2 
			WHERE Segmento__c IN ('Individual', 'Viagem') AND 
					RecordType.DeveloperName = 'ProdutoComercial' 
					AND Status__c = 'Ativo'
			LIMIT 200
		];
	}
	//PLV-5230 - FIM

	// II-24-FIX01 INICIO
	public Integer buscarCodigoEmpresa(String idProduto) {
		List<Product2> listresult = [
			SELECT Empresa__r.CodigoEmpresa__c FROM Product2 WHERE Id =  :idProduto
		];
		return (listresult != null && listresult.size()>0) ? Integer.valueOf(listresult.get(0).Empresa__r.CodigoEmpresa__c) : null; 
	}
	// II-24-FIX01 FIM

	//RVI-202 INICIO
	public String buscarEmpresa14() {
		List<Product2> listresult = [
			SELECT Id, Empresa__r.CodigoEmpresa__c FROM Product2 WHERE Empresa__r.CodigoEmpresa__c = '14' AND Status__c = 'Ativo' AND Segmento__c = 'Individual' AND CodigoPrecificaProduto__c = 'VI-PESSOAS'
		];
		return (listresult != null && listresult.size()>0) ? listresult.get(0).Id : null; 
	}
	//RVI-202 FIM

	//PLV-5331 - INICIO
	public Product2 buscProdPrecDtCalc(String codPrecProd, String idProdutoSf) {
        system.debug('buscProdPrecDtCalc baixo');
        system.debug('codPrecProd = ' + codPrecProd);
        system.debug('idProdutoSf = ' + idProdutoSf);
        system.debug('buscProdPrecDtCalc acima');
		return [ 
			SELECT ProductCode, CodigoPrecificaProduto__c FROM Product2 
			WHERE CodigoPrecificaProduto__c =: codPrecProd AND Id =: idProdutoSf  LIMIT 1
		];
	}	
	//PLV-5331 - FIM

	//VIAG-148-FIX02-INICIO
	public Map<Id,Product2> buscarProdPorCod(Set<Id> idProdutoSf){
		Map<Id,Product2> retornoIdProduto = new Map<Id,Product2>([SELECT ProductCode, CodigoPrecificaProduto__c FROM Product2 
		WHERE Id IN:idProdutoSf]);
		return retornoIdProduto;
	}
	//VIAG-148-FIX02-FIM

	//PLV-5331 - INICIO
	public List<Product2> buscProdPrecDtCalcList(Set<String> codPrecProd, Set<String> idProdutoSf) {
        system.debug('buscProdPrecDtCalc baixo');
        system.debug('codPrecProd = ' + codPrecProd);
        system.debug('idProdutoSf = ' + idProdutoSf);
        system.debug('buscProdPrecDtCalc acima'); 
		return [ 
			SELECT ProductCode, CodigoPrecificaProduto__c FROM Product2 
			WHERE CodigoPrecificaProduto__c IN: codPrecProd AND Id IN: idProdutoSf  LIMIT 1
		];
	}	
	//PLV-5331 - FIM


	//PLV - 5355 - Inicio
	public boolean buscProductIndividual(String payloadCodigoProdutoVida) {
		List<Product2> listIndividual = [ 
			SELECT Id,CodigoPrecificaProduto__c FROM Product2 
			WHERE Segmento__c = 'Individual' AND Status__c = 'Ativo'
		];
            for(Product2 prod : listIndividual){
				system.debug('prod.CodigoPrecificaProduto__c Danilo:' + prod.CodigoPrecificaProduto__c);
				system.debug('payloadCodigoProdutoVida Danilo:' + payloadCodigoProdutoVida);
                if(prod.CodigoPrecificaProduto__c == payloadCodigoProdutoVida){
					return true;
                }
            }
		return false;
	}
	//PLV - 5355 - FIM

	// RVI-202 - INICIO / NÃO UTILIZADO
	// public List<Product2> entCalcConv(String codPrd, String codEmp, String statPrd, Integer startPos, Integer endPos) {
			
	// 	String prodBusca = codPrd.substring(startPos, endPos) + '%';
		
	// 	List<Product2> lstCodProvid = [SELECT Id, CodigoPrecificaProduto__c FROM Product2 
	// 								   WHERE Empresa__r.CodigoEmpresa__c =: codEmp  
	// 								   AND  Status__c =: statPrd 
	// 								   AND ProductCode LIKE :prodBusca LIMIT 1];

	// 	return lstCodProvid;
	// }
	// RVI-202 - FIM / NÃO UTILIZADO
}