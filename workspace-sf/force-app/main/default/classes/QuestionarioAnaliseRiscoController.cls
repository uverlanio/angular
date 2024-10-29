/**
 * Created by Alessndro Ponte on 19/06/2018.
 */

public with sharing class QuestionarioAnaliseRiscoController {

  private static QuoteBO bo = QuoteBO.getInstance();

  public class WrapperQuestionario{

    public Id questionarioId;
    public list<PerguntaQuestionario__c> listPerguntaQuestionario;
    public String siglaGarantia;
    public Decimal limiteCapitalMinimo;
    public Decimal limiteCapitalMaximo;
  }

  @AuraEnabled
  public static List<sobject> buscarListVidaProposta(Id quoteId){
    return bo.buscarListVidaProposta(quoteId);   
  }
  

  @AuraEnabled
  public static String buscarPerguntas(Id quoteId){
    return JSON.serialize(bo.buscarPerguntasQuestionario(quoteId));
  }

  @AuraEnabled
  public static List<RespostaQuestionario__c> salvarRespostaQuestionario(List<RespostaQuestionario__c> listRespostas){
    String listRespostaString = JSON.serialize(listRespostas);
    List<RespostaQuestionario__c> listRespostaQuestionario = (List<RespostaQuestionario__c>) JSON.deserialize(listRespostaString,List<RespostaQuestionario__c>.class);
    return bo.salvarRespostaQuestionario(listRespostaQuestionario);
  }


}