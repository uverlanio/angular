trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update, before delete) {
    List<AccountContactRelation_Event__e> AccountContactRelationEvents = New List<AccountContactRelation_Event__e>();
    String operation;
    if(Trigger.IsInsert || Trigger.IsUpdate){
            for(AccountContactRelation c:Trigger.new){        
            if(Trigger.IsInsert){operation = 'created';}        
            if(Trigger.IsUpdate){operation = 'updated';}
                AccountContactRelationEvents.add(new AccountContactRelation_Event__e(
                    AccountId__c                = c.AccountId,
                    ContactId__c                = c.ContactId,
                    EndDate__c                  = c.EndDate,
                    Id__c                       = c.Id,
                    Responsavel_financeiro__c   = c.Responsavel_financeiro__c,
                    StartDate__c                = c.StartDate,
                    Operation__c                = operation
                ));
        }
    }else if(Trigger.IsDelete){
        for(AccountContactRelation c:Trigger.old){
            AccountContactRelationEvents.add(new AccountContactRelation_Event__e(
                AccountId__c                = c.AccountId,
                ContactId__c                = c.ContactId,
                EndDate__c                  = c.EndDate,
                Id__c                       = c.Id,
                Responsavel_financeiro__c   = c.Responsavel_financeiro__c,
                StartDate__c                = c.StartDate,
                Operation__c                = 'deleted'
            ));
    	}
    }    
    if(AccountContactRelationEvents.size() > 0 ) EventBus.publish(AccountContactRelationEvents);
}