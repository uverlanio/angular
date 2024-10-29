/*****************************************************************************
* Consulta 
* @author Gabriel - Globant, Erika - Globant
* @date 16/07/2020
* Classe criada por conta da história PLV-3910
*****************************************************************************/
@RestResource(urlMapping='/corretor/apolice')
global class ConsultaCorretorRest  {
   
   
    @HttpGet
	global static Response consultar(){
        ContractDAO contractDAO = ContractDAO.getInstance();
        RestRequest request = RestContext.request;
        Response response = new Response();
        Contract apolice;
        List<ID> lstCorretorId = new List<ID>();
        ConsultaParam param = new ConsultaParam(RestContext.request);


        if(param.numApolice == null) return response;

        apolice =  getApolice(param.numApolice);

        if(apolice == null) return response;

        response.data = getCorretores(apolice.id);

        response.meta.error = null;
       
        return response;
    }

    private static Contract getApolice(String numApolice){
        try {
            return [
                SELECT 
                    id
                FROM Contract 
                WHERE IdExterno__c =: numApolice
                LIMIT 1
            ];
        } catch (Exception ex) {
            System.debug('ERROR: ' + ex.getMessage());
            return null;
        }
    }

    private static List<Corretor> getCorretores(ID apoliceId){
        List<Corretor> lstCorretor = new List<Corretor>();

        List<FavorecidoRemuneracaoContrato__c> lstCorretoresRaw = [
            SELECT 
                Id, 
                Susep__c,
                // Papel__c,
                // Participacao__c,
                // CorretorLider__c,
                DadosCorretor__r.NomeCorretor__r.ID, 
                DadosCorretor__r.NomeCorretor__r.Email__c, 
                DadosCorretor__r.NomeCorretor__r.PersonEmail, 
                DadosCorretor__r.NomeCorretor__r.Name,
                DadosCorretor__r.NomeCorretor__r.Phone
            FROM 
                FavorecidoRemuneracaoContrato__c 
            WHERE 
                RemuneracaoContrato__r.Contrato__c = :apoliceId
            ORDER BY CorretorLider__c DESC, CreatedDate ASC
            LIMIT 1
        ];

        
        for(FavorecidoRemuneracaoContrato__c corretorRaw : lstCorretoresRaw){
            if(corretorRaw.DadosCorretor__r.NomeCorretor__r.ID != null) {
                Corretor corretor = new Corretor();
                corretor.nome = corretorRaw.DadosCorretor__r.NomeCorretor__r.Name;
                corretor.telefone = corretorRaw.DadosCorretor__r.NomeCorretor__r.Phone;
                corretor.email = corretorRaw.DadosCorretor__r.NomeCorretor__r.Email__c;
                corretor.susep.add(corretorRaw.Susep__c);
                lstCorretor.add(corretor);
            }
        }

        return lstCorretor;
    }
    
    global class Response {
        public List<Corretor> data {get;set;}
        public MetaTO meta {get;set;}

        public Response(){
            this.data = new List<Corretor>();
            this.meta = new MetaTO();
        }
    } 

    global class Corretor{
        public String nome {get;set;}
        public List<String> susep  {get;set;}
        public String telefone {get;set;}
        public String email  {get;set;}


        public Corretor(){
           this.susep = new List<String>();
        }
    }
    
    global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        public String error  {get;set;}
        
        public MetaTO() {
            this.error = 'SUSEP não encontrada';
            this.servico = 'ConsultaCorretor';
            this.dataExecucao = System.now();
            this.mensagem = 'OK';
            this.statusHttp = 200;
        }
    }

    global class ConsultaParam {
        public String numApolice {get; set;}

        public ConsultaParam(RestRequest req){
            this.numApolice = req.params.get('numeroApolice');
        }
    }
}