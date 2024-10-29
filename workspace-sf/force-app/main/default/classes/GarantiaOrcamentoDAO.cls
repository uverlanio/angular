public class GarantiaOrcamentoDAO 
{
	private static final GarantiaOrcamentoDAO instancia = new GarantiaOrcamentoDAO();
	private GarantiaOrcamentoDAO() {}
	public static GarantiaOrcamentoDAO getInstance() { return instancia; }

	public List<GarantiaOrcamento__c> listarGarantiasOrcamento(Set<Id> idsOrcamentos)
	{
		return
		[
			SELECT
				Capital__c,
				DescontoAgravo__c,
				Garantia__c,
				GarantiaProduto__c,
				LimiteCapital__c,
				NumeroSorte__c,
				NumeroSerie__c,
				Orcamento__c,
				Percentual__c,
                PremioComercial__c,
				PremioPuro__c,
				PremioComercialDesconto__c,
				PremioPuroDesconto__c,
				PremioPuroResseguro__c,
				PremioPuroInterno__c,
				CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
				TaxaAnual__c,
				TaxaComercial__c,
				TaxaMensal__c,
				TaxaPura__c,
				TaxaPuroInterno__c,
				TipoCapital__c,
				TaxaPuroResseguro__c
			FROM
				GarantiaOrcamento__c
			WHERE
				Orcamento__c = :idsOrcamentos
		];
	}
}