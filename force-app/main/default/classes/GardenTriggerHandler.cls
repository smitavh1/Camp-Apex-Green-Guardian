public with sharing class GardenTriggerHandler {
    public GardenTriggerHandler() {

    }

    public static void beforeInsertPopulateGardenDetails(List< CAMPX__Garden__c>  newGardenRecords){

        // Usage - obj.Field__c = (obj.Field__c != null) ? obj.Field__c : 'Default Value';

        for (CAMPX__Garden__c newGardenRecord : newGardenRecords){

            newGardenRecord.CAMPX__Status__c = newGardenRecord.CAMPX__Status__c != null ? newGardenRecord.CAMPX__Status__c : 'Awaiting Resources';
            newGardenRecord.CAMPX__Max_Plant_Count__c = newGardenRecord.CAMPX__Max_Plant_Count__c != null ? newGardenRecord.CAMPX__Max_Plant_Count__c : 100;
            newGardenRecord.CAMPX__Minimum_Plant_Count__c = newGardenRecord.CAMPX__Minimum_Plant_Count__c != null ? newGardenRecord.CAMPX__Minimum_Plant_Count__c : 1;
            newGardenRecord.CAMPX__Total_Plant_Count__c = newGardenRecord.CAMPX__Total_Plant_Count__c != null ? newGardenRecord.CAMPX__Total_Plant_Count__c : 0;

            newGardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c = newGardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c != null ? newGardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c : 0;

            if( newGardenRecord.CAMPX__Max_Plant_Count__c != null && newGardenRecord.CAMPX__Total_Plant_Count__c != null){

                Decimal calculateCapacity = (newGardenRecord.CAMPX__Total_Plant_Count__c / newGardenRecord.CAMPX__Max_Plant_Count__c) * 100;
            
            newGardenRecord.CAMPX__Capacity__c = calculateCapacity;
            }

            else if(newGardenRecord.CAMPX__Max_Plant_Count__c == null || newGardenRecord.CAMPX__Total_Plant_Count__c == null){

                newGardenRecord.CAMPX__Capacity__c = 0.0;
            }
       
            }

      

        }

        public static void afterInsertTaskCreation(List<CAMPX__Garden__c> newlyCreatedGardenRecords){
            //Create a task when a new Garden is created and Manager lookup for the garden is populated. 
            List<Task> newTasksToBeInserted = new List<Task>();


            // Get the Manager Lookup record details to attach the task thats going to be created. 
      
            for(CAMPX__Garden__c newlyCreatedGardenRecord:newlyCreatedGardenRecords){


                if(newlyCreatedGardenRecord.CAMPX__Manager__c != null){

                    //Populate  Task Details
                    Task newTask = new Task();

                    newTask.Subject = 'Acquire Plants';
                    newTask.WhatId = newlyCreatedGardenRecord.Id;
                    newTask.OwnerId = newlyCreatedGardenRecord.CAMPX__Manager__c;
                    newTasksToBeInserted.add(newTask);
                    System.debug(newTask);


                }
            }



insert newTasksToBeInserted;
System.debug(newTasksToBeInserted);

        }


    
        public static void afterUpdateUpdateTask(MAP<Id, CAMPX__Garden__c> updatedGardenRecords, Map<Id,CAMPX__Garden__c> OldGardenRecords) {
            List<Task> tasksCreatedForUpdatedGardenRecords = new List<Task>();

            Set<Id> gardenIds = new Set<Id>();
                    
            // For each updated Manager for garden the tasks should be reassigned to the new Manager
            for (CAMPX__Garden__c updatedGardenRecord : updatedGardenRecords.values()) {
                // Get the old version of the record
                CAMPX__Garden__c oldGardenRecord = OldGardenRecords.get(updatedGardenRecord.Id);
        
                              // If Manager has changed, we need to update existing tasks
                if (oldGardenRecord.CAMPX__Manager__c != updatedGardenRecord.CAMPX__Manager__c && updatedGardenRecord.CAMPX__Manager__c != null) {
                    gardenIds.add(updatedGardenRecord.Id);
                }
                System.debug(gardenIds);
            }


            //Query the tasks for all the gardenId's
            
                    List<Task> tasksTobeUpdated = [SELECT Id, OwnerId, Status, Subject,WhatId 
                                                   FROM Task 
                                                   WHERE WhatId IN :gardenIds
                                                   AND Subject = 'Acquire Plants' 
                                                   AND Status != 'Completed'];
                                                   System.debug(tasksTobeUpdated);
        
                    for (Task eachTaskToBeUpdated : tasksTobeUpdated) {
                        // Update the owner of the task if criteria match
                        //Get the Garden record
                        Id ManagerId = updatedGardenRecords.get(eachTaskToBeUpdated.WhatId).CAMPX__Manager__c;
                        
                        eachTaskToBeUpdated.OwnerId = ManagerId;
                        tasksCreatedForUpdatedGardenRecords.add(eachTaskToBeUpdated);
                        
                    }
         
         
                 
        
            // Update existing tasks after all iterations
            if (!tasksCreatedForUpdatedGardenRecords.isEmpty()) {
                System.debug(tasksCreatedForUpdatedGardenRecords);
                update tasksCreatedForUpdatedGardenRecords;
            }
        }
        


// Part2 - Create Task

public static void afterUpdateCreateTask(List<CAMPX__Garden__c> updatedGardenRecords, Map<Id,CAMPX__Garden__c> OldGardenRecords) {
    List<Task> newTasksToBeInserted = new List<Task>();

            
    // For each updated Garden record with a Manager a task should be created.
    for (CAMPX__Garden__c updatedGardenRecord : updatedGardenRecords) {
        // Get the old version of the record
        CAMPX__Garden__c oldGardenRecord = OldGardenRecords.get(updatedGardenRecord.Id);

        // Check if the old lookup field was null and the new lookup field is not null
        if (oldGardenRecord.CAMPX__Manager__c == null && updatedGardenRecord.CAMPX__Manager__c != null) {
            System.debug('Lookup field changed from null to non-null!');
            
            // Add logic to create a new task
            Task newTask = new Task();
            newTask.Subject = 'Acquire Plants';
            newTask.WhatId = updatedGardenRecord.Id;
            newTask.OwnerId = updatedGardenRecord.CAMPX__Manager__c;
            newTasksToBeInserted.add(newTask);
        }

            }

    // Insert new tasks after all iterations
    if (!newTasksToBeInserted.isEmpty()) {
        insert newTasksToBeInserted;
    }

    
}


public static void afterUpdateDeleteTask(Map<Id,CAMPX__Garden__c>  updatedMapWithNoManagerGardenRecords, Map<Id,CAMPX__Garden__c> OldGardenRecords){

    // Storing GardenIds
    Set<Id> gardenIds = new Set<Id>();
    List<Task> tasksOfGardenRecordToBeDeleted = new List<Task>();

   // For each removed Manager for garden the tasks should be deleted.
   for (CAMPX__Garden__c removedGardenRecord : updatedMapWithNoManagerGardenRecords.values()) {
    // Get the old version of the record
    CAMPX__Garden__c oldGardenRecord = OldGardenRecords.get(removedGardenRecord.Id);

                  // If Manager has been emptied out then we delete existing tasks
    if (oldGardenRecord.CAMPX__Manager__c != null && removedGardenRecord.CAMPX__Manager__c == null) {
        gardenIds.add(removedGardenRecord.Id);
    }
    System.debug(gardenIds);
}

// Query all the tasks to be deleted for all the garden Ids.

 //Query the tasks for all the gardenId's
            
 List<Task> tasksTobeDeleted = [SELECT Id, OwnerId, Status, Subject,WhatId 
 FROM Task 
 WHERE WhatId IN :gardenIds
 AND Subject = 'Acquire Plants' 
 AND Status != 'Completed'];
 System.debug(tasksTobeDeleted);
  
    //Delete all the tasks of the Garden record if the Manager is removed from the record. 

    for (Task eachTaskToBeDeleted : tasksTobeDeleted) {
       
        tasksOfGardenRecordToBeDeleted.add(eachTaskToBeDeleted);
        
    }



// Update existing tasks after all iterations
if (!tasksOfGardenRecordToBeDeleted.isEmpty()) {
System.debug(tasksOfGardenRecordToBeDeleted);
delete tasksOfGardenRecordToBeDeleted;
}





}

public static void beforeInsertSetManagerStartDate(List<CAMPX__Garden__c> newGardenRecsWithManagers){

    for(CAMPX__Garden__c eachGardenRecWithManager : newGardenRecsWithManagers){

        if(eachGardenRecWithManager.CAMPX__Manager__c != null){

            eachGardenRecWithManager.CAMPX__Manager_Start_Date__c = Datetime.now().date();
        }
           }
}

public static void beforeUpdateIfManagersDateIsCleared(List<CAMPX__Garden__c> newGardenRecsWithManagers, Map<Id,CAMPX__Garden__c> oldVersionOfGRecords){

    for(CAMPX__Garden__c eachGardenRecWithManager : newGardenRecsWithManagers){

        CAMPX__Garden__c oldVersionOfTheRecord = oldVersionOfGRecords.get(eachGardenRecWithManager.id);
        System.debug(oldVersionOfTheRecord);
        System.debug('Old Manager: ' + oldVersionOfTheRecord.CAMPX__Manager__c);


        if(eachGardenRecWithManager.CAMPX__Manager__c == null && oldVersionOfTheRecord.CAMPX__Manager__c != null ){

            eachGardenRecWithManager.CAMPX__Manager_Start_Date__c = null;
        }


        if((oldVersionOfTheRecord.CAMPX__Manager__c == null && eachGardenRecWithManager.CAMPX__Manager__c != null) || (oldVersionOfTheRecord.CAMPX__Manager__c != eachGardenRecWithManager.CAMPX__Manager__c)){

            eachGardenRecWithManager.CAMPX__Manager_Start_Date__c = date.today();
        }


        if( eachGardenRecWithManager.CAMPX__Max_Plant_Count__c != null && eachGardenRecWithManager.CAMPX__Total_Plant_Count__c != null && eachGardenRecWithManager.CAMPX__Max_Plant_Count__c > 0){

            Decimal calculateCapacity = (eachGardenRecWithManager.CAMPX__Total_Plant_Count__c / eachGardenRecWithManager.CAMPX__Max_Plant_Count__c) * 100;
        
            eachGardenRecWithManager.CAMPX__Capacity__c = calculateCapacity;
        }
        else if(eachGardenRecWithManager.CAMPX__Max_Plant_Count__c == null  || eachGardenRecWithManager.CAMPX__Total_Plant_Count__c == null || eachGardenRecWithManager.CAMPX__Max_Plant_Count__c <= 0 ){

            eachGardenRecWithManager.CAMPX__Capacity__c = 0.0;
        }



}


}


// Calculate Health Index considering "Total Plant Count" or "Total Unhealthy Plant Count"

public static void calculateHealthIndexOfGardenOnInsert(List<CAMPX__Garden__c> gardenRecords){

    for(CAMPX__Garden__c eachGarden : gardenRecords){


        if(eachGarden.CAMPX__Total_Plant_Count__c != null && eachGarden.CAMPX__Total_Plant_Count__c > 0){

            eachGarden.CAMPX__Health_Index__c = ((eachGarden.CAMPX__Total_Plant_Count__c - eachGarden.CAMPX__Total_Unhealthy_Plant_Count__c) / eachGarden.CAMPX__Total_Plant_Count__c) * 100;

                    }
                    else {
                        eachGarden.CAMPX__Health_Index__c = 0.0;
                    }

    }

}
    public static void calculateHealthIndexOfGardenOnUpdate(List<CAMPX__Garden__c> gardenRecords, Map<Id,CAMPX__Garden__c> oldVIdToGardenRecords){

for(CAMPX__Garden__c eachGardenRecord : gardenRecords){

    if ((eachGardenRecord.CAMPX__Total_Plant_Count__c != oldVIdToGardenRecords.get(eachGardenRecord.Id).CAMPX__Total_Plant_Count__c && eachGardenRecord.CAMPX__Total_Plant_Count__c > 0) || (eachGardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c != oldVIdToGardenRecords.get(eachGardenRecord.Id).CAMPX__Total_Unhealthy_Plant_Count__c && eachGardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c > 0 )){

        eachGardenRecord.CAMPX__Health_Index__c = ((eachGardenRecord.CAMPX__Total_Plant_Count__c - eachGardenRecord.CAMPX__Total_Unhealthy_Plant_Count__c)/ eachGardenRecord.CAMPX__Total_Plant_Count__c) * 100;
    }
}


    }


    // Set Garden Status based on Capacity,Total Plant Count,Min Plant Count, HealthIndex

    public static void setGardenStatusBasedOnConditions( List<CAMPX__Garden__c> gardensToBeSetWithStatus){

        for(CAMPX__Garden__c eachGarden : gardensToBeSetWithStatus){

            
            if (eachGarden.CAMPX__Status__c == 'Permanent Closure'){

                eachGarden.CAMPX__Status__c = 'Permanent Closure';
            }


           else if (eachGarden.CAMPX__Capacity__c >= 70 &&
    eachGarden.CAMPX__Capacity__c <= 100 &&
    eachGarden.CAMPX__Total_Plant_Count__c >= eachGarden.CAMPX__Minimum_Plant_Count__c &&
    eachGarden.CAMPX__Health_Index__c >= 70) {
    // Your code here
    eachGarden.CAMPX__Status__c = 'Operational';

}

            else if( eachGarden.CAMPX__Capacity__c == 0.0){

                eachGarden.CAMPX__Status__c = 'Temporary Closure';
            }

            else if(eachGarden.CAMPX__Capacity__c > 100 ){

                eachGarden.CAMPX__Status__c = 'Over Capacity';
            }

    

            else if((eachGarden.CAMPX__Capacity__c > 0 && eachGarden.CAMPX__Capacity__c < 70) || 
        eachGarden.CAMPX__Health_Index__c < 70 || 
        eachGarden.CAMPX__Minimum_Plant_Count__c > eachGarden.CAMPX__Total_Plant_Count__c) {

    eachGarden.CAMPX__Status__c = 'Awaiting Resources';
}



                    }
    }

    public static void gardenAllowOnlyPositiveValues(List<CAMPX__Garden__c> gardenRecords){

        for(CAMPX__Garden__c eachGarden : gardenRecords){

            if(eachGarden.CAMPX__Max_Plant_Count__c < 0 || eachGarden.CAMPX__Minimum_Plant_Count__c < 0 || eachGarden.CAMPX__Total_Plant_Count__c < 0 || eachGarden.CAMPX__Total_Unhealthy_Plant_Count__c < 0){

                eachGarden.addError('Plant Count fields must be greater than or equal to zero');
            }
        }
    }


}








