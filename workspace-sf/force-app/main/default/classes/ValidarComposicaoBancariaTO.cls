public class ValidarComposicaoBancariaTO {

	public DadosBancarios DadosBancarios {get;set;}
	public Integer status {get;set;}
	public String codigo {get;set;}
	public String mensagem {get;set;}
	public String dataOcorrencia {get;set;}
	public String fonte {get;set;}
	public String tipo {get;set;}
	public String additionalInfo {get;set;}

	public class DadosBancarios {
		public Id idConsultaRegistro {get;set;}
		public String banco {get;set;}
		public String agencia {get;set;}
		public String contaCorrente {get;set;}
		public String digitoContaCorrente {get;set;}
	}

	public ValidarComposicaoBancariaTO(){
		DadosBancarios = new DadosBancarios();
	}


}