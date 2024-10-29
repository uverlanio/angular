public class OpcoesServicoTO {

    public String id;
	public String servico;
	public String body; //PLV-4324 - Inicio/Fim
	public String metodo; //PLV-4324 - Inicio/Fim
	
	public static List<OpcoesServicoTO> parse(String json) {
		return (List<OpcoesServicoTO>) System.JSON.deserialize(json, List<OpcoesServicoTO>.class);
	}
    
}