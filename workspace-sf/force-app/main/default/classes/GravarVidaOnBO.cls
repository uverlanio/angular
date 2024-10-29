/******************************************************************************************************************************
 * Classe de Negocio implementada para enviar o Cpf e suas respectivas propostas e contratos do produto Vida ON para o heroku *
 * @author : Globant                                                                                                          *
 * @date 19/07/2022                                                                                                           *
 * Classe implementada tendo como origem a história AV-530                                                                    *
 * Disparada através do Schedule 'GravarVidaOnSchedule'                                                                       *
 * ****************************************************************************************************************************/

//AV-530 FIX-01 INICIO
public with sharing class GravarVidaOnBO {    
    @future(callout=true)
    public static void gravarCPFVidaOn() { 
        
        RequestHerokuGravarCPF dadosContrato = new RequestHerokuGravarCPF();
        List<RequestHerokuGravarCPF> lstReq = new List<RequestHerokuGravarCPF>(); 
        
        List<Contract> lstCtrVidaOn = [SELECT Id, Name, Status, Account.Cpf__c, Tipo__c FROM Contract WHERE Produto__r.ProductCode = 'VIDA_ON'];
        System.debug('lstCtrVidaOn: ' + lstCtrVidaOn);
        //AV-530 FIX-03 INICIO
        if(!lstCtrVidaOn.isEmpty()){
            for(Contract contrato : lstCtrVidaOn){                         
                dadosContrato.propostas.add(new ContratoVdOnTO(contrato)); //AV-530 FIX-02
            }  
            System.debug('dadosContrato: ' + dadosContrato);        
            String jsonList = JSON.serialize(dadosContrato);
            System.debug('jsonListContract: ' + jsonList);
            ResponseHerokuGravarCPFVidaOn responseGravarCPFVidaOn = HerokuService.getInstance().gravarCPFVidaOn(jsonList);
            String jsonResponseGravar = JSON.serialize(responseGravarCPFVidaOn);
        }
        //AV-530 FIX-03 FIM
    }     

    public class RequestHerokuGravarCPF{
        public List<ContratoVdOnTO> propostas               {get;set;} //AV-530 FIX-02
        Public RequestHerokuGravarCPF(){
            this.propostas = new List<ContratoVdOnTO>(); //AV-530 FIX-02
        }
    }

    public class ContratoVdOnTO{
        public String numeroCpf                             {get;set;}
        public String numeroApolice                         {get;set;} 
        public String statusApolice                         {get;set;}
        public String tipoContrato                          {get;set;}
        
        public ContratoVdOnTO(Contract contrato){    
            this.numeroCpf = contrato.Account.Cpf__c.replace('.','').replace('-','');
            this.numeroApolice = contrato.Name == null ? null : contrato.Name;
            this.statusApolice = contrato.Status == null ? null : contrato.Status;
            this.tipoContrato = contrato.Tipo__c == null ? null : contrato.Tipo__c;
        }
    }

    public class ResponseHerokuGravarCPFVidaOn{        
        public String servico                               {get;set;}
        public String status                                {get;set;}  
        public Integer codigoprocessamento                  {get;set;}
        public String dataexecucao                          {get;set;}
        public String descricao                             {get;set;}
        public List<RequestHerokuGravarCPF> dados           {get;set;}
    }
}
//AV-530 FIX-01 FIM