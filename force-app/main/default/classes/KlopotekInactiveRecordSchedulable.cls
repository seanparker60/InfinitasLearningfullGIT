global class KlopotekInactiveRecordSchedulable implements Schedulable{
    global void execute(SchedulableContext sc)
    {
        //KlopotekInactiveRecordSchedulable klopotekTest = new KlopotekInactiveRecordSchedulable();
        //klopotekTest.execute(null);
        callBatch();
    }
    
    public void callBatch()
    {
        // get klopotek accounts and contacts that have not been modified for 10 days
        // mark them as inactive

        DateTime dtTenDaysAgo = DateTime.now().addDays(-10);
        List<KlopotekAccount__c> accLs = new List<KlopotekAccount__c>();
        List<KlopotekContact__c> contactLs = new List<KlopotekContact__c>();
        
        if(!Test.isRunningTest()){
            accLs = [SELECT Id, Account__c
                                              FROM KlopotekAccount__c
                                              WHERE Inactive__c = false AND LastModifiedDate <= :dtTenDaysAgo];
            
            system.debug('KlopotekInactiveRecordSchedulable accLs: ' + accLs.size());
            
            contactLs = [SELECT Id, Contact__c
                                                  FROM KlopotekContact__c
                                                  WHERE Inactive__c = false AND LastModifiedDate <= :dtTenDaysAgo];
            
            system.debug('KlopotekInactiveRecordSchedulable contactLs: ' + contactLs.size());
        } else {
            accLs = [SELECT Id, Account__c
                     FROM KlopotekAccount__c
                     WHERE Inactive__c = false];
            
            system.debug('KlopotekInactiveRecordSchedulable accLs: ' + accLs.size());
            
            contactLs = [SELECT Id, Contact__c
                         FROM KlopotekContact__c
                         WHERE Inactive__c = false];
            
            system.debug('KlopotekInactiveRecordSchedulable contactLs: ' + contactLs.size());
        }

        
        // get account subsidiaries and set pending inactive = true
        // also update klopotekaccount records
        Set<Id> accIdLs = new Set<Id>();
        Set<Id> contactIdLs = new Set<Id>();
        
        for(KlopotekAccount__c klpAcc : accLs){
            accIdLs.add(klpAcc.Account__c);
            
            klpAcc.Inactive__c = true;
        }
        
        for(KlopotekContact__c klpCont : contactLs){
            contactIdLs.add(klpCont.Contact__c);
            
            klpCont.Inactive__c = true;
        }
        
        List<AccountSubsidiary__c> accSubLs = [SELECT Id from AccountSubsidiary__c WHERE Account__c IN :accIdLs];
        List<Contact> contLs = [SELECT Id from Contact WHERE Id IN :contactIdLs];
        
        for(AccountSubsidiary__c accSub : accSubLs){
            accSub.IsInactive__c = true;
        }
        
        for(Contact con : contLs){
            con.IsInactive__c = true;
        }
        
        
        KlopotekInactiveRecordsBatch batchJob = new KlopotekInactiveRecordsBatch(accSubLs, contLs, accLs, contactLs);
        Id batchJobId = Database.executeBatch(batchJob, 25);   
        /*try{
            update accSubLs;
            update contLs;
            
            update accLs;
            update contactLs;
        } catch(Exception exc){
            system.debug('EXCEPTION: ' + exc.getMessage());
        } */
    }
}