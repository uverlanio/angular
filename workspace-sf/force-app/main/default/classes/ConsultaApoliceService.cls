/*******************************************************************************************************************************
* Consulta dados Básicos de Apólice/Contrato
* @author Isabela - Globant
* @date 28/04/2020
* @modifiedAt 01/04/2020
* Classe criada por conta da história PLV-3719
******************************************************************************************************************************/
public with sharing class ConsultaApoliceService {
    @TestVisible private static public_arquivoecm__x[] listMockedRequest = new public_arquivoecm__x[]{}; //PLV-3745 - INICIO/FIM
    private ConsultaApoliceREST.ConsultaParam param;
    public static Map<Id, CondicaoCobranca__c> condicaoCobrancaByFormaPagamento; //PLV-4758 FIX 1 INICIO/FIM

    //Resgatar parâmetros de pesquisa enviados pelo método consultar()
    public ConsultaApoliceService(ConsultaApoliceREST.ConsultaParam param) {
        this.param = param;
    }
	
    //PLV-3745 - INICIO
    public ConsultaApoliceREST.DataTO consultar(){

        //PLV-4286 - INICIO
        Set<Id> idApoliceContrato = new Set<Id>();
        List<Contract> contratosApolices = this.getContracts();
        System.debug('contratosApolices >><<' + contratosApolices);
        List<BeneficiarioSeguradoContrato__c> beneficiariosContratoApolice = new List<BeneficiarioSeguradoContrato__c>();

        for(Contract contractApolice : contratosApolices){
            idApoliceContrato.add(contractApolice.Id);
        }
        //LECVPV-177 - ajuste na query INICIO/FIM
        for(BeneficiarioSeguradoContrato__c beneficiario: [SELECT Id, Nome__c, NomeSocial__c, Data_de_Nascimento__c,
            TipoBeneficiario__c, GrauParentesco__c, PercentualIndenizacao__c, CpfCnpj__c,
            SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c
            FROM BeneficiarioSeguradoContrato__c WHERE 
            SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c IN: idApoliceContrato])
        {
            beneficiariosContratoApolice.add(beneficiario);
        }    
        System.debug('beneficiariosContratoApolice >><<' + beneficiariosContratoApolice);
        //PLV-4286 - FIM
		
        ConsultaApoliceRest.DataTO resposta =  new ConsultaApoliceRest.DataTO();
        //PLV-4376 - FIX - INICIO
        Boolean retornarSegurado;
        retornarSegurado = String.isNotBlank(this.param.cpf) && String.isNotBlank(this.param.susep) ? true : false;
        //PLV-4376 - FIX - INICIO
        //PLV-4343-FIX INICIO
        Map<Id, Account> mapAccountContract = new Map<Id, Account>();
        List<Id> listIdAccount = new List<Id>();
        
        for(Contract contrato : contratosApolices){ //PLV-4286    
            listIdAccount.add(contrato.AccountId);
        }
        // PLV-4553 - AJUSTE NA QUERY
        //MGRC-488 INICIO
        //LECVPV-177 - ajuste na query INICIO/FIM
        for(Account contaSegurado : [SELECT Id, Cpf__c, Name, NomeSocial__c, Fumante__c, Profissao__r.Name, RegimeTrabalho__c, PersonBirthdate, Sexo__c, PersonEmail, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,DataExpedicao__c,EstadoCivil__c  FROM Account WHERE Id IN: listIdAccount]){
            mapAccountContract.put(contaSegurado.Id, contaSegurado);    
        }
        System.debug('mapAccountContract >><<' + mapAccountContract);
        //MGRC-488 FIM
        //PLV-4343-FIX FIM        

		//PLV - 4653 Inicio
		List<Id> propostasList = new List<Id>();		
        for(Contract contrato : contratosApolices){ //PLV-4286            
			propostasList.add(contrato.Proposta__c);
		}

		Map<Id, RemuneracaoProposta__c> remuneracaoPropostasMap = new Map<Id, RemuneracaoProposta__c>([Select Id, Name, Papel__c, Participacao__c, Percentual__c, Porcentagem_de_Retencao__c, Proposta__c, RemuneracaoProduto__c, SystemModstamp, TipoRemuneracao__c, TipoRemuneracao__r.Name FROM RemuneracaoProposta__c where Proposta__c in : propostasList and TipoRemuneracao__r.Name = 'CORRETAGEM' ]);
		//PLV - 4653 Fim
        
        //PLV-4758 FIX 3 INICIO
        Map<String, SeguradoContrato__c> seguradoContratoMap = getSeguradoContratoMap(contratosApolices);
        //PLV-4758 FIX 3 FIM

        // CH-5802153 - INICIO
        List<String> contratantesIds = new List<String>();
        for(Contract contrato : contratosApolices){
            for(ContratanteContrato__c contratante: contrato.ContratantesContrato__r){
                contratantesIds.add(contratante.Contrato__c + '_' +  contratante.Id);
            }
        }

        Map<String, List<public_parcelacontrato__x>> parcelasContratosMap = getParcelasContratosMap(contratantesIds);
        // CH-5802153 - FIM

        for(Contract contrato : contratosApolices) { //PLV-4286           
            //Preenchendo dados da apólice pelo construtor
            ConsultaApoliceREST.ApoliceConsultaTO apolice = new ConsultaApoliceREST.ApoliceConsultaTO(contrato);
            
            //PLV-4376 - FIX - INICIO
            if(retornarSegurado){
                system.debug('4376 - retornarSegurado: ' + retornarSegurado);
                if(this.param.mapContratosDoSegurado.get(contrato.Id) != null)
                    apolice.addDadosContratante(this.param.mapContratosDoSegurado.get(contrato.Id));                
            }else{
                // PLV-4343-FIX INICIO
                //Preenchendo dados do contratante e adicionando à apólice resposta do serviço
                // for(ContratanteContrato__c contratante: contrato.ContratantesContrato__r){
                //     apolice.addDadosContratante(contratante);
                // }
                
                //PLV-4758 FIX 3 INICIO Extraido a query de segurados do loop na ConsultaApoliceREST.ApoliceConsultaTO.addDadosContratante e mapeado os segurados por contrato @ cpf
                SeguradoContrato__c segurado;
                if (mapAccountContract.containsKey(contrato.AccountId) && mapAccountContract.get(contrato.AccountId).Cpf__c != null
                    && seguradoContratoMap.containsKey(contrato.Id + '@' + mapAccountContract.get(contrato.AccountId).Cpf__c)) {
                    System.debug('entrou if 107 >><<');    
                    segurado = seguradoContratoMap.get(contrato.Id + '@' + mapAccountContract.get(contrato.AccountId).Cpf__c);
                }
                apolice.addDadosContratante(mapAccountContract.get(contrato.AccountId), segurado);
                System.debug('apolice >><<' + apolice);
                //PLV-4758 FIX 3 FIM
                // PLV-4343-FIX FIM
            }
            //PLV-4376 - FIX - FIM

            //Preenchendo dados da garantia do contrato e adicionando à apólice resposta do serviço
            for(GarantiaContrato__c garantia : contrato.GarantiasContrato__r){
                apolice.addDadosGarantia(garantia);         
            }  
			 
			//PLV - 4653 Inicio
			if(contrato.Proposta__c != null){
				for(RemuneracaoProposta__c remProposta : remuneracaoPropostasMap.values()){					
					System.debug('remProposta. Proposta__c = '+ remProposta.Proposta__c);
					if(contrato.Proposta__c == remProposta.Proposta__c){
						apolice.percentualPropostaCorretagem = remProposta.Percentual__c;	
					}
					         
				}
			}			
			//PLV - 4653 Fim
			           
			//PLV-4255 - INICIO - Pegando o percentual de comissão e o tipo remuneração do corretor 
            for(RemuneracaoContrato__c remContrato : contrato.RemuneracoesContrato__r){
                //PLV 4653 Inicio
				if(remContrato.TipoRemuneracao__r.Name == 'AGENCIAMENTO'){
					apolice.percentualPropostaAgenciamento = remContrato.Percentual__c;	
				}				
				apolice.addDadosRemuneracao(remContrato);
				//PLV 4653 Fim 				        
            }                 
            //PLV-4255 - FIM			

            //PLV-4286 - INICIO
            for(BeneficiarioSeguradoContrato__c beneficiarioFinalApolice : beneficiariosContratoApolice){
                if(beneficiarioFinalApolice.SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c == contrato.Id){
                    apolice.addDadosBeneficiarios(beneficiarioFinalApolice);
                }                
            }            
            //PLV-4758 FIX 2 INICIO          
            ParcelamentoContratoTO retornoParcelas = new ParcelamentoContratoTO();
            retornoParcelas.data = new List<ParcelamentoContratoTO.DataTO>();

            // CH-5802153 - INICIO
            /*
            //PLV-4949 FIX 1 - INÍCIO
            List<String> contratantesIds = new List<String>();
            Map<String,public_parcelacontrato__x> mapParcelasContrato = new  Map<String,public_parcelacontrato__x>();

            for(ContratanteContrato__c contratante: contrato.ContratantesContrato__r){
                contratantesIds.add(contratante.Contrato__c + '_' +  contratante.Id);
            }

            List<public_parcelacontrato__x> parcelas = [ 
                SELECT  
                //PLV-4949 FIX 4 - INÍCIO
                id__c, 
                datavencimento__c,
                numeroparcela__c, 
                valoriof__c, 
                valorliquido__c, 
                idfatura__c, 
                idexterno__c, 
                status__c, 
                valorparcela__c 
                FROM public_parcelacontrato__x WHERE idexterno__c IN :contratantesIds
                //PLV-4949 FIX 4 - FIM
            ];
            
            for(public_parcelacontrato__x parcela : parcelas){
                mapParcelasContrato.put(parcela.idexterno__c, parcela);
            }*/
            // CH-5802153 - FIM

            for(ContratanteContrato__c contratante: contrato.ContratantesContrato__r){ 
                
                String chave = contratante.Contrato__c + '_' +  contratante.Id;
                System.debug('chave >><<' + chave);
                System.debug('parcelasContratosMap >><<' + parcelasContratosMap);
                if(!Test.isRunningTest()){

                    // CH-5802153 - INICIO
                    /*List<public_parcelacontrato__x> parcelasTemp = new List<public_parcelacontrato__x>();
                    
                    for(public_parcelacontrato__x parcelaContrato : mapParcelasContrato.values()){
                        if(parcelaContrato.idexterno__c == chave ){
                            parcelasTemp.add(parcelaContrato);
                        }
                    }
                    retornoParcelas = ParcelamentoContratoTO.DTOParcelaContrato(parcelasTemp);
                    */
                    System.debug('retorno de Parcelas: ' + parcelasContratosMap.get(chave));

                    retornoParcelas = ParcelamentoContratoTO.DTOParcelaContrato(parcelasContratosMap.get(chave));
                    
                    // CH-5802153 - FIM
                    
                    //retornoParcelas = HerokuService.getInstance().consultarParcelasContrato(chave);
                    //PLV-4949 FIX 1 - FIM
                    //retornoParcelas = ContractFacade.getInstance().ObterParcelasContratoSegurado(contratante.Id);               
                } else {
                    String payloadTest = '{"meta":{"statusHttp":200,"servico":"Buscar parcelas do contrato por segurado ou vida","mensagem":"OK","dataExecucao":"2021-01-13T14:36:16.381Z"},"data":[{"vidasalesforce":null,"valorparcela":"11.62","valorliquido":"11.53","valoriof":"0.09","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":1,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113847,"endosso":"0","empresa":"1","datavencimento":"2021-01-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-10T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":2,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113848,"endosso":"0","empresa":"1","datavencimento":"2021-02-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-10T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":3,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113849,"endosso":"0","empresa":"1","datavencimento":"2021-03-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-10T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"PAGA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":4,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113850,"endosso":"0","empresa":"1","datavencimento":"2021-04-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":"2021-01-09T00:00:00.000Z","contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":5,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113851,"endosso":"0","empresa":"1","datavencimento":"2021-05-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":6,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113852,"endosso":"0","empresa":"1","datavencimento":"2021-06-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":7,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113853,"endosso":"0","empresa":"1","datavencimento":"2021-07-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":8,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113854,"endosso":"0","empresa":"1","datavencimento":"2021-08-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":9,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113855,"endosso":"0","empresa":"1","datavencimento":"2021-09-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":10,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113856,"endosso":"0","empresa":"1","datavencimento":"2021-10-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":11,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113857,"endosso":"0","empresa":"1","datavencimento":"2021-11-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"},{"vidasalesforce":null,"valorparcela":"11.53","valorliquido":"11.49","valoriof":"0.04","titulo":"","sucursal":"1","status":"CANCELADA","seguradosalesforce":"a0fL0000007X0ugIAC","responsavelfinanceiro":"001L000001YsT3FIAV","ramo":"1381","origemproposta":18,"numeroproposta":null,"numeroparcela":12,"idparceiro":null,"idfatura":null,"idexterno":"800L0000002OvrDIAS_a0fL0000007X0ugIAC","id":113858,"endosso":"0","empresa":"1","datavencimento":"2021-12-15T00:00:00.000Z","dataPagamentoParceiro":null,"datapagamento":null,"contrato":null,"apolice":"000001166"}]}';
                    retornoParcelas = (ParcelamentoContratoTO)JSON.deserialize(payloadTest, ParcelamentoContratoTO.class);
                }
                if(!retornoParcelas.data.isEmpty() && retornoParcelas != null){    //VIAG-248 - FIX - INICIO                
                    for(ParcelamentoContratoTO.DataTO item: retornoParcelas.data){                        
                        apolice.addParcelasContratos(item);
                    }
                }                
            }
            //PLV-4758 FIX 2 FIM   
            
            //PLV-4286 - FIM
            
            resposta.addApolice(apolice);
            System.debug('resposta >><<' + resposta);
        }
        
        //busca o nome do arquivo no heroku (estará no ECM)
		for(public_arquivoecm__x arquivoEcm : this.getArquivosECM(resposta.getIds())){
            ConsultaApoliceREST.ArquivoTO fileTO = resposta.getTO(arquivoEcm.idsf__c);
            if(fileTO == null) continue;
            fileTO.fileName = arquivoEcm.nomearquivo__c;
        }
        
        //content
		for(ContentDocumentLink linkArquivoSF : this.getArquivosSF(resposta.getIds())){
            ConsultaApoliceREST.ArquivoTO fileTO = resposta.getTO(linkArquivoSF.LinkedEntityId);
            if(fileTO == null) continue;
            fileTO.fileName = linkArquivoSF.ContentDocument.Title;
        }        
        //getIdContent        
        
        return resposta;
    }

    //PLV-4758 FIX 3 INICIO
    private Map<String, SeguradoContrato__c> getSeguradoContratoMap(List<Contract> contratos) {
        Map<String, SeguradoContrato__c> result = new Map<String, SeguradoContrato__c>();
        
        if (contratos  != null && contratos.size() > 0) {
            Set<Id> contratosIds = new Set<Id>();

            for (Contract contrato : contratos) {
                contratosIds.add(contrato.Id);
            }

            List<SeguradoContrato__c> segurados = [
                SELECT Id
                    ,GrupoContrato__r.contratanteContrato__r.contrato__c
                    ,GrupoContrato__r.contratanteContrato__r.QuantidadeParcelas__c
                    ,GrupoContrato__r.contratanteContrato__r.FormaPagamento__r.Name
                    ,GrupoContrato__r.contratanteContrato__r.Contrato__r.PorQuantoTempoQuerGarantirRenda__c
                    ,GrupoContrato__r.contratanteContrato__r.Contrato__r.DependentesFinanceiros__c
                    ,FaixaRenda__c
                    ,Conta__c
                    ,Conta__r.Name
                    ,Conta__r.NomeSocial__c //LECVPV-177 - INICIO/FIM
                    ,Conta__r.CPF__c
                    ,Conta__r.PersonBirthdate
                    ,Conta__r.Sexo__c
                    ,Conta__r.PersonEmail
                    ,Conta__r.BillingStreet
                    ,Conta__r.BillingCity
                    ,Conta__r.BillingState
                    ,Conta__r.BillingPostalCode
                    ,Conta__r.BillingCountry
                FROM SeguradoContrato__c 
                WHERE GrupoContrato__r.ContratanteContrato__r.Contrato__c IN :contratosIds
                AND Conta__r.Cpf__c <> NULL
            ];

            if (segurados != null && segurados.size() > 0) {
                
                for (SeguradoContrato__c segurado : segurados) {
                    String chave = segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c + '@' + segurado.Conta__r.cpf__c;
                    result.put(chave, segurado);
                }
            }
        }

        return result;
    }
    //PLV-4758 FIX 3 FIM

    //PLV-4758 FIX 1 INICIO
    public static Map<Id, CondicaoCobranca__c> getMapCondCobrancaPagamento() {
    
        if (condicaoCobrancaByFormaPagamento == null) {
            condicaoCobrancaByFormaPagamento = new Map<Id, CondicaoCobranca__c>();

            List<CondicaoCobranca__c> condicoesCobranca = [
                SELECT Id
                    ,TipoPagamento__c
                    ,FormaPagamento__c
                FROM CondicaoCobranca__c
                WHERE TipoPagamento__c <> NULL
                AND FormaPagamento__c <> NULL
                ORDER BY FormaPagamento__c ASC
                LIMIT 500 //FNPVVEP-47  INICIO/FIM
            ];

            if (condicoesCobranca.size() > 0) {
                for (CondicaoCobranca__c cond : condicoesCobranca) {
                    condicaoCobrancaByFormaPagamento.put(cond.FormaPagamento__c, cond);
                }
            }
        }

        return condicaoCobrancaByFormaPagamento;
    } 
    //PLV-4758 FIX 1 FIM
    
    //PLV-3475 Fix - Paginação para query com filtro IN() em objeto externo - INICIO
    private public_arquivoecm__x[] getArquivosECM(Set<Id> param){
        
        public_arquivoecm__x[] arquivos = new public_arquivoecm__x[]{};
        Set<Id> setIdLinkDoc = param.clone();
		Set<Id> filtroDoc = new Set<Id>();       
        Integer indice = 0;
        
        for(Id objId :setIdLinkDoc){
            filtroDoc.add(objId);
            indice++;
            if(indice == 100 || filtroDoc.size() == setIdLinkDoc.size()){
				arquivos.addAll(this.queryArquivosECM(filtroDoc));
            	setIdLinkDoc.removeAll(filtroDoc);
				filtroDoc.clear();
				indice = 0;                
            }
        }
        return arquivos;
    }
    
    private public_arquivoecm__x[] queryArquivosECM(Set<Id> idsLinkDoc){
        return !listMockedRequest.isEmpty() ? listMockedRequest : [SELECT nomearquivo__c, idsf__c 
                                                                   FROM public_arquivoecm__x 
                                                                   WHERE idsf__c IN :idsLinkDoc AND status__c = 'CRIADO'
                                                                   AND (nomearquivo__c LIKE 'Apolice_%' OR nomearquivo__c LIKE 'Voucher_%')];
    }
    //PLV-3475 Fix - Paginação para query com filtro IN() em objeto externo - FIM
    
    private ContentDocumentLink[] getArquivosSF(Set<Id> idsLinkDoc){
        return idsLinkDoc.isEmpty() ? new ContentDocumentLink[]{} : [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title 
                                                                     FROM ContentDocumentLink 
                                                                     WHERE LinkedEntityId IN :idsLinkDoc
                                                                     AND (ContentDocument.Title LIKE 'Apolice_%' OR ContentDocument.Title LIKE 'Voucher_%' OR ContentDocument.Title LIKE 'Endosso_%')]; //PLV-5554 INICIO - FIM
    }
    //PLV-3745 - FIM

    private Contract[] getContracts(){
        Set<Id> idsContratoPorCpf = new Set<Id>();
        Set<Id> idsContratoPorSusep = new Set<Id>();
        Set<Id> idsContrato = new Set<Id>();
        Set<Id> idsContratoPorCanalIdCanal = new Set<Id>(); //PLV-4193 INICIO/FIM        
        //PLV-4376 - FIX - INICIO - LINHA REMOVIDA - FIM
        //PLV-4376 - FIX - INICIO
        String cpfTratado;
        if(String.isNotBlank(this.param.cpf)) cpfTratado = this.param.cpf.contains('.') ? this.param.cpf : Util.imprimeCPF(this.param.cpf);
        //PLV-4376 - FIX - FIM        
        System.debug('cpfTratado ><' + cpfTratado);

        //VIAG-248 - FIX - INICIO

        //Pesquisando por CPF do contratante
        if(String.isNotBlank(this.param.cpf)){ //PLV-4376 - FIX - INICIO/FIM
            //PLV-4758 INICIO - A Pesquisa por CPF agora deve buscar todos os contratos por CPF, independente se é contratante ou não, Ex PASSAGEIROS Viagem
            for (Contract contrato : [SELECT Id FROM Contract WHERE Account.Cpf__c =: cpfTratado ORDER BY CREATEDDATE DESC LIMIT 500]) {//FNPVVEP-47 - INICIO/FIM
                idsContratoPorCpf.add(contrato.Id);
            }
            //PLV-4376 - FIX - INICIO - LINHA REMOVIDA - FIM
            //for(ContratanteContrato__c con : [SELECT Contrato__c FROM ContratanteContrato__c WHERE Tipo__c = 'Principal' AND Conta__r.Cpf__c = :cpfTratado limit 1000]) { //PLV 4193 - Inicio/fim Adicionado Limite como pede na história
            //    idsContratoPorCpf.add(con.Contrato__c);
            //}
            //PLV-4758 FIM
        }        

        //VIAG-248 - FIX - FIM
                
        //Pesquisando por SUSEP
        if(String.isNotBlank(this.param.susep)){
            for(FavorecidoRemuneracaoContrato__c frc : [SELECT RemuneracaoContrato__r.Contrato__c FROM FavorecidoRemuneracaoContrato__c WHERE Papel__c = 'Corretor' AND Susep__c =: this.param.susep]) //PLV 4193 - Inicio/fim Adicionado Limite como pede na história //VIAG-248 - FIX - INICIO/FIM
                idsContratoPorSusep.add(frc.RemuneracaoContrato__r.Contrato__c);
        }
        //PLV - 4193 INICIO
		//Pesquisando por Canal & Id do canal
        if(String.isNotBlank(this.param.canal) && String.isNotBlank(this.param.idCanal)){
            for(Contract contrato : [SELECT CanalDistribuicao__r.Name,CodigoCorretor__r.Name FROM Contract 
                                     WHERE CodigoCorretor__r.Name =: this.param.idCanal AND 
                                     CanalDistribuicao__r.Name =: this.param.canal limit 500 //PLV 4193 - Inicio/fim Adicionado Limite como pede na história || FNPVVEP-47 - INICIO/FIM
                                    ])
                idsContratoPorCanalIdCanal.add(contrato.id);
        }
        System.debug('idsContratoPorCanalIdCanal ' + idsContratoPorCanalIdCanal);

        //PLV - 4193 FIm

        //PLV-4376 - INICIO
        //Quando a busca por CPF é feita via portal do corretor, sempre serão informados a Susep e o CPF. 
        //Nesse caso é necessário retornar apenas as apólices em que o CPF pesquisado consta como segurado. 
        if(String.isNotBlank(this.param.cpf) && String.isNotBlank(this.param.susep)){
            //PLV-4376 - FIX - INICIO
            system.debug('4376 - consultaApoliceService - cpfTratado: ' + cpfTratado);
            //LECVPV-177 - ajuste na query INICIO/FIM
            for(SeguradoContrato__c segContrato : [
                SELECT id, grupoContrato__r.contratanteContrato__r.contrato__c, 
                Conta__c, Conta__r.Name, Conta__r.NomeSocial__c, Conta__r.CPF__c, Conta__r.PersonBirthdate,
                // PLV-4343 - INICIO
                grupoContrato__r.contratanteContrato__r.QuantidadeParcelas__c,
                grupoContrato__r.contratanteContrato__r.FormaPagamento__r.Name,
                grupoContrato__r.contratanteContrato__r.FormaPagamento__c, //PLV-4758 FIX 1 INICIO/FIM
                // PLV-4553 Inicio
                Conta__r.Fumante__c,
                Conta__r.Profissao__r.Name,
                Conta__r.RegimeTrabalho__c,
                grupoContrato__r.contratanteContrato__r.Contrato__r.PorQuantoTempoQuerGarantirRenda__c,
                grupoContrato__r.contratanteContrato__r.Contrato__r.DependentesFinanceiros__c,
                FaixaRenda__c,
                // PLV-4553 Fim
                // PLV-4343 - FIM
                Conta__r.Sexo__c, Conta__r.PersonEmail, Conta__r.BillingStreet, Conta__r.BillingCity, 
                Conta__r.BillingState, Conta__r.BillingPostalCode, Conta__r.BillingCountry
                FROM SeguradoContrato__c 
                WHERE conta__r.cpf__c = :cpfTratado limit 500]//FNPVVEP-47 - INICIO/FIM
            ){
                this.param.mapContratosDoSegurado.put(segContrato.grupoContrato__r.contratanteContrato__r.contrato__c, segContrato);                
            }
            //PLV-4376 - FIX - FIM
        }
        system.debug('4376 - mapContratosDoSegurado:' + this.param.mapContratosDoSegurado.keySet());
        //PLV-4376 - FIM
        
        System.debug('idsContratoPorSusep ' + idsContratoPorSusep);
        System.debug('idsContratoPorCpf ' + idsContratoPorCpf);

		if( (idsContratoPorCpf.isEmpty() && String.isNotBlank(this.param.cpf)) && (idsContratoPorSusep.isEmpty() && String.isNotBlank(this.param.susep)) 
           && (idsContratoPorCanalIdCanal.isEmpty() && (String.isNotBlank(this.param.canal) &&(String.isNotBlank(this.param.idCanal)))) ) { //PLV - 4193 inicio/fim
            //Caso os dois parâmetros estejam presentes e as duas pesquisas não retornem registros, devolver lista nula, pois os parâmetros não se relacionam com o mesmo contrato
            return new Contract[]{};
        }
        else{
            //PLV - 4193 INICIO
            //Verificar se os dois conjuntos possuem o Id do mesmo contrato
            if(String.isNotBlank(this.param.cpf) && String.isNotBlank(this.param.susep) && (String.isNotBlank(this.param.canal) && String.isNotBlank(this.param.idCanal) ) ){
                for(Id idCon : idsContratoPorCpf) {
                    if(idsContratoPorSusep.contains(idCon) && idsContratoPorCanalIdCanal.contains(IdCon)) idsContrato.add(idCon);
                }
            }
            
            //Se somente o parâmetro CPF estiver presente e a pesquisa dele retornar contrato, usar na próxima pesquisa o id do contrato retornado
            else if(String.isNotBlank(this.param.cpf) && !idsContratoPorCpf.isEmpty() && String.isBlank(this.param.susep)) idsContrato = idsContratoPorCpf; //PLV-4376 - FIX - INICIO/FIM
            //Se somente os parâmetro canal e idCanal estiver presente e a pesquisa dele retornar contrato, usar na próxima pesquisa o id do contrato retornado
            else if((String.isNotBlank(this.param.canal) && String.isNotBlank(this.param.idCanal)) && !idsContratoPorCanalIdCanal.isEmpty()) idsContrato = idsContratoPorCanalIdCanal;
            //PLV-4376 - INICIO
            //Se somente o parâmetro SUSEP estiver presente e a pesquisa dele retornar contrato, usar na próxima pesquisa o id do contrato retornado
            else if(String.isNotBlank(this.param.susep) && !idsContratoPorSusep.isEmpty() && String.isBlank(this.param.cpf)) idsContrato = idsContratoPorSusep;
            //Se os parâmetros CPF e Susep estiverem preenchidos, porém, não existe segurado com o CPF pesquisado, retornar a lista vazia.
            //PLV-4376 - FIX - INICIO
            else if(String.isNotBlank(this.param.cpf) && String.isNotBlank(this.param.susep) && this.param.mapContratosDoSegurado.isEmpty()) return new Contract []{};
            //Se os parâmetros CPF e Susep estiverem preenchidos, e a consulta do segurado retornou registros, verificar se o contrato do segurado está associado a susep
            else if(String.isNotBlank(this.param.cpf) && String.isNotBlank(this.param.susep) && !this.param.mapContratosDoSegurado.isEmpty()){
                for(String idContrato : idsContratoPorSusep){
                    if(this.param.mapContratosDoSegurado.containsKey(idContrato)) 
                        idsContrato.add(this.param.mapContratosDoSegurado.get(idContrato).grupoContrato__r.contratanteContrato__r.contrato__c);
                }
            }
            //PLV-4376 - FIX - FIM

            system.debug('4376 - this.param.cpf: ' + this.param.cpf);
            system.debug('4376 - this.param.susep: ' + this.param.susep);
            system.debug('4376 - idsContrato: ' + idsContrato);
            //Se os parâmetros CPF e Susep estiverem preenchidos, porém, o contrato do segurado não está relacionado ao corretor (susep), retornar a lista vazia
            if(String.isNotBlank(this.param.cpf) && String.isNotBlank(this.param.susep) && idsContrato.isEmpty()) return new Contract []{};
            //PLV-4376 - FIM
        }
        //PLV - 4193 FIM
		
        //Evitar retorno de todos os registros, caso "idsContrato" esteja nulo e os parâmetros SUSEP ou CPF não estejam
        if((String.isNotBlank(this.param.susep) || String.isNotBlank(this.param.cpf)  || (String.isNotBlank(this.param.canal) && String.isNotBlank(this.param.idCanal)))  && idsContrato.isEmpty()) return new Contract[]{}; //PLV - 4193 inicio/fim

        String SOQL = 'SELECT NumeroApolice__c, Id, '
            + ' Status,'
            + ' CodigoRamo__c,'
            // PLV-4343 - INICIO
            + ' FormaPagamento__r.Name,'
            + ' FormaPagamento__c,' //PLV-4758 FIX 1 INICIO/FIM
            + ' ValorPremio__c,'
            + ' Account.CPF__c,'
            // PLV-4343 - FIM
            + ' DataEmissao__c,'
            + ' StartDate,'
            + ' VigenciaFinal__c,'
            // PLV-4480 - Inicio
            + ' Hora_Expiracao_Link__c,' //FNPVVEP-98 INICIO/FIM
            + ' Segmento__c,'
            // PLV-4480 - Fim
            //  PLV-4264 - Inicio 
            + ' Endosso__c,'
            + ' Sucursal__c	,'
            //PLV - 5554 - INICIO
            + ' Empresa__c,'
            //PLV - 5554 - FIM
            //  PLV-4264 - fim 
            + ' Proposta__c,'
            + ' Produto__c,'
            + ' AccountId,'
            + ' ModalidadeSeguro__c,'
            + ' TipoViagem__c,'
            + ' PremioTotal__c,'
            + ' ViagemAventura__c,'
            //PLV-3879 - INICIO
            + ' PaisesDestino__c,'
            //PLV-3879 - FIM
            + ' UtilizaMoto__c,'
            + ' IncluiPaisEuropeu__c,'
            //PLV-3981 - INICIO
            + 'Tipo__c,'
            + 'MeioComercializacao__c,'
            + 'CodigoCorretor__r.Name,'
            //PLV-3981 - FIM
            + ' QuantidadePassageiros070Anos__c,'
            + ' VidasEntre7190Anos__c,'
            + ' Produto__r.Name,'
            + ' ModalidadeSeguro__r.Name,'
            + ' Proposta__r.AccountId,'
            + ' Proposta__r.NumeroProposta__c,'
            + ' Proposta__r.ResponsavelFinanceiro__r.Name,'            
            + ' Account.Name,'
			//PLV-4197 Inicio
			+ ' Proposta__r.Origem__c,'
			//+ ' CreatedDate,'
			//PLV-4197 Fim
            //PLV-4255 - INICIO                        
            + 'CodigoCorretor__r.NomeCorretor__r.Name,'
            //PLV-4255 - FIM
            //PLV-4193 - INICIO
			+ ' ApolicePdfDownloadUrl__c,'
            + ' Proposta__r.VoucherPdfDownloadUrl__c,'
            + ' EndossoPdfDownloadUrl__c,' //PLV-5554 INICIO - FIM
            //PLV-4193 - FIM
            + ' ('
            + ' SELECT Conta__c,'
            + ' Conta__r.Name,'
            + ' Conta__r.NomeSocial__c,' //LECVPV-177 - INICIO/FIM
            + ' Conta__r.CPF__c,'
            + ' Conta__r.PersonBirthdate,'
            + ' Tipo__c,'
            //PLV-4255 - INICIO
            + ' Conta__r.Sexo__c,'
            + ' Conta__r.PersonEmail,'
            + ' Conta__r.BillingStreet,'
            + ' Conta__r.BillingCity,'
            + ' Conta__r.BillingState,'
            + ' Conta__r.BillingPostalCode,'
            + ' Conta__r.BillingCountry,'                        
            //PLV-4255 - FIM            
            //PLV-4193 - INICIO
            + ' Id,'
            + ' QuantidadeParcelas__c,'
            + ' FormaPagamento__c,' //PLV-4758 FIX 1 INICIO/FIM
            + ' Contrato__c,' //PLV-4758 FIX 2 INICIO/FIM
            + ' FormaPagamento__r.Name'
            //PLV-4193 - FIM
            + ' FROM ContratantesContrato__r'
            + ' ),'
            + ' ('
            + ' SELECT Garantia__c,'
            + ' Garantia__r.Name,'
            + ' Capital__c'
            + ' FROM GarantiasContrato__r'
            + ' ),'
            //PLV-4255 - INICIO
            + ' ('
            + ' SELECT TipoRemuneracao__r.Name,' 
            + ' Percentual__c,' 
            + ' Contrato__c,'
            + ' Porcentagem_de_Retencao__c'  //PLV - 4553 - INICIO/FIM
            + ' FROM RemuneracoesContrato__r)'
            //PLV-4255 - FIM
            // PLV-4351 Ajuste na string e filtro de proposta
            + ' FROM Contract WHERE Proposta__c != null';

            //System.debug('statusContrato = ' + statusContrato);
			//System.debug('statusProposta = ' + statusProposta);
			// PLV-4351 - INICIO
            if(String.isBlank(this.param.statusApolice) && String.isBlank(this.param.nomeSegurado))
                SOQL += ' AND Proposta__r.Status = :statusProposta'; //PLV - 4714 - INICIO/FIM
            
            //II-124 FIX01 INICIO
            if(String.isNotBlank(param.codigoOferta)){
                String oferta = param.codigoOferta.toUpperCase();
                Set<String> ofertas = new Set<String>{oferta};
                List<Constante__mdt> produto = MetadataDAO.getInstance().buscarConstantes(ofertas);
                if (produto != null && !produto.isEmpty()) {
                    String idProduto = produto[0].Valor__c;
                    Set<String> idProdutoSet = new Set<String>(idProduto.split(','));
                    SOQL += ' AND Produto__c IN : idProdutoSet';
                }
            }
            //II-124 FIX01 FIM

            if(String.isNotBlank(this.param.statusApolice))
                SOQL += ' AND Status = :statusApoliceParam';
            
            if(String.isNotBlank(this.param.nomeSegurado))
                SOQL += ' AND Account.Name LIKE :nomeSeguradoParam';  

            if(String.isNotBlank(this.param.susep))
                SOQL += ' AND Proposta__r.CodigoCorretor__r.Name =: susepParam';// PLV-5554-FIX-INICIO/FIM
            //PLV-4197 Inicio
            //PLV-4758 INICIO
            System.debug('this.param.Proposta = '+ this.param.Proposta);
            System.debug('this.param.Origem = '+ this.param.Origem);
            if(String.isNotBlank(this.param.Origem) && String.isNotBlank(this.param.Proposta)) {
                String nameProposta = this.param.Origem + '-' +this.param.Proposta.leftPad(8,'0');
                System.debug('nameProposta = ' + nameProposta);
                SOQL += ' AND Proposta__r.Name = :nameProposta';
            }
            //PLV-4758 FIM
			
			if(String.isNotBlank(this.param.quantidadeDeMeses)){
				Date dataCalculada = Date.valueOf(System.today().addMonths(- Integer.valueOf(this.param.quantidadeDeMeses))); 
				System.debug('dataCalculada = '+ dataCalculada);
			}
			if(String.isNotBlank(this.param.quantidadeDeMeses))
                SOQL += ' AND DataEmissao__c >= :dataCalculada'; 
			
			//PLV-4197 Fim
            
            String statusApoliceParam = this.param.statusApolice;
            String nomeSeguradoParam = '%' + this.param.nomeSegurado + '%';
            String susepParam = this.param.susep;// PLV-5554-FIX-INICIO/FIM
            // PLV-4351 - FIM

            String statusProposta = 'Contratada';
            String statusContrato = 'Cancelado';            

            //PLV-4286 - INICIO    
            //FNPVVEP-44 INICIO    
            String numApolice = '';
            String sucursalApolice = '';
            String empresaApolice = '';
            String ramoApolice = '';
            String numeroEndosso = '';
            String apolice = '';
            String[] numeroApolice;

            // if(String.isNotBlank(this.param.empresaSucursalRamoApolice)){            
            //     String[] empresaSucursalRamoApoliceParams = this.param.empresaSucursalRamoApolice.split('-');                              
            //     if(empresaSucursalRamoApoliceParams.size() == 4){
            //         empresaApolice = empresaSucursalRamoApoliceParams[0];
            //         sucursalApolice = empresaSucursalRamoApoliceParams[1];
            //         ramoApolice = empresaSucursalRamoApoliceParams[2];
            //         numApolice = empresaSucursalRamoApoliceParams[3];
            //     }                              
            // }else{
            //     numApolice = this.param.numApolice;
            // }

            if(String.isNotBlank(this.param.numApolice)){            
                numeroApolice = this.param.numApolice.split('-');    
                System.debug('numeroApolice.size() >< ' + numeroApolice.size()); 
                if(numeroApolice.size() == 3){
                    empresaApolice = numeroApolice[0];
                    sucursalApolice = numeroApolice[1];
                    ramoApolice = numeroApolice[2];
                    SOQL += ' AND Empresa__c = :empresaApolice';
                    SOQL += ' AND Sucursal__c = :sucursalApolice';
                    SOQL += ' AND CodigoRamo__c = :ramoApolice';
                }else if(numeroApolice.size() == 4){
                    if (numeroApolice[2].length() > 5) {
                        sucursalApolice = numeroApolice[0];
                        ramoApolice = numeroApolice[1];
                        numApolice = numeroApolice[2];
                        numeroEndosso = numeroApolice[3];
                    }else{
                        empresaApolice = numeroApolice[0];
                        sucursalApolice = numeroApolice[1];
                        ramoApolice = numeroApolice[2];
                        numApolice = numeroApolice[3];
                    }
                    SOQL += ' AND NumeroApolice__c = :numApolice';
                    SOQL += ' AND Sucursal__c = :sucursalApolice';
                    SOQL += ' AND CodigoRamo__c = :ramoApolice';
                        if(String.isNotBlank(numeroEndosso)){
                            SOQL += ' AND Endosso__c = :numeroEndosso';
                        }
                        if(String.isNotBlank(empresaApolice)){
                            SOQL += ' AND Empresa__c = :empresaApolice';
                        }
                }else if(numeroApolice.size() == 5){
                    empresaApolice = numeroApolice[0];
                    sucursalApolice = numeroApolice[1];
                    ramoApolice = numeroApolice[2];
                    numApolice = numeroApolice[3];
                    numeroEndosso = numeroApolice[4];
                    SOQL += ' AND Empresa__c = :empresaApolice';
                    SOQL += ' AND NumeroApolice__c = :numApolice';
                    SOQL += ' AND Sucursal__c = :sucursalApolice';
                    SOQL += ' AND CodigoRamo__c = :ramoApolice';
                    if(String.isNotBlank(numeroEndosso)){
                        SOQL += ' AND Endosso__c = :numeroEndosso';
                    }
                }                      
            }
        	//PLV-4758-FIX5 - inicio
            // if(this.param.numApolice != null){

            //     String[] numApoliceSplit = this.param.numApolice.split('-'); 
            //     if(numApoliceSplit.size() == 5){
            //         numApolice = numApoliceSplit[0]+'-'+numApoliceSplit[1]+'-'+numApoliceSplit[2]+'-'+numApoliceSplit[3].leftPad(9, '0')+'-'+numApoliceSplit[4];
            //     }

            // }
        	//PLV-4758-FIX5 fim
        
            //PLV-4286 - FIM
            
            //PLV-4607 Inicio
        	//if(String.isNotBlank(numApolice)) SOQL += ' AND Name = :numApolice';            
            //PLV-4286 - INICIO
            //if(String.isNotBlank(numApolice)) SOQL += ' AND Name LIKE \'%' + String.escapeSingleQuotes(numApolice) + '%\'';
            // if(String.isNotBlank(this.param.empresaSucursalRamoApolice)){                                    
            //     SOQL += ' AND Empresa__c = :empresaApolice';
            //     SOQL += ' AND Sucursal__c = :sucursalApolice';
            //     SOQL += ' AND CodigoRamo__c = :ramoApolice';
            // }    
            //PLV-4286 - FIM
			//PLV-4607 FIM	
            //FNPVVEP-44 FIM
        
			System.debug('idsContrato =' + idsContrato);
        	//PLV-4607 Inicio
        	if(String.isNotBlank(numApolice) && String.isBlank(this.param.quantidadeDeMeses) && String.isBlank(this.param.Origem) && String.isBlank(this.param.Proposta) && String.isBlank(this.param.nomeSegurado) && String.isBlank(this.param.statusApolice))
            {                
              //  SOQL += ' ORDER BY Name Desc LIMIT 1';
              SOQL += ' ORDER BY Name Desc';//PLV - 5554 INICIO FIM
            }else{
                //PLV-4758 FIX 2 INICIO
                if(!idsContrato.isEmpty()) SOQL += ' AND Id IN :idsContrato ORDER BY CreatedDate DESC LIMIT 100'; //PLV 4193 - Inicio/fim Adicionado Limite como pede na história            
                //PLV-4758 FIX 2 FIM
            }
            //PLV-4607 FIM

            System.debug('Carlos - ' + soql.split('FROM Contract WHERE')[1]);
            System.debug('Carlos - ' + this.param.statusApolice);
            System.debug('Carlos - ' + this.param.nomeSegurado);
            
			System.debug('Database.query(SOQL) = ' + SOQL);
        return (Contract[]) Database.query(SOQL);
    }

    // CH-5802153 - INICIO
    private Map<String, List<public_parcelacontrato__x>> getParcelasContratosMap(List<String> contratantesIds)
    {
        List<public_parcelacontrato__x> parcelas = [ 
                SELECT  
                id__c, 
                datavencimento__c,
                numeroparcela__c, 
                valoriof__c, 
                valorliquido__c, 
                idfatura__c, 
                idexterno__c, 
                status__c, 
                valorparcela__c 
                FROM public_parcelacontrato__x WHERE idexterno__c IN :contratantesIds
            ];
        
        Map<String, List<public_parcelacontrato__x>> mapParcelas = new Map<String, List<public_parcelacontrato__x>>();

        for(public_parcelacontrato__x parcela : parcelas)
        {
            if(mapParcelas.containsKey(parcela.idexterno__c))
            {
                List<public_parcelacontrato__x> lstParcelas = mapParcelas.get(parcela.idexterno__c);
                lstParcelas.add(parcela);
            }
            else 
            {
                List<public_parcelacontrato__x> lstParcelas = new List<public_parcelacontrato__x>();
                lstParcelas.add(parcela);
                mapParcelas.put(parcela.idexterno__c, lstParcelas);
            }
        }
        return mapParcelas;
    }
    // CH-5802153 - FIM
}