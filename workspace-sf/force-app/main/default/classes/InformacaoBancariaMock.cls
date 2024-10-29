@isTest
global class InformacaoBancariaMock implements HttpCalloutMock {

	global HttpResponse respond(HTTPRequest req) {

		HttpResponse res = new HttpResponse();

		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"MsgRetornoSOAP":{"Header":{"tipoConsulta":2},'+
			+'"Parceiro":{"Parceiros":{"nome1":"AEC CORR","nome2":"SEGUROS",'+
			+'"DadosBancarios":""}},'+
			+'"Mensagem":{"codigoRetorno":2,"mensagem":"Não existe dados bancários inválidos para a chave externa 341300521244323232332332 para o parceiro de negócios 188509160"},'+
			+'"Trailer":{"qntdRegistros":1}}}');
		res.setStatusCode(200);

		return res;
	}

	global HttpResponse respond2(HTTPRequest req) {

		HttpResponse res = new HttpResponse();

		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"RG_ENR": "","LOGR_COMPLEMENTO1_ENR": "AP 262","FONE1_ENR": "00000000",'+
    		+'"BAIRRO3_ENR": "ITACORUBI","LOGR_NUMERO2_ENR": "197","CEL3_ENR": "00000000",'+
    		+'"CEL2_ENR": "0000000000","DDD3_ENR": "41","ORGAO_EMISSOR_ENR": "","BAIRRO1_ENR": "JARDIM",'+
    		+'"DDD1_ENR": "18","status": "nao atualizado","NOME_MAE_ENR": "NOME DA MAE",'+
    		+'"CEP2_ENR": "123456","SEXO_ENR": "M","CEP1_ENR": "09080500","UF3_ENR": "SC","LOGR_TIPO2_ENR": "R",'+
    		+'"ENDERECO3_ENR": "R","DDDCEL3_ENR": "18","data_de_atualizacao": "2019-03-18 12:39:12",'+
    		+'"LOGR_TIPO1_ENR": "AV","FONE2_ENR": "00000000","status_receita": "ativo","DDDCEL1_ENR": "48",'+
    		+'"LOGR_TIPO3_ENR": "R","LOGR_TITULO1_ENR": "","CIDADE1_ENR": "SANTO ANDRE","LOGR_COMPLEMENTO2_ENR": "",'+
    		+'"LOGR_TITULO2_ENR": "","NASCIMENTO_ENR": "1987-02-26","CPF_DIGITO": "00","UF2_ENR": "SP",'+
    		+'"CIDADE2_ENR": "ASSIS","LOGR_NOME2_ENR": "CAMPOS SALES","LOGR_TITULO3_ENR": "","ENDERECO2_ENR": "R",'+
    		+'"CEL1_ENR": "00000000","origem_informacao": "interna","FONE3_ENR": "00000000","DDDCEL2_ENR": "18",'+
    		+'"DDD2_ENR": "18","UF_EMISSAO_ENR": "","NOME_ENR": "NOME DO NOME","LOGR_COMPLEMENTO3_ENR": "",'+
    		+'"CPF_RADICAL": "00000000","LOGR_NUMERO3_ENR": "280","CIDADE3_ENR": "FLORIANOPOLIS",'+
    		+'"LOGR_NOME1_ENR": "INDUSTRIAL","BAIRRO2_ENR": "VL OPERARIA","LOGR_NUMERO1_ENR": "750","UF1_ENR": "SP",'+
    		+'"ENDERECO1_ENR": "AV","CEP3_ENR": "00000000","LOGR_NOME3_ENR": "NOME LOGR"}');
		res.setStatusCode(200);

		return res;
	}

}