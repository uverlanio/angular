/*
*
* Classe base para ser utilizada com as classes de serviço rest
*
*/
global abstract class ServicoRestBase 
{
	private RetornoRestTO retorno {get; set;}
	private String nomeServico {get; set;}
	private RestResponse response {get; set;}
	private Boolean retornarMetadados {get; set;}

	global abstract void processarServico(String metodo);

	global void setServicoRestBase(String nomeServico){
		this.retorno = new RetornoRestTO(nomeServico);
		this.response = RestContext.response;
		this.retornarMetadados = true;
	}

	global void setRetornoMeta(Boolean retornarMeta){
		this.retornarMetadados = retornarMeta;
	}

	//Atribui dados que deverão ser retornados
	global void retonarSucesso(String dadosRetorno, Integer codigoHttp){
		String retonoObj;
		Object dadosRetornoObj = JSON.deserializeUntyped(dadosRetorno); 

		if(this.retornarMetadados){
			this.retorno.data = dadosRetornoObj;
			this.retorno.meta.statusHttp = codigoHttp;
			this.retorno.meta.mensagem = 'OK';
			dadosRetornoObj = JSON.deserializeUntyped(JSON.serialize(this.retorno));
		}
		System.debug(' @#@#@ obj success:> ' + JSON.serialize(dadosRetornoObj));
		this.executarRetorno(dadosRetornoObj);
	}

	//Gera mensagem de erro para ser retornado
	global void retornarErro(String erro){
		this.retorno.meta.statusHttp = 500;
		this.retorno.meta.mensagem = erro;
		System.debug(' $#@$#@ retorno antes erro:> ' + JSON.deserializeUntyped(JSON.serialize(this.retorno)));
		this.executarRetorno(JSON.deserializeUntyped(JSON.serialize(this.retorno)));
	}

	//Gera response para quem chamou o serviço
	private void executarRetorno(Object obj){
		// System.debug(' @#@#@ obj:> ' + obj);
		// System.debug(' @#@#@ this.response:> ' + this.response);
		// System.debug(' @#@#@ ALahu AKABAR !!:> ');
		if(Test.isRunningTest() && response == null) response = new RestResponse(); //PLV-3285
		// System.debug(' @#@#@ this.response.responseBody:> ' + this.response.responseBody);
		this.response.responseBody = Blob.valueOf(JSON.serialize(obj));
		this.response.addHeader('Content-Type', 'application/json');
	}
}