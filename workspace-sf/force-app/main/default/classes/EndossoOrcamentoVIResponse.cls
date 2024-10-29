/****
@description Classe de response para EndossoOrcamentoREST
@author Jeferson santana
@date 30/12/2020
-Classe criada por conta da historia PLV-4695    
*****/
public with sharing class EndossoOrcamentoVIResponse{
    public class DataTO{
		public List<OfertaTO> ofertas { get; set; }
	}

	public class OfertaTO{
		public OrcamentoTO orcamento { get; set; }
		
	}
	//PLV-5300 - INICIO
    public class OrcamentoTO{
        public String orcnum								{ get;set; }
		public String numeroOrcamento						{ get;set; }
		public String numeroOferta							{ get;set; }
		public String tipoSeguro							{ get;set; }
		public String dataCalculo							{ get;set; }
		public String motivoCancelamento					{ get;set; }
		public ContratoGenericoTO contratoOriginal		    { get;set; } // TKCL-601 INICIO/FIM
		public List<ContratanteTO> contratantes				{ get;set; }
		public String segmento								{ get;set; }
		public String tipoVigencia							{ get;set; }
		public Date vigenciaFinal							{ get;set; }
		public Date vigenciaInicial							{ get;set; }
		public Integer qtdDiasVigencia                      { get;set; } //PLV-5833 INICIO/FIM
		public String numeroPortal							{ get;set; }
		public Date dataEndosso								{ get;set; }
		public Integer ordemPortal							{ get;set; }
		public Integer entradaNegocio						{ get;set; }
		public String canalDistribuicao						{ get;set; }
		public String meioComercializacao					{ get;set; }
		public String codigoProdutoVida						{ get;set; }
		public ResultadoIntegracaoTO resultadoIntegracoes	{ get;set; } 
		public List<VersoesCalculoTO> versoesCalculos		{ get;set; } 
		public List<RemuneracoesTO> remuneracoes			{ get;set; }			
	}	

	 // TKCL-601 INICIO
	public abstract class ContratoGenericoTO {

	}
	 // TKCL-601 FIM

    public class ContratoTO extends ContratoGenericoTO {        
		public String vigenciaInicial						{ get;set; }
		public String vigenciaFinal							{ get;set; }
		public String vigenciaInicialOriginal				{ get;set; } //FNPVVEP-121 INICIO/FIM
		public String codigoProdutoVida						{ get;set; }
        public String idProdutoSf                           { get;set; } // PLV-5331 INICIO / FIM
		public String numeroOrcamento						{ get;set; } 
        public Integer endosso								{ get;set; }
        public Integer ramo									{ get;set; }
        public String apolice								{ get;set; }
        public Integer sucursal								{ get;set; }
        public Integer empresa								{ get;set; }
		public PrecificacaoTO precificacao					{ get;set; }
		public ResultadoIntegracaoTO resultadoIntegracoes	{ get;set; }
		public List<ContratanteTO> contratantes				{ get;set; }
		public String tarifa								{ get;set; }
		public Integer qtdDiasVigencia 						{ get;set; } // TKCL-601 INICIO/FIM
    }
	//PLV-5300 - FIM

	  public class ContratoTO_APTLMK extends ContratoGenericoTO {       // TKCL-601 INICIO/FIM  
		public String vigenciaInicial						{ get;set; }
		public String vigenciaFinal							{ get;set; }
		public String codigoProdutoVida						{ get;set; }
        public String idProdutoSf                           { get;set; } // PLV-5331 INICIO / FIM
		public Integer numeroOrcamento						{ get;set; } // TKCL-601 INICIO/FIM
        public Integer endosso								{ get;set; }
        public Integer ramo									{ get;set; }
        public String apolice								{ get;set; }
        public Integer sucursal								{ get;set; }
        public Integer empresa								{ get;set; }
		public PrecificacaoTO precificacao					{ get;set; }
		public ResultadoIntegracaoTO resultadoIntegracoes	{ get;set; }
		public List<ContratanteTO> contratantes				{ get;set; }
		public String tarifa								{ get;set; }
		public Date dataCalculo 							{ get;set; } // TKCL-601 INICIO/FIM	
		public String tipoSeguro 							{ get;set; } // TKCL-601 INICIO/FIM
		public Integer qtdDiasVigencia 						{ get;set; } // TKCL-601 INICIO/FIM
		public DadosPessoaTO dadosPessoaFisica 				{ get;set; } // TKCL-601 INICIO/FIM
		public List<CoberturaTO> coberturas 				{ get;set; } // TKCL-601 INICIO/FIM
		public List<RemuneracoesTO> remuneracoes            { get;set; } // TKCL-601 INICIO/FIM
		public List<VersoesCalculoTO> versoesCalculos		{ get;set; } // TKCL-601 INICIO/FIM
		public List<RetornosCalculoOriginalTO> retornosCalculoOriginal { get;set; } // TKCL-601 INICIO/FIM 
    }

    public class PrecificacaoTO {
        public Integer juros{get;set;}
		public Double iof{get;set;}
		public Integer encargos{get;set;}
		public Integer custoDeApolice{get;set;}
		public PremioTO premio{get;set;}
		//public TaxaTO taxa{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;}
		public List<CoberturasPrecificacaoTO> coberturas{get;set;}
		public List<ContratantesPrecificacaoTO> contratantes{get;set;}
    }

	public class DescontoAgravoTO{
		public Double percentual{get;set;}
		public Double monetario{get;set;}
		public String tipo{get;set;}
	}

    public class PremioTO {
		//public Double integral {get;set;} //PLV-5351 INICIO/FIM //PLV-5384 INICIO/FIM
        public Double comercial {get;set;}
		public Double puro {get;set;}
		public Double total {get;set;}
		public Double premioPago {get;set;}
		public Double puroCarregado {get; set;} //TKCL-601 INICIO/FIM
		public List<DescontoAgravoTO> descontoAgravo {get;set;} //TKCL-601 INICIO/FIM
    }

    public class TaxaTO {
        public Double comercial{get;set;}
		public Double pura{get;set;}
		public Double total{get;set;}
    }

    public class CoberturasPrecificacaoTO {
        public String sigla{get;set;}
		public Double iof{get;set;}
		public PremioTO premio{get;set;}
		public TaxaTO taxa{get;set;} // TKCL-601 INICIO/FIM
		public List<DescontoAgravoTO> descontoAgravo{get;set;}
	}
	
	public class CoberturasPrecificacaoGrupoTO {
        public String sigla{get;set;}
		public Double iof{get;set;}
		public PremioTO premio{get;set;}
		public TaxaTO taxa{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;}
		public Double capitalContratacao{get;set;}
		
    }

    public class ContratantesPrecificacaoTO {
        public Integer numero{get;set;}
		public Double iof{get;set;}
		public PremioTO premio{get;set;}
		//public TaxaTO taxa{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;}
		public List<CoberturasPrecificacaoTO> coberturas{get;set;}
		public List<GruposPrecificacaoTO> grupos{get;set;}
    }

    public class GruposPrecificacaoTO {
        public Integer numero{get;set;}
		public Double iof{get;set;}
		public PremioTO premio{get;set;}
		//public TaxaTO taxa{get;set;}
		public List<CoberturasPrecificacaoTO> coberturas{get;set;}
		public List<SeguradosPrecificacaoTO> segurados{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;}
    }

    public class SeguradosPrecificacaoTO {
        public Integer numero{get;set;}
		public Double iof{get;set;}
		public PremioTO premio{get;set;}
		//public TaxaTO taxa;
		public List<CoberturasPrecificacaoGrupoTO> coberturas{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;}
    }

    public class ContratanteTO {
        public String tipo{get;set;}
		public Integer numero{get;set;}
		public List<GrupoTO> grupos{get;set;}
    }

    public class GrupoTO {
        public Integer numero{get;set;}
		public String nome{get;set;}
		//public String tipoCalculo;
		//public Integer tarifa;
		public Integer qtdeVidas{get;set;}
		public List<SeguradoTO> segurados{get;set;}
    }

    public class SeguradoTO {
        public Integer numero{get;set;}
		public List<CoberturaTO> coberturas{get;set;}
		public PessoaTO pessoa {get;set;}
    }

    public class CoberturaTO {
        public String sigla{get;set;}
		public Double valor{get;set;}
		public String moeda{get;set;}
		//public Double cotacaoMoeda;
		//public String cobrado;
		public String franquia{get;set;}
		public Decimal quantidade{get;set;}  // TKCL-601 INICIO/FIM
		public String unidade{get;set;} // TKCL-601 INICIO/FIM
    }

	public class ValidacaoOrcamentoTO 
	{
		public List<DevolutivasTO> devolutivas { get; set; }
		public List<OfertasTO> ofertas { get; set; }
	}

	public class OfertasTO 
	{
		public OrcamentoAtualizadoTO orcamento { get; set; }
	
	}

	public class DevolutivasTO 
	{
		public Integer codigo { get; set; }
		public String origem { get; set; }
		public Integer tipoRegistro { get; set; }
		public Integer numeroCampo { get; set; }
		public String descricao { get; set; }
	}

	public class OrcamentoAtualizadoTO
	{
		public String status { get; set; }
		public Integer apolice { get; set; }
		public Integer ramo { get; set; }
		public String tipoSeguro { get; set; }
		public String tipoAdesao { get; set; }
		public String vigenciaFinal { get; set; }
		public Integer empresa { get; set; }
		public String dataCalculo { get; set; }
		public Integer sucursal { get; set; }
		public String vigenciaInicial { get; set; }
		public Integer numeroOrcamento { get; set; }
		public String meioComercializacao { get; set; }
		public Integer qtdDiasVigencia { get; set; }
	}

	
		public class ResultadoIntegracaoTO{
			
		}
		public class VersoesCalculoTO{
			public Integer opcao{get;set;}
			public String tipo{get;set;}
			public Double descontoAgravo{get;set;}
		}


		public class RemuneracoesTO{
			public Double percentual{get;set;}
			public String tipoRemuneracao{get;set;}
		}

		public class PessoaTO{
			public String tipo{get;set;}
			public String nome{get;set;}
			public String nomeSocial {get;set;} //LECVPV-188 INICIO/FIM
			public DadosPessoaTO dadosPessoaFisica{get;set;} 
		}

		public class DadosPessoaTO{
			public String profissao{get;set;}
			public String grupoProfissao{get;set;}
			public String sexo{get;set;}
			public Boolean fumante{get;set;}
			public Date dataNascimento{get;set;}
			public String regimeTrabalho{get;set;}
		}

		// TKCL-601 INICIO
		public class RetornosCalculoOriginalTO {
			public String tarifa {get;set;}
			public List<String> dlls {get;set;}
			public Integer opcao {get;set;}
			public PremioTO premio {get;set;}
			public PrecificacaoTO precificacao {get;set;}
		}
		// TKCL-601 FIM
	
}