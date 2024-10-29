/*******************************************************************************************************************************
* 
* @author Pedro Augusto Braz - SYS4B
* @date 10/12/2020
* @modifiedAt 
* Classe criada por conta da história PLV-4572
* Serviço para Criptografar valores
******************************************************************************************************************************/
@RestResource(urlMapping='/crypto/*')
global with sharing class CryptoTokenREST {

    /*PAYLOAD EXEMPLO ENTRADA
    {
        "acao":"encrypt",
        "itens":[
            {
                "id":"abcdaef",
                "input":"001235152"
            }
        ]
    }

    PAYLOAD RETORNO ESPERADO
    {"sucesso":true,"mensagem":"","itens":[{"sucesso":true,"output":"EZIUg9nyOqLV3fwE7TREDgo5YijcccgFZq8t23qh00g=","input":"001235152","id":"abcdaef"}],"acao":"encrypt"}
    */

    public class Request{
        String acao {get;set;}
        List<ToCrypto> itens{get;set;}
    }
    
    public class Response{
        String acao {get;set;}
        String mensagem {get;set;}
        Boolean sucesso  {get;set;}
        List<ToCrypto> itens{get;set;}

        public Response setError(String mensagem,String acao){
			this.sucesso = false;
			this.acao = acao;
			this.mensagem = mensagem;
			return this;
		}
		public void setSucesso(){
			this.sucesso = true;
			this.mensagem = '';
		}
    }

    public class ToCrypto{
        String id {get;set;}
        String input {get;set;}
        String output {get;set;}
        Boolean sucesso {get;set;}
        String mensagem {get;set;}
    }


    @HttpPost
	global static void processarPost() {
		System.debug('processarPost');
		RestRequest req = RestContext.request;
		RestResponse response = RestContext.response;
		Response responseToSend = new Response();
		String payload = req.requestBody.toString();
		
		System.debug('payload '+payload);
		
		try {
			CryptoTokenREST.Request payloadRequest = (CryptoTokenREST.Request) JSON.deserialize(payload, CryptoTokenREST.Request.class);
			responseToSend = processarAcao(payloadRequest);
			System.debug('responseToSend'+JSON.serialize(responseToSend));	
		} catch (Exception e) {
			responseToSend.setError('Inconsistências no payload de requisição: '+e.getCause() +' - '+e.getStackTraceString(), null);
		}
		
		response.responseBody = Blob.valueOf(JSON.serialize(responseToSend,true));
		response.addHeader('Content-Type', 'application/json');
    }

    public static CryptoTokenREST.response processarAcao(CryptoTokenREST.Request request){
        CryptoTokenREST.Response responseToSend = new CryptoTokenREST.Response ();
        if(request.itens==null || request.itens.isEmpty()){return responseToSend.setError('Lista de itens vazia',request.acao);}
        
        // PLV-5188 INICIO FIX01

        if(request.acao!='encrypt' && 
           request.acao!='decrypt' &&
           request.acao!='encryptUrl' &&
           request.acao!='decryptUrl' ){return responseToSend.setError('Ação não reconhecida',request.acao);}
        
        List<ToCrypto> processedItens = new List<ToCrypto>();
        CryptoToken c = new CryptoToken();
        String acaoCrypto = request.acao;
        System.debug(acaoCrypto);//PLV-5188-INICIO/FIM FIX02
        if((acaoCrypto == 'encrypt' || acaoCrypto == 'encryptUrl')){
            System.debug(acaoCrypto);//PLV-5188-INICIO/FIM FIX02
            for(ToCrypto item : request.itens){
                if(item.input!=null && item.input!=''){
                    try {
                        item.output = acaoCrypto =='encrypt' ? c.encrypt(item.input) : c.encryptUrl(item.input);//função de criptografia
                        item.sucesso = true;
                    } catch (Exception e) {
                        item.mensagem = 'Erro ao Criptografar: '+e.getCause()+' - '+e.getStackTraceString();
                        item.sucesso = false;
                    }
                }else{
                    item.mensagem = 'Input Vazio ou Nulo';
                    item.sucesso = false;
                }
                processedItens.add(item);
            }
        }else{
            System.debug(acaoCrypto);//PLV-5188-INICIO/FIM FIX02
            for(ToCrypto item : request.itens){
                if(item.input!=null && item.input!=''){
                    try {
                        item.output = acaoCrypto =='decrypt' ? c.decrypt(item.input) : c.decryptUrl(item.input);//função de descriptografar
                        item.mensagem = '';
                        item.sucesso = true;
                    } catch (Exception e) {
                        item.mensagem = 'Erro ao Descriptografar: '+e.getCause()+' - '+e.getStackTraceString();
                        item.sucesso = false;
                    }
                }else{
                    item.mensagem = 'Input Vazio ou Nulo';
                    item.sucesso = false;
                }
                processedItens.add(item);
            }
        }
        // PLV-5188 FINAL FIX01

        responseToSend.setSucesso();
        responseToSend.acao = request.acao;
        responseToSend.itens = processedItens;
        return responseToSend;
    }      
}