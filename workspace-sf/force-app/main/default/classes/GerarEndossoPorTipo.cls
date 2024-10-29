/**
 * valida direcionamento para realizar o Endosso
 * Jeferso santana 08/12/2020
 * PLV-4578
 **/
public class GerarEndossoPorTipo {
    public string mensagem{get;set;}
    private static final Integer ENDOSSO_DIAS_ANTES_FINAL=30; // PLV-4668 INICIO/FIM SYS4B ODEMIR // PLV-5221-INCIO/FIM
    public GerarEndossoPorTipo(ApexPages.StandardController controller) {
        //PLV-4695-FIX6-INICIO
        this.mensagem = 'Endosso não permitido - Contrato não Emitido.';
        //this.mensagem = 'Segmento '+ ApexPages.currentPage().getParameters().get('segmento')+' do contrato não permite Endosso!';
        //PLV-4695-FIM
        
    }
   
    public PageReference validarRedirect(){
        system.debug('id cobntrato'+ApexPages.currentPage().getParameters().get('id'));
    
        Id contractId =(ID) ApexPages.currentPage().getParameters().get('id');
        String segmento = ApexPages.currentPage().getParameters().get('segmento');
        if(contractId == null){
        contractId = ApexPages.currentPage().getParameters().get('idContrato');
        }
        //PLV-4695-FIX6 - INICIO
        //PLV-4536 inicio
        Contract contrato = [SELECT Id, Usuario_temporario__c, Status, Tipo__c,
        VigenciaFinal__c  // PLV-4668 INICIO/FIM SYS4B ODEMIR
             FROM Contract WHERE Id =:contractId];
        String statusContrato = contrato.Status;
        String tipoContrato = contrato.Tipo__c;
        contrato.Usuario_temporario__c = UserInfo.getUserId();
       //  update contrato; //  PLV-4668 INICIO/FIM SYS4B ODEMIR  
        System.debug('UserID: ' + UserInfo.getUserId());
        //PLV-4536 fim
        system.debug('validarRedirect'+contractId);
        string url;
        
        if(tipoContrato == 'Cancelamento'){
            this.mensagem = 'Endosso não permitido - Contrato tipo Cancelamento não pode ser alterado.';
        }

        // PLV-4668 INICIO SYS4B ODEMIR   
        Date dataAtualizadaToday = System.today();
        if (segmento == 'Individual' && System.today().daysBetween(contrato.VigenciaFinal__c) <= ENDOSSO_DIAS_ANTES_FINAL) {
            this.mensagem = 'Não foi possível realizar a emissão do endosso - Vigência final do contrato inferior a '+ENDOSSO_DIAS_ANTES_FINAL+' dias ';
            return null;
        }
        // PLV-4668 INICIO SYS4B ODEMIR     

        if(segmento == 'Viagem' && statusContrato == 'Emitido' && tipoContrato != 'Cancelamento'){
            url = '/apex/GerarEndossoViagem?idContrato='+contractId;        
        }else if(segmento == 'Individual' && statusContrato == 'Emitido' && tipoContrato != 'Cancelamento'){
            url = '/apex/GerarEndossoVidaIndividual?idContrato='+contractId;
        }else{
            url = '';
        }
        if(url == ''){
            return null;
        }

        update contrato; //  PLV-4668 INICIO/FIM SYS4B ODEMIR  
        //PLV-4695-FIX6-FIM
        PageReference retURL = new PageReference(url);
        retURL.getParameters().put('idContrato',contractId);
        retURL.setRedirect(true);
        return retURL;
       
        
        

    }
   

}