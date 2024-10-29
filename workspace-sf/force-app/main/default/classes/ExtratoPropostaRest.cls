/*******************************************************************************************************************************
* Classe consulta de extrado de propostas para o Megaday
* @author Squad Globant
* @date 19/07/2021
* Classe criada por conta da história PLV-5068
******************************************************************************************************************************/

@RestResource(urlMapping='/extrato-proposta')
global class ExtratoPropostaRest {
    
    @HttpPost
    global static ResponseTO consultaExtratoProposta() {
        //EX : { "inicio": "2020-01-01", "fim": "2020-01-01", "cobertura": ["SIGLA"], "ramo": ["1391", "1381"]}
        
        ResponseTO response = new ResponseTO();
        System.debug(RestContext.request);
        Request request = (Request) JSON.deserialize(RestContext.request.requestBody.toString(), Request.class);
        request.coberturas = request.coberturas == null? new List<String>() : request.coberturas;
        request.ramos = request.ramos == null? new List<String>() : request.ramos;
        request.produto = request.produto == null? new List<String>() : request.produto; //II-159 INICIO-FIM
        System.debug('request r<>' + JSON.serialize(request));
        if(!request.isValid()){
            response.setErrorMessage('Invalid JSON: ' + JSON.serialize(request));
            return response;
        }
        
        try{
            List<Quote> lstPropostas = ExtratoPropostaService.getPropostas(request);
            Map<ID, SeguradoProposta__c> mpSegurados = ExtratoPropostaService.getSegurados(lstPropostas);
            Map<Id, List<FavorecidoRemuneracaoProposta__c>> mpCorretor = ExtratoPropostaService.getCorretores(lstPropostas);

            for (Quote proposta : lstPropostas) {
                response.data.propostas.add(new PropostaTO(proposta, mpSegurados.get(proposta.id), mpCorretor.get(proposta.id)));
            }            
        } catch (Exception ex) {
            System.debug('/extrato-proposta Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString());
            response.setErrorMessage('Exception: ' + ex.getMessage() + ', ' + ex.getStackTraceString());
        }

        response.data.count = response.data.propostas.size();
        
        return response;
    }
    
    global class Request {

        public Request(){}

        public Date inicio  {get; set;}
        public Date fim  {get; set;}
        public List<String> coberturas {get;set;}
        public List<String> ramos {get;set;}
        //II-159 INICIO
        public List<String> produto {get;set;}
        
        public Request(RestRequest req){}
        
        public Boolean isValid(){
            return this.inicio != null && this.fim != null && this.coberturas != null && this.coberturas.size() > 0 && this.ramos != null && this.ramos.size() > 0 && this.produto != null && this.produto.size() > 0;
        }
        //II-159 FIM
    }
    
    global class ResponseTO {
        public DataTO data {get;set;}
        public MetaTO meta {get;set;}
        
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
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String status {get;set;}
        public String error  {get;set;}
        
        public MetaTO() {
            this.servico = 'ExtratoPropostaRest';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.error = null;
            this.status = 'OK';
        }
    }
    
    global class DataTO {
        public List<PropostaTO> propostas {get; set; }
        public Integer count {get; set;}
        
        Public DataTO(){
            this.count = 0;
            this.propostas = new List<PropostaTO>();
        }
    }
    
    global class PropostaTO{
        public String origem {get; set;}
        public String proposta {get; set;}
        public String status {get; set;}
        public String cpfnumero {get; set;}
        public String cpfdigito {get; set;}
        public String npasrne {get; set;}
        public String sexo {get; set;}
        public String cepzonapostal {get; set;}
        public String cepsufixo {get; set;}
        public String cidade {get; set;}
        public String uf {get; set;}
        public String complementoendereco {get; set;}
        public String bairro {get; set;}
        public String logradouro {get; set;}
        public String numerocasa {get; set;}
        public String ddd {get; set;}
        public String telefone {get; set;}
        public String email {get; set;}
        public String produto {get; set;}
        public String nome {get; set;}
        //II-159 INICIO
        public String profissao {get; set;}
        public Decimal rendaMensal {get; set;}
        public String cicloVacinal {get; set;}
		//II-159 FIM
        public Date datamodificacao {get; set; }
		public Date datatransmissao {get; set; }    //PLV- 5068 - FIX01 - INICIO/FIM
		public Date datanascimento {get; set; }
        
        public Decimal premio {get; set; }

        public List<CorretorTO> corretores {get; set; }
        
        public PropostaTO(Quote proposta, SeguradoProposta__c segurado, List<FavorecidoRemuneracaoProposta__c> lstCorretor){
            if(segurado == null ) segurado = new SeguradoProposta__c();
            if(lstCorretor == null ) lstCorretor = new List<FavorecidoRemuneracaoProposta__c>();

            this.origem = proposta.Origem__c;
            this.proposta = proposta.NumeroProposta__c;
            this.status = proposta.status;
        
            String[] cpfSplit = segurado.Conta__r.Cpf__c == null ? new List<String>{'', ''} : segurado.Conta__r.Cpf__c.replace('.', '').split('-');
            this.cpfnumero = cpfSplit[0];
            this.cpfdigito = cpfSplit[1];
            this.npasrne = segurado.Conta__r.Rne__c;
            this.sexo = segurado.Conta__r.Sexo__c;

            String[] cepSplit = segurado.CepResidencial__c == null ? new List<String>{'', ''} : segurado.CepResidencial__c.split('-');
            this.cepzonapostal = cepSplit[0];
            this.cepsufixo = cepSplit[1];
            this.cidade = segurado.CidadeResidencial__c;
            this.uf = segurado.UFResidencial__c;
            this.complementoendereco = segurado.ComplementoResidencial__c;
            this.bairro = segurado.BairroResidencial__c;
            this.logradouro = segurado.LogradouroResidencial__c;
            this.numerocasa = segurado.numeroResidencial__c;

            String[] telefoneSplit = segurado.Conta__r.PersonHomePhone == null ? new List<String>{'', ''} : segurado.Conta__r.PersonHomePhone.replaceAll('[^0-9)]','').split('\\)');
            this.ddd = telefoneSplit[0];
            this.telefone = telefoneSplit[1];
            this.email = segurado.Conta__r.PersonEmail; //PLV- 5068 - FIX02 - INICIO/FIM
            this.produto = proposta.produto__r.name;
            this.nome = segurado.Conta__r.Name;

            this.datamodificacao = proposta.LastModifiedDate.date();
            this.datatransmissao = proposta.DataProtocolo__c;  //PLV- 5068 - FIX01 - INICIO/FIM
            this.datanascimento = segurado.Conta__r.PersonBirthdate;
 
            this.premio = (proposta.PremioTotal__c != null) ? proposta.PremioTotal__c.setScale(2) : 0; //PLV-5881 INICIO-FIM

            //II-159 INICIO
            this.cicloVacinal = segurado.CicloVacinal__c;
            this.rendaMensal = segurado.Conta__r.Renda__c;
            this.profissao = segurado.Conta__r.Profissao__r.Name;
            //II-159 FIM                    
            this.corretores = new List<CorretorTO>();
            for(FavorecidoRemuneracaoProposta__c corretor : lstCorretor){
                this.corretores.add(new CorretorTO(corretor));
            }

        }
    }

    global class CorretorTO{
        public String susep {get; set;}
        public String flagsuseplider {get; set;}

        public CorretorTO(FavorecidoRemuneracaoProposta__c corretor){
            this.susep = corretor.Susep__c;
            this.flagsuseplider = corretor.CorretorLider__c ? 'S' : 'N';
        }
    }
}