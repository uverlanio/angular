public class FaturaDAO {

	private static final FaturaDAO instancia = new FaturaDAO();

	private FaturaDAO(){}

	public static FaturaDAO getInstance(){
		return instancia;
	}

	public List<Fatura__c> buscarFaturasPorIds(Set<Id> Ids) {
		return [SELECT
						Id,
						Name,
						Apolice__c,
						Empresa__c,
						Conta__c,
						Sucursal__c,
						Ramo__c,
						CodigoProdutoComercial__c,
						DataEmissao__c,
						DataVencimento__c,
						Endosso__c,
						FinalCompetencia__c,
						InicioCompetencia__c,
						Origem__c,
						Parceiro__c,
						Parceiro__r.Name,
						Parceiro__r.Codigo__c,
						Proposta__c,
						Status__c,
						TipoFatura__c,
						ValorIOF__c,
						ValorLiquido__c,
						ValorTotal__c,
						IdFatura__c,
						DataPagamento__c // PLV-2192-27 - mudançã de assinatura do metodo - INICIO - FIM
		FROM
						Fatura__c
		WHERE
						Id IN :Ids];
	}

	public List<Fatura__c> buscarFaturasPorParceiro(Set<Id> setParceirosIds) {
		return [SELECT
						Id,
						Apolice__c,
						Empresa__c,
						Conta__c,
						Sucursal__c,
						Ramo__c,
						CodigoProdutoComercial__c,
						DataEmissao__c,
						DataVencimento__c,
						Endosso__c,
						FinalCompetencia__c,
						InicioCompetencia__c,
						Origem__c,
						Parceiro__c,
						Proposta__c,
						Status__c,
						TipoFatura__c,
						ValorIOF__c,
						ValorLiquido__c,
						ValorTotal__c
		FROM
						Fatura__c
		WHERE
		Parceiro__c IN :setParceirosIds
		AND TipoFatura__c = 'BatimentoContabil'
		AND Status__c <> 'Cancelada'
		ORDER BY Parceiro__c, DataEmissao__c, Name DESC];
	}

	public List<Fatura__c> buscarFaturasPorCodigo(List<String> codigosFatura){
		return [SELECT
						Name,
						Apolice__c,
						Empresa__c,
						Conta__c,
						Sucursal__c,
						Ramo__c,
						CodigoProdutoComercial__c,
						DataEmissao__c,
						DataVencimento__c,
						Endosso__c,
						FinalCompetencia__c,
						InicioCompetencia__c,
						Origem__c,
						Parceiro__c,
						Proposta__c,
						Status__c,
						TipoFatura__c,
						ValorIOF__c,
						ValorLiquido__c,
						ValorTotal__c
		FROM
						Fatura__c
		WHERE
						Name IN :codigosFatura];
	}


}