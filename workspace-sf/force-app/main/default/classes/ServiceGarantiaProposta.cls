/*
PLV-4350 - CRIADO EM 12/11/2020
AUTOR: JEFERSON SANTANA
DESCRIÇÃO: SERVIÇO RETORNO RESPOSTA SAMPLEMED
*/
@RestResource(urlMapping='/ServiceGarantiaProposta/*')
Global with sharing class ServiceGarantiaProposta {
    public ServiceGarantiaProposta() {

    }    
    public Applicants applicants {get;set;} 
    public class Answer {

		
	}
    public class Applicants {
		public Applicant Applicant {get;set;} 
		public Questionnaire Questionnaire {get;set;} 
		public List<Answer> Answer {get;set;} 
		public List<ApplicantsProduct> ApplicantsProduct {get;set;} 
		public List<Answer> Upload {get;set;} 
		public Paging paging {get;set;} 
	}

    public class Questionnaire {
		public String name {get;set;} 
		public String id {get;set;} 
	}

    public class ApplicantsProduct {
		public String capital_id {get;set;} 
		public String status {get;set;} 
		public String value {get;set;} 
		public String id {get;set;} 
		public String applicant_id {get;set;} 
		public String label {get;set;} 
		public String id_on_origin {get;set;}
		public String medical_opinion {get;set;} //PLV-4350 - FIX1 - INICIO/FIM
		public List<Answer> ApplicantsProductsRule {get;set;} 
    }
    
    public class Paging {
		public Integer page {get;set;} 
		public Integer current {get;set;} 
		public Integer count {get;set;} 
		public Boolean prevPage {get;set;} 
		public Boolean nextPage {get;set;} 
		public Integer pageCount {get;set;} 
		public List<Answer> order {get;set;} 
		public Integer limit_Z {get;set;} 
	}

    public class Applicant {
		public String address {get;set;} 
		public String birthday {get;set;} 
		public String broker_agency_name {get;set;} 
		public String city {get;set;} 
		public String codproposal {get;set;} 
		public Object conclusion_questionnaire {get;set;} 
		public String document_value {get;set;} 
		public String created {get;set;} 
		public String email {get;set;} 
		public String id {get;set;} 
		public String marital_status {get;set;} 
		public String name {get;set;} 
		public String neighborhood {get;set;} 
		public String observation {get;set;} 
		public String occupation {get;set;} 
		public String phone1 {get;set;} 
		public String phone2 {get;set;} 
		public String phone3 {get;set;} 
		public String questionnaire_status {get;set;} 
		public String rg_informed {get;set;} 
		public String salary {get;set;} 
		public String sex {get;set;} 
		public String state {get;set;} 
		public String zip {get;set;} 
		public String age {get;set;} 
		public String created_formatted {get;set;} 
		public String finished_date_formatted {get;set;} 
		public String interview_date_formatted {get;set;} 
		public String conclusion_questionnaire_formatted {get;set;} 
		public String birthday_formatted {get;set;} 
		public String first_name {get;set;} 
		public String questionnaire_status_label {get;set;} 
		public Integer score_result {get;set;} 
		public String status_progress {get;set;} 
        public Integer sla_stage {get;set;} 
    }
  
    
    
    public static ServiceGarantiaProposta parse(String json) {
		return (ServiceGarantiaProposta) System.JSON.deserialize(json, ServiceGarantiaProposta.class);
	}


    @HttpPost
    global static void garantiasPropostaLista(){
        Map<String,String> mapDeparaStatusSampleMed = new Map<String,String>{'1'=>'Aprovado','2'=>'Recusado','3'=>'Inconclusivo'};
		Map<String,String> mapStatusProponente = new Map<String,String>{'5'=>'Concluído','6'=>'Expirado','7'=>'Cancelado'};
        system.debug('mapDeparaStatusSampleMed'+mapDeparaStatusSampleMed);

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String json = req.requestBody.toString();
        system.debug('req'+json);
        ServiceGarantiaProposta obj = parse(json);
        String numeroProposta = obj.applicants.Applicant.codproposal;
        system.debug('numeroProposta'+numeroProposta);

        system.debug('objeto deserialize'+obj);
        List<ServiceGarantiaProposta.ApplicantsProduct>listGarantiasPropostas = new List<ServiceGarantiaProposta.ApplicantsProduct>();
		if(obj.applicants.ApplicantsProduct.size() > 0){
			for(ServiceGarantiaProposta.ApplicantsProduct objSampleMed : obj.applicants.ApplicantsProduct){
				//if(mapDeparaStatusSampleMed.containsKey(objSampleMed.status)){
				if(objSampleMed.status != '' || objSampleMed.status != null){
					//objSampleMed.status = mapDeparaStatusSampleMed.get(objSampleMed.status);
					listGarantiasPropostas.add(objSampleMed);
				}
			}
		}else{
			responseRequest('{ "mensagem" : "Não existe Garantias no Json de entradas para serem atualizadas", "total de garantias":"0"}',res);
		}
		
        system.debug('listGarantiasPropostas'+listGarantiasPropostas);
        if(listGarantiasPropostas.size() > 0){
			//PLV-4350-FIX2 - INICIO
			GarantiaPropostaBO objGarantia =  GarantiaPropostaBO.getInstance();
			List<Quote> lProposta = [SELECT 
								Id, Status, StatusProponente__c
								FROM Quote 
								WHERE NumeroPropostaUnico__c =: numeroProposta
							];
			if(lProposta.size() > 0){
				//PLV-4936 INICIO
				String codStatusSampled = obj.applicants.Applicant.questionnaire_status;
				
				String labelStatusSamplemed = obj.applicants.Applicant.questionnaire_status_label != null && obj.applicants.Applicant.questionnaire_status_label != '' ? obj.applicants.Applicant.questionnaire_status_label : codStatusSampled ;

				lProposta[0].StatusProponente__c = mapStatusProponente.containsKey(codStatusSampled) ? mapStatusProponente.get(codStatusSampled) : labelStatusSamplemed;
				update lProposta[0];

				if(codStatusSampled == '5' || labelStatusSamplemed.toLowerCase() == 'completed'){
					objGarantia.atualizaGarantiasProposta(numeroProposta, listGarantiasPropostas);
					responseRequest('{ "mensagem" : "registros atualizados com sucesso", "total de garantias":"'+listGarantiasPropostas.size()+'"}',res);
				}else{
					objGarantia.atualizarCriticaSampleMed(numeroProposta, 'Inconclusiva' );
					responseRequest('{ "mensagem" : "Status do Proponente da Proposta "'+ labelStatusSamplemed +'", garantias das proposta não foram atualizadas. "Proposta":"'+numeroProposta+'"}',res);
				}
				//PLV-4936 FIM
			}else{
				responseRequest('{ "mensagem" : "Proposta não encontrada no Salesforce", "Proposta":"'+numeroProposta+'"}',res);
			}
			//PLV-4350-FIX2 - FIM
			
        }else{
			responseRequest('{ "mensagem" : "Status das garantias enviadas no Json, não existem no salesforce"}',res);
		}		
        
    }


    private static void responseRequest(String msg, RestResponse res) {
        res.addHeader('Content-Type', 'application/json');
        String message = msg;
        res.responseBody = Blob.valueOf(message);
        res.statusCode = 200;
        return;
    }

    
}