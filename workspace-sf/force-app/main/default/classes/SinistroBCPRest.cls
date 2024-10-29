// PLV-4095 criação da classe

@RestResource(urlMapping='/sinistro/bcp')
global class SinistroBCPRest {    
    @HttpGet
    global static Response consultaSinistroBCP(){
        
        Response result = new Response();
        ConsultaParam param = new ConsultaParam(RestContext.request);

        EnvioSinistroBCP envio = new EnvioSinistroBCP();
        result.data = envio.envioSinistroBCP( param.caseId , param.edsTip );
        return result;
    }

    global class ConsultaParam {
        public String caseId        {get; set;}
        public String edsTip        {get; set;}

        public ConsultaParam(RestRequest req){
            this.caseId = req.params.get('caseId');
            this.edsTip = req.params.get('edsTip');
        }
    }

    global class Response {
        public SinistroBCPTO data {get;set;}
        public MetaTO meta {get;set;}

        public Response(){
            this.meta = new MetaTO();
            this.data = new SinistroBCPTO();
        }
     }
    
    global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'sinistroBCP';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }
}