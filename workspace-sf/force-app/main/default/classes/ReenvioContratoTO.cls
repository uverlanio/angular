//LECVP-72 - INICIO
public class ReenvioContratoTO {

    public class PayloadTO 
	{
		public ReenvioContratoTO contrato { get; set; }
	}
		public String numero { get; set; }
		public String tipoSeguro { get; set; }
		public Integer origem { get; set; }
		public String vigenciaInicial { get; set; }
		public String vigenciaFinal { get; set; }
		public String vigenciaInicialContratoOriginal { get; set; }	
		public String vigenciaFinalContratoOriginal { get; set; }
		public String ramoSeguro { get; set; }
		public Integer numeroEndosso { get; set; }
		public Integer numeroApolice { get; set; }
		public String dataInclusao { get; set; }
		public String dataAlteracao { get; set; }
		public String codigoSucursal { get; set; }
		public String codigoEmpresa { get; set; }
		public String codigoOrigemDoMovimentoBCP { get; set; }
		public List<RemuneracoesTO> remuneracoes { get; set; }
		public List<ContratantesTO> contratantes { get; set; }
		public List<AlteracoesEndossoTO> alteracoesEndosso  {get; set; }

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

    public class RemuneracoesTO 
	{
		public List<FavorecidosTO> favorecidos { get; set; }
		public String tipoRemuneracao { get; set; }
		public Decimal percentual { get; set; }
	}

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

    public class CoberturasTO 
	{
		public Decimal iof { get; set; }
		public Decimal capital { get; set; }
		public PremioTO premio { get; set; }
		public TaxaTO taxa { get; set; }
		public String sigla { get; set; }
		public List<FranquiasTO> franquias { get; set; }
		public List<CarenciasTO> carencias { get; set; }
		public String clausulaReducaoFranquiaAcidente { get; set; }
		public Decimal valor { get; set; }
		public String descricaoGarantia { get; set; }
		public String numeroSorte { get; set; }
		public String numeroSerie { get; set; }

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
		public String susep { get; set;}
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

    public class ResponsavelPagamentoTO 
	{
		public String nome { get; set; }
		public String tipo { get; set; }
		public DadospessoajuridicaTO dadosPessoaJuridica { get; set; }
		public DadospessoafisicaTO dadosPessoaFisica { get; set; }
		public List<EnderecosTO> enderecos { get; set; }
		public List<TelefonesTO> telefones { get; set; }		
	}

    public class ParcelasTO 
	{
		public String meioPagamento { get; set; }
		public Integer numeroParcela { get; set; }
		public Decimal valorIOF { get; set; }
		public Decimal valorParcela { get; set; }
		public String dataVencimentoParcela { get; set; }
	}

    public class FormaPagamentoTO{
		public Integer codigo { get; set; }		
	}

    public class FranquiasTO 
	{
		public String descricao { get; set; }
	}

    public class CarenciasTO 
	{
		public String descricao { get; set; }
	}

    public class PessoaTO 
	{
		public String nome { get; set; }
		public String tipo { get; set; }	
		public String email { get; set; }
		public List<TelefonesTO> telefones { get; set; }
		public List<EnderecosTO> enderecos { get; set; }
		public DadospessoafisicaTO dadosPessoaFisica { get; set; }
		public DadospessoajuridicaTO dadosPessoaJuridica { get; set; }
		public Integer faixaRenda { get; set; }
		public Integer pessoaExpostaPoliticamente { get; set; }
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
		public Decimal integral { get; set; } 
		public Decimal puro { get; set; }
		public Decimal total { get; set; }
	}

    public class BeneficiariosTO 
	{
		public String tipoBeneficiario { get; set; }
		public String nome { get; set; } 
		public String cpfCnpj { get; set; } 
		public Double participacao { get; set; } 
		public String grauParentesco { get; set; } 
		public String pep { get; set; } 
	}

    public class DadosPessoaJuridicaTO 
	{
		public String digitoCnpj { get; set; }
		public String numeroCnpj { get; set; }
		public String ordemCnpj { get; set; }
	}

    public class DadosPessoaFisicaTO 
	{
		public String sexo { get; set; }
		public String nacionalidade { get; set; }
		public String estadoCivil { get; set; }
		public String digitoCpf { get; set; }
		public String dataNascimento { get; set; }
		public String numeroCpf { get; set; }
		public String email { get; set; }
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
		public String complemento { get; set; }
	}

    public class TelefonesTO 
	{
		public String tipoTelefone { get; set; }
		public String numeroTelefone { get; set; }
		public String dddTelefone { get; set; }
	}

	public class AlteracoesEndossoTO {
		public String sigla {get;set;}
		public Integer codigoBCP {get;set;}
		public Integer ordem {get;set;}
	}
}
//LECVP-72 - FIM