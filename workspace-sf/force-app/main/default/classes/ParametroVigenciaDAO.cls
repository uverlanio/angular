/**
 * DAO ParametroVigencia
 * @author Fernando Barcellos @ 17/05/2018
 *
 **/
public class ParametroVigenciaDAO {
	private static ParametroVigenciaDAO classInstance;

	static {
		classInstance = new ParametroVigenciaDAO();
	}

	private ParametroVigenciaDAO() {

	}

	public static ParametroVigenciaDAO getInstance() {
		return classInstance;
	}

	public List<ParametroVigencia__c> buscarParametrosVigencia() {
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
		];
	}

	public List<ParametroVigencia__c> buscarParametrosVigencia(Set<Id> ids) {
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
						Id IN : ids
		];
	}


	public List<ParametroVigencia__c> buscarParametrosVigenciaProduto(Set<Id> idsProduto)
	{
		return
		[
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
						Produto__c IN : idsProduto
		];
	}
}