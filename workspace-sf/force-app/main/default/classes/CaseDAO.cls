public virtual class CaseDAO {

	private static final CaseDAO instancia = new CaseDAO();
	private CaseDAO() { }

	public static CaseDAO getInstance(){
		return instancia;
	}

	public List<Case> buscarCasoPorId(Set<id> ids){
		return [
			SELECT
				Id,
				Account.PersonEmail,
				Account.Email__c,
				Contact.Email
			FROM
				Case
			WHERE
				Id IN :ids
		];
	}

	// POR062-1 - INICIO
	public List<Case> buscarPorNumeroDoSinistro(Set<String> numeroSinistro) {
		List<Case> casoLista = [
			SELECT
				Id, NumeroApoliceFormula__c, Contrato__c, Status, Status_Dependente__c, Sinistro_Judicial__c,
				Segurado_do_contrato__r.Conta__r.Name, Segurado_do_contrato__r.Conta__r.CPF__c, Contrato__r.Sucursal__c,
				Contrato__r.CodigoRamo__c, Contrato__r.CodigoModalidade__c, Contrato__r.NumeroApolice__c, Contrato__r.Endosso__c,
				Contrato__r.TipoEndosso__c, Contrato__r.StartDate, Contrato__r.VigenciaFinal__c, Contrato__r.EndDate,
				Contrato__r.CodigoCorretor__c, Contrato__r.CodigoCorretor__r.NomeCorretor__r.Name, Contrato__r.CodigoCorretor__r.NomeCorretor__r.Phone,
				Contrato__r.CodigoCorretor__r.NomeCorretor__r.CodigoSusepCorretor__c, Contrato__r.RamoSeguro__r.GrupoRamoSinistro__c, Motivos_de_recusa__c,
				RamoSplit__c, NumeroSinistro__c, NumeroSinistroSplit__c, AnoSinistroSplit__c, Contrato__r.ModalidadeSeguro__r.RamoSeguro__c, Data_sinistro_avisado__c
			FROM Case
			WHERE NumeroSinistro__c IN :NumeroSinistro
            ORDER By ID
		];
		return casoLista;
	}
	// POR062-1 - FIM
}