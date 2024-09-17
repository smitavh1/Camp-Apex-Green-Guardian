trigger Garden_beforeInsertTrigger on CAMPX__Garden__c (before insert) {

     switch on Trigger.operationType {
        when BEFORE_INSERT {
            GardenTriggerHandler.beforeInsertPopulateGardenDetails(Trigger.new);

            
        }
    }
}


