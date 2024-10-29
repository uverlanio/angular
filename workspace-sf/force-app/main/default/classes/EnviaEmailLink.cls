/*
@description  Realiza o envio do link por email - //RVI-262  e RVI-223 - INCIO
@author Vinícius Amaral - Sys4b
@date 10/03/2023
*/

public with sharing class EnviaEmailLink {
    
    public class Input {
        public String email;
        public String link;
        public String nome;
        public String proposta;
        public String corretor;
    }
    //RVI-262-FIX01-INICIO
    public static String formatarEmail(Input input){
 
        List<OrgWideEmailAddress> lstEmailAddress = [select Id from OrgWideEmailAddress WHERE Address = 'adminsalesforce.vida@portoseguro.com.br'];
        EmailTemplate emailTemplate = [Select Id, HtmlValue from EmailTemplate where name = 'EnviaLinkEmail' LIMIT 1];
        String bodyToSend = emailTemplate.HtmlValue; 
        if(input.email != null && input.link != null && input.nome != null && input.proposta != null && input.corretor != null){   
            bodyToSend = bodyToSend.replace('@NOME', input.nome);
            bodyToSend = bodyToSend.replace('#linkApolice#', input.link);
            bodyToSend = bodyToSend.replace('#proposta#', input.proposta);
            bodyToSend = bodyToSend.replace('#corretor#', input.corretor);
            
            String[] toAddresses = new String[] {input.email};
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            email.setToAddresses(toAddresses);
            email.setSubject('LINK PARA DADOS DE PAGAMENTO DO SEU SEGURO DE VIDA');
            email.setHtmlBody(bodyToSend);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            for (Messaging.SendEmailResult mr : results) 
            {
                if (mr.isSuccess()) {
                    return 'Deu sucesso';
                }  else {           
                    for(Messaging.SendEmailError err : mr.getErrors()) {
                        return err.getStatusCode() + ' - ' + err.getMessage() + ' - ' + err.getFields();
                    }
                }
            }
        }
        return 'Nem sucesso nem erro';
    }
    //RVI-262-FIX01-FIM
    
    public static Input parse(String json){
        return (Input) System.JSON.deserialize(json, Input.class);
    }
    
}//RVI-262  e RVI-223- FIM