/**
 * Controller para o componente SeletorParametrosVigencia.cmp
 * @author Fernando Barcellos @ 07/05/2018
 *
 **/
public class SeletorParametrosVigenciaController {

	@AuraEnabled
	public static List<ParametroVigencia__c> buscarParametrosVigencia(Id idProduto) {
		Product2 produtoComercial = ProductBO.getInstance().buscarProdutos(new Set<Id>{ idProduto }, false)[0];
		List<ParametroVigencia__c> parametrosVigenciaProdutoTec = ProductDAO.getInstance().buscarParametrosVigencia(produtoComercial.ProdutoTecnico__c);
		return parametrosVigenciaProdutoTec;
	}

	@AuraEnabled
	public static Id clonarParametroVigencia(Id idProdutoComercial, Id idParametroVigencia) {
		try {

			List<ParametroVigencia__c> parametrosVigenciaRemover = [SELECT Id FROM ParametroVigencia__c WHERE Produto__c =: idProdutoComercial];
			//List<FaixaDevolucao__c> faixasDevolucaoRemover = [SELECT Id FROM FaixaDevolucao__c WHERE ParametroVigencia__c IN : parametrosVigenciaRemover];

			delete parametrosVigenciaRemover;
			//delete faixasDevolucaoRemover;

			Product2 produtoComercial = [SELECT Id, RecordTypeId FROM Product2 WHERE Id =: idProdutoComercial LIMIT 1];
			System.debug('::: produtoComercial: ' + produtoComercial);

			ParametroVigencia__c parametroVigenciaExistente = [SELECT Id, Name, RecordTypeId, IdadeMaximaRenovacao__c, IndiceReajuste__c, ModeloResgate__c, ParametroVigencia__c, Periodicidade__c, PeriodoCoberturaMinimo__c, PeriodoCoberturaMaximo__c, PeriodoMaximoInadimplenciaPeriodica__c, PeriodoMaximoVigencia__c, PeriodoMinimoVigencia__c, PrazoAplicacaoReajuste__c, PrazoAvisarRenovacao__c, PrazoDesistenciaRenovacao__c, PrazoMinimoCancelamento__c, PrazoRetornoAviso__c, Produto__c, ProdutoRenovavel__c, QuantidadeRenovacaoesAnuencia__c, RenovaEsgotamentoIndenizacao__c, Tipo__c, TipoPeriodo__c, VigenciaMinimaRenovacao__c, PeriodoMaximoInadimplencia__c  FROM ParametroVigencia__c WHERE Id =: idParametroVigencia LIMIT 1];
			System.debug('::: parametroVigenciaExistente: ' + parametroVigenciaExistente);

			ParametroVigencia__c parametroVigenciaClone = parametroVigenciaExistente.clone();
			parametroVigenciaClone.RecordTypeId = RecordTypeBO.buscarTipoRegistro('ParametroVigencia__c', 'ProdutoComercial').Id;
			parametroVigenciaClone.Produto__c = produtoComercial.Id;
			parametroVigenciaClone.ParametroVigencia__c = parametroVigenciaExistente.Id;
			parametroVigenciaClone.PeriodoMaximoInadimplencia__c = parametroVigenciaExistente.PeriodoMaximoInadimplencia__c;
			insert parametroVigenciaClone;

			List<FaixaDevolucao__c> faixasDevolucaoClone = new List<FaixaDevolucao__c>();
			List<FaixaDevolucao__c> faixasDevolucaoExistentes = [SELECT Id, FaixaDe__c, FaixaAte__c, FaixaDevolucao__c, Name, ParametroVigencia__c, Percentual__c, RecordTypeId FROM FaixaDevolucao__c WHERE ParametroVigencia__c =: parametroVigenciaExistente.Id];

			if (faixasDevolucaoExistentes.size() > 0) {
				for (FaixaDevolucao__c faixaDevolucaoOriginal : faixasDevolucaoExistentes) {
					FaixaDevolucao__c faixaDevolucao = faixaDevolucaoOriginal.clone();
					faixaDevolucao.RecordTypeId = RecordTypeBO.buscarTipoRegistro('FaixaDevolucao__c', 'ProdutoComercial').Id;
					faixaDevolucao.ParametroVigencia__c = parametroVigenciaClone.Id;
					faixasDevolucaoClone.add(faixaDevolucao);
				}
				insert faixasDevolucaoClone;
			}

			//System.debug('::: parametroVigenciaClone: ' + parametroVigenciaClone);

			return parametroVigenciaClone.Id;
		}
		catch(Exception e) {
			System.debug('::: ERR: ' + e.getLineNumber() + ' @ ' + e.getMessage());
			return null;
		}
	}

}