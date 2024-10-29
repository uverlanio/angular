/**
 * Created by GFS on 25/04/2019.
 */

public class CasoTO{ 

    //Retorno JSON de proposta para o serviço de cancelamento
    public validacaoPropostaTO validacaoProposta;

	public class validacaoPropostaTO {
		public datametaTO meta {get; set;}
	}
	public class datametaTO {
		public String dataExecucao {get; set;}	//2019-04-25T20:33:03.437Z
		public String mensagem {get; set;}	//OK
		public Integer statusHttp {get; set;}	//200
		public String servico {get; set;}	//GeracaoProposta
	}
    
    
}