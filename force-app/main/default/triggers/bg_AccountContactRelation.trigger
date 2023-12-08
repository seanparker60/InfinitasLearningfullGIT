trigger bg_AccountContactRelation on AccountContactRelation (After insert, After Update) {

    AWSSwitches__mdt[] AWSSwitches = [Select DeveloperName,Active__c from AWSSwitches__mdt where DeveloperName='AccountContactRelation'];

    if(trigger.isInsert){
        if(AWSSwitches[0].Active__c){
            bg_AllObjectTriggerHandler.afterObjectInsert(trigger.newMap,'AccountContactRelation');
        }    
    }
     
    if(trigger.Isupdate){
        if(AWSSwitches[0].Active__c){
            bg_AllObjectTriggerHandler.afterObjectUpdate(trigger.newMap, trigger.oldMap,'AccountContactRelation');
        }    
    }
    
}