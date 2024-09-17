public with sharing class PlantTriggerHandler {
    public PlantTriggerHandler() {

    }

    public static void beforeInsertPopulatePlantFields(List<CAMPX__Plant__c> initialPlantRecords){
        //Get all plants that have parent garden field.

        set<Id> gardenIds = new set<Id>();

        // Get parent garden records iterating through plant records

        for(CAMPX__Plant__c eachPlantRecord : initialPlantRecords){

            gardenIds.add(eachPlantRecord.CAMPX__Garden__c);

        }
        System.debug(gardenIds);

        //Query all the gardens based on the Id for Sun Exposure and store it  in Map

        Map<Id, CAMPX__Garden__c> IdToGardenRecordMap = new MAP<Id, CAMPX__Garden__c> ([SELECT Id, CAMPX__Sun_Exposure__c FROM CAMPX__Garden__c WHERE Id IN :gardenIds]);
        System.debug(IdToGardenRecordMap.values());

        //If the user does not specify a value for 'Soil Type' or 'Water', set it to the values in the table above
        for( CAMPX__Plant__c plantRecord : initialPlantRecords){
            
           // If the user does specify a value for 'Soil Type' or 'Water', do not default the field
            //newGardenRecord.CAMPX__Status__c = newGardenRecord.CAMPX__Status__c != null ? newGardenRecord.CAMPX__Status__c : 'Awaiting Resources';
         plantRecord.CAMPX__Soil_Type__c = plantRecord.CAMPX__Soil_Type__c != null ? plantRecord.CAMPX__Soil_Type__c : 'All Purpose Potting Soil';
         plantRecord.CAMPX__Water__c = plantRecord.CAMPX__Water__c != null ? plantRecord.CAMPX__Water__c : 'Once Weekly';


        /*If a plant has a garden with 'CAMPX__Sun_Exposure__c' populated,
         that value should be inherited, unless a user specifies their own value */
         CAMPX__Garden__c associatedGarden = IdToGardenRecordMap.get(plantRecord.CAMPX__Garden__c);


                     // Check if plant's Sun Light (CAMPX__Sunlight__c) field is null and the garden exists in the map
                    if(plantRecord.CAMPX__Sunlight__c == null && plantRecord.CAMPX__Garden__c != null)
                    {

                        if(associatedGarden != null){

                            //Inherit the Sun exposure into Plants Sun Light
                            plantRecord.CAMPX__Sunlight__c = associatedGarden.CAMPX__Sun_Exposure__c;
                        }
                    }

                    /* If a plant can not inherit 'CAMPX__Sun_Exposure__c' from its garden 
                    (it's missing a garden or the garden is missing data),
                     then "Partial Sun" should be used as the default, 
                     unless the user specifies their own value  */
                if(plantRecord.CAMPX__Garden__c == null || associatedGarden.CAMPX__Sun_Exposure__c == null){

                    plantRecord.CAMPX__Sunlight__c = 'Partial Sun';
                }
                     

    }

   // update initialPlantRecords;
}
}