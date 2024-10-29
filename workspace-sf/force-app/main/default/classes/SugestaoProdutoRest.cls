/*
*
* Serviço responsável pela disponibilização dos processamentos de sugestão de produtos 
*
*/
@RestResource(urlMapping='/sugestaoproduto')
global class SugestaoProdutoRest extends ServicoRestBase{
	private static final SugestaoProdutoRest instance = new SugestaoProdutoRest();
	private static SugestaoProdutoFacade sugestaoProduto = SugestaoProdutoFacade.getInstance();

	global SugestaoProdutoRest(){
		super.setServicoRestBase('SugestaoProduto');
		super.setRetornoMeta(false);
	}

	@HttpPost
    global static void processarPost() {
    	instance.processarServico('POST');
    }

    public override void processarServico(String metodo){
    	try {
    		if(metodo == 'POST'){
	        	String payload = RestContext.request.requestBody.toString();
	        	SugestaoProdutoTO.SaidaTO dadosSaida = sugestaoProduto.sugerirProdutos((OrcamentoTO.PayloadTO)JSON.deserialize(payload, OrcamentoTO.PayloadTO.class));
	        	this.retonarSucesso(JSON.serialize(dadosSaida), 200);
    		}
		}
		catch (Exception e) {
			this.retornarErro(e.getMessage());
		}
    }
}