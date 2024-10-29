/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável pelas funcionalidades do componente de dados do orçamento
 *  
 **************************************************************************************************************************************************************************/
public class ComplementoOrcamentoController {
  private static OpportunityBO objOportunidadeBo = OpportunityBO.getInstance();
  private static GarantiaProdutoBO objGarantiaProdutoBo = GarantiaProdutoBO.getInstance();


  /*********************************************************************************************************
  *
  * Busca uma oportunidade por ID e verifica se é possível realizar um update
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static Opportunity buscarOportunidade(Id oportunidadeId){
    Opportunity oportunidade = objOportunidadeBo.buscarOportunidade((Id)oportunidadeId);
//    Savepoint sp = Database.setSavepoint();

    //Verifica se é possível ainda editar a oportunidade, antes de permitir utiliza-lá no componente
//    try {
//      update oportunidade;
//
//    } catch(Exception e) {
//      oportunidade = null;
      //Database.rollback(sp); 

//    }

    return oportunidade;
  }
  
  /*********************************************************************************************************
  *
  * Busca os fields set criados para um produto especifico
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static String buscarFieldSetProduto(String codigoProduto, String objeto){
    return JSON.serialize(objOportunidadeBo.buscarFieldSetProduto(codigoProduto, objeto));
  }


  /*********************************************************************************************************
  *
  * Busca as garantias de um produto
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static List<GarantiaProduto__c> buscarGarantiasProdutos(String produtoId){
    return objGarantiaProdutoBo.buscarGarantiasProduto((Id)produtoId);
  }


  /*********************************************************************************************************
  *
  * Busca uma oportunidade por ID
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static List<ContratanteOrcamento__c> buscarContratantesOrcamento(Id oportunidadeId){
    return objOportunidadeBo.buscarContratantesOrcamento(oportunidadeId);
  }


  /*********************************************************************************************************
  *
  * Realiza update de uma oportunidade
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static Opportunity atualizaOportunidade(Opportunity oportunidade){
    return objOportunidadeBo.atualizaOportunidade(oportunidade);
  }


  /*********************************************************************************************************
  *
  * Realiza update de uma lista de Garantias do grupo de um orçamento
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static List<String> atualizarGarantiasDoGrupoDoOrcamento(List<sObject> listGarantiasGrupoOrcamento, Id oportunidadeId){
    System.debug('listGarantiasGrupoOrcamento ------------------------- ' + listGarantiasGrupoOrcamento);
    return objOportunidadeBo.atualizarGarantiasDoGrupoDoOrcamento(listGarantiasGrupoOrcamento, oportunidadeId);
  }

  
  /*********************************************************************************************************
  *
  * Retorna payload com toda a estrutura de um orçamento. TODO: MUDAR O NOME DESSE METODO. 
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static String buscarGarantiasOrcamento (Id oportunidadeId){
    return objOportunidadeBo.buscarGarantiasOrcamento(oportunidadeId);
  }


  /*********************************************************************************************************
  *
  * Salva apenas os dados da aba de garantias
  *
  *********************************************************************************************************/
  @AuraEnabled  
  public static void salvarDadosAbaGarantias(List<SObject> garantiasOrcamentoUpsert, List<SObject> garantiasOrcamentoDelete){

    // deserializa JSON
    List<SObject> listSObjects = (List<SObject>) JSON.deserialize(JSON.serialize(garantiasOrcamentoUpsert), List<SObject>.class);

    // recupera o SObjectType da GarantiaSeguradoOrcamento__c e GarantiaGrupoOrcamento__c
    Schema.SObjectType sObjectTypeGarantiaSeguradoOrcamento = Schema.GarantiaSeguradoOrcamento__c.getSObjectType();
    Schema.SObjectType sObjectTypeGarantiaGrupoOrcamento = Schema.GarantiaGrupoOrcamento__c.getSObjectType();

    // declara variaveis
    List<GarantiaGrupoOrcamento__c> listGarantiasGrupoOrcamentoUpsert = new List<GarantiaGrupoOrcamento__c>();
    List<GarantiaSeguradoOrcamento__c> listGarantiasSeguradoOrcamentoUpsert = new List<GarantiaSeguradoOrcamento__c>();

    // Itera os sobjects
    for(SObject sObj : listSObjects){

      if(sObj.getSObjectType() == sObjectTypeGarantiaSeguradoOrcamento){

        listGarantiasSeguradoOrcamentoUpsert.add( (GarantiaSeguradoOrcamento__c) sObj );

      }else if(sObj.getSObjectType() == sObjectTypeGarantiaGrupoOrcamento){

        listGarantiasGrupoOrcamentoUpsert.add( (GarantiaGrupoOrcamento__c) sObj );

      }

    }

    // upsert nas GarantiaGrupoOrcamento__c
    if(!listGarantiasGrupoOrcamentoUpsert.isEmpty()){
       Database.upsert((List<GarantiaGrupoOrcamento__c>)JSON.deserialize(JSON.serialize(listGarantiasGrupoOrcamentoUpsert), List<GarantiaGrupoOrcamento__c>.class), GarantiaGrupoOrcamento__c.Id, true);
    }

    // upsert nas GarantiaSeguradoOrcamento__c
    if(!listGarantiasSeguradoOrcamentoUpsert.isEmpty()){
      Database.upsert((List<GarantiaSeguradoOrcamento__c>)JSON.deserialize(JSON.serialize(listGarantiasSeguradoOrcamentoUpsert), List<GarantiaSeguradoOrcamento__c>.class), GarantiaSeguradoOrcamento__c.Id, true);
    }

    if(!garantiasOrcamentoDelete.isEmpty()){
     delete garantiasOrcamentoDelete;
    }
  }

  /*********************************************************************************************************
  *
  * Salva apenas os dados da aba de garantias
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static String validarCalcularOrcamento(Id orcamentoId){
    String mensagemErro;
    
    try {
      // Validar aqui as remuneracoes obrigatorias
      objOportunidadeBo.validarCalculoOrcamento(orcamentoId);
    } catch(Exception e) {
      mensagemErro = e.getMessage();
    }

    return mensagemErro;

  }


  /*********************************************************************************************************
  *
  * Salva apenas os dados da aba de garantias
  *
  *********************************************************************************************************/
  @AuraEnabled  
  public static String calcularOrcamento(Id oportunidadeId){
    String mensagemErro;

    try {
      objOportunidadeBo.calcularOrcamento(oportunidadeId);
    } catch(Exception e) {
      mensagemErro = e.getMessage();
    }

    return mensagemErro;
  }  
  

  /*********************************************************************************************************
  *
  * Retorna as garantias de um grupo
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static List<GarantiaGrupoOrcamento__c> buscarGarantiasGrupoOrcamento(Id grupoId){
    return objOportunidadeBo.buscarGarantiasGrupoOrcamento(grupoId);
  }

  /*********************************************************************************************************
  *
  * Retorna as garantias de um segurado
  *
  *********************************************************************************************************/
  @AuraEnabled
  public static List<GarantiaContratanteOrcamento__c> buscarGarantiasSeguradoOrcamento(Id seguradoId){
    return objOportunidadeBo.buscarGarantiasContratanteOrcamento(seguradoId);
  }

}