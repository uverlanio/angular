@RestResource(urlMapping ='/api/consultaArquivoOrcamento/*')
global with sharing class consultaArquivoOrcamento {

    @HttpGET
    global static CodigoPropostaResponse doGET() {
        String lJsonRequest = RestContext.request.requestBody.toString();
        RestRequest req = RestContext.request;
        String request = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        //CodigoPropostaRequest request =  (CodigoPropostaRequest) JSON.deserialize(lJsonRequest,CodigoPropostaRequest.class);
        CodigoPropostaResponse response = new CodigoPropostaResponse();
      
    

        if(!String.IsEmpty(request)) {
            String searchTerm = '{'+request+',entradaServico}';
            String Documento = 'FIND' + searchTerm + ' IN ALL FIELDS RETURNING ContentDocument(Id) LIMIT 10';
            List<List <sObject>> searchList = search.query(Documento);

            if (searchList.size() >0 ) {
              List<ContentDocument> accList = New List<ContentDocument>();
              accList = ((List<ContentDocument>)searchList[0]);
              List<ContentVersion> Conteudo = New List<ContentVersion>();
              Conteudo = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :accList AND IsLatest = true];
              if (Conteudo.size() >0 ) {
                String body = Conteudo[0].VersionData.toString();
                response.isSuccess = true;
                response.message = 'Arquivo capturado com sucesso';
                response.ArquivoJson = body; 
              } else {
                response.isSuccess = false;
                response.message = 'Erro, o numero do orcamento nao encontrado';
                response.ArquivoJson = 'Não possui json';
              }

           } else {
            response.isSuccess = false;
            response.message = 'Erro, o numero do orcamento nao encontrado';
            response.ArquivoJson = 'Não possui json';
           }
           
           
           
        } else {
            response.isSuccess = false;
            response.message = 'Erro, o numero do orcamento nao pode ser vazio';
            response.ArquivoJson = 'Não possui json';
        }

      return response;
        
    }

    global class CodigoPropostaResponse {
    @testVisible global Boolean isSuccess  {get;set;}
    @testVisible global String  message    {get;set;}
    @testVisible global String  ArquivoJson {get;set;}

    }

    global class CodigoPropostaRequest {
    @testVisible global String numeroOrcamento {get;set;}
   }

}