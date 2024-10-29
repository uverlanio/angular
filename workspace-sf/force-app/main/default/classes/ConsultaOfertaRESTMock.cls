/**
 * Consulta Oferta REST
 * @author IF - Globant @ 30/12/2019
 * @modified IF - Globant @ 30/12/2019
 *
 **/
//PLV-3223 - INÍCIO
global class ConsultaOfertaRESTMock {
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HttpResponse();
        
        String jsonRetorno = '{' +
           '"data":{' + 
              '"retornosConsulta":[' +
                 '{' + 
                    '"status":"Disponível para contratação",' +
                    '"numero":"00005900",' +
                    '"nomeproduto":"Seguro de Pessoas Individual Sniper",' +
                    '"nome":"CO2-00005900"' +
                 '}' +
              ']' +
           '},' +
           '"meta":{' + 
              '"dataExecucao":"2019-12-30T18:54:40.362Z",' +
              '"mensagem":"OK",' +
              '"servico":"ConsultaOferta",' +
              '"statusHttp":200' +
           '}' +
        '}';
        
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonRetorno);
        res.setStatusCode(200);
        
        return res;
    }
}
//PLV-3223 - FIM