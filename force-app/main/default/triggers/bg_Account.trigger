trigger bg_Account on Account (Before Update, Before insert, After insert, After Update, Before delete, After delete) {
    
    
    AWSSwitches__mdt[] AWSSwitches = [Select DeveloperName,Active__c from AWSSwitches__mdt where DeveloperName='Account'];

    if (trigger.isBefore) {

        if(trigger.isDelete && MERGE_StoreDeletedRecords.deleteHandler == null){
            ACC_AccountHelper.ValidateAccountBeforeTriggerDelete(trigger.old);
        }
    }

    if (trigger.isAfter) {

        if(trigger.isInsert){
            VAT_checkVat.CheckVatOnInsert(trigger.new);
            if(AWSSwitches[0].Active__c){
                bg_AllObjectTriggerHandler.afterObjectInsert(trigger.newMap,'Account');
            }
            
        }

        if(trigger.Isupdate){
            VAT_checkVat.CheckVatOnUpdate(trigger.newMap, trigger.oldMap);
            if(AWSSwitches[0].Active__c){                
                bg_AllObjectTriggerHandler.afterObjectUpdate(trigger.newMap, trigger.oldMap,'Account');
            }
            
        }

        if (trigger.isDelete) {
            MERGE_mergeHelper.dedupeAccounttClassificationsOneMerge(trigger.old);
            MERGE_StoreDeletedRecords.HandletriggerDelete(trigger.old);
        }        
    }

}