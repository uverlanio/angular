/***
* Created: Jeferson Santana (Sys4b)
* Date: 2024-08
* Description: class responsible for testing: BatchCreateFileReportMegaDayTest 
* task-History : LECVPV-218
***/ 
public with sharing class BatchPep implements Queueable, Database.AllowsCallouts {
    public Map<String,PepTo.DataObjects> mapObj;
	public Boolean processPep = false;

    
    public BatchPep(Map<String,PepTo.DataObjects> mapObj, Boolean processPep) {
        this.mapObj = mapObj;
		this.processPep = processPep;
    }

    
    public void execute(QueueableContext context) {
          if(this.processPep){
			String body = null;
			List<PepTO> listPepTo = new List<PepTO>();
			for(String str : this.mapObj.keySet()){

				List<Object> params = new List<Object>{str};
				String url = SensediaServices.PEP_CPF;
				//String.format(url, params)
				SensediaServices.getInstance().params = params;
				String retorno = SensediaServices.getInstance().montagemServicoSensedia(SensediaServices.VERB.POST, SensediaServices.DOMAIN.ON_PREMISES_EXTERNO, SensediaServices.PEP_CPF, body);
				
				if(retorno != 'Erro na requisição'){
						//PepTO dataPepTo = this.mockResponseService();
						PepTO dataPepTo = (PepTO) System.JSON.deserialize(retorno, PepTo.class);							
						PepTO.DataObjects dataobj = new PepTO.DataObjects();
						dataobj.cpf = this.mapObj.get(str).cpf;
						dataobj.id = this.mapObj.get(str).id;
						dataobj.nomeAccount = this.mapObj.get(str).nomeAccount;
						dataobj.nomeObject = this.mapObj.get(str).nomeObject;
						dataobj.accountId = this.mapObj.get(str).accountId;
						dataPepTo.dadosObjeto = dataobj;
						listPepTo.add(dataPepTo);
				}
			}
			//System.debug('###listPepTo'+listPepTo);
			if(listPepTo.size() > 0) PepBO.createPepObjeto(listPepTo);
		  }
		  
    }
}