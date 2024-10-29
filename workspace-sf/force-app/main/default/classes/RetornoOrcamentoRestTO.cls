public with sharing class RetornoOrcamentoRestTO 
{
	public class ValidacaoOrcamentoTO 
	{
		public List<DevolutivasTO> devolutivas { get; set; }
		public OrcamentoTO orcamento { get; set; }
		public List<OfertasTO> ofertas { get; set; }
	}

	public class OfertasTO 
	{
		public String retornoCalculo { get; set; }
		public String retornoIntegracoes { get; set; }
		public String retornoValidacaoProduto { get; set; }
		public OrcamentoTO orcamento { get; set; }
		public String retornoAceitacao { get; set; }
	
	}

	public class DevolutivasTO 
	{
		public Integer codigo { get; set; }
		public String origem { get; set; }
		public Integer tipoRegistro { get; set; }
		public Integer numeroCampo { get; set; }
		public String descricao { get; set; }
	}

	public class OrcamentoTO
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
        public String codigoCupom { get; set; }  // AV-644
	}
}