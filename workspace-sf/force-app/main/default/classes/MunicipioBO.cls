/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de Municipio
 *
 **************************************************************************************************************************************************************************/
public  class MunicipioBO {
	private static final MunicipioBO instancia = new MunicipioBO();
	private static final MunicipioDAO dao = MunicipioDAO.getInstance();

	private MunicipioBO() {	
	}

	public static MunicipioBO getInstance(){
		return instancia;
	}

	/**
	 * Realiza a busca de municipios via serviço externo, e atualiza Salesforce
	 *
	 */
	public void sincronizarDadosMunicipio(){
		List<Schema.PicklistEntry> estados = Municipio__c.Uf__c.getDescribe().getPicklistValues();
		List<Municipio__c> municipioSincronizar = new List<Municipio__c>();

		for(Schema.PicklistEntry estado : estados){
			String uf = estado.getValue();
		
			for(ServiceTO.MunicipioTO municipio : F5Service.getInstance().buscarMunicipios(uf)){
				municipioSincronizar.add(
					new Municipio__c(
						IdExterno__c = uf + '_' + municipio.codigoCidade,
						Name = municipio.nomeCidade,
						Uf__c = municipio.unidadeFederativaCodigo
					)
				);
			}
		}

		if(!municipioSincronizar.isEmpty()){
			upsert municipioSincronizar IdExterno__c;
		}
	}

	/**
	 * Realiza a busca de municipios no Salesforce e retorna
	 *
	 */
	public List<Municipio__c> buscarMunicipiosPorEstados(Set<String> setEstados){
		return dao.buscarMunicipiosPorEstados(setEstados);
	}
}