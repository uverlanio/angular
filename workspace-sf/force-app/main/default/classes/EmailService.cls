@RestResource (urlMapping = '/EmailService/*') 
global class EmailService { 
   @HttpPost 
   // #PLV-3718 - Reenvio de e-mail do kit boas vindas - apólices
    global static EmailServiceResponse doPost (string apolice) {

        String responseStr;
        
        try {
            list<Contract> contractList = [select id, Account.PersonEmail, AccountID, IdExterno__c from Contract where IdExterno__c =: apolice];
            
            if(contractList.size() <= 0){
                return responseVal('nocontract');
            }
            list<Contact> conList = [select id from contact where AccountId =: contractList[0].AccountId];
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setWhatId(contractList[0].id);
            message.setTargetObjectId(conList[0].Id);
            // Template de email configurado aqui
            // Para reaproveitar o codigo, alterar essa query
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Email Apolice Segunda Via'];
            message.setTemplateId(emailTemplate.Id);
            message.setTreatTargetObjectAsRecipient(false);
            message.toAddresses = new String[]{contractList[0].Account.PersonEmail};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success)
            {
                return responseVal('success');
            }
        } catch (Exception e) {
            return responseVal('invalid');
        } 
         return null; 
    }
    
    //Tratamento do Retorno do Serviço
    public static EmailServiceResponse  responseVal(String status){
        EmailServiceResponse resp = new EmailServiceResponse();
        EmailServiceResponse.Meta metaVal = new EmailServiceResponse.Meta();
        EmailServiceResponse.Data dataVal = new EmailServiceResponse.Data();
        dataVal.apolice = new List<String>();
        metaVal.dataExecucao = string.valueOf(system.now());
        metaVal.servico = 'reenvioEmail';
        metaVal.statusHttp = 200;
           
           //Sucesso
        if(status == 'success'){
            metaVal.mensagem = 'Ok';
            dataVal.statusChamada = 1;
            dataVal.descricaoChamada= 'Email re-enviado com successo';
        } //Inválido 
        else if(status == 'invalid') {
            metaVal.mensagem = 'NOk';
            dataVal.statusChamada = 9;
            dataVal.descricaoChamada= 'parâmetros insuficientes para completar a requisição';
        } //Sem contrato 
        else if (status == 'nocontract') {
            metaVal.mensagem = 'NOk';
            dataVal.statusChamada = 0;
            dataVal.descricaoChamada= 'Apólice não encontrada';
        }
        
        resp.Meta = metaVal;
        resp.Data = dataVal;
        return resp;
    }
    // #PLV-3718 - FIM
}