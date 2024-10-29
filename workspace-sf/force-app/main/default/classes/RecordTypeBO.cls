public class RecordTypeBO {
	//PLV-4122 - INICIO - PEDRO AUGUSTO - SYS4B

	/**
	*  Busca um tipo de registro
	* @param - objeto: Nome do SObject que possuí o tipo de registro buscado
	* @param - developerName: nome (DeveloperName) do tipo de registro buscado
	*/
	public static RecordType buscarTipoRegistro(string objeto, string developerName) {
		RecordType tipoRegistro = new RecordType();
		if (String.isNotBlank(objeto) && String.isNotBlank(developerName)) {
			tipoRegistro.Id = Schema.getGlobalDescribe().get(objeto).getDescribe().getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
		}
		if(tipoRegistro == null){
			throw new RecordTypeException('Não foi encontrado o Record type ' + developerName + ' para o objeto ' + objeto);
		}
		return tipoRegistro;
	}
    
    
    /**
	*  Busca um tipo de registro
	* @param - objeto: Nome do SObject que possuí o tipo de registro buscado
	* @param - developerName: nome (DeveloperName) do tipo de registro buscado
	*/
    public static Map<String, RecordType> buscarTipoRegistro(String objeto) {
		Map<String, RecordType> mapRecordTypeCacheObj = null; 
		if (mapRecordTypeCacheObj == null) {
			mapRecordTypeCacheObj = new Map<String, RecordType>();

			for(RecordType rt : RecordTypeDAO.getInstance().listar()){
				mapRecordTypeCacheObj.put(rt.SobjectType + '|' +  rt.DeveloperName, rt);
			}
		}

		if(mapRecordTypeCacheObj.isEmpty()){
			throw new RecordTypeException('Não foi encontrado o Record type para o objeto ' + objeto);
		}

		return mapRecordTypeCacheObj;
	}

	//PLV-4122 - FIM - PEDRO AUGUSTO - SYS4B


	public class RecordTypeException extends Exception {	}
}