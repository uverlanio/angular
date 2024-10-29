trigger CriticaContratoTrigger on CriticaContrato__c (after insert, after update, after delete) {
    List<CriticaContrato_Event__e> CriticaContratoEvents = New List<CriticaContrato_Event__e>();
    String operation;
    if(Trigger.IsInsert || Trigger.IsUpdate){
        for(CriticaContrato__c c:Trigger.new){        
            if(Trigger.IsInsert){operation = 'created';}        
            if(Trigger.IsUpdate){operation = 'updated';}
            CriticaContratoEvents.add(new CriticaContrato_Event__e(
                Area__c                  = c.Area__c,
                Codigo__c                = c.Codigo__c, 
                Contrato__c              = c.Contrato__c, 
                DataConclusao__c         = c.DataConclusao__c, 
                Descricao__c             = c.Descricao__c, 
                Id__c                    = c.Id, 
                // INICIO | PLV-4647-VI-Guilherme Brito
                MensagemCliente__c       = c.MensagemCliente__c, 
                MensagemInterna__c       = c.MensagemInterna__c, 
                MensagemRepresentante__c = c.MensagemRepresentante__c, 
                Procedimento__c          = c.Procedimento__c, 
                //FIM| PLV-4647-VI-Guilherme Brito */
                Name__c                  = c.Name, 
                Origem__c                = c.Origem__c, 
                Severidade__c            = c.Severidade__c, 
                Status__c                = c.Status__c, 
                Tipo__c                  = c.Tipo__c,
                Operation__c             = operation
            ));
        }
    }
    else if(Trigger.IsAfter && Trigger.IsDelete){
        for(CriticaContrato__c c:Trigger.old){
            CriticaContratoEvents.add(new CriticaContrato_Event__e(
                Area__c                  = c.Area__c,
                Codigo__c                = c.Codigo__c, 
                Contrato__c              = c.Contrato__c, 
                DataConclusao__c         = c.DataConclusao__c, 
                Descricao__c             = c.Descricao__c, 
                Id__c                    = c.Id, 
                // INICIO | PLV-4647-VI-Guilherme Brito
                MensagemCliente__c       = c.MensagemCliente__c, 
                MensagemInterna__c       = c.MensagemInterna__c, 
                MensagemRepresentante__c = c.MensagemRepresentante__c, 
                Procedimento__c          = c.Procedimento__c, 
                //FIM| PLV-4647-VI-Guilherme Brito */
                Name__c                  = c.Name, 
                Origem__c                = c.Origem__c, 
                Severidade__c            = c.Severidade__c, 
                Status__c                = c.Status__c, 
                Tipo__c                  = c.Tipo__c,
                Operation__c             = 'deleted'
            ));
        }
    }
    
    if(CriticaContratoEvents.size() > 0 ) EventBus.publish(CriticaContratoEvents);
}