/**
 *  Atualiza Dadis Arquivos ECM - REST
 *
 **/
@RestResource(urlMapping='/arquivos_ecm/*')
global with sharing class AtualizarDadosArquivosEcmREST extends ServicoRestBase  {
	private static final AtualizarDadosArquivosEcmREST instance = new AtualizarDadosArquivosEcmREST();
	private static AtualizarDadosArquivosEcmFacade  AtualizarIdECMArquivos = AtualizarDadosArquivosEcmFacade.getInstance();

	global AtualizarDadosArquivosEcmREST(){
		super.setServicoRestBase('AtualizarIdArquivos');
	}

	@HttpPost
	global static void processarPost() {
		instance.processarServico('POST');
	}

	public override void processarServico(String metodo){
		try {
			if(metodo == 'POST'){
				String payload = RestContext.request.requestBody.toString();
				RetornoRestTO retorno = AtualizarIdECMArquivos.Atualizar(payload);
				this.retonarSucesso(JSON.serialize(retorno), 200);
			}
		}
		catch (Exception e) {
			this.retornarErro(e.getMessage());
		}
	}
}