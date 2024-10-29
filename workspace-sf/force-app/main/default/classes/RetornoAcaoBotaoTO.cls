public class RetornoAcaoBotaoTO{
	public String tipo {get; set;}
	public List<String> mensagens {get; set;}
	public String linkRedirecionar {get; set;}
	public List<SObject> registros {get; set;}

	public static final String SUCCESS = 'success';
	public static final String WARNING = 'warning';
	public static final String ERROR = 'error';

	public RetornoAcaoBotaoTO(){
		this.registros = new List<SObject>();
		this.mensagens = new List<String>();
	}

	public RetornoAcaoBotaoTO(String tipo, List<String> mensagens, String linkRedirecionar, List<SObject> registros){
		this.tipo = tipo;
		this.mensagens = mensagens;
		this.linkRedirecionar = linkRedirecionar;
		this.registros = registros;
	}
}