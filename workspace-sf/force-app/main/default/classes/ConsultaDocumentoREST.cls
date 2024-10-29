/*******************************************************************************************************************************
* Consulta documento
* @author Carlos - Meta
* @date 05/04/2021
* Classe criada por conta da história PLV-4891
******************************************************************************************************************************/
@RestResource(urlMapping='/consultaDocumento')
global class ConsultaDocumentoREST {
    
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
                ConsultaDocumentoService service = new ConsultaDocumentoService(param);
                result.data = service.consultar();
                System.debug('KARIN RESULT');
                System.debug(result);
                System.debug(result.data);
            }else{
                result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
                return result;
            }
        } catch (Exception ex) {
            result.setMessageErro(-1, 'Erro ao consultar documento. ' + ex.getLineNumber());
            return result;
        }

        if(result == null || !result.hasDocument()){
            result.setMessageErro(0, 'Nenhum documento encontrado pelo número do orçamento.');
        }
        return result;
    }


    /*    Classes internas    */
    global class ConsultaParam {
        public String orcamento {get; set;}

        public Boolean isValid(){
			if(this.orcamento == null || String.isBlank(this.orcamento)){					
                return false;								            
			}else{
				return true;
			}				
        }
	}    

    global class Response {
        public DataTO data {get;set;}
        public MetaTO meta {get;set;}

        public Response(){
            this.meta = new MetaTO();
            this.data = new DataTO();
        }

        public Boolean hasDocument(){
            if(this.data != null && this.data.ofertaPadrao != null)
                return true;
            else
                return false;
        }

        public void setMessageErro(Integer codError, String msg){
            if(this.data == null)
                this.data = new DataTO();
            this.data.statusChamada = codError;
            this.data.descricaoErro = msg;
        }
     } 

     global class DataTO {        
        public Integer statusChamada {get;set;}
        public String descricaoErro {get;set;}
        public String ofertaPadrao {get;set;}
        public String localstorage {get;set;}
     }

     global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'consultaDocumentos';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

}