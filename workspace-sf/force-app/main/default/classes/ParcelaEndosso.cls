//plv 4014 inicio
public class ParcelaEndosso {

	public class Meta {
		public Integer statusHttp;
		public String servico;
		public String mensagem;
		public String dataExecucao;
	}

	public Meta meta;
	public List<Data> data;

	public class Data {
		public Object vidasalesforce;
		public String valorparcela;
		public String valorliquido;
		public String valoriof;
		public String titulo;
		public String sucursal;
		public String status;
		public String seguradosalesforce;
		public String responsavelfinanceiro;
		public String ramo;
		public Integer origemproposta;
		public Object numeroproposta;
		public Integer numeroparcela;
		public Object idparceiro;
		public Object idfatura;
		public String idexterno;
		public Integer id;
		public String endosso;
		public String empresa;
		public String datavencimento;
		public Object dataPagamentoParceiro;
		public Object contrato;
		public String apolice;
	}

	
	public static ParcelaEndosso parse(String json) {
		return (ParcelaEndosso) System.JSON.deserialize(json, ParcelaEndosso.class);
	}
}
//plv 4014 fim