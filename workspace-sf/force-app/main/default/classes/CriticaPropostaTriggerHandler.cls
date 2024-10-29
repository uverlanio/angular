public class CriticaPropostaTriggerHandler extends TriggerHandler {
		public static Boolean isFirstTime = true;//PLV-4449-VI - INICIO/FIM - PEDRO AUGUSTO BRAZ - SYS4B
		CriticaPropostaBO bo = CriticaPropostaBO.getInstance(); //PLV-4591 - INICIO/FIM

    		//exemplo de instância 
    		//private static XXXBO objBO = XXXBO.getInstance();

    	//private static CriticaPropostaBO bo = CriticaPropostaBO.getInstance();

    	public override void beforeInsert(){
			//PLV-4517 INICIO 
			/*
			CriticaPropostaBO bo = CriticaPropostaBO.getInstance();     	
			bo.atribuiProprietarioCriticaProposta(trigger.new);
			*/
			//PLV-4517 FIM 
			
			CriticaPropostaAtribuicao.AtribuirFilasPrioritarias(Trigger.new);//VEP-141 - INICIO/FIM - PEDRO AUGUSTO BRAZ
			bo.updateProprietarioText(trigger.new, null); //PLV-4976 INICIO-FIM
   		}
    

		public override void afterInsert(){     
            //FCVEP-33 INICIO
            //bo.autorizarFormaDePagamento((Map<Id, CriticaProposta__c>)trigger.newMap, (Map<Id, CriticaProposta__c>)trigger.oldMap);
            //FCVEP-33 FIM
            
            //PLV-4494 INICIO
			//bo.iniciaProcessoAprovacaoCriticaProposta(trigger.new);
			//PLV-4494 FIM
			
			//PLV-4179 - INICIO
            //bo.salvarCriticaPropostaIntegracaoAS(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);-RVI-139
			//PLV-4179 - FIM

			//PLV-4365 - INICIO
			bo.integrarSampleMed(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
			//PLV-4365 - FIM
			
			//PLV-4977 - INICIO
			bo.gravarSegmentoNaProposta(trigger.new);
			//PLV-4977 - FIM
			
			
		}
		
		//PLV-4179 - INICIO
		public override void afterUpdate(){
			System.debug(LoggingLevel.ERROR,'afterUpdate - isFirstTime:'+isFirstTime);
			System.debug('XXX - AFTER UPDATE' + JSON.serialize(trigger.new));

			//bo.salvarCriticaPropostaIntegracaoAS(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);-RVI-139
			//PLV-4564-VI - INICIO - Codigo removido

			//PLV-4365 - INICIO
			bo.integrarSampleMed(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
			//PLV-4365 - FIM
			
            //PLV-4592 - INICIO
			//if(System.isFuture() == false){ //FNPVVEP-69 - INICIO/FIM
			System.debug('Caique1' );
			if(System.IsBatch() == false && System.isFuture() == false){ //FNPVVEP-69 - INICIO/FIM
				System.debug('Caique2: ' + System.JSON.serializePretty(trigger.new));
				bo.processarOrcamentoPorCritica(trigger.new, (Map<Id, CriticaProposta__c>) trigger.oldMap);
			
			//PLV-4592 - FIM
			//DataStatusProposta.AtualizaCampoDataFase(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
            //PLV-4495 - INICIO
            	CriticaPropostaStatus.automacaoCritica(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
            //PLV-4495 - FIM
			}//RVI-297 - INICIO / FIM
            //PLV-4790 FIX 6 INICIO
            CriticaPropostaStatus.cancelaCriticasRecusado(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
            //PLV-4790 FIX 6 FIM	
			
			//AV-796 - INICIO 
			CriticaPropostaStatus.atualizaCriticaPropostaHub(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
			//AV-796 - FIM

		}
		//PLV-4179 - FIM
	
		//PLV-4449-VI - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
		public override void beforeUpdate() {

			bo.atualizarDataInicioPendencia((Map<Id, CriticaProposta__c>)trigger.oldMap,trigger.new); // II-53 INICIO/FIM

			//PLV-5100 - INICIO
			if (!bo.validarLiberacaoPalavraFinal((Map<Id, CriticaProposta__c>)trigger.newMap)) {
				return;
			}
			//PLV-5100 - FIM

			//PLV-4619-VI - Inicio - Isabela Fin - Globant
			System.debug(LoggingLevel.ERROR,'isFirstTime:'+isFirstTime);
			if(isFirstTime){
				//PLV-4564-VI - INICIO - PEDRO AUGUSTO BRAZ - SYS4B
				bo.criarCriticaRecalculo((Map<Id, CriticaProposta__c>)trigger.newMap, (Map<Id, CriticaProposta__c>)trigger.oldMap);
				//PLV-4564-VI - FIM - PEDRO AUGUSTO BRAZ - SYS4B
				//FCVEP-33 INICIO
				bo.autorizarFormaDePagamento((Map<Id, CriticaProposta__c>)trigger.newMap, (Map<Id, CriticaProposta__c>)trigger.oldMap);
                //FCVEP-33 FIM
			}
			//PLV-4517 INICIO
			CriticaPropostaAtribuicao.AtribuirFilas(Trigger.new, (Map<Id, CriticaProposta__c>)Trigger.oldMap);
			//PLV-4517 FIM
			//PLV-4619-VI - Fim - Isabela Fin - Globant
			
            //PLV-4591 - INICIO
			bo.verificarStatusSLACritica(trigger.new, (Map<Id, CriticaProposta__c>) trigger.oldMap);
			//PLV-4591 - FIM
			//PLV-4872 - INICIO
			bo.gravaDataFimAnalise(trigger.new, (Map<Id, CriticaProposta__c>) trigger.oldMap);
			bo.gravaDataInicioResseguro(trigger.new, (Map<Id, CriticaProposta__c>) trigger.oldMap);
			bo.gravaDatafimResseguro(trigger.new, (Map<Id, CriticaProposta__c>) trigger.oldMap);
			bo.gravarDataRecusa(trigger.new);
			//PLV-4872 - FIM

			//PLV-5058 - INICIO
			if(isFirstTime){
				bo.updateProprietarioText(trigger.new, (Map<Id, CriticaProposta__c>) trigger.oldMap); //PLV-4976 INICIO-FIM
				bo.atualizaSetorCritica(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap); 
			} 
			//PLV-5058 - FIM
			
			//PLV-5077 - INICIO
			bo.distribuicaoCriticas(trigger.new, (Map<Id, CriticaProposta__c>)trigger.oldMap);
			//PLV-5077 - FIM	
		}
		//PLV-4449-VI - FIM - PEDRO AUGUSTO BRAZ - SYS4B

}