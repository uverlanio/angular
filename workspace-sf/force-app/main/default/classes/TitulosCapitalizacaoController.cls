/**
 * Created by Alessandro Ponte on 14/12/2018.
 */

public with sharing class TitulosCapitalizacaoController {

  public static ParceiroBO boParceiro = ParceiroBO.getInstance();
  public static ContractBO bo = ContractBO.getInstance();

  @AuraEnabled
  public static List<Parceiro__c> buscarTodosParceiros(){
    return boParceiro.buscarTodosParceiros();
  }

  @AuraEnabled
  public static String gerarNumeroProposta(String solicitarTituloTOString){
    ContratoTO.SolicitarTituloTO solicitarTituloTO = (ContratoTO.SolicitarTituloTO)JSON.deserialize(solicitarTituloTOString,ContratoTO.SolicitarTituloTO.class);

    try{
      return bo.gerarNumeroPropostaCapitalizacao(solicitarTituloTO);
    }catch (Exception e){
      System.debug('Exception capturada para o componente ' + e.getMessage());
//      ExcecaoCustomizada excecaoCustomizada = new ExcecaoCustomizada('Erro ao gerar número proposta', e.getMessage(), 400);
      System.debug('e.getMessage() ----------------------- ' + e.getMessage());

      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String consultarEstoque(String consultarEstoqueTOString){
    ContratoTO.ConsultarEstoqueTO consultarEstoqueTO = (ContratoTO.ConsultarEstoqueTO ) JSON.deserialize( consultarEstoqueTOString, ContratoTO.ConsultarEstoqueTO.class );
    return JSON.serialize(bo.consultarEstoque(consultarEstoqueTO));
  }

}