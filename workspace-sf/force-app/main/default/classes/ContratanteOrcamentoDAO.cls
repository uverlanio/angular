public with sharing class ContratanteOrcamentoDAO 
{
	private static final ContratanteOrcamentoDAO instancia = new ContratanteOrcamentoDAO();
	private ContratanteOrcamentoDAO() {}
	public static ContratanteOrcamentoDAO getInstance(){ return instancia; } 

	public List<ContratanteOrcamento__c> buscarContratantesPrincipaisPorOrcamento(Set<Id> idsOrcamentos) 
	{
		return 
		[
			SELECT
				Id,
				Bairro__c,
				Cidade__c,
				Complemento__c,
				Conta__c,
				Estado__c,
				IOF__c,
				Logradouro__c,
				Numero__c,
				NumeroEndereco__c,
				Orcamento__c,
				Pais__c,
				PremioComercial__c,
				PremioPuro__c,
				TaxaComercial__c,
				TaxaPura__c,
				Tipo__c,
				TipoEndereco__c,
				TipoLogradouro__c
				
			FROM
				ContratanteOrcamento__c
			WHERE 
				Tipo__c = :	'Principal' AND
				Orcamento__c IN :idsOrcamentos
		];
	}

	// PLV-2414-iNICIO
	public List<CondicaoCobranca__c> buscarCondicaoCobranca(String idProduto) 
	{
		// ANNVI-48 - INICIO
		//PLV-2938 - Inicio - Adição de parametro no SELECT
		//PLV-3318 - INICIO INCLUSAO DE PARAMETRO PercentualDescontoAgravo__c
		List<CondicaoCobranca__c> retLst= [SELECT FormaPagamento__c,
							//PLV-3571 - INICÍO
							NomeFormaPagamento__c,
							//PLV-3571 - FIM
							FormaPagamento__r.Name, 
							FormaPagamento__r.Codigo__c,	
							TipoPagamento__c,
							AntecipacaoComissao__c, //PLV-4344 - Inicio/Fim
							QuantidadeParcelas__c,
							PercentualDescontoAgravo__c
							// LimiteValorParcela__c // ANNVI-48 - INICIO/FIM
					   FROM CondicaoCobranca__c 
					   WHERE Produto__r.ProductCode = :idProduto
                       AND Produto__r.Status__c = 'Ativo']; //PLV-4344 - Inicio/Fim
        //PLV-3318 - FIM
		//PLV-2938 - Fim - Adição de parametro no SELECT

		System.debug('buscarCodicaoCobranca '+retLst);
		return retLst;
		// ANNVI-48 - FIM
	}
	 // PLV-2414-FIM

	public List<GarantiaContratanteOrcamento__c> listarGarantias(Set<Id> idsContratante)
	{
		return
		[
			SELECT
				Capital__c,
				IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
				ClausulaReducaoFranquiaAcidente__c,
				ContratanteOrcamento__c,
				DescontoAgravoMonetarioComercial__c,
				DescontoAgravoMonetarioInformado__c,
				DescontoAgravoMonetarioTecnico__c,
				DescontoAgravoPercentualComercial__c,
				DescontoAgravoPercentualInformado__c,
				DescontoAgravoPercentualTecnico__c,
				DescontoAgravo__c,
				GarantiaProduto__c,
				Garantia__c,
				//PLV-3455 - INICIO - Incluir campo sigla
				Garantia__r.Sigla__c,
				//PLV-3455 - FIM
				Id,
				Name,
				NumeroSerie__c,
				NumeroSorte__c,
				PercentualFilhos__c,
				PercentualIndenizacaoEspecial__c,
				PercentualReferenciado__c,
				Percentual__c,
                PremioComercialDesconto__c,
				PremioComercial__c,
				PremioPuroDesconto__c,
				PremioPuroInterno__c,
				PremioPuroResseguro__c,
				PremioPuro__c,
				PremioTotal__c,
				Quantidade__c,
				CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
				TaxaAnual__c,
				TaxaComercial__c,
				TaxaMensal__c,
				TaxaPura__c,
				TaxaPuroInterno__c,
				TaxaPuroResseguro__c,
				TaxaTotal__c,
				TipoDescontoAgravo__c,
				ValorCotacao__c,
				Valor__c
			FROM
				GarantiaContratanteOrcamento__c
			WHERE
				ContratanteOrcamento__c IN: idsContratante

		];
	}
}