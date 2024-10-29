/**
* Consulta Oferta TO
* @author IF @ 25/12/2019
* @modified IF @ 26/12/2019
*
**/
//PLV-3223 - INÍCIO
public class ConsultaOfertaTO {
    public String mensagem {get;set;}
    public RetornoConsultaTO retornoCosulta {get;set;}
    public List<RetornoConsultaTO> retornosConsulta {get;set;}
    
    public class RetornoConsultaTO {
        public String nome {get;set;}
        public String numero {get;set;}
        public String nomeproduto {get;set;}
        public String status {get;set;}
    }
}
//PLV-3223 - FIM