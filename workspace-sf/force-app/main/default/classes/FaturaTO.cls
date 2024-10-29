/**
 * Fatura TO
 *
 **/
public class FaturaTO {

//	public class PayloadTO {
//		public List<FaturaTO> Faturas { get; set; }
//	}

	public class DadosFaturaTO
	{
		public Integer idlote {get;set;}
		public Integer idarquivo {get;set;}
		public Id conta { get; set; }
		public Integer origemproposta { get; set; }
		public String status { get; set; }
		public String codigosproduto  { get; set; }
		public String codigoparceiro { get; set; }
		public String numerocontratoparceiro {get;set;}
		public String empresa { get; set; }
		public String sucursal { get; set; }
		public String ramo { get; set; }
		public String apolice { get; set; }
		public String endosso { get; set; }
		public String tipofatura { get; set; }
		public Integer numeroproposta { get; set; }
		public Date iniciocompetencia { get; set; }
		public Date competencia { get; set; }
		public Date finalcompetencia { get; set; }
		public Date datavencimento { get; set; }
		public Date dataemissao { get; set; }
		public Decimal valorliquido { get; set; }
		public Decimal valoriof { get; set; }
		public Decimal valortotal { get; set; }
		public String idproduto { get; set; }//VEP-939
	}
    
	// PLV-2192-27-INICIO - TOs de atualizaão de parcela
	public class AtualizarParcelaTO{
		public String numeroFatura { get; set; }
		public String dataPagamento  { get; set; }

	}
	// PLV-2192-27-FIM

}