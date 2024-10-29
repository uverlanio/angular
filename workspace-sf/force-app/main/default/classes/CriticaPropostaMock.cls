/****
@description Classe de mock para classe CriticaPropostaTest
@author Isabela Fin - Globant
@date 21/10/2020
@Classe referente a historia PLV-4449      
*****/
@isTest
global class CriticaPropostaMock {
    global class LiberacaoSucesso implements HttpCalloutMock {
        protected String numeroReferecia;
        global LiberacaoSucesso(String numeroReferecia) {
            this.numeroReferecia = numeroReferecia;
        }
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String strResp = '{"sucesso":true,"mensagem":"OK"}';
            res.setHeader('Content-Type','application/json');
            res.setBody(strResp);
            res.setStatusCode(200);
            return res;
        }
    }
}