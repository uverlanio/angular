/*
*
* Classe responsável pela estrutura de retorno dos serviços REST dispoibilizados pelo Salesforce
*
*/
public class RetornoRestTO{
	public Object data {get; set;} 
	public MetaTO meta {get; set;}

	public RetornoRestTO(String nomeServico){
		this.meta = new MetaTO();
		this.meta.servico = nomeServico;
		this.meta.dataExecucao = System.now();
	}
	
	public class MetaTO {
		public String servico {get; set;}
		public Datetime dataExecucao {get; set;}
		public Integer statusHttp {get; set;}
		public String mensagem {get; set;}
	}
}