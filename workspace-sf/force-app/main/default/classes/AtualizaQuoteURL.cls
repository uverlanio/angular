public with sharing class AtualizaQuoteURL {
    public AtualizaQuoteURL() {
        List<String> lVoucher = new  List<String>();
        List<String> lproposta = new  List<String>();
        String Title;
        List<Quote> proposta = [Select Id, Name, Origem__c, NumeroProposta__c, VoucherPdfDownloadUrl__c,PropostaPdfDownloadUrl__c  from Quote where CreatedDate > 2022-12-01T01:25:00.000+0000 and DistributionPublicUrl__c =''];    
       if ( proposta.size() > 0 ) {
          for (integer i=0; i<proposta.size(); i++) {
            if (proposta[i].VoucherPdfDownloadUrl__c !='') {
                //Lista as Propostas 
                 lVoucher.add('Voucher_'+proposta[i].Origem__c+'_'+proposta[i].NumeroProposta__c);
            }
            if (proposta[i].PropostaPdfDownloadUrl__c !='') {
                Title = 'Proposta_' + (proposta[i].Name).replace('-','_');
                lproposta.add(Title); 
            }
        }
            if (lVoucher.size() > 0){
                for (integer i=0; i < lVoucher.size(); i++) {
                List<ContentDistribution> conteudo =[Select Id, DistributionPublicUrl from  ContentDistribution where Name =: lVoucher[i] Limit 1];
                    if(conteudo.size() >0) {
                        for (integer a=0; a<conteudo.size(); a++) {
                            System.debug('DistributionPublicUrl>>>'+conteudo[a].DistributionPublicUrl+'>>>>'+ conteudo[a].Name);
                        }
                    }
                
                }   
            }
            if (lProposta.size() > 0){
                for (integer i=0; i < lProposta.size(); i++) {
                List<ContentDistribution> conteudo =[Select Id, Name, DistributionPublicUrl from  ContentDistribution where Name =: lProposta[i] Limit 1];
                    if(conteudo.size() >0) {
                        for (integer b=0; b<conteudo.size(); b++) {
                            System.debug('lProposta DistributionPublicUrl>>>'+conteudo[b].DistributionPublicUrl+conteudo[b].Name);
                        }
                    }
                
                }   
            }
       }

     

      
    }
}