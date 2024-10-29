/*******************************************************************************************************************************
* Classe service para consulta de contratos para a atualização de data de cobertura
* @author Squad ICloud
* @date 18/03/2022
* Classe criada por conta da história PLV-5346
******************************************************************************************************************************/

@RestResource(urlMapping='/atualiza-dtcobertura')
global class DataCoberturaREST {
    
    @HttpPost
    global static ResponseTO consultaContDtCob() {
        ResponseTO response = new ResponseTO();
        System.debug(RestContext.request);
        Request request = (Request) JSON.deserialize(RestContext.request.requestBody.toString(), Request.class);
        request.ids = request.ids == null? new List<String>() : request.ids;       
        
        if(!request.isValid()){
            response.setErrorMessage('Invalid JSON: ' + JSON.serialize(request));
            return response;
        }
        
        try{
            List<ContratanteContrato__c> lstContratos = DataCoberturaService.getContracts(request);            
            for (ContratanteContrato__c contrato : lstContratos) {
                response.data.contratos.add(new ContratoTO(contrato));
            }
            
        } catch (Exception ex) {
            System.debug('/atualiza-dtcobertura Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString());
            response.setErrorMessage('Exception: ' + ex.getMessage() + ', ' + ex.getStackTraceString());
        }

        response.data.count = response.data.contratos.size();
        
        return response;
    }
    
    global class Request {
        public List<String> ids                 {get;set;}                       
        
        public Request(RestRequest req){}
        
        public Boolean isValid(){
            return this.ids != null && this.ids.size() > 0;
        }
    }
    
    global class ResponseTO {
        public DataTO data                      {get;set;}
        public MetaTO meta                      {get;set;}
        
        public ResponseTO(){
            this.meta = new MetaTO();
            this.data = new DataTO();
        }
        
        public void setErrorMessage(String msg){
            this.data = null;
            this.meta.status = 'ERROR';
            this.meta.error = msg;
        }
    } 
    
    global class MetaTO {
        public String servico                   {get;set;}
        public Datetime dataExecucao            {get;set;}
        public Integer statusHttp               {get;set;}
        public String status                    {get;set;}
        public String error                     {get;set;}
        
        public MetaTO() {
            this.servico = 'AtualizaDataCobertura'; //PLV-5346 - FIX01 - INICIO/FIM
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.error = null;
            this.status = 'OK';
        }
    }
    
    global class DataTO {
        public List<ContratoTO> contratos       {get; set;}
        public Integer count                    {get; set;}
        
        Public DataTO(){
            this.count = 0;
            this.contratos = new List<ContratoTO>();
        }
    }    
   
    global class ContratoTO{
        public String idcontrato                {get; set;}
        public Date vigenciafinal               {get; set;}
        public String numeropropostaunico       {get; set;}
        public String idrespagamento            {get; set;}
        public String cpf                       {get; set;}
        public String cnpj                      {get; set;}
        
        public ContratoTO(ContratanteContrato__c contrato){            
            this.idcontrato = contrato.Contrato__r.Id;
            this.vigenciafinal = contrato.Contrato__r.VigenciaFinal__c;
            this.numeropropostaunico = contrato.Contrato__r.NumeroPropostaUnico__c;
            this.idrespagamento = contrato.ResponsavelPagamento__r.Id;
            this.cpf = contrato.ResponsavelPagamento__r.Cpf__c;
            this.cnpj = contrato.ResponsavelPagamento__r.Cnpj__c;
        }
    }    
}