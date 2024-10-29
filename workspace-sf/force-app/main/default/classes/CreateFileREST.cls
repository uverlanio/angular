/*******************************************************************************************************************************
* 
* @author Pedro Augusto Braz - SYS4B
* @date 08/04/2021
* @modifiedAt 
* Classe criada por conta da história PLV-4891
* Serviço para Criar Arquivos
******************************************************************************************************************************/
@RestResource(urlMapping='/createfile/*')
global with sharing class CreateFileREST {

    /*PAYLOAD EXEMPLO ENTRADA
    {"itens":[{"fileName":"PEDRAO-TÁTESTADNO_localStorage","fileBody":"001235152","extensao":".min.json","recordId":"0Q0L0000000QBnqKAG"}]}

    PAYLOAD RETORNO ESPERADO
    {"sucesso":true,"mensagem":"","itens":[{"sucesso":true,"recordId":"0Q0L0000000QBnqKAG","fileName":"PEDRAO-TÁTESTADNO_localStorage","extensao":".min.json","documentId":"06AL0000001hhRNMAY","contentId":"068L0000000xrZHIAY"}]}
    */

    public class Request{
        List<FileToInsert> itens{get;set;}
    }
    
    public class Response{
        String mensagem {get;set;}
        Boolean sucesso  {get;set;}
        List<FileToInsert> itens{get;set;}

        public Response setError(String mensagem){
			this.sucesso = false;
			this.mensagem = mensagem;
			return this;
		}
		public void setSucesso(){
			this.sucesso = true;
			this.mensagem = '';
		}
    }


    public class FileToInsert{
        public String fileName {get;set;}
        public String fileBody {get;set;}
        public String recordId {get;set;}
        public String extensao {get;set;}
        public String contentId {get;set;}
        public String documentId {get;set;}
        public String mensagem {get;set;}
        public Boolean sucesso {get;set;}
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
			CreateFileREST.Request payloadRequest = (CreateFileREST.Request) JSON.deserialize(payload, CreateFileREST.Request.class);
			responseToSend = processarAcao(payloadRequest);
			System.debug('responseToSend'+JSON.serialize(responseToSend));	
		} catch (Exception e) {
			responseToSend.setError('Inconsistências no payload de requisição: '+e.getCause() +' - '+e.getStackTraceString());
		}
		
		response.responseBody = Blob.valueOf(JSON.serialize(responseToSend,true));
		response.addHeader('Content-Type', 'application/json');
    }

    public static CreateFileREST.response processarAcao(CreateFileREST.Request request){
        CreateFileREST.Response responseToSend = new CreateFileREST.Response ();
        if(request.itens==null || request.itens.isEmpty()){return responseToSend.setError('Lista de itens vazia');}

        List<FileToInsert> processedItens = new List<FileToInsert>();
        Boolean SucessoLista = true;
        for(FileToInsert item : request.itens){
            if(String.isBlank(item.fileName) || String.isBlank(item.fileBody) || String.isBlank(item.recordId) || String.isBlank(item.extensao)){
                item.mensagem = 'Um dos paramestros está vazio: fileName: '+item.fileName+' - fileBody: '+item.fileBody+' - recordId: '+item.recordId+' - extensao:'+item.extensao;
                item.sucesso = false;
                SucessoLista = false;
            }else{

                try {
                    Map<String,String> arquivo = FileController.createTextFileSync(item.fileName, item.fileBody, item.recordId, item.extensao);
                    item.contentId = arquivo.get('contentId');
                    item.documentId = arquivo.get('documentId');
                    item.sucesso = true;
                } catch (Exception e) {
                    item.mensagem = 'Erro ao Criar arquivo: '+e.getCause()+' - '+e.getStackTraceString();
                    item.sucesso = false;
                }
                item.fileBody = null;

                SucessoLista = SucessoLista == false ? false : item.sucesso;
            }
            
            processedItens.add(item);
        }
        if(SucessoLista)
        responseToSend.setSucesso();
        else
        responseToSend.setError('Alguns itens não foram processados corretamente');

        responseToSend.itens = processedItens;
        return responseToSend;
    }      
}