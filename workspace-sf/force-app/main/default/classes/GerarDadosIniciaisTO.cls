/*********************************************************************************************************************************************************************
@description  TO criada para geração de dados iniciais no processo de contratação
@author Isabela Fin - Avanxo
@date 10/01/2020
@Classe criada por conta da história PLV-2146      
**********************************************************************************************************************************************************************/
public class GerarDadosIniciaisTO {
    public List<VersaoCalculoTO> versoesCalculo {get; set; }
    public VersaoCalculoTO versaoCalculo {get; set; }
    public class RetornoTO {
    	public List<OfertaTO> ofertas { get; set; }
    }
    public class PayloadTO {
    	public List<OrcamentoTO> orcamentos { get; set; }
    }
	public class OrcamentoTO {
		public String meioComercializacao { get; set; }
        public String codigoProdutoVida { get; set; }
        public String idProdutoSf { get; set; } // PLV-5331 INICIO / FIM
        public Date dataCalculo { get; set; }
        public Integer ordemPortal { get; set; } //PLV-2146 FIX - INICIO/FIM
		//PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
        public String canalDistribuicao {get; set;}
        public ContratoOriginalEntradaTO contratoOriginal { get; set; }
        public String tipoSeguro {get;set;}
        //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B
        public String Cupom {get;set;} //PLV-5461 INICIO/FIM
        //RVI-160 - INICIO
		public Date vigenciaInicial { get; set; }
		public Date vigenciaFinal { get; set; }
        //RVI-160 - FIM
        public List<ContratanteTO> contratantes {get;set;}//PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B
	    // PLV-4655 - INICIO
        public Double premioPago {get; set;}
        public String numeroOferta {get;set;}
        // PLV-4655 - INICIO
        public string dataEndosso {get;set;} //INICIO/FIM - PLV-4686 - Guilherme Brito
        public String cicloVacinal { get; set; } // PLV-5150 - FIX02 - INICIO/FIM
        public String idContratoRenovado { get; set; } // RVI-193-INICIO/FIM
    }

    //PLV-2146 FIX - INICIO/FIM - Codigo removido por conta da historia PLV-2146
    public class OfertaTO {
        public OrcamentoRetornoTO orcamento { get; set; }
        public RegraTO regra {get; set; }
        public MoedasCotacaoTO moedasCotacao { get; set; } //PLV-3729 - INICIO/FIM - Índice monetário
        public PrecificacaoTO precificacao { get; set; } //PLV-4168 - V.I - INICIO/FIM
    }
    public class OrcamentoRetornoTO {
        public String numeroOrcamento { get; set; }
        public String numeroOferta { get; set; } //PLV-3317 - INÍCIO/FIM
        public Integer ordemPortal { get; set; } //PLV-2146 FIX - INÍCIO/FIM
        public String ramoSeguro { get; set; } //PLV-4498 Início/Fim
        //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
        public ContratoOriginalRetornoTO contratoOriginal { get; set; } // PLV-4655
        public String canalDistribuicao {get; set;}
        public String dataEndosso {get;set;}
		//PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B

		//PLV-4403 INICIO
        public Date vigenciaInicial { get; set; }
		public Date vigenciaFinal { get; set; }
		public Integer qtdDiasVigencia { get; set; }
		//PLV-4403 FIM
        public List<ContratanteTO> contratantes {get;set;} // PLV-4655
        public EndossoTO tiposEndosso {get;set;} //5066 INICIO/FIM
    }
    //PLV-5066 INICIO
    public class EndossoTO{
        public Boolean cad;
    }
    //PLV-5066 FIM
    public class RegraTO {
        public List<VersaoCalculoTO> versoesCalculo { get; set; }
    }
    public class VersaoCalculoTO {
        public Decimal descontoAgravo { get; set; }
        public String tipo { get; set; }
        public Integer opcao { get; set; }
        public List<ContratanteContrato__c> ListDescontoAgravo { get; set; } // RVI- 225
    }

    //PLV-3729 - INICIO - Índice monetário
    public class MoedasCotacaoTO{
        public Date dataInicio { get; set; }
        public Date dataCalculo { get; set; }
        public Set<String> moedasGarantias { get; set; }        
    }    
    //PLV-3729 - FIM - Índice monetário

    //PLV-4168 - V.I - INICIO
    public class PrecificacaoTO{
        public PremioTO               premio         { get; set; }
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
        public List<CoberturaTO>     coberturas     { get; set; }
        public Decimal iof { get; set; }
        public Decimal juros  {get; set; }
        public Decimal encargos { get; set; }
        public Decimal custoDeApolice { get; set; }
        public List<ContratanteTO> contratantes { get; set; } //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B - Alterado para Lista
        //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
        //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B

		// PLV-4655 - REMOVIDO / IOF / JUROS / CUSTOAPOLICE / ENCARGOS / TAXA
        //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B

    }

    public class PremioTO{
        public decimal minimo { get; set; }

        //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
        //PLV - 4655 - VI - INICIO - GFUSTAVO PEREIRA SYS4B
        public Decimal comercial { get; set; }
        public Decimal integral { get; set; } //PLV-5351 INICIO/FIM 
        public Decimal total { get; set; }
        public Decimal puro { get; set; }
        public Decimal premioPago {get;set;}
        //PLV - 4655 - VI - FIM - GFUSTAVO PEREIRA SYS4B
        //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B
        // TKCL-584 INICIO
        public Decimal puroCarregado {get; set;}
        public List<DescontoAgravoTO> descontoAgravo {get; set;}
        // TKCL-584 INICIO
    }

    public class DescontoAgravoTO{
        public decimal percentual { get; set; }
        public decimal monetario  { get; set; }
        public String  tipo       { get; set; }
    }
    //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    /*public class CoberturasTO{
        public String sigla { get; set; }
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
    }*/
    //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B
    //PLV-4168 - V.I - FIM
    
    //PLV - 4487 - VI - INICIO - Gustavo Pereira SYS4B
    public class ContratoOriginalEntradaTO{
       
        public String sucursal {get;set;}
        public String ramo {get;set;}
        public String endosso {get;set;}
        public String empresa {get;set;}
        public String apolice {get;set;}
        public Double premioPago {get;set;} // PLV-4655

    }
	// PLV-4655 - INICIO  Alterado BLOCO intero até linha 338
    public class ContratoOriginalRetornoTO{

        //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B
        public String sucursal {get;set;}
        public String ramo {get;set;}
        //RVI-229 INICIO
        public String tipoSeguro {get;set;}
        public Date dataCalculo {get;set;}
        //RVI-229 FIM
        public String endosso {get;set;}
        public String empresa {get;set;}
        public String apolice {get;set;}
        //PLV - 4626 - VI - FIM - GUSTAVO PEREIRA SYS4B
        public String tarifa {get;set;} // PLV-4666

        public String vigenciaFinal {get;set;}
        public String codigoProdutoVida {get;set;}
        //public Double premioTotal {get;set;}
        public String vigenciaInicial {get;set;}
        public String vigenciaInicialOriginal {get;set;} //FNPVVEP-21 INICIO/FIM

        public PrecificacaoContratoOriginalTO precificacao {get;set;}
        public List<ContratanteTO> contratantes {get;set;} //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B - Alterado para Lista
        public Integer numeroOrcamento { get; set; }

        public List<RemuneracaoContratoTO> remuneracoes {get;set;} //PLV-4715 INICIO/FIM
        //public Double premioPago {get; set;}
        // TKCL-584 INICIO
       // public String cicloVacinal {get;set;} 
        public Integer qtdDiasVigencia { get; set; }
        // II-25 INICIO
        // public DadosPessoaFisicaTO dadosPessoaFisica {get;set;} 
        public List<Segurado_NovoTO> segurados {get; set;} 
        public List<BeneficiarioTO> beneficiarios {get;set;}
        public DadosPagamentoTO dadosPagamento {get;set;} 
        // II-25 FIM
        public List<CoberturaTO> coberturas {get;set;}
        public List<VersaoCalculoTO> versoesCalculos {get;set;}
        public List<RetornosCalculoOriginalTO> retornosCalculoOriginal {get;set;}
         // TKCL-584 FIM
    }


    //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
    public class PrecificacaoContratoOriginalTO{

        public Decimal iof { get; set; }
        public Decimal juros  {get; set; }
        public Decimal encargos { get; set; }
        public Decimal custoDeApolice { get; set; }
        public PremioTO  premio { get; set; }
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        public List<CoberturaTO> coberturas { get; set; }
        public List<ContratanteTO> contratantes { get; set; } //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B - Alterado para Lista

    }

    // TKCL-584 INICIO
    public class RetornosCalculoOriginalTO {
        public String tarifa {get;set;}
        public List<String> dlls {get;set;}
        public Integer opcao {get;set;}
        public PrecificacaoTO precificacao;
    }
    // TKCL-584 FIM

    /*public class PremioPrecificacaoTO{

        public Decimal comercial { get; set; }
        public Decimal puro { get; set; }
        public Decimal total { get; set; }
        public Decimal premioPago {get;set;}
    }
    public class OutroPremioPrecificacaoTO{

        public Decimal comercial { get; set; }
        public Decimal puro { get; set; }
        public Decimal total { get; set; }

    }

    public class CoberturasPrecificacaoTO{
                
        public String sigla {get;set;}   
        public Decimal capitalContratacao {get;set;}
        public Decimal iof {get;set;}
        public OutroPremioPrecificacaoTO premio {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }

    }
    public class ContratantesPreicifacaoTO{

        public Integer numero {get;set;}
        public Double iof {get;set;}
        public OutroPremioPrecificacaoTO premio {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        public List<GrupoPrecificacaoTO> grupos {get;set;}

    }

    public class GrupoPrecificacaoTO{

        public Integer numero {get;set;}
        public Double iof {get;set;}
        public OutroPremioPrecificacaoTO premio {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        public List<SeguradoPrecificacaoTO> segurados {get;set;}

    }
    public class SeguradoPrecificacaoTO{

        public Integer numero {get;set;}
        public Double iof {get;set;}
        public OutroPremioPrecificacaoTO premio {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        public List<CoberturaPrecificacaoSeguradoTO> coberturas {get;set;}

    }
    public class CoberturaPrecificacaoSeguradoTO{ 
        
        public String sigla {get;set;}
        public Decimal capitalContratacao {get;set;}
        public Decimal iof {get;set;}
        public OutroPremioPrecificacaoTO premio {get;set;}
        public TaxaTO taxa {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }

    }

    public class CoberturaPrecificacaoTO{ 
        
        public String sigla {get;set;}
        public Decimal capitalContratacao {get;set;}
        public Decimal iof {get;set;}
        public OutroPremioPrecificacaoTO premio {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
    }*/
    //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

    public class ContratanteTO{
        
        public String tipo {get;set;}
        public Integer numero {get;set;} //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B - Alterado para string
        //public Dobule iof {get;set;}
        //ublic TaxaTO taxa {get;set;}
        //public PremioTO premio {get;set;}
        //PLV - 4655 - VI - REMOVIDO CONTA INICIO/FIM - GFUSTAVO PEREIRA SYS4B
        //public List<DescontoAgravoTO> descontoAgravo { get; set; }
        public List<GrupoTO> grupos {get;set;}
        public DadosPagamentoTO dadosPagamento {get;set;}
        public PessoaTO pessoa {get;set;} // PLV-4715 INICO/FIM
        //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - INICIO
        public Double iof {get;set;}
        public PremioTO premio {get;set;}
        public TaxaTO taxa {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - INICIO
    }
    public class GrupoTO {

        public Integer numero {get;set;} //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B - Alterado para string
        public String nome {get;set;}
        public Double qtdeVidas {get;set;} //PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B - Alterado para double
        public List<SeguradoTO> segurados {get;set;}
        //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - INICIO
        public Double iof {get;set;}
        public PremioTO premio {get;set;}
        public TaxaTO taxa {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - INICIO
    }
    public class SeguradoTO {

        public Integer numero {get;set;}
        public PessoaTO pessoa {get; set;}//PLV - 4626 - VI - INICIO/FIM - GUSTAVO PEREIRA SYS4B
        public List<CoberturaTO> coberturas {get;set;}
        public List<BeneficiarioTO> beneficiarios {get;set;}// PLV 4715 INICIO/FIM
        //PLV-4666 - INICIO - PEDRO AUGUSTO BRAZ - INICIO
        public Double iof {get;set;}
        public PremioTO premio {get;set;}
        public TaxaTO taxa {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
        //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - INICIO
    }

    // II-25 INICIO
    public class Segurado_NovoTO {
        public String nome {get;set;} 
        public String nomeSocial {get;set;} // LECVPV-188 INICIO/FIM 
        public String rendaMensal {get;set;} 
        public String email {get;set;}
        public String pessoaExpostaPoliticamente {get;set;} 
        public DadosPessoaFisicaTO dadosPessoaFisica {get;set;}
        public List<EmissaoTO.EnderecoTO> enderecos {get;set;}
        public List<EmissaoTO.TelefoneTO> telefones {get;set;} 
        public List<BeneficiarioTO> beneficiarios {get;set;}
    }

    // II-25 FIM

    //PLV - 4626 - VI - INICIO - GUSTAVO PEREIRA SYS4B
    public class PessoaTO{

        public String tipo {get;set;}
        public String nome {get;set;}
        public String nomeSocial {get;set;} // LECVPV-188 INICIO/FIM
        public DadosPessoaFisicaTO dadosPessoaFisica {get; set;}
        public Decimal rendaMensal {get;set;}//PLV-4655 fix 1 - INICIO //PLV-4715 INICIO/FIM
        
        //PLV-4715 INICIO
        public String melhorPeriodo {get; set;}
        public String pessoaExpostaPoliticamente {get; set;}
        public String email {get; set;}
        public List<EmissaoTO.EnderecoTO> enderecos {get; set;}
        public List<EmissaoTO.TelefoneTO> telefones {get; set;}

        public PessoaTO(){}
        public PessoaTO(ContratanteContrato__c contratante){
            this.tipo = contratante.Tipo__c != null ? contratante.Tipo__c : '';
            this.nome= contratante.NomeContratante__c != null ? contratante.NomeContratante__c : ''; //PLV-4813 INICIO/FIM 
            this.nomeSocial= contratante.NomeSocial_do_Contratante__c != null ? contratante.NomeSocial_do_Contratante__c : ''; //LECVPV-188 INICIO/FIM 
            this.dadosPessoaFisica = new DadosPessoaFisicaTO();
            this.dadosPessoaFisica.fumante = null;

            
            if(contratante.CpfCnpj__c != null && contratante.CpfCnpj__c != ''){
                String docContratante = contratante.CpfCnpj__c.replace('.','').replace('-', '');
                this.dadosPessoaFisica.numeroCpf = docContratante.substring(0, docContratante.length() - 2);
                this.dadosPessoaFisica.digitoCpf = docContratante.replace('.','').replace('-', '').right(2);
            }else{
                System.debug('contratante do contrato não possui CPF cadastrado');
                this.dadosPessoaFisica.numeroCpf = '';
                this.dadosPessoaFisica.digitoCpf =  '';
            }
        }
        //PLV-4715 FIM
    }
    public class DadosPessoaFisicaTO{

        public String profissao {get;set;}
        public String grupoProfissao {get; set;}
        public String sexo {get;set;}
        public Boolean fumante { get; set; }
        //PLV-4715 INICIO
        public String dataNascimento {get;set;}
        public String regimeTrabalho {get;set;}
        public String paisResidente {get; set;}
        public Boolean resideBrasil { get; set; }
        public String numeroCpf {get; set;}
        public String digitoCpf {get; set;}
        public String estadoCivil {get; set;}
        public String orgaoExpedidor {get; set;}
        public String docIdentificacao {get; set;}
        public String tipoDocIdentificacao {get; set;}
        public String nacionalidade {get; set;}
        public String paisDeOrigem {get; set;} //PLV-5231 INICIO/FIM 
        public Date dataExpedicao {get; set;}
        //public String CicloVacinalEnd { get; set; } // PLV-5150 - FIX01 - INICIO/FIM - FIX02

        // TKCL-584 INICIO
        public DadosPessoaFisicaTO(){  

        }
        // TKCL-584 FIM 
         // flag de construtor, caso queiramos inicializar os Dados PF com fumante igual a false.
        public DadosPessoaFisicaTO(Boolean fumantefalse){ // TKCL-584 INICIO/FIM
            fumante = false; 
        }
        //PLV-4715 FIM

    }

    //PLV-4666 - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
    public class CoberturaTO{
        public String sigla {get;set;}
        public Double valor {get;set;}
        public Decimal quantidade {get;set;}
        public String unidade {get;set;} //TKCL-584 INICIO/FIM
        public String franquia {get;set;}
        public TaxaTO taxa {get;set;}
        public PremioTO premio {get;set;}
        public Decimal capitalContratacao {get;set;}
        public Decimal iof {get;set;}
        public List<DescontoAgravoTO> descontoAgravo { get; set; }
    }
    //PLV-4666 - FIM - PEDRO AUGUSTO BRAZ - SYS4B

    public class TaxaTO {
        //PLV - 4655 - VI - INICIO - GFUSTAVO PEREIRA SYS4B
        public Decimal pura { get; set; }
        public Decimal comercial { get; set; }
        public Decimal total { get; set; }
        //PLV - 4655 - VI - FIM - GFUSTAVO PEREIRA SYS4B

    }    
    //PLV - 4487 - VI - FIM - Gustavo Pereira SYS4B

    public class RemuneracaoContratoTO{
        public Decimal percentual {get;set;}
        public String tipoRemuneracao {get;set;}
        public List<FavorecidosTO> favorecidos {get;set;}
    }

    public class FavorecidosTO{
        public String papel {get;set;}
        public Double participacao {get;set;}
        public Boolean corretorLider {get;set;}
        public String susep {get;set;}
        public Boolean antecipacaoComissao {get;set;}
        public PessoaTO pessoa {get;set;}
    }

    public class DadosPessoaJuridicaTO{
        public String numeroCnpj {get;set;}
        public String ordemCnpj {get;set;}
        public String digitoCnpj {get;set;}
    }
	
	//PLV4715 - INICIO
	 public class DadosPagamentoTO{
        public String tipoResponsavelPagamento { get; set; }
        public String diasPagamento { get; set; }
        public String codigo { get; set; }
        public String descricao { get; set; }
        public Date vencimentoPrimeiraParcela { get; set; }
        public String idPlanoParcelamento { get; set; }
        public Integer codigoFormaPagamento { get; set; }
        public Integer quantidadeParcelas { get; set; }
        public String vencimentoDemaisParcelas { get; set; }
        public Date vigenciaInicial { get; set; }
        public String codigoMeioRecebimento { get; set; }

        // PLV-5066 INICIO
        public EmissaoTO.FormaPagamentoTO formaPagamento { get; set; }
        public Boolean responsavelFinanceiro { get; set;}
        public EmissaoTO.PessoaTO responsavelFinanceiroSeguro { get; set;}
        public EmissaoTO.DadosBancarioTO dadosBancarios { get; set;}
        public EmissaoTO.dadosCartaoCreditoTO dadosCartaoCredito { get; set;}
        // PLV-5066 FIM


        public DadosPagamentoTO(){}

        public DadosPagamentoTO(ContratanteContrato__c contratanteOriginal){
            this.codigo = contratanteOriginal.FormaPagamento__r.Codigo__c != null ? contratanteOriginal.FormaPagamento__r.Codigo__c : '';
            this.diasPagamento = contratanteOriginal.DiasPagamento__c != null ? contratanteOriginal.DiasPagamento__c + '' : null;
            this.descricao = contratanteOriginal.FormaPagamento__r.Name != null ? contratanteOriginal.FormaPagamento__r.Name : '';
            this.tipoResponsavelPagamento = contratanteOriginal.TipoResponsavelPagamento__c != null ? contratanteOriginal.TipoResponsavelPagamento__c : '';
            this.vencimentoPrimeiraParcela = contratanteOriginal.VencimentoPrimeiraParcela__c;
            this.idPlanoParcelamento = contratanteOriginal.PlanoParcelamento__c  != null ? contratanteOriginal.PlanoParcelamento__c  + '' : null;
            this.vigenciaInicial = contratanteOriginal.VigenciaInicial__c;
            this.vencimentoDemaisParcelas = contratanteOriginal.VencimentoDemaisParcelas__c != null ? contratanteOriginal.VencimentoDemaisParcelas__c : '';
            this.codigoMeioRecebimento = contratanteOriginal.PlanoParcelamento__r.CodigoMeioRecebimento__c != null ? contratanteOriginal.PlanoParcelamento__r.CodigoMeioRecebimento__c : '';
            
            this.codigoFormaPagamento = 
                contratanteOriginal.FormaPagamento__r != null && 
                contratanteOriginal.FormaPagamento__r.Codigo__c != null ? Integer.valueOf(contratanteOriginal.FormaPagamento__r.Codigo__c) : null;
            this.quantidadeParcelas = Integer.valueOf(contratanteOriginal.QuantidadeParcelas__c);

            // PLV-5066 INICIO
            this.formaPagamento = new EmissaoTO.FormaPagamentoTO();
            this.formaPagamento.codigo = this.codigoFormaPagamento + '';
            this.formaPagamento.descricao = '';
            this.formaPagamento.idFormaPagamento = contratanteOriginal.FormaPagamento__c;

            this.formaPagamento.planoParcelamento = new EmissaoTO.PlanoParcelamentoTO(); 
            this.formaPagamento.planoParcelamento.quantidadeParcelas = Integer.valueOf(contratanteOriginal.QuantidadeParcelas__c);
            this.formaPagamento.planoParcelamento.idPlanoParcelamento = '1';
            // this.formaPagamento.planoParcelamento.codigoMeioRecebimento = contratanteOriginal.PlanoParcelamento__r.CodigoMeioRecebimento__c;

            this.responsavelFinanceiro = contratanteOriginal.Conta__c == contratanteOriginal.ResponsavelPagamento__c;
            if(!this.responsavelFinanceiro){
                this.responsavelFinanceiroSeguro = new EmissaoTO.PessoaTO();

                this.responsavelFinanceiroSeguro.nome = contratanteOriginal.ResponsavelPagamento__r.name;
                this.responsavelFinanceiroSeguro.vinculoComSegurado = '';
                this.responsavelFinanceiroSeguro.email = contratanteOriginal.ResponsavelPagamento__r.Email__c;
                
                this.responsavelFinanceiroSeguro.dadosPessoaFisica = new EmissaoTO.DadosPessoaFisicaTO();
                this.responsavelFinanceiroSeguro.dadosPessoaFisica.numeroCpf = Util.getNumCPF(contratanteOriginal.ResponsavelPagamento__r.Cpf__c);
                this.responsavelFinanceiroSeguro.dadosPessoaFisica.digitoCpf = Util.getDigitoCPF(contratanteOriginal.ResponsavelPagamento__r.Cpf__c);

                this.responsavelFinanceiroSeguro.telefones = new List<EmissaoTO.TelefoneTO>();
                if(contratanteOriginal.ResponsavelPagamento__r.PersonHomePhone != null){
                    EmissaoTO.TelefoneTO phone = new EmissaoTO.TelefoneTO();
                    phone.tipoTelefone = 'RES';
                    phone.numeroTelefone = Util.getPhoneDDD(contratanteOriginal.ResponsavelPagamento__r.PersonHomePhone);
                    phone.dddTelefone = Util.getPhoneNumber(contratanteOriginal.ResponsavelPagamento__r.PersonHomePhone);

                    this.responsavelFinanceiroSeguro.telefones.add(phone);
                }
                if(contratanteOriginal.ResponsavelPagamento__r.PersonMobilePhone != null){
                    EmissaoTO.TelefoneTO phone = new EmissaoTO.TelefoneTO();
                    phone.tipoTelefone = 'CEL';
                    phone.numeroTelefone = Util.getPhoneDDD(contratanteOriginal.ResponsavelPagamento__r.PersonMobilePhone);
                    phone.dddTelefone = Util.getPhoneNumber(contratanteOriginal.ResponsavelPagamento__r.PersonMobilePhone);

                    this.responsavelFinanceiroSeguro.telefones.add(phone);
                }
                if(contratanteOriginal.ResponsavelPagamento__r.Phone != null){
                    EmissaoTO.TelefoneTO phone = new EmissaoTO.TelefoneTO();
                    phone.tipoTelefone = 'COM';
                    phone.numeroTelefone = Util.getPhoneDDD(contratanteOriginal.ResponsavelPagamento__r.Phone);
                    phone.dddTelefone = Util.getPhoneNumber(contratanteOriginal.ResponsavelPagamento__r.Phone);

                    this.responsavelFinanceiroSeguro.telefones.add(phone);
                }

                this.responsavelFinanceiroSeguro.enderecos = new List<EmissaoTO.EnderecoTO>();

                List<Endereco__c> lstEndereco = [
                    SELECT 
                        Bairro__c, CEP__c, Cidade__c, 
                        Complemento__c, Estado__c, Logradouro__c,
                        Numero__c, Pais__c, TipoEndereco__c
                    FROM Endereco__c
                    WHERE 
                        Conta__c =: contratanteOriginal.ResponsavelPagamento__c
                        AND MaisAtual__c = true
                ];

                for(Endereco__c edr : lstEndereco){
                    EmissaoTO.EnderecoTO endereco = new EmissaoTO.EnderecoTO();

                    endereco.bairro = edr.Bairro__c;
                    endereco.cep = Util.getNumCep(edr.CEP__c);
                    endereco.cidade = edr.Cidade__c;
                    endereco.complemento = edr.Complemento__c;
                    endereco.complementoCep = Util.getDigitoCep(edr.CEP__c);
                    endereco.logradouro = edr.Logradouro__c;
                    endereco.numeroLogradouro = edr.Numero__c;
                    endereco.tipoEndereco = edr.TipoEndereco__c;
                    endereco.uf = edr.Estado__c;

                    this.responsavelFinanceiroSeguro.enderecos.add(endereco);
                }
            }

            if(contratanteOriginal.InformacaoBancaria__c != null ){
                this.dadosBancarios = new EmissaoTO.DadosBancarioTO();

                //II-150 - INICIO
                String agencia = contratanteOriginal.InformacaoBancaria__r.Agencia__c;
                if(!agencia.contains('-')){
                    contratanteOriginal.InformacaoBancaria__r.Agencia__c = agencia + '-0';
                }
                //II-150 - FIM
                
                this.dadosBancarios.agencia = contratanteOriginal.InformacaoBancaria__r.Agencia__c.split('-')[0];
                this.dadosBancarios.digitoAgencia = contratanteOriginal.InformacaoBancaria__r.Agencia__c.split('-')[1];
                this.dadosBancarios.banco = contratanteOriginal.InformacaoBancaria__r.Banco__c;
                this.dadosBancarios.conta = contratanteOriginal.InformacaoBancaria__r.NumeroConta__c;
                this.dadosBancarios.digitoConta = contratanteOriginal.InformacaoBancaria__r.Digito__c;
                this.dadosBancarios.tipoPessoa = contratanteOriginal.InformacaoBancaria__r.TipoPessoa__c;
                this.dadosBancarios.cpf = Util.getNumCPF(contratanteOriginal.CpfCnpj__c) + Util.getDigitoCPF(contratanteOriginal.CpfCnpj__c);
            }

            if(contratanteOriginal.CartaoCredito__c != null ){
                this.dadosCartaoCredito = new EmissaoTO.dadosCartaoCreditoTO();

                this.dadosCartaoCredito.numero = null;
                //PLV-5187 - INICIO
                this.dadosCartaoCredito.validade = contratanteOriginal.CartaoCredito__r.Vencimento__c == null ? null : contratanteOriginal.CartaoCredito__r.Vencimento__c;
                this.dadosCartaoCredito.bandeira = contratanteOriginal.CartaoCredito__r.Bandeira__c == null ? null : contratanteOriginal.CartaoCredito__r.Bandeira__c.toLowerCase();  
                this.dadosCartaoCredito.cartaoPorto = contratanteOriginal.CartaoCredito__r.CartoPortoSeguro__c == null ? null : contratanteOriginal.CartaoCredito__r.CartoPortoSeguro__c;
                this.dadosCartaoCredito.nome = contratanteOriginal.CartaoCredito__r.NomeTitular__c == null ? null : contratanteOriginal.CartaoCredito__r.NomeTitular__c;
                this.dadosCartaoCredito.ticket = contratanteOriginal.CartaoCredito__r.Ticket__c == null ? null : contratanteOriginal.CartaoCredito__r.Ticket__c;
                //PLV-5187 - FIM
            }

            // PLV-5066 FIM
            
        }
    }
    
	public class BeneficiarioTO{
        public String tipoBeneficiario { get; set; }
        public Double participacao { get; set; }
        public String grauParentesco { get; set; }
        public String grauParentescoOutros { get; set; } // PLV-5231 INICIO/FIM
        public PessoaTO pessoa { get;set; }
        public String motivoSemCpfCnpj { get; set; }
        public Date nascimento {get;set;}
        public Decimal percentualIndenizacao {get;set;}
        public String nome {get;set;}
        public String nomeSocial {get;set;} // LECVPV-188 INICIO/FIM
        public String cpf  { get;set;}
        public String sexoBeneficiario {get;set;}
        public Boolean imprimirCertificado {get;set;}

        public BeneficiarioTO(){}

        public BeneficiarioTO(BeneficiarioSeguradoContrato__c beneficiarioOriginal){
            this.nome = beneficiarioOriginal.Nome__c;
            this.nomeSocial = beneficiarioOriginal.NomeSocial__c; // LECVPV-188 INICIO/FIM
            this.tipoBeneficiario = beneficiarioOriginal.TipoBeneficiario__c;
            this.participacao = beneficiarioOriginal.Participacao__c;
            this.grauParentesco = beneficiarioOriginal.GrauParentesco__c;
            this.grauParentescoOutros = beneficiarioOriginal.BeneficiarioGrauParentescoOutros__c; // PLV-5231 INICIO/FIM
            this.motivoSemCpfCnpj = beneficiarioOriginal.MotivoSemCpfCnpj__c;
            
            this.nascimento = beneficiarioOriginal.Data_de_Nascimento__c;

            this.percentualIndenizacao = beneficiarioOriginal.PercentualIndenizacao__c;
            this.cpf = beneficiarioOriginal.CpfCnpj__c;
            this.sexoBeneficiario = beneficiarioOriginal.Sexo__c;
            this.imprimirCertificado = beneficiarioOriginal.ImprimirCertificadoSeguro__c;
        }
    }
	//PLV4715 - FIM
}