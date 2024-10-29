public with sharing class GrupoOrcamentoDAO 
{
	private static final GrupoOrcamentoDAO instancia = new GrupoOrcamentoDAO();
	private GrupoOrcamentoDAO() {}
	public static GrupoOrcamentoDAO getInstance() { return instancia; }

	public List<GrupoOrcamento__c> listarGrupoOrcamento(Set<Id> idsOrcamentoContratante) 
	{
		return 
		[
			SELECT
				CodigoArquivo__c,
				ContratanteOrcamento__c,
				DescontoAgravoMonetarioComercial__c,
				DescontoAgravoMonetarioInformado__c,
				DescontoAgravoMonetarioTecnico__c,
				DescontoAgravoPercentualComercial__c,
				DescontoAgravoPercentualInformado__c,
				DescontoAgravoPercentualTecnico__c,
				DescontoAgravo__c,
				Descricao__c,
				Id,
				IOF__c,
				Name,
				Numero__c,
				Percentual__c,
				PremioComercial__c,
				PremioPuro__c,
				PremioTotal__c,
				PremioIntegral__c, //PLV-5351 INICIO/FIM
				QuantidadeVidas__c,
				TaxaComercial__c,
				TaxaPura__c,
				TaxaTotal__c,
				TipoCalculo__c,
				TipoDescontoAgravo__c,
				(
					SELECT
						Capital__c,
						ClausulaReducaoFranquiaAcidente__c,
						DescontoAgravoMonetarioComercial__c,
						DescontoAgravoMonetarioInformado__c,
						DescontoAgravoMonetarioTecnico__c,
						DescontoAgravoPercentualComercial__c,
						DescontoAgravoPercentualInformado__c,
						DescontoAgravoPercentualTecnico__c,
						DescontoAgravo__c,
						GarantiaProduto__c,
						Garantia__c,
						IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
						//PLV-3455 - INICIO - Sigla garantia
						Garantia__r.Sigla__c,
						//PLV-3455 - FIM
						GrupoOrcamento__c,
						Id,
						Name,
						NumeroSerie__c,
						NumeroSorte__c,
						PercentualFilhos__c,
						PercentualIndenizacaoEspecial__c,
						PercentualReferenciado__c,
						Percentual__c,
						PremioComercialDesconto__c,
						PremioPuroDesconto__c,
						PremioIntegral__c, //PLV-5351 INICIO/FIM
						PremioPuroInterno__c,
						PremioPuroResseguro__c,
                        PremioComercial__c,
						PremioPuro__c,
						PremioTotal__c,
						ValorCotacao__c,
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
						Valor__c
					FROM
						GruposGarantiaOrcamento__r
				),
				(
					SELECT
						Afastado__c,
						CID__c,
						Conta__c,
						// PLV-4675 INICIO
						Conta__r.Name,
						Conta__r.NomeSocial__c, // LECVPV-188(CANCELAMENTO) INICIO/FIM
						Conta__r.PersonMobilePhone,
						Conta__r.PersonHomePhone,
						Conta__r.Phone,
						Conta__r.EmpresaTrabalhaSocio__c,
						Conta__r.Ramo_de_atividade__c,  // PLV-4810  INICIO/FIM SYS4B ODEMIR
						Conta__r.PersonEmail,
						Conta__r.MelhorPeriodoContato__c,
						Conta__r.Renda__c,
						// PLV-4675 FIM
						CPF__c,
						DataNascimento__c,
						DescontoAgravoMonetarioComercial__c,
						DescontoAgravoMonetarioInformado__c,
						DescontoAgravoMonetarioTecnico__c,
						DescontoAgravoPercentualComercial__c,
						DescontoAgravoPercentualInformado__c,
						DescontoAgravoPercentualTecnico__c,
						EnderecoBoleto__c,
						GrupoOrcamento__c,
						Id,
						IOF__c,
						IPCA__c,
						Name,
						Numero__c,
						PorcentagemParticipacaoSegurado__c,
						PorcentagemParticipacaoVida__c,
						PremioParcela__c,
						PremioIntegral__c, //PLV-5351 INICIO/FIM
						PremioComercial__c,
						PremioPuro__c,
						PremioTotal__c,
						QuantidadeParcelas__c,
						Reenquadramento__c,
						TaxaComercial__c,
						TaxaPura__c,
						TaxaTotal__c,
						TipoCusteio__c,
						TipoDescontoAgravo__c,
						TipoResponsavelPagamento__c,
						TemDependentes__c, //PLV-4441-VI-Fix4 - INICIO/FIM
						VencimentoPrimeiraParcela__c,
						// PLV-4606 - INICIO
						Profissao__r.name,
						Profissao__r.Limite_de_capital_maximo__c,
						Profissao__r.CodigoProfissao__c,
						Profissao__r.Codigo__c,
						FaixaRenda__c,
						RegimeTrabalho__c,
						Conta__r.Pep__c,
						Conta__r.Type,
						Conta__r.PaisResidencia__c,
						Conta__r.OrgaoExpedidor__c,
						Conta__r.EstadoCivil__c,
						Conta__r.DocIndentificacao__c,
						Conta__r.ResideBrasil__c,
						Conta__r.Fumante__c,
						Conta__r.Cpf__c,
						Conta__r.DataExpedicao__c,
						Conta__r.Idade__c,
						Conta__r.TipoDocidentificacao__c,
						Conta__r.Sexo__c,
						Conta__r.PersonBirthdate,
						Conta__r.Nacionalidade__c,
						Conta__r.RegimeTrabalho__c,
						Conta__r.Profissao__c
						// PLV-4606 - FIM

					FROM
						SeguradosOrcamento__r
				)
			FROM
				GrupoOrcamento__c
			WHERE 
		
				ContratanteOrcamento__c IN :idsOrcamentoContratante
		];
	}

	public List<GarantiaSeguradoOrcamento__c> listarGarantiasSegurados(Set<Id> idsOrcamentoSegurado)
	{
		return
		[
			SELECT
				Capital__c,
				IOF__c,//PLV-4689 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
				ClausulaReducaoFranquiaAcidente__c,
				DescontoAgravoMonetarioComercial__c,
				DescontoAgravoMonetarioInformado__c,
				DescontoAgravoMonetarioTecnico__c,
				DescontoAgravoPercentualComercial__c,
				DescontoAgravoPercentualInformado__c,
				DescontoAgravoPercentualTecnico__c,
				DescontoAgravo__c,
				GarantiaProduto__c,
				Garantia__c,
				Id,
				Name,
				NumeroSerie__c,
				NumeroSorte__c,
				PercentualFilhos__c,
				PercentualIndenizacaoEspecial__c,
				PercentualReferenciado__c,
				Percentual__c,
				PremioComercialDesconto__c,
				PremioIntegral__c, //PLV-5351 INICIO/FIM
				PremioPuroDesconto__c,
				PremioPuroInterno__c,
				PremioPuroResseguro__c,
                PremioPuro__c,
				PremioTotal__c,
				PremioComercial__c,
				ValorCotacao__c,
				Quantidade__c,
				CurrencyIsoCode, //PLV-3884 - INICIO/FIM - Retornando o campo de moeda para referencia
				SeguradoOrcamento__c,
				TaxaAnual__c,
				TaxaComercial__c,
				TaxaMensal__c,
				TaxaPura__c,
				TaxaPuroInterno__c,
				TaxaPuroResseguro__c,
				TaxaTotal__c,
				TipoDescontoAgravo__c,
				//PLV2365: INICIO
				Valor__c,
				Garantia__r.Sigla__c,
				//PLV2365: FIM
                //PLV-4620 FIX 2 INICIO
                Tipo_de_limite_de_utilizacao__c,
                Limite_de_Uso__c
                //PLV-4620 FIX 2 FIM            				
			FROM
				GarantiaSeguradoOrcamento__c
			WHERE
				SeguradoOrcamento__c IN:  idsOrcamentoSegurado
		];

	}
}