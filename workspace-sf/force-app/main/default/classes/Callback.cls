// CRIAÇÃO EM FUNÇÃO DA HISTORIA PLV-3918
public class Callback extends DataSource.AsyncSaveCallback{
    //PLV-3918-FIX4 - INICIO
     @TestVisible private List<Pagamento_de_Sinistro__c> lpgtest = new List<Pagamento_de_Sinistro__c>();
    //PLV-3918-FIX4 - FIM
    public override void processSave(Database.SaveResult saveResult){
        system.debug('itens salvos'+JSON.serialize(saveResult));
      	
        if(saveResult.success == true){
            Pagamento__x obj = null;
            if(!Test.isRunningTest())
            	obj = [SELECT ExternalId, idObjeto__c FROM Pagamento__x WHERE Id =: saveResult.id];
            else
                obj = new pagamento__x(
                	 //PLV-3918-FIX3 - INICIO
                	 ExternalId = '133'
                     //PLV-3918-FIX3 - FIM
                );
            //PLV-3918-FIX4 - INICIO
            	//PLV-3918-FIX1 - INICIO
            Requisicao_de_Pagamento__c objr = null;
            List<Pagamento_de_Sinistro__c> lpg = (!lpgtest.isEmpty()) ? lpgtest : [SELECT Id, Requisicao_de_Pagamento__c FROM Pagamento_de_Sinistro__c WHERE 
                                                             Requisicao_de_Pagamento__c =: obj.idObjeto__c
                                                            ];
            List<Pagamento_de_Sinistro__c> upPagamento = new List<Pagamento_de_Sinistro__c>();
            //PLV-3918-FIX3 - INICIO
            NotaFiscal__c notaFiscal = null;
            //PLV-3918-FIX3 - FIM
            if(!Test.isRunningTest()){
                //PLV-3918-FIX3 - INICIO
                //PLV-4148-FIX5 - INICIO
            	objr = [SELECT Status__c, Nota_fiscal__c,Data_Programada_de_Pagamento__c   FROM Requisicao_de_Pagamento__c WHERE Id =: obj.idObjeto__c];
                //PLV-4148-FIX5 - FIM
            	notaFiscal = [SELECT Pagamento__c FROM NotaFiscaL__c WHERE Id =: objr.Nota_fiscal__c LIMIT 1];
                //PLV-3918-FIX3 - FIM
            	//lpg  =  [SELECT Id, Requisicao_de_Pagamento__c FROM Pagamento_de_Sinistro__c WHERE Requisicao_de_Pagamento__c =: obj.idObjeto__c];
                
            }else{
                //PLV-4148-FIX5 - INICIO
                objr = [SELECT Status__c, Data_Programada_de_Pagamento__c FROM Requisicao_de_Pagamento__c limit 1];
                //PLV-4148-FIX5 - FIM
                //lpg  =  [SELECT Id, Requisicao_de_Pagamento__c FROM Pagamento_de_Sinistro__c limit 1];
                //PLV-3918-FIX3 - INICIO
                notaFiscal = [SELECT Pagamento__c FROM NotaFiscaL__c LIMIT 1];
                //PLV-3918-FIX3 - FIM
            }
            //PLV-3918-FIX4 -FIM
            objr.Status__c = 'Enviado p/ Financeiro';
            objr.Numero_OP_SAP__c = obj.ExternalId;
       
            update objr;
            //PLV-3918-FIX3 - INICIO
            notaFiscal.Pagamento__c = obj.ExternalId;
          
            update notaFiscal;
            //PLV-3918-FIX3 - FIM
            
            system.debug('pagamento de sisnitro'+lpg);
            for(Pagamento_de_Sinistro__c pg : lpg){
                pg.OP_SAP__c =  obj.ExternalId;
                Pagamento_de_Sinistro__c objPag = pg;
                //PLV-4148-FIX5 - INICIO
                pg.Data_Programada_de_Pagamento__c = objr.Data_Programada_de_Pagamento__c ;
                //PLV-4148-FIX5 - FIM
                upPagamento.add(objPag);
            }
            update upPagamento;
            //PLV-3918 - FIX1 FIM
        }
        
    }
}