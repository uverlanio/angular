/*******************************************************************************************************************************
* 
* @author Leonardo - Globant
* @date 15/07/2020
* @modifiedAt 
* Classe criada por conta da história PLV-4094
* Classe TO para o serviço do Civ Sinistro
******************************************************************************************************************************/
global with sharing class CivSinistroTO {
    
    private CivSinistroTO(){}
	
	global class Sinistro {
        public Request sinistro;       
	}  
    
    /***** clase de estrutura do Json de entrada do serviço  **/
    global class Request {
        public String                   nomeSegurado                {get; set;}
        public String                   cpfSegurado                 {get; set;}
        public String                   digitoCpfSegurado           {get; set;}
        public String                   dataOcorrencia              {get; set;}
        public String                   assunto                     {get; set;}
        public String                   descricao                   {get; set;}
        public String                   origem                      {get; set;}
        public String                   prestadora                  {get; set;}
        public String                   vitima                      {get; set;}
        public String                   idAtendimentoPrestadora     {get; set;}
        public String                   tipoEvento                  {get; set;}
		public String                   avisado                     {get; set;}
        public String                   empresa                     {get; set;}
        public String                   sucursal                    {get; set;}
        public String                   ramo                        {get; set;}
        public String                   apolice                     {get; set;}
        public String                   endosso                     {get; set;}        
        public Boolean                  sinistroPrioritario         {get; set;}        
		//4096 inicio
		public String                   edsTip                      {get; set;}
        //4096 fim
		//PLV-4094 - INICIO
        public Id                       caseId                      {get; set;}
        public String                   numeroSinistro              {get; set;}
        //PLV-4094 - FIM
        public List<GarantiaSinistroTO> garantias                   {get; set;} 
       
        public transient String         prestadoraName              {get; private set;}//PLV-4509 - Inicio/Fim
        public transient Contract       contrato                    {get; private set;} 
        public transient Account        segurado                    {get; private set;}
        public transient Contact        contatoSegurado             {get; private set;}
        public transient Parceiro__c    contaPrestadora             {get; private set;}        
        public transient Boolean        numeroSinistroExiste        {get; private set;} //PLV-4094 - INICIO/FIM
        
        public transient SeguradoContrato__c             seguradoContrato                {get; private set;}
        public transient Map<String, GarantiaSinistroTO> mapGarantia                     {get; private set;} 
        //PLV-4509 - Inicio
        public transient Map<String,List<BeneficiarioSinistroTO>> mapBeneficiarios       {get; private set;} 
        public transient List<CivSinistroTO.BeneficiarioSinistroTO> listBeneficiariosTO  {get; private set;}     
        //PLV-4509 - Fim   
        
        public Request(){
            this.garantias = new List<GarantiaSinistroTO>();                     
        }

        public void fillData(){

            //PLV - 4166_FIX - INICIO
            String numeroContratoConcat = empresa + '-' + sucursal + '-' + ramo + '-' + apolice + '-' + endosso;            System.debug('numeroContratoConcat: ' + numeroContratoConcat);
            
            //PLV - 4166_FIX - FIX

            Contract[] lsContract = [
                SELECT AccountId, Account.cpf__c
                FROM Contract
                WHERE name = :numeroContratoConcat //PLV - 4166_FIX - INICIO/FIM
                //WHERE NumeroApolice__c = :this.apolice.substring(0,9) //PLV - 4166_FIX - INICIO/FIM
                 AND  NumeroApolice__c <> null
            ];

            if(lsContract.isEmpty()) return;

            this.contrato = lsContract.get(0);
            this.segurado = contrato.Account;

            if(this.segurado == null) return;

            //contato do segurado
            Contact[] lsContact = [
                SELECT Id FROM Contact WHERE AccountId = :this.segurado.Id LIMIT 1
            ];
                    
            if(lsContact.isEmpty()) return;
            this.contatoSegurado = lsContact.get(0);

            //conta da prestadora
            //PLV-4509 - Inicio
            Parceiro__c[] listPrestadora = [
                SELECT id, conta__c,SiglaParceiro__c, Conta__r.name 
                FROM Parceiro__c
                WHERE Status__c = 'Ativo'                
                AND SiglaParceiro__c  = :this.prestadora
                //AND Conta__r.name  = :this.prestadora
            //PLV-4509 - Fim
                // AND Conta__r.Cpf__c  = :this.setCpfprestadoraSigla
                // AND Ramo__c = :this.ParametroEntrada.ramo
                // AND Empresa__c = :this.ParametroEntrada.empresa
                LIMIT 1
            ];
            
            if(listPrestadora.isEmpty()) return;

            this.ContaPrestadora = listPrestadora.get(0);
            this.prestadoraName = listPrestadora.get(0).Conta__r.name ; //PLV-4509 - Inicio/Fim
            system.debug('naemPrestadore: '+prestadoraName);

            //garantias
            //converter as garantias TO em um map
            this.mapGarantia = new Map<String, GarantiaSinistroTO>();
            //PLV-4509 - Inicio
            this.mapBeneficiarios = new Map<String, List<BeneficiarioSinistroTO>>();
            this.listBeneficiariosTO = new  List<CivSinistroTO.BeneficiarioSinistroTO>(); 
            //PLV-4509 - Fim
            for(GarantiaSinistroTO garantia : this.garantias){
                this.mapGarantia.put(garantia.sigla, garantia);
                 //PLV-4509 - Inicio
                this.mapBeneficiarios.put(garantia.sigla, garantia.beneficiarios);  
                listBeneficiariosTO.addAll(garantia.beneficiarios);  
                 //PLV-4509 - Fim              
            }

            //PLV-3904 - INICIO
            for(GarantiaSeguradoContrato__c gsc : [
                SELECT garantia__r.sigla__c, garantia__c, garantia__r.name,
                        SeguradoContrato__r.Name , Capital__c,
                        SeguradoContrato__r.VigenciaFinal__c,
                        SeguradoContrato__r.VigenciaInicial__c,
                        GarantiaProduto__r.VigenciaGarantia__c
                 FROM GarantiaSeguradoContrato__c 
                WHERE SeguradoContrato__r.Conta__c = :this.segurado.Id
                 AND  garantia__r.sigla__c = :this.getMapGarantia().keySet()
                 AND  SeguradoContrato__r.GrupoContrato__r.ContratanteContrato__r.Contrato__c = :this.contrato.Id
            ]){
                String sigla = gsc.garantia__r.sigla__c;

                if(this.seguradoContrato == null) this.seguradoContrato = gsc.seguradoContrato__r;

                GarantiaSinistroTO garantia = this.mapGarantia.get(sigla);
                if(garantia == null) continue;
                garantia.garantiaSegurado = gsc;
                garantia.segurado = gsc.SeguradoContrato__r;
                garantia.garantiaProduto = gsc.GarantiaProduto__r;                
            }
            //PLV-3904 - FIM

            //PLV-4094 - INICIO
            //PLV-4826 - Inicio
            if(String.isBlank(this.numeroSinistro)){
                this.numeroSinistroExiste = false;
                return;
            } 
            //PLV-4826 - Fim
            List<Case> casoExistente = [
                SELECT Id 
                FROM Case 
                WHERE NumeroSinistro__c = :this.numeroSinistro
            ];
            
            this.numeroSinistroExiste = !casoExistente.isEmpty() ? true : false;
            //PLV-4094 - FIM             
        }

        public Date getDateOcorrencia(){
            Date result = null;
            try{
                result = Date.valueOf(this.dataOcorrencia);
            }
            catch(Exception ex){
                System.debug('ERROR PARSE DATE dataOcorrencia: ' + this.dataOcorrencia);
                ///data invalida
            }             
            return result;
        }

        public String getCPF(){
            String cpf = this.cpfSegurado + '' + this.digitoCpfSegurado;
            cpf = cpf.replace('.', '').replace('-', '');
            cpf = cpf.leftPad(11, '0');

            return Util.imprimeCPF(cpf);
        }
        
        public String validar(){
            if(String.isBlank(this.cpfSegurado))             return 'CPF não informado';
            if(String.isBlank(this.digitoCpfSegurado))       return 'Dígito do CPF não informado';

            //PLV-4059 - INICIO
            if(this.contrato == null)
            {           
                string msgCaseConvivencia = System.Label.MSG_ERRO_APOLICE_SUCESS_CASE;
                
                try {
                      Case caseConvivencia = getCaseConvivencia();
                      insert caseConvivencia;
                    } catch(DmlException e) {
                        
                        System.debug('Erro na criação do case de Convivencia: ' + e.getMessage());
                        msgCaseConvivencia = System.Label.MSG_ERRO_APOLICE;
                    }
                
                return msgCaseConvivencia;
              
            }  
            //PLV-4059 - FIM
            
            if( this.segurado == null)                       return 'Cliente não encontrado'; 
            if( !Util.isCPF(this.getCPF()) )                 return 'O CPF informado é inválido'; 
            if( this.segurado.cpf__c != this.getCPF() )      return 'CPF diferente do contrato';       

            if(String.isBlank(this.nomeSegurado))            return 'Nome Segurado não informado';
           
            if(String.isBlank(this.dataOcorrencia))          return 'Data de ocorrência do sinistro não informada';
            if(this.getDateOcorrencia() == null)             return 'Data de ocorrência inválida, deve estar no formato yyyy-MM-dd';
           
            if(String.isBlank(this.assunto))                 return 'Campo Assunto não informado';
            if(String.isBlank(this.descricao))               return 'Campo Descrição não informado';
            if(String.isBlank(this.origem))                  return 'Campo Origem não informado';
            if(String.isBlank(this.prestadora))              return 'Campo Prestadora não informado';
            if(String.isBlank(this.vitima))                  return 'Campo Vítima não informado';
            if(String.isBlank(this.idAtendimentoPrestadora)) return 'Id da Prestadora não informado';
            if(String.isBlank(this.tipoEvento))              return 'Tipo de evento não informado';
            if(String.isBlank(this.empresa))                 return 'Campo Empresa não informado';
            if(String.isBlank(this.sucursal))                return 'Campo Sucursal não informado';
            if(String.isBlank(this.ramo))                    return 'Campo Ramo não informado';

            if(String.isBlank(this.apolice))                 return 'Número da apólice não informado';
            //if(this.contrato == null)                      return 'Apólice não localizada';
    
            if(String.isBlank(this.endosso))                 return 'Campo Endosso não informado';
            if(this.garantias.isEmpty())                     return 'Garantias do sinistro não informadas';
            if(this.sinistroPrioritario == null)             return 'Campo Sinistro Prioritário não informado';
            if(this.ContaPrestadora == null)                 return 'Conta da prestadora não encontrada';
            if(this.contatoSegurado == null)                 return 'Segurado sem contato associado';
            //PLV-4094 - INICIO
            //if(this.numeroSinistroExiste == true)            return 'O número de sinistro informado está em uso. Por favor, tente novamente.'; //PLV-4166 - INICIO/FIM
            //PLV-4094 - FIM

            //PLV-3904 - INICIO            
            for(GarantiaSinistroTO garantia : this.garantias){
                if(garantia.garantia == null) return String.format('Garantia {0} não localizada no contrato', new String[]{garantia.sigla});

                //if contrato nao iniciado
                if(garantia.segurado.VigenciaInicial__c > this.getDateOcorrencia()){
                    
                    if(!(garantia.garantiaProduto.VigenciaGarantia__c == 'Contratação até fim da apólice'
                            || garantia.garantiaProduto.VigenciaGarantia__c == 'Contratação até início da apólice')){
                        System.debug('Não Iniciado');
                        return String.format('Não é possível realizar a abertura do sinistro para a garantia {0} por não estar na vigência da garantia',new String[]{garantia.sigla});
                    }

                }else if(garantia.segurado.VigenciaInicial__c <= this.getDateOcorrencia() && garantia.segurado.VigenciaFinal__c >= this.getDateOcorrencia()){
                    
                    if(!(garantia.garantiaProduto.VigenciaGarantia__c == 'Contratação até fim da apólice'
                        || garantia.garantiaProduto.VigenciaGarantia__c == 'Mesma da apólice') ){
                            System.debug('Iniciado');
                            return String.format('Não é possível realizar a abertura do sinistro para a garantia {0} por não estar na vigência da garantia',new String[]{garantia.sigla});
                    }
            }
        }
        //PLV-3904 - FIM
            
            if(this.seguradoContrato == null)    return 'Segurado do Contrato não localizado';
            
            return '';
        }

        public Case getCase(){
            return new Case(
                Origin               	= this.origem,
                Type                 	= 'Sinistro',
                status               	= 'Aberto', //fase
                Status_Dependente__c 	= 'Aberto',
                Vitima__c            	= this.vitima,
                Subject              	= this.assunto,
                Description          	= this.descricao,
                IdPrestadora__c      	= this.idAtendimentoPrestadora,
                TipoEvento__c       	= this.tipoEvento,
                Numero_titulo__c     	= this.prestadoraName,//PLV-4509 - Inicio/Fim
                Dataocorrencia__c    	= this.getDateOcorrencia(),
                RamoSplit__c         	= Integer.valueOf(this.ramo),
                EmpresaSplit__c      	= Integer.valueOf(this.empresa),
                AccountId            	= this.segurado.Id,
                Segurado_do_contrato__c = this.seguradoContrato.Id,
                ContactId              	= this.contatoSegurado.Id,
                Contrato__c            	= this.contrato.Id
            );
        }
        
       //PLV-4059 - INICIO
        public Case getCaseConvivencia()
        {
            Id  accConvivencia  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convivencia').getRecordTypeId();

			Case caseConvivencia = new Case(                    
     		RecordTypeId            = accConvivencia, 
            Description    			= this.descricao,
            Nome_Segurado__c		= this.nomeSegurado,
            Cpf_Segurado__C			= this.cpfSegurado +'-'+ this.digitoCpfSegurado,                    
            Dataocorrencia__c    	= Date.valueOf(this.dataOcorrencia),
            Subject                 = this.assunto,
            Origin                  = this.origem,
            Numero_titulo__c        = this.prestadoraName,//PLV-4509 - Inicio/Fim
            Vitima__c               = this.vitima,
            IdPrestadora__c         = this.idAtendimentoPrestadora,
            TipoEvento__c           = this.tipoEvento,
            EmpresaSplit__c         = Decimal.valueOf(this.empresa),
            RamoSplit__c            = Decimal.valueOf(this.ramo),  
            sucursal__c				= String.valueOf(this.sucursal),
            Numero_Apolice__c 		= String.valueOf(this.apolice),
            SinistroPrioritario__c  = this.sinistroPrioritario,                     
            status                  = 'Avisar');
            
            //garantias 
            For(GarantiaSinistroTO a:this.garantias)
            {
                String Garantia = caseConvivencia.Garantias_Convivencia__c != null ? caseConvivencia.Garantias_Convivencia__c : '';            	
                caseConvivencia.Garantias_Convivencia__c = Garantia + ' Sigla: '+ a.Sigla + ' ValorIndenizado: '+ a.valorIndenizado + ' MoedaIndenizacao: '+a.moedaIndenizacao +'\n';
              }
            return caseConvivencia;            
        }

         //PLV-4059 - FIM
        
        public Map<String, GarantiaSinistroTO> getMapGarantia(){
            Map<String, GarantiaSinistroTO> result = new Map<String, GarantiaSinistroTO>();
            for(GarantiaSinistroTO garantiaRequest: this.garantias){
                result.put(garantiaRequest.sigla, garantiaRequest);
            }
            return result;
        }
        
        //PLV4921 INICIO
        @TestVisible
        private void setContaPrestadora(Parceiro__c contaPrestadora){
            this.contaPrestadora = contaPrestadora;
        }
        //PLV4921 FIM
    }

    global class GarantiaSinistroTO {
        public String sigla                                     { get; set; }
        public double valorIndenizado                           { get; set; }
        public String moedaIndenizacao                          { get; set; }
        public String tipoValor                                 { get; set; } //PLV-4166 - INICIO/FIM
        public List<BeneficiarioSinistroTO> beneficiarios       { get; set; } //PLV-4509 - Inicio---FIm
        
        public transient GarantiaSeguradoContrato__c garantiaSegurado {get; set;}
        public transient Garantia__c garantia {get {return this.garantiaSegurado.garantia__r;}}
        //PLV-3904 - INICIO
        public transient SeguradoContrato__c segurado {get; set;}
        public transient GarantiaProduto__c garantiaProduto {get; set;}
        //PLV-3904 - FIM
        public PagamentoGarantia__c getPagamentoGarantia(Id caseId){
            system.debug('teste111122 '+ this.beneficiarios);
            return new PagamentoGarantia__c(
                Caso__c                             = caseId,
                name                                = garantia.name,
                Fase__c                             = 'Em Análise', //PLV-4070_FIX - INICIO/FIM
                Status_do_pagamento__c              = 'Em análise',
                Garantia_do_segurado_do_contrato__c = garantiaSegurado.id,                    
                CurrencyIsoCode                     = this.moedaIndenizacao, 
                Valor_indenizado__c                 = this.valorIndenizado,
                Capital__c                          = this.garantiaSegurado.Capital__c,
                ValorIndenizadoInicial__c           = this.valorIndenizado //PLV-4070 - INICIO/FIM
            );
        }

        //PLV-4509 - Inicio
        public GarantiaSinistroTO(){                    
            this.beneficiarios = new List<BeneficiarioSinistroTO>();                     
        }
         //PLV-4509 - Fim
    }

      //PLV-4509 - Inicio
    global class BeneficiarioSinistroTO {
        public String nomeBeneficiario                                       { get; set; }
        public String tipo                                                   { get; set; }
        public String valorIndenizacaoBeneficiario                           { get; set; }
        public String moeda                                                  { get; set; }   
        public DadosPessoaFisicaSinistroTO dadosPessoaFisica                 { get; set; } 
        public DadosPessoaJuridicaSinistroTO dadosPessoaJuridica             { get; set; }          
        
        public BeneficiarioSinistroTO(){                    
            this.dadosPessoaFisica = new DadosPessoaFisicaSinistroTO(); 
            this.dadosPessoaJuridica = new DadosPessoaJuridicaSinistroTO();                    
        }               
    } 
        
     global class DadosPessoaFisicaSinistroTO {
        public String numeroDocumentoBeneficiario        { get; set; }         
    } 
         
     global class DadosPessoaJuridicaSinistroTO {
        public String numeroDocumentoBeneficiario        { get; set; }
        public Boolean documentoEstrangeiro              { get; set; }                   
    } 
     //PLV-4509 - Fim

    /***** claase de estrutura do JSON de retorno do serviço  **/
    global class Response {

        public transient string caseId {get {return this.data.caseId;}} //PLV-4094 - INICIO/FIM
     

        public DataTO data { get; set; }
        public MetaTO meta { get; set; }

        public Response(){
            this.data = new DataTO();
            this.meta = new MetaTO();
        }
        
        public Response setError(String mensagem){
            this.data.mensagem = mensagem;
            return this;
        }
    }

    global class DataTO {        
       
        //PLV-4094 - INICIO
        public transient String caseId {
            get{ 
                return this.sinistro.caseId;
            }
            set { 
                this.sinistro.caseId = value;
            }
        }
        //PLV-4094 - FIM

        public SinistroResponseTO sinistro { get; set; }

        public String mensagem {get; set;}
        public Boolean erro {
            get{ return String.isNotBlank(this.mensagem); }
        }

        public DataTO(){
            this.mensagem = '';
            this.sinistro = new SinistroResponseTO();
        }
    }

    global class SinistroResponseTO{
        public String   empresa                 {get; set;}
        public String   ramo                    {get; set;}
        public Integer  ano                     {get; set;}
        public String   numeroSinistro          {get; set;}
        public String   status                  {get; set;}
        public String   idAtendimentoPrestadora {get; set;}
        //PLV-4094 - INICIO
        public String   caseId                  {get; set;}
        public String   edsTip                  {get; set;}
        //PLV-4094 - FIM
		//PLV-4096 - Inicio
		public String   idTicketBCP                  {get; set;}
		//PLV-4096 - Fim

        public SinistroResponseTO(){
            this.empresa                 = '';
            this.ramo                    = '';
            this.ano                     = 0;
            this.numeroSinistro          = '';
            this.status                  = '';
            this.idAtendimentoPrestadora = '';
            //PLV-4094 - INICIO
            this.caseId                  = '';
            this.edsTip                  = '';
            //PLV-4094 - FIM
			//PLV-4096 - Inicio
			this.idTicketBCP             = '';
			//PLV-4096 - Fim
        }
        
    }

    global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = '/sinistro/criar';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }
    
}