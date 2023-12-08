trigger bg_AccountSubsidiary on AccountSubsidiary__c (After insert, After Update) {
    System.debug(LoggingLevel.DEBUG, '==========> bg_AccountSunsidiary Trigger');
    
    AWSSwitches__mdt[] AWSSwitches = [Select DeveloperName,Active__c from AWSSwitches__mdt where DeveloperName='AccountSubsidiary'];

    if(trigger.isInsert){
        if(AWSSwitches[0].Active__c){
         //   bg_AllObjectTriggerHandler.afterObjectInsert(trigger.newMap,'AccountSubsidiary__c');
        }    
    }
     
    if(trigger.Isupdate){
        if(AWSSwitches[0].Active__c){
            bg_AllObjectTriggerHandler.afterObjectUpdate(trigger.newMap, trigger.oldMap,'AccountSubsidiary__c');
        }
    }
}