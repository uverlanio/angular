/****
@description Classe de response para EndossoOrcamentoREST e EndossoAtualizaOrcamentoREST
@author Diego Zampieri - Globant
@date 22/07/2020
-Classe criada por conta da historia PLV-3926    
*****/
public class EndossoOrcamentoResponse{
	
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
		public ContratoTO contratoOriginal					{ get;set; }
		public List<ContratanteTO> contratantes				{ get;set; }
		//PLV-4738 - INICIO
		public Date vigenciaFinal							{ get;set; }
		public Date vigenciaInicial							{ get;set; } 
		public String codigoProdutoVida						{ get;set; }
		public ResultadoIntegracaoTO resultadoIntegracoes	{ get;set; } 
		public List<VersoesCalculoTO> versoesCalculos		{ get;set; } 
		public List<RemuneracoesTO> remuneracoes			{ get;set; }	
		//plv-4738 - fim
		//public String tarifa								{ get;set; }		
	}
	//PLV-5300 - FIM

    public class ContratoTO {
		//PLV-4738 - INCIO
        //public Integer premioTotal{get;set;}
		//public Double premioPago{get;set;}
		public String vigenciaInicial{get;set;}
		public String vigenciaFinal{get;set;}
		public String codigoProdutoVida{get;set;}
		public PrecificacaoTO precificacao{get;set;}
		
		public String numeroOrcamento{get;set;}
		public Integer endosso{get;set;}
        public Integer ramo{get;set;}
        public String apolice{get;set;}
        public Integer sucursal{get;set;}
		public Integer empresa{get;set;}
		public ResultadoIntegracaoTO resultadoIntegracoes{get;set;}
		public List<VersoesCalculoTO> versoesCalculos{get;set;}
		//PLV-4738 - FIM
    }

    public class PrecificacaoTO {
        public Integer juros{get;set;}
		public Double iof{get;set;}
		public Integer encargos{get;set;}
		public Integer custoDeApolice{get;set;}
		public PremioTO premio{get;set;}
		//public TaxaTO taxa{get;set;}
		public List<CoberturasPrecificacaoTO> coberturas{get;set;}
		public List<ContratantesPrecificacaoTO> contratantes{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;} //PLV-4738 - INICIO/FIM
    }

    public class PremioTO {
        public Double comercial{get;set;}
		public Double puro{get;set;}
		public Double total{get;set;}
		public Double premioPago{get;set;} //PLV-4738 - INICIO/FIM
		public Double integral {get;set;} //PLV-5351 INICIO/FIM
    }

    public class TaxaTO {
        public Double comercial{get;set;}
		public Double pura{get;set;}
		public Double total{get;set;}
    }

    public class CoberturasPrecificacaoTO {
        public String sigla{get;set;}
		public Double iof{get;set;} //PLV-4738 - INICIO/FIM
		public PremioTO premio{get;set;}
		public TaxaTO taxa{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;} //PLV-4738 - INICIO/FIM
		public Double capitalContratacao{get;set;} //PLV-4738 - INICIO/FIM
    }

    public class ContratantesPrecificacaoTO {
        public Integer numero{get;set;}
		public Double iof{get;set;} //PLV-4738 - INICIO/FIM
		public PremioTO premio{get;set;}
		//public TaxaTO taxa{get;set;} PLV-4738 - INICIO/FIM
		//public List<CoberturasPrecificacaoTO> coberturas{get;set;} //PLV-4738
		public List<GruposPrecificacaoTO> grupos{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;}//PLV-4738 - INICIO/FIM
    }
	//PLV-4738 - INICIO
    public class GruposPrecificacaoTO {
        public Integer numero{get;set;}
		public Double iof{get;set;} 
		public PremioTO premio{get;set;}
		//public TaxaTO taxa{get;set;} 
		//public List<CoberturasPrecificacaoTO> coberturas{get;set;}
		public List<SeguradosPrecificacaoTO> segurados{get;set;}
		public List<DescontoAgravoTO> descontoAgravo{get;set;} 
	}
	
	
    public class SeguradosPrecificacaoTO {
        public Integer numero{get;set;}
		public Double iof;
		public PremioTO premio{get;set;}
		//public TaxaTO taxa{get;set;}
		public List<CoberturasPrecificacaoTO> coberturas{get;set;}
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
		public String tipoCalculo{get;set;}
		//public Integer tarifa{get;set;} 
		public Integer qtdeVidas{get;set;}
		public List<SeguradoTO> segurados{get;set;}
    }

    public class SeguradoTO {
        public Integer numero{get;set;}
		public List<CoberturaTO> coberturas{get;set;}
		public PessoaTO pessoa {get;set;} 
	}
	
	
	public class PessoaTO{
		public String tipo{get;set;}
		public String nome{get;set;}
		public String redaMensal{get;set;}
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

    public class CoberturaTO {
        public String sigla{get;set;}
		public Double valor{get;set;}
		public String moeda{get;set;}
		public Double cotacaoMoeda{get;set;}
		public String cobrado{get;set;}
		//public Integer quantidade{get;set;} 
    }
	//PLV-4738 - FIM
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

	//PLV-4738 - INICIO
	public class ResultadoIntegracaoTO{
		public IndiceMonetarioTO IndiceMonetario{get;set;} // PLV-4606 - INICIO/FIM
	}

	public class IndiceMonetarioTO{
		public List<ItensCotacaoTO> ItensCotacao{get;set;}
	}

	public class ItensCotacaoTO{
		public String moedaDestino{get;set;}
		public Integer dataCotacao{get;set;}
		public String moedaOrigem{get;set;}
		public String cotacao{get;set;}
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

	public class DescontoAgravoTO{
		public Double percentual{get;set;}
		public Double monetario{get;set;}
		public String tipo{get;set;}
	}
	//PLV-4738 -FIM

}