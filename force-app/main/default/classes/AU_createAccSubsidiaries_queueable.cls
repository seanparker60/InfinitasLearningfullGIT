public class AU_createAccSubsidiaries_queueable implements Queueable {

    public List<Id> createdAccountIdList,updatedAccountIdList;
    Integer batchSize = 200;
    
    public AU_createAccSubsidiaries_queueable(List<Id> createdAccountIds, List<Id> updatedAccountIds) {
        this.createdAccountIdList = createdAccountIds;
        this.updatedAccountIdList = updatedAccountIds;
    }

    public void execute(QueueableContext context) {
        System.debug('AU_createAccSubsidiaries_queueable - execute - START');
        
        List<Account> accountUpdateList = new List<Account>();
        List<AccountSubsidiary__c> accSubList = new List<AccountSubsidiary__c>();

        List<Id> newCreatedAccountIdList = new List<Id>();
        List<Id> newUpdatedAccountIdList = new List<Id>();
        Integer accountCount = 0;
        Integer accSubCount = 0;
        Boolean updateFinished = false;

        for (Id accId : this.createdAccountIdList) {

            if (accountCount < this.batchSize) {
                Account acc = new Account();
                acc.Id = accId;
                acc.AgodiUpdateInProgress__c = false;
                accountUpdateList.add(acc);

                /*********************************************************
                **  CREATION OF SUBSIDIARIES IS NOT NEEDED ANYMORE      **
                **  THIS HAS BEEN REPLACED BY A FLOW THAT CREATES       **
                **  A NEW SUBSIDIARY ON EACH INSERT OF A NEW ACCOUNT    **
                **********************************************************/

                accountCount ++;
            } else {
                newCreatedAccountIdList.add(accId);
            }            
        }

        for (Id accId : this.updatedAccountIdList) {

            if (accountCount < this.batchSize) {
                Account acc = new Account();
                acc.Id = accId;
                acc.AgodiUpdateInProgress__c = false;
                accountUpdateList.add(acc);

                accountCount ++;
            } else {
                newUpdatedAccountIdList.add(accId);
            }

        }
        
        if (this.updatedAccountIdList.size() <= this.batchSize && newCreatedAccountIdList.size() == 0) {
            updateFinished = true;
        }

        update accountUpdateList;

        if (accountCount == batchSize && !updateFinished) {
            if (!Test.isRunningTest()) {
                Id jobId = System.enqueueJob(new AU_createAccSubsidiaries_queueable(newCreatedAccountIdList, newUpdatedAccountIdList));
                System.debug('AU_createAccSubsidiaries_queueable is enqueued with Job Id: ' + jobID);
                System.debug('AU_createAccSubsidiaries_queueable - execute - END');
                return;
            }
        } else {
            System.debug('AU_createAccSubsidiaries_queueable - execute - END');
            if (!Test.isRunningTest()) {
                System.enqueueJob(new AU_getCurrentAgodiAccounts());   
            }
            System.debug('===> Agodi Account Update is completed. Proceding to Agodi Student number update.');
        }
    }
}