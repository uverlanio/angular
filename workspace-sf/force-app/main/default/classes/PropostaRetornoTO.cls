public class PropostaRetornoTO
{
	public class PayloadTO 
	{
		public PropostaTO proposta { get; set; }
	}

	public class PropostaTO 
	{
		public Integer empcod { get; set; }
		public Integer prporg { get; set; }
		public string prpnumdig { get; set; }
		public Integer codope { get; set; }
		public string emsdat { get; set; }
		public string ramcod { get; set; }
		public Integer subcod { get; set; }
		public string rmemdlcod { get; set; }
		public string succod { get; set; }
		public string aplnumdig { get; set; }
		public string edsnumdig { get; set; }
		public string viginc { get; set; }
		public string vignfl { get; set; }
		public string pgtfrm { get; set; }
		public Decimal prmliqvlr { get; set; }
		public Decimal adcfrcvlr { get; set; }
		public Decimal prmbruvlr { get; set; }
		public Integer parqtd { get; set; }
		public Integer prpstt { get; set; }
		public Decimal rmecmlniv { get; set; }
		public String basclcdat { get; set; }
		public string segnom { get; set; }
		public string segsclnom { get; set; }  //LECVPV-177 - INICIO/FIM
		public string corsus { get; set; }
		//PLV 4736 Inicio
		//public string dscemsesp { get; set; }
		//PLV 4736 Fim
		public Integer Status { get; set; }
		public string Mensagem { get; set; }
		public string edsnumref { get; set; }
		public string aplemsdat { get; set; }
		public string prmmda { get; set; }
		public Integer comtaxcod { get; set; }
		public string comflgngc { get; set; }
		public Decimal ciaperptc { get; set; }
		public Integer parnum { get; set; }
		public Integer notcmpflg { get; set; }
        //PLV-4464 - INICIO
		public string codigoPessoaBCP { get; set; }
		//PLV-4464 - FIM
	}
}