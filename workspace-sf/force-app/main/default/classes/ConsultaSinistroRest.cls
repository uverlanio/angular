/*******************************************************************************************************************************
* Consulta dados Básicos de Apólice/Contrato
* @author Gabriel Roetger- Globant
* @date 20/07/2020
* Classe criada por conta da história PLV-3967 / PLV-4525
******************************************************************************************************************************/
@RestResource(urlMapping='/sinistro/buscar') 
global class ConsultaSinistroRest {
    
    
    @HttpGet
    global static Response consultar(){
        Response response = new Response();
        ConsultaParam param = new ConsultaParam(RestContext.request);

        ConsultaSinistroService consultaService = new ConsultaSinistroService(
            param.apolice,
            param.sinistro
        );
               
        if(!param.hasParams()) {
            response.meta.error = 'Pesquisa sem parâmetros.';
            return response;
        }

        return consultaService.getSinistros();
    }
    
    global class Response {
        public List<Sinistro> data {get;set;}
        public MetaTO meta {get;set;}

        public Response(){
            this.data = new List<Sinistro>();
            this.meta = new MetaTO();
        }
    } 

    global class ConsultaParam {
        public String apolice  = null;
        public String sinistro = null;

        public ConsultaParam(RestRequest req){
            this.apolice = req.params.get('apolice');
            this.sinistro = req.params.get('sinistro');

        }

        public Boolean hasParams(){
            return (this.apolice != null) || (this.sinistro != null);
        }
    }

    global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        public String error  {get;set;}
        
        public MetaTO() {
            this.error = 'Sinistro não encontrado para o contrato';
            this.servico = 'ConsultaSinistro';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

    global class Sinistro{
        public String numeroDoSinistro                  {get;set;}  // Número do sinistro (caso)
        public String reclamante                        {get;set;}  // Reclamante (Nome do Contato do caso)
        public Datetime dataHoraAbertura                {get;set;}  // Data/hora de abertura do sinistro (caso)
        public String statusDoSinistro                  {get;set;}  // Status do sinistro (caso)
        public List<Comentario> comentarios             {get;set;}  // Comentários do sinistro (caso)
        public String contrato                          {get;set;}  // Número do contrato
        public Datetime dataOcorrencia                  {get;set;}  // Data do evento (data da ocorrência)
        public List<GarantiaDoSinistro> garantias       {get;set;}  // Garantias  (descrição)

        public Sinistro(Case rawCase, List<GarantiaDoSinistro> garantias){

            this.numeroDoSinistro = rawCase.NumeroSinistro__c;                                  
            this.reclamante = rawCase.Contact.Name;                                             
            this.dataHoraAbertura = rawCase.CreatedDate;                                        
            this.statusDoSinistro = rawCase.Status + ' - ' + rawCase.Status_Dependente__c;      

            this.comentarios = new List<Comentario>();      
            for(CaseComment rawComent : rawCase.CaseComments) this.comentarios.add(new Comentario(rawComent));

            this.contrato = rawCase.Contrato__r.ContractNumber;                                   
            this.dataOcorrencia= rawCase.Dataocorrencia__c;                                     
            
            this.garantias = new List<GarantiaDoSinistro>();

            if(garantias != null) this.garantias = garantias;
        }
    }

    global class Comentario{
        public String comentario {get;set;}                                             // Comentários do sinistro (caso)
        public Datetime data {get;set;}

        public Comentario(CaseComment rawComment){
            this.comentario = rawComment.CommentBody;                                       
            this.data = rawComment.CreatedDate;
        }
    }

    global class GarantiaDoSinistro{
        
        public String descricao 				{get;set;} // Garantias  (descrição)
        public Decimal capitalContratado 		{get;set;} // Capital contratado
        // PLV-4525 - inicio
        public Decimal dias 					{get;set;} 
        public Decimal franquia					{get;set;} 
        public String franquiaContrato 			{get;set;} 
        // PLV-4525 - fim
        public List<Beneficiario> beneficiario 	{get;set;} //Beneficiário

        public GarantiaDoSinistro(PagamentoGarantia__c rawGarantia, List<BeneficiarioGarantia__c> rawBeneficiarios){
            this.descricao = rawGarantia.name;
            this.capitalContratado = rawGarantia.Capital__c;
            // PLV-4525 - inicio
            this.dias = rawGarantia.QuantidadeDias__c;
            this.franquia = rawGarantia.Franquias__c;
            this.franquiaContrato = rawGarantia.FranquiaContrato__c;
            // PLV-4525 - fim
            this.beneficiario = new List<Beneficiario>();
            if (rawBeneficiarios != null) {
                for (BeneficiarioGarantia__c rawBeneficiario : rawBeneficiarios) {
                    this.beneficiario.add(new Beneficiario(rawBeneficiario));
                }
            } 
        }
    }

    global class Beneficiario{
        public String nome                      {get;set;}  // Beneficiário 
        public Pagamento pagamento              {get;set;}

        public Beneficiario(BeneficiarioGarantia__c rawBeneficiario){
            this.nome = rawBeneficiario.conta__r.Name;
            if (rawBeneficiario.Pagamento_de_Sinistro__r != null){
                this.pagamento = new Pagamento(rawBeneficiario.Pagamento_de_Sinistro__r, rawBeneficiario.Percentual_de_indenizacao__c);
            }
        }
    }

    global class Pagamento{
        public String tipo                      {get;set;}  // Forma de pagamento 
        public Decimal percentalIndenizacao     {get;set;}  // Percentual de indenização 
        public DateTime dataProgramadaPagamento {get;set;}  // Data_programada_do_pagamento__c
        public DateTime dataPagamento           {get;set;}  // DataPagamento__c
        public Decimal valorPago                {get;set;}  // ValorPago__c 
        public DadosBancarios dadosBancarios    {get;set;}
        public String sucursal                 {get;set;}

        public Pagamento(Pagamento_de_Sinistro__c rawPagamento, Decimal percentalIndenizacao){
            this.tipo = rawPagamento.Tipo_de_Pagamento__c;
            this.sucursal = rawPagamento.Sucursal_Destino_de_Cheque__c;
            this.percentalIndenizacao = percentalIndenizacao;
            this.dataProgramadaPagamento = rawPagamento.Data_Programada_de_Pagamento__c;
            this.dataPagamento = rawPagamento.Data_de_pagamento__c;
            this.valorPago = rawPagamento.Valor_total_a_ser_indenizado__c;
            
            if(rawPagamento.Dados_Bancarios__r.Agencia__c != null ){
                this.dadosBancarios = new DadosBancarios(rawPagamento);
            }
        }
    }

    global class DadosBancarios{
        public String numeroConta               {get;set;}
		//PLV-3918-FIX6 - INICIO
		//PLV-3918-FIX7 - INICIO
        public String digito                    {get;set;}
		//PLV-3918-FIX7 - FIM
		//PLV-3918-FIX6 - FIM
        public String agencia                   {get;set;}
        public String banco                     {get;set;}
        public String papel                     {get;set;}

        public DadosBancarios(Pagamento_de_Sinistro__c rawPagamento){
            this.numeroConta = rawPagamento.Dados_Bancarios__r.NumeroConta__c;
            this.digito = rawPagamento.Dados_Bancarios__r.Digito__c;
            this.agencia =rawPagamento.Dados_Bancarios__r.Agencia__c;
            this.banco = rawPagamento.Dados_Bancarios__r.Banco__c;
            this.papel = rawPagamento.Dados_Bancarios__r.Papel__c;
        }
    }
}