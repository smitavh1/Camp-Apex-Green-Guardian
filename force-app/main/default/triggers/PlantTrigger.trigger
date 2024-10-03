trigger PlantTrigger on CAMPX__Plant__c (after insert, after update, after delete, after undelete) {

    switch on Trigger.operationType {
        when AFTER_INSERT {
            PlantTriggerHandler.handlePlantCountUpdateOnPlantAddition(Trigger.new);
            PlantTriggerHandler.calculateAggrUnhealthyPlantCount(Trigger.new);


            
        }
        when AFTER_UPDATE {
            PlantTriggerHandler.handlePlantCountUpdateOnPlantUpdate(Trigger.new, Trigger.oldMap);
            PlantTriggerHandler.calculateAggrUnhealthyPlantCount(Trigger.new);
            
        }

        when AFTER_DELETE {
            PlantTriggerHandler.handlePlantCountUpdateOnPlantAddition(Trigger.old);
            PlantTriggerHandler.calculateUnhealthyPlantCountAfterDelete(Trigger.old);
            
        }


    }

   

}