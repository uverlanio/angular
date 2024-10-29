/**************************************************************************************************
 * 
 * Classe responsavel para expor o serviço REST de gravar orçamento
 *
 *************************************************************************************************** */
//PLV-3649 - INICIO - Criação da classe de serviço
@RestResource(urlMapping = '/gravarorcamentos/*') 
global with sharing class GravarOrcamentoRest {

    @HttpPost
    global static Response gravar(){ 
        Response result = new Response();
        String body = RestContext.request.requestBody.toString();
        System.debug('carlos ' + body);
        Request rs = (Request) JSON.deserialize(body, Request.class);
        system.debug('json orçamento rest '+ JSON.serialize(rs));

        GravarOrcamentoService service = new GravarOrcamentoService(rs);

        result.data = service.getComplemento();
        system.debug('retorno ' + JSON.serialize(result));

        return result;
    }
    /* ***************************************************************** */
    global class Request {
        public EmissaoTO.OfertasTO[] ofertas {
            get;
            set;
        }
    }

    /* ***************************************************************** */
    global class Response {
        // global Object data {get; set;}
        //public ServiceTO data {get; set;}
        public ServiceTO.PayRetornoOfertasTO data {get; set;}
        public MetaTO meta {
            get;
            set;
        }

        global Response() {
            this.meta = new MetaTO();
        }
    }

    global class MetaTO {
        public String servico {
            get;
            set;
        }
        public Datetime dataExecucao {
            get;
            set;
        }
        public Integer statusHttp {
            get;
            set;
        }
        public String mensagem {
            get;
            set;
        }

        private transient Long startTime = System.currentTimeMillis();
        public Long executionTime {
            get {
                return System.currentTimeMillis() - this.startTime;
            }
        }

        public MetaTO() {
            this.servico = 'gravarorcamentos';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

    /*global class ServiceTO {
        public PayRetornoOfertasTO retorno {get; set;}
    }

    global class PayRetornoOfertasTO {
		public List<OfertaTO> ofertas { get; set; }
        public RetornoValidacaoProdutoTO retornoValidacaoProduto { get; set; } 
    }
    
    global class OfertaTO {
		public OrcamentoTO orcamento { get; set; }
		public RegrasRetornoOfertaTO regras  { get; set; }
		public List<ParcelamentoTO> parcelamentos { get; set; }
		public RetornoAceitacaoTO retornoAceitacao { get; set; }
    }
    
    global class RetornoValidacaoProdutoTO {
        public List<RecusaTO> recusas { get; set; }
   }

   global class RecusaTO
    {
        public Integer codigo { get; set; }
        public MensagenTO mensagens { get; set; }
        public String descricao { get; set; }
        public String area { get; set; }
        public String procedimento { get; set; }
        public Integer severidade { get; set; }
    }
    
    global class MensagenTO
    {
        public String interna { get; set; }
        public String cliente { get; set; }
        public String representante { get; set; }
    }

    global class OrcamentoTO {
		public String ordemPortal { get; set; }
		public String numeroOrcamento { get; set; }
		public String numeroPortal { get; set; }
		public Boolean varConsultivo {get;set;}
    }
    
    global class ParcelamentoTO
	{
		public Integer qtdParcelas { get; set; }
		public Integer juros { get; set; }
		public Double iof { get; set; }
		public Integer encargos { get; set; }
		public String descricao { get; set; }
		public Integer custoapolice { get; set; }
		public Integer codigo { get; set; }
		public String meioRecebimentoPrimeiraParcela { get; set; }
		public String meioRecebimentoDemaisParcelas { get; set; }
		public String valorPrimeiraParcela { get; set; }
		public String valorDemaisParcelas { get; set; }
		public String idFormaPagamento { get; set; }
		public String agrupamento { get; set; }
		public integer opcao {get; set;}
		public Decimal descontoAgravo { get; set; }
    }

    global class RegrasRetornoOfertaTO {
        public List<String> coberturasLideres { get; set; }
        public List<CoberturaRetornoOfertaTO> coberturas { get; set; }
        public List<RemuneracaoRetornoOfertaTO> remuneracoes { get; set; }
    	public List<QuestionarioTO> questionarios { get; set; }
    }

    global class CoberturaRetornoOfertaTO {
        public String sigla { get; set; }
		public Decimal prioridade { get; set; }
		public String nome { get; set; }
        public String tipo { get; set; }
        public Boolean obrigatorio { get; set; }
        public Double limiteMinimo { get; set; }
        public Double limiteMaximo { get; set; }
        public List<String> inclui { get; set; }
        public String descricao {get;set; }
    }

    global class RemuneracaoRetornoOfertaTO {
        public String tipoRemuneracao { get; set; }
        public Boolean obrigatorio { get; set; }
        public Double limiteMinimo { get; set; }
        public Double limiteMaximo { get; set; }
    }

    global class QuestionarioTO {
    	public String idPergunta { get; set; }
    	public String pergunta { get; set; }
    	public String tipoResposta { get; set; }
    	public String opcoesRespostas { get; set; }
    	public String proximaPergunta { get; set; }
    }

    global class RetornoAceitacaoTO
    {
        public List<AnaliseTO> analises { get; set; }
        public List<AvisoTO> avisos { get; set; }
        public List<RecusaTO> recusas { get; set; }
        public List<PendenciaTO> pendencias { get; set; }
    }

	global class AnaliseTO
    {
        public Integer codigo { get; set; }
        public String area { get; set; }
        public String procedimento { get; set; }
        public String descricao { get; set; }
        public Integer severidade { get; set; }
        public MensagenTO mensagens { get; set; }
    }
    
    global class AvisoTO
    {
        public Integer codigo { get; set; }
        public String area { get; set; }
        public MensagenTO mensagens { get; set; }
        public String procedimento { get; set; }
        public String descricao { get; set; }
        public Integer severidade { get; set; }
    }

	global class PendenciaTO
    {
        public String identificacao { get; set; }
        public Boolean atendida { get; set; }
        public MensagenTO mensagens { get; set; }
        public String area { get; set; }
        public Integer codigo { get; set; }
        public String procedimento { get; set; }
        public String descricao { get; set; }
        public Integer severidade { get; set; }
    }*/

}

//PLV-3649 - FIM