/**
 * Consultivo REST
 * @author Fábio Rente / Everymind @ 03/06/2019
 *
 **/
@RestResource(urlMapping='/consultivo/mock/*')
global with sharing class ConsultivoRest extends ServicoRestBase {

	private static final ConsultivoREST instance = new ConsultivoREST();

	global ConsultivoREST(){
		super.setServicoRestBase('Consultivo');
	}

	@HttpPost
	global static void processarPost() {
		instance.processarServico('POST');
	}

	public override void processarServico(String metodo){
      try
      	{
	        String payload;
			if(!Test.isRunningTest()){
				payload = RestContext.request.requestBody.toString();
			}else{
				HttpRequest req = new HttpRequest();
				CasoRestMock mock = new CasoRestMock();
				HttpResponse resposta = mock.respond(req);
				payload = resposta.getBody();
			}

			this.retonarSucesso(JSON.serialize(SniperMock.retornoCivConsultivo()), 200);

		}
		catch (Exception e) {
			system.debug('error : ' + e); 
		}
    }
}