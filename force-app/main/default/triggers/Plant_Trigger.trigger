trigger Plant_Trigger on CAMPX__Plant__c (before insert) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            PlantTriggerHandler.beforeInsertPopulatePlantFields(Trigger.new);

            
        }
    }
}

