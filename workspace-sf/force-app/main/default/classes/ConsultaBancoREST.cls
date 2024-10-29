/******************************************************************************************************************************
* Consulta dados de Banco
* @author Carlos - Meta
* @date 08/09/2020
* Classe criada por conta da história PLV-4383
******************************************************************************************************************************/
@RestResource(urlMapping='/consultaBanco')
global class ConsultaBancoREST {
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
                ConsultaBancoService service = new ConsultaBancoService(param);
                result.data = service.consultar();
            }else{
                result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
                return result;
            }
        } catch (Exception ex) {
            result.setMessageErro(-1, 'Erro ao consultar Banco. ' + ex.getMessage());
            return result;
        }

        if(!result.hasBancos()) result.setMessageErro(0, 'Nenhum banco encontrado pelo parâmetro fornecido.');
        return result;
    }


    /*    Classes internas    */
    global class ConsultaParam {
        public String bancosConveniados {get; set;}
        
        public Boolean isValid(){
            if(String.isBlank(this.bancosConveniados))
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

        public Boolean hasBancos(){
            return !this.data.Bancos.isEmpty();
        }

        public void setMessageErro(Integer codError, String msg){
            this.data.statusChamada = codError;
            this.data.descricaoErro = msg;
        }
     } 

     global class DataTO {        
        public Integer statusChamada {get;set;}
        public String descricaoErro {get;set;}
        public List<ConsultaBancoTO> Bancos {get;set;}
     }

     global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'consultaBanco';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

    global class ConsultaBancoTO{
        public String codigoBanco { get; set; }
        public String nomeBanco { get; set; }
    }
}