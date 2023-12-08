global class KlopotekInactiveRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
    private List<AccountSubsidiary__c> accSubLs;
    private List<Contact> contactLs;
    private List<KlopotekAccount__c> klpAccLs;
    private List<KlopotekContact__c> klpConLs;
    
    public KlopotekInactiveRecordsBatch(List<AccountSubsidiary__c> accountSubLs, List<Contact> conLs, List<KlopotekAccount__c> klpAccountLs, List<KlopotekContact__c> klpContactLs){
        accSubLs = accountSubLs;
        contactLs = conLs;
        klpAccLs = klpAccountLs;
        klpConLs = klpContactLs;
    }
    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        return accSubLs;
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> records){
        system.debug('accSubLs.size(): ' + accSubLs);
        system.debug('contactLs.size(): ' + contactLs);
        system.debug('klpAccL.size(): ' + klpAccLs);
        system.debug('klpConLs.size(): ' + klpConLs);
        
        
        update accSubLs;
        update contactLs;
        
        update klpAccLs;
        update klpConLs; 
    } 
    
    
    global void finish(Database.BatchableContext bc){
        
        // delete existing job (if there is one)
        /*CronTrigger[] jobRecordLs = [SELECT Id FROM CronTrigger where CronJobDetail.Name LIKE '%KlopotekInactiveRecordSchedulable_%'];
        
        if(jobRecordLs.size() > 0){
            for(CronTrigger cTrig : jobRecordLs){
                System.abortJob(cTrig.Id);
            }
        }*/
        
        // run every hour
        /*if(!Test.isRunningTest()){
            KlopotekInactiveRecordSchedulable pa = new KlopotekInactiveRecordSchedulable();
            String cronStr = '0 0 06 * * ? *';
            System.schedule('KlopotekInactiveRecordSchedulable', cronStr, pa); 
        }*/

    }
}