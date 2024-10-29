/****************************************************************************************************************************
 * Classe  de estrutura de dados implementada para o serviço de consulta de contratos para parceiros                        *
 * @author : Globant                                                                                                        *
 * @date 21/08/2023                                                                                                         *
 * Classe implementada tendo como origem a história VIAG-17                                                                 *
 * **************************************************************************************************************************/

public class RetornoAilusTO {
    //VIAG-17 FIX-02 INICIO
    public class PayloadTO 
	{
		public List<InformacoespropostaTO> propostas { get; set; }
	}

    public class InformacoespropostaTO 
    {
        public String Status  { get; set; }
        public String Origem  { get; set; }
        public String MeioComercializacao  { get; set; }
        public String Numero { get; set; }
        public String FormaDePagamento  { get; set; }
        public String PremioLiquido  { get; set; }
        public String ValorIoF { get; set; }
        public String PremioTotal  { get; set; }
        public String NumeroParcelas  { get; set; }
        public InformacoesContratoTO Contrato  { get; set; } 
        public InformacoesRemuneracaoTO Remuneracao  { get; set; }
        public InformacoesContratanteTO Contratante  { get; set; }
        public InformacoesProdutoTO Produto  { get; set; }
    }

    public class InformacoesContratoTO
    {
        public String NumeroApolice  { get; set; }
        public String Tipo  { get; set; }
        public String VigenciaInicial  { get; set; }
        public String VigenciaFinal  { get; set; }
        public String DataEmissao  { get; set; }
        public String CodigoSucursal  { get; set; }
        public String CodigoRamo  { get; set; }
        public String NumeroEndosso  { get; set; }
        public String Status  { get; set; }
    }

    public class InformacoesRemuneracaoTO
    {
        public InformacoesRemuneracaoDetalhesTO Corretagem  { get; set; }
        public InformacoesRemuneracaoDetalhesTO Agenciamento  { get; set; }
    }

    public class InformacoesRemuneracaoDetalhesTO
    {
        public List<InformacoesFavorecidoRemuneracaoDetalhesTO> Favorecidos  { get; set; }
        public String Percentual  { get; set; }
    }

    public class InformacoesFavorecidoRemuneracaoDetalhesTO
    {
        public String Nome  { get; set; }
        public String CorretorLider { get; set; }
        public String Participacao { get; set; }
        public String CodigoCorretor  { get; set; }
    }

    public class InformacoesContratanteTO
    {
        public String Nome  { get; set; }
        public String NumeroDocumento  { get; set; }
        public String TipoPessoa { get; set; }
    }
    public class InformacoesProdutoTO
    {
        public String Nome  { get; set; }
        public String Segmento { get; set; }
    }
    //VIAG-17 FIX-02 FIM
    //VIAG-17 FIX-01 INICIO
    public class RequestTO 
    {
        public string susep  { get; set; }
        public string dataInicio { get; set; }
        public string dataFim { get; set; }
    }
    //VIAG-17 FIX-01 FIM
}