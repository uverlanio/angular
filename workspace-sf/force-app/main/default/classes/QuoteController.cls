public with sharing class QuoteController {

    @AuraEnabled
    public static void enviarTemplateEmail(Id quoteId) {

        Quote quote = [SELECT Id, 
                            Email__c, 
                            Name, 
                            Empresa__c, 
                            AccountId, 
                            Account.Name, 
                            Link_Questionario_Samplemed__c
                        FROM Quote 
                        WHERE Id = :quoteId LIMIT 1];

        if (quote != null) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            String toAddress = quote.Email__c;
            email.setToAddresses(new String[] { toAddress });

            String htmlBody = '<p>Prezado ' + quote.Name + ' (Proposta Nº ' + quote.Id + '),</p>' +
                            '<p>Por favor, clique no link abaixo para preencher o formulário:</p>' +
                            '<p><a href="' + quote.Link_Questionario_Samplemed__c + '" target="_blank">Clique aqui</a></p>' +
                            '<p>Atenciosamente,</p>' +
                            '<p>Sua Empresa</p>';

            email.setHtmlBody(htmlBody);
            email.setSubject('Preenchimento de Formulário - Proposta Nº ' + quote.Name);
            email.setSaveAsActivity(false);

            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            } catch (Exception e) {
                throw new AuraHandledException('Erro ao enviar o e-mail: ' + e.getMessage());
            }
        }
    }

    

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getQuoteDetails(String quoteId) {
        Map<String, Object> result = new Map<String, Object>();
    
        if (String.isNotBlank(quoteId)) {
            Quote quote = [
                SELECT Status, Link_expirado__c, CreatedDate, Id_do_Proponente__c //FNPVVEP-99-FIX01 - INICIO/FIM
                FROM Quote 
                WHERE Id = :quoteId
                LIMIT 1
            ];
    
            result.put('status', quote.Status);
            result.put('linkExpirado', quote.Link_expirado__c);
            result.put('dataEmissao', quote.CreatedDate);
            result.put('idProponente', quote.Id_do_Proponente__c);//FNPVVEP-99-FIX01 - INICIO/FIM
        } else {
            result.put('error', 'Invalid Quote ID');
        }
        
        return result;
    }
    
    
    
}