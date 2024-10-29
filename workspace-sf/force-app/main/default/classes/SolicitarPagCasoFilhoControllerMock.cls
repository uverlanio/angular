@isTest
global class SolicitarPagCasoFilhoControllerMock implements HttpCalloutMock {

	global HttpResponse respond(HttpRequest req){

		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('[{"idconta": "0011F000009D3eOQAS", "cnpjcpf": null, "tipoconta": null,'+
        '"valorpagamento": "2000.00000", "status": "PENDENTE", "datapagamento": "2019-01-24T00:00:00.000Z",'+
        '"dataprogramadapagamento": "2019-01-25T00:00:00.000Z","tipopagamento": "SINISTRO",'+
        '"idobjeto": "5003F000004yoRmQAI","matricula": null,"codigoexcecao": null,"descricaoexcecao": null,'+
        '"valorbruto": null,"tributacao": null,"tiporemuneracao": null,"datacancelamento": null,'+
        '"motivo": "pagou atrasado","descricao": null,"susepcorretor": null,'+
        '"dataatualizacao": "2019-01-31T00:00:00.000Z"}]');

		res.setStatusCode(200);
		return res;
	}

    
    global HttpResponse respond2(HttpRequest reqDel){

		HttpResponse resDel = new HttpResponse();
		resDel.setHeader('Content-Type', 'application/json');
		resDel.setBody('[{"id": "456"}]');

		resDel.setStatusCode(200);
		return resDel;
	}
    
    
}