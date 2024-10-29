/*******************************************************************************************************************************
* Consulta dados Básicos do asegurado
* @author Edgar Peralta - Globant / Francisco Rochett - Globant
* @date 28/07/2020
* Classe criada por conta da história PLV-3956
******************************************************************************************************************************/
@RestResource(urlMapping='/ConsultaDadosDoSegurado/*')
global with sharing class ConsultaDadosDoSegurado {

    @HttpPost
    global static response doPost(String cpf){
        RestRequest req = RestContext.request;
    	RestResponse res = RestContext.response;
        List<Account> listInsuredData = new List<Account>();
        
        req.httpMethod = 'POST';
		String cpfunMasked = getUnMask(cpf);
        String cpfMasked = getMask(cpfunMasked);
        
        listInsuredData = [SELECT Id, Name, Cpf__c, PersonBirthdate, Idade__c, PersonEmail, BillingAddress, 
        						  PersonMailingAddress, ShippingAddress, PersonHomePhone, Phone, PersonMobilePhone,
        						  EstadoCivil__c, Nacionalidade__c, Pep__c, Profissao__r.Name, Fumante__c, Renda__c
        				   FROM Account 
                           WHERE Cpf__c =: cpfMasked];
        
		Response resp = new Response();
        
        if(!listInsuredData.isEmpty()){ 
            contaResponseTO con = new contaResponseTO();
       		resp.data.conta.add(con);
            resp.meta.mensagemdetalhes = 'Cliente encontrado';
            resp.meta.erro = FALSE;
            resp.data.conta[0].NomeDoSegurado = listInsuredData[0].Name;
            resp.data.conta[0].CPF = listInsuredData[0].Cpf__c;
            resp.data.conta[0].DataDeNascimento = listInsuredData[0].PersonBirthdate;
            resp.data.conta[0].Idade = listInsuredData[0].Idade__c;
            resp.data.conta[0].Email = listInsuredData[0].PersonEmail;
            if(listInsuredData[0].PersonMailingAddress != NULL){
                resp.data.conta[0].EnderecoResidencial.add(fillEndereco(listInsuredData[0].PersonMailingAddress));
            }
            if(listInsuredData[0].BillingAddress != NULL){
                resp.data.conta[0].EnderecoComercial.add(fillEndereco(listInsuredData[0].BillingAddress));
            }
            if(listInsuredData[0].ShippingAddress != NULL){
                resp.data.conta[0].EnderecoCobranca.add(fillEndereco(listInsuredData[0].ShippingAddress));
            }
            resp.data.conta[0].TelefoneResidencial = String.valueOf(listInsuredData[0].PersonHomePhone);
            resp.data.conta[0].TelefoneCelular = listInsuredData[0].PersonMobilePhone;
            resp.data.conta[0].TelefoneComercial = listInsuredData[0].Phone;
            resp.data.conta[0].EstadoCivil = listInsuredData[0].EstadoCivil__c;
            resp.data.conta[0].Nacionalidade = listInsuredData[0].Nacionalidade__c;
            resp.data.conta[0].PEP = listInsuredData[0].Pep__c;
            resp.data.conta[0].Profissao = listInsuredData[0].Profissao__r.Name;
            resp.data.conta[0].Fumante = listInsuredData[0].Fumante__c;
            resp.data.conta[0].Renda = listInsuredData[0].Renda__c;
        }
        
        return resp;
    }

    public static String getMask(String text){
        String newTexgt = '';
        if (text != NULL) {
            newTexgt =   text.substring(0, 3) + '.' + text.substring(3, 6) + '.' + text.substring(6, 9) + '-' + text.substring(9);
        }
        return newTexgt;
    }

    public static String getUnMask(String text){
        String newTexgt = '';
        if (text.length() > 0) {
            newTexgt = text.replaceAll('[^a-zA-Z0-9\\s+]', '');
        }
        return newTexgt;
    }
        
    global class Response {
        public DataTO data {get; set;}
        public MetaTO meta {get; set;}
        
        public Response(){
            this.data = new DataTO();
            this.meta = new MetaTO();
        }
    }
    
    global class MetaTO {
        public String servico 		 {get; set;}
        public Datetime dataExecucao {get; set;}
        public Integer statusHttp 	 {get; set;}
        public String mensagem 		 {get; set;}
        public String mensagemdetalhes 		 	   {get; set;}
        public Boolean erro 			   {get; set;}
        
        public MetaTO() {
            this.servico = 'ConsultaDadosDoSegurado';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
            this.erro = TRUE;
            this.mensagemdetalhes = 'Cliente não encontrado';
        }
    }
    
    global class contaResponseTO{
        public String NomeDoSegurado 	  		  {get; set;}
        public String CPF 				  		  {get; set;}
        public Date DataDeNascimento	  		  {get; set;}
        public Decimal Idade 			  		  {get; set;}
        public String Email 			  		  {get; set;}
        public List<Endereco> EnderecoResidencial {get; set;}
        public List<Endereco> EnderecoComercial   {get; set;}
        public List<Endereco> EnderecoCobranca 	  {get; set;}
        public String TelefoneResidencial 		  {get; set;}
        public String TelefoneCelular	   		  {get; set;}
        public String TelefoneComercial   		  {get; set;}
        public String EstadoCivil		  		  {get; set;}
        public String Nacionalidade 	  		  {get; set;}
        public String PEP 				  		  {get; set;}
        public String Profissao 		  		  {get; set;}
        public String Fumante 			  		  {get; set;}
        public Decimal Renda 			  		  {get; set;}
		
        public contaResponseTO(){
            this.EnderecoResidencial = new List<Endereco>();
            this.EnderecoComercial = new List<Endereco>();
            this.EnderecoCobranca = new List<Endereco>();
        }        
    }
    
    global class Endereco{
        public String Cidade	{get; set;}
        public String Pais		{get; set;}
        public String Stado		{get; set;}
        public String Rua		{get; set;}
        public String CEP		{get; set;}
    }
    
    global class DataTO{
        public List<contaResponseTO> conta {get; set;}
        
        public DataTO(){
            this.conta = new List<contaResponseTO>();
        }
    }
    
    public static Endereco fillEndereco(Address endereco){
        Endereco edrco = new Endereco();
        edrco.Cidade = endereco.getCity();
        edrco.Pais = endereco.getCountry();
        edrco.Stado = endereco.getState();
        edrco.Rua = endereco.getStreet();
        edrco.CEP = endereco.getPostalCode();
        return edrco;
    }

}