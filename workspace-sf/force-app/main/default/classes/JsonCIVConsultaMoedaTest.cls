//PLV-3854 INICIO

@IsTest
public class JsonCIVConsultaMoedaTest {
	
	static testMethod void testParse() {
		String json = '{\"ItensCotacao\":{\"ItemCotacao\":{\"moedaOrigem\":\"USD\",\"moedaDestino\":\"BRL\",\"dataCotacao\":22052020,\"cotacao\":\"5.60130000\"}}}';
		JsonCIVConsultaMoeda obj = JsonCIVConsultaMoeda.parse(json);
		System.assert(obj != null);
	}
}
//PLV-3854 FIM