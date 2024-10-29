/*******************************************************************************************************************************
* 
* @author Pedro Augusto - SYS4B
* @date 27/07/2020
* @modifiedAt 
* Classe criada por conta da história PLV-4122
********************************************************************************************************************************/

public with sharing class BotaoReabrirSinistroController {


    public static Map<String, String> getMapPicklist(String Objeto, String Campo) {

		Map<String, String> mapValuesPickList = new Map<String, String> ();

        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(Objeto);

		if (targetType != null) {
			sObject sobj = targetType.newSObject();

			Schema.DescribeSObjectResult describeSObjectResult = sobj.getSObjectType().getDescribe();
			Map<String, Schema.SObjectField> fields = describeSObjectResult.fields.getMap();

			Schema.SObjectField fld = fields.get(Campo);

			if (fld != null) {

				if (fld.getDescribe().getType().equals(Schema.DisplayType.PICKLIST) || fld.getDescribe().getType().equals(Schema.DisplayType.MULTIPICKLIST)) {

					Schema.DescribeFieldResult fieldResult = fld.getDescribe();
					List<Schema.PicklistEntry> listPickListEntry = fieldResult.getPicklistValues();

					for (Schema.PicklistEntry pickListVal : listPickListEntry) {
						mapValuesPickList.put(pickListVal.getValue(), pickListVal.getLabel());
					}

					return mapValuesPickList;
				}
			}
		}

		return mapValuesPickList;
    }

    public class innerPicklist{
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String label {get;set;}
    }

    @AuraEnabled
    public static Map<String,Object> buscarInformacoes(String recordId){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        String perfilAtual = [SELECT Id,Name FROM Profile WHERE Id=:Userinfo.getProfileId()].Name;
        Case caso = [SELECT Id, Status, Sinistro_Judicial__c FROM Case WHERE Id=:recordId];
        System.debug('Status: '+ caso.Status);
        Boolean visible = caso.Status=='Fechado'?true:false;
        mapToReturn.put('visible', visible);
        
        
        List<innerPicklist> motivosToReturn = new List<innerPicklist>();
        List<innerPicklist> tiposContagemToReturn = new List<innerPicklist>();

        //Busca todos os motivos de acordo com o picklist   
        Map<String,String> motivos = getMapPicklist('Case','MotivosReabertura__c');
        for(String key : motivos.keyset()){
            innerPicklist entry = new innerPicklist();
            entry.value = key;
            entry.label = motivos.get(key);
            motivosToReturn.add(entry);
        }
        mapToReturn.put('motivosReabertura',motivosToReturn);

        Map<String,String> contagem = getMapPicklist('Case','TipoContagem__c');
        for(String key : contagem.keyset()){
            innerPicklist entry = new innerPicklist();
            entry.value = key;
            entry.label = contagem.get(key);
            tiposContagemToReturn.add(entry);
        }
        mapToReturn.put('listTipoContagem',tiposContagemToReturn);
        

        List<String> getCanReabrir = getCanReabrir();
        if(getCanReabrir.contains(perfilAtual)){
            //perfil pode reabrir
            Boolean judicial = caso.Sinistro_Judicial__c;
            
            List<String> getCanReabrirJuridico = getCanReabrirJuridico();

            if(judicial && getCanReabrirJuridico.contains(perfilAtual)){
                mapToReturn.put('canReopen',true);
            }else if(judicial && !getCanReabrirJuridico.contains(perfilAtual)){
                mapToReturn.put('canReopen',false);
            }else{
                mapToReturn.put('canReopen',true);
            }
        }else{
                mapToReturn.put('canReopen',false);
        }        

        
        return mapToReturn;
    }

    
    @AuraEnabled
    public static Map<String,Object> reabrirSinistro(String recordId, String motivo,String TipoContagem, String observacao){
        Map<String,Object> mapToReturn = new Map<String,Object>();

        Case casoToUpdate = new Case();
        casoToUpdate.Id = recordId;
        casoToUpdate.Status = 'Em Regulação';
        casoToUpdate.Status_Dependente__c = 'Avisado';
        casoToUpdate.MotivosReabertura__c = motivo;
        casoToUpdate.DataReabertura__c = System.now();
        casoToUpdate.ConsideracoesReabertura__c = observacao;
        casoToUpdate.TipoContagem__c = TipoContagem;

        //FIX 5415674 - Reabertura de sinistro - INICIO
        List<PagamentoGarantia__c> listGarantias = [SELECT Id
                                                        , Name
                                                        , Capital__c
                                                        FROM PagamentoGarantia__c
                                                        WHERE Caso__c=:recordId 
                                                        AND Fase__c ='Fechado'
                                                        AND (Status_do_pagamento__c='Cancelado' OR Status_do_pagamento__c='Recusado')];

        List<MovimentoSinistro__c> listMovimentoToCreate = null;
        
        if(!listGarantias.isEmpty()){
            Integer iteradorMovimento = 0;  //PLV-5852 INICIO/FIM
            listMovimentoToCreate = new List<MovimentoSinistro__c>();
            for (PagamentoGarantia__c pg : listGarantias) {
                MovimentoSinistro__c tocreate = criarMovimentoReabertura(recordId, pg.Id, pg.Capital__c, iteradorMovimento); //PLV-5852 INICIO/FIM
                listMovimentoToCreate.add(tocreate);

                pg.Fase__c ='Aberto';
                pg.Status_do_pagamento__c= 'Em Análise';
                iteradorMovimento = iteradorMovimento + 1; //PLV-5852 INICIO/FIM
            }
        }
        //FIX 5415674 - Reabertura de sinistro - FIM

		Savepoint sp = Database.setSavepoint();

        try {

            update casoToUpdate;
            
            if(listMovimentoToCreate!=null){
                insert listMovimentoToCreate;
                update listGarantias;
            }

            mapToReturn.put('sucesso', true);   

        } catch (Exception e) {
    	    Database.rollback(sp);
            System.debug('Erro ao atualizar o caso'+ e.getLineNumber() + ' - '+e.getMessage());           
            mapToReturn.put('sucesso', false);         
            mapToReturn.put('mensagem', 'Erro ao atualizar o caso '+ e.getLineNumber() + ' - '+e.getMessage());  
            return mapToReturn;       
        }

        return mapToReturn;
    }

    
    //FIX 5415674 - Reabertura de sinistro - INICIO
    public static MovimentoSinistro__c criarMovimentoReabertura(String caseId, String garantiaId, Decimal valor, Integer iteradorMovimento){ //PLV-5852 INICIO/FIM
        Map<Id, Integer> mSequenciaMov = SequenciaMovimentoSinistroHelper.sequenciaMovimentos(new Set<Id>{caseId});
		PagamentoGarantiaBO pgbo= new PagamentoGarantiaBO();
		Integer movimento = pgbo.getSequencia(mSequenciaMov, caseId) + iteradorMovimento; //PLV-5852 INICIO/FIM		

        MovimentoSinistro__c movimentoToCreate = new MovimentoSinistro__c();
        movimentoToCreate.DescricaoMovimento__c = '25'; // obrigatório para reabrir o caso
        movimentoToCreate.Caso__c=caseId;
        movimentoToCreate.DataMovimento__c=System.now();
        movimentoToCreate.ValorMovimento__c = valor;
		movimentoToCreate.SequenciaMovimento__c = String.valueOf(movimento);
        movimentoToCreate.PagamentoGarantia__c=garantiaId;
        movimentoToCreate.TipoMovimento__c='Aviso';
        return movimentoToCreate;
    }
    //FIX 5415674 - Reabertura de sinistro - FIM

	public static List<String> getCanReabrir(){
		//LISTAR AQUI TODOS OS PERFIS QUE PODEM REABRIR SINISTROS
		List<String> permitidos = new List<String>();
		permitidos.add('Administrador Porto');
		permitidos.add('Administrador do sistema');
		permitidos.add('System Administrator');
		permitidos.add('Jurídico');
		permitidos.add('API');
		permitidos.add('Processos e Projetos');
		permitidos.add('Sinistro e Benefícios');


		return permitidos;
    }
    
	public static List<String> getCanReabrirJuridico(){
		//PERFIS QUE PODEM REABRIR CASOS JURÍDICOS
		List<String> permitidos = new List<String>();
		permitidos.add('Administrador Porto');
		permitidos.add('Administrador do sistema');
        permitidos.add('System Administrator');
        permitidos.add('Jurídico');

		
		return permitidos;
	}
}