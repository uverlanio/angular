@RestResource(urlMapping='/consultaseguros/*')
global with sharing class ApoliceVigente {

    @HttpPost
    global static void apoliceVigente() {
        RestRequest req = RestContext.request;
        BuscaRequest busca = (BuscaRequest) System.JSON.deserialize(RestContext.request.requestBody.toString(), BuscaRequest.class);
        
        String prodFilter = '';
        // PLV-3740 #Inicio - Realizando a validação de data de ocorrencia
        Date dataOcorrenciaDate;
        try {
            
            dataOcorrenciaDate = Date.valueOf(busca.buscaSegurados.dataOcorrencia);    
            //PLV-3866 - INICIO
            system.debug('dataOcorrenciaDate'+dataOcorrenciaDate);
            //PLV-3866 - INICIO FIX1
            if( dataOcorrenciaDate > System.today()){
                Response res = new Response();
                res.resultados = '-1';
                res.mensagem = 'A data de ocorrência deverá ser menor ou igual a data de hoje.';
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
                return;
            }
            //PLV-3866 - FIM FIX1
            //PLV-3866 - FIM
        } catch (Exception es) {
            Response res = new Response();
            res.resultados = '-1';
            res.mensagem = 'Favor, verificar se a data foi inserida corretamente.';
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
            return;
        }
        
       
        // PLV-3740 #Fim
        if( busca.buscaSegurados.prestador == null  ||  busca.buscaSegurados.prestador  == '' ){
            Response res = new Response();
            res.resultados = '-1';
            res.mensagem = 'Verifique os campos obrigatórios';
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
            return;
        }

        if( ( busca.buscaSegurados.prestador  != null  &&  busca.buscaSegurados.prestador  != '' ) && 
           	( busca.buscaSegurados.produto  != null  &&  busca.buscaSegurados.produto  != '' ) && 
           	( busca.buscaSegurados.plano  != null  &&  busca.buscaSegurados.plano  != '' ) ){
            prodFilter = 	'AND Produto__r.ProdutoTecnico__r.ProductCode = \'' + String.escapeSingleQuotes(busca.buscaSegurados.produto) + '\' ' + 
                			'AND Produto__r.ProductCode = \'' + String.escapeSingleQuotes(busca.buscaSegurados.plano) + '\' ' ;
        }
        else if((busca.buscaSegurados.prestador != null  &&  busca.buscaSegurados.prestador  != '' ) &&
            	(busca.buscaSegurados.produto != null    &&  busca.buscaSegurados.produto  != '' ) ){
            prodFilter = 'AND Produto__r.ProdutoTecnico__r.ProductCode = \'' + String.escapeSingleQuotes(busca.buscaSegurados.produto) + '\' ' ;
        }
        Set<String> prodIdSet = new Set<String>();
        try{
        	System.debug('Query Produto = ' + 'SELECT Id, Produto__c, Produto__r.ProdutoTecnico__r.ProductCode,Produto__r.ProductCode, Parceiro__c, Parceiro__r.SiglaParceiro__c ' +
            'FROM ProdutoParceiro__c ' + 'WHERE Parceiro__r.SiglaParceiro__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.prestador) + '\' ' +
            prodFilter + ' LIMIT 1000');
			
			for( ProdutoParceiro__c pp : (List<ProdutoParceiro__c>) Database.query('SELECT Id, Produto__c, Produto__r.ProdutoTecnico__r.ProductCode,Produto__r.ProductCode, Parceiro__c, Parceiro__r.SiglaParceiro__c ' +
            'FROM ProdutoParceiro__c ' + 'WHERE Parceiro__r.SiglaParceiro__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.prestador) + '\' ' +
            prodFilter + ' LIMIT 1000') ) prodIdSet.add(pp.Produto__c);
        }catch(exception e){
        	Response res = new Response();
            res.resultados = '-2';
            res.mensagem = 'Erro de Infra';
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
            return;
        }
        
        String contractFilter = '';
            
        if( ( busca.buscaSegurados.empresa != null &&  busca.buscaSegurados.empresa  != '' ) && 
           	( busca.buscaSegurados.sucursal  != null  &&  busca.buscaSegurados.sucursal  != '' ) && 
           	( busca.buscaSegurados.ramo  != null  &&  busca.buscaSegurados.ramo  != '' ) && 
           	( busca.buscaSegurados.apolice  != null  &&  busca.buscaSegurados.apolice  != '' ) && 
           	( busca.buscaSegurados.endosso  != null  &&  busca.buscaSegurados.endosso  != '' ) ){
         	
         	contractFilter = 	'AND Empresa__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.empresa) + '\' ' +  
                				'AND Sucursal__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.sucursal) + '\' ' + 
                				'AND RamoSeguro__r.Codigo__c = \''+ String.escapeSingleQuotes(busca.buscaSegurados.ramo)  + '\' ' + 
                				'AND Numeroapolice__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.apolice) + '\' ' + 
                				'AND Endosso__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.endosso) + '\' ' ; 
            
        } 
        else if (   ( busca.buscaSegurados.idSeguro  != null  &&  busca.buscaSegurados.idSeguro  != '' ) ){
            String[] idSeguroSplit = busca.buscaSegurados.idSeguro.split('-');
            contractFilter =    'AND Empresa__c = \'' + String.escapeSingleQuotes(idSeguroSplit[0]) + '\' ' +  
                                'AND Sucursal__c = \'' + String.escapeSingleQuotes(idSeguroSplit[1]) + '\' ' + 
                                'AND RamoSeguro__r.Codigo__c = \''+ String.escapeSingleQuotes(idSeguroSplit[2])  + '\' ' + 
                                'AND Numeroapolice__c = \'' + String.escapeSingleQuotes(idSeguroSplit[3]) + '\' ' + 
                                'AND Endosso__c = \'' + String.escapeSingleQuotes(idSeguroSplit[4]) + '\' ' ;
        }
        else if (	( busca.buscaSegurados.origem  != null  &&  busca.buscaSegurados.origem  != '' ) && 
           			( busca.buscaSegurados.proposta  != null  &&  busca.buscaSegurados.proposta  != '' )){
           contractFilter = 'AND Proposta__r.Origem__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.origem) + '\' ' + 
               				'AND Proposta__r.NumeroProposta__c = \'' + String.escapeSingleQuotes(busca.buscaSegurados.proposta) + '\' ' ;
        }
        else if (	( busca.buscaSegurados.numeroCpf   != null  &&  busca.buscaSegurados.numeroCpf   != '' ) && 
           			( busca.buscaSegurados.digitoCpf   != null  &&  busca.buscaSegurados.digitoCpf   != '' )){
        	    contractFilter = 'AND  Account.Cpf__c = \'' + 
                String.escapeSingleQuotes(busca.buscaSegurados.numeroCpf.left(3)) + '.' + String.escapeSingleQuotes(busca.buscaSegurados.numeroCpf.left(6).right(3)) + '.' + 
                String.escapeSingleQuotes(busca.buscaSegurados.numeroCpf.right(3)) + '-' + String.escapeSingleQuotes(busca.buscaSegurados.digitoCpf) + '\' ' ;
        }
        else if (   busca.buscaSegurados.nome   != null  &&  busca.buscaSegurados.nome   != ''  && 
                    busca.buscaSegurados.nome.remove('%').length() > 4  ) {
            contractFilter = 'AND Account.Name LIKE \''+ String.escapeSingleQuotes(busca.buscaSegurados.nome) + '\' ';
        }else{
            Response res = new Response();
            res.resultados = '-1';
            res.mensagem = 'Verifique os campos obrigatórios';
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
            return;
        }
        
        Map<Id,SeguradoContrato__c> seguradoMap;
        Map<Id,Contract > contractMap;
		System.debug('prodIdSet = '+ prodIdSet);
        try{
           //PLV-3866 - INICIO - Inclusão do campo AccountId no retorno da consulta 
			//PLV-4602 inicio
            // VIAG-202 INICIO
            String consultaParceiro = 'SELECT Id, AccountId, Empresa__c, Sucursal__c, RamoSeguro__r.Codigo__c, Numeroapolice__c, Endosso__c, ' +
            'Status, DataEmissao__c, StartDate, VigenciaFinal__c, Proposta__r.NumeroProposta__c, Proposta__r.Origem__c, Parceria__r.SiglaParceiro__c,' +
            'Account.Cpf__c, Account.Name, Produto__c, Produto__r.Name, Produto__r.ProductCode, Account.PersonBirthdate, Account.Sexo__c, ' +
            'Proposta__r.Opportunity.CodigoCorretor__c, Proposta__r.Opportunity.CodigoCorretor__r.NomeCorretor__r.Name,  Proposta__r.Opportunity.CodigoCorretor__r.NomeCorretor__r.Email__c, PremioTotal__c, IdExterno__c, 	ModalidadeSeguro__r.Name ' +
            'FROM Contract WHERE ';
            // VIAG-186-INICIO-FIX01
            // VIAG-186-INICIO-FIX02
            //VIAG-277 Lucas Sousa
            //if(busca.buscaSegurados.prestador == 'URA' || busca.buscaSegurados.prestador == 'ASSISTCARD'){ //VIAG-231
            if(busca.buscaSegurados.prestador == 'URA'){
                consultaParceiro  += ' Status = \'Emitido\' AND';
                consultaParceiro  += ' Segmento__c = \'Viagem\'';
                consultaParceiro  += 'AND Tipo__c = \'Novo\' ';
                consultaParceiro  += 'AND StartDate <= '+ String.escapeSingleQuotes(busca.buscaSegurados.dataOcorrencia)+ ' ';
                consultaParceiro  += 'AND VigenciaFinal__c >= ' + String.escapeSingleQuotes(busca.buscaSegurados.dataOcorrencia) + ' ';
            } else if(busca.buscaSegurados.prestador == 'ASSISTCARD'){
                consultaParceiro  += ' Segmento__c = \'Viagem\'';
                consultaParceiro  += 'AND Tipo__c = \'Novo\' ';
            }else{
             consultaParceiro  += 'Produto__c IN :prodIdSet AND';
             consultaParceiro  += ' Status = \'Emitido\'';
            }
            //VIAG-277 Lucas Sousa - END
            // VIAG-186-FIM-FIX02
            //VIAG-186-FIM-FIX01
            //PLV-3866 - INICIO FIX1
            //'AND StartDate <= '  + String.escapeSingleQuotes(busca.buscaSegurados.dataOcorrencia) +  ' ' +
            //'AND VigenciaFinal__c >= ' + String.escapeSingleQuotes(busca.buscaSegurados.dataOcorrencia) + ' ' +
            //PLV-3866 - FIM FIX1
 
            /*if (busca.buscaSegurados.prestador == 'URA') {
             consultaParceiro  += 'AND Tipo__c = \'Novo\' ';
             consultaParceiro  += 'AND StartDate <= '+ String.escapeSingleQuotes(busca.buscaSegurados.dataOcorrencia)+ ' ';
             consultaParceiro  += 'AND VigenciaFinal__c >= ' + String.escapeSingleQuotes(busca.buscaSegurados.dataOcorrencia) + ' ';
            }*/
 
            consultaParceiro  += contractFilter  + ' LIMIT 1000';
 
 
             contractMap = new Map<Id,Contract >((List<Contract> ) Database.query(consultaParceiro));
             // VIAG-202 FIM
             //PLV-4602 Fim
             //PLV-3866 FIM
            //PLV 4602 Inicio
            System.debug('contrato1 ' + contractMap.keySet());
            seguradoMap = new Map<Id,SeguradoContrato__c>([ 
                SELECT 	Id, Conta__c, GrupoContrato__r.ContratanteContrato__r.Contrato__c, GrupoContrato__r.ContratanteContrato__r.Numero__c,
                        GrupoContrato__r.Numero__c, Numero__c, Conta__r.PersonHomePhone, Conta__r.BillingStreet, Conta__r.BillingCity, 
						Conta__r.BillingPostalCode, Conta__r.BillingState  
                FROM 	SeguradoContrato__c 
                WHERE 	GrupoContrato__r.ContratanteContrato__r.Contrato__c IN: contractMap.keySet()
            ]);
		//PLV 4602 Fim
			System.debug('seguradoMap 1 = '+ seguradoMap);
        }catch(exception e){
            System.debug('Consulta seguros erro: ' + e.getMessage());
            Response res = new Response();
            res.resultados = '-2';
            res.mensagem = 'Erro de Infra';
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
            return;
        }
		//PLV-3866 - INICIO
        Response res = new Response();
		
		//PLV 4602 Inicio
		//List<GarantiasContrato__c> garantiasContrato = [select Garantia__r.Name from GarantiasContrato__c where Contrato__c IN: contractMap.keySet()];
		Map<Id,GarantiaContrato__c> garantiasContratoMap;

		garantiasContratoMap = new Map<Id,GarantiaContrato__c>([select Id, Contrato__c, Garantia__r.Name, Capital__c, Garantia__r.Sigla__c from GarantiaContrato__c where Contrato__c IN: contractMap.keySet()]); //PLV-5802 INICIO-FIM
		System.debug('Chave Mapa = ' + garantiasContratoMap.values());
		System.debug('Chave Mapa keySet = ' + garantiasContratoMap.keySet());

		Map<Id,Endereco__c> enderecoMap;		
		List<Account> contasList = new List<Account>();

		for(SeguradoContrato__c segurado : seguradoMap.values()){
			Contract contrato = contractMap.get(segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
			Account conta = contrato.Account;
			contasList.add(conta);
		}

		enderecoMap = new Map<Id,Endereco__c>([select Id, Bairro__c from Endereco__c where Conta__c IN: contasList and MaisAtual__c = true]);
		System.debug('Chave Mapa = ' + enderecoMap.values());
		System.debug('Chave Mapa keySet = ' + enderecoMap.keySet());
		//PLV 4602 Fim

        String contaId;
        for(SeguradoContrato__c segurado : seguradoMap.values()){
            Contract contrato = contractMap.get(segurado.GrupoContrato__r.ContratanteContrato__r.Contrato__c);
			
            Segurado seg = new Segurado();
            seg.idSeguro = contrato.Empresa__c + '-' + contrato.Sucursal__c + '-' + contrato.RamoSeguro__r.Codigo__c + '-' + contrato.Numeroapolice__c + '-' +
                    contrato.Endosso__c;
            seg.empresa = contrato.Empresa__c;
            seg.sucursal = contrato.Sucursal__c;
            seg.ramo = contrato.RamoSeguro__r.Codigo__c;
            seg.apolice = contrato.Numeroapolice__c;
            seg.endosso = contrato.Endosso__c;
            seg.origem = contrato.Proposta__r.Origem__c;
            seg.proposta = contrato.Proposta__r.NumeroProposta__c;
            seg.statusSeguro = contrato.Status;
            seg.idSegurado = contrato.Empresa__c + '-' + contrato.Sucursal__c + '-' + contrato.RamoSeguro__r.Codigo__c + '-' + contrato.Numeroapolice__c + '-' +
                    contrato.Endosso__c + '/' +  segurado.GrupoContrato__r.ContratanteContrato__r.Numero__c + '-' + 
                    segurado.GrupoContrato__r.Numero__c + '-' +  segurado.Numero__c;
            seg.produto = contrato.Produto__r.Name;
            seg.plano = contrato.Produto__r.ProductCode;
            seg.dataEmissao = String.valueOf(contrato.DataEmissao__c);
            seg.vigenciaInicial = String.valueOf(contrato.StartDate);
            seg.vigenciaFinal = String.valueOf(contrato.VigenciaFinal__c);
            seg.nome = contrato.Account.Name;
            // VIAG-186 - INICIO
            if (busca.buscaSegurados.prestador == 'URA') {
                seg.parceria = contrato.Parceria__r.SiglaParceiro__c;
            }else{
                seg.parceria = '';
            }
            // VIAG-186 - FIM
            
            seg.dataNascimento = string.valueOf(contrato.Account.PersonBirthdate);
            if( contrato.Account.Cpf__c != null)    seg.numeroCpf = contrato.Account.Cpf__c.remove('.').left(9);
            if( contrato.Account.Cpf__c != null)    seg.digitoCpf = contrato.Account.Cpf__c.right(2);
            seg.sexo = contrato.Account.Sexo__c;						
			//PLV 4602 Inicio
			seg.codigoContrato		= contrato.IdExterno__c;
			List<GarantiaContrato__c> GarantiaContratoList = garantiasContratoMap.values();
			System.debug('GarantiaContratoList = ' + GarantiaContratoList);			
			///g.nomeGarantiaProduto = GarantiaContrato.Garantia__r.Name;
			Decimal valorTotal = 0;
			for(GarantiaContrato__c g : GarantiaContratoList){
				GarantiaProduto gP = new GarantiaProduto();
				if(contrato.Id == g.Contrato__c){                    
					gP.nomeGarantiaProduto = g.Garantia__r.Name;
                    
                    //Correção inc. 4963072 - Inicio
                    if(g.Capital__c == null){
                    	g.Capital__c = 0;                        
                    }
                    //Correção inc. 4963072 - Fim
                    
                    //PLV-5802 - INICIO
                    if(busca.buscaSegurados.prestador != 'CDF'){
                        valorTotal = valorTotal + g.Capital__c;
					    //seg.codigoPlanos.add(gP);
                    }else{
                        if(g.Garantia__r.Sigla__c == 'AFI' || g.Garantia__r.Sigla__c == 'AFF'){
                            valorTotal = valorTotal + g.Capital__c;
                        }
                    }
                    seg.codigoPlanos.add(gP);
                    //PLV-5802 - FIM
				}				
			}
			
			List<Endereco__c> enderecosList = enderecoMap.values();
			System.debug('enderecosList = ' + enderecosList);
			for(Endereco__c ende : enderecosList){
				seg.bairroSegurado = ende.Bairro__c;
			}			 								 	
			seg.telefoneSegurado	= segurado.Conta__r.PersonHomePhone;
			seg.enderecoSegurado	= segurado.Conta__r.BillingStreet;			
			seg.cidadeSegurado 		= segurado.Conta__r.BillingCity;
			seg.cepSegurado 		= segurado.Conta__r.BillingPostalCode;
			seg.UFSegurado			= segurado.Conta__r.BillingState;

			seg.susepCorretor = contrato.Proposta__r.Opportunity.CodigoCorretor__c;
			seg.nomeCorretor		= contrato.Proposta__r.Opportunity.CodigoCorretor__r.NomeCorretor__r.Name;
			seg.emailCorretor = contrato.Proposta__r.Opportunity.CodigoCorretor__r.NomeCorretor__r.Email__c;
			seg.valorImportanciaSegurada =  String.valueOf(valorTotal);
			seg.tipoSeguro = contrato.ModalidadeSeguro__r.Name;
			
			//PLV 4602 Fim
			            
			contaId = contrato.AccountId;
			//PLV-3866 - INICIO FIX1
			if( dataOcorrenciaDate >= Date.valueOf(seg.vigenciaInicial) && dataOcorrenciaDate <= Date.valueOf(seg.vigenciaFinal)){
				res.segurados.add(seg);		
                System.debug ('SEG SF ' +seg );
                system.debug('apolice vigente');
			}else if( dataOcorrenciaDate > Date.valueOf(seg.vigenciaFinal)){
				res.segurados.add(seg);		
                system.debug('apolice encerrada');
			}
            else{
                system.debug('apolice futura');
                res.segurados.add(seg);		
				res.resultados = '-3';
				res.mensagem = 'SUCESSO';
			}
            //PLV-3866 - FIM FIX 1
        }

		if(res.segurados.size() > 0){
			res.resultados = '' + seguradoMap.values().size();
			res.mensagem = 'SUCESSO';
			RestContext.response.addHeader('Content-Type', 'application/json');
			RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
		}			        

		if(seguradoMap.isEmpty()){
			//res.resultados = '' + seguradoMap.values().size();
            // VIAG-202 INICIO
			  res.resultados = '0';
            if (busca.buscaSegurados.prestador == 'URA') {
              res.mensagem = 'Não localizamos seguro com os dados informados';
            } else {
              res.mensagem = 'Insucesso';
            }
		    // VIAG-202 FIM
			RestContext.response.addHeader('Content-Type', 'application/json');
			RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(res));
		}
	
        //PLV-3866 - FIM
        
        // PLV-3740 #Inicio - Realizando o registro de consulta do serviço
        Map<String, Prestadores__c> setupPrestadores = Prestadores__c.getAll();
        if(setupPrestadores.containsKey(busca.buscaSegurados.prestador)){
            // PLV-3866 - INICIO - INCLUSAO DO PARAMETRO contaId
            registrarCasoPorRequisicao(RestContext.request.requestBody.toString(), seguradoMap.values().size(), JSON.serializePretty(res), contractFilter, prodIdSet, contaId);
        	// PLV-3866 - FIM
        }
        // PLV-3740	 #Fim
		
    }

    global class BuscaRequest {
        global BuscaSegurado buscaSegurados;        
    }
    
    global class BuscaSegurado {
        public String prestador;
        public String idSeguro;
        public String empresa;
        public String sucursal;
        public String ramo;
        public String apolice;
        public String endosso;
        public String origem;
        public String proposta;
        public String numeroCpf;
        public String digitoCpf;
        public String nome;
        public String produto;
        public String plano;
        public String dataOcorrencia;
    }
    
     public static ApoliceVigente parse(String json) { 
         return (ApoliceVigente) System.JSON.deserialize(json, ApoliceVigente.class);
     }
    
    public class Response {
        public String 		    resultados 			{get; set;}
        public String 		    mensagem 			{get; set;}
        public List<Segurado> 	segurados			{get; set;} 

        public Response(){
            segurados = new List<Segurado>();
        }        
    }
    
    public class Segurado {
        //PLV-4602 inicio
		public List<GarantiaProduto> 	codigoPlanos {get; set;}
		public Segurado(){
            codigoPlanos = new List<GarantiaProduto>();
        }
		//PLV-4602 Fim
		 
		public String 	idSeguro 			{get; set;}
        public String 	empresa 			{get; set;}
        public String 	sucursal 			{get; set;}
        public String 	ramo 				{get; set;}
        public String 	apolice 			{get; set;}
        public String 	endosso 			{get; set;}
        public String 	origem 				{get; set;}
        public String 	proposta 			{get; set;}
        public String 	statusSeguro 		{get; set;}
        public String 	idSegurado 			{get; set;}
        public String 	produto 			{get; set;}
        public String 	plano 				{get; set;}
        public String 	dataEmissao 		{get; set;}
        public String 	vigenciaInicial 	{get; set;}
        public String 	vigenciaFinal 		{get; set;}
        public String 	nome 				{get; set;}
        public String 	dataNascimento		{get; set;}
        public String 	numeroCpf 			{get; set;}
        public String 	digitoCpf 			{get; set;}
        public String 	sexo 				{get; set;}
        public String  parceria             {get; set;} // VIAG-186 INICIO/FIM

		//PLV-4602 Inicio
		public String 	codigoContrato 				{get; set;}
		//public String 	codigoPlano 				{get; set;}
		public String 	telefoneSegurado 			{get; set;}
		public String 	enderecoSegurado 			{get; set;}
		public String 	bairroSegurado 				{get; set;}
		public String 	cidadeSegurado 				{get; set;}
		public String 	cepSegurado 				{get; set;}
		public String 	UFSegurado 					{get; set;}
		public String   susepCorretor				{get; set;}
		public String	nomeCorretor				{get; set;}
		public String	emailCorretor				{get; set;}
		public String	valorImportanciaSegurada	{get; set;}
		public String	tipoSeguro					{get; set;}
		//PLV-4602 Fim
    }
	//PLV 4602 Inicio
	public class GarantiaProduto{
		public String 	nomeGarantiaProduto 		{get; set;}
	}
	//PLV 4602 Fim


    // PLV-3740	#Inicio - Responsável pela criação de um registro de Case para armazenamento de informações da requisição
    @future
    //PLV-3866 - INICIO - INCLUSAO DO PARAMETRO contaId
    private static void registrarCasoPorRequisicao(String buscaObj, Integer numeroSegurados, String response, String contractFilter, Set<String> prodIdSet, String contaId){
    //PLV - 3866 - FIM
        try {
            BuscaRequest busca = (BuscaRequest) System.JSON.deserialize(buscaObj, BuscaRequest.class);
            Response res = (Response) System.JSON.deserialize(response, Response.class);
            //PLV-3866 - INICIO FIX2
            system.debug('busca'+ busca);
           
            /*
            Map<Id,SeguradoContrato__c> seguradoMap;
            Map<Id,Contract > contractMap;
           
            contractMap = new Map<Id,Contract >(
                (List<Contract> ) Database.query(
                    'SELECT Id, Empresa__c, Sucursal__c, RamoSeguro__r.Codigo__c, Numeroapolice__c, Endosso__c, ' +
                    'Status, DataEmissao__c, StartDate, VigenciaFinal__c, Proposta__r.NumeroProposta__c, Proposta__r.Origem__c, ' +
                    'Account.Cpf__c, Account.Name, Produto__c, Produto__r.Name, Produto__r.ProductCode, Account.PersonBirthdate, Account.Sexo__c ' +
                    'FROM Contract ' +
                    'WHERE Produto__c IN :prodIdSet ' + 
                    //PLV-3866 - FIX2
                    //'AND VigenciaFinal__c < ' + String.escapeSingleQuotes(busca.buscaSegurados.dataOcorrencia) + ' ' +
                    //PLV-3866 - FIX2
                    'AND Status = \'Emitido\' ' +
                        contractFilter  + ' LIMIT 1000'
                )
            );
            System.debug('contrato2 ' + contractMap.keySet());
            seguradoMap = new Map<Id,SeguradoContrato__c>([ 
                SELECT 	Id, GrupoContrato__r.ContratanteContrato__r.Contrato__c, GrupoContrato__r.ContratanteContrato__r.Numero__c,
                        GrupoContrato__r.Numero__c, Numero__c
                FROM 	SeguradoContrato__c 
                WHERE 	GrupoContrato__r.ContratanteContrato__r.Contrato__c IN: contractMap.keySet()
            ]);
			*/
            //PLV-3866 - FIM FIX2
            Case caseWithError = new Case();
            caseWithError.Subject = 'API: Consulta de Assistências de Clientes';
            caseWithError.Dataocorrencia__c = convertDate(busca.buscaSegurados.dataOcorrencia);
            caseWithError.Numero_titulo__c = busca.buscaSegurados.prestador;
            //PLV-3866 - INICIO
            caseWithError.Origin = 'Prestadora';
            //PLV-3866 - FIM
            caseWithError.Type = 'Assistencia';
            caseWithError.Resolucao__c = 'Resultado da pesquisa: ';
            //PLV-4447 INICIO
            caseWithError.Parceiro__c = getParceiroPrestadorId(busca.buscaSegurados.prestador);
            //PLV-4447 FIM
            
            //PLV-3866 - INICIO FIX2
            system.debug('res criar caso' + res);
            Integer contratosAtivos = 0;
            Integer contratosEncerrados = 0;
            Integer contratosFuturos = 0;
            List<String> listResolucao = new List<String>();
            Date dataOcorrencia = Date.valueOf(busca.buscaSegurados.dataOcorrencia);
            if((Integer.valueOf(res.resultados) > 0)){
              
               for(Segurado s : res.segurados){
                   system.debug('vigenciaFinal'+Date.valueOf(s.vigenciaFinal));
                   system.debug('dataOcorrencia'+Date.valueOf(busca.buscaSegurados.dataOcorrencia));
                   Date dtVigenciaFinal = Date.valueOf(s.vigenciaFinal);
                   Date dtVigenciaInicial = Date.valueOf(s.vigenciaInicial);
                   Integer diffDateFinal = dataOcorrencia.daysBetween(dtVigenciaFinal);
                   Integer diffDateInicial = dataOcorrencia.daysBetween(dtVigenciaInicial);
				   system.debug('diffDateFinal'+diffDateFinal);
                   system.debug('diffDateIncial'+diffDateInicial);
                   if( diffDateFinal >= 0 && diffDateInicial < 0){
                           contratosAtivos = contratosAtivos + 1;
                   }else if(diffDateFinal < 0){
                           contratosEncerrados = contratosEncerrados + 1;
                   }else if(diffDateInicial > 0){
                       contratosFuturos = contratosFuturos + 1;
                   }
               }            
            }else{
              listResolucao.add('Não localizado.');
              //caseWithError.Resolucao__c += 'Não localizado.';   
            }
                                   
            if(contratosAtivos > 0){
                listResolucao.add(contratosAtivos + ' Ativo(s)');
                //caseWithError.Resolucao__c += contratosAtivos + ' Ativo(s), ';   
            }
            if(contratosEncerrados > 0){
                listResolucao.add(contratosEncerrados + ' Encerrado(s)');
                //caseWithError.Resolucao__c += contratosEncerrados + ' Encerrado(s), ';   
            }
            if(contratosFuturos > 0){
                listResolucao.add(contratosFuturos + ' Futuro(s)');
                //caseWithError.Resolucao__c += contratosFuturos + ' Futuro(s), ';   
            }
            system.debug('listResolucao'+listResolucao);
            caseWithError.Resolucao__c = 'Resultado da pesquisa: '+String.join(listResolucao, ',');

            //PLV-3866 FIM FIX2
            
			//PLV-3866 - INICIO
			if(numeroSegurados == 1){				
				caseWithError.AccountId = contaId;
			}
			//PLV-3866 - FIM
            caseWithError.Sucesso__c = numeroSegurados > 0 ? true : false;
            caseWithError.Payload__c = 'Entrada: \n ' + buscaObj + '\n Saída: ' + res.segurados;
            
            if(busca.buscaSegurados.idSeguro != '' && busca.buscaSegurados.idSeguro != null)
                caseWithError.Description = 'Busca realizada por idSegurado:\n' + busca.buscaSegurados.idSeguro;
            
            if(busca.buscaSegurados.numeroCpf != '' && busca.buscaSegurados.numeroCpf != null)
                caseWithError.Description = 'Busca realizada por CPF: \n' + busca.buscaSegurados.numeroCpf + busca.buscaSegurados.digitoCpf;
            
            if(busca.buscaSegurados.proposta != '' && busca.buscaSegurados.proposta != null)
                caseWithError.Description = 'Busca realizada por Origem e Proposta: \n' + busca.buscaSegurados.origem + '-' + busca.buscaSegurados.proposta;
            
            if(busca.buscaSegurados.apolice != '' && busca.buscaSegurados.apolice != null){
                caseWithError.Description = 'Busca realizada por Empresa, Sucursal, Ramo, Apolice e Endosso:\n';
                caseWithError.Description += busca.buscaSegurados.empresa + ' ';
                caseWithError.Description += busca.buscaSegurados.sucursal + ' ';
                caseWithError.Description += busca.buscaSegurados.ramo + ' ';
                caseWithError.Description += busca.buscaSegurados.apolice + ' ';
                caseWithError.Description += busca.buscaSegurados.Endosso;
            }

            if (busca.buscaSegurados.nome != null && busca.buscaSegurados.nome != '')
                caseWithError.Description = 'Busca realizada por Nome:\n' + busca.buscaSegurados.nome;

            insert caseWithError;
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
        
    private static Date convertDate(String data){
        List<String> listData = data.split('-');
        return Date.newInstance(Integer.valueOf(listData[0]), Integer.valueOf(listData[1]), Integer.valueOf(listData[2]));
    }
    // PLV-3740	#Fim

    //PLV-4447 INICIO
    private static Id getParceiroPrestadorId(String siglaParceiro) {
        Id result;

        if (!String.isBlank(siglaParceiro)){
            List<Parceiro__c> l = [
                SELECT Id
                FROM Parceiro__c
                WHERE SiglaParceiro__c = :siglaParceiro
            ];

            if (l.size() > 0){
                result = l.get(0).Id;
            }
        }

        return result;
    }
    //PLV-4447 FIM
    
}