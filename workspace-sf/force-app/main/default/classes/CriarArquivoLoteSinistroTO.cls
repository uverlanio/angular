/**
 * Created by Renato M Simião on 29/01/2019.
 */
public class CriarArquivoLoteSinistroTO {

	public ArquivoTO arquivo {get;set;}
	public LoteTO lote {get;set;}
	public List<SinistroTO> sinistros {get;set;}

	public CriarArquivoLoteSinistroTO() {

		this.arquivo = new ArquivoTO();
		this.lote = new LoteTO();
		this.sinistros = new List<SinistroTO>();
	}
	
	public class ArquivoTO {
		
		//public Integer id {get;set;}
		//public Integer idlote {get;set;}
		public String tipoarquivo {get;set;}
		public String nomearquivo {get;set;}
		//public Datetime dataregistro {get;set;}
		//public Datetime horaregistro {get;set;}
		public String direcao {get;set;}
		public String codigoparceiro {get;set;}
		public String produto {get;set;}
		public String loteparceiro {get;set;}
		public Integer versaoarquivo {get;set;}
		public String status {get;set;}
		public String sigla {get;set;}
	}

	public class LoteTO {

		//public Integer id {get;set;}
		//public Datetime datacriacao {get;set;}
		public String nome {get;set;}
		public String status {get;set;}
	}

	public class SinistroTO {

		//public Integer id {get;set;}
		public String cpf {get;set;}
		public String idlote {get;set;}
		public String nome {get;set;}
		public Datetime dataocorrencia {get;set;}
		public Datetime dataaviso {get;set;}
		public String codigoprodutoparceiro {get;set;}
		public String numerosinistro {get;set;}
		public String idseguradoparceiro {get;set;}
		public String status {get;set;}
		public String origemproposta {get;set;}
		public String numeropropostaporto {get;set;}
		public String numerocontratoparceiro {get;set;}
		//public Datetime dataindenizacao {get;set;}
		//public Datetime datastatus {get;set;}
		//public String motivoencerramento {get;set;}
		public Decimal valorindenizado {get;set;}
		//public Decimal ordempagamento {get;set;}
		//public String agencia {get;set;}
		//public String banco {get;set;}
		//public String conta {get;set;}
		public String observacao {get;set;}
		//public Integer idarquivo {get;set;}
		public String fase {get;set;}
		public String idcaso {get;set;}
	}
}