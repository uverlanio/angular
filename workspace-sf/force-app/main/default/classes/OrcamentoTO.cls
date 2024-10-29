/**
 * Orçamento TO
 * @author Fernando Barcellos @ 19/04/2018, 01/06/2018
 *
 **/
public class OrcamentoTO {

	// OrcamentoTO.PayloadTO objPayload = (OrcamentoTO.PayloadTO) JSON.deserialize(payload, OrcamentoTO.PayloadTO.class);
	public class PayloadTO {
		public List<OrcamentoTO> orcamentos { get; set; }
	}

	// Principais atributos do Orçamento
	public SolicitacaoOfertaTO solicitacaoOferta { get; set; }
	//public List<GuiaPostalTO> guiaPostal { get; set; }
	//public List<LicitacaoTO> licitacoes { get; set; }
	//public List<SerasaTO> serasa { get; set; }
	public List<IndiceMonetarioTO> IndiceMonetario { get; set; }//PLV-4666 - INICIO/FIM - PEDRO BRAZ
	//public RetornoValidacaoProdutoTO retornoValidacaoProduto { get; set; }
	public RetornoAceitacaoTO retornoAceitacao { get; set; }
	public OfertaTO oferta { get; set; }
	public List<OfertaTO> ofertas { get; set; }
	public String mensagem { get; set; }
	public Integer erro { get; set; }

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].solicitacaoOferta
	public class SolicitacaoOfertaTO {
		public Opportunity objSf { get; set; }
		public List<GarantiaOrcamento__c> garantiasOrcamentoSf { get; set; }
		public String segmento { get; set; }
		public String meioComercializacao { get; set; }
		public String numeroOrcamento { get; set; }
		public String numeroPortal { get; set; }
		public Date dataCalculo { get; set; }
		public Date dataCriacaoPortal { get; set; }
		public String codigoCanal { get; set; }
		public Integer codigoProdutoPortal { get; set; }
		public String codigoProdutoVida { get; set; }
		public String tipoVigencia { get; set; }
		public Date vigenciaInicial { get; set; }
		public Date vigenciaFinal { get; set; }
		public Integer qtdDiasVigencia { get; set; }
		public String tipoSeguro { get; set; }
		public String tipoAdesao { get; set; }
		public Decimal descontoComercial { get; set; }
		public Decimal agravoComercial { get; set; }
		public String observacoesGerais { get; set; }
		public String parceiro { get; set; }
		public String empresa { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		public String apolice { get; set; }
		public String tipoEndosso { get; set; }
		public EventoTO evento { get; set; }
		public ViagemTO viagem { get; set; }
		public TransferenciaCongenereTO transferenciaCongenere { get; set; }
		public List<ContratanteTO> contratantes { get; set; }
		public RemuneracaoTO remuneracao { get; set; }
		public List<SugestaoProdutoTO.ProdutoTO> produtos {get; set;}
		public PrecificacaoTO precificacao { get; set; }
	
	}

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].guiaPostal[]
	/*public class GuiaPostalTO {
		public String cep { get; set; }
		public String cidade { get; set; }
		public String uf { get; set; }
	}*/

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].licitacao[]
	/*public class LicitacaoTO {
		public String orgaoPublico { get; set; }
		public String cnpj { get; set; }
	}*/

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].serasa[]
	/*public class SerasaTO {
		public String cnpj { get; set; }
		public String cnae { get; set; }
		public String cep { get; set; }
	}*/

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].indiceMonetario[]
	public class IndiceMonetarioTO {
		public String moeda { get; set; }
		public decimal valor { get; set; }
	}

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].retornoValidacaoProduto
	/*public class RetornoValidacaoProdutoTO {
		public Integer codigoProduto { get; set; }
		public Integer versaoProduto { get; set; }
		public Decimal descontoComercial { get; set; }
		public Decimal descontoTecnico { get; set; }
		public Decimal agravoComercial { get; set; }
		public Decimal agravoTecnico { get; set; }
		public List<PremioMinimoTO> premiosMinimos { get; set; }
		public List<String> moedasExtrangeiras { get; set; }
	}*/

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].retornoAceitacao
	public class RetornoAceitacaoTO {
		public List<StatusTO> avisos { get; set; }
		public List<StatusTO> analises { get; set; }
		public List<StatusTO> recusas { get; set; }
		public List<StatusTO> pendencias { get; set; }
	}

	// ENTIDADE "PRINCIPAL"
	// orcamentos[i].oferta
	public class OfertaTO {
		public String permiteTransmissao { get; set; }
		public List<ParcelamentoTO> parcelamentos { get; set; }
		public String origem { get; set; }
		public String numeroPortal { get; set; }
		public Integer numero { get; set; }
		public CalculoTO calculo { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class EventoTO {
		public String tipoEvento { get; set; }
		public String qstControlePublico { get; set; }
		public String qstLocalEvento { get; set; }
		public String informacoesEvento { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class ViagemTO {
		public String tipoViagem { get; set; }
		public String praticaEsportesAventura { get; set; }
		public String utilizaraMotocicleta { get; set; }
		public String incluiPaisSchengen { get; set; }
		public String trackageBagagem { get; set; }

		public Integer passageirosNaoIdosos { get; set; }
		public Integer passageirosIdosos { get; set; }

		public List<DestinoTO> destinos { get; set; }

		//public String nomePrincipal { get; set; } //PLV-4928 - FIX - INICIO/FIM
	}

	// ENTIDADE "INTERNA"
	public class DestinoTO {

		public String pais { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class TransferenciaCongenereTO {
		public String congenere { get; set; }
		public Integer tempoPermanencia { get; set; }
		public Decimal sinistralidade { get; set; }
		public Decimal taxaVigencia { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class ContratanteTO {
		public ContratanteOrcamento__c objSf { get; set; }
		public Account contaSf { get; set; }
		public String idSf { get; set; }
		public Integer numero { get; set; }
		public String tipo { get; set; }
		public PessoaTO pessoa { get; set; }
		public DadosPagamentoTO dadosPagamento { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public List<CoberturaTO> coberturas { get; set; }
		public List<GrupoTO> grupos { get; set; }
		// RVI-160 - INICIO
		public String tipoSeguro { get; set; }
		public Date vigenciaInicial { get; set; }
		public Date vigenciaFinal { get; set; }
		// RVI-160 - FINAL
	}

	// ENTIDADE "INTERNA"
	public class PessoaTO {
		public String tipo { get; set; }
		public String nome { get; set; }
		public String email { get; set; }
		public DadosPessoaJuridicaTO dadosPessoaJuridica { get; set; }
		public DadosPessoaFisicaTO dadosPessoaFisica { get; set; }
		public List<EnderecoTO> enderecos { get; set; }
		public List<TelefoneTO> telefones { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class DadosPagamentoTO {
		public Decimal quantidadeParcelas { get; set; }
		public Date vencimentoPrimeiraParcela { get; set; }
		public String tipoResponsavelPagamento { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class TelefoneTO {
		public String tipoTelefone { get; set; }
		public String dddTelefone { get; set; }
		public String numeroTelefone { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class EnderecoTO {
		public String tipoLogradouro { get; set; }
		public String tipoEndereco { get; set; }
		public String logradouro { get; set; }
		public String numeroLogradouro { get; set; }
		public String complemento { get; set; }
		public String bairro { get; set; }
		public String cidade { get; set; }
		public String uf { get; set; }
		public String paisResidencia { get; set; }
		public String cep { get; set; }
		public String complementoCep { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class DadosPessoaJuridicaTO {
		// ver com murray
		public String numeroCnpj { get; set; }
		public String ordemCnpj { get; set; }
		public String digitoCnpj { get; set; }

		// já tinha no payload este campo
		public String cnpj { get; set; }
		public Integer codigoCNAE { get; set; }
		public String descricaoCNAE { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class DadosPessoaFisicaTO {
		public Date dataNascimento { get; set; }
		public String sexo { get; set; }
		public String numeroCpf { get; set; }
		public String digitoCpf { get; set; }
		public String nacionalidade { get; set; }
		public String paisDeOrigem { get; set; } //PLV-5231 INICIO/FIM
		public String estadoCivil { get; set; }
		public String profissao { get; set; }
		public Boolean pep { get; set; }
		public String tipoRelacionamentoPep { get; set; }
		public PessoaRelacionamentoPepTO pessoaRelacionamentoPep { get; set; }
		public List<DocumentoTO> documentos { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class DocumentoTO {
		public String tipoDocumentoIdentidade { get; set; }
		public String orgaoExpedidorDocumento { get; set; }
		public String numeroDocumentoIdentidade { get; set; }
		public Date dataExpedicaoDocumento { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class PessoaRelacionamentoPepTO {
		public String tipo { get; set; }
		public String nome { get; set; }
		public DadosPessoaFisicaTO dadosPessoaFisica { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class GrupoTO {
		public GrupoOrcamento__c objSf { get; set; }
		public String idSf { get; set; }
		public String nome { get; set; }
		public Integer numero { get; set; }
		public String tipoContratante { get; set; }
		public Integer qtdeSegurados { get; set; }
		public String idArquivoSegurados { get; set; }
		public String tipoCalculo { get; set; }
		public Integer prazoMaximoFinanciamentoPrestamista { get; set; }
		public Decimal saldoDevedor { get; set; }
		public Decimal valorDoBem { get; set; }
		public PremioTO premio { get; set; }
		public Decimal agravo { get; set; }
		public Decimal desconto { get; set; }
		public String escolhaDescontoAgravo {get;set;}
		public Decimal valorDescontoAgravo {get;set;}
		public TaxaTO taxa { get; set; }
		public List<SeguradoTO> segurados { get; set; }
		public List<CoberturaTO> coberturas { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class SeguradoTO {		
		public SeguradoOrcamento__c objSf { get; set; }		
		public Integer numero { get; set; }
		public String nome { get; set; }
		public Date dataNascimento { get; set; }
		public String numeroCpf { get; set; }
		public String digitoCpf { get; set; }
		public String afastado { get; set; }
		public String cid { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public PessoaTO pessoa { get; set; }
		public List<CoberturaTO> coberturas { get; set; }
		//PLV-4071 - INICIO - PEDRO AUGUSTO - SYS4B
        public String profissao { get; set; }
        //PLV-4071 - FIM - PEDRO AUGUSTO - SYS4B
	}

	// ENTIDADE "INTERNA"
	public class CoberturaTO {
		public String idGarantiaProdutoSf { get; set; }
		public sObject objSf { get; set; } // TEST
		public GarantiaProduto__c garantiaProdutoSf { get; set; }
		public Garantia__c garantiaSf { get; set; }
		public GarantiaOrcamento__c garantiaOrcamentoSf { get; set; }
		public String idSf { get; set; }
		public String sigla { get; set; }
		public Decimal capital { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public Decimal valor { get; set; }
		public Decimal agravo { get; set; }
		public Decimal desconto { get; set; }
		public String moeda { get; set; }
		public String escolhaDescontoAgravo {get;set;}
		public Decimal valorDescontoAgravo {get;set;}
		public String garantiaReferenciada { get; set; }
		public Decimal percentual { get; set; }
		public String inclusaoIndenizacaoEspecial { get; set; }
		public Decimal percentualIndenizacaoEspecial { get; set; }
		public String inclusaoFilhos { get; set; }
		public Decimal percentualFilhos { get; set; }
		public Integer quantidade { get; set; }
		public String clausulaReducaoFranquiaAcidente { get; set; }
		public Decimal importancia { get; set; }
		public String numeroSerie { get; set; }
		public String numeroSorte { get; set; }

		public String franquia { get; set; } //PLV-4598 INICIO-FIM
	}

	// ENTIDADE "INTERNA"
	public class RemuneracaoTO {
		public String canal { get; set; }

		public String susep { get; set; }
		public String susepEmissao { get; set; }
		public String susepOrcamento { get; set; }
		public String tipoPessoaCorsus { get; set; }

		public String codigoOperacao { get; set; }
		public Decimal codigoOperacaoPercentual { get; set; }
		public String codigoOperacaoImprimir { get; set; }

		public Decimal proLabore { get; set; }
		public Decimal agenciamento { get; set; }
		public Decimal assessoria { get; set; }
		public List<AgenteTO> agentes { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class AgenteTO {
		public TipoRemuneracao__c objSf { get; set; }
		public String papel { get; set; }
		public Decimal corretagem { get; set; }
		public String susep { get; set; }
		public String tipoPessoaCorsus { get; set; }
		public String susepEmissao { get; set; }
		public String susepOrcamento { get; set; }
		public Decimal agenciamento { get; set; }
		public Decimal proLabore { get; set; }
		public Decimal assessoria { get; set; }
		public Decimal comissao { get; set; }
		public PessoaTO pessoa { get; set; }
	}

	// ENTIDADE "INTERNA"
	// orcamentos[i].retornoValidacaoProduto.premiosMinimo[]
	public class PremioMinimoTO {
		public Integer quantidadeParcelas { get; set; }
		public String formaPagamento { get; set; }
		public Decimal premioMinimo { get; set; }
	}

	// ENTIDADE "INTERNA"
	// genérico a confirmar com murray a necessidade de mais campos
	public class StatusTO {
		public Integer codigo { get; set; } // converter para string
		public String origem { get; set; }
		public String area { get; set; }
		public String descricao { get; set; }
		public String procedimento { get; set; }
		public Integer severidade { get; set; }
		public Integer quantidade { get; set; }
		public String status { get; set; }
		public MensagemTO mensagens { get; set; }
	}

	public class MensagemTO {
		public String cliente { get; set; }
		public String interna { get; set; }
		public String representante { get; set; }
	}

	// ENTIDADE "INTERNA"
	// orcamentos[i].oferta.parcelamentos[]
	public class ParcelamentoTO {
		public Decimal valorDemaisParcelas { get; set; }
		public Decimal valor1aParcela { get; set; }
		public Integer qtdParcelas { get; set; }
		public Decimal juros { get; set; }
		public Decimal iof { get; set; }
		public Decimal encargos { get; set; }
		public String descricao { get; set; }
		public Decimal custoapolice { get; set; }
		public Integer codigo { get; set; }
	}

	// ENTIDADE "INTERNA"
	// orcamentos[i].oferta.calculo
	public class CalculoTO {
		public PrecificacaoTO precificacao { get; set; }
		public AnaliseAtuarialTO analiseAtuarial { get; set; }
	}

	// ENTIDADE "INTERNA"
	// orcamentos[i].oferta.calculo.precificacao
	public class PrecificacaoTO {
		public Decimal juros { get; set; }
		public Decimal iof { get; set; }
		public Decimal encargos { get; set; }
		public Decimal custoApolice { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public List<CoberturaTO> coberturas { get; set; }
		public List<ContratanteTO> contratantes { get; set; }
	}

	// ENTIDADE "INTERNA"
	// orcamentos[i].oferta.calculo.analiseAtuarial
	public virtual class AnaliseAtuarialTO {
		public AnaliseEstatisticaTO estatistica { get; set; }
		public AnaliseAnaliticaTO analitica { get; set; }
		public List<AnaliseContratanteTO> contratantes { get; set; }
	}

	// ENTIDADE "INTERNA"
	// orcamentos[i].oferta.calculo.analiseAtuarial.contratantes[]
	public class AnaliseContratanteTO extends AnaliseAtuarialTO {
		public Integer numero { get; set; }
		public AnaliseEstatisticaTO estatistica { get; set; }
		public AnaliseAnaliticaTO analitica { get; set; }
		public List<AnaliseContratanteTO> grupos { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class PremioTO {
		public Decimal informado { get; set; }
		public Decimal puro { get; set; }
		public Decimal puroDesconto { get; set; }
		public Decimal puroInterno { get; set; }
		public Decimal puroResseguro { get; set; }
		public Decimal comercial { get; set; }
		public Decimal comercialDesconto { get; set; }
		public Decimal total { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class TaxaTO {
		public Decimal pura { get; set; }
		public Decimal mensal { get; set; }
		public Decimal anual { get; set; }
		public Decimal puroInterno { get; set; }
		public Decimal puroResseguro { get; set; }
		public Decimal comercial { get; set; }
		public Decimal total { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class AnaliseAnaliticaTO {
		public Integer quantidadeSegurados { get; set; }
		public Decimal publicoMasculino { get; set; }
		public Decimal publicoFeminino { get; set; }
		public Decimal capitalMedio { get; set; }
		public Decimal idadeMediaAtuarial { get; set; }
		public Decimal idadeMediaPonderada { get; set; }
		public Decimal idadeMediaPonderadaPorIS { get; set; }
		public Decimal idadeMediaAritmetica { get; set; }
		public Decimal taxaModelagem { get; set; }
		public Decimal percentualDescontoModelagem { get; set; }
		public Decimal expectativaSinistrosAnual { get; set; }
		public Decimal capitalPonderadoPorExpectativaSinistro { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class AnaliseEstatisticaTO {
		public List<FaixaEtariaTO> faixaEtaria { get; set; }
		public List<FaixaCapitalTO> faixaCapital { get; set; }
		public List<StatusTO> status { get; set; }
	}

	// ENTIDADE "INTERNA"
	public virtual class FaixaValoresBaseTO {
		public String tipo { get; set; }
		public Integer quantidade { get; set; }
		public Decimal percentual { get; set; }
		public Decimal capital { get; set; }
		public Decimal mediaCapital { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class FaixaEtariaTO extends FaixaValoresBaseTO {
		public Integer inicioFaixa { get; set; }
		public Integer finalFaixa { get; set; }
	}

	// ENTIDADE "INTERNA"
	public class FaixaCapitalTO extends FaixaValoresBaseTO {
		public Decimal inicioFaixa { get; set; }
		public Decimal finalFaixa { get; set; }
	}

	
	//PLV-3285 - MetadataTO - INICIO
	public class MdtGrupoTO {
		public String GRUPO_IDOSOS_NOME ;
		public String GRUPO_JOVENS_NOME ;
		public String GRUPO_JOVENS_IDADE_MIN ;
		public String GRUPO_JOVENS_IDADE_MAX ;
		public String GRUPO_IDOSOS_IDADE_MIN ;
		public String GRUPO_IDOSOS_IDADE_MAX ;
	
		public MdtGrupoTO(){
			
			List<Constante__mdt> mdtList = new List<Constante__mdt>();
			mdtList.addAll([SELECT DeveloperName, Valor__c FROM Constante__mdt	WHERE Label LIKE '%GRUPO%' ]);

			Map<String,String> mdtMap = new Map<String,String>();
			for(Constante__mdt mdt : mdtList)	mdtMap.put(mdt.DeveloperName, mdt.Valor__c);

			GRUPO_JOVENS_NOME = mdtMap.get('GRUPO_JOVENS_NOME') ;
			GRUPO_IDOSOS_NOME = mdtMap.get('GRUPO_IDOSOS_NOME') ;
			GRUPO_JOVENS_IDADE_MIN = mdtMap.get('GRUPO_JOVENS_IDADE_MIN') ;
			GRUPO_JOVENS_IDADE_MAX = mdtMap.get('GRUPO_JOVENS_IDADE_MAX') ;
			GRUPO_IDOSOS_IDADE_MIN = mdtMap.get('GRUPO_IDOSOS_IDADE_MIN') ;
			GRUPO_IDOSOS_IDADE_MAX = mdtMap.get('GRUPO_IDOSOS_IDADE_MAX') ;
		}
	}
	//PLV-3285 - MetadataTO - FIM
}