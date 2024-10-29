/**************************************************************************************************************************************************************************
 *
 *	Classe responsável pela busca de dados de Account
 *
 **************************************************************************************************************************************************************************/
public virtual class AccountDAO 
{
	private static final AccountDAO instancia = new AccountDAO();

	private AccountDAO() {	}

	public static AccountDAO getInstance(){
		return instancia;
	}
	

	public List<Account> buscarContasComFilhos(Set<Id> contaIds){
		return [
			SELECT
				Id,
                //PLV2365: INICIO
				RecordTypeId,
				//PLV2365: INICIO
				//PLV-4148 - INICIO
				NomeFantasia__c,
				//PLV4148 - FIM
				Papel__c,
				Cpf__c,
				Cnpj__c,
				ServicosParceiro__c,
				ServicosPrestador__c,
				CodigoSusepCorretor__c,
				Sucursal__c,
				Renda__c,
				CodigoSusepCia__c,
				NumeroContratoParceiro__c,
				NumeroContratoPrestador__c,
				NumeroContratoRespresentante__c,
				IdExterno__c,
				Name,
				Pep__c,
				CurrencyIsoCode,
				Email__c,
                //PLV2365: INICIO
				Sexo__c,
				EstadoCivil__c,
				PersonBirthdate,
                //PLV2365: FIM
				(
					SELECT
						Id,
						Papel__c,
						Banco__c,
						// PLV-4473 - INICIO
						BancoNew__r.Name,
						BancoNew__r.Id,
						BancoNew__r.CodigoBanco__c,
						// PLV-4473 - FIM
						Agencia__c,
						NumeroConta__c,
                        Principal__c,
                        //PLV-4445 INICIO
                        Digito__c
                        //PLV-4445 FIM
					FROM
						InformacoesBancarias__r
				),
				(
					SELECT
						Id,
						Conta__c,
						Bairro__c,
						CEP__c,
						Cidade__c,
						Complemento__c,
						Estado__c,
						Logradouro__c,
						NumeroEndereco__c,
						TipoEndereco__c,
						TipoLogradouro__c
					FROM
						ContratantesOrcamento__r
				),
				//PLV2365: INICIO
				(
					SELECT
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
						Enderecos__r
				)
				//PLV2365: FIM
			FROM
				Account
			WHERE
				Id IN: contaIds
		];
	}

	public List<Account> buscarContasComFilhos1(Set<Id> contaIds){
		return [
			SELECT
				Id,
				Papel__c,
				Cpf__c,
				Cnpj__c,
				ServicosParceiro__c,
				ServicosPrestador__c,
				CodigoSusepCorretor__c,
				Sucursal__c,
				CodigoSusepCia__c,
				NumeroContratoParceiro__c,
				NumeroContratoPrestador__c,
				NumeroContratoRespresentante__c,
				IdExterno__c,
				Pep__c,
				CurrencyIsoCode,
				Renda__c,
				Email__c,
				(
					SELECT
						Id,
						Papel__c,
						Banco__c,
						Agencia__c,
						NumeroConta__c,
						Principal__c
					FROM
						InformacoesBancarias__r
				),
				(
					SELECT
						Id,
						Conta__c,
						Bairro__c,
						CEP__c,
						Cidade__c,
						Complemento__c,
						Estado__c,
						Logradouro__c,
						NumeroEndereco__c,
						TipoEndereco__c,
						TipoLogradouro__c
					FROM
						ContratantesOrcamento__r
				)
			FROM
				Account
			WHERE
				Id IN: contaIds
		];
	}

	public List<Account> buscarEmpresasGrupoPorto() {
		return [
			SELECT
				Id,
				Name,
				CodigoEmpresa__c
			FROM
				Account
			WHERE
				CodigoEmpresa__c != NULL
		];
	}

	public List<Account> buscarContasPorPapel(String papel) {
		return  [
			SELECT
				Id,
				Name,
				CodigoSusepCorretor__c
			FROM
				Account
			WHERE
				Papel__c =: papel
			ORDER BY
				Name ASC
		];
	}

	public List<Account> buscarContasPorIdExterno(Set<String> idsExternos) {
		return [
			SELECT
				Id,
				//Name,
				LastName,
				PersonEmail,
				Rg__c,
				DataExpedicao__c,
				OrgaoExpedidor__c,
				PersonBirthDate,
				EstadoCivil__c,
				Nacionalidade__c,
				PaisDeOrigem__c, //PLV-5231 - INICIO/FIM
				Sexo__c,
				ParentId,
				RecordTypeId,
				Cpf__c,
				Cnpj__c,
				Papel__c,
				Sucursal__c,
				SusepPrincipal__c,
				IdExterno__c,
				Email__c,
				Renda__c,
				(
					SELECT
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
						Enderecos__r
				)
			FROM
				Account
			WHERE IdExterno__c IN :idsExternos
		];
	}

	public List<Account> buscarContasPorCodEmpresa(Set<String> codigos) {
		return [
			SELECT
				Id,
				CodigoEmpresa__c
			FROM
				Account
			WHERE CodigoEmpresa__c IN :codigos
		];
	}
}