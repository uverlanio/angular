trigger FavorecidoRemuneracaoContratoTrigger on FavorecidoRemuneracaoContrato__c (after insert, after update, before delete) {
	List<FavorecidoRemuneracaoContrato_Event__e> FavorecidoRemuneracaoContratoEvents = New List<FavorecidoRemuneracaoContrato_Event__e>();
    String operation;
    if(Trigger.IsInsert || Trigger.IsUpdate){
        for(FavorecidoRemuneracaoContrato__c c:Trigger.new){        
            if(Trigger.IsInsert){operation = 'created';}        
            if(Trigger.IsUpdate){operation = 'updated';}    
            FavorecidoRemuneracaoContratoEvents.add(new FavorecidoRemuneracaoContrato_Event__e(
                Conta__c                  = c.Conta__c,
                CorretorLider__c          = c.CorretorLider__c,
                DadosCorretor__c          = c.DadosCorretor__c,
                Id__c                     = c.Id,
                Name__c                   = c.Name,
                Papel__c                  = c.Papel__c,
                Participacao__c           = c.Participacao__c,
                RemuneracaoContrato__c    = c.RemuneracaoContrato__c,
                SusepEmissao__c           = c.SusepEmissao__c,
                SusepOficialCorretor__c   = c.SusepOficialCorretor__c,
                SusepOrcamento__c         = c.SusepOrcamento__c,
                Susep__c                  = c.Susep__c,
                Operation__c              = operation
            ));
    	}
    }
    else if(Trigger.IsDelete){
        for(FavorecidoRemuneracaoContrato__c c:Trigger.old){
            FavorecidoRemuneracaoContratoEvents.add(new FavorecidoRemuneracaoContrato_Event__e(
                Conta__c                  = c.Conta__c,
                CorretorLider__c          = c.CorretorLider__c,
                DadosCorretor__c          = c.DadosCorretor__c,
                Id__c                     = c.Id,
                Name__c                   = c.Name,
                Papel__c                  = c.Papel__c,
                Participacao__c           = c.Participacao__c,
                RemuneracaoContrato__c    = c.RemuneracaoContrato__c,
                SusepEmissao__c           = c.SusepEmissao__c,
                SusepOficialCorretor__c   = c.SusepOficialCorretor__c,
                SusepOrcamento__c         = c.SusepOrcamento__c,
                Susep__c                  = c.Susep__c,
                Operation__c              = 'deleted'
            ));
    	}
    }
    if(FavorecidoRemuneracaoContratoEvents.size() > 0 ) EventBus.publish(FavorecidoRemuneracaoContratoEvents);
}