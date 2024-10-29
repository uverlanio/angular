/**************************************************************************************************************************************************************************
 * 
 *	Classe responsável pelo negócio do objeto de Forma de pagamento
 *
 **************************************************************************************************************************************************************************/
public  class FormaPagametoBO {
	private static final FormaPagametoBO instancia = new FormaPagametoBO();
	private FormaPagamentoDAO dao = FormaPagamentoDAO.getInstance();

	private FormaPagametoBO() {	
	}

	public static FormaPagametoBO getInstance(){
		return instancia;
	}

	/**
	 * Realiza a busca de formas de pagamento via serviço externo, e atualiza Salesforce
	 *
	 */
	public void sincronizarFormasPagamento(){
		List<FormaPagamento__c> formasPagamentoSincronizar = new List<FormaPagamento__c>();
		Date dataAtual = System.today();
		String vigencia = String.valueOf(dataAtual.year()) + '-' + String.valueOf(dataAtual.month()) + '-' + String.valueOf(dataAtual.day());

		for(RamoSeguro__c ramo : RamoSeguroBO.getInstance().listarRamos()){	
			for(ServiceTO.FormaPagamentoTO formaPgto : F5Service.getInstance().buscarFormasPagamento(ramo.CodigoEmpresa__c, ramo.Codigo__c, vigencia) ) {
				formasPagamentoSincronizar.add(
					new FormaPagamento__c(
						Codigo__c = formaPgto.codigoPlanoParcelamento,
						Name = formaPgto.descricaoPlanoParcelamento,
						IdExterno__c = ramo.Id + '|' + formaPgto.codigoModalidade + '|' + formaPgto.codigoPlanoParcelamento
					)
				);
			}
		}

		if(!formasPagamentoSincronizar.isEmpty()){
			upsert formasPagamentoSincronizar IdExterno__c;
		}
	}

	//Retorna todas as formas de pagamento relacionado com um os ramos de seguro passador por parametro
	public List<FormaPagamento__c> buscarFormasPagamentoPorIds(Set<Id> idsFormaPagamento){
		return dao.buscarFormasPagamentoPorIds(idsFormaPagamento);
	}
}