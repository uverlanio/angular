/**
 * Product Service TO 
 * @author Fernando Barcellos @ 26/06/2018
 *
 **/
public class ProductServiceTO {

	public class RetornoConsultaProdutoTO {
		public transient Map<Id, ProdutoTO> mapProdutoTO { get; set; }
		public List<ProdutoTO> produtos { get; set; }
		public String mensagem { get; set; }
		public Integer erro { get; set; }

		public RetornoConsultaProdutoTO(){
			this.produtos = new List<ProdutoTO>();
			this.mapProdutoTO = new Map<Id, ProdutoTO>();
			this.erro = 0;
		}
	}

	public class ProdutoTO {
		public Integer codigoProduto { get; set; }
		public String descricao { get; set; }
		public List<FormaPagamentoTO> formasPagamento { get; set; }
		public List<DocumentoTO> documentos { get; set; }

		public ProdutoTO(){
			this.formasPagamento = new List<FormaPagamentoTO>();
			this.documentos = new List<DocumentoTO>();
		}
	}

	public class FormaPagamentoTO {
		public String ramoSeguro { get; set; }
		public Integer modalidade { get; set; }
		public String descricao { get; set; }
		public String codigo { get; set; }
		public List<ParcelaTO> parcelas { get; set; }

		public FormaPagamentoTO(){
			this.parcelas = new List<ParcelaTO>();
		}
	}

	public class ParcelaTO {
		public Decimal numeroParcela { get; set; }
		public String meioRecebimento { get; set; }
	}

	public class DocumentoTO {
		public String nomeDocumento { get; set; }
		public Boolean documentoObrigatorio { get; set; }
	}
}