//PLV - 4572 GUSTAVO DA SILVA PEREIRA SYS4B - INICIO
public class BoletoComponenteController {
    
    @AuraEnabled
    public static List<BoletoTO> BoletoToComponent(String id){
        
        List<BoletoTO> lstBoleto = new List<BoletoTO>();
        
        List<public_boleto__x> boletoFind = new List<public_boleto__x>();
        
        ContratanteContrato__c contratanteContrato = [SELECT Id, Contrato__c FROM ContratanteContrato__c WHERE Id =: id];
        
        if(!test.isRunningTest()){
            boletoFind = [SELECT ExternalId, idcontrato__c, status__c, vencimento__c, numeroparcela__c, urlboleto__c, quantidadevalorcontrato__c, dataenvio__c 
                          FROM public_boleto__x 
                          WHERE idcontrato__c =: contratanteContrato.Contrato__c ];
        }else{
            public_boleto__x boletoExterno = new public_boleto__x();
            boletoExterno.idcontrato__c = contratanteContrato.Contrato__c;
            boletoExterno.numeroparcela__c = '1';
            boletoExterno.status__c = ' a';
            boletoExterno.quantidadevalorcontrato__c = 1.0;
            boletoExterno.dataenvio__c = system.today();
            boletoExterno.vencimento__c = system.today();
            boletoExterno.urlboleto__c = 'asfasfasf';
            boletoFind.add(boletoExterno);
        }
        
        
        NamedCredential endpontSF = [select Endpoint from NamedCredential where DeveloperName = 'SFECM' limit 1];
        system.debug('endpontSF: '+endpontSF);
        
        if(!boletoFind.isEmpty())
        {
            for(public_boleto__x item: boletoFind)
            {
                BoletoTO boleto 	= new BoletoTO();
                
                boleto.parcela = Integer.ValueOf(item.numeroparcela__c);
                boleto.status = item.status__c;
                boleto.valor = item.quantidadevalorcontrato__c;
                boleto.dataEnvio = item.dataenvio__c;
                boleto.dataVencimento = item.vencimento__c;
                boleto.url = endpontSF.Endpoint+'apex/VFGerarBoleto?token='+item.urlboleto__c ;
                
                lstBoleto.add(boleto);		
                
            }
        }
        
        return lstBoleto;
    }
    public class BoletoTO
    {
        @AuraEnabled public Integer parcela { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Decimal valor { get; set; }
        @AuraEnabled public Date dataVencimento { get; set; }
        @AuraEnabled public Date dataEnvio { get; set; }
        @AuraEnabled public String url { get; set; } 
    }
}
//PLV - 4572 GUSTAVO DA SILVA PEREIRA SYS4B - FIM