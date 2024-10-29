/**
 * Fatura REST
 *
 **/
@RestResource(urlMapping='/fatura/*')
global with sharing class FaturaREST extends ServicoRestBase  {
	private static final FaturaREST instance = new FaturaREST();
	private static FaturaFacade fatura = FaturaFacade.getInstance();

	global FaturaREST(){
		super.setServicoRestBase('GeracaoFatura');
	}

	@HttpPost
	global static void processarPost() {
		instance.processarServico('POST');
	}

	public override void processarServico(String metodo){
		try {
			if(metodo == 'POST'){
				String payload = RestContext.request.requestBody.toString();
				FaturaFacade.RetornoFaturaRestTO retorno = fatura.gerarFatura(payload);
				this.retonarSucesso(JSON.serialize(retorno), 200);
			}
		}
		catch (Exception e) {
			this.retornarErro(e.getMessage());
		}
	}
}