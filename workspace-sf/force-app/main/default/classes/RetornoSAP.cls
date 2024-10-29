//plv-4148- inicio
public class RetornoSAP {

	public Retornofornecedor retornofornecedor;
	public Retornoop retornoop;

	public class Mensagens_Z {
		public String codigoRetorno;
		public String mensagemErro;
	}

	public class Retornofornecedor {
		public String nroDocCPFCNPJFornecedor;
		public List<Mensagens> mensagens;
	}

	public class Mensagens {
		public String codigoRetorno;
		public String mensagemRetorno;
	}

	public class Retornoop {
		public String numeroDocumento;
		public String numeroDocumentoOrdemPag;
		public List<Mensagens_Z> mensagens;
	}

	
	public static RetornoSAP parse(String json) {
		return (RetornoSAP) System.JSON.deserialize(json, RetornoSAP.class);
	}
}
//PLV-4148 - FIM