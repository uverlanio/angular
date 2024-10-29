public with sharing class GarantiaGrupoOrcamentoDAO 
{
	private static final GarantiaGrupoOrcamentoDAO instancia = new GarantiaGrupoOrcamentoDAO();
	private GarantiaGrupoOrcamentoDAO() {}
	public static GarantiaGrupoOrcamentoDAO getInstance() { return instancia; }

	// public List<GarantiaOrcamento__c> listaGarantiasSegurado (Set<Id> setIdVida)
	// {
	// 	return 
	// 	[
	// 		SELECT
	// 			Capital__c,
	// 			ClausulaReducaoFranquiaAcidente__c,
	// 			DescontoAgravo__c,
	// 			GarantiaProduto__c,
	// 			IncluirFilhos__c,
	// 			IncluirIndenizacaoEspecial__c,
	// 			NumeroSorte__c,
	// 			NumeroSerie__c,
	// 			Percentual__c,
	// 			PercentualFilhos__c,
	// 			PercentualIndenizacaoEspecial__c,
	// 			PercentualReferenciado__c,
	// 			PremioComercial__c,
	// 			PremioComercialDesconto__c,
	// 			PremioPuro__c,
	// 			PremioPuroDesconto__c,
	// 			PremioPuroInterno__c,
	// 			PremioPuroResseguro__c,
	// 			Quantidade__c,
	// 			TaxaAnual__c,
	// 			TaxaComercial__c,
	// 			TaxaPura__c,
	// 			TaxaMensal__c,
	// 			Valor__c,
	// 			ValorCotacao__c,
	// 			// TODO: eric  as garantias do grupo não serao relacionadas com o segurado
	// 			//SeguradoOrcamento__c,
	// 			GrupoOrcamento__c,
	// 			GarantiaOrcamento__c,
	// 			ContratanteOrcamento__c
				
	// 		FROM
	// 			GarantiaGrupoOrcamento__c
	// 		WHERE
	// 			SeguradoOrcamento__c =: setIdVida
	// 	];
	// }
}