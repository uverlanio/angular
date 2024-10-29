public class geraJsonSAP {
	public class Requisitante {
		public String tipoUsuario{get; set;}
		public String codigoEmpresaMatricula{get; set;}
		public String matriculaResponsavel{get; set;}
	}

	public Ordempagamento ordempagamento{get; set;}

	public class Fornecedor {
		public String origemDados{get; set;}
		public String nome{get; set;}
		public String complementoNome{get; set;}
		public String termoPequisa{get; set;}
		public String tipoPessoa{get; set;}
		public String cpfCnpj{get; set;}
		public String ordemCnpj{get; set;}
		public String digitoCpfCnpj{get; set;}
		public String email{get; set;}
		public String tipoParceiroNegocio{get; set;}
		public Endereco endereco{get; set;}
		public String tipoCategoriaCtaContrato{get; set;}
		public String grupoPrevisaoTesouraria{get; set;}
		public String visaoCtaExterna{get; set;}
		public Requisitante requisitante{get; set;}
	}

	public class Itens {
		public String numeroParcela{get; set;}
		public String valorParcela{get; set;}
		public String dataVencimento{get; set;}
		public String formaPagamento{get; set;}
		public String codigoSucursal{get; set;}
		public String codigoMunicipio{get; set;}
		public String codigoRamoModalidade{get; set;}
		public String centroCusto{get; set;}
		public String codigoDespesa{get; set;}
		public String criterioOperacaoSub{get; set;}
		public String grupoPrevTesouraria{get; set;}
		public String bloqueioDocumento{get; set;}
		public String descricaoOrdemPagamento{get; set;}
	}

	public class Ordempagamento {
		public String codigoOrigem{get; set;}
		public String empresa{get; set;}
		public String moeda{get; set;}
		public String numeroDocumento{get; set;}
		public String numeroSinistroAno{get; set;}
		public String localRiscoUF{get; set;}
		public String tipoUsuAprov{get; set;}
		public String codigoEmpMatAprov{get; set;}
		public String matriculaRespAprov{get; set;}
		public String tipoUsuarioRequisitante{get; set;}
		public String codigoEmpMatRequisitante{get; set;}
		public String matriculaRespRequisitante{get; set;}
		public String dataAprovLegado{get; set;}
		public String dataContabil{get; set;}
		public String indTributavel{get; set;}
		public String categoriaContaContrato{get; set;}
		public String grupoPrevTesouraria{get; set;}
		public String visaoContaExterna{get; set;}
		public String categoriaObjetoSeguro{get; set;}
		public String numeroApolice{get; set;}
		public String numeroProposta{get; set;}
		public String numeroEndosso{get; set;}
		public String dataVigenciaInicio{get; set;}
		public String dataVigenciaFinal{get; set;}
		public String susepCorretor{get; set;}
		public String dataCobertura{get; set;}
		public String dataEmissao{get; set;}
		public Fornecedor fornecedor{get; set;}
		public Fatura fatura{get; set;}
		public List<Itens> itens{get; set;}
	}

	public class DadosBancarios {
		public String paisBanco{get; set;}
		public String banco{get; set;}
		public String agencia{get; set;}
		public String digitoAgencia{get; set;}
		public String contaCorrente{get; set;}
		public String digitoContaCorrente{get; set;}
	}

	public class Fatura {
		public String codigoSucursal{get; set;}
		public String dataFatura{get; set;}
		public String montanteBruto{get; set;}
		public String dataBaseCalculoVenc{get; set;}
		public String condicaoPagamento{get; set;}
		public String categoriaNotaFiscal{get; set;}
		public DadosBancarios dadosBancarios{get; set;}
		public String aliquotaISS{get; set;}
		public String numeroDocCompras{get; set;}
	}

	public class Endereco {
		public String endereco{get; set;}
		public String complemento{get; set;}
		public String cidade{get; set;}
		public String numero{get; set;}
		public String bairro{get; set;}
		public String uf{get; set;}
		public String cep{get; set;}
		public String pais{get; set;}
		public String prefixoTelefone{get; set;}
		public String telefone{get; set;}
	}
    
}