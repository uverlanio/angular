//PLV-4556 - INÍCIO
@RestResource(urlMapping='/apoliceInadimplencia/*')
global with sharing class ApoliceInadimplenciaREST {

  @HttpPost
  global static void cancelarApolice() {

    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;

    System.debug('request> ' + JSON.serializePretty(request));
    System.debug('body>' + request.requestBody.toString());

    Request requestListContratos = new Request();
    Response responseListContratos = new Response();
    responseListContratos.itens = new List<ItemResponse>();
    Map<String, ItemRequest> mapItemContrato = new Map<String, ItemRequest>();

    try {
      requestListContratos = (Request) JSON.deserialize( request.requestBody.toString(), Request.class );
      System.debug('Contratos: ' + System.JSON.serializePretty(requestListContratos));
     for (ItemRequest item : requestListContratos.itens) {
        mapItemContrato.put(item.input, item);
      }

      List<Contract> listContract = ContractDAO.getInstance().buscarContratosByName(mapItemContrato.keySet());
     
     for (Contract contrato : listContract) {
        mapItemContrato.get(contrato.Name).contract = contrato;
        contrato.StatusHeroku__c = 'Aguardando Processamento';
      }
     TriggerHandler.bypass('ContractTriggerHandler');
      update listContract ;
      TriggerHandler.clearBypass('ContractTriggerHandler');
      //PLV-5458 INICIO
      List<Contract> contratosInadimp = new List<contract>();
      for (ItemRequest item : mapItemContrato.values()) {
        system.debug('item> ' + JSON.serialize(item));
        if (item.contract != null) {
          item.sucesso = true;
          item.status = 'Aguardando Processamento';
          system.debug('beforeCancelarContrato');
          system.debug(item.contract);
          contratosInadimp.add(item.contract);
        } else {
          item.sucesso = false;
          item.status = 'Recusado';
        }
      }
      if(!contratosInadimp.isEmpty()){
        // ContractBO.cancelarContratoInadimplencia(JSON.serialize(contratosInadimp));     //MGRC-1657 - INICIO/FIM
      }
      //PLV-5458 FIM
    } catch (Exception e) {
      responseListContratos.status = 'ERRO';
      responseListContratos.sucesso = false;
    }
    responseListContratos.status = 'PROCESSADO';
    responseListContratos.sucesso = true;
    responseListContratos.acao = 'cancelar';

    for (ItemRequest item : mapItemContrato.values()) {
      ItemResponse itemResponse = new ItemResponse();
      itemResponse.id = item.id;
      itemResponse.contrato = item.contrato.trim();
      itemResponse.input = item.input;
      itemResponse.sucesso = item.sucesso;
      itemResponse.status = item.status;
      responseListContratos.itens.add(itemResponse);
    }

    System.debug('response> ' + JSON.serializePretty(responseListContratos));
    if(!test.isRunningTest()){ //PLV-4556 FIX 1 - INÍCIO
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(responseListContratos));
    } //PLV-4556 FIX 1 - INÍCIO
  }


  public class Request {
    String acao { get; set; }
    List<ItemRequest> itens { get; set; }
    String status { get; set; }
    Boolean sucesso { get; set; }
  }
  public class ItemRequest {
    String id { get; set; }
    String input { get; set; }
    Boolean sucesso { get; set; }
    String contrato { get; set; }
    Contract contract { get; set; }
    String status { get; set; }
  }
  global class Response {
    global List<ItemResponse> itens { get; set; }
    global String acao { get; set; }
    global Boolean sucesso { get; set; }
    global String status { get; set; }
  }
  global class ItemResponse {
    global String id { get; set; }
    global String contrato { get; set; }
    global String input { get; set; }
    global Boolean sucesso { get; set; }
    global String status { get; set; }
    global String apolice {get; set; }
  }
}
//PLV-4556 - FIM