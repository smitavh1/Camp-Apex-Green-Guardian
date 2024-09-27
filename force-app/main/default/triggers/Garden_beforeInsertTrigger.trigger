trigger Garden_beforeInsertTrigger on CAMPX__Garden__c (before insert, after insert, before update, after update) {

     switch on Trigger.operationType {
        when BEFORE_INSERT {
            GardenTriggerHandler.beforeInsertPopulateGardenDetails(Trigger.new);
            GardenTriggerHandler.beforeInsertSetManagerStartDate(Trigger.new);

            
        }

        when BEFORE_UPDATE{

            GardenTriggerHandler.beforeUpdateIfManagersDateIsCleared(Trigger.new, Trigger.oldMap);

        }

        when AFTER_INSERT {
            GardenTriggerHandler.afterInsertTaskCreation(Trigger.new);

            
        }

        when AFTER_UPDATE {
            GardenTriggerHandler.afterUpdateUpdateTask(Trigger.newMap, Trigger.oldMap);
            GardenTriggerHandler.afterUpdateCreateTask(Trigger.new, Trigger.oldMap);
            GardenTriggerHandler.afterUpdateDeleteTask(Trigger.newMap, Trigger.oldMap);
            
        }
    }
}


