trigger TipoRemuneracaoTrigger on TipoRemuneracao__c (after insert, after update, before delete) {
    List<TipoRemuneracao_Event__e> TipoRemuneracaoEvents = New List<TipoRemuneracao_Event__e>();
    String operation;
    if(Trigger.IsInsert || Trigger.IsUpdate){
        for(TipoRemuneracao__c c:Trigger.new){        
            if(Trigger.IsInsert){operation = 'created';}        
            if(Trigger.IsUpdate){operation = 'updated';}
            TipoRemuneracaoEvents.add(new TipoRemuneracao_Event__e(
                Codigo__c            = c.Codigo__c,
                Descricao__c         = c.Descricao__c,
                Id__c                = c.Id,
                LimiteMaximo__c		 = c.LimiteMaximo__c,
                LimiteMinimo__c		 = c.LimiteMinimo__c,
                ModeloRecuperacao__c = c.ModeloRecuperacao__c,
                Name__c              = c.Name,
                Operation__c		 = operation
            ));
        }
    }
    else if(Trigger.IsDelete){
        for(TipoRemuneracao__c c:Trigger.old){        
            TipoRemuneracaoEvents.add(new TipoRemuneracao_Event__e(
                Codigo__c            = c.Codigo__c,
                Descricao__c         = c.Descricao__c,
                Id__c                = c.Id,
                LimiteMaximo__c		 = c.LimiteMaximo__c,
                LimiteMinimo__c		 = c.LimiteMinimo__c,
                ModeloRecuperacao__c = c.ModeloRecuperacao__c,
                Name__c              = c.Name,
                Operation__c		 = 'deleted'
            ));
        }
    }
    
    if(TipoRemuneracaoEvents.size() > 0 ) EventBus.publish(TipoRemuneracaoEvents);
}