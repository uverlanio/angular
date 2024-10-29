/**
 * @author Guilherme Azevedo
 * @date 2020-11-17
 * @description Criada para a história PLV-4365
 */
global class IntegracaoSampleMed {
    //PLV-4365 INICIO

    private static final String responseMockSuccess = '{"errors":[],"success":1,"total":1,"successEntries":[{"ApplicantsProduct":[{"id_on_origin":"AFF","capital_id":1001,"value":10000},{"id_on_origin":"CAN","capital_id":1001,"value":100000},{"id_on_origin":"IPA","capital_id":1001,"value":60000},{"id_on_origin":"BAS","capital_id":1001,"value":60000}],"Applicant":{"birthday":"1994-01-01","__product_group_id":1,"city":"SAO PAULO","sex":2,"__on_demand_applicant_data_hash":"0Q0L0000000Q4xYKAS","state":"SP","codproposal":"18-000287811","questionnaire_id":"4","company_id":"2","id":"70","questionnaire_url":"https://portosegurodev-subauto-questionario.samplemed.com.br?id=4c45311d0c6ae23fa2aaaf8abe1d251ec0ee76257cbd00d46615f829ae1dc46a"}}]}';
    private static final String responseMockFail = '{"errors":[{"ApplicantsProduct":[{"id_on_origin":"AFF","capital_id":1001,"value":10000},{"id_on_origin":"CAN","capital_id":1001,"value":100000},{"id_on_origin":"IPA","capital_id":1001,"value":60000},{"id_on_origin":"BAS","capital_id":1001,"value":60000}],"Applicant":{"birthday":"1994-01-01","__product_group_id":1,"city":"SAO PAULO","sex":2,"__on_demand_applicant_data_hash":"0Q0L0000000Q4xYKAS","state":"SP","codproposal":"18-000287811"},"validationErrors":{"codproposal":["The proposal code must be unique."]}}],"success":0,"total":1,"successEntries":[]}';

    //++++++++++++++++++++++++
    // PUBLIC METHODS
    //++++++++++++++++++++++++

    public static Boolean enviarProposta(Quote proposta, CriticaProposta__c critica, SeguradoProposta__c segurado, FavorecidoRemuneracaoProposta__c favorecido) { //PLV-4644 INICIO/FIM //PLV-4854-FIX2 - INICIO/FIM //PLV-5493 - INICIO/FIM
       
        //PLV-5493 - INICIO
        //get response
        ResponseSampleMed response = IntegracaoSampleMed.getSampleMed(proposta , critica, segurado, favorecido);
        //PLV-5493 - FIM

        if (response != null && response.success != null && response.success > 0) {
            return true;
        }
        //PLV-4644 INICIO
        else if (response != null && response.errors != null && response.errors.size() > 0) {
            //save error
            System.debug('Retorno Integração - Enviar proposta - Erros : ' + JSON.serializePretty(response));
            //notasDeErro.add(new Note(
            //    ParentId = critica.Id,
            //    Body = retorno,
            //    Title = 'Retorno Integração - Enviar proposta - Erros'
            //));
        }
        //PLV-4644 FIM
        else if (response == null || response.total == null && response.SuccessEntries == null && response.success == null && response.errors == null) {
            System.debug('Falha na Integração CIV x SampleMed : ' + JSON.serializePretty(response));
            throw new IntegracaoSampleMedException('Falha na Integração CIV x SampleMed : ' + JSON.serializePretty(response));
        }

        return false;
    }

    //PLV-4644 INICIO
    public static void integrar(Set<Id> criticasIds, Boolean isFuture) {

        if (isFuture) {
            integrarAsync(criticasIds);
        }
        else {
            integrar(criticasIds);
        }
    }

    @future(callout=true) 
    public static void integrarAsync(Set<Id> criticasIds) {
        integrar(criticasIds);
    }

    //@future(callout=true)
    //PLV-4644 FIM
    public static void integrar(Set<Id> criticasIds) {
        List<CriticaProposta__c> criticasToUpdate = new List<CriticaProposta__c>();
        //List<Note> notasDeErro = new List<Note>(); //PLV-4644 INICIO/FIM
        Boolean responseSampleOK = false;
        
        List<Quote> propostas = getPropostasCriticadas(criticasIds); 
        Map<Id, SeguradoProposta__c> seguradoPropostas = getSeguradoProposta(propostas); //PLV-4854-FIX2 - INICIO/FIM
        Map<Id, CriticaProposta__c> criticaByPropostaMap = criticaByPropostaMap(propostas);
        //II-183 - INICIO
        Map<Id, List<FavorecidoRemuneracaoProposta__c>> favorecidoProposta = getFavorecidoRemuneracaoProposta(propostas); //PLV-5493 - INICIO/FIM
        // IntegracaoAS__mdt task = MetadataDAO.getInstance().buscarDadosIntegracaoAS('163');  //PLV-4875 - INICIO/FIM
        system.debug('favorecidoProposta++++++' + favorecidoProposta);
        for (Quote proposta : propostas) {
            CriticaProposta__c critica = criticaByPropostaMap.get(proposta.Id);
            //PLV-5493 - INICIO
            FavorecidoRemuneracaoProposta__c favLider;
            Boolean corretorResposta = false;
            List<FavorecidoRemuneracaoProposta__c> favorecidos = favorecidoProposta.get(proposta.Id);
            system.debug('favorecidos++++++' + favorecidos);
            for(FavorecidoRemuneracaoProposta__c fav : favorecidos){
                system.debug('fav++++++' + fav);
                if(fav.CorretorLider__c){
                    favLider = fav;
                    if(fav.CorretorResponde__c == true){
                        corretorResposta = true;
                        break;
                    }
                }
            }
            if(corretorResposta){
                system.debug('corretorResponde++++++');
                continue;
            }          
            //II-183 - FIM
            //PLV-5493 - FIM
            try { 
                //II-183 - INICIO
                system.debug('entrou try++++++');
                //responseSampleOK = enviarProposta(proposta, critica, seguradoPropostas.get(proposta.Id), favorecidoProposta.get(proposta.Id)); //PLV-4644 INICIO/FIM //PLV-4854-FIX2 - INICIO/FIM //PLV-5493 - INICIO/FIM
                responseSampleOK = enviarProposta(proposta, critica, seguradoPropostas.get(proposta.Id), favLider);
                //II-183 - FIM
                if (responseSampleOK) { 
                    critica.Status__c = 'Em aprovação';
                    // IntegracaoAS.enviarSubscricao(proposta, critica, task); //PLV-4644 INICIO/FIM   //PLV-4875 - INICIO/FIM
                }
                else {
                    //PLV-4631 INICIO
                    critica.Status__c = 'Falha na Integração';
                    //PLV-4631 FIM
                }

                criticasToUpdate.add(critica);
            } catch (Exception ex) {
                System.debug('IntegracaoSampleMed :: integrar : Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString() + ', ' + ex.getLineNumber());

                //PLV-4631 INICIO
                critica.Status__c = 'Falha na Integração';
                //PLV-4631 FIM
                criticasToUpdate.add(critica);

                //PLV-4644 INICIO
                //notasDeErro.add(new Note(
                //    ParentId = critica.Id,
                //    Body = 'IntegracaoSampleMed :: integrar : Exception : ' + ex.getMessage() + ', ' + ex.getStackTraceString() + ', ' + ex.getLineNumber(),
                //    Title = 'Retorno Integração - Subscrição SampleMed Exception'
                //));
                //PLV-4644 FIM
            }
            
        }

        if (criticasToUpdate.size() > 0) {
            update criticasToUpdate;
        } 
        
        //PLV-4644 INICIO
        //if (notasDeErro.size() > 0) {
        //    insert notasDeErro;
        //} 
        //PLV-4644 FIM
    } 

    //++++++++++++++++++++++++
    // PRIVATE METHODS
    //++++++++++++++++++++++++

    private static Map<Id, CriticaProposta__c> criticaByPropostaMap(List<Quote> propostas) {
        Map<Id, CriticaProposta__c> result = new Map<Id, CriticaProposta__c>();

        for (Quote proposta : propostas) {

            for (CriticaProposta__c critica : proposta.CriticasProposta__r) {
                if (!result.containsKey(proposta.Id)) {
                    result.put(proposta.Id, critica);
                }
            }
        }

        return result;
    } 

    private static List<Quote> getPropostasCriticadas(Set<Id> criticasIds) {
        return [
            SELECT Id
                ,AccountId
                ,Account.BillingCity
                ,Account.BillingPostalCode
                ,Account.BillingState
                ,Account.BillingStreet
                ,Account.Cpf__c
                ,Account.PersonBirthdate
                ,Account.PersonEmail
                ,Account.Profissao__c
                ,Account.Profissao__r.Name
                ,Account.Rg__c
                ,Account.Sexo__c 
                ,CodigoCorretor__c
                ,CodigoCorretor__r.Name
                ,Name
                ,Nome_do_contratante__c
                ,NumeroPropostaUnico__c
                ,NumeroProposta__c
                ,OpportunityId
                ,Origem__c
                ,Status
                ,MelhorPeriodoContato__c
                ,(
                    SELECT Id
                        ,Acao__c //INICIO/FIM | PLV-4647-VI-Guilherme Brito
                        ,Status__c
                        ,Proposta__c
                    FROM CriticasProposta__r
                    WHERE Id IN: criticasIds
                )
                ,(
                    SELECT Id
                        ,Garantia__r.Sigla__c
                        ,Capital__c
                    FROM GarantiasProposta__r
                    WHERE TipoGarantia__c = 'Cobertura' //PLV-4790 FIX 7 INICIO/FIM
                )
            FROM Quote
            WHERE Id IN (
                SELECT Proposta__c FROM CriticaProposta__c 
                WHERE Id IN: criticasIds
            )
        ];
    }
    
    //PLV-4854-FIX2 - INICIO
    public static Map<Id, SeguradoProposta__c> getSeguradoProposta(List<Quote> propostas) {

        Map<Id, SeguradoProposta__c> mSegurado = new Map<Id, SeguradoProposta__c>();

        for (SeguradoProposta__c segP : [SELECT Id
                                            ,Profissao__r.Codigo__c
                                            ,GrupoProposta__r.ContratanteProposta__r.Proposta__c
                                        FROM SeguradoProposta__c
                                        WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c IN: propostas]) {

            mSegurado.put(segP.GrupoProposta__r.ContratanteProposta__r.Proposta__c, segP);
        }
        return mSegurado;
    }
    //PLV-4854-FIX2 - FIM

    //PLV-5493 - INICIO
    //-183 INICIO
    public static Map<Id, List<FavorecidoRemuneracaoProposta__c> > getFavorecidoRemuneracaoProposta(List<Quote> propostas){
        String tipoRemuneracao = 'CORRETAGEM';
		system.debug('PRO+++' + propostas);
        Map<Id, List<FavorecidoRemuneracaoProposta__c>> mFavorecidoRemuneracaoProposta = new Map<Id, List<FavorecidoRemuneracaoProposta__c>>();

        for (FavorecidoRemuneracaoProposta__c favP : [SELECT Id,CorretorResponde__c, RemuneracaoProposta__r.Proposta__c, CorretorLider__c  
                                                        FROM FavorecidoRemuneracaoProposta__c 
                                                        WHERE RemuneracaoProposta__r.TipoRemuneracao__r.Name =:tipoRemuneracao AND RemuneracaoProposta__r.Proposta__c IN: propostas]) {

            if (!mFavorecidoRemuneracaoProposta.containsKey(favP.RemuneracaoProposta__r.Proposta__c)) {
                mFavorecidoRemuneracaoProposta.put(favP.RemuneracaoProposta__r.Proposta__c, new List<FavorecidoRemuneracaoProposta__c>());
            }
            mFavorecidoRemuneracaoProposta.get(favP.RemuneracaoProposta__r.Proposta__c).add(favP);
        }        
        system.debug('MapProposta+++++' + mFavorecidoRemuneracaoProposta);
        return mFavorecidoRemuneracaoProposta;
    }
    //-183 INICIO
    //PLV-5493 - FIM



    private static String getMock(CriticaProposta__c critica) {

        // INICIO | PLV-4647-VI-Guilherme Brito
        if (critica.Acao__c == 'auto') {
            return responseMockSuccess;
        }
         //FIM| PLV-4647-VI-Guilherme Brito */

        return responseMockFail;
    }

    //PLV-5493 - INICIO

    public static ResponseSampleMed getSampleMed(Quote proposta, CriticaProposta__c critica, SeguradoProposta__c segurado, FavorecidoRemuneracaoProposta__c favorecido){
        Boolean result = false;
        RequestSampleMed request = new RequestSampleMed();

        //build payload
        // INICIO | PLV-4647-VI-Guilherme Brito
        request.tipoSubscricao = critica.Acao__c;
        request.body = new Body(proposta, critica.Acao__c, segurado, favorecido); //PLV-4854-FIX2 - INICIO/FIM //PLV-5493 - INICIO/FIM
        //FIM| PLV-4647-VI-Guilherme Brito */

        String requestJson = JSON.serializePretty(request, true).replaceAll('x_','__'); 
        System.debug('IntegracaoSampleMed :: enviarProposta : requestJson ' + requestJson);
        
        //send request
        String retorno = Test.isRunningTest() ? getMock(critica) : SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.AWS_EXTERNO, SensediaServices.INTEGRACAO_SAMPLEMED, requestJson).replaceAll('__', 'x_');//MGRC-1276 - INICIO/FIM

        //get response
        ResponseSampleMed response = (ResponseSampleMed) JSON.deserialize(retorno, ResponseSampleMed.class);
        System.debug('IntegracaoSampleMed :: enviarProposta : response ' + JSON.serialize(response));

        //FNPVVEP-98 - INICIO
        if(!response.SuccessEntries.isEmpty() || response.SuccessEntries != null){
            for (SuccessEntries entry : response.SuccessEntries) {
                if (entry.Applicant != null) {
                    proposta.Link_Questionario_Samplemed__c = (entry.Applicant.questionnaire_url != null && String.isNotBlank(entry.Applicant.questionnaire_url)) ?  entry.Applicant.questionnaire_url : '';
                    proposta.Id_do_Proponente__c = (entry.Applicant.id != null && String.isNotBlank(entry.Applicant.id)) ?  entry.Applicant.id : '';
                    proposta.Hora_Expiracao_Link__c = Datetime.now().addHours(-3); //FNPVVEP-98 - INICIO/FIM - FIX02
                }
            }
        }
 
        if(proposta.Link_Questionario_Samplemed__c != '' && proposta.Id_do_Proponente__c != '') update proposta;
        //FNPVVEP-98 - FIM

        return response;
    }

    //PLV-5493 - FIM

    public class IntegracaoSampleMedException extends Exception {}

    //++++++++++++++++++++++++
    // ENTITY CLASSES
    //++++++++++++++++++++++++

    public class RequestSampleMed {

        public String tipoSubscricao;
        public Body body;

        public RequestSampleMed() {}
    }

    public class ResponseSampleMed {

        public List<Error> errors; 
        public Integer success; 
        public Integer total; 
        public List<SuccessEntries> SuccessEntries; 
    }

    public class SuccessEntries {

        public List<ApplicantsProduct> ApplicantsProduct; 
		public Applicant Applicant; 
    }

    public class Error {

		public List<ApplicantsProduct> ApplicantsProduct; 
		public Applicant Applicant; 
		public ValidationErrors ValidationErrors; 
	}
	
	public class ValidationErrors {

		public List<String> codproposal; 
	}
    
    public class Body {

        public Applicant Applicant;
        public Conjuge Conjuge;
        public List<ApplicantsProduct> ApplicantsProduct;
        public List<ApplicantsPhone> ApplicantsPhone;
        
        public Body(Quote proposta, String tipoSubscricao, SeguradoProposta__c segurado, FavorecidoRemuneracaoProposta__c favorecido) { //PLV-4854-FIX2 - INICIO/FIM //PLV-5493 - INICIO/FIM

            this.applicant = new Applicant(); 
            //PLV-4916 INICIO   
            if (tipoSubscricao == 'auto') {
                this.ApplicantsProduct = new List<ApplicantsProduct>(); //PLV-4958-INICIO/FIM
            }else{
                this.Applicant.ApplicantsProduct = new List<ApplicantsProduct>();//PLV-4958-INICIO/FIM
            }   
            //PLV-4916 FIM 
           
            
            this.applicant.codproposal = proposta.NumeroPropostaUnico__c;
            this.applicant.occupation = (segurado.Profissao__r.Codigo__c != null) ? segurado.Profissao__r.Codigo__c : ''; //PLV-4854-FIX2 - INICIO/FIM

            if (proposta.AccountId != null) {
                //PLV-4790 FIX 6 FIM
                if (proposta.Account.PersonBirthdate != null) {
                    Date birthDay = proposta.Account.PersonBirthdate;
                    //PLV-5154 INICIO
                    // String birthDayStr = DateTime.newInstance(birthDay.year(), birthDay.month(), birthDay.day()).format('dd-MM-YYYY');
                    String birthDayStr = DateTime.newInstance(birthDay.year(), birthDay.month(), birthDay.day()).format('dd-MM-yyyy');
                    //PLV-5154 FIM
                    this.applicant.birthday = birthDayStr;
                }
                //PLV-4790 FIX 6 FIM
                this.applicant.city = proposta.Account.BillingCity;
                this.applicant.state = proposta.Account.BillingState;
                //PLV-4853 INICIO
                String sex = proposta.Account.Sexo__c.toLowerCase();
                this.applicant.sex = sex == 'masculino' || sex == 'masc'  ? 2 : 1;
                //PLV-4853 FIM
                //this.applicant.sex = proposta.Account.Sexo__c == 'Masculino' ? 2 : 1; // PLV-4869 Fix 4 //PLV-4853 INICIO/FIM - LINHA COMENTADA
            }

            if (tipoSubscricao == 'auto') {

                this.applicant.return_url = null;
                //this.applicant.x_product_group_id = 1; //Envio padrão, sem definição SampleMed //PLV-4790 FIX 6 INICIO/FIM
                this.applicant.x_on_demand_applicant_data_hash = proposta.Id;
            }
            else if (tipoSubscricao == 'tele' || tipoSubscricao == 'video') {
                

                //this.applicant.shift = proposta.MelhorPeriodoContato__c; PLV-4853 INICIO/ FIM LINHA COMENTADA
                // //PLV-4853 INICIO
                this.applicant.priority = 0;
                this.applicant.x_use_video_interview = tipoSubscricao == 'tele' ? 0 : 1;
                // //PLV-4853 FIM
                
                // this.applicantsPhone = new List<ApplicantsPhone>();
                
                //!* Todos os dados fora o shift ainda estão pendentes de definição da SampleMed
                //!* Por hora a definição é de enviar somente o shift para tele/video alem dos atributos genéricos

                //if (proposta.AccountId != null) {
                    // this.applicant.address = proposta.Account.BillingStreet;
                    // this.applicant.cpf_informed = proposta.Account.Cpf__c;
                    // this.applicant.email = proposta.Account.PersonEmail;
                    // this.applicant.occupation = proposta.Account.Profissao__c != null ? proposta.Account.Profissao__r.Name : '';
                    // this.applicant.rg_informed = proposta.Account.Rg__c;
                    // this.applicant.zip = proposta.Account.BillingPostalCode;
                //}

                // this.applicant.broker_agency_name = proposta.CodigoCorretor__c != null ? proposta.CodigoCorretor__r.Name : null;
                // this.applicant.marital_status = 1; 
                // this.applicant.name = proposta.Nome_do_contratante__c;
                // this.applicant.neighborhood = '';  
                // this.applicant.observation = ''; 
                // this.applicant.salary = null; 

                //TODO : PENDENTE DE DEFINIÇÃO Preencher Applicants Phone
                //TODO : PENDENTE DE DEFINIÇÃO Preencher Conjuge
            }
            
            
            for (GarantiaProposta__c garantia : proposta.GarantiasProposta__r) {
                //PLV-4916 INICIO
                //CHM-8001986 - Devido não ter acionado a Samplemed para cadastro da garantia AFP, todas as propostas com essa garantia está gerando problemas na integração e por isso não estamos enviando a mesma para a Samplemed de forma paliativa.
                //CHM-8001986 FIX01 - Remoçao da solução paliativa
                //CHM-8001986 INICIO FIX01
                if(tipoSubscricao == 'tele' || tipoSubscricao == 'video'){
                    this.applicant.ApplicantsProduct.add(new ApplicantsProduct(garantia));//PLV-4958-INICIO/FIM
                }else{
                    this.ApplicantsProduct.add(new ApplicantsProduct(garantia));//PLV-4958-INICIO/FIM
                }
                //CHM-8001986 FIM FIX01
                //PLV-4916 INICIO
            }
            
            this.applicant.is_filled_by_broker = favorecido.CorretorResponde__c == false ? 0 : 1; //PLV-5493 - INICIO/FIM
        }
    }	
	
    public class ApplicantsProduct {
	
        public Integer capital_id; 
		public Decimal value;
        public String id_on_origin; 
        
        public ApplicantsProduct(GarantiaProposta__c garantia) {
            //this.capital_id = 1001; //PLV-4790 FIX 6 INICIO/FIM
            this.value = garantia.Capital__c;
            this.id_on_origin = garantia.Garantia__r.Sigla__c; 
        }
    }

	public class Applicant {
		
        public String address; 
		public String birthday; 
		public String broker_agency_name; 
		public String city; 
		public String codproposal; 
		public String cpf_informed; 
		public String document_value; 
		public String email; 
		public Integer marital_status; 
		public String name; 
		public String neighborhood; 
		public String observation; 
		public String occupation; 
		public String phone1; 
		public String phone2; 
		public String phone3; 
		public String rg_informed; 
		public String return_url; 
		public Double salary; 
		public Integer sex; 
		public String state; 
		public String zip; 
        public String shift;
		public Integer x_product_group_id; // in json: __product_group_id
        public String x_on_demand_applicant_data_hash; // in json: __on_demand_applicant_data_hash 
        public String questionnaire_url;
        public String id;
        public String questionnaire_id;
        public String company_id;
        //PLV-4853 INICIO
        public Integer priority;
        public Integer x_use_video_interview; // in json: __use_video_interview
        //PLV-4853 FIM
        public List<ApplicantsProduct> ApplicantsProduct; //PLV-4916 INICIO/FIM //PLV-4958-INICIO/FIM
        public Integer is_filled_by_broker; //PLV-5493 - INICIO/FIM
    }
    
    public class ApplicantsPhone {

        public Integer country_code;
        public String phone;
    }

    public class Conjuge {

        public String birthday;
        public String cpf_informed;
        public String email;
        public String name;
        public String observation;
        public String occupation;
        public String rg_informed;
        public Double salary;
        public Integer sex;

        public List<ApplicantsProduct> ApplicantsProduct;//PLV-4958-INICIO/FIM
        public List<ApplicantsPhone> ApplicantsPhone;//PLV-4958-INICIO/FIM
    }
    //PLV-4365 FIM
}