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

       
            }

      

        }


    

    }


