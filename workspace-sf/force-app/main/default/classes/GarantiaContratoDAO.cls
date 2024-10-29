/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pela busca de dados do objeto de GarantiaContrato__c
 *
 **************************************************************************************************************************************************************************/
public  class GarantiaContratoDAO {
	private static final GarantiaContratoDAO instancia = new GarantiaContratoDAO();

	private GarantiaContratoDAO() {	}

	public static GarantiaContratoDAO getInstance(){
		return instancia;
	}

	public List<GarantiaContrato__c> buscarGarantiasContratoPorContrato(List<String> contratos){
		return [
			Select id,
			contrato__r.Name
			from garantiacontrato__c
			Where contrato__r.name IN: contratos
		];
	}


}