/*******************************************************************************************************************************
* Consulta dados de Proposta
* @author Carlos - Meta
* @date 30/07/2020
* Classe criada por conta da história PLV-4205
******************************************************************************************************************************/
@RestResource(urlMapping='/consultaProposta')
global class ConsultaPropostaADMREST {
    
    @HttpPost
    global static Response consultar(){
        
        Response result = new Response();
        System.debug(LoggingLevel.DEBUG, RestContext.request.requestBody.toString());
        if(RestContext.request.requestBody.toString() == ''){
            result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
            return result;
        }
        ConsultaParam param = (ConsultaParam) JSON.deserialize(RestContext.request.requestBody.toString(), ConsultaParam.class);

         

        System.debug('PARAM +++' + param);
        System.debug('Isvalid = '+ param.isValid());

        //II-32 INICIO
        Boolean hasCritica;
        if(param.pendencia != null ){
            hasCritica = Boolean.valueOf(param.pendencia);
        }else{
            hasCritica = false;
        }
        
        try {
            if(param.isValid() && hasCritica){
                System.debug('Entrou no if Rogerio');
                ConsultaPropostaService service = new ConsultaPropostaService(param);
                result.data = service.consultaPendencia();
            }
            else if(param.isValid() && !hasCritica) {
                ConsultaPropostaService service = new ConsultaPropostaService(param);
                result.data = service.consultar();
            } //II-32 FIM
            else{
                result.setMessageErro(-1, 'Parâmetros insuficientes para completar a requisição.');
                return result;
            }
        } catch (Exception ex) {
            result.setMessageErro(-1, 'Erro ao consultar proposta. ' + ex.getLineNumber());
            return result;
        }

        if(!result.hasPropostas()) result.setMessageErro(0, 'Nenhuma proposta encontrada para a Susep informada.');
        return result;
    }


    /*    Classes internas    */
    global class ConsultaParam {
        public String canal 	 {get; set;}
        public String idCanal 	 {get; set;}
        public String codigoOferta 	 {get; set;} //II-124 FIX01 INICIO-FIM
		//PLV-4197 Inicio
		public String origem 	 {get; set;}
        public String proposta 	 {get; set;}
		public String cpfContratante 	 {get; set;}
		public String quantidadeDeMeses 	 {get; set;}
        //II-32 INICIO
        public String pendencia  {get; set;}
        public String dataInicio  {get; set;}
        public String dataFinal  {get; set;}
        //II-32 FIM
        //PLV-4197 Fim
        //PLV-4928 INICIO
        public String nomeSegurado    {get; set;}
        public String numeroProposta  {get; set;}
        public String dataProposta    {get; set;}
        //PLV-4928 FIM

        public Boolean isValid(){
            System.debug('isValid');
			//PLV-4197 Inicio 			
			System.debug('Origem = ' + this.origem);
			System.debug('Proposta = ' + this.proposta);
            System.debug('idCanal' + this.idCanal);
            System.debug('canal' + this.canal);
            System.debug('codigoOferta ><' + this.codigoOferta);
            System.debug('cpfContratante' + this.cpfContratante);
			if((String.isBlank(this.origem) || String.isBlank(this.proposta)) && String.isBlank(this.idCanal) && String.isBlank(this.canal) && String.isBlank(this.cpfContratante)){												
					System.debug('Primeiro');
					return false;								            
			}else if((String.isBlank(this.idCanal) || String.isBlank(this.canal)) && String.isBlank(this.origem) && String.isBlank(this.proposta) && String.isBlank(this.cpfContratante)){
					System.debug('Segundo');
					return false;
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

        public Boolean hasPropostas(){
            return !this.data.propostas.isEmpty();
        }

        public void setMessageErro(Integer codError, String msg){
            this.data.statusChamada = codError;
            this.data.descricaoErro = msg;
        }
     } 

     global class DataTO {        
        public Integer statusChamada {get;set;}
        public String descricaoErro {get;set;}
        public List<ConsultaPropostaTO> propostas {get;set;}
     }

     global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public MetaTO() {
            this.servico = 'consultaProposta';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

    global class ConsultaPropostaTO{
        public Integer numeroProposta { get; set; }
        public String motivoPendencia { get; set; } //II-32 INICIO-FIM
        public Integer motivoRecusa { get; set; } //II-48 INICIO-FIM
        public Integer origemProposta { get; set; } //PLV-4352 - YURI - INÍCIO/FIM
        public String nomeCliente { get; set; }
        public String nomeSocial { get; set; } //LECVPV-177 - INICIO/FIM
        public String cpfCliente { get; set; }
        public String status { get; set; }
        public String produto { get; set; }
        public String inicioVigencia { get; set; }
        public String fimVigencia { get; set; }
        public String formaPagamento { get; set; }
        public Integer quantidadeParcelas { get; set; }
        public String contratacaoPDF { get; set; }
        public List<CriticasPropostaTO> criticas { get; set; } //PLV-4304 - INICIO/FIM - Inclusao da variavel
        //PLV-4605 - inicio
        public String email { get; set; }
        public String telefoneresidencial { get; set; }
        public String telefonecomercial { get; set; }
        public String telefonecelular { get; set; }
        //FNPVVEP-98 INICIO
        public Boolean linkExpirado { get; set; }
        public String linkQuestionarioSamplemed { get; set; }
        public String idDoProponente {get; set; }
        public Datetime horaExpiracaoLink {get; set; } //FNPVVEP-98 - INICIO/FIM - FIX
        //FNPVVEP-98 FIM
        //PLV-4605 - fim
        //PLV-5024 - INICIO
        public String susepCorretor { get; set; }
        public String emailCorretor { get; set; }
        //PLV-5024 - FIM
        
        //PLV-5528 - INCIO
        public String segmento { get; set; }
        public String codigoPrecificacao { get; set; }
        //PLV-5528 - FIM

        public String corretorCelular { get; set; } //PLV-5493 - INICIO/FIM

        //PLV-5436 - INCIO
        public String statusCriacao { get; set; }
        public String statusAguardaAnalise { get; set; }
        public String statusAnalise { get; set; }
        public String statusDispContratacao { get; set; }
        public String statusContratada { get; set; }
        public String statusDevolvida { get; set; }
        public String statusRecusada { get; set; }
        //II-12 INCIO
        public String faseStatusAnalise { get; set; }
        public List<String> faseStatusAnaliseNew { get; set; }
        //II-12 FIM
        //PLV-5436 - FIM
        //FNPVVEP-22 INICIO
        public String apolicePdfDownloadUrl { get; set; }
        public String endossoPdfDownloadUrl { get; set; }
        //FNPVVEP-22 FIM
    }

    //PLV-4304 - INICIO - Criacao de estrutura para retorno
    public class CriticasPropostaTO{
        public String area {get;set;}
        public String codigo {get;set;}
        public String descricao {get;set;}
        public String mensagemCliente {get;set;}
        public String mensagemInterna {get;set;}
        public String mensagemRepresentante {get;set;}
        public String origem {get;set;}
        public String status {get;set;}
        public String tipo {get;set;}
        public String momentoAnalise {get;set;} //II-12 INCIO-FIM
    }
    //PLV-4304 - FIM
}