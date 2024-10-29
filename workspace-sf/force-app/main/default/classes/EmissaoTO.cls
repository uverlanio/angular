/**
 * @description       : 
 * @author            : giordano.menezes@globant.com
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class EmissaoTO {

    public class PayloadTO
    {
        public EmissaoTO proposta { get; set; }   
        public PessoaTO proposta2 { get; set; }   //OKR-146 INICIA-FIN        
        public EmissaoTO orcamento { get; set; }
        public List<EmissaoTO> orcamentos { get; set; }
        public List<PayloadTO> propostas { get; set; } // PLV-4606
        //PLV2365: INICIO
        public List<OfertasTO> ofertas { get; set; }
        //PLV2365: FIM
		//PLV3294: INICIO
        public List<ContratanteTO> contratantes {get; set;}
		//PLV3294: FIM
        //PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
        public List<EmissaoTO> devolutivas { get; set; }
        public RetornoFinanceiroTO retornoFinanceiro { get; set; }
        //PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
        public CalculoTO calculo { get; set; }        
        public RetornoAceitacaoTO retornoAceitacao { get; set; }
        public RetornoIntegracoesTO retornoIntegracoes  { get; set; }
        public ResultadosIntegracoesTO resultadosIntegracoes  { get; set; } // PLV-4606 - INICIO / FIM
        public RetornoValidacaoProdutoTO retornoValidacaoProduto  { get; set; }
        public RetornoCalculoTO retornoCalculo  { get; set; }
        //PLV-3136 - INÍCIO
        public List<RetornoCalculoTO> retornosCalculo  { get; set; }
        //PLV-3136 - INÍCIO
        //PLV-3318 INICIO
    	//public List<VersoesCalculo> versoesCalculo;
        //PLV-3318 - FIM
        //PLV-4398 - Viagem - INICIO - Correção Múltiplos passageiros
        public Boolean atualizarOrcamento { get; set; }
        //PLV-4398 - Viagem - FIM - Correção Múltiplos passageiros
        public Boolean recusada  { get; set; }//PLV-4993 - INICIO/FIM -PEDRO AUGUSTO BRAZ;
        public String origemRecusa  { get; set; }//PLV-4993 - INICIO/FIM -PEDRO AUGUSTO BRAZ;

    }
    //PLV-3318 INICIO
   	public class VersoesCalculo {
		public Integer opcao;
		public string tipo;
		public Decimal descontoAgravo;
       
	}
    //PLV-3318 - FIM

    //PLV-5066 INICIO
    public class TipoEndossoTO{
        public Boolean cad;
    } 
    //PLV-5066 FIM

    //PLV2365: INICIO
    public class OfertasTO {
        public EmissaoTO orcamento { get; set; } 
        public List<EmissaoTO> propostas { get; set; }       
        //PLV-3136 - INÍCIO
        public List<RetornoCalculoTO> retornosCalculo { get; set; }
        //PLV-3136 - FIM
        public RetornointegracoesTO retornoIntegracoes { get; set; }
         //PLV-2439 - INICIO
        public RetornoaceitacaoTO retornoAceitacao { get; set; }
        //PLV-2439 - INICIO
    }
    //PLV2365: FIM
    
    //PLV-4393 - Pedro Augusto Braz - Sys4b - Inicio
    public Boolean customizavel { get; set; }
    //PLV-4393 - Pedro Augusto Braz - Sys4b - Fim
    public String dataEndosso {get;set;} //PLV-4686 - INÍCIO/FIM - Guilherme Brito
	// PLV-2372-29 INICIO
    public String chaveContrato { get; set; }
    // PLV-2372-29 FIM
    public String empresa { get; set; }
    public Integer sucursal { get; set; }
    public Integer ramo { get; set; }
    public String apolice { get; set; }
    public String tipoSeguro { get; set; }

    // RVI-118 INICIO
    public String idContratoRenovado { get; set; }  
    // RVI-118 FIM

    //RVI-117 INICIO
    public Decimal IndiceIPCA { get; set; }
    //RVI-117 FIM

    public String tipoEndosso { get; set; }
    public TipoEndossoTO tiposEndosso {get; set;} //PLV-5066 INICIO/FIM 
    public String dataCalculo { get; set; }
    public String vigenciaInicial { get; set; }
    public String meioComercializacao { get; set; }
    // public String _DecisionID_ { get; set; } // PLV-4606
    // PLV-3079 INICIO
    public Boolean varConsultivo { get; set; }
    // PLV-3079 FIM

    //PLV-3926 - INICIO - Novo campo
    public Double premioPago {get;set;}
    //PLV-3926 - FIM

    //PLV-4199 - INICIO - Campo da susep do corretor para o orcamento
    public String susepOrcamento {get;set;}
    //PLV-4199 - FIM

    //-- informação incluída na PLV1793
    public String entradaNegocio { get; set; }
    // PLV-2312-28 INICIO Inclusao do id do lote no payload
    public String idlote { get; set; }
    public String nomeArquivo { get; set; }
    // PLV-2312-28 FIM Inclusao do id do lote no payload
    public String endosso { get; set; }
    public EmissaoTO contratoOriginal { get; set; }
    public Integer origemOriginal { get; set; }
    public String numeroOriginal { get; set; }
    public String canalDistribuicao { get; set; }
    public String parceiro { get; set; }
    public String tipoResponsavelPagamento { get; set; }
    public String tipoBeneficiario { get; set; }
    public String idContratoParceiro { get; set; }
    public String idContratanteParceiro { get; set; }
    public Integer origem { get; set; }
    public String numero { get; set; }
    public String segmento { get; set; }
    public String origemRequisicao { get; set; }
    public Integer codigoEmpresa { get; set; }
    public String nomeEmpresa { get; set; }
    public String numeroOrcamento { get; set; }
    public String numeroPortal { get; set; }    
    // PLV-2365-29 INICIO    
    public String ordemPortal { get; set; }
    // PLV-2365-29 FIM
    // PLV-2502 INICIO    
    public String ProductCode { get; set; }
    // PLV-2502 FIM
    public String cupomDesconto { get; set; }  // AV-664 INICIO - FIM
    public String numeroApolice { get; set; }
    public Integer numeroEndosso { get; set; }
    public Integer numeroSucursal { get; set; }
    public Integer ramoSeguro { get; set; }
    public String descricaoRamo { get; set; }
    public Integer modalidade { get; set; }
    public String descricaoModalidade { get; set; }
    public String dataProtocolo { get; set; }
    public String dataCriacaoPortal { get; set; }
    public String codigoProdutoVida { get; set; }
    public String idProdutoSf { get; set; } // PLV-5331 INICIO / FIM
    public String descricaoProduto { get; set; }
    public String tipoVigencia { get; set; }
    public String vigenciaFinal { get; set; }
    public Double descontoEmissaoEspecial { get; set; }
    public Integer setorOrigem { get; set; }
    public String dataEmissao { get; set; }
    public String dataCancelamento { get; set; }
    public String status { get; set; }
    public String descricaoStatus { get; set; }
    public String mensagemStatus { get; set; }
    public String observacoesGerais { get; set; }
    public Boolean flagReentrada { get; set; }
    public Integer idProtocolo { get; set; }
    // 2666 - INICIO
    public Boolean imprimirCertificadoSeguro { get; set; }
    // 2666 - FIM
    public List<PendenciaTO> pendencias { get; set; }
    public List<ArquivoTO> arquivos { get; set; }
    public RemuneracaoTO remuneracao { get; set; }
    public EventoTO evento { get; set; }
    public ViagemTO viagem { get; set; }
    public TransferenciaCongenereTO transferenciaCongenere { get; set; }
    public DadosDevolucaoTO dadosDevolucao { get; set; }
    public List<ContratanteTO> contratantes { get; set; }
    public PrecificacaoTO precificacao { get; set; }
    public List<RemuneracaoTO> remuneracoes { get; set; }
    public List<CoberturaTO> coberturas { get; set; }
    public Integer indice { get; set; }     //PLV-3285 - INÍCIO 
	//PLV-3318 - INICIO
    public List<VersoesCalculo> versoesCalculos{get;set;}
	//PLV-3318 - FIM
    //public QuestionarioTO questionario { get; set; }
    //public String quantidadeParcelas { get; set; }
    //public String numeroPortal { get; set; }
    //public List<SeguradoTO> segurado { get; set; }
    //public List<ParcelasTO> parcelas { get; set; }
    //public String boletoGeral { get; set; }

    //PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
    public EmissaoTO proposta { get; set; }
    public RetornoAceitacaoTO retornoAceitacao { get; set; }
    //PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista

    
    // PLV-4440 - INICIO - Odemir/SYS4B 071020
    public String  tempoRendaProtegida { get;set;}    //PorQuantoTempoQuerGarantirRenda__c
    public Boolean dependentesFinanceiros { get;set;} // DependentesFinanceiros__c
    //public String  tipoContrato  { get;set;}          // TipoContrato__c //PLV-4725
    public String formaReceberApolice { get;set; }    // FormaReceberApolice__c
    public Boolean  termoGuarda { get;set;}           // TermoGuarda__c
    public Boolean termoResponsabilidade {get;set;}   // TermoResponsabilidade__c
    public Boolean assinaturaEletronica {get;set;}    // AssinaturaEletronica__c
    public Boolean reaproveitarAssinatura {get;set;}    //ReaproveitarAssinatura__c PLV-5643 INICIO/FIM 
         
    // PLV-4440 - FIM -  Odemir/SYS4B 071020

    // PLV-4416 - INICIO 
    public Decimal scoreFraude { get; set; }
     // public String  ramoSeguro  { get; set;} // ja defindo abaixo como Integer ( PLV-2502)
    // PLV-4416 - FIM 
    public Decimal scoreSerasa { get; set; }//PLV - 4388 - INICIO/FIM - Gustavo Pereira SYS4b
   
    public String melhorPeriodo { get; set; } // PLV-4386 - INÍCIO/FIM

    public String tarifa { get; set; }//PLV-4488 INICIO/FIM // PLV-4606
    public RetornoIntegracoesTO resultadoIntegracoes { get; set; }//PLV-4488 INICIO/FIM // PLV-4606
    
    // II-25 INICIO
    public List<SeguradoTO> segurados { get; set; } 
    public List<RetornoCalculoTO> retornosCalculoOriginal { get; set; } 
    public Integer qtdDiasVigencia { get; set; }
    public DadosPagamentoTO dadosPagamento { get; set; }
    // II-25 FIM


    public String  senha { get; set; } // MGRC-505 INICIO-FIM
	public String  distributionPublicUrl { get; set; } // MGRC-505 INICIO-FIM

    public class CalculoTO
    {
        public PrecificacaoTO precificacao { get; set; }
    }

    public class ContratoTO
    {

    }

    public class PrecificacaoTO
    {
        public Decimal iof { get; set; }
        public Decimal juros { get; set; }
        public PremioTO premio { get; set; }
        public List<ContratanteTO> contratantes { get; set; }
        public Decimal custoApolice { get; set; }
        public Integer custoDeApolice { get; set; } // PLV-4706 - INÍCIO/FIM
        public TaxaTO taxa { get; set; }
        public Decimal encargos { get; set; }
        public List<CoberturaTO> coberturas { get; set; }
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
    }

    public class DescontoagravoTO
    {
        public Decimal percentual { get; set; }
        public String tipo { get; set; }
        public Decimal monetario { get; set; }
    }

    public class EventoTO
    {
        public String tipoEvento { get; set; }
        public String qstControlePublico { get; set; }
        public String qstLocalEvento { get; set; }
        public String informacoesEvento { get; set; }
    }

    public class QuestionarioTO
    {
        public String codigo { get; set; }
        //public String idQuestionario { get; set;} //PLV-4257-FIX-2-VI inicio/fim
        public String idquestionario { get; set;}  //RVI-138 INICIO-FIM FIX01
        public List<RespostaTO> respostas { get; set; }
    }

    public class DadosDevolucaoTO
    {
        public String susepCorretor { get; set; }
        public String codigo { get; set; }
        public String motivo { get; set; }
        public String matricula { get; set; }
    }

    public class RemuneracaoTO
    {
        public String tipoRemuneracao { get; set; }
        // PLV-4234 - INICIO
        public Decimal DICIO_RETENCAO  { get; set; }
        // PLV-4234 - FIM
        public String canal { get; set; }
        public String susep { get; set; }
        public String susepEmissao { get; set; }
        public String susepOrcamento { get; set; }
        public String tipoPessoaCorsus { get; set; }
        public String codigoOperacao { get; set; }
        public Decimal codigoOperacaoPercentual { get; set; }
        public String codigoOperacaoImprimir { get; set; }
        public Decimal percentual { get; set; }
        public Decimal retencao   { get; set; }  // PLV-4470 INICIO/FIM
        public Decimal proLabore { get; set; }
        public Decimal agenciamento { get; set; }
        public Decimal assessoria { get; set; }
        public List<AgenteTO> agentes { get; set; }
        public List<FavorecidoTO> favorecidos { get; set; }
        public RemuneracaoProposta__c ojSFProposta { get; set; }
        public RemuneracaoOrcamento__c ojSFOrcamento { get; set; }
        public Double bonusCampanha {get;set;} //II-167 INICIO-FIM
    }

    public class FavorecidoTO
    {
        public String papel { get; set; }
        public Decimal corretagem { get; set; }
        public Decimal participacao { get; set; }
        public String susep { get; set; }
        public String tipoPessoaCorsus { get; set; }
        public String susepEmissao { get; set; }
        public String susepOficialCorretor { get; set; }
        public String susepOrcamento { get; set; }
        public Decimal agenciamento { get; set; }
        public Decimal proLabore { get; set; }
        public Decimal assessoria { get; set; }
        public PessoaTO pessoa { get; set; }
        public Boolean corretorLider { get; set; }
        public Boolean antecipaComissao { get; set; } //PLV-4344 - Inicio/Fim
        public Boolean antecipacaoComissao { get; set; } //PLV-4488 INICIO/FIM // PLV-4606
        public Boolean corretorResponde { get; set; } //PLV-5493 - INICIO/FIM
        public String corretorCelular { get; set; } //PLV-5493 - INICIO/FIM
    }

    public class PendenciaTO
    {
        public String identificacao { get; set; }
        public Boolean atendida { get; set; }
        public MensagenTO mensagens { get; set; }
        public String area { get; set; }
        public Integer codigo { get; set; }
        public String procedimento { get; set; }
        public String descricao { get; set; }
        public Integer severidade { get; set; }
        public String setor { get; set; } //PLV-4790 INICIO/FIM
        public String momentoAnalise { get; set; } //PLV-4790 FIX 11
    }

    //PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
	public class DecisaoTO{
        public Integer codigo { get; set; }
        public String descricao { get; set; }
        public String tipo { get; set; }
        public String acao { get; set; }//PARA O QUESTIONARIO AQUI VAI ESTAR O CODIGO DO QUESTIONARIO
	}
	//PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B

    public class ContratanteTO
    {
        public Account contaSf { get; set; }
        public ContratanteProposta__c objSf { get; set; }
        public ContratanteOrcamento__c objSfO { get; set; }
        public String idSf { get; set; }
        public String numero { get; set; } 
        public String tipo { get; set; }
        public PessoaTO pessoa { get; set; }
        public Decimal iof { get; set; }
        public PremioTO premio { get; set; }
        public TaxaTO taxa { get; set; }
        public List<CoberturaTO> coberturas { get; set; }
        public String formaReceberApolice { get;set; } //PLV-4612 - INICIO/FIM
        public List<GrupoTO> grupos { get; set; }
        public ContatoTO contato { get; set; }
        public DadosPagamentoTO dadosPagamento { get; set; }
        public List<DescontoagravoTO> descontoAgravo { get; set; } 
        public String conta {get;set;} //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B
        public Boolean manterPlanoParcelamento {get;set;} //PLV-5066 INICIO/FIM
        public Boolean recorrencia {get;set;} //TKCL 460 - INICIO/FIM

    }
    
    //INICIO | PLV-2610
    public class BeneficiarioTO
    {
        public String tipoBeneficiario { get; set; }
        public Double participacao { get; set; }
        public String grauParentesco { get; set; }
        public String grauParentescoOutros { get; set; } //PLV-5231 - INICIO/FIM
        public PessoaTO pessoa { get;set; }
        //INICIO | PLV-2355
        public String motivoSemCpfCnpj { get; set; }
        //FIM | PLV-2355

        // PLV-4440 - INICIO - Odemir/SYS4B 071020
        public Date nascimento {get;set;}    // Nascimento__c
        public Decimal percentualIndenizacao {get;set;}    // PercentualIndenizacao__c
        public String nome {get;set;}   // name
        public String nomeSocial {get;set;} // LECVPV-184 INICIO/FIM
        public String cpf  { get;set;}  // CpfCnpj__c
        public String sexoBeneficiario {get;set;} //PLV - 4473 complemento - INICIO/FIM
        public Boolean imprimirCertificado {get;set;}
        // PLV-4440 - FIM- Odemir/SYS4B 071020
    }

    public class DadosPagamentoTO
    {
        public String vencimentoPrimeiraParcela { get; set; }
        //PLV-2146 - INÍCIO
        public Integer opcao { get;set; }
        //PLV-2146 - FIM
        public String tipoResponsavelPagamento { get; set; }
        public FormaPagamentoTO formaPagamento { get; set; }
         // PLV-3285 - INICIO
        public Integer codigoFormaPagamento { get; set; }
        public String descricaoFormaPagamento { get; set; }
        public String codigoMeioRecebimento { get; set; }
        public dadosCartaoCreditoTO dadosCartaoCredito  { get; set; }
         // PLV-3285 - FIM
        public DadosBancarioTO dadosBancarios { get; set; }
        public PessoaTO responsavelPagamento { get; set; }
        public CartaoCreditoTO cartaoCredito { get; set; }

        public String idPlanoParcelamento { get; set; }
        public Integer quantidadeParcelas { get; set; }
        public String boleto { get; set; }
        public List<ParcelaTO> parcelas { get; set; }

        public String formaInfoCartao {get; set;} //RVI-248 - INICIO/FIM
        
        // PLV-4440 - INICIO - ODEMIR - SYS4B 071020
        public String vencimentoDemaisParcelas { get; set; }
        public String vigenciaInicial { get; set; }
        public String diasPagamento { get; set; }
        public PessoaTO responsavelFinanceiroSeguro { get; set; } //PLV-4911 - INICIO/FIM
        public Boolean responsavelFinanceiro { get; set; } //PLV-5067 - INICIO/FIM
        // PLV-4440 - FIM - ODEMIR - SYS4B 071020
        public Decimal premioTotal {get;set;}//PLV-4488 INICIO/FIM // PLV-4606
        public Integer codigo {get;set;}//PLV-4488 INICIO/FIM // PLV-4606
        public String descricao {get;set;}//PLV-4488 INICIO/FIM // PLV-4606
        // TKCL-473 - INICIO
        public Decimal valorPrimeiraParcela {get;set;}
        public Decimal valorDemaisParcelas {get;set;}
        // TKCL-473 - FIM
     
        
    }

    // PLV-3285 - INICIO
    public class dadosCartaoCreditoTO {
        public String numero { get; set; }
        public String validade { get; set; }
        public String validadeCriptografada { get; set; }//PLV-4449 - INICIO/FIM
        public String nome { get; set; }
        public String ticket { get; set; }//PLV-4449 - INICIO/FIM
        public String bandeira { get; set; }//PLV-4926 - INICIO/FIM
        public Boolean cartaoPorto {get; set;}
        // RVI-39 - INICIO
        public String nomeTitular { get; set; }
        public String codigoBandeiraCartao { get; set; }///
        public String nomeTitularCartao { get; set; }//
        public String ticketCartao { get; set; }//
        public String codigoSeguranca { get; set; }
        
        public String cvv { get; set; } //Add Julio Duarte - 24/2/2022
        // RVI-39 - FIM
    }




    // PLV-3285 - FIM
    public class FormaPagamentoTO {

        public String idFormaPagamento { get; set; }
        public String descricao { get; set; }
        public String codigo { get; set; }
        // 2666 - INICIO
        public PlanoParcelamentoTO planoParcelamento { get; set; }
    }

    public class PlanoParcelamentoTO {

        public Integer quantidadeParcelas { get; set; }
        public String idPlanoParcelamento { get; set; }
        public String codigoMeioRecebimento { get; set; }
        public Decimal valorParcela { get; set; }
        // 2666 - FIM
    }

    /*public class ResponsavelpagamentoTO
    {
        public DadosPessoaFisicaTO dadosPessoaFisica { get; set; }
        public DadosPessoaJuridicaTO dadosPessoaJuridica { get; set; }
        public String nome { get; set; }
        public String tipo { get; set; }
    }*/
    //FIM | PLV-2610

    public class TaxaTO
    {
        public Decimal pura { get; set; }
        public Decimal mensal { get; set; }
        public Decimal anual { get; set; }
        public Decimal puroInterno { get; set; }
        public Decimal puroResseguro { get; set; }
        public Decimal comercial { get; set; }
        public Decimal total { get; set; }
    }

    public class PessoaTO
    {
        public String tipo { get; set; }
        public String nome { get; set; }
        public String nomeSocial { get; set; }  // LECVPV-184 INICIO/FIM
        public String email { get; set; }
        public Double rendaMensal { get; set; }
        public String melhorPeriodo { get; set; } // PLV-4612 - INÍCIO/FIM
        public String nivelRelacionamento {get; set; } //OKR-134 - INÍCIO/FIM 
        // PLV-3285 - INICIO
        public String pep { get; set; }
        public pessoaRelacionamentoPepTO pessoaRelacionamentoPep { get; set; }
        // PLV-3285 - FIM
		
        //PLV - 4440 - INCIO
        public String pessoaExpostaPoliticamente { get; set; }
        public PessoaRelacionamentoPepTO pessoaPEP { get; set; }
        //PLV - 4440 - FIM

        public RetornoIntegracaoPepTO  retornoIntegracaoPEP { get; set; } // // PLV-4594 INICIO/FIM SYS4B ODEMIR
        public List<EnderecoTO> enderecos { get; set; }
        public List<TelefoneTO> telefones { get; set; }
        public String tipoPessoa { get;set; } // ANNVI-18 - INICIO/FIM
        public DadosPessoaFisicaTO dadosPessoaFisica { get; set; }
        public DadosPessoaJuridicaTO dadosPessoaJuridica { get; set; }
        public String vinculoComSegurado { get; set; }   //PLV-4911 - INICIO/FIM

    }

    //PLV - 4440 - INICIO
    public class ResponsavelFinanceiroSeguroTO {
        public String nome { get; set; }   // nomeResponsavel__c
        public String cpf { get; set; }   // CpfResponsavel__c
        public String vinculoComSegurado { get; set; }   // vinculoComSegurado__c
    }
    //PLV - 4440 - FIM

    public class GrupoTO
    {
        public GrupoProposta__c objSF { get; set; }
        public GrupoOrcamento__c objSFO { get; set; }
        public String idSf { get; set; }
        public String nome { get; set; }
        public String numero { get; set; }
        public String tipoSegurado { get; set; }
        // 2666 - INICIO
        public Double qtdeVidas { get; set; } //PLV - 4487 - VI - INICIO/FIM - Gustavo Pereira SYS4B
        // 2666 - FIM
        public String idArquivoVidas { get; set; }
        public String tipoCalculo { get; set; }
        public String prazoMaximoFinanciamentoPrestamista { get; set; }
        public Decimal saldoDevedor { get; set; }
        public Decimal valorDoBem { get; set; }
        public PremioTO premio { get; set; }
        public Decimal agravo { get; set; }
        public Decimal desconto { get; set; }
        public String escolhaDescontoAgravo {get;set;}
        public Decimal valorDescontoAgravo {get;set;}
        public TaxaTO taxa { get; set; }
        public Decimal iof { get; set; }
        public List<SeguradoTO> segurados { get; set; }
        public List<CoberturaTO> coberturas { get; set; }
        public List<DescontoagravoTO> descontoAgravo { get; set; }
        public Integer tarifa { get; set; }//PLV-4488 INICIO/FIM // PLV-4606
    }

    public class SeguradoTO
    {
        public SeguradoProposta__c objSF { get; set; }
        public SeguradoOrcamento__c objSfO { get; set; }
        public String numero { get; set; }
        public String nome { get; set; }
        public Date dataNascimento { get; set; }
        public String numeroCpf { get; set; }
        public String digitoCpf { get; set; }
        public String afastado { get; set; }
        public List<String> cid { get; set; }
        public Decimal iof { get; set; }
        public PremioTO premio { get; set; }
        public TaxaTO taxa { get; set; }
        public List<CoberturaTO> coberturas { get; set; }
        public PessoaTO pessoa { get; set; }
        //PLV-2666 - Inicio
        public DadosPagamentoTO dadosPagamento { get; set; }
        //PLV-2666 - Fim
        public List<DescontoagravoTO> descontoAgravo { get; set; }
        public List<BeneficiarioTO> beneficiarios { get; set; }
        public String vigenciaInicial { get; set; }
        public String vigenciaFinal { get; set; }
        public QuestionarioTO questionario { get; set; }
        //PLV-3285 - Inicio
        public ContatoEmergenciaTO contatoEmergencia { get; set; }
        //PLV-3285 - Fim
        //PLV-4071 - INICIO - PEDRO AUGUSTO - SYS4B
        public String profissao { get; set; }
        //PLV-4071 - FIM - PEDRO AUGUSTO - SYS4B
        //PLV - 4440 - INICIO
        public Boolean responsavelFinanceiro { get; set; }
        public PessoaTO responsavelFinanceiroSeguro { get; set; }//PLV-4911 - INICIO/FIM
        public String  empresaQueTrabalha { get;set;}  //EmpresaQueTrabalha__c
        public String  ramoAtividade { get;set;}  //PLV-4595
        public String  ocupacaoProfissionalPrincipal { get;set; }  //profissao__c
        public String  formaTrabalho { get;set; }      // RegimeTrabalho__c
        public String  faixaRenda { get;set ;}         // faixaRenda__c
        //PLV - 4440 - INICIO
        public Decimal  limiteProfissao { get;set ;}         // PLV-4606 INICIO/FIM
        // II-25 INICIO
        public List<TelefoneTO> telefones {get;set;} 
        public List<EnderecoTO> enderecos {get;set;}
        public Double rendaMensal { get; set; }
        public String pessoaExpostaPoliticamente { get; set; }
        public DadosPessoaFisicaTO dadosPessoaFisica {get;set;}
        public String email {get;set;}
        // II-25 FIM
        
    }

    //PLV-3285 - Inicio
    public class ContatoEmergenciaTO {
        public String nome { get; set; }
        public String ddd { get; set; } //VIAG-288 INICIO/FIM 
        public String telefone { get; set; }
    }
    //PLV-3285 - Fim

    public class PremioTO
    {
        public Decimal informado { get; set; }
        public Decimal puro { get; set; }
        public Decimal puroDesconto { get; set; }
        public Decimal puroInterno { get; set; }
        public Decimal puroResseguro { get; set; }
        public Decimal puroCarregado { get; set; } // II-25 INICIO/FIM
        public List<DescontoagravoTO> descontoAgravo { get; set; } // II-25 INICIO/FIM
        public Decimal premioPago { get; set; }//PLV-4488 INICIO/FIM // PLV-4606
        public Decimal comercial { get; set; }
        public Decimal comercialDesconto { get; set; }
        public Decimal total { get; set; }
        public Decimal integral {get ; set;} //PLV-5147 INICIO/FIM FIX 03 
    }

    // 2666 - INICIO
    public class CartaoCreditoTO
    {
        public String nomeTitular { get; set; }
       public String codigoBandeiraCartao { get; set; }///
        public String nomeTitularCartao { get; set; }//
        public String ticketCartao { get; set; }//
        public String ticket { get; set; }
        public String numero { get; set; }
        public String codigoSeguranca { get; set; }
        public String validade { get; set; }
        public String validadeCriptografada { get; set; }//PLV-4449 - INICIO/FIM
        public Boolean cartaoPorto { get; set; }
    }
    // 2666 - FIM

    public class AgenteTO
    {
        public String papel { get; set; }
        public Decimal corretagem { get; set; }
        public String susep { get; set; }
        public String tipoPessoaCorsus { get; set; }
        public String susepEmissao { get; set; }
        public String susepOrcamento { get; set; }
        public Decimal agenciamento { get; set; }
        public Decimal proLabore { get; set; }
        public Decimal assessoria { get; set; }
        public PessoaTO pessoa { get; set; }
        public SusepBloqueioTO susepBloqueios { get; set; } // PLV-4606
    }

    // PLV-4606 - Inicio
    public class SusepBloqueioTO
    {
        public List<BloqueioTO> bloqueios { get; set; }
    }

    public class BloqueioTO
    {
        public String bloqueioProducao { get; set; }
        public String bloqueioComissoes { get; set; }
        public String bloqueioFenacor { get; set; }
        public String bloqueioInativos { get; set; }
        public String susepPorto { get; set; }
        public String status { get; set; }
    }
    
    // PLV-4606 - FIM

    public class TelefoneTO
    {
        public String tipoTelefone { get; set; }
        public String dddTelefone { get; set; }
        public String numeroTelefone { get; set; }
    }

    public class ParcelaTO
    {
        public String boleto { get; set; }
        public String dataVencimentoParcela { get; set; }
        public DadosPagamentoTO dadosPagamento { get; set; }
        public String numeroParcela { get; set; }
        public String meioPagamento { get; set; }
        public String numeroTitulo { get; set; }
        public Decimal valorParcela { get; set; }
        public Decimal valorIOF { get; set; }
        public String status { get; set; }
    }

    public class DadosPessoaFisicaTO
    {
        public String tipoRelacionamentoPep { get; set; }
        // INICIO - 2610
        public String pep { get; set; }
        public String cpfPep { get; set; }
        public String nomePessoaPep { get; set; }
        // FIM - 2610
        public String profissao { get; set; }
        public String numeroCpf { get; set; }
        public String sexo { get; set; }
        public String dataNascimento { get; set; }
        public List<DocumentoTO> documentos { get; set; }
        public String estadoCivil { get; set; }
        public String digitoCpf { get; set; }
        public Decimal imc { get; set; } // ANNVI-17 - Inicio/Fim
        public Integer idade { get; set; } //PLV-4388 - Inicio/Fim
        public String nacionalidade { get; set; }
        public String paisDeOrigem { get; set; } //PLV-5231 INICIO/FIM
        public String grupoProfissao { get; set; } // PLV-4606 - INICIO/FIM
        public PessoaTO pessoaRelacionamentoPep { get; set; }
        //PLV-2720 - Inicio - Incluido fumante para ser passado para conta e outras integrações
        public String cicloVacinal {get; set;}  //PLV-5124 INICIO/FIM 
        public Boolean fumante { get; set; }
        public Boolean temDependentes  { get; set; } //PLV - 4442 inicio/fim
        public DadosPessoaFisicaTO(){
            fumante = false; 
            temDependentes = false; //PLV - 4442 inicio/fim
        }
        public SerasaViagemTO serasa { get; set; } // PLV-4606
        //PLV-2720 - Fim

        //PLV - 4442 inicio
        public String renda  { get; set; }
        public String regimeTrabalho  { get; set; }
        public String tempoGarantiaRenda { get; set; }
        //PLV - 4442 fim
        // PLV-4440 - INICIO - ODEMIR - SYS4B 071020
         public String  ocupacaoProfissionalPrincipal { get;set; } 
         public String  formaTrabalho { get;set; }      // RegimeTrabalho__c
         public String  faixaRenda { get;set ;}         // faixaRenda__c
         public Boolean resideBrasil { get;set;}        //ResideBrasil__c
         public String  paisResidente { get;set;}       //PaisResidencia__c
         public String tipoDocIdentificacao { get;set;}   // TipoDocidentificacao__c
         public String docIdentificacao { get;set;}   // DocIndentificacao__c
         public String orgaoExpedidor { get;set;}   // OrgaoExpedidor__c
         public Date dataExpedicao { get;set;}   // DataExpedicao__c
         public String grauParentesco { get;set;}   // GrauParentesco__c
         // PLV-4440 - FIM -  ODEMIR - SYS4B
         //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH
         public String tipoEmpresa { get;set;}          
         public String numeroCnpj { get;set;} 
         public Integer qtdFuncionarios { get;set;} 
         //PLV-5098 - INICIO/FIM - BRUNO FILIPE/JOSE LUCIANO/GABRIEL LOCH

    }

    public class DadosPessoaJuridicaTO
    {
        public String numeroCnpj { get; set; }
        public String ordemCnpj { get; set; }
        public String digitoCnpj { get; set; }

        public String cnpj { get; set; }
        public String codigoCNAE { get; set; }
        public String descricaoCNAE { get; set; }
    }

    public class PessoaRelacionamentoPepTO
    {
        public String tipo { get; set; }
        public String nome { get; set; }
        public DadosPessoaFisicaTO dadosPessoaFisica { get; set; }
        public DadosPessoaJuridicaTO dadosPessoaJuridica { get; set; }
		//PLV - 4440 - INICIO 
        public String cpf { get; set; }
        public String grauParentesco { get; set; }
        //PLV - 4440 - FIM

        public RetornoIntegracaoPepTO  retornoIntegracaoPEP { get; set; } // // PLV-4594 INICIO/FIM SYS4B ODEMIR
        
    }


   // PLV-4594 INICIO  SYS4B ODEMIR
    public class RetornoIntegracaoPepTO
    { 
        public String pep    { get; set; }
        public String cargo  { get; set; }
        public String dataAtualizacao { get; set; }
    }
   // PLV-4594 FIM  SYS4B ODEMIR


    public class ContatoTO
    {
        public String ddd { get; set; }
        public String nome { get; set; }
        public String telefone { get; set; }
    }

    public class DocumentoTO
    {
        public String orgaoExpedidorDocumento { get; set; }
        public String numeroDocumentoIdentidade { get; set; }
        public String dataExpedicaoDocumento { get; set; }
        public String tipoDocumentoIdentidade { get; set; }
    }

    public class TransferenciaCongenereTO{
        public Integer tempoPermanencia { get; set; }
        public String congenere { get; set; }
        public Decimal taxaVigencia { get; set; }
        public Decimal sinistralidade { get; set; }
    }

    public class ViagemTO
    {
        public String trackageBagagem { get; set; }
        public String utilizaraMotocicleta { get; set; }
        public String passageirosNaoIdosos { get; set; }
        public String tipoViagem { get; set; }
        public String praticaEsportesAventura { get; set; }
        public List<DestinoTO> destinos { get; set; }
        public String incluiPaisSchengen { get; set; }
        public String passageirosIdosos { get; set; }
        public String nomePrincipal { get; set; } //PLV-4928 - FIX - INICIO/FIM
        public String nomeSocial {get; set;} // LECVPV-184 INICIO/FIM
    }

    public class DestinoTO
    {
        public String pais { get; set; }
        public String codigo { get; set; }//PLV-4488 INICIO/FIM // PLV-4606
    }

    public class CoberturaTO
    {
        public String idSf { get; set; }
        public String sigla { get; set; }
        public Decimal capital { get; set; }
        public Decimal iof { get; set; }
        public PremioTO premio { get; set; }
        public TaxaTO taxa { get; set; }
        public Decimal valor { get; set; }
        public Decimal agravo { get; set; }
        public Decimal desconto { get; set; }
        public String escolhaDescontoAgravo {get;set;}
        public Decimal valorDescontoAgravo {get;set;}
        public String garantiaReferenciada { get; set; }
        public Decimal percentual { get; set; }
        public String inclusaoIndenizacaoEspecial { get; set; }
        public Decimal percentualIndenizacaoEspecial { get; set; }
        public String inclusaoFilhos { get; set; }
        public Decimal percentualFilhos { get; set; }
        public String quantidade { get; set; }
        public String unidade {get; set;} // II-25 INICIO/FIM
        public Decimal importancia { get; set; }
        public String clausulaReducaoFranquiaAcidente { get; set; }
        public String numeroSerie { get; set; }
        public String numeroSorte { get; set; }
        public String dataSorteio { get; set; }
        public String tituloCapitalizacao { get; set; }
        public String statusCapitalizacao { get; set; }
        public String versaoCapitalizacao { get; set; }
        public String dataSolicitacao { get; set; }
        public Decimal capitalContratacao { get; set; } //PLV-4706 INICIO-FIM
        public String loteCapitalizacao { get; set; }
        public List<DescontoagravoTO> descontoAgravo { get; set; }
        public String franquia { get; set; } //PLV-4598 INICIO-FIM
        public Decimal caracteristicaespecialvalor { get; set; } //PLV-4620 FIX 2 INICIO-FIM
        public String caracteristicaespecialtipo { get; set; } //PLV-4620 FIX 2 INICIO-FIM
        public String limitemaximo { get; set; } //PLV-5419 INICIO-FIM
        public String limiteminimo { get; set; } //PLV-5419 INICIO-FIM
    }
   
    public class EnderecoTO
    {
        public String tipoLogradouro { get; set; }
        public String tipoEndereco { get; set; }
        public String logradouro { get; set; }
        public String numeroLogradouro { get; set; }
        public String complemento { get; set; }
        public String bairro { get; set; }
        public String cidade { get; set; }
        public String uf { get; set; }
        public String paisResidencia { get; set; }
        public String cep { get; set; }
        public String complementoCep { get; set; }
    }


    public class DadosBancarioTO
    {
        public String digitoConta { get; set; }
        public String agencia { get; set; }
        public String conta { get; set; }
        public String digitoAgencia { get; set; }
        public String banco { get; set; }
        public String tipoPessoa { get;set;} // PLV-4440 - INICIO/FIM - Odemir/SYS4B 071020
        public String cpf { get; set; } // PLV-5066 INICIO/FIM
    }

    public class ArquivoTO
    {
        public String descricao { get; set; }
        public String idArquivo { get; set; }
        public String nome { get; set; }
        public String bytes { get; set; }
    }

    public class RespostaTO
    {
        public String questao { get; set; }
        public String resposta { get; set; }
       // public String justificativa { get; set; } // ANNVI-17 - Inicio/Fim
    }

    public class RetornoAceitacaoTO
    {
        public List<AnaliseTO> analises { get; set; }
        public List<AvisoTO> avisos { get; set; }
        public List<RecusaTO> recusas { get; set; }
        public List<PendenciaTO> pendencias { get; set; }
	    //PLV-4260 - INICIO - PEDRO AUGUSTO - SYS4B
        public List<DecisaoTO> decisoes { get; set; }
        public String nr {get; set;}
	    //PLV-4260 - FIM - PEDRO AUGUSTO - SYS4B

    }

    public class AnaliseTO
    {
        public Integer codigo { get; set; }
        public String area { get; set; }
        public String procedimento { get; set; }
        // INICIO | PLV=2402-30
        public String descricao { get; set; }
        // FIM | PLV=2402-30
        public Integer severidade { get; set; }
        // PLV-4471 
        public String integracao { get; set; }
        public MensagenTO mensagens { get; set; }
        //PLV-4350 INICIO
        public String momentoAnalise { get; set; } 
        //PLV-4350 FIM
        //PLV-4365 INICIO
        public String acao { get; set; } 
        //PLV-4365 FIM
        public String setor { get; set; } //PLV-4790 INICIO/FIM
    }

    public class RecusaTO
    {
        public Integer codigo { get; set; }
        public MensagenTO mensagens { get; set; }
        public String descricao { get; set; }
        public String area { get; set; }
        public String procedimento { get; set; }
        public Integer severidade { get; set; }
    }


    public class AvisoTO
    {
        public Integer codigo { get; set; }
        public String area { get; set; }
        public MensagenTO mensagens { get; set; }
        public String procedimento { get; set; }
         // INICIO | PLV=2402-30
        public String descricao { get; set; }
        // FIM | PLV=2402-30
        public Integer severidade { get; set; }
    }

    public class MensagenTO
    {
        public String interna { get; set; }
        public String cliente { get; set; }
        public String representante { get; set; }
    }
    
    // PLV-3285 - INICIO
    public class RetornoIntegracoesTO {
        public validacaoZeroDolarTO validacaoZeroDolar { get; set; }
        //PLV-3731 - INICIO
        public IndiceMonetarioTO IndiceMonetario {get;set;}//PLV-4666 - INICIO/FIM - PEDRO BRAZ
        //PLV-3731 - FIM
    }
        // PLV-4606 - INICIO
    public class ResultadosIntegracoesTO {
        public DossieTO dossie = new DossieTO();
		public SerasaTO serasa = new SerasaTO();
		public List<CoberturasAcumuladasTO> coberturasAcumuladas = new List<CoberturasAcumuladasTO>();
    }
    public class DadosCadastraisTO {
		public String numeroCpf;
		public String nome;
		public String dataNascimento;
		public String digitoCpf;
	}

	public class ScoreTO {
		public String taxa;
		public ScoresTO scores;
		public String mensagem;
		public String faixa;
	}

	public class RestritivosTO {
		public String cpf_radical;
		public String ind_Recheque;
		public String cpf_digito;
		public String pessoa;
		public String cod_registro;
		public String status_receita;
		public String ind_Concentre;
		public String nome;
		public String origem_informacao;
		public List<DetalhesTO> detalhes;
		public String data_de_atualizacao;
		public String status;
	}

	public class SociedadesTO {
	}

	public class BuscarSociosTO {
		public String cpfCnpjPesquisa;
		public List<SociedadesTO> sociedades;
	}

	public class ScoresTO {
		public Double csba;
		public Double csb08;
		public Double sb01;
	}

	public class DetalhesTO {
		public String status_receita;
		public String data_restricao;
		public String origem;
		public String valor;
		public String cnpj_emp_falida;
		public String nome_praca_restricao;
		public String nome_emp_falida;
		public String ind_anuencia;
		public String cod_restricao_descricao;
		//public Object uf_restricao; //PLV-5066 - INICIO/FIM
		public String cod_restricao;
		public String cpf_radical;
		public String cpf_digito;
		public String cod_registro;
		//public Object cod_emp_restricao; //PLV-5066 - INICIO/FIM
		//public Object cod_praca_restricao; //PLV-5066 - INICIO/FIM
		public String natureza;
		public String origem_informacao;
		public String cnpj_emp_restricao;
		public String data_de_atualizacao;
		public String status;
	}

	public class SerasaTO {
		public DadosCadastraisTO dadosCadastrais = new DadosCadastraisTO();
		public ScoreTO score = new ScoreTO();
		public BuscarSociosTO buscarSocios = new BuscarSociosTO();
		public RestritivosTO restritivos = new RestritivosTO();
	}

    // PLV-4606 - INICIO
    public class SerasaViagemTO {
		public DadosCadastraisTO dadosCadastrais = new DadosCadastraisTO();
		public ScoreViagemTO score = new ScoreViagemTO();
		public BuscarSociosTO buscarSocios = new BuscarSociosTO();
		public RestritivosTO restritivos = new RestritivosTO();
	}

    public class ScoreViagemTO {
		public String taxa;
		public ScoresTO scores;
		public String mensagem;
		public String faixa;
	}
    // PLV-4606 - FIM

	public class CoberturasAcumuladasTO {
		public String sigla;
		public Double valor;
	}

	public class DossieTO {
		public Boolean valido;
		public String mensagem;
	}
    // PLV-4606 - FIM
    public class validacaoZeroDolarTO {
        public Integer codigo { get; set; }
        public String mensagem { get; set; }
        public Integer codigoGateway { get; set; }
        public String mensagemGateway { get; set; }        
    }
    // PLV-3285 - FIM
    
    //PLV-3731 - INICIO
    public class IndiceMonetarioTO{
        public List<ItensCotacaoTO> ItensCotacao {get;set;} //PLV-4666 - INICIO/FIM - PEDRO BRAZ
    }
    
    public class ItensCotacaoTO{
        public String moedaOrigem {get;set;}
        public String moedaDestino {get;set;}
        public String dataCotacao {get;set;}
        public Decimal cotacao {get;set;}
    }
    //PLV-3731 - FIM

    public class RetornoValidacaoProdutoTO {
         public List<RecusaTO> recusas { get; set; }
        
    }
    //PLV2365: INICIO
    public class RetornoCalculoTO {
        public String orcnum { get; set; }
        public Integer opcao { get; set; }
        public PrecificacaoTO precificacao { get; set; }
        //PLV-3317 - INICIO - Ajuste para receber os dados do Sinapse
        public String numeroOrcamento { get; set;}
        public Integer numeroOferta { get; set;}
        // PLV-4666 - INICIO
        public List<String> dlls;
        public String tarifa;
        
        // PLV-4666 - FIM
        //PLV-3317 - FIM
    }
    //PLV2365: FIM
        
    //--> INICIO PLV2312
    public class FilaEventoTO{
        public String origem { get; set; }
        public String codigo { get; set; }
        public String status { get; set; } 
        public String tipoProcessamento { get; set; }
        public Id id { get; set; }
        public FilaEventoTO(){}
        public FilaEventoTO(Id id){
            this.id = id;
        }
    }
    //--> FINAL PLV2312

    //PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
    public class RetornoFinanceiroTO{
        public AutorizacaoCartaoTO autorizacaoCartao { get; set; }
    }
    
    public class AutorizacaoCartaoTO{
        public StargateTO stargate { get; set; }
        public PortoPagTO portoPag { get; set; }
    }
   
    public class StargateTO{
        public Integer codigo { get; set; }
        public String  mensagem { get; set; }
        public Integer codigoGateway { get; set; }
        public String  mensagemGateway { get; set; }
		//PLV-3888: INICIO
		public String codigoAgrupamento { get; set; }
		//PLV-3888: FIM
    }
    //PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
    //TKCL 458 - INICIO
    public class PortoPagTO{
        public String id { get; set; } 
        public String idExterno { get; set; }
        public String estado { get; set; }
        public List<CobrancaTO> cobrancas { get; set; }
        
        public String codigo { get; set; }
        public Integer grupo { get; set; }
        public String mensagem { get; set; }
        public List<ErrosTO> erros { get; set; } //II-48 FIX03 INICIO-FIM
    }

    public class CobrancaTO{
        public String id { get; set; }
        public Decimal valor { get; set; }
        public String estado { get; set; }
        public String meioPagamento { get; set; }
        public String detalhes { get; set; }
        public String idProduto { get; set; }
        public CartaoTO cartao { get; set; }
    }

    public class CartaoTO{
        public String primeirosDigitos { get; set; }
        public String ultimosDigitos { get; set; }
        public String bandeira { get; set; }
    }

    public class ErrosTO{
        public String campo { get; set; }
        public String erro { get; set; }
    }
    //TKCL 458 - FIM

    
}