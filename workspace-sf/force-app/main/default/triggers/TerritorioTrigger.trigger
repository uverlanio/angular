trigger TerritorioTrigger on Territorio__c (after insert, after update, before delete) {
    List<Territorio_Event__e> TerritorioEvents = New List<Territorio_Event__e>();
    String operation;
    if(Trigger.IsInsert || Trigger.IsUpdate){
        for(Territorio__c c : Trigger.new){        
            if(Trigger.IsInsert){operation = 'created';}        
            if(Trigger.IsUpdate){operation = 'updated';}
            TerritorioEvents.add(new Territorio_Event__e(
                Continente__c            = c.Continente__c,
                Estado__c                = c.Estado__c,
                GarantiaProduto__c       = c.GarantiaProduto__c,
                Id__c                    = c.Id,
                Municipio__C             = c.Municipio__c,
                Name__c                  = c.Name,
                Pais__c                  = c.Pais__c,
                Produto__c               = c.Produto__c,
                Territorio__c            = c.Territorio__c,
                Tipo__c                  = c.Tipo__c,
                Operation__c             = operation
            ));
        }
    }else if(Trigger.IsDelete){
        for(Territorio__c c:Trigger.old){
            TerritorioEvents.add(new Territorio_Event__e(
                Continente__c            = c.Continente__c,
                Estado__c                = c.Estado__c,
                GarantiaProduto__c       = c.GarantiaProduto__c,
                Id__c                    = c.Id,
                Municipio__C             = c.Municipio__c,
                Name__c                  = c.Name,
                Pais__c                  = c.Pais__c,
                Produto__c               = c.Produto__c,
                Territorio__c            = c.Territorio__c,
                Tipo__c                  = c.Tipo__c,
                Operation__c             = 'deleted'
            ));
        }
    }    
    if(TerritorioEvents.size() > 0 ) EventBus.publish(TerritorioEvents);
}