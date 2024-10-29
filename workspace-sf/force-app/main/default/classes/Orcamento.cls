/**************************************************************************************************************************************************************************
 * 
 *  Classe estrutural de Orcamento
 *
 **************************************************************************************************************************************************************************/
public class Orcamento {
	public OrcamentoWrapper orcamentoWrapper {get; set;}
	
	public Orcamento(){
		this.orcamentoWrapper = new OrcamentoWrapper();
	}

	public class OrcamentoWrapper {

		public Opportunity sfOrcamento {get; set;}
		public List<ContratanteWrapper> contratantesWrapper {get; set;}
		public List<RemuneracaoOrcamentoWrapper> RemuneracaoOrcamentoWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		public List<CriticaOrcamento__c> criticas { get; set; }
		public RetornoWrapper retornoWrapper { get; set; }

		public OrcamentoWrapper(){
			this.sfOrcamento = new Opportunity();
			this.garantiasWrapper = new List<GarantiaWrapper>();
			this.contratantesWrapper = new List<Orcamento.ContratanteWrapper>();
			this.RemuneracaoOrcamentoWrapper = new List<Orcamento.RemuneracaoOrcamentoWrapper>();
			this.criticas = new List<CriticaOrcamento__c>();
			this.retornoWrapper = new RetornoWrapper();
		}
	}

	public class ContratanteWrapper {
		public ContratanteOrcamento__c sfContratante {get; set;}
		public PessoaWrapper pessoaWrapper {get; set;}
		public List<GrupoWrapper> gruposWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		public String chave { get; set;}

		public ContratanteWrapper(){
			this.sfContratante = new ContratanteOrcamento__c();
			this.pessoaWrapper = new PessoaWrapper();
			this.garantiasWrapper = new List<GarantiaWrapper>();
			this.gruposWrapper = new List<Orcamento.GrupoWrapper>();
		}
	}

	public class GrupoWrapper {
		public GrupoOrcamento__c sfGrupo {get; set;}
		public List<SeguradoWrapper> seguradosWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		public String chave { get; set;}

		public GrupoWrapper(){
			this.sfGrupo = new GrupoOrcamento__c();
			this.garantiasWrapper = new List<GarantiaWrapper>();
			this.seguradosWrapper = new List<Orcamento.SeguradoWrapper>();
		}
	}

	public class SeguradoWrapper {
		public SeguradoOrcamento__c sfSegurado {get; set;}
		public PessoaWrapper pessoaWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		public String chave { get; set;}

		public SeguradoWrapper(){
			this.sfSegurado = new SeguradoOrcamento__c();
			this.pessoaWrapper = new PessoaWrapper();
			this.garantiasWrapper = new List<GarantiaWrapper>();
		}
	}

	public class PessoaWrapper {
		public Account sfConta {get; set;}
		public List<Endereco__c> enderecos {get; set;}

		public PessoaWrapper(){
			this.sfConta = new Account();
			this.enderecos = new List<Endereco__c>();
		}
	}

	public class retornoWrapper{

		public String numeroApolice {get; set;}
		public String codigoEmpresa {get; set;}
		public String codigoSucursal {get; set;}
		public String codigoRamo {get; set;}
		public String tipoEndosso {get; set;}
		public RetornoOrcamentoRestTO.ValidacaoOrcamentoTO retorno  { get; set; }

		public retornoWrapper (){
			this.retorno = new RetornoOrcamentoRestTO.ValidacaoOrcamentoTO();
			this.retorno.devolutivas = new List<RetornoOrcamentoRestTO.DevolutivasTO>();
		}

	}

	public class RemuneracaoOrcamentoWrapper
	{
		public RemuneracaoOrcamento__c sfRemuneracaoOrcamento { get; set; }

		public String chave { get; set; }

		public RemuneracaoOrcamentoWrapper(){
			this.sfRemuneracaoOrcamento = new RemuneracaoOrcamento__c();
		}
	}

	public class GarantiaWrapper{

		public String sigla { get; set; }
		public GarantiaOrcamento__c sfGarantiaOrcamento { get; set; }
		public GarantiaContratanteOrcamento__c sfGarantiasContratanteOrcamento { get; set; }
		public GarantiaGrupoOrcamento__c sfGarantiaGrupoOrcamento { get; set; }
		public GarantiaSeguradoOrcamento__c sfGarantiaSeguradoOrcamento { get; set; }

	}

}