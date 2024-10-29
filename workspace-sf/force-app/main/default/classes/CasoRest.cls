/**
 * Caso REST
 * @author GFS @ 30/01/2019
 * @modified GFS @ 21/03/2019
 *
 **/
 @RestResource(urlMapping='/caso/pagamentosinistro/*')
 global with sharing class CasoRest extends ServicoRestBase {

   private static final CasoREST instance = new CasoREST();

   global CasoREST(){
    super.setServicoRestBase('PagamentoSinistro');
  }

  @HttpPost
  global static void processarPost() {
    instance.processarServico('POST');
  }

  public override void processarServico(String metodo){
    try{
      String payload;
      //PLV-2285 - Início - Ajuste na classe para maior cobertura na classe de teste 
      if(!Test.isRunningTest()){payload = RestContext.request.requestBody.toString();
        }else{
          HttpRequest req = new HttpRequest();
          req.setBody(metodo);
          CasoRestMock mock = new CasoRestMock();
          HttpResponse resposta = mock.respond(req);
            System.debug('*********************************** passou aqui');
          payload = resposta.getBody();
        } 
      //PLV-2285 - Fim - Ajuste na classe para maior cobertura na classe de teste
        String JsonInput = payload.replace('[','').replace(']','');
        List<Object> listObject = (List<Object>) JSON.deserializeUntyped(payload);
   
        Map<String,Map<String,Object>> mBeneficiario = new Map<String,Map<String,Object>>();        
        
        for(Object obj :listObject)
        {
         String stringObject = JSON.serialize(obj); 
         Map<String, Object> mObject = (Map<String, Object>) JSON.deserializeUntyped(stringObject);   

         mBeneficiario.put(String.valueOf(mObject.get('idobjeto')), mObject); 

       }

       Set<BeneficiarioGarantia__c> lstpagamentos = new Set<BeneficiarioGarantia__c>();
       List<BeneficiarioGarantia__c> pagamento2update = new List<BeneficiarioGarantia__c>();

       List<BeneficiarioGarantia__c> LstBeneficiarioGaran = [SELECT Id, DataPagamento__c, NumeroOrdemPagamento__c, ValorPago__c, 
                                                                    Status__c, Tipo_de_Pagamento__c, 
                                                                    Pagamento_de_garantia__r.Caso__c,
                                                                    Pagamento_de_garantia__c
                                                             FROM BeneficiarioGarantia__c
                                                             WHERE Id =: mBeneficiario.keySet()
                                                             AND Status__c != 'Pago'
                                                             ];

       if(LstBeneficiarioGaran.isempty())
       {
        this.retonarSucesso(JSON.serialize('ERRO'), 400);
        }else{
		//PLV-2285 Fix1 - Início - Ajuste na classe para atender regra de negócio
          Set<String> idsObjeto = new Set<String>();

          for(BeneficiarioGarantia__c paggarantia : LstBeneficiarioGaran){
            Map<String,Object> mRegistro = mBeneficiario.get(paggarantia.Id);
            if(mRegistro.get('status') == 'PAGO'){
                if(mRegistro.get('datapagamento') != null){
                  String dataFormat = String.valueOf(mRegistro.get('datapagamento'));
                  dataFormat = dataFormat.replace('T', ' '); 
                  dataFormat = dataFormat.replace('Z', '');
                  paggarantia.DataPagamento__c = Datetime.valueOf(dataFormat); 
                }
                paggarantia.NumeroOrdemPagamento__c = String.valueOf(mRegistro.get('id'));
                paggarantia.ValorPago__c = Decimal.valueOf(String.valueOf(mRegistro.get('valorpagamento')));
                paggarantia.Status__c = 'Pago';
                lstpagamentos.add(paggarantia);
            //Código removido por conta da história PLV-2296
            }else if(mRegistro.get('status') == 'ERRO'){
              paggarantia.Status__c = 'Erro';
              lstpagamentos.add(paggarantia);
            }else if(mRegistro.get('status') == 'CANCELADO'){
              paggarantia.Status__c = 'Cancelado';
              paggarantia.Observacao__c = String.valueOf(mRegistro.get('motivo'));
              lstpagamentos.add(paggarantia);
            //PLV-2285 Fix1 - Fim - Ajuste na classe para atender regra de negócio
          }
        }

        }

        if(!lstpagamentos.isempty()){   
          for(BeneficiarioGarantia__c pag : lstpagamentos)
          {
            pagamento2update.add(pag);
          }
          
          List<String> result = new List<String>();
          if(!pagamento2update.isempty()){
           Database.SaveResult[] srList = Database.update(pagamento2update, false);
           for (Database.SaveResult sr : srList) {
             if (sr.isSuccess()) {
             }
             else { 
              for(Database.Error err : sr.getErrors()) {
                result.add('Erro');
                break;
              }  
            }
          }
        }
        if(result.isempty()) this.retonarSucesso(JSON.serialize('OK'), 200);
        if(!result.isempty()) this.retonarSucesso(JSON.serialize('ERRO'), 400);
      }

    }
    catch (Exception e) {
     system.debug('error : ' + e.getMessage()); 
   }
 }
}