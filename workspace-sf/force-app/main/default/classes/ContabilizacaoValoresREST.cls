/**
 * ContabilizacaoValoresREST
 *
 **/
@RestResource(urlMapping='/contabilizacaovalores/*')
global with sharing class ContabilizacaoValoresREST extends ServicoRestBase  {
	private static final ContabilizacaoValoresREST instance = new ContabilizacaoValoresREST();
	private static ContabilizacaoValoresFacade contabilizacao = ContabilizacaoValoresFacade.getInstance();

	global ContabilizacaoValoresREST(){
		super.setServicoRestBase('ContabilizacaoValores');
	}

	@HttpPost
	global static void processarPost() {
		instance.processarServico('POST');
	}

	public override void processarServico(String metodo){
		try {
			if(metodo == 'POST'){
				String parametro = RestContext.request.requestBody.toString();
				
				contabilizacao.ExcluirRegistros(parametro);

				contabilizacao.GerarRegistros(parametro);

				this.retonarSucesso('{"processamento" : "ok"}', 200);
			}
		}
		catch (Exception e) {
			this.retornarErro(e.getMessage());
		}
	}
}