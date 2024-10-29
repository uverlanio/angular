/**
 * GarantiaContratoTO
 *
 **/
public class GarantiaContratoTO {

	//---- Json para consulta PortoCAP

	public class DadosPortoCap {
  		public String Nr_cnpj { get; set; }						
  		public String Cd_promocao { get; set; }		
  		public Integer cd_versao { get; set; }
	}


	//--- Json de retorno da consulta PortoCAP

	public class RetornoConsultaTitulosTO {
		public List<PropostasTO> Propostas { get; set; }
	}

	public class PropostasTO {
		public String nm_pessoa  { get; set; }
		public Long nr_cnpjcpf { get; set; }
		public String Cd_promocao { get; set; }
		public Integer cd_versao { get; set; }
		public String nr_serie { get; set; }
		public String nr_proposta { get; set; }
		public String dt_emissao { get; set; }
		public String dt_inicio_vigencia { get; set; }
		public DadosTitulos DadosTitulos;
		public String nm_retorno { get; set; }
	}

	public class DadosTitulos {
		public List<Titulos> Titulos;
	}


	public class Titulos {
		public String cd_cessionario { get; set; }
		public String nm_cessionario { get; set; }
		public Integer nr_cpfcnpj_cessionario { get; set; }
		public Integer Nr_titulo { get; set; }
		public Integer nr_Lote { get; set; }
		public Double vr_desconto { get; set; }
		public Double Vr_valor { get; set; }
		public String nr_sorte { get; set; }
		public String nm_status { get; set; }
		public Date dt_sorteio { get; set; }
	}

	public class GarantiasTO {
		public String contrato { get; set; }
		public String contratanteContrato { get; set; }
		public String grupoContrato{ get; set; }
		public String seguradoContrato{ get; set; }
		public String tipoCapitalProduto { get; set; }
		public String tipoGarantia { get; set; }
		public Double capital { get; set; }
		public String moedaGarantia{ get; set; }
		public String demonstracaoPremio{ get; set; }
		public Double limiteUso { get; set; }
		public Double iof { get; set; }
	}
	
}