public class FormularioSniperTO {
    
		public Consultivo consultivo;

	public class Consultivo {
		public String codigoOfertaConsultiva;
		public String canalDistribuicao;
		public String susepCorretor;
		public String meioComercializacao;
		public List<Conjuntos> conjuntos;
	}

	public class Conjuntos {
		public Integer id;
		public String titulo;
		public String subtitulo;
		public List<Informacoes> informacoes;
		public List<RegrasSequencia> regrasSequencia;
	}

	public class Informacoes {
		public String id;
		public String nome;
		public String descricao;
		public String tipo;
		public Boolean obrigatorio;
		public List<Opcoes> opcoes;
		public String servico;
	}

	public class Opcoes {
		public String codigo;
		public String rotulo;
	}

	public class RegrasSequencia {
		public Integer sequencia;
		public Integer proximoConjunto;
	}
	
	public static FormularioSniperTO parse(String json) {
		return (FormularioSniperTO) System.JSON.deserialize(json, FormularioSniperTO.class);
	}
    
}