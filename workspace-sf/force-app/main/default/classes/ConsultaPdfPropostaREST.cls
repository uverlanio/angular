/*******************************************************************************************************************************
* Consulta PDF Proposta
* @author Yuri - Sys4B
* @date 22/04/2021
* Classe criada por conta da história PLV-4896
******************************************************************************************************************************/
@RestResource(urlMapping='/consultaPropostaPDF')
global class ConsultaPdfPropostaREST {
    
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
                ConsultaPdfPropostaService service = new ConsultaPdfPropostaService(param);
                result.data = service.consultar();
                System.debug('KARIN RESULT');
                System.debug(result);
                System.debug(result.data);
            }else{
                result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
                return result;
            }
        } catch (Exception ex) {
            result.setMessageErro(-1, 'Erro ao consultar proposta. ' + ex.getLineNumber());
            return result;
        }

        if(result == null || !result.hasDocument()){
            result.setMessageErro(0, 'Nenhum documento encontrado pelo número da proposta.');
        }
        return result;
    }


    /*    Classes internas    */
    global class ConsultaParam {
        public String proposta {get; set;}
        public String canal {get; set;}
        public String idCanal {get; set;}

        public Boolean isValid(){
			if(this.proposta == null || String.isBlank(this.proposta)){					
                return false;								            
			}else if(this.idCanal == null || String.isBlank(this.idCanal)){					
                return false;								            
			}else if(this.canal == null || String.isBlank(this.canal)){					
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
            if(this.data != null && this.data.pdfData != null)
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
        public String pdfData {get;set;}
     }

     global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'consultaPropostaPDF';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

}