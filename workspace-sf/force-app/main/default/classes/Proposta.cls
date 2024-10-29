/**************************************************************************************************************************************************************************
 * 
 *  Classe estrutural de proposta
 *
 **************************************************************************************************************************************************************************/

public without sharing class Proposta
{
	public PropostaWrapper propostaWrapper {get; set;}
	public Proposta(){
		this.propostaWrapper = new PropostaWrapper();
	}

	public class PropostaWrapper 
	{
		public Quote sfProposta {get; set;}

		public List<ContratanteWrapper> contratantesWrapper {get; set;}
		public List<RemuneracaoPropostaWrapper> remuneracaoPropostaWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		// INICIO | PLV-2402-30
		public List<CriticaPropostaWrapper> criticasWrapper { get; set; }
		// FIM | PLV-2402-30
		public List<CriticaProposta__c> criticas { get; set; }
		public RetornoWrapper retornoWrapper { get; set; }
	
		public PropostaWrapper()
		{
			this.sfProposta = new Quote();
			this.garantiasWrapper = new List<GarantiaWrapper>();
			this.contratantesWrapper = new List<Proposta.ContratanteWrapper>();
			this.remuneracaoPropostaWrapper = new List<Proposta.RemuneracaoPropostaWrapper>();
			// INICIO | PLV-2402-30
			this.criticasWrapper = new List<Proposta.CriticaPropostaWrapper>();
			// FIM | PLV-2402-30
			this.criticas = new List<CriticaProposta__c>();
			this.retornoWrapper = new RetornoWrapper();
		}
	}
	// 2666 - INICIO
	public class ContratanteWrapper 
	{
		public ContratanteProposta__c sfContratante {get; set;}
		public PessoaWrapper pessoaWrapper {get; set;}
		public InformacaoBancaria__c sfInformacaoBancaria {get; set;}
		public CartaoCredito__c sfCartaoCredito {get; set;}
		public List<GrupoWrapper> gruposWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		public String chave { get; set; }

		public ContratanteWrapper()
		{
			this.sfContratante = new ContratanteProposta__c();
			this.pessoaWrapper = new PessoaWrapper();
			this.sfInformacaoBancaria = new InformacaoBancaria__c();
			this.sfCartaoCredito = new CartaoCredito__c();
			this.garantiasWrapper = new List<GarantiaWrapper>();
			this.gruposWrapper = new List<Proposta.GrupoWrapper>();
		}
	}
	// 2666 - FIM

	public class GrupoWrapper 
	{
		public GrupoProposta__c sfGrupo {get; set;}
		public List<SeguradoWrapper> seguradosWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		public String chave { get; set; }

		public GrupoWrapper()
		{
			this.sfGrupo = new GrupoProposta__c();
			this.garantiasWrapper = new List<GarantiaWrapper>();
			this.seguradosWrapper = new List<Proposta.SeguradoWrapper>();
		}
	}

	public class SeguradoWrapper 
	{
		public SeguradoProposta__c sfSegurado {get; set;}
		public PessoaWrapper pessoaWrapper {get; set;}
		public List<GarantiaWrapper> garantiasWrapper { get; set; }
		public List<BeneficiariosWrapper> beneficiariosWrapper {get; set;}
		public String chave { get; set; }

		public SeguradoWrapper()
		{
			this.sfSegurado = new SeguradoProposta__c();
			this.pessoaWrapper = new PessoaWrapper();
			this.garantiasWrapper = new List<GarantiaWrapper>();
			this.beneficiariosWrapper = new List<Proposta.BeneficiariosWrapper>();
		}
	}

	public class PessoaWrapper
	{
		public Account sfConta {get; set;}
		public List<Endereco__c> enderecos {get; set;}

		public PessoaWrapper()
		{
			this.sfConta = new Account();
			this.enderecos = new List<Endereco__c>();
		}
	}

	public class RemuneracaoPropostaWrapper
	{
		public RemuneracaoProposta__c sfRemuneracaoProposta { get; set; }
		public List<FavorecidoRemuneracaoWrapper> favorecidosRemuneracaoWrapper { get; set; }
		public String chave { get; set; }

		public RemuneracaoPropostaWrapper(){
			this.sfRemuneracaoProposta = new RemuneracaoProposta__c();
			this.favorecidosRemuneracaoWrapper = new List<Proposta.FavorecidoRemuneracaoWrapper>();
		}
	}

	public class FavorecidoRemuneracaoWrapper
	{
		public FavorecidoRemuneracaoProposta__c sfFavorecidoRemuneracaoProposta { get; set; }
		public PessoaWrapper pessoaWrapper {get; set;}

		public FavorecidoRemuneracaoWrapper(){
			this.sfFavorecidoRemuneracaoProposta = new FavorecidoRemuneracaoProposta__c();
			this.pessoaWrapper = new PessoaWrapper();
		}

	}

	public class retornoWrapper{

		public String numeroApolice {get; set;}
		public String codigoEmpresa {get; set;}
		public String codigoSucursal {get; set;}
		public String codigoRamo {get; set;}
		public String tipoEndosso {get; set;}
		public String numeroOrcamento {get; set;}
        public String cupomDesconto {get; set;} // AV-664 INICIO/FIM
		public RetornoPropostaRestTO.ValidacaopropostaTO retorno  { get; set; }
		//PLV_3196 - INICIO - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
		public String modalidade {get; set;}
		//PLV_3196 - FIM - Alteração do Serviço "Gravar Proposta" para retornar Ramo e Modalidade da Proposta
		//PLV-3763 - INICIO - Converter serviço de Devolutivas da Proposta em lista
		public Integer indice { get; set; }
		public String LinkVoucher { get; set; }
		//PLV-3763 - FIM - Converter serviço de Devolutivas da Proposta em lista
		public String  validadePagamento  {get; set;} // VIAG-141 INICIO-FIM
		public String  senha { get; set; } // MGRC-505 INICIO-FIM
		public String  distributionPublicUrl { get; set; } // MGRC-505 INICIO-FIM
		



		public retornoWrapper (){
			this.retorno = new RetornoPropostaRestTO.ValidacaopropostaTO();
			this.retorno.devolutivas = new List<RetornoPropostaRestTO.DevolutivasTO>();	
		}
	}

	public class BeneficiariosWrapper{
		public BeneficiarioSeguradoProposta__c sfBeneficiarioSeguradoProposta { get; set; }
	}

	public class GarantiaWrapper{

		public String sigla { get; set; }
		public GarantiaProposta__c sfGarantiaProposta { get; set; }
		public GarantiaContratanteProposta__c sfGarantiaContratanteProposta { get; set; }
		public GarantiasGrupoProposta__c sfGarantiaGrupoProposta { get; set; }
		public GarantiaSeguradoProposta__c sfGarantiaSeguradoProposta { get; set; }

	}

	// INICIO | PLV-2402-30
	public class CriticaPropostaWrapper{
		public CriticaProposta__c sfCriticaProposta { get; set; }
	}
	// FIN | PLV-2302-30
	
}