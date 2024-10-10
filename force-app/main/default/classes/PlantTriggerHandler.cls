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


    // Method to handle plant count updates based on trigger context
    public static void handlePlantCountUpdateOnPlantAddition(List<CAMPX__Plant__c> newPlants) {

        // Set to track affected Garden IDs
        Set<Id> gardenIdsToUpdate = new Set<Id>();

        // Handling insert and undelete (plant is added)
            for (CAMPX__Plant__c plant : newPlants) {
              //  if (plant.CAMPX__Garden__c != null ) {
                    gardenIdsToUpdate.add(plant.CAMPX__Garden__c);
               // }


                // // check if the Garden field on the plant has been emptied out now.
                // if(plant.CAMPX__Garden__c == null){

                //     CAMPX__Plant__c oldVersionOfPlant = updatedPlants.get(plant.CAMPX__Garden__c);
                //    if( oldVersionOfPlant.CAMPX__Garden__c == plant.CAMPX__Garden__c){
                //     gardenIdsToUpdate.add(plant.CAMPX__Garden__c);
                //    }
                    
                // }
            }
        

        // Query the garden records.
List<CAMPX__Garden__c>  gardensWherePlantAdded= [SELECT Id, CAMPX__Total_Plant_Count__c FROM CAMPX__Garden__c WHERE Id IN :gardenIdsToUpdate];

 // Query the garden which has lost plants
// List<CAMPX__Garden__c> gardensWherePlantRemoved = [SELECT Id, CAMPX__Total_Plant_Count__c FROM CAMPX__Garden__c WHERE Id IN :gardenIdsToUpdate];
for(CAMPX__Garden__c eachGarden : gardensWherePlantAdded){

    // find the total number of updated plants for each garden
   List <CAMPX__Plant__c> totalNoOfPlantsNow = [SELECT Id FROM CAMPX__Plant__c where CAMPX__Garden__c =:eachGarden.Id];

    Integer totalPlantListSize = totalNoOfPlantsNow.size();
    eachGarden.CAMPX__Total_Plant_Count__c = totalPlantListSize;

   

    // for(CAMPX__Garden__c eachGardenWithRemovedPlant: gardensWherePlantRemoved){

    //     // find the total no of updated plants for each garden

    //     List<CAMPX__Plant__c> totalNoOfPlantsAfterRemoval = [SELECT Id FROM CAMPX__Plant__c where CAMPX__Garden__c =:eachGardenWithRemovedPlant.Id];

    //     Integer totalUpdatedPlantSize = totalNoOfPlantsAfterRemoval.size();
    //     eachGardenWithRemovedPlant.CAMPX__Total_Plant_Count__c = totalUpdatedPlantSize;

    // }

}
update gardensWherePlantAdded;

    }


    public static void handlePlantCountUpdateOnPlantUpdate( List<CAMPX__Plant__c> plantsUpdatedWithNoGarden, Map<Id,CAMPX__Plant__c> oldVersionOfPlantRecords)
    {

        // Set to track affected Garden IDs
        Set<Id> gardenIdsToUpdate = new Set<Id>();

        for (CAMPX__Plant__c plant : plantsUpdatedWithNoGarden) {

            // Handling update (plant is removed from the Garden)
            
                    // check if plant did have a Garden populated earlier
            
                   CAMPX__Plant__c oldVersionOfPlant = oldVersionOfPlantRecords.get(plant.Id);
            
                   System.debug(oldVersionOfPlant);

                   //Commented - (plant.CAMPX__Garden__c == null && oldVersionOfPlant.CAMPX__Garden__c !=null)  
            
                    if (oldVersionOfPlant.CAMPX__Garden__c != plant.CAMPX__Garden__c) {
                        gardenIdsToUpdate.add(plant.CAMPX__Garden__c);
                        gardenIdsToUpdate.add(oldVersionOfPlant.CAMPX__Garden__c);
                    }
                }

        // Query the garden records along with its plants.
List<CAMPX__Garden__c>  gardensWherePlantCountWasChanged= [SELECT Id,(SELECT Id FROM CAMPX__Plants__r), CAMPX__Total_Plant_Count__c FROM CAMPX__Garden__c WHERE Id IN :gardenIdsToUpdate];
                
for(CAMPX__Garden__c eachGardenWithChangedPlantCount : gardensWherePlantCountWasChanged){

    List<CAMPX__Plant__c> totalPlantsOfEachGarden = eachGardenWithChangedPlantCount.CAMPX__Plants__r;

    Integer totalPlantSizeAfterChange = totalPlantsOfEachGarden.size();
    
    eachGardenWithChangedPlantCount.CAMPX__Total_Plant_Count__c = totalPlantSizeAfterChange;

}

update gardensWherePlantCountWasChanged;

    }

public static void calculateAggrUnhealthyPlantCount(List<CAMPX__Plant__c> plantsWithUnhealthyStatus){


       // Set to track affected Garden IDs
       Set<Id> gardenIdsToUpdate = new Set<Id>();

       List<CAMPX__Plant__c> totalUnhealthyPlants = new List<CAMPX__Plant__c>();
       for(CAMPX__Plant__c eachUnHealthyPlant : plantsWithUnhealthyStatus){
   
      
     
        gardenIdsToUpdate.add(eachUnHealthyPlant.CAMPX__Garden__c);

       }

             // Query all the gardens with subset of unhealthy plants in them.

             List<CAMPX__Garden__c> allGardensWithTheirPlants = [SELECT Id,(SELECT Id,CAMPX__Status__c FROM CAMPX__Plants__r),CAMPX__Total_Unhealthy_Plant_Count__c FROM CAMPX__Garden__c WHERE Id IN :gardenIdsToUpdate];

             for(CAMPX__Garden__c eachGardenWithUnhealthyPlants : allGardensWithTheirPlants){
               
        

                List<CAMPX__Plant__c> totalPlantsOfEachGarden = eachGardenWithUnhealthyPlants.CAMPX__Plants__r;
                           // Your logic here
                           for(CAMPX__Plant__c eachPlant : totalPlantsOfEachGarden){
                            if(eachPlant.CAMPX__Status__c == 'Sick' || 
                            eachPlant.CAMPX__Status__c == 'Wilting' || 
                            eachPlant.CAMPX__Status__c == 'Deceased')
totalUnhealthyPlants.add(eachPlant);
                           }
   
          

                Integer totalUnhealthyPlantCount = totalUnhealthyPlants.size();

                eachGardenWithUnhealthyPlants.CAMPX__Total_Unhealthy_Plant_Count__c = totalUnhealthyPlantCount;


             }

             update allGardensWithTheirPlants;


}


public static void calculateUnhealthyPlantCountAfterDelete(List<CAMPX__Plant__c> deletedIdToUnhealthyPlants){

      // Set to track affected Garden IDs
      Set<Id> gardenIdsToUpdate = new Set<Id>();

      for(CAMPX__Plant__c eachDeletedPlant : deletedIdToUnhealthyPlants){
        
     
        gardenIdsToUpdate.add(eachDeletedPlant.CAMPX__Garden__c);

       }
       // Query all the gardens with subset of unhealthy plants in them.

       List<CAMPX__Garden__c> allGardensWithTheirDeletedPlants = [SELECT Id, 
       (SELECT Id, CAMPX__Status__c FROM CAMPX__Plants__r WHERE CAMPX__Status__c IN ('Sick', 'Deceased', 'Wilted')), 
       CAMPX__Total_Unhealthy_Plant_Count__c 
FROM CAMPX__Garden__c 
WHERE Id IN :gardenIdsToUpdate
];


for(CAMPX__Garden__c eachGardenWithDeletedPlant : allGardensWithTheirDeletedPlants){

    List<CAMPX__Plant__c> totalUpdatedPlantsOfEachGarden = eachGardenWithDeletedPlant.CAMPX__Plants__r;

    eachGardenWithDeletedPlant.CAMPX__Total_Unhealthy_Plant_Count__c = totalUpdatedPlantsOfEachGarden.size();


}

update allGardensWithTheirDeletedPlants;


       


}


// This method will handle both insert and update operations for Plant records.
public static void beforeInsertUpdate(List<CAMPX__Plant__c> newPlants, Map<Id, CAMPX__Plant__c> oldVOfPlants) {
    
    // Retrieve the set of Garden IDs from the incoming plant records.
    Set<Id> gardenIds = new Set<Id>();
    for (CAMPX__Plant__c plant : newPlants) {
        if (plant.CAMPX__Garden__c != null) {
            gardenIds.add(plant.CAMPX__Garden__c);
        }
    }
    
    // Query the Garden records that match the IDs and have a status of 'Permanent Closure'.
    Map<Id, CAMPX__Garden__c> closedGardens = new Map<Id, CAMPX__Garden__c>(
        [SELECT Id, CAMPX__Status__c FROM CAMPX__Garden__c WHERE Id IN :gardenIds AND CAMPX__Status__c = 'Permanent Closure']
    );
    
    // Loop through the plant records and check if any are associated with closed gardens.
    for (CAMPX__Plant__c plant : newPlants) {
        if (plant.CAMPX__Garden__c != null && closedGardens.containsKey(plant.CAMPX__Garden__c)) {
            plant.addError('The garden selected for this plant is permanently closed. Please select a different garden.');
        }


            // Check if it's an update and if the garden has been changed to a closed garden
            if(oldVOfPlants != null  && oldVOfPlants.containsKey(plant.Id)){
               CAMPX__Plant__c oldVersionOfPlant = oldVOfPlants.get(plant.Id);

               // Only throw error if the Garden was changed to a closed Garden
               if(oldVersionOfPlant.CAMPX__Garden__c != plant.CAMPX__Garden__c && plant.CAMPX__Garden__r.CAMPX__Status__c == 'Permanent Closure'){
                   plant.addError('The garden selected for this plant is permanently closed. Please select a different garden.');
               }
            } 
        }
    }
}




    









