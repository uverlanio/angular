/****
@description Classe de servico de criacao de orcamento
@author Diego Zampieri - Globant
@date 22/07/2020
-Classe criada por conta da historia PLV-3926    
*****/
@RestResource(urlMapping = '/endosso/orcamento/criar')
global with sharing class EndossoOrcamentoREST {
    //PLV-4695 - INCIO
    @HttpPost
    global static void gravarOrcamentoEndosso(){
        //Response result = new Response();
        String body = RestContext.request.requestBody.toString();
        
        System.debug('entrada serviço ' + body);
        Request rs = (Request) JSON.deserialize(body, Request.class);
        System.debug('rs ' + rs);
        String segmento = rs.orcamento.segmento;
        segmento = segmento.trim();
        if(segmento.toUpperCase() == 'INDIVIDUAL'){
            EndossoOrcamentoVIService service = new EndossoOrcamentoVIService(rs);
            EndossoOrcamentoVIResponse.DataTO data = new EndossoOrcamentoVIResponse.DataTO();
            ResponseVI respostaServico = new ResponseVI();
            respostaServico.data = data;
            data.ofertas = service.gravaOrcamentoEndosso();
            String retorno = JSON.serialize(respostaServico,true);
            RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
            res.addHeader('Content-Type', 'application/json charset=utf-8');
            res.responseBody = Blob.valueOf(retorno);
            res.statusCode = 200;
            System.debug('RESPOSTA SERVICO PLV-4695 ' + res);
            System.debug('Gior - Response Body: ' + retorno);
            
        }else{
            EndossoOrcamentoService service = new EndossoOrcamentoService(rs);
            Response respostaServico = new Response();
            respostaServico.data = new EndossoOrcamentoResponse.DataTO();
            respostaServico.data.ofertas = service.gravaOrcamentoEndosso();
            String retorno = JSON.serialize(respostaServico);
            RestResponse res = RestContext.response;
            if (res == null) {
                res = new RestResponse();
                RestContext.response = res;
            }
            res.addHeader('Content-Type', 'application/json charset=utf-8');
            res.responseBody = Blob.valueOf(retorno);
            res.statusCode = 200;

            system.debug('retrono servico'+res);
            
            /*EndossoOrcamentoService service = new EndossoOrcamentoService(rs);
            result.data = new EndossoOrcamentoResponse.DataTO();
            result.data.ofertas = service.gravaOrcamentoEndosso();
            System.debug('CARLOSJSON ' + JSON.serialize(result));
            return result;
            */
        }
       
        
    }
     //PLV-4695 - FIM
    /* ***************************************************************** */
     global class Request {
        public EmissaoTO orcamento {
            get;
            set;
        }
    } 

    /* ***************************************************************** */

    global class Response{
        public EndossoOrcamentoResponse.DataTO data {get; set;}
        
        public MetaTO meta {
            get;
            set;
        }

        global Response() {
            this.meta = new MetaTO();
        }
    }

    //PLV-4695 - INICIO
    global class ResponseVI{
        public EndossoOrcamentoVIResponse.DataTO data {get; set;}
        
        public MetaTO meta {
            get;
            set;
        }

        global ResponseVI() {
            this.meta = new MetaTO();
        }
    }
     //PLV-4695 - FIM

    global class MetaTO {
        public String servico {
            get;
            set;
        }
        public Datetime dataExecucao {
            get;
            set;
        }
        public Integer statusHttp {
            get;
            set;
        }
        public String mensagem {
            get;
            set;
        }

        private transient Long startTime = System.currentTimeMillis();
        public Long executionTime {
            get {
                return System.currentTimeMillis() - this.startTime;
            }
        }

        public MetaTO() {
            this.servico = 'endossoCriarOrcamento';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }
}