//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class ParcelamentoWrapper {
	//VIAG-241 INICIO KAYMON
	public Integer opcao {get;set;} 
	public Integer qtdParcelas {get;set;} 
	public String valorPrimeiraParcela {get;set;} 
	public String valorDemaisParcelas {get;set;} 

	public ParcelamentoWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'opcao') {
						opcao = parser.getIntegerValue();
					} else if (text == 'qtdParcelas') {
						qtdParcelas = parser.getIntegerValue();
					} else if (text == 'valorPrimeiraParcela') {
						valorPrimeiraParcela = parser.getText();
					} else if (text == 'valorDemaisParcelas') {
						valorDemaisParcelas = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'ParcelamentoWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<ParcelamentoWrapper> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfParcelamentoWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

    private static List<ParcelamentoWrapper> arrayOfParcelamentoWrapper(System.JSONParser p) {
        List<ParcelamentoWrapper> res = new List<ParcelamentoWrapper>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ParcelamentoWrapper(p));
        }
        return res;
    }
	//VIAG-241 FIM KAYMON
}