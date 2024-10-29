public class CriticaOrcamentoBO {
	private static final CriticaOrcamentoBO instancia = new CriticaOrcamentoBO();
	public CriticaOrcamentoBO() {}

	public static CriticaOrcamentoBO getInstance(){
		return instancia;
	}

	public void atualizarOportunidade(List<CriticaOrcamento__c> criticas){
        //AVX - PLV2608 - INÍCIO - Criação do workflow de orçamento
		//Group filaAnaliseMedica = QueueDAO.getInstance().buscarFilaPorNome('AnaliseMedica');
		//AVX - PLV2608 - FIM - Criação do workflow de orçamento
		Set<Id> idsOportunidade = new Set<Id>();
		Integer qtdeCriticasLiberadas = 0;
        
		for(CriticaOrcamento__c critica : criticas){
			idsOportunidade.add(critica.Orcamento__c);
		}

		List<Opportunity> oportunidades = OpportunityDAO.getInstance().buscarOportunidadesPorId(idsOportunidade);
		List<Opportunity> oportunidadesAtualizadas = new List<Opportunity>();

        //AVX - PLV2608 - INÍCIO - Criação do workflow de orçamento
		//List<Roteamento__c> roteamentos = new List<Roteamento__c>();
		//AVX - PLV2608 - FIM - Criação do workflow de orçamento
        
		for(Opportunity oportunidade : oportunidades){
		//AVX - PLV2608 - INÍCIO - Criação do workflow de orçamento
            //Integer qtdeCriticasLiberadas = 0;
			//Boolean enviarAreaMedica = false;
		//AVX - PLV2608 - FIM - Criação do workflow de orçamento
            System.debug('oportunidade.CriticaOrcamentos__r: ' + oportunidade.CriticaOrcamentos__r);
			for(CriticaOrcamento__c critica : oportunidade.CriticaOrcamentos__r){                
		//AVX - PLV2608 - INÍCIO - Criação do workflow de orçamento
            //	if (critica.Area__c == 'MED') {
			//		enviarAreaMedica = true;
			//	}
		//AVX - PLV2608 - FIM - Criação do workflow de orçamento
                
				if(critica.Status__c == 'Recusado'){
					oportunidade.StageName = 'Recusado';
					oportunidadesAtualizadas.add(oportunidade);
					break;
				}
				else if(critica.Status__c == 'Liberado'){
					qtdeCriticasLiberadas++;
				}
			}

			if(qtdeCriticasLiberadas == oportunidade.CriticaOrcamentos__r.size()){
				oportunidade.StageName = 'Disponível para contratação';
		//AVX - PLV2608 - INÍCIO - Criação do workflow de orçamento
             /*	if (enviarAreaMedica) {
					Roteamento__c rota = new Roteamento__c();
					rota.Orcamento__c = oportunidade.Id;
					rota.IdExterno__c = oportunidade.Id;
					rota.OwnerId = filaAnaliseMedica.Id;
					roteamentos.add(rota);
				}
			*/
				oportunidadesAtualizadas.add(oportunidade);
			}
			//PLV-4944 - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
			if(Test.isRunningTest()){
				update oportunidadesAtualizadas;
			}else{
				Util.sObjectActionCIVasync('update', JSON.serialize(oportunidadesAtualizadas), true, true, null,false);
			}
			//PLV-4944 - FIM - PEDRO AUGUSTO BRAZ - SYS4B     
		}
    
		//upsert roteamentos IdExterno__c;
		//update oportunidadesAtualizadas; 
		//
	//AVX - PLV2608 - FIM - Criação do workflow de orçamento		
    }
        
    //AVX - PLV2608 - INÍCIO - Criação do workflow de orçamento
    
    //O método abaixo foi comentado porque o relacionamento entre os objetos "Opportunity" e "Crítica do orçamento" 
    //foi alterado de Mestre e Detalhes para Pesquisa. Com isso o objeto "Roteamento" não será utilizado.
	
    /*public void enviarOrcamentoAreaTecnica(List<CriticaOrcamento__c> criticas) {
		Group filaAnaliseTecnica = QueueDAO.getInstance().buscarFilaPorNome('AnaliseTecnica');
		Set<Id> idsOportunidade = new Set<Id>();

		for(CriticaOrcamento__c critica : criticas){
			idsOportunidade.add(critica.Orcamento__c);
		}

		List<Opportunity> oportunidades = OpportunityDAO.getInstance().buscarOportunidadesPorId(idsOportunidade);
		List<Roteamento__c> roteamentos = new List<Roteamento__c>();

		for(Opportunity oportunidade : oportunidades){
			Roteamento__c rota = new Roteamento__c();
			rota.Orcamento__c = oportunidade.Id;
			rota.IdExterno__c = oportunidade.Id;
			rota.OwnerId = filaAnaliseTecnica.Id;
			roteamentos.add(rota);
		}

		upsert roteamentos IdExterno__c;
	}
	*/
    
    public void atribuiProprietarioCriticaOrcamento(List<CriticaOrcamento__c> criticasOrcamento){
        
        MAP<String,QueueSobject> mapFilas = new MAP<String,QueueSobject>();
        
        List<QueueSobject> listaFilas = [SELECT QueueId, Queue.developerName
                                 		 FROM QueueSobject
                                         WHERE Queue.developerName IN('FilaCoordenadorOrcamento','FilaMedicaOrcamento','FilaTecnicaOrcamento')
                                         ORDER BY Queue.developerName];  
        
        if(listaFilas.isEmpty()) return;
            
        for(QueueSObject sObj : listaFilas){
    		mapFilas.put(sObj.Queue.developerName, sObj);
    	}

    	for(CriticaOrcamento__c critica : criticasOrcamento){
    		if(critica.Tipo__c == 'Análise' || critica.Tipo__c == 'Pendência'){

    			if(critica.Area__c == 'MED'){
    				System.debug('Dentro do IF : FilaMedica - Orcamento == MED');
    				critica.OwnerId = mapFilas.get('FilaMedicaOrcamento').QueueID;
    			}
    			if(critica.Area__c != 'MED' && critica.Severidade__c == 1) {
    				System.debug('Dentro do IF: FilaTecnica - Orcamento Severidade 1');
    				critica.OwnerId = mapFilas.get('FilaTecnicaOrcamento').QueueID;
    			}
    			if(critica.Area__c != 'MED' && critica.Severidade__c > 1) {
    				System.debug('Dentro do IF: FilaCoordenacao - Orcamento Severidade > 1');
    				critica.OwnerId = mapFilas.get('FilaCoordenadorOrcamento').QueueID;
    			}		
    		}
    	}	
    } 
    
    public void iniciaProcessoAprovacaoCriticaOrcamento(List<CriticaOrcamento__c> criticasOrcamento){
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();

    	for (CriticaOrcamento__c critica : criticasOrcamento){
    		if(critica.Tipo__c == 'Análise' || critica.Tipo__c == 'Pendência'){
    			if(critica.Area__c == 'MED'){
    				//req1.setComments('Encaminhando requisição para aprovação');
    				req1.setObjectId(critica.id);
                    Approval.ProcessResult result = Approval.process(req1);
    				System.debug('ProcessResult1 : ' + result);
    				}else if(critica.Severidade__c == 1){
    					req1.setComments('Encaminhando requisição para aprovação');
    					req1.setObjectId(critica.id);
    					Approval.ProcessResult result2 = Approval.process(req1);
    					System.debug('ProcessResult2 : ' + result2);
    					}else if(critica.Severidade__c > 1){
    						req1.setComments('Encaminhando requisição para aprovação');
    						req1.setObjectId(critica.id);
    						Approval.ProcessResult result3 = Approval.process(req1);
    						System.debug('ProcessResult3 : ' + result3);
    					}
    		}
    	}
    } 
    
    //AVX - PLV2608 - FIM - Criação do workflow de orçamento
}