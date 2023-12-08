public with sharing class bg_AllObjectInvocableHandler {
    
    @invocablemethod
    Public static void AllObjectInvocableHandler(List<Id> RecordIds){

        String objectName = RecordIds[0].getSobjectType().getDescribe().getName();

        if(objectName == 'AccountSubsidiary__c'){
            objectName = 'AccountSubsidiary';
        }   
        
       // UTIL_TriggerController.OrderItemTriggerSwitch = false;
        bg_AWSInvocableUtils.ProcessAWSCallout(ObjectName, RecordIds);

    }
    


}