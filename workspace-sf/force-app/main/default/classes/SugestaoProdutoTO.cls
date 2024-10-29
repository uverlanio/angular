public class SugestaoProdutoTO {

	public class EntradaTO {
		public DadosBuscaTO dadosBusca {get; set;}

		public EntradaTO(){
			this.dadosBusca = new DadosBuscaTO();
		}
	}

	public class SaidaTO {
		public List<ProdutoTO> produtos {get; set;}
		public List<OrcamentoTO> orcamentos { get; set; }

		public SaidaTO(){
			this.produtos = new List<ProdutoTO>();
		}
	}

	public class DadosBuscaTO{
		public String segmento {get; set;}
		public String produto {get; set;}
		public String cobertura {get; set;}
		public String capitalCobertura {get; set;}
		public String assistencia {get; set;}
		public String vigencia {get; set;}
		public String dataNascimento {get; set;}
		public String fumante {get; set;}
		public String profissao {get; set;}
		public String remuneracao {get; set;}
		public String sexo {get; set;}
		public String renda {get; set;}
		public String nomeProponente {get; set;}
		public String cnpj{get; set;}
		public String faixaIdade {get; set;}
		public String cpf {get; set;}
		public String periodoVigencia {get; set;}
		public String estadoCivil {get; set;}
		public String protecaParaQuem {get; set;}
		public String formaTrabalho {get; set;}
		public String faixaRenda {get; set;}
		public String cep {get; set;}
		public String quantidadeMotoboys {get; set;}
		public String quantidadeMotoristas {get; set;}
		public String cnae {get; set;}
		public String quantidadeFuncionarios {get; set;}
		public String transferenciaCongenere {get; set;}
		public String possuiAfastados {get; set;}
		public String tipoContratante {get; set;}
		public String cooperados {get; set;}
		public String funcionarios {get; set;}
		public String sociosEstagiarios {get; set;}
		public String tipoCalculo {get; set;}
		public String seguradosEntre70e74Anos {get; set;}
		public String prestadoresOuEstagiarios {get; set;}
		public String tipoEvento {get; set;}
		public String cursosPeriodoDeterminado {get; set;}
		public String excursoesPasseiosTuristicos {get; set;}
		public String exposicoesDeiras {get; set;}
		public String formaturasFestas {get; set;}
		public String shows {get; set;}
		public String cinema {get; set;}
		public String pecasTeatroFilmagens {get; set;}
		public String eventosEsportivos {get; set;}
		public String eventosRodeio {get; set;}
		public String eventoLocalFechado {get; set;}
		public String tiposContratante {get; set;}
		public String quantidadesegurados {get; set;}
		public String capital {get; set;}
		public String eventosEsportesRadicais {get; set;}
		public String lutas {get; set;}
		public String artesMarciais {get; set;}
		public String paisesDestino {get; set;}
		public String viagemAventura {get; set;}
		public String periodoViagem {get; set;}
		public String quantidadePassageiros {get; set;}
		public String faixaEtaria {get; set;}
		public String destino {get; set;}
		public String utilizaMoto {get; set;}
	}

	public class ProdutoTO {
		public String nome {get; set;}
		public String codigo {get; set;}
		public Decimal versao {get; set;}
		public List<ValidacaoTO> validacoes {get; set;}
		public List<GarantiaTO> garantias {get; set;}
		public List<PremioMinimoTO> premiosMinimo {get; set;}
		public List<CondicaoCobrancaTO> condicoesCobranca {get; set;}

		public ProdutoTO(){
			this.garantias = new List<GarantiaTO>();
			this.premiosMinimo = new List<PremioMinimoTO>();
			this.condicoesCobranca = new List<CondicaoCobrancaTO>();
			this.validacoes = new List<ValidacaoTO>();
		}
	} 

	public class GarantiaTO {
		public String nome {get; set;}
		public String codigo {get; set;}
		public String tipoCapital {get; set;}
		public Boolean capitalRisco {get; set;}
		public Decimal valorInicial {get; set;}
		public Decimal valorFinal {get; set;}
		public Decimal percentualAgravoMinimo {get; set;}
		public Decimal percentualAgravoMaximo {get; set;}
		public Decimal percentualDescontoMinimo {get; set;}
		public Decimal percentualDescontoMaximo {get; set;}
		public String sigla {get; set;}
		public String moeda {get; set;}


		public GarantiaTO(String nome, String codigo, String tipoCapital, Boolean capitalRisco, Decimal valorInicial, Decimal valorFinal, Decimal percentualAgravoMinimo, Decimal percentualAgravoMaxima, Decimal percentualDescontoMinimo, Decimal percentualDescontoMaximo, String sigla, String moeda){
			this.nome = nome;
			this.codigo = codigo;
			this.tipoCapital = tipoCapital;
			this.capitalRisco = capitalRisco;
			this.valorInicial = valorInicial;
			this.valorFinal = valorFinal;
			this.percentualAgravoMinimo = percentualAgravoMinimo;
			this.percentualAgravoMaximo = percentualAgravoMaximo;
			this.percentualDescontoMinimo = percentualDescontoMinimo;
			this.percentualDescontoMaximo = percentualDescontoMaximo;
			this.sigla = sigla;
			this.moeda = moeda;
		}
	}

	public class PremioMinimoTO {
		public String formaPagamento {get; set;}
		public String tipoContratacao {get; set;}
		public String periodicidadePagamento {get; set;}
		public Decimal premioMinimo {get; set;}

		public PremioMinimoTO(String formaPagamento, String tipoContratacao, String periodicidadePagamento, Decimal premioMinimo){
			this.formaPagamento = formaPagamento;
			this.tipoContratacao = tipoContratacao;
			this.periodicidadePagamento = periodicidadePagamento;
			this.premioMinimo = premioMinimo;
		}
	} 

	public class CondicaoCobrancaTO {
		public String formaPagamento {get; set;}
		public String quantidadeParcelas {get; set;}
		public Decimal percentualMinimo {get; set;}
		public Decimal percentualMaximo {get; set;}

		public CondicaoCobrancaTO(String formaPagamento, String quantidadeParcelas, Decimal percentualMinimo, Decimal percentualMaximo){
			this.formaPagamento = formaPagamento;
			this.quantidadeParcelas = quantidadeParcelas;
			this.percentualMinimo = percentualMinimo;
			this.percentualMaximo = percentualMaximo;
		}
	} 

	public class ValidacaoTO{
		public String tipo {get; set;}
		public String descricao {get; set;}
	}
}