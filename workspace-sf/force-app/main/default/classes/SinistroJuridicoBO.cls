/*******************************************************************************************************************************
* 
* @author Pedro Augusto - SYS4B
* @date 25/09/2020
* @modifiedAt 
* Classe criada por conta da história PLV-4046
* Classe de apoio ao serviço
******************************************************************************************************************************/
global with sharing class SinistroJuridicoBO {
    
    private static final SinistroJuridicoBO instance = new SinistroJuridicoBO();

	global static SinistroJuridicoBO getInstance() {
		return instance;
    }
    
    global class ResponseAtualizar {

		
		public Integer resultado {get;set;}
		public String mensagem {get;set;}
		public String empresa {get; set;} //LECVPV-141 INICIO/FIM
		public Integer ramo {get;set;}
		public Integer ano {get;set;}
		public Decimal numero {get;set;}
        public Decimal item {get;set;}

        public ResponseAtualizar(){
			this.resultado = 1;
			this.mensagem = '';
			this.item = 0;//não temos
        }
        // POR062-1 - INICIO
        public ResponseAtualizar setError(String mensagem, Request sinistro){
			System.debug('Sinistro (Erro): ' + this.mensagem);
			this.resultado = 1;
			this.mensagem = mensagem;
			this.empresa = sinistro.empresa == null ? '' : sinistro.empresa; //LECVPV-141 INICIO/FIM
			this.ano = String.isNotBlank(sinistro.ano) ? Integer.valueOf(sinistro.ano) : null;
			this.ramo = String.isNotBlank(sinistro.ramo) ? Integer.valueOf(sinistro.ramo) : null;
			this.numero = String.isNotBlank(sinistro.numero) ? Decimal.valueOf(sinistro.numero) : null;
			this.item = 0;
			return this;
		}
		// POR062-1 - FIM
		public void setSucesso(Request sinistro){
			this.resultado = 0;
			this.mensagem = '';
			this.empresa = sinistro.empresa == null ? '' : sinistro.empresa; //LECVPV-141 INICIO/FIM
			this.ano = String.isNotBlank(sinistro.ano) ? Integer.valueOf(sinistro.ano) : null;
			this.ramo = String.isNotBlank(sinistro.ramo) ? Integer.valueOf(sinistro.ramo) : null;
			this.numero = String.isNotBlank(sinistro.numero) ? Decimal.valueOf(sinistro.numero) : null;
			this.item = 0;
			//this.item = sinistro.item;
		}
    }

    global class Request {
	   
		public String				ramo				{get; set;}
		public String				ano                 {get; set;}
		public String				numero              {get; set;}
		public String				item                {get; set;}
		public String				empresa             {get; set;}
		public String				cobertura           {get; set;}
		public String				codigodaprovisao    {get; set;}
		public Decimal				valor               {get; set;}
		public String				matricula           {get; set;}
		public Integer				movimento           {get; set;}
		public Integer				codigoencerramento  {get; set;}
        public FavorecidoTO 		favorecido 			{get; set;}
		public Integer				sucursal            {get; set;}
		public Long				    apolice             {get; set;}
        
		//LECVPV-141 - INICIO
        public void Request(String tipo){
        //        this.empresa = String.isBlank(this.empresa) ? this.empresa : '1';
        }
		//LECVPV-141 - FIM
		
        public void atualizarInit(){
            this.valor = this.valor!=null ? this.valor : 0;
        }

	  	// POR062-1 - INICIO
		public String validar(String tipo){
            if(tipo=='ConsultarSinistro'){
                if(String.isBlank(this.ano)) return 'Ano do sinistro não informado';
                if(String.isBlank(this.ramo)) return 'Código do ramo do sinistro não informado';
                if(String.isBlank(this.numero)) return 'Número do sinistro não informado';

			}else if(tipo=='AtualizarSinistro'){
                if(String.isBlank(this.ramo)) return 'Ramo não informado';
                if(String.isBlank(this.ano)) return 'Ano não informado';
                if(String.isBlank(this.numero)) return 'Numero não informado';
                if(String.isBlank(this.cobertura))return 'Cobertura não informada';
                if( this.valor==null || (this.valor == 0 && !MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_RECEBIDOS_SEM_VALOR).contains(this.movimento))) return 'Valor não informado ou igual a zero'; //PLV-4624
                if(String.isBlank(this.matricula)) return 'Matricula não informada';
                if(this.movimento==null) return 'Código do movimento de ajuste de reserva não informado';
				if(MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_PAGAMENTOS_INDENIZACAO).contains(this.movimento)) return 'Pagamentos devem ser gerados pelo Salesforce';
                if(!MovimentoSinistroTO.getInstance().recuperarConjuntoMovimentoValor(MovimentoSinistroTO.CONJ_MOV_JURIDICO).contains(this.movimento)) return 'Código do movimento fora do esperado'; //PLV-4624
			}else if(tipo=='ConsultarApolice'){
                if(String.isBlank(this.ramo)) return 'Código do ramo da apólice não informado';
                if(this.apolice==null) return 'Número da apólice não informado';
                if(this.sucursal==null) return 'Sucursal da apólice não informada';
            }
			return '';
		}
    }
    // POR062-1 - FIM
	
	global class FavorecidoTO {
		public String				cpf_cnpj            {get; set;} // LECVPV-141 INICIO/FIM
		public Integer				tipopagamento       {get; set;}
	}
	
	// LECVPV-141 INICIO
    // global class SinistroResponse{
	//	public  Integer Resultado {get;set;}
	//	public  String Mensagem {get;set;}
	// }
	
	global class SeguradoTO{
		public  String nomeSegurado {get;set;}//Conta__r.Name
		public  String documentoSegurado {get;set;}//Comta__r.CPF__c
		
	//	public SeguradoTO dtoSegurado(Case caso){
	//		SeguradoTO SeguradoToReturn = new SeguradoTO();
	//		SeguradoToReturn.NomeSegurado		=	String.isNotBlank(caso.Segurado_do_contrato__r.Conta__r.Name) ? caso.Segurado_do_contrato__r.Conta__r.Name : '';
	//		SeguradoToReturn.DocumentoSegurado	=	String.isNotBlank(caso.Segurado_do_contrato__r.Conta__r.CPF__c) ? caso.Segurado_do_contrato__r.Conta__r.CPF__c : '';
		
	//		return SeguradoToReturn;
	//	}

		public SeguradoTO() {
			
		}

		public SeguradoTO(Case caso) {
			this.nomeSegurado = String.isNotBlank(caso.Segurado_do_contrato__r.Conta__r.Name) ? caso.Segurado_do_contrato__r.Conta__r.Name : '';
			this.documentoSegurado = String.isNotBlank(caso.Segurado_do_contrato__r.Conta__r.CPF__c) ? caso.Segurado_do_contrato__r.Conta__r.CPF__c : '';
		}

	}
	
	global class TerceiroTO{
		public  String nomeTerceiro {get;set;} // Não temos
		public  String documentoTerceiro {get;set;} // Não temos
	}
	global class VistoriaTO{
		public  String numeroVistoria {get;set;} // Não temos
		public  Integer anoVistoria {get;set;} // Não temos
	}

	global class SinistroTO{

		public Integer empresa {get;set;}
		public  Integer grupoDeRamo {get;set;}
		public  Integer ramo {get;set;}//RamoSplit__c
		public  Decimal numero {get;set;} //NumeroSinistro__c ou NumeroSinistroSplit__c
		public  Integer ano {get;set;}//AnoSinistroSplit__c
		public  Integer item {get;set;}//??
	//	public  Integer Empresa {get;set;}//1 ou o que receber
		public  Integer subRamo {get;set;}//?? // Contrato.ModalidadeSeguro__r.RamoSeguro__c verificar no objeto
		public  Integer modalidade {get;set;}//Contrato.CodigoModalidade__c 
		public  Date dataSinistro {get;set;}//Data_sinistro_avisado__c
		public  Decimal estimativa {get;set;}//??
		public  Decimal franquia {get;set;}//??
		public  Integer natureza {get;set;}//??
		public  Decimal saldo {get;set;}//??
		public  String situacao {get;set;}//Fase?? Status
		public  Integer tipoDePerda {get;set;}//Não obrigatório
		public  Decimal valorCia {get;set;}//?? 
		public  Integer aviso {get;set;}//??
		public  TerceiroTO terceiroCausador {get;set;} //Não obrigatório
		public VistoriaTO vistoria {get;set;} //Não obrigatório
		public  List<CoberturaTO> coberturas {get;set;}
		public  ApoliceTO apolice {get;set;}
		public  SeguradoTO segurado {get;set;}


		//NÃO OBRIGATORIO
		//public  List<CoberturaTO> Coberturas {get;set;}

		public SinistroTO() {

		}

		public SinistroTO(Case caso) {
			//  SinistroTO SinistroToReturn = new SinistroTO();
			String [] expNumero = String.isNotBlank(caso.NumeroSinistro__c) ? caso.NumeroSinistro__c.split('\\.') : null;

			this.grupoDeRamo = caso.Contrato__r.RamoSeguro__r.GrupoRamoSinistro__c!=null ? Integer.valueOf(caso.Contrato__r.RamoSeguro__r.GrupoRamoSinistro__c) : null;
			this.ramo = caso.RamoSplit__c!=null ? Integer.valueOf(caso.RamoSplit__c) : String.isNotBlank(expNumero[1]) ? Integer.valueOf(expNumero[1]) : null;
			this.numero = caso.NumeroSinistroSplit__c!=null ? Decimal.valueOf(caso.NumeroSinistroSplit__c) : String.isNotBlank(expNumero[3]) ? Decimal.valueOf(expNumero[3]) : null; //PLV-4485
			this.ano = caso.AnoSinistroSplit__c!=null ? Integer.valueOf(caso.AnoSinistroSplit__c) : String.isNotBlank(expNumero[2]) ?  Integer.valueOf(expNumero[2]) : null; //PLV-4485
			this.item = 0;//não temos
			this.empresa = caso.EmpresaSplit__c!=null ? Integer.valueOf(caso.EmpresaSplit__c) : null;
			this.subRamo = 0;//não temos - (automóvel)
			this.modalidade = caso.Contrato__r.CodigoModalidade__c!=null ? Integer.valueOf(caso.Contrato__r.CodigoModalidade__c) : null;
			this.dataSinistro = caso.Dataocorrencia__c!=null ? Date.valueOf(caso.Dataocorrencia__c) : null; // LECVPV-237 - INICIO/FIM
			this.estimativa = null;//nao faz sentido pois esta nas garantias
			this.franquia = null;//nao faz sentido pois esta nas garantias
			this.natureza = null;//não temos
			this.saldo = null;//nao faz sentido pois esta nas garantias
			this.situacao = caso.Status;//precisa de tabela dominio
			this.tipoDePerda = 0;//não temos
			this.valorCia = 0;//não temos
			this.aviso = 0;//não temos
			// LECVPV-237 - INICIO
			this.segurado = new SeguradoTO();
			this.segurado.nomeSegurado = caso.Segurado_do_contrato__r.Conta__r.Name;
			this.segurado.documentoSegurado = caso.Segurado_do_contrato__r.Conta__r.CPF__c;
			// LECVPV-237 - FIM
		}

		// public List<SinistroTO> dtoSinistro(List<Case> lCase){
            
		// 	SinistroTO SinistrosToReturn = new SinistroTO();
			
		// 	String[] expNumero;
		// 	List<SinistroTO> Sinistros = new List<SinistroTO>(); //LECVPV-141 - INICIO/FIM
        //     for(Case caso : lCase){

		// 	expNumero = String.isNotBlank(caso.NumeroSinistro__c) ? caso.NumeroSinistro__c.split('\\.') : null;

        //     System.debug('caso >>'+JSON.serialize(caso));
        //     System.debug('caso.NumeroSinistro__c >>'+caso.NumeroSinistro__c);

		// 	SinistrosToReturn.GrupodeRamo = caso.Contrato__r.RamoSeguro__r.GrupoRamoSinistro__c!=null ? Integer.valueOf(caso.Contrato__r.RamoSeguro__r.GrupoRamoSinistro__c) : null;
		// 	SinistrosToReturn.Ramo = caso.RamoSplit__c!=null ? Integer.valueOf(caso.RamoSplit__c) : String.isNotBlank(expNumero[1]) ? Integer.valueOf(expNumero[1]) : null;
		// 	SinistrosToReturn.Numero = caso.NumeroSinistroSplit__c!=null ? Decimal.valueOf(caso.NumeroSinistroSplit__c) : String.isNotBlank(expNumero[3]) ? Decimal.valueOf(expNumero[3]) : null; //PLV-4485
		// 	SinistrosToReturn.Ano = caso.AnoSinistroSplit__c!=null ? Integer.valueOf(caso.AnoSinistroSplit__c) : String.isNotBlank(expNumero[2]) ?  Integer.valueOf(expNumero[2]) : null; //PLV-4485
		// 	SinistrosToReturn.Item = 0;//não temos
		// 	SinistrosToReturn.Empresa = caso.EmpresaSplit__c!=null ? Integer.valueOf(caso.EmpresaSplit__c) : null;
		// 	SinistrosToReturn.Subramo = 0;//não temos - (automóvel)
		// 	SinistrosToReturn.Modalidade = caso.Contrato__r.CodigoModalidade__c!=null ? Integer.valueOf(caso.Contrato__r.CodigoModalidade__c) : null;
		// 	SinistrosToReturn.Datasinistro = caso.Data_sinistro_avisado__c!=null ? Date.valueOf(caso.Data_sinistro_avisado__c) : null;
		// 	SinistrosToReturn.Estimativa = null;//nao faz sentido pois esta nas garantias
		// 	SinistrosToReturn.Franquia = null;//nao faz sentido pois esta nas garantias
		// 	SinistrosToReturn.Natureza = null;//não temos
		// 	SinistrosToReturn.Saldo = null;//nao faz sentido pois esta nas garantias
		// 	SinistrosToReturn.Situacao = caso.Status;//precisa de tabela dominio
		// 	SinistrosToReturn.TipodePerda = 0;//não temos
		// 	SinistrosToReturn.ValorCia = 0;//não temos
		// 	SinistrosToReturn.Aviso = 0;//não temos

		//	return SinistroToReturn;
		// }
	}
	global class CoberturaTO{//PagamentoGarantia__c

		public  String codigo {get;set;}    //Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c
		public  String nome {get;set;} //Garantia_do_segurado_do_contrato__r.Garantia__r.Name   // LECVPV-201 INICIO/FIM
		public  Decimal valorFranquia {get;set;}//0
		public  Decimal valorIS {get;set;}//Garantia_do_segurado_do_contrato__r.Valor__c
		public  Integer natureza {get;set;}//null - 

		public CoberturaTO() {

		}

		public CoberturaTO(PagamentoGarantia__c garantia) {
			this.codigo				=	garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c;
			this.nome				=	garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Name; // LECVPV-201 INICIO/FIM
			this.valorFranquia			=	0;
			this.valorIS				=	garantia.Garantia_do_segurado_do_contrato__r.Valor__c;
			this.natureza				=	null;//(nao temos)
		}


	// global class CoberturaTO{//PagamentoGarantia__c
	//	public  String Codigo {get;set;}    //Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c
	//	public  String Descricao {get;set;} //Garantia_do_segurado_do_contrato__r.Garantia__r.Descricao__c
	//	public  Decimal ValorFranquia {get;set;}//0
	//	public  Decimal ValorIS {get;set;}//Garantia_do_segurado_do_contrato__r.Valor__c
	//	public  Integer Natureza {get;set;}//null - 


		// public CoberturaTO dtoCobertura(PagamentoGarantia__c garantia){
		// 	CoberturaTO CoberturaToReturn = new CoberturaTO();
		// 	CoberturaToReturn.Codigo				=	garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Sigla__c;
		// 	CoberturaToReturn.Descricao				=	garantia.Garantia_do_segurado_do_contrato__r.Garantia__r.Descricao__c;
		// 	CoberturaToReturn.ValorFranquia			=	0;
		// 	CoberturaToReturn.ValorIS				=	garantia.Garantia_do_segurado_do_contrato__r.Valor__c;
		// 	CoberturaToReturn.Natureza				=	null;//(nao temos)
			
		// 	return CoberturaToReturn;
		// }
	}
	global class ApoliceTO{// contract
		public  Integer sucursal {get;set;} //Sucursal__c
		public  Integer ramo {get;set;}//CodigoRamo__c
		public  Integer modalidade {get;set;}//CodigoModalidade__c
		public  String numero {get;set;}//NumeroApolice__c // 
		public  Integer endosso {get;set;}//Endosso__c   precisa do TipoEndosso__c??
		public  Date inicioVigencia {get;set;}// StartDate
		public  Date fimVigencia {get;set;}//FimVigencia__c?? ou EndDate?
		public  String susep {get;set;}//CodigoCorretor__c
		public  String corretor {get;set;}//CodigoCorretor__r.NomeCorretor__c
		public  String foneCorretor {get;set;}//nao tem no cadastro
		public  Decimal cosseguro {get;set;}//Nao tem
        public  Decimal resseguro {get;set;}//0 - POR AGORA NÃO TERIA ESSA INFORMAÇÃO
        public List<SinistroTO> sinistros {get;set;}

		public ApoliceTO() {

		}

		public ApoliceTO(Case caso) {
			this.sucursal 			=	caso.Contrato__r.Sucursal__c!=null ? Integer.valueOf(caso.Contrato__r.Sucursal__c) : null;
			this.ramo 				=	caso.Contrato__r.CodigoRamo__c !=null ? Integer.valueOf(caso.Contrato__r.CodigoRamo__c) : null;
			this.modalidade			=	caso.Contrato__r.CodigoModalidade__c !=null ? Integer.valueOf(caso.Contrato__r.CodigoModalidade__c) : null;
			this.numero				=	caso.Contrato__r.NumeroApolice__c !=null ? caso.Contrato__r.NumeroApolice__c : null;
			this.endosso				=	caso.Contrato__r.Endosso__c !=null ? Integer.valueOf(caso.Contrato__r.Endosso__c) : null;
			this.inicioVigencia		=	caso.Contrato__r.StartDate;
			this.fimVigencia			=	caso.Contrato__r.VigenciaFinal__c !=null ? caso.Contrato__r.VigenciaFinal__c : null;
			this.susep				=	caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c !=null ? caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c : '';
			this.corretor			=	caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Name !=null ? caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Name : '';
			this.foneCorretor		=	caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Phone !=null ? caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Phone : '';
			this.cosseguro			=	null;//lCase[0].;
			this.resseguro			=	null;//lCase[0].;
		}

		public ApoliceTO(Contract contrato) {
			this.sucursal 			=	contrato.Sucursal__c!=null ? Integer.valueOf(contrato.Sucursal__c) : null;
			this.ramo 				=	contrato.CodigoRamo__c !=null ? Integer.valueOf(contrato.CodigoRamo__c) : null;
			this.modalidade			=	contrato.CodigoModalidade__c !=null ? Integer.valueOf(contrato.CodigoModalidade__c) : null;
			this.numero				=	contrato.NumeroApolice__c !=null ? contrato.NumeroApolice__c : null;
			this.endosso				=	contrato.Endosso__c !=null ? Integer.valueOf(contrato.Endosso__c) : null;
			this.inicioVigencia		=	contrato.StartDate;
			this.fimVigencia			=	contrato.VigenciaFinal__c !=null ? contrato.VigenciaFinal__c : null;
			this.susep				=	contrato.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c !=null ? contrato.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c : '';
			this.Corretor			=	contrato.CodigoCorretor__r.NomeCorretor__r.Name !=null ? contrato.CodigoCorretor__r.NomeCorretor__r.Name : '';
			this.foneCorretor		=	contrato.CodigoCorretor__r.NomeCorretor__r.Phone !=null ? contrato.CodigoCorretor__r.NomeCorretor__r.Phone : '';
			this.cosseguro			=	null;
			this.resseguro			=	null;
		}
		
		//Nao obrigatorio daqui pra baixo
		/*public  String DocumentoSucursal {get;set;} public  String Estipulante {get;set;} public  String Subestipulante {get;set;} public  Decimal DanosMorais {get;set;} public  Decimal DMH {get;set;} public  Decimal Invalidez {get;set;} public  Decimal Morte {get;set;} public  Decimal RCFDC {get;set;} public  Decimal RCFDM {get;set;} public  String Chassi {get;set;} public  String Placa {get;set;} public  Decimal Vida {get;set;}*/
		
		// public ApoliceTO dtoApolice(Case caso,Contract contrato){
		// 	ApoliceTO ApoliceToReturn = new ApoliceTO();
		// 		  if(contrato!=null){
		// 			ApoliceToReturn.Sucursal 			=	contrato.Sucursal__c!=null ? Integer.valueOf(contrato.Sucursal__c) : null;
		// 			ApoliceToReturn.Ramo 				=	contrato.CodigoRamo__c !=null ? Integer.valueOf(contrato.CodigoRamo__c) : null;
		// 			ApoliceToReturn.Modalidade			=	contrato.CodigoModalidade__c !=null ? Integer.valueOf(contrato.CodigoModalidade__c) : null;
		// 			ApoliceToReturn.Apolice				=	contrato.NumeroApolice__c !=null ? Decimal.valueOf(contrato.NumeroApolice__c) : null;
		// 			ApoliceToReturn.Endosso				=	contrato.Endosso__c !=null ? Integer.valueOf(contrato.Endosso__c) : null;
		// 			ApoliceToReturn.Iniciovigencia		=	contrato.StartDate;
		// 			ApoliceToReturn.FimVigencia			=	contrato.VigenciaFinal__c !=null ? contrato.VigenciaFinal__c : null;
		// 			ApoliceToReturn.SUSEP				=	contrato.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c !=null ? contrato.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c : '';
		// 			ApoliceToReturn.Corretor			=	contrato.CodigoCorretor__r.NomeCorretor__r.Name !=null ? contrato.CodigoCorretor__r.NomeCorretor__r.Name : '';
		// 			ApoliceToReturn.FoneCorretor		=	contrato.CodigoCorretor__r.NomeCorretor__r.Phone !=null ? contrato.CodigoCorretor__r.NomeCorretor__r.Phone : '';
		// 			ApoliceToReturn.Cosseguro			=	null;
		// 			ApoliceToReturn.Resseguro			=	null;
		// 			}else if(caso!=null){
		// 		ApoliceToReturn.Sucursal 			=	caso.Contrato__r.Sucursal__c!=null ? Integer.valueOf(caso.Contrato__r.Sucursal__c) : null;
		// 		ApoliceToReturn.Ramo 				=	caso.Contrato__r.CodigoRamo__c !=null ? Integer.valueOf(caso.Contrato__r.CodigoRamo__c) : null;
		// 		ApoliceToReturn.Modalidade			=	caso.Contrato__r.CodigoModalidade__c !=null ? Integer.valueOf(caso.Contrato__r.CodigoModalidade__c) : null;
		// 		ApoliceToReturn.Apolice				=	caso.Contrato__r.NumeroApolice__c !=null ? Decimal.valueOf(caso.Contrato__r.NumeroApolice__c) : null;
		// 		ApoliceToReturn.Endosso				=	caso.Contrato__r.Endosso__c !=null ? Integer.valueOf(caso.Contrato__r.Endosso__c) : null;
		// 		ApoliceToReturn.Iniciovigencia		=	caso.Contrato__r.StartDate;
		// 		ApoliceToReturn.FimVigencia			=	caso.Contrato__r.VigenciaFinal__c !=null ? caso.Contrato__r.VigenciaFinal__c : null;
		// 		ApoliceToReturn.SUSEP				=	caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c !=null ? caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c : '';
		// 		ApoliceToReturn.Corretor			=	caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Name !=null ? caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Name : '';
		// 		ApoliceToReturn.FoneCorretor		=	caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Phone !=null ? caso.Contrato__r.CodigoCorretor__r.NomeCorretor__r.Phone : '';
		// 		ApoliceToReturn.Cosseguro			=	null;//lCase[0].;
		// 		ApoliceToReturn.Resseguro			=	null;//lCase[0].;		
		// 	}
			
		// 	return Apolices;
		// }
	}
	// LECVPV-141 FIM
}