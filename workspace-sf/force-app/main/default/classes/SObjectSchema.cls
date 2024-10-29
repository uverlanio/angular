/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável por prover informações de metadados dos objetos Salesforce
 *
 **************************************************************************************************************************************************************************/
public class SObjectSchema {

	/**
     * Retorna Schema de um objeto
     *
     * @param nomeSobject  - nome do objeto no qual se quer o Schema
     *
     * @return Schema.DescribeSobjectResult - Schema do objeto
     */
	public static Schema.DescribeSobjectResult recuperarMetadadoObjeto(String nomeSobject){
		return recuperarMetadadosObjetos(new List<String> {nomeSobject}).get(0);
	}

	/**
     * Retorna Schema de um objeto
     *
     * @param List<String>  - nomes do objetos nos quais se quer o Schema
     *
     * @return List<Schema.DescribeSobjectResult> - Schemas dos objetos
     */
	public static List<Schema.DescribeSobjectResult> recuperarMetadadosObjetos(List<String> nomesSobjects){
		return Schema.describeSObjects(nomesSobjects);					
	}

	/**
     * Retorna Schema dos campos de um objeto
     *
     * @param schemaObjeto  - Schema de um objeto nos quais se quer o schema dos campos
     *
     * @return Map<String, Schema.SObjectField> - Schemas dos campos
     */
	public static Map<String, Schema.SObjectField> recuperarCampos(Schema.DescribeSobjectResult schemaObjeto){
		return schemaObjeto.fields.getMap();
	}

	/**
     * Retorna lista contendo todos os campos editáveis de um objeto
     *
     * @param nomeSobject  - Nome do objeto no qual se quer os campos editaveis
     *
     * @return List<String> - lista com os campos
     */
	public static List<String> listarCamposEditaveis(String nomeSobject){
		List<String> camposEditaveis = new List<String>();
		Map<String, Schema.SObjectField> mapCampos = recuperarCampos(recuperarMetadadoObjeto(nomeSobject));

		for(String nomeCampo : mapCampos.keySet()){
			Schema.DescribeFieldResult campo = mapCampos.get(nomeCampo).getDescribe();

			//Verifica se o campo pode ser editado
			if(campo.isAccessible() && !campo.isAutoNumber() && campo.isCreateable()){
				camposEditaveis.add(nomeCampo);
			}
		}

		return camposEditaveis;
	}

     /**
     * Retorna lista contendo todos os campos de um objeto
     *
     * @param nomeSobject  - Nome do objeto no qual se quer os campos
     *
     * @return List<String> - lista com os campos
     */
     public static List<String> listarCampos(String nomeSobject){
          Map<String, Schema.SObjectField> mapCampos = recuperarCampos(recuperarMetadadoObjeto(nomeSobject));
          return new List<String>(mapCampos.keySet());
     }

	/**
     * Retorna Schema dos campos definidos de um objeto
     *
     * @param nomeSobject  - Nome do objeto a ter o fieldset buscado
     * @param nomeFieldSet - Nome do field set
     *
     * @return List<Schema.FieldSetMember> - Schemas dos campos do fieldset
     */
	public static List<Schema.FieldSetMember> recuperarCamposFieldSet(String nomeSobject, String nomeFieldSet){
		return recuperarMetadadoObjeto(nomeSobject).fieldSets.getMap().get(nomeFieldSet).getFields();
	}
}