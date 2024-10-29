//PLV-3854 INICIO

public class JsonCIVConsultaMoeda {

	public ItensCotacao ItensCotacao;

	public class ItensCotacao {
		public ItemCotacao ItemCotacao;		
	} 

	public class ItemCotacao {
		public String moedaOrigem;
		public String moedaDestino;
        //PLV 3854 - fix
		public String dataCotacao;
        //PLV 3854 - fix
		public String cotacao;
	}
	
	public static JsonCIVConsultaMoeda parse(String json) {
		return (JsonCIVConsultaMoeda) System.JSON.deserialize(json, JsonCIVConsultaMoeda.class);
	}

}
//PLV-3854 FIM