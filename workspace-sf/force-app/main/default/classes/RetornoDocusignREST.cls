/******************************************************************************************************************************
* Executa alterações após a assinatura do documento Docusign
* @author Carlos - Meta
* @date 03/03/2021
* Classe criada por conta da história PLV-4839
******************************************************************************************************************************/
@RestResource(urlMapping='/retornoDocusign')
global class RetornoDocusignREST {
    @HttpPost
    global static Response consultar(){
        Response result = new Response();
        System.debug(LoggingLevel.DEBUG, RestContext.request.requestBody.toString());
        if(RestContext.request.requestBody.toString() == ''){
            result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
            return result;
        }
        ConsultaParam param = (ConsultaParam) JSON.deserialize(RestContext.request.requestBody.toString(), ConsultaParam.class);

        try {
            if(param.isValid()) {
                RetornoDocusignService service = new RetornoDocusignService(param);
                result.data = service.consultar();
            }else{
                result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
                return result;
            }
        } catch (Exception ex) {
            result.setMessageErro(-1, 'Erro ao consultar Banco. ' + ex.getMessage());
            return result;
        }

        // if(!result.data.atualizado)
        //     result.setMessageErro(0, 'Não foi possível atualizar a critica.');
        return result;
    }


    /*    Classes internas    */
    global class ConsultaParam {
        public String sfId {get; set;}
        public String status {get; set;}
        public String parecer {get; set;}//PLV-4883 - INICIO/FIM - PEDRO AUGUSTO BRAZ
        
        public Boolean isValid(){
            if(String.isBlank(this.sfId) || String.isBlank(this.status))
                return false;
            return true;
        }
    }

    global class Response {
        public DataTO data {get;set;}
        public MetaTO meta {get;set;}

        public Response(){
            this.meta = new MetaTO();
            this.data = new DataTO();
        }

       

        public void setMessageErro(Integer codError, String msg){
            this.data.statusChamada = codError;
            this.data.descricaoErro = msg;
        }
     } 

     global class DataTO {        
        public Integer statusChamada {get;set;}
        public String descricaoErro {get;set;}
        public Boolean atualizado {get;set;}
     }

     global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'retornoDocusign';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

}