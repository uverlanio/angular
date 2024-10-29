/**************************************************************************************************************************************************************************
 * 
 *  Classe responsável pelas funcionalidades do componente de gerenciamento de territórios
 *
 **************************************************************************************************************************************************************************/
public class GerenciamentoTerritoriosController {
    public static final TerritorioBO objTerritorioBo = TerritorioBO.getInstance();

    /**
     * Realiza busca de map contendo a prefixos dos SObjects que podem ser pai de território
     *
     * @return  String - Lista contendo os paises serializados
     */
    @AuraEnabled
    public static String buscarPrefixosSObjects(){
        return JSON.serialize(objTerritorioBo.gerarMapPrefixoSobject());
    }

    /**
     * Busca os tipos de territorios
     *
     * @return String - Lista contendo os tipos serializados
     */
    @AuraEnabled
    public static String buscarTipos(){
        return JSON.serialize(objTerritorioBo.gerarListaOpcoesTipos());
    }

     /**
     * Busca continentes
     *
     * @return String - Lista contendo os continentes serializados
     */
    @AuraEnabled
    public static String buscarContinentes(){
        return JSON.serialize(objTerritorioBo.gerarListaOpcoesContinentes());
    }

    /**
     * Realiza as buscas dos paises
     *
     * @return  String - Lista contendo os paises serializados
     */
    @AuraEnabled
    public static String buscarTodosPaises(){
        return JSON.serialize(objTerritorioBo.gerarListaOpcoesPaises());    
    }

    /**
    * Busca os países de um continente
    *
    * @param   continentes  - string contendo os continentes
    * @return String - Lista contendo os paises serializados
    */
    @AuraEnabled
    public static String buscarPaises(String continentes){
        return JSON.serialize(objTerritorioBo.gerarListaOpcoesPaises(continentes));
    }

    /**
     * Busca estados
     *
     * @return String - Lista contendo os estados serializados
     */
    @AuraEnabled
    public static String buscarEstados(){
        return JSON.serialize(objTerritorioBo.gerarListaOpcoesEstados());
    }

    /**
    * Busca os municípios de uma estado
    *
    * @param   estados  - string contendo os estados
    * @return String - Lista contendo os paises serializados
    */
    @AuraEnabled
    public static String buscarMunicipios(String estados){
        return JSON.serialize(objTerritorioBo.gerarListaOpcoesMunicipios(estados));
    }

    /**
     * Realiza as buscas dos territorios das garantias de acordo com uma garantia de produto
     *
     * @param   garantiaProdutoId  - id de uma garantia de produto
     * @return  List<Territorio__c> - Lista contendo os territorios da garantia
     */
    @AuraEnabled
    public static List<Territorio__c> buscarTerritorios(Id sObjectPaiId, String nomeSObjectPai){
      return objTerritorioBo.buscarTerritorios(sObjectPaiId, nomeSObjectPai);
    }

    /**
     * Salva as informações de territorio passadas por parametro
     *
     * @param   territorios  - lista de Territorio__c para serem salvas
     */
      @AuraEnabled
    public static void salvarTerritorios (List<Territorio__c> territorios){
      objTerritorioBo.salvar((List<Territorio__c>)JSON.deserialize(JSON.serialize(territorios), List<Territorio__c>.class));
    }

    @AuraEnabled
    public static void excluir(Id territorioId){
        Territorio__c territorio = new Territorio__c(Id = territorioId);
        delete territorio;
    }
}