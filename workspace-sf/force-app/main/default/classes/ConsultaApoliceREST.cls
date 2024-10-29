/*******************************************************************************************************************************
* Consulta dados Básicos de Apólice/Contrato
* @author Isabela - Globant
* @date 28/04/2020
* @modifiedAt 01/04/2020
* Classe criada por conta da história PLV-3719
******************************************************************************************************************************/
@RestResource(urlMapping='/consultaApolices')
global class ConsultaApoliceREST {
    
    @HttpGet
    global static Response consultar(){
        
        Response result = new Response();
        ConsultaParam param = new ConsultaParam(RestContext.request);
        
        if(!param.isValid()) {
            result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
            return result;
        }

        ConsultaApoliceService service = new ConsultaApoliceService(param);
        result.data = service.consultar(); //PLV-3745 - INICIO/FIM

        if(!result.hasApolices()) result.setMessageErro(0, 'Apólice não encontrada.');
        return result;
    }

    global class ConsultaParam {
        public String cpf        {get; set;}
        public String numApolice {get; set;}
        public String susep      {get; set;}
        //PLV - 4193 INICIO
        public String canal 	 {get; set;}
        public String idCanal 	 {get; set;}
        //PLV - 4193 FIM
        public String codigoOferta 	 {get; set;} //II-124 FIX01 INICIO-FIM
        // PLV-4351 - INICIO
        public String nomeSegurado 	 {get; set;}
        public String statusApolice {get; set;}
        // PLV-4351 - FIM
        //PLV-4376 - FIX - INICIO
        public transient Map<String, SeguradoContrato__c> mapContratosDoSegurado { get; set; }
        //PLV-4376 - FIX - FIM

		//PLV-4197 Inicio
		public String Origem        {get; set;}
        public String Proposta {get; set;}
		public String quantidadeDeMeses {get; set;}
        //PLV-4197 Fim
        
        //PLV-4286 - INICIO
        public String empresaSucursalRamoApolice    {get; set;}        
        //PLV-4286 - FIM

        
        public ConsultaParam(RestRequest req){
            this.cpf = req.params.get('cpfContratante');
            this.numApolice = req.params.get('numeroApolice');
            this.susep = req.params.get('susep');
        	//PLV - 4193 INICIO
            this.canal = req.params.get('canal');
            this.idCanal = req.params.get('idCanal');
        	//PLV - 4193 FIM
            this.codigoOferta = req.params.get('codigoOferta'); //II-124 FIX01 INICIO-FIM
            // PLV-4351 - INICIO
            this.nomeSegurado = req.params.get('nomeSegurado');
            this.statusApolice = req.params.get('statusApolice');
            // PLV-4351 - FIM
            //PLV-4376 - FIX - INICIO
            this.mapContratosDoSegurado = new Map<String, SeguradoContrato__c>();
            //PLV-4376 - FIX - FIM 
			
			//PLV-4197 Inicio
			this.Origem = req.params.get('origem');
			this.Proposta = req.params.get('proposta');
			this.quantidadeDeMeses = req.params.get('quantidadeDeMeses');
            //PLV-4197 Fim
            
            //PLV-4286 Inicio
			this.empresaSucursalRamoApolice = req.params.get('empresaSucursalRamoApolice');
            //PLV-4286 Fim

        }

        public Boolean isValid(){
            //Validação de cpf (corretamente pontuado ou somente numérico)
            // PLV-4351 - AJUSTE NO IF (ADICIONANDO NOME SEGURADO E STATUS CONTRATO)

            //PLV-4607 Inicio							
            if(String.isNotBlank(this.numApolice) && String.isBlank(this.Proposta) && String.isBlank(this.nomeSegurado) && String.isBlank(this.cpf) && String.isBlank(this.susep) && String.isBlank(this.idCanal) && String.isBlank(this.canal) && String.isBlank(this.empresaSucursalRamoApolice)) //PLV-4286
            {
                return true;
            }
            //PLV-4607 fim
            
			//PLV-4197 Inicio							
			if(String.isBlank(this.Origem) || String.isBlank(this.Proposta)){
                
                if(String.isBlank(this.statusApolice) && String.isBlank(this.nomeSegurado) && String.isBlank(this.cpf) && String.isBlank(this.numApolice) && String.isBlank(this.susep) && (String.isBlank(this.idCanal) || String.isBlank(this.canal)) && String.isBlank(this.empresaSucursalRamoApolice)){ // PLV 4193 - inicio/fim //PLV-4286
					return false;
				}
				else{
					if(String.isNotBlank(this.cpf)){
						Pattern p = Pattern.compile('^(\\d{3}\\.\\d{3}\\.\\d{3}\\-\\d{2})?$');
						Matcher pm = p.matcher(this.cpf);
						return pm.matches() || this.cpf.isNumeric() ? Util.isCPF(this.cpf) : false; //PLV-3719 Fix - Validação de CPF
					}
					else{
						return true;
					}
				}
			}else{
				return true;
			}
			//PLV-4197 Fim											
        }
    }

    global class Response {
        public DataTO data {get;set;}
        public MetaTO meta {get;set;}

        public Response(){
            this.meta = new MetaTO();
            this.data = new DataTO();
        }

        public Boolean hasApolices(){
            return !this.data.apolices.isEmpty();
        }

        public void setMessageErro(Integer codError, String msg){
            this.data.statusChamada = codError;
            this.data.descricaoErro = msg;
        }
     } 

    global class DataTO {        
        public Integer statusChamada {get;set;}
        public String descricaoErro {get;set;}
        public ApoliceConsultaTO[] apolices {get;set;}
        
        //PLV-3745 - INICIO
        public transient Map<Id, ApoliceConsultaTO> mapApolices {get;set;}

        public DataTO(){
            this.statusChamada = 0;
            this.descricaoErro = '';
            this.apolices = new ApoliceConsultaTO[]{};
            this.mapApolices = new Map<Id, ApoliceConsultaTO>();
        }

        public void addApolice(ApoliceConsultaTO to){
            this.apolices.add(to);
            if(to.fileContrato.recId != null) this.mapApolices.put(to.fileContrato.recId, to);
            if(to.fileProposta.recId != null) this.mapApolices.put(to.fileProposta.recId, to);
            System.Debug('mapApolices ' + mapApolices);
        }

        public Set<Id> getIds(){
            return this.mapApolices.keySet();
        }

        public Set<Id> getIdContent(){
            Set<Id> result = new Set<Id>();
            for(ApoliceConsultaTO to :this.apolices){
                if(!to.fileContrato.hasFile()) result.add(to.fileContrato.recId);
                if(!to.fileProposta.hasFile()) result.add(to.fileProposta.recId);
            }
            return result;
        }

        public ArquivoTO getTO(Id recId){
            ApoliceConsultaTO to = this.mapApolices.get(recId);
            if(to == null) return null;
            if(to.fileContrato.recId == recId) return to.fileContrato;
            if(to.fileProposta.recId == recId) return to.fileProposta;

            return null;
        }
        //PLV-3745 - FIM
    }
    
    global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'consultaapolices';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

    global class ApoliceConsultaTO {
        
        //PLV-3745 - INICIO
        public transient ArquivoTO fileContrato {get;set;}
        public transient ArquivoTO fileProposta {get;set;}
        //PLV-3745 - FIM
        
        public Integer numeroApolice {get;set;}
        public Integer numeroProposta {get;set;} //PLV-4758-FIX4 //PLV-4758-FIX5
        public String statusApolice {get;set;}
        public String vigenciaInicial {get;set;}
        public String vigenciaFinal {get;set;}
        public String segmento {get;set;} // PLV 4480 - Inicio/Fim

        //FNPVVEP-98 INICIO
        public Datetime horaExpiracaoLink { get; set; }
        //FNPVVEP-98 FIM

        // PLV-4343  - INICIO
        public String formaPagamento {get;set;}
        public Double valorPremio {get;set;}
        // PLV-4343  - FIM
        
        //  PLV-4264 - Inicio 
        public String endosso {get;set;}
        public String sucursal {get;set;}
        //  PLV-4264 - FIM

        // PLV - 5554 - INICIO
        public String empresa {get;set;}
        // PLV - 5554 - FIM

        public String responsavelFinanceiro {get;set;}
        // PLV-4343 - INICIO
        // public String responsavelFinanceiroCPF {get;set;}
        // PLV-4343 - FIM
        public String modalidadeSeguro {get;set;}
        public String produto {get;set;}
        public Integer codidoRamoSeguro {get;set;}
        public String tipodaViagem {get;set;}
        public String destino {get;set;}
        public Integer passageiro0a70 {get;set;}
        public Integer passageiro71a90 {get;set;}
        public String praticaAventura {get;set;}
        public String visitaPaisesEuropeu {get;set;}
        public String usaMotocicleta {get;set;}
        public Double premioTotal {get;set;}

        //PLV-3981 - INICIO
        public String dataEmissao {get;set;}
        public String tipo {get; set;}
        public String canalDeContratacao {get; set;}
        public String corretor {get; set;}        
        //PLV-3981 - FIM        
        
        //PLV-4193 - INICIO
        public String apolicePdfDownloadUrl {get;set;}
        public String voucherPdfDownloadUrl {get;set;}
        //PLV-4193 - FIM

        public String endossoPdfDownloadUrl {get;set;} //PLV-5554 INICIO - FIM
        
        //PLV-3745 - INICIO
        public String tokenApolice {
            get{
                return this.fileContrato.token;
            }
        }
        
        public String tokenVoucher { 
            get{
                return this.fileProposta.token;
            }
        }
        //PLV-3745 - FIM

        //PLV-4255 - INICIO               
        public string nomeCorretor {get;set;}   
        public RemuneracaoContratoConsultaTO[] remuneracaoDoContrato {get;set;}   
        //PLV-4255 - FIM
        
        public BeneficiariosContratoConsultaTO[] beneficiarios {get;set;} //PLV - 4553 - INICIO/FIM
        
        public ParcelasContratoConsultaTO[] parcelas {get;set;} //PLV-4286
        
        public DadosContratanteConsultaTO[] dadosContratante {get;set;}
        public GarantiasContratoConsultaTO[] garantiasDoContrato {get;set;}
		
		//PLV-4197 Inicio
		public string Origem {get;set;}
		public string dataTransmissao {get;set;}       
        //PLV-4197 Fim

		//PLV 4653 Inicio
		public Decimal percentualProposta				{get;set;}
		public Decimal percentualPropostaCorretagem		{get;set;}
		public Decimal percentualPropostaAgenciamento	{get;set;}
		//PLV 4653 Fim
		        
        public ApoliceConsultaTO(Contract contrato){
            Quote proposta = contrato.Proposta__r;
            
            //PLV-4758-FIX5 - inicio
            //PLV-4758-FIX4 - inicio
            this.numeroProposta = Integer.valueOf(proposta.NumeroProposta__c);
            //PLV-4758-FIX4 - fim
            //PLV-4758-FIX5 - fim
            
			//PLV-4197 Inicio
			this.Origem = proposta.Origem__c;
			this.dataTransmissao = formatarData(contrato.DataEmissao__c);
			//PLV-4197 Inicio

            //FNPVVEP-98 INICIO
            this.horaExpiracaoLink = contrato.Hora_Expiracao_Link__c;
            //FNPVVEP-98 FIM

			Modalidade__c modalidade = contrato.ModalidadeSeguro__r;            
            this.modalidadeSeguro = modalidade.Name;
            
            Product2 produto = contrato.Produto__r;
            this.produto     = produto.Name;
            // PLV-4343 - INICIO
            // Preenchimento de responsável financeiro de contratante do tipo "Principal"
            for(ContratanteContrato__c con : contrato.ContratantesContrato__r){
                if(con.Tipo__c == 'Principal') this.responsavelFinanceiro = con.Conta__r.Name;
            }
            // this.responsavelFinanceiro = contrato.Account.Name;
            // this.responsavelFinanceiroCPF = contrato.Account.CPF__c;
            // PLV-4343 - FIM
            
            //PLV-3745 - INICIO
            this.fileContrato=  new ArquivoTO(contrato.Id);
            this.fileProposta = new ArquivoTO(proposta.Id);
            //PLV-3745 - FIM

            this.numeroApolice = String.isNotBlank(contrato.NumeroApolice__c) ? Integer.valueOf(contrato.NumeroApolice__c) : null;
            this.statusApolice = contrato.Status;
            this.codidoRamoSeguro = String.isNotBlank(contrato.CodigoRamo__c) ? Integer.valueOf(contrato.CodigoRamo__c) : null;
            this.tipodaViagem = contrato.TipoViagem__c;
            //  PLV-4264 - Inicio 
            this.endosso = contrato.Endosso__c;
            this.sucursal = contrato.Sucursal__c;
            //  PLV-4264 - FIM 
            // PLV - 5554 - INICIO
            this.empresa = contrato.Empresa__c;
            // PLV - 5554 - FIM

            //PLV-3879 - INICIO
            this.destino = contrato.PaisesDestino__c;
            //PLV-3879 - FIM
            this.passageiro0a70 = contrato.QuantidadePassageiros070Anos__c != null ? Integer.valueOf(contrato.QuantidadePassageiros070Anos__c) : null;
            this.passageiro71a90 = contrato.VidasEntre7190Anos__c != null ? Integer.valueOf(contrato.VidasEntre7190Anos__c) : null;
            this.praticaAventura = contrato.ViagemAventura__c ? 'Sim' : 'Não';
            this.visitaPaisesEuropeu = contrato.IncluiPaisEuropeu__c ? 'Sim' : 'Não';
            this.usaMotocicleta = contrato.UtilizaMoto__c ? 'Sim' : 'Não';
            this.premioTotal = contrato.PremioTotal__c; 
            this.dataEmissao = formatarData(contrato.DataEmissao__c);
            this.vigenciaInicial = formatarData(contrato.StartDate);
            this.vigenciaFinal = formatarData(contrato.VigenciaFinal__c);
            this.segmento = contrato.Segmento__c; //PLV-4480 Inicio/Fim

           //PLV-3981 - INICIO
            this.tipo = contrato.Tipo__c;
            this.canalDeContratacao = contrato.MeioComercializacao__c;
            this.corretor = contrato.CodigoCorretor__r.Name;
            //PLV-3981 - FIM

            // PLV-4343  - INICIO
            //PLV-4553 - INICIO
            //PLV-4758 FIX 1 INICIO
            //CondicaoCobranca__c condicaoCobranca = [SELECT Id, TipoPagamento__c FROM CondicaoCobranca__c WHERE FormaPagamento__c =:contrato.FormaPagamento__r.Id ORDER BY Name ASC Limit 1];
            if (contrato.FormaPagamento__c <> null) { 
                Map<Id, CondicaoCobranca__c> condicaoCobrancaByFormaPagamento = ConsultaApoliceService.getMapCondCobrancaPagamento();
                
                if (condicaoCobrancaByFormaPagamento != null && condicaoCobrancaByFormaPagamento.containsKey(contrato.FormaPagamento__c)) {
                    this.formaPagamento = condicaoCobrancaByFormaPagamento.get(contrato.FormaPagamento__c).TipoPagamento__c;
                    System.debug('1 - ApoliceTO formaPagamento => ' + this.formaPagamento);
                }
            }
            //PLV-4758 FIX 1 FIM
            //PLV-4553 - FIM
            this.valorPremio = contrato.ValorPremio__c;
            // PLV-4343  - FIM
           // MGRC-567 INCIO
            //https://portoapicloud-hml.portoseguro.com.br/vida/crm/acessorios/v1/documentos/c..r40MHq7Rv2XNt86uxxZV4j2X1PJpMc60iIMMSHgi03lO08..Y5f5LuHX6avjS3zgr77Zjjmd0R2wsS5BgY8..w==
            //PLV-4193 - INICIO
          // this.apolicePdfDownloadUrl = contrato.ApolicePdfDownloadUrl__c;
          //  this.voucherPdfDownloadUrl = contrato.Proposta__r.VoucherPdfDownloadUrl__c;
         
           this.apolicePdfDownloadUrl = String.isNotBlank(contrato.ApolicePdfDownloadUrl__c) ?  System.Label.hostSensediaAWS + +'/vida/crm/acessorios/v1/documentos/'+contrato.ApolicePdfDownloadUrl__c.subStringAfter('doGet/') : null; 
           this.voucherPdfDownloadUrl = String.isNotBlank(contrato.Proposta__r.VoucherPdfDownloadUrl__c) ?  System.Label.hostSensediaAWS + +'/vida/crm/acessorios/v1/documentos/'+ contrato.Proposta__r.VoucherPdfDownloadUrl__c.subStringAfter('doGet/') : null; 
          
           this.endossoPdfDownloadUrl = String.isNotBlank(contrato.EndossoPdfDownloadUrl__c) ?  System.Label.hostSensediaAWS+'/vida/crm/acessorios/v1/documentos/'+ contrato.EndossoPdfDownloadUrl__c.subStringAfter('doGet/') : null; 
                  
          //PLV-4193 - FIM   
          // MGRC-567 FIM
            //PLV-4255 - INICIO                                               
            this.nomeCorretor = contrato.CodigoCorretor__r.NomeCorretor__r.Name;            
            this.remuneracaoDoContrato = new RemuneracaoContratoConsultaTO[]{};         
            //PLV-4255 - FIM

            this.beneficiarios = new BeneficiariosContratoConsultaTO[]{};//PLV - 4553 - INICIO/FIM

            this.parcelas = new ParcelasContratoConsultaTO[]{}; //PLV-4286
            
            this.dadosContratante = new DadosContratanteConsultaTO[]{};
            this.garantiasDoContrato = new GarantiasContratoConsultaTO[]{};                        
        }
		
        //Preenchendo dados do contratante pelo construtor
        public void addDadosContratante(ContratanteContrato__c con){
            this.dadosContratante.add(new DadosContratanteConsultaTO(con));
        }
        //PLV-4376 - FIX - INICIO
        //As tags de contratante no json de retorno serão utilizadas para retornar os dados do segurado temporariamente
        //para que não ocorra impacto na solução do Portal do corretor. Será ajustado em uma história futura.
        public void addDadosContratante(SeguradoContrato__c segurado){
            this.dadosContratante.add(new DadosContratanteConsultaTO(segurado));
        }        
        //PLV-4376 - FIX - FIM

        //PLV-4343-FIX INICIO
        //PLV-4758 FIX 3 INICIO
        public void addDadosContratante(Account conta, SeguradoContrato__c segurado){
            this.dadosContratante.add(new DadosContratanteConsultaTO(conta, segurado));
        }     
        //PLV-4758 FIX 3 FIM
        //PLV-4343-FIX FIM

        //Preenchendo dados da garantia do contrato pelo construtor
        public void addDadosGarantia(GarantiaContrato__c garan){
            this.garantiasDoContrato.add(new GarantiasContratoConsultaTO(garan));
        }

        //PLV-4255 - INICIO
        //Preenchendo dados do corretor pelo construtor
        public void addDadosRemuneracao(RemuneracaoContrato__c remContract){
            //PLV 4653 Inicio
			if(remContract.TipoRemuneracao__r.Name == 'AGENCIAMENTO'){
				this.percentualProposta = this.percentualPropostaAgenciamento;	
			}else if(remContract.TipoRemuneracao__r.Name == 'CORRETAGEM'){
				this.percentualProposta = this.percentualPropostaCorretagem;
			}
			this.remuneracaoDoContrato.add(new RemuneracaoContratoConsultaTO(remContract, this.percentualProposta));
			//PLV 4653 Fim
        }
        //PLV-4255 - FIM
						   
        //PLV-4553 - INICIO
        public void addDadosBeneficiarios(BeneficiarioSeguradoContrato__c beneficiarioContrato){
            this.beneficiarios.add(new BeneficiariosContratoConsultaTO(beneficiarioContrato));
        }
        //PLV-4553 - INICIO
        
        //PLV-4286 - INICIO
        public void addParcelasContratos(ParcelamentoContratoTO.DataTO parcelaContrato){
            this.parcelas.add(new ParcelasContratoConsultaTO(parcelaContrato));
        }
		//PLV-4286 - FIM
    }

    global class DadosContratanteConsultaTO {
        public String cpfContratante {get;set;}
        public String nome {get;set;}
        public String nomeSocial {get;set;} //LECVPV-177 - INICIO/FIM
        public String dataNascimento {get;set;}
        //PLV 4193 - INICIO
        public String quantidadeParcelas {get;set;}
        public String formaPagamento {get;set;}
        //Código removido pois não precisara das parcelas
        //PLV 4193 - FIM        
        // PLV-4553 Inicio
        public String fumante {get;set;}
        public String profissao {get;set;}
        public String formaTrabalho {get;set;}
        public String faixaRenda {get;set;}
        // PLV-4553 Fim        
        //PLV-4255 - INICIO       
        public String sexoContratante {get;set;}
        public String emailContratante {get;set;}
        public String logradouroContratante {get;set;}
        public String cidadeContratante {get;set;}
        public String ufContratante {get;set;}
        public String cepContratante {get;set;}
        public String paisContratante {get;set;}                   
        //PLV-4255 - FIM

        //PLV - 4553 - INICIO
        /*publcis String fumante {get;set;}
        publcis String formaTrabalho{get;set;}*/
        public String tempoRendaProtegida {get;set;}
        public String dependentesFinancerios {get;set;}
        //PLV - 4553 - FIM
        // MGRC-488 INICIO
        public String  estadoCivilContratante {get;set;}
        public String  dataExpedicaoDoc {get;set;}
        // MGRC-488 FIM
        public DadosContratanteConsultaTO(ContratanteContrato__c con){
            Account contaContratante = con.Conta__r;
            //PLV-4758 FIX 1 INICIO 
            //CondicaoCobranca__c condicaoCobranca = [SELECT Id, TipoPagamento__c FROM CondicaoCobranca__c WHERE FormaPagamento__c =:con.FormaPagamento__r.Id ORDER BY Name ASC Limit 1]; //PLV-4553 - INICIO/FIM
            this.cpfContratante = String.isNotBlank(contaContratante.Cpf__c) ? contaContratante.Cpf__c.remove('.').remove('-') : null;
            this.nome = contaContratante.Name;
            this.nomeSocial = con.conta__r.NomeSocial__c; //LECVPV-177 - INICIO/FIM
            this.dataNascimento = formatarData(contaContratante.PersonBirthdate);
            
        	//PLV 4193 - INICIO
            this.quantidadeParcelas = String.ValueOf(con.QuantidadeParcelas__c);
            if (con.FormaPagamento__c != null) {
                Map<Id, CondicaoCobranca__c> condicaoCobrancaByFormaPagamento = ConsultaApoliceService.getMapCondCobrancaPagamento();

                if (condicaoCobrancaByFormaPagamento != null && condicaoCobrancaByFormaPagamento.containsKey(con.FormaPagamento__c)) {
                    this.formaPagamento = condicaoCobrancaByFormaPagamento.get(con.FormaPagamento__c).TipoPagamento__c;
                    System.debug('2 - DadosContratanteConsultaTO ContratanteContrato formaPagamento => ' + this.formaPagamento);
                }
            }
            //PLV-4758 FIX 1 FIM
    		//Código removido pois não precisara das parcelas
            //PLV 4193 - FIM

            //PLV-4255 - INICIO                                    
            this.sexoContratante = con.Conta__r.Sexo__c;
            this.emailContratante = con.Conta__r.PersonEmail;
            this.logradouroContratante = con.Conta__r.BillingStreet;
            this.cidadeContratante = con.Conta__r.BillingCity;
            this.ufContratante = con.Conta__r.BillingState;
            this.cepContratante = con.Conta__r.BillingPostalCode;
            this.paisContratante = con.Conta__r.BillingCountry;           
            //PLV-4255 - FIM       
            
            //PLV - 4553 - INICIO
            this.fumante  = con.Conta__r.Fumante__c;
            this.formaTrabalho = con.Conta__r.RegimeTrabalho__c;
            this.tempoRendaProtegida = con.Contrato__r.PorQuantoTempoQuerGarantirRenda__c;
            this.dependentesFinancerios = con.Contrato__r.DependentesFinanceiros__c == true? 'Sim':'Não';
            //PLV - 4553 - FIM
        }

        //PLV-4376 - FIX - INICIO
        //As tags de contratante no json de retorno serão utilizadas para retornar os dados do segurado temporariamente
        //para que não ocorra impacto na solução do Portal do corretor. Será ajustado em uma história futura.
        public DadosContratanteConsultaTO(SeguradoContrato__c seguradoContrato){
            Account contaSegurado = seguradoContrato.Conta__r;
            //PLV-4758 FIX 1 INICIO
            //CondicaoCobranca__c condicaoCobranca = [SELECT Id, TipoPagamento__c FROM CondicaoCobranca__c WHERE FormaPagamento__c =:seguradoContrato.grupoContrato__r.contratanteContrato__r.FormaPagamento__r.Id ORDER BY Name ASC Limit 1]; //PLV-4553 - INICIO/FIM
            if (seguradoContrato.grupoContrato__r.contratanteContrato__r.FormaPagamento__c != null) {
                Map<Id, CondicaoCobranca__c> condicaoCobrancaByFormaPagamento = ConsultaApoliceService.getMapCondCobrancaPagamento();

                if (condicaoCobrancaByFormaPagamento != null && condicaoCobrancaByFormaPagamento.containsKey(seguradoContrato.grupoContrato__r.contratanteContrato__r.FormaPagamento__c)) {
                    this.formaPagamento = condicaoCobrancaByFormaPagamento.get(seguradoContrato.grupoContrato__r.contratanteContrato__r.FormaPagamento__c).TipoPagamento__c;
                    System.debug('3 - DadosContratanteConsultaTO SeguradoContrato formaPagamento => ' + this.formaPagamento);
                }
            }
            //PLV-4758 FIX 1 FIM

            this.cpfContratante = String.isNotBlank(contaSegurado.Cpf__c) ? contaSegurado.Cpf__c.remove('.').remove('-') : null;
            this.nome = contaSegurado.Name;
            this.nomeSocial = contaSegurado.NomeSocial__c; //LECVPV-177 - INICIO/FIM
            this.dataNascimento = formatarData(contaSegurado.PersonBirthdate);            
            this.sexoContratante = contaSegurado.Sexo__c;
            this.emailContratante = contaSegurado.PersonEmail;
            // PLV-4553 Inicio
            this.fumante = contaSegurado.Fumante__c;
            this.profissao = contaSegurado.Profissao__r.Name;
            this.formaTrabalho = contaSegurado.RegimeTrabalho__c;
            this.faixaRenda = String.valueOf(seguradoContrato.FaixaRenda__c);
            this.tempoRendaProtegida = seguradoContrato.grupoContrato__r.contratanteContrato__r.Contrato__r.PorQuantoTempoQuerGarantirRenda__c;
            this.dependentesFinancerios = seguradoContrato.grupoContrato__r.contratanteContrato__r.Contrato__r.DependentesFinanceiros__c == true? 'Sim':'Não';
            // PLV-4553 Fim
            this.logradouroContratante = contaSegurado.BillingStreet;
            this.cidadeContratante = contaSegurado.BillingCity;
            this.ufContratante = contaSegurado.BillingState;
            this.cepContratante = contaSegurado.BillingPostalCode;
            this.paisContratante = contaSegurado.BillingCountry; 
            // PLV-4343 - INICIO
            this.quantidadeParcelas = String.valueOf(seguradoContrato.grupoContrato__r.contratanteContrato__r.QuantidadeParcelas__c);
            //PLV-4758 FIX 1 INICIO
            //this.formaPagamento = condicaoCobranca.TipoPagamento__c; //PLV-4553 - INICIO/FIM 
            //PLV-4758 FIX 1 FIM
            // PLV-4343 - FIM
            
        }

        //PLV-4343 INICIO
        //PLV-4758 FIX 3 INICIO
        public DadosContratanteConsultaTO(Account contaSegurado, SeguradoContrato__c seguradoContrato){
            //SeguradoContrato__c seguradoContrato = [
            //    SELECT id, grupoContrato__r.contratanteContrato__r.contrato__c,
            //    grupoContrato__r.contratanteContrato__r.QuantidadeParcelas__c,
            //    grupoContrato__r.contratanteContrato__r.FormaPagamento__r.Name,
			//	//PLV-4553 - INICIO
            //    grupoContrato__r.contratanteContrato__r.Contrato__r.PorQuantoTempoQuerGarantirRenda__c,
            //    grupoContrato__r.contratanteContrato__r.Contrato__r.DependentesFinanceiros__c, FaixaRenda__c, 
			//	//PLV-4553 - FIM
            //    Conta__c, Conta__r.Name, Conta__r.CPF__c, Conta__r.PersonBirthdate,
            //    Conta__r.Sexo__c, Conta__r.PersonEmail, Conta__r.BillingStreet, Conta__r.BillingCity, 
            //    Conta__r.BillingState, Conta__r.BillingPostalCode, Conta__r.BillingCountry
            //    FROM SeguradoContrato__c 
            //    WHERE conta__r.cpf__c = :contaSegurado.CPF__c and GrupoContrato__r.ContratanteContrato__r.Contrato__c =: contratoId];
            //    
            //PLV-4758 FIX 3 FIM
            //PLV-4758 FIX 1 INICIO
            //CondicaoCobranca__c condicaoCobranca = [SELECT Id, TipoPagamento__c FROM CondicaoCobranca__c WHERE FormaPagamento__c =:seguradoContrato.grupoContrato__r.contratanteContrato__r.FormaPagamento__r.Id ORDER BY Name ASC Limit 1]; //PLV-4553 - INICIO/FIM
            //PLV-4758 FIX 1 FIM

            this.cpfContratante = String.isNotBlank(contaSegurado.Cpf__c) ? contaSegurado.Cpf__c.remove('.').remove('-') : null;
            this.nome = contaSegurado.Name;
            this.nomeSocial = contaSegurado.NomeSocial__c; //LECVPV-177 - INICIO/FIM
            this.dataNascimento = formatarData(contaSegurado.PersonBirthdate);            
            this.sexoContratante = contaSegurado.Sexo__c;
            this.emailContratante = contaSegurado.PersonEmail;
            this.logradouroContratante = contaSegurado.BillingStreet;
            this.cidadeContratante = contaSegurado.BillingCity;
            this.ufContratante = contaSegurado.BillingState;
            this.cepContratante = contaSegurado.BillingPostalCode;
            this.paisContratante = contaSegurado.BillingCountry; 
            // PLV-4553 INICIO
            this.fumante = contaSegurado.Fumante__c;
            this.profissao = contaSegurado.Profissao__r.Name;
            this.formaTrabalho = contaSegurado.RegimeTrabalho__c;
            //this.renda = String.valueOf(contaSegurado.Renda__c);
            // PLV-4553 FIM
            //MGRC-488 INICIO
            this.estadoCivilContratante = String.isNotBlank(contaSegurado.EstadoCivil__c) ? contaSegurado.EstadoCivil__c : '';
            this.dataExpedicaoDoc = String.isNotBlank(String.ValueOf(contaSegurado.DataExpedicao__c)) ? formatarData(contaSegurado.DataExpedicao__c):'';  
            //MGRC-488 FIM

            if(seguradoContrato != null){
                this.quantidadeParcelas = String.valueOf(seguradoContrato.grupoContrato__r.contratanteContrato__r.QuantidadeParcelas__c);
                //PLV-4553 - INICIO
                //PLV-4758 FIX 1 INICIO
                //PLV-4917 INICIO
                if (seguradoContrato.grupoContrato__r.contratanteContrato__r.FormaPagamento__c != null) {

                     this.formaPagamento = seguradoContrato.grupoContrato__r.contratanteContrato__r.FormaPagamento__r.Name;
                     System.debug('4 - DadosContratanteConsultaTO Conta Contrato formaPagamento => ' + this.formaPagamento);
                }
                //PLV-4917 FIM
                //PLV-4758 FIX 1 FIM
                this.tempoRendaProtegida = seguradoContrato.grupoContrato__r.contratanteContrato__r.Contrato__r.PorQuantoTempoQuerGarantirRenda__c;
                this.dependentesFinancerios = seguradoContrato.grupoContrato__r.contratanteContrato__r.Contrato__r.DependentesFinanceiros__c == true? 'Sim':'Não';
                this.faixaRenda = String.valueOf(seguradoContrato.FaixaRenda__c);
                //PLV-4553 - INICIO
			}
        }
        //PLV-4343 FIM
    }

    //PLV 4193 - INICIO    
    //Código removido pois não precisara das parcelas
    //PLV 4193 - FIM

    global class GarantiasContratoConsultaTO {
        public String garantia {get;set;}
        public Double capital {get;set;}
        
        public GarantiasContratoConsultaTO(GarantiaContrato__c garan){
        	Garantia__c g = garan.Garantia__r;
        	this.garantia = g.Name;
        	this.capital = garan.Capital__c;   
        }
    }

    //PLV-4255 - INICIO
    global class RemuneracaoContratoConsultaTO {
        public String tipoRemuneracaoContrato {get;set;}
        public Double percentualContrato {get;set;}
        public Double agenciamento {get;set;} //PLV - 4553 - INICIO/FIM

        //PLV - 4653 Inicio
        public RemuneracaoContratoConsultaTO(RemuneracaoContrato__c remContrato, Decimal percentualProposta){        	
            this.tipoRemuneracaoContrato = remContrato.TipoRemuneracao__r.name;               
			//this.percentualContrato = remContrato.Percentual__c;
			this.percentualContrato = percentualProposta;
		//PLV - 4653 Fim  
            this.agenciamento = remContrato.Porcentagem_de_Retencao__c; //PLV - 4553 - INICIO/FIM              
        }		
    }
    //PLV-4255 - FIM

    //PLV-4553 - INICIO
    global class BeneficiariosContratoConsultaTO {
        public String nome {get;set;}
        public String nomeSocial {get;set;} //LECVPV-177 - INICIO/FIM
        public String dataDeNascimento {get;set;}
        public String tiposDeBeneficiario {get;set;}
        public String grauDeParentesco {get;set;}
        public String grauDeParentescoEspecifico {get;set;}
        public Decimal porcentagemDeIndenizacao {get;set;}
        public String cpf {get;set;}
        
        public BeneficiariosContratoConsultaTO(BeneficiarioSeguradoContrato__c beneficiarioContrato){
            
            
            this.nome =  beneficiarioContrato.Nome__c;
            this.nomeSocial =  beneficiarioContrato.NomeSocial__c; //LECVPV-177 - INICIO/FIM
            this.dataDeNascimento = String.ValueOf(beneficiarioContrato.Data_de_Nascimento__c);
            this.tiposDeBeneficiario = beneficiarioContrato.TipoBeneficiario__c;
            this.grauDeParentesco = beneficiarioContrato.GrauParentesco__c;
            //this.grauDeParentescoEspecifico = beneficiarioContrato
            this.porcentagemDeIndenizacao = beneficiarioContrato.PercentualIndenizacao__c;
            this.cpf = beneficiarioContrato.CpfCnpj__c;
           
        }
    }
    //PLV-4553 - FIM

    //PLV-4286 - INICIO
    global class ParcelasContratoConsultaTO {        
		public String status                { get; set; }
		public Decimal valorpremiomensal    { get; set; }
		public Integer numeroparcela        { get; set; }
		public String datavencimento        { get; set; }
        public String datapagamento         { get; set; }
		        
        public ParcelasContratoConsultaTO(ParcelamentoContratoTO.DataTO parcelaContrato){
            
            this.status = parcelaContrato.status; 
            this.valorpremiomensal = decimal.ValueOf(parcelaContrato.valorparcela);            
            this.numeroparcela = parcelaContrato.numeroparcela;            
            this.datavencimento = parcelaContrato.datavencimento != null ? formatarData(date.valueOf(parcelaContrato.datavencimento)) : null;                        
            this.datapagamento = parcelaContrato.datapagamento != null ?formatarData(date.valueOf(parcelaContrato.datapagamento)) : null;               
        }
    }
    //PLV-4286 - FIM

    //PLV-3745 - INICIO
    global class ArquivoTO {
        public Id     recId    {get; private set;}
        public String token    {get; private set;}

        public String fileName {
            set {
                if(String.isBlank(value)) return;
                CryptoToken token = new CryptoToken();
                this.fileName = value.contains('.pdf') ? value : value + '.pdf';
                this.token   = token.encrypt(this.recId + '|' + this.fileName);
            }
            get {
                return String.isBlank(this.fileName) ? '' : this.fileName;
            }
        }
        
        public ArquivoTO (Id recId){
            this.recId = recId;
            this.token = '';
        }

        public Boolean hasFile(){
            return String.isNotBlank(this.token);
        }
    }
	//PLV-3745 - FIM
    
    private static String formatarData(Date d){
       	return d != null ? DateTime.newInstance(d.year(),d.month(),d.day()).format('dd/MM/YYYY') : null;
    }
}