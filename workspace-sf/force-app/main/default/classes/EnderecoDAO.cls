/**
 * EnderecoDAO
 * @author Fernando Barcellos @ 19/12/2017
 *
 **/
public class EnderecoDAO {

	private static final EnderecoDAO instance = new EnderecoDAO();

	public static EnderecoDAO getInstance() {
		return instance;
	}

	public Endereco__c buscarEnderecoConta(String idConta) {
		List<Endereco__c> lst = buscarEnderecoContas(new Set<Id> {idConta});
		return lst.isEmpty() ? null : lst[0];
	}

	public List<Endereco__c> buscarEnderecosConta(String idConta) {
		List<Endereco__c> lst = buscarEnderecoContas(new Set<Id> {idConta});
		return lst;
	}

	public List<Endereco__c> buscarEnderecoContas(Set<Id> idsContas) {
		return [
			SELECT
				Id,
				Name,
				CEP__c,
				Cidade__c,
				Complemento__c,
				Conta__c,
				Estado__c,
				Logradouro__c,
				MaisAtual__c,
				Numero__c,
				Pais__c,
				TipoEndereco__c,
				TipoLogradouro__c,
				Bairro__c
			FROM
				Endereco__c
			WHERE
				Conta__c IN: idsContas
		];
	}

	public List<Endereco__c> buscarEnderecosDesatualizados(Set<Id> idsContas) {
		return [
			SELECT
				Id,
				Conta__c,
				MaisAtual__c
			FROM
				Endereco__c
			WHERE
				MaisAtual__c = true
				AND Conta__c IN :idsContas
		];
	}

	public List<Endereco__c> buscarEnderecosPorId(Set<Id> idsEndereco) {
		return [
			SELECT
				Id,
				Name,
				CEP__c,
				Cidade__c,
				Complemento__c,
				Conta__c,
				Estado__c,
				Logradouro__c,
				MaisAtual__c,
				Numero__c,
				Pais__c,
				TipoEndereco__c,
				TipoLogradouro__c
			FROM
				Endereco__c
			WHERE
				Id IN :idsEndereco
		];
	}
}