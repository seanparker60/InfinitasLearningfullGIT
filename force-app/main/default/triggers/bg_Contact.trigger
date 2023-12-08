trigger bg_Contact on Contact (After insert, After Update, After delete) {
    AWSSwitches__mdt[] AWSSwitches = [Select DeveloperName,Active__c from AWSSwitches__mdt where DeveloperName='Contact'];

    if(trigger.isInsert){
        if(AWSSwitches[0].Active__c){
            bg_AllObjectTriggerHandler.afterObjectInsert(trigger.newMap,'Contact');
        }
    }
     
    if(trigger.Isupdate){
        if(AWSSwitches[0].Active__c){
            bg_AllObjectTriggerHandler.afterObjectUpdate(trigger.newMap, trigger.oldMap,'Contact');
        }    
    }

    if (trigger.isDelete) {
        MERGE_mergeHelper.dedupeContactClassificationsOneMerge(trigger.old);
        MERGE_StoreDeletedRecords.HandletriggerDelete(trigger.old);
    }
    
}