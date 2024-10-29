@RestResource(urlMapping='/contrato/consultaAcumuloCapital')
global class ConsultaAcumuloCapitalRest {
    //PLV-4503 INICIO

    //++++++++++++++++++++++++
    // HTTP METHODS
    //++++++++++++++++++++++++
    
    @HttpPost
    global static void consultaAcumuloCapital() {
        Response res = new Response();

        try {
            //EX : {"cpf": "524.880.397-72","coberturas":[{"sigla": "AFI","valorSumarizadoLegado": 100000}]}

            Request req = (Request) JSON.deserialize(RestContext.request.requestBody.toString(), Request.class);

            if (req.isValid()) {
                
                res = ConsultaAcumuloCapitalBusiness.getAcumuloCapitalCoberturasByCpf(req);

                res.doSucesso();
            }
            else {
                throw new ConsultaAcumuloCapitalRestException('Parâmetros de entrada inválidos: ' + JSON.serializePretty(req));
            }

        } catch (Exception ex) {
            res.doBadRequest(ex);
        }
    }

    //++++++++++++++++++++++++
    // PUBLIC INNER CLASSES
    //++++++++++++++++++++++++

    public class Request {
        public String cpf;
        public List<Cobertura> coberturasLegado;
        public List<Cobertura> coberturasPortal;

        //++++++++++++++++++++++++
        // PUBLIC METHODS
        //++++++++++++++++++++++++

        public Boolean isValid() {
            return !String.isBlank(this.cpf);
        }
    }

    public class Response {
        public String status;
        public String mensagem;
        public List<Cobertura> coberturas;

        //++++++++++++++++++++++++
        // PUBLIC METHODS
        //++++++++++++++++++++++++ 

        public void doBadRequest(Exception ex) {
            System.debug('doBadRequest :: Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString());
            coberturas = null;
            status = 'FAIL';
            mensagem = ex.getMessage() + ', ' + ex.getStackTraceString();
            setResponse(getJSON(), 400);
        } 
    
        public void doSucesso() {
            status = 'OK';
            mensagem = 'Sucesso';
            setResponse(getJSON(), 200);
        }
    
        //++++++++++++++++++++++++
        // PRIVATE METHODS
        //++++++++++++++++++++++++

        private void setResponse(Blob respondeBody, Integer statusCode) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = respondeBody;
            RestContext.response.statusCode = statusCode;
        }
    
        private Blob getJSON() {
            return Blob.valueOf(JSON.serializePretty(this, true));
        }
    }

    public class Cobertura {
        public String sigla;
        public Double valor;
    }
    
    public class ConsultaAcumuloCapitalRestException extends Exception {}
    
    //PLV-4503 FIM
}