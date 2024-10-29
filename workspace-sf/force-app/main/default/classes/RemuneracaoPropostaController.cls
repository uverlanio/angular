/**
 * Created by Alessandro Ponte on 11/07/2018.
 */

public class RemuneracaoPropostaController {
  private static QuoteBO bo = QuoteBO.getInstance();

  @AuraEnabled
  public static List<RemuneracaoProposta__c> buscarRemuneracaoProposta (Id quoteId){
    return bo.buscarRemuneracaoProposta(quoteId);
  }

  @AuraEnabled
  public static List<Opportunity> buscarRemuneracaoOrcamentoNoOrcamento (Id quoteId){
    return bo.buscarRemuneracaoOrcamentoNoOrcamento(quoteId);
  }

  @AuraEnabled
  public static String salvarRemuneracaoProposta (List<RemuneracaoProposta__c> listRemuneracaoProposta, List<RemuneracaoProposta__c> listaRemuneracaoPropostaParaApagar){
    // Cast na lista para upsert
    String listRemuneracaoString = JSON.serialize(listRemuneracaoProposta);
    listRemuneracaoProposta = (List<RemuneracaoProposta__c>) JSON.deserialize(listRemuneracaoString, List<RemuneracaoProposta__c>.class);
    return bo.salvarRemuneracaoProposta(listRemuneracaoProposta, listaRemuneracaoPropostaParaApagar);
  }

}