public class ConsultaCartaoTO {
	public class PostTO{
		public PostItemTO ofertarEConsultarCartao {get; set;}

		public PostTO(){
			this.ofertarEConsultarCartao = new PostItemTO();
		}
	}

	public class PostItemTO{
		public PostSubItemTO entradaOfertarEConsultarCartao {get; set;}

		public PostItemTO(){
			this.entradaOfertarEConsultarCartao = new PostSubItemTO();
		}
	}

	public class PostSubItemTO{
		public String bonusSeguro {get; set;}
		public String codCanal {get; set;}
		public String codProduto {get; set;}
		public String codRamoSolicitante {get; set;}
		public String cpf {get; set;}
		public String dataNasc {get; set;}
		public String deptoSolicitante {get; set;}
		public String idadeInformacao {get; set;}
		public String nome {get; set;}
		public String premio {get; set;}
		public String ramoProduto {get; set;}
		public String score {get; set;}
		public String sistemaOrigem {get; set;}
		public String susep {get; set;}
		public String tipoCanal {get; set;}
		public String tipoEndosso {get; set;}
		public String tipoPessoa {get; set;}
		public String tipoPlano {get; set;}
		public String tipoSistema {get; set;}
		public String uf {get; set;}
		public String clienteComRestricao {get; set;}
		public String scoreCsb8 {get; set;}
	}

	public class ResponseTO{
		public ResponseItemTO ofertarEConsultarCartaoResponse {get; set;}

		public ResponseTO(){
			this.ofertarEConsultarCartaoResponse = new ResponseItemTO();
		}
	}

	public class ResponseItemTO{
		public String codRetorno {get; set;}
		public String msgRetorno {get; set;}
		public String devolutivaOferta {get; set;}
		public String prioridadeBandeira {get; set;}
		public RetornoSegundaCompraTO retornoSegundaCompra {get; set;}
		public String codigoRetorno {get; set;}
		public String mensagemRetorno {get; set;}
	}

	public class RetornoSegundaCompraTO{
		public String cartoesCliente {get; set;}
		public String codigoRetorno {get; set;}
		public String mensagemRetorno {get; set;}
	}
}