//PLV-4148 - INICIO
@IsTest
public class RetornoSAPTest {
	static testMethod void testParse() {
		String json = '{'+
		'   \"retornofornecedor\":{'+
		'      \"nroDocCPFCNPJFornecedor\":\"27351731000138\",'+
		'      \"mensagens\":['+
		'         {'+
		'  \"codigoRetorno\":\"003\",'+
		'  \"mensagemRetorno\":\"Fornecedor 8567002 atualizado\"'+
		'}'+
		'      ]'+
		'   },'+
		'   \"retornoop\":{'+
		'      \"numeroDocumento\":\"RP-0135\",'+
		'      \"numeroDocumentoOrdemPag\":\"10037311043\",'+
		'      \"mensagens\":['+
		'         {'+
		'  \"codigoRetorno\":\"000\",'+
		'  \"mensagemErro\":\"\"'+
		'}'+
		'      ]'+
		'   }'+
		'}';
		RetornoSAP obj = RetornoSAP.parse(json);
		System.assert(obj != null);
	}
}
//PLV-4148 - FIM