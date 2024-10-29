/********************************************************************************************************************
* Proposta de Seguro Viagem Controler
* @author Edgar Peralta - Globant
* @date 04/09/2020
* Classe criada por conta da história PLV-4345
*********************************************************************************************************************/
public with sharing class PropostaSeguroViagemController {
    public String nomeOpp											{get; set;}
    public List<Quote> Quote   										{get; set;}
    public List<FavorecidoRemuneracaoProposta__c> dadosCorrector	{get; set;}
    public Integer quoteSize										{get; set;}
    public Integer coberturasSize									{get; set;}
    public String periodoViagem                                     {get; set;}
    public List<seguradoProposta__c>  seguradoEndereco              {get; set;} //PLV - 4849 INICIO - FIM

    public PropostaSeguroViagemController(){
        this.nomeOpp = ApexPages.currentPage().getParameters().get('numProposta'); 
        this.Quote = getQuote(nomeOpp);    
        this.seguradoEndereco = getSeguradoEndereco(nomeOpp); //PLV - 4849 INICIO - FIM        
        if(Quote[0].Produto__r.Segmento__c != 'Viagem'){
            CalloutException e = new CalloutException();
            e.setMessage('Proposta informada não pertence ao segmento Viagem!');
            throw e;
        }
        quoteSize = Quote.size();
        coberturasSize = Quote[0].GarantiasProposta__r.size();
        this.dadosCorrector = getDadosCorrector(Quote[0].Id);
        this.periodoViagem = Quote[0].VigenciaInicial__c != null && Quote[0].VigenciaFinal__c !=null  ?  String.ValueOf(((this.Quote[0].VigenciaInicial__c).daysBetween(this.Quote[0].VigenciaFinal__c)+1)) +' dia(s)':''; 
    }
    private List<Quote> getQuote (String nomeOpp){
        return [SELECT ID, Name, ContactId, VigenciaFinal__c, VigenciaInicial__c, Origem__c, PaisesDestino__c,
                OpportunityId, DiasAnalise__c, FormaPagamento__r.Name, Account.Name, Account.BillingStreet, 
                Account.BillingPostalCode, Account.BillingCity, Account.BillingState, Account.BillingCountry,
                Account.Cpf__c, Account.Sexo__c, Account.PersonEmail, Account.PersonBirthdate, Account.Nacionalidade__c,
                Account.Pep__c, Account.Id, Opportunity.Numero__c, Produto__r.NumeroSusep__c, Produto__r.Name, Produto__r.Segmento__c,
                (SELECT ID, Name, Capital__c, CurrencyIsoCode, Garantia__r.name FROM GarantiasProposta__r) 
                FROM Quote 
                WHERE Name =: nomeOpp];
    }
    private List<FavorecidoRemuneracaoProposta__c> getDadosCorrector(String numeroOpp){
        return [SELECT conta__c, SusepOficialCorretor__c, Susep__c, conta__r.Phone, conta__r.Name, conta__r.Email__c
                FROM FavorecidoRemuneracaoProposta__c
                WHERE RemuneracaoProposta__r.Proposta__c =: numeroOpp];
    }
    //PLV - 4849 INICIO
    private List<seguradoProposta__c> getSeguradoEndereco (String nomeOpp){
        return [SELECT UFResidencial__c, paisResidencial__c, numeroResidencial__c, logradouroResidencial__c, ComplementoResidencial__c, CidadeResidencial__c, cepResidencial__c, bairroResidencial__c
                FROM seguradoProposta__c 
                WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__r.Name =: nomeOpp ];
    }
    //PLV - 4849 FIM
}