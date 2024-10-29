/*******************************************************************************************************************************
* Consulta dados de Orcamento
* @author Carlos - Meta
* @date 30/07/2020
* Classe criada por conta da história PLV-4204
******************************************************************************************************************************/
@RestResource(urlMapping='/consultaOrcamento')
global class ConsultaOrcamentoREST {
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
                ConsultaOrcamentoService service = new ConsultaOrcamentoService(param);
                result.data = service.consultar();
            }else{
                result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
                return result;
            }
        } catch (Exception ex) {
            result.setMessageErro(-1, 'Erro ao consultar Orcamento. ' + ex.getMessage());
            return result;
        }

        if(!result.hasOrcamentos()) result.setMessageErro(0, 'Nenhum orçamento encontrado para a Susep informada.');
        return result;
    }


    /*    Classes internas    */
    global class ConsultaParam {
        public String canal 	 {get; set;}
        public String idCanal 	 {get; set;}
        public String nomeSegurado {get; set;}    //PLV-4928 - INICIO
        public String numeroOrcamento {get; set;}
        public String dataProposta {get; set;}    //PLV-4928 - FIM
        public String codigoOferta 	 {get; set;} //II-124 FIX01 INICIO-FIM
        
        public Boolean isValid(){
            if(String.isBlank(this.idCanal) || String.isBlank(this.canal) )
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

        public Boolean hasOrcamentos(){
            return !this.data.Orcamentos.isEmpty();
        }

        public void setMessageErro(Integer codError, String msg){
            this.data.statusChamada = codError;
            this.data.descricaoErro = msg;
        }
     } 

     global class DataTO {        
        public Integer statusChamada {get;set;}
        public String descricaoErro {get;set;}
        public List<ConsultaOrcamentoTO> Orcamentos {get;set;}
     }

     global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'consultaOrcamento';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

    global class ConsultaOrcamentoTO{
        public String orcamento { get; set; }
        public String meioComercializacao { get; set; }
        public String status { get; set; }
        public double premio { get; set; }
        public String segmento { get; set; } //PLV-4393 - Inicio-Fim
        public String produto { get; set; }  //PLV-4928 - FIX - INICIO/FIM
        public Boolean customizavel { get; set; } //PLV-4393 - Inicio-Fim
        public String dataCriacao { get; set; } //PLV-4393 - COMPLEMENTO - incio/fim
        public List<ConsultaOrcamentoGarantiaTO> garantias { get; set; }
        public Integer ramoseguro   {get; set; }
        public String nomeCliente { get; set; } //PLV-4929 - INICIO/FIM
    }

    global class ConsultaOrcamentoGarantiaTO{
        public string nome { get; set; }
        public double ordemPrioridade { get; set; }
        public double capital { get; set; }
    }
}