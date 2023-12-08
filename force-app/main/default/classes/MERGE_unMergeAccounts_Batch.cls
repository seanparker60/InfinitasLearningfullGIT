global class MERGE_unMergeAccounts_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Integer undeleteCount = 0;

    global Database.QueryLocator start (Database.BatchableContext BC) {

        String query = 'SELECT Id, MasterRecordId, BillingCity, ParentId FROM Account WHERE MasterRecordId != null AND LastModifiedDate > 2021-02-18T00:00:00.000z AND IsDeleted = true ALL ROWS';

        return Database.getQueryLocator(query);
    }


    global void execute (Database.BatchableContext BC, List<Account> scope) { 
        undeleteCount += MERGE_unmergeAccounts.unMergeAccounts(scope);
    }


    global void finish (Database.BatchableContext BC) {
        System.debug('We have undeleted ' + undeleteCount + ' Accounts.');
    }

}