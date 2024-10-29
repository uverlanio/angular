/**
 * Contrato TO
 * @author Eric Tunú @ 03/10/2018
 *
 **/
public class ContratoTO
{
	public class PayloadTO 
	{
		public ContratoTO contrato { get; set; }
	}

	public String segmento { get; set; }
	public String meioComercializacao { get; set; }
	public String idcontratanteParceiro { get; set; }
	public String codigoEmpresa { get; set; }  
	public String ramoSeguro { get; set; }
	public String CodigoOrigemDoMovimentoBCP { get; set; }  // PLV-3855
	public String vigenciaInicial { get; set; }
	public String tipoVigencia { get; set; }
    public String tipoEndosso { get; set; }
	public Integer origem { get; set; }
	public String tipoSeguro { get; set; }
	public Integer numeroEndosso { get; set; }
	public String canalDistribuicao { get; set; }
	public String nomeEmpresa { get; set; }
	public String numero { get; set; }
	public String codigoSucursal { get; set; }
	public String nomeRamoSeguro { get; set; }
	public String vigenciaFinal { get; set; }
	public Decimal valorPremio { get; set; }
	public String idContratoParceiro { get; set; }
	public String dataCalculo { get; set; }
	public Integer numeroApolice { get; set; }
	public String nomeProduto { get; set; }
	public String codigoProdutoVida { get; set; }
	public String parceiro { get; set; }
	public String numeroSusepProduto { get; set; }
	public String nomeCanalDistribuicao { get; set; }
	public String vigenciaInicialContratoOriginal { get; set; }	//POR062-99 - INICIO
	public String vigenciaFinalContratoOriginal { get; set; }	//POR062-99 - FIM
	public String CupomDesconto { get; set; }
	public GeracaoapoliceTO geracaoApolice { get; set; }

	public List<ContratantesTO> contratantes { get; set; }

	public List<RemuneracoesTO> remuneracoes { get; set; }
	public PrecificacaoTO precificacao { get; set; }
	// PLV-4488
	public List<AlteracoesEndosso> alteracoesEndosso {get;set;}
	
	//PLV-5033 - INICIO
	public String dataInclusao { get; set; }
	public String dataAlteracao { get; set; }
	//PLV-5033 - FIM

	public class PrecificacaoTO 
	{
		public Integer custoApolice { get; set; }
		public Decimal iof { get; set; }
		public Integer juros { get; set; }
		public PremioTO premio { get; set; }
		public List<CoberturasTO> coberturas { get; set; }
		public TaxaTO taxa { get; set; }
		public Integer encargos { get; set; }
		public List<ContratantesTO> contratantes { get; set; }
	}

	public class TaxaTO 
	{
		public Decimal pura { get; set; }
		public Decimal comercial { get; set; }
		public Decimal total { get; set; }
	}

	public class PremioTO 
	{
		public Decimal comercial { get; set; }
		public Decimal integral { get; set; } //PLV-5351 INICIO/FIM
		public Decimal puro { get; set; }
		public Decimal total { get; set; }
	}

	public class ContratantesTO 
	{
		public List<GruposTO> grupos { get; set; }
		public PessoaTO pessoa { get; set; }
		public DadospagamentoTO dadosPagamento { get; set; }
		public String tipo { get; set; }
		public Decimal iof { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public List<CoberturasTO> coberturas { get; set; }
		public Integer numero { get; set; }
		
		
	}

	public class DadospagamentoTO 
	{
		public ResponsavelpagamentoTO responsavelPagamento { get; set; }	
		public List<ParcelasTO> parcelas { get; set; }
		public String tipoResponsavelPagamento { get; set; }
		public Integer quantidadeParcelas { get; set; }
		//PLV-3393 - INICIO - Integração BCP
		public FormaPagamentoTO formaPagamento { get; set; }
		//PLV-3393 - FIM - Integração BCP
	}

	//PLV-3393 - INICIO - Integração BCP
	public class FormaPagamentoTO{
		public Integer codigo { get; set; }		
	}
	//PLV-3393 - FIM - Integração BCP

	public class GruposTO 
	{
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public Decimal iof { get; set; }
		public Integer numero { get; set; }
		public List<CoberturasTO> coberturas { get; set; }
		public String nome { get; set; }
		public Integer qtdeVidas { get; set; }
		public List<SeguradosTO> segurados { get; set; }
	}

	public class SeguradosTO 
	{		
		public PessoaTO pessoa { get; set; }
		public List<BeneficiariosTO> beneficiarios { get; set; }
		public Decimal iof { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public Integer numero { get; set; }
		public List<CoberturasTO> coberturas { get; set; }
		public DadospagamentoTO dadosPagamento { get; set; }
	}

	public class RemuneracoesTO 
	{
		public List<FavorecidosTO> favorecidos { get; set; }
		public String tipoRemuneracao { get; set; }
		public Decimal percentual { get; set; }
	}

	public class FavorecidosTO 
	{
		public String papel { get; set; }
		public Decimal participacao { get; set; }
		public PessoaTO pessoa { get; set; }
		public Boolean corretorLider { get; set; }
		public String susepOficialCorretor { get; set; }
		public String susepEmissao { get; set; }
		public String susepOrcamento { get; set; }
		//PLV-3572 - INICIO
		public String susep { get; set;}
		//PLV-3572 - FIM
	}

	public class AgentesTO 
	{
		public String susepEmissao { get; set; }
		public Decimal corretagem { get; set; }
		public String susep { get; set; }
		public String tipoPessoaCorsus { get; set; }
		public String nomeSucursal { get; set; }
		public String papel { get; set; }
		public PessoaTO pessoa { get; set; }
	}

	public class DadospessoafisicaTO 
	{
		public String sexo { get; set; }
		public String nacionalidade { get; set; }
		public String estadoCivil { get; set; }
		public String digitoCpf { get; set; }
		public String dataNascimento { get; set; }
		public String numeroCpf { get; set; }
		public String email { get; set; } //PLV-3572 - INICIO/FIM
	}

	public class PessoaTO 
	{
		public String nome { get; set; }
		public String nomeSocial { get; set; } //LECVPV 192 - INICIO/FIM
		public String tipo { get; set; }	
		public String email { get; set; }
		public List<TelefonesTO> telefones { get; set; }
		public List<EnderecosTO> enderecos { get; set; }
		public DadospessoafisicaTO dadosPessoaFisica { get; set; }
		public DadospessoajuridicaTO dadosPessoaJuridica { get; set; }
		//PLV-5033 - INICIO
		public Integer faixaRenda { get; set; }
		public Integer pessoaExpostaPoliticamente { get; set; }
		//PLV-5033 - FIM
	}

	public class CoberturasTO 
	{
		public Decimal iof { get; set; }
		public Decimal capital { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public String sigla { get; set; }
		public List<FranquiasTO> franquias { get; set; }
		public List<CarenciasTO> carencias { get; set; }
		//public Integer ramo { get; set; }
		public String clausulaReducaoFranquiaAcidente { get; set; }
		public Decimal valor { get; set; }
		public String descricaoGarantia { get; set; }
		public String numeroSorte { get; set; }
		public String numeroSerie { get; set; }

	}

	public class CarenciasTO 
	{
		public String descricao { get; set; }
	}


	public class TelefonesTO 
	{
		public String tipoTelefone { get; set; }
		public String numeroTelefone { get; set; }
		public String dddTelefone { get; set; }

		// PLV-2335 - Inicio - RollBack
		// PLV-2335 - Fim
	}

	public class DadospessoajuridicaTO 
	{
		public String digitoCnpj { get; set; }
		public String numeroCnpj { get; set; }
		public String ordemCnpj { get; set; }
	}

	public class BeneficiariosTO 
	{
		public String tipoBeneficiario { get; set; }
		public String nome { get; set; } 
		public String cpfCnpj { get; set; } 
		public Double participacao { get; set; } 
		public String grauParentesco { get; set; } 
		public String Pep { get; set; } 
	}

	public class ResponsavelpagamentoTO 
	{
		public String nome { get; set; }
		public String tipo { get; set; }
		public DadospessoajuridicaTO dadosPessoaJuridica { get; set; }
		public DadospessoafisicaTO dadosPessoaFisica { get; set; }
		public List<EnderecosTO> enderecos { get; set; }
		public List<TelefonesTO> telefones { get; set; }
		
	}

	public class EnderecosTO 
	{
		public String tipoLogradouro { get; set; }
		public String cidade { get; set; }
		public String tipoEndereco { get; set; }
		public String logradouro { get; set; }
		public String bairro { get; set; }
		public String cep { get; set; }
		public String uf { get; set; }
		public String numeroLogradouro { get; set; }
		public String paisResidencia { get; set; }
		public String complementoCep { get; set; }
		//PLV-5033 - INICIO
		public String complemento { get; set; }
		//PLV-5033 - FIM
	}

	public class ParcelasTO 
	{
		public String meioPagamento { get; set; }
		public Integer numeroParcela { get; set; }
		public Decimal valorIOF { get; set; }
		public Decimal valorParcela { get; set; }
		public String dataVencimentoParcela { get; set; }
	}

	public class GeracaoapoliceTO 
	{
		public String unidadeNegocio { get; set; }
		public String nomeArquivoJasper { get; set; }
		public String leituraApartir { get; set; }
		public String centroDeCustoPagador { get; set; }
		public String tipoExtensaoGerada { get; set; }
		public String idAplicacaoUtilizadora { get; set; }
		public String nomeRelatorioGerado { get; set; }
		public String fileSystem { get; set; }
		public ArquivoTO arquivo { get; set; }
		public String nomeDiretorioArquivo { get; set; }
		public String assinaturaDiretor { get; set; }
	}

	public class ArquivoTO 
	{
		public String textoInformativo { get; set; }
		public String mensagemAssistenciaFuneral { get; set; }
		public String exibirMensagemRenovacao { get; set; }
		public ObservacoesTO observacoes { get; set; }
		public CabecalhoTO cabecalho { get; set; }
		public String mensagemProcessoSusep { get; set; }
		public String numeroProcessoSusepCNSP315 { get; set; }
		public String unidadeOperacional { get; set; }
	}

	public class SolicitarTituloTO {
		public String parceiro { get; set; }
		public String produto { get; set; }
		public Integer origemproposta { get; set; }
		public Integer quantidade { get; set; }
	}

	public class consultarEstoqueTO {
		public String codigoParceiro { get; set; }
		public String codigoProduto { get; set; }
		public String dataInicial { get; set; }
		public String dataFinal { get; set; }
	}

	public class CabecalhoTO 
	{
		public String image { get; set; }
	}

	public class ObservacoesTO 
	{
		public String condicoesGerais { get; set; }
	}

	public class FranquiasTO 
	{
		public String descricao { get; set; }
	}

	public class ConsultarArquivoECMTO { 
		public String idsf { get; set; } 
		public String dataInicial { get; set; } 
		public String dataFinal { get; set; } 
	}
	
	// INICIO | PLV-4614-VI-Guilherme Brito / Vinícius Caetano
	public class AlteracoesEndosso {
		public String sigla {get;set;}
		public Integer codigoBCP {get;set;}
		public Integer ordem {get;set;}
	}
	// FIM | PLV-4614-VI-Guilherme Brito / Vinícius Caetano
}