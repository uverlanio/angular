/****
@description Classe de servico para atualizacao do orcamento
@author Diego Zampieri - Globant
@date 22/07/2020
-Classe criada por conta da historia PLV-3926    
*****/
@RestResource(urlMapping = '/endosso/orcamento/atualizar')
global with sharing class EndossoAtualizaOrcamentoREST {
    
    @HttpPost
    global static Response gravarOrcamentoEndosso(){

        Response result = new Response();

        String body = RestContext.request.requestBody.toString();
        
        System.debug('body ' + body);
        Request rs = (Request) JSON.deserialize(body, Request.class);
        System.debug('rs ' + JSON.serialize(rs));
        EndossoAtualizaOrcamentoService service = new EndossoAtualizaOrcamentoService(rs);

        result.data = service.atualizaEndosso();

        return result;
    }

    /* ***************************************************************** */
    global class Request {
        public EmissaoTO.OfertasTO[] ofertas {
            get;
            set;
        }
    }
    
    /* ***************************************************************** */

    global class Response {
        public EndossoOrcamentoResponse.ValidacaoOrcamentoTO data {get; set;}
        public MetaTO meta {get; set; }

        global Response() {
            this.meta = new MetaTO();
        }
    }

    global class MetaTO {
        public String servico {get; set;}
        public Datetime dataExecucao {get; set;}
        public Integer statusHttp {get; set;}
        public String mensagem {get;set;}

        private transient Long startTime = System.currentTimeMillis();
        public Long executionTime {
            get {
                return System.currentTimeMillis() - this.startTime;
            }
        }

        public MetaTO() {
            this.servico = 'endossoAtualizaOrcamento';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }
}