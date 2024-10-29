/*
* Classe consulta de contratos para sistemas externos
* @author Squad Globant
* @date 24/02/23
* Classe criada por conta da história PLV-5775
*/

global class ContractService {

    static final String ERROR_MESSAGE_TO_CODE_0 = 'Consulta efetuada com sucesso';
    static final Integer CODE_ERROR_0 = 0;

    static final String STATUS_CTR_ATIVO = 'Emitido';
    static final String STATUS_CTR_CANCELADO = 'Cancelado';
    static final String STATUS_CTR_ALTERADO = 'Alterado';

    //II-98 FIX01 INICIO
    static final String TIPO_CTR_NOVO = 'Novo';
    static final String TIPO_CTR_CANCELADO = 'Cancelamento';
    static final String TIPO_CTR_ALTERADO = 'Endosso';
    //II-98 FIX01 FIM
    
    static final String CONTRACT = 'contract';
    static final String ASSURANCE = 'assurance';

    global class Request {
		global String nome;
		global String dataNascimento;
		global String cpf;
		global String cnpj;
		global String assistencia;

        global Request(RestRequest req){}

        global Boolean isValid()
        {
            return (String.isNotBlank(this.cpf) && String.isNotBlank(this.assistencia)) ? true : false;
        }
	}

    global class Response {
        global List<ListaSegurosTO> listaSeguros    {get; set;}	
        global Integer codErro 						{get; set;}	
        global String descricaoErro 				{get; set;}

        public void setErrorMessage(Integer codeErro, String msg){
            this.listaSeguros = new List<ListaSegurosTO>();
            this.codErro = codeErro;
            this.descricaoErro = msg;
        }
    }

    global class DadosSeguroTO {
        global String apolice 					    {get; set;}
		global String dataEmissao 				    {get; set;}
		global Integer status 					    {get; set;}
		global Decimal valorImportanciaSegurada     {get; set;}
		global Integer origemProposta 			    {get; set;}
		global Integer numeroProposta 			    {get; set;}
		global String produto 					    {get; set;}
		global String vigenciaInicial 			    {get; set;}
		global String vigenciaFinal  				{get; set;}  
        global String codPlano  				    {get; set;} //II-98 INICIO-FIM
        global String dataCancelamento  				    {get; set;} //VIAG-230
    }
    
    global class DadosSeguradoTO {
        global String cpf                    	    {get; set;}
		global String dataNascimento      		    {get; set;}
		global String nome 						    {get; set;}
        global String nomeSocial 					{get; set;} //LECVPV - 198 - INICIO/FIM
		global Integer numeroDigitoSegurado 	    {get; set;}
    }

    global class ListaSegurosTO {
        global DadosSeguradoTO dadosSegurado        {get; set;}
        global DadosSeguroTO dadosSeguro            {get; set;}
        ///II-76 INICIO
        //global EstipulanteTO estipulanteTO          {get; set;} 
        //global EstipulanteTO dadosVidaGrupo         {get; set;}
        ///II-76 FIM
        global List<EstipulanteTO> beneficiarios    {get; set;}
    }

	global class EstipulanteTO {}

    public static Response createResponse(
        Map<Id, SeguradoContrato__c> insuredMap,
        Map<Id, Map<String, Sobject>> assuranceAndContractByInsuredMap
    ){

        List<ListaSegurosTO> assuranceList = new List<ListaSegurosTO>();

        for(Id insuredId : assuranceAndContractByInsuredMap.keySet())
        {

            SeguradoContrato__c insured = insuredMap?.get(insuredId);

            Contract contract = (Contract) assuranceAndContractByInsuredMap.get(insuredId).get(CONTRACT);

            GarantiaContrato__c assurance = (GarantiaContrato__c) assuranceAndContractByInsuredMap?.get(insuredId)?.get(ASSURANCE);

            ListaSegurosTO assuranceResponse = new ListaSegurosTO();

            assuranceResponse.dadosSegurado = getDadosSegurado(insured);
            if(assurance != null )
            {
                assuranceResponse.dadosSeguro = getDadosSeguro(assurance);
            }
            ///II-76 INICIO
            //assuranceResponse.estipulanteTO = new EstipulanteTO(); 
            //assuranceResponse.dadosVidaGrupo = new EstipulanteTO();
            ///II-76 FIM
            assuranceResponse.beneficiarios = new List<EstipulanteTO>();
            //II-87 INICIO
            if(assuranceResponse.dadosSeguro != null){
                assuranceList.add(assuranceResponse);
            }
            //assuranceList.add(assuranceResponse);
            //II-87 FIM
        }
        
        Response response = new Response();

        response.codErro = CODE_ERROR_0;
        response.descricaoErro = ERROR_MESSAGE_TO_CODE_0;
        response.listaSeguros = assuranceList;


        return response;
    }

    public static DadosSeguradoTO getDadosSegurado(SeguradoContrato__c insured){

        DadosSeguradoTO segurado = new DadosSeguradoTO();

        segurado.cpf = insured.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Cpf__c.replace('.','').replace('-','');
        segurado.dataNascimento = formatarData(insured.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.PersonBirthdate);
        
        segurado.nome = insured.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Name;
        segurado.nomeSocial = insured.GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.NomeSocial__c; //LECVPV - 198 - INICIO/FIM
        segurado.numeroDigitoSegurado =  0;

        return segurado;
    }

    public static DadosSeguroTO getDadosSeguro(GarantiaContrato__c assurance){

        DadosSeguroTO seguro = new DadosSeguroTO();

        seguro.apolice = assurance.Contrato__r.NumeroApolice__c;
        seguro.dataEmissao = formatarData(assurance.Contrato__r.DataEmissao__c);
        //II-98 FIX01 INICIO
        System.debug('assurance.Contrato__r.Status >>> ' + assurance.Contrato__r.Tipo__c);
        if(assurance.Contrato__r.Tipo__c == TIPO_CTR_NOVO)
        {
            seguro.Status = 0;
        }else if (assurance.Contrato__r.Tipo__c == TIPO_CTR_CANCELADO || assurance.Contrato__r.Tipo__c == TIPO_CTR_ALTERADO)
        {
            seguro.Status = 1;
            seguro.dataCancelamento = formatarData(assurance.Contrato__r.DataEmissao__c); //VIAG-230
        }
        // if(assurance.Contrato__r.Status == STATUS_CTR_ATIVO)
        // {
        //     seguro.Status = 0;
        // }else if (assurance.Contrato__r.Status == STATUS_CTR_CANCELADO || assurance.Contrato__r.Status == STATUS_CTR_ALTERADO)
        // {
        //     seguro.Status = 1;
        // }
        //II-98 FIX01 FIM

        seguro.valorImportanciaSegurada = assurance.Capital__c != null ? assurance.Capital__c : 0;
        seguro.origemProposta = Integer.valueOf(assurance.Contrato__r.Origem__c);
        seguro.numeroProposta = Integer.valueOf(assurance.Contrato__r.NumeroProposta__c);
        seguro.produto = assurance.Contrato__r.Produto__r.Name;
        seguro.vigenciaInicial = formatarData(assurance.Contrato__r.StartDate);
        seguro.vigenciaFinal = formatarData(assurance.Contrato__r.VigenciaFinal__c);
        seguro.codPlano = assurance.Garantia__r.Sigla__c; //II-98 INICIO-FIM

        return seguro;
    }

    // public static Map<Id, SeguradoContrato__c> getInsuredMap(String name, String cpf){ PLV-5775 - FIX01 - INICIO/FIM
    public static Map<Id, SeguradoContrato__c> getInsuredMap(String cpf){ // PLV-5775 - FIX01 - INICIO/FIM

        Map<Id, SeguradoContrato__c> insuredMap = new Map<Id, SeguradoContrato__c>();

        // PLV-5775 - FIX01 - INICIO
        List<SeguradoContrato__c> seguradosCtr = [SELECT
                                                      GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Cpf__c
                                                    , GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.PersonBirthdate
                                                    , GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Name
                                                    , GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.NomeSocial__c //LECVPV - 198 - INICIO/FIM
                                                    , GrupoContrato__r.ContratanteContrato__r.Contrato__c
                                                  FROM SeguradoContrato__c
                                                  WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Cpf__c =: cpf];
                                                // WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Name =: name
                                                // AND GrupoContrato__r.ContratanteContrato__r.Contrato__r.Account.Cpf__c =: cpf];
        // PLV-5775 - FIX01 - FIM                                        

        for(SeguradoContrato__c sc : seguradosCtr){
            insuredMap.put(sc.Id, sc);
        }                                 

        return insuredMap;
    }

    public static Map<Id, GarantiaContrato__c> getAssuranceMap(Map<Id, Contract> contractMappedByInsured, String assistencia){

        Map<Id, GarantiaContrato__c> assuranceMap = new Map<Id, GarantiaContrato__c>();

        List<GarantiaContrato__c> garantiasContrato =[SELECT 
                                                          Capital__c
                                                        , Contrato__r.NumeroApolice__c
                                                        , Contrato__r.DataEmissao__c
                                                        , Contrato__r.Status
                                                        , Contrato__r.Origem__c
                                                        , Contrato__r.NumeroProposta__c
                                                        , Contrato__r.Produto__r.Name
                                                        , Contrato__r.StartDate
                                                        , Contrato__r.VigenciaFinal__c
                                                        , Contrato__c
                                                        , Contrato__r.Tipo__c //II-98 FIX01 INICIO-FIM
                                                        , Garantia__r.Sigla__c //II-98 INICIO-FIM
                                                     FROM GarantiaContrato__c 
                                                     WHERE Contrato__c IN : new Map<Id, Contract>(contractMappedByInsured.values()).keySet() 
                                                     AND GarantiaProduto__r.SiglaGarantia__c =: assistencia
                                                     AND Contrato__r.VigenciaFinal__c > TODAY //II-98 FIX01 INICIO-FIM
                                                     AND Contrato__r.StartDate <= TODAY]; //VIAG-200 FIX01 INICIO-FIM

        for(GarantiaContrato__c gc : garantiasContrato)
        {
            //PLV-5775-FIX01 - INICIO
            if(!assuranceMap.containsKey(gc.Id))
            {
                assuranceMap.put(gc.Id, gc);
            }
            //PLV-5775-FIX01 - FIM
        }                                 

        return assuranceMap;
    }

    public static Map<Id, Map<String, Sobject>> getGrtAndCtrByInsuredMap(
        Map<Id, Contract> contractMappedByInsured, Map<Id, GarantiaContrato__c> assuranceMappedByContract
    ){
        Map<Id, Map<String, SObject>> result = new Map<Id, Map<String, SObject>>();

        for(Id insuredId : contractMappedByInsured.keySet()){

            if(!result.containsKey(insuredId))
                result.put(
                    insuredId, 
                    new Map<String, SObject>()
                );

            Contract contract = contractMappedByInsured.get(insuredId);

            GarantiaContrato__c assurance = assuranceMappedByContract?.get(contract.Id);
            result.get(insuredId).put('contract', contract);
            result.get(insuredId).put('assurance', assurance);
        }

        return result;
    }

    private static String formatarData(Date data){
        return data != null ? DateTime.newInstance(data.year(),data.month(),data.day()).format('dd/MM/yyyy') : null; //VIAG-200 INICIO-FIM
    }
}