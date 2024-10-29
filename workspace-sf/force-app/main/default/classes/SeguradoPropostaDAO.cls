public without sharing class SeguradoPropostaDAO //FNPVVEP-126 INICIO-FIM
{
	private static final SeguradoPropostaDAO instancia = new SeguradoPropostaDAO();
	private SeguradoPropostaDAO(){}
	public static SeguradoPropostaDAO getInstance(){ return instancia; }


	public List<SeguradoProposta__c> buscarGruposPropostaPorIds(Set<Id> setGrupos)
	{
		return 
		[
			SELECT
				Id,
				Numero__c,
				PremioPuro__c,
				PremioComercial__c,
				PremioTotal__c,
				TaxaPura__c,
				TaxaTotal__c,
				TaxaComercial__c,
				IOF__c,
				QuantidadeParcelas__c,
				TipoResponsavelPagamento__c,
				VencimentoPrimeiraParcela__c,
				//PLV-5033 - INICIO
				FaixaRenda__c,
				PEP__c,
				Conta__c,
				//PLV-5033 - FIM
				FormaPagamento__r.Codigo__c,
				GrupoProposta__r.ContratanteProposta__r.Proposta__c,
				Conta__r.RecordType.DeveloperName,
				Conta__r.RecordTypeId,
				Conta__r.Name,
				Conta__r.NomeSocial__c, //LECVPV 192 - INICIO/FIM
				Conta__r.Email__c,
				Conta__r.Cpf__c,
				Conta__r.Sexo__c,
				Conta__r.EstadoCivil__c,
				Conta__r.Cnpj__c,
				Conta__r.PersonAssistantPhone,
				Conta__r.PersonHomePhone,
				Conta__r.PersonOtherPhone,
				Conta__r.PersonMobilePhone, // PLV-4601-FIX2
				Conta__r.Phone,
				Conta__r.Fax,
				Conta__r.PersonEmail, //PLV-3572 - INICIO/FIM 
				//PLV-3572 - INICIO - Enviar para BCP dados do segurado
				Conta__r.PersonBirthdate,
				//PLV-3572 - FIM - Enviar para BCP dados do segurado
				ResponsavelPagamento__c,
				ResponsavelPagamento__r.Id,
				ResponsavelPagamento__r.Name,
				ResponsavelPagamento__r.Email__c,
				ResponsavelPagamento__r.RecordTypeId,
				ResponsavelPagamento__r.Papel__c,
				ResponsavelPagamento__r.Cpf__c,
				ResponsavelPagamento__r.Cnpj__c,
				ResponsavelPagamento__r.ServicosParceiro__c,
				ResponsavelPagamento__r.Sexo__c,
				ResponsavelPagamento__r.ServicosPrestador__c,
				ResponsavelPagamento__r.CodigoSusepCorretor__c,
				ResponsavelPagamento__r.Sucursal__c,
				ResponsavelPagamento__r.CodigoSusepCia__c,
				ResponsavelPagamento__r.NumeroContratoParceiro__c,
				ResponsavelPagamento__r.NumeroContratoPrestador__c,
				ResponsavelPagamento__r.NumeroContratoRespresentante__c,
				ResponsavelPagamento__r.IdExterno__c,
				ResponsavelPagamento__r.Profissao__c,
				ResponsavelPagamento__r.EstadoCivil__c,
				ResponsavelPagamento__r.PersonAssistantPhone,
				ResponsavelPagamento__r.PersonBirthdate,
				ResponsavelPagamento__r.PersonHomePhone,
				ResponsavelPagamento__r.PersonOtherPhone,
				ResponsavelPagamento__r.PersonMobilePhone, // PLV-4601-FIX2
				ResponsavelPagamento__r.Phone,
				ResponsavelPagamento__r.Fax
			FROM
				SeguradoProposta__c
			WHERE 
				GrupoProposta__c IN :setGrupos
		];
	}

	public List<SeguradoProposta__c> buscarGruposPropostaPorPropostaIds(Set<Id> setPropostas)
	{
		return [
			SELECT
				Id,
				Conta__c,
				GrupoProposta__r.ContratanteProposta__r.Proposta__c
			FROM
				SeguradoProposta__c
			WHERE 
				GrupoProposta__r.ContratanteProposta__r.Proposta__c = :setPropostas
		];
	}
}