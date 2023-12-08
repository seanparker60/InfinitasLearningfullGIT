@IsTest
public class AU_createAccSubsidiaries_queueable_TEST {
    @TestSetup
    static void makeData(){
        List<Account> AccountList = AU_TestDataFactory.createMultipleAccounts(10, false);
        for (Account acc : AccountList) {
            acc.AgodiUpdateInProgress__c = true;
        }
        insert AccountList;
    }

    @IsTest
    static void Test01(){

        List<Account> accountList = [Select Id FROM Account];
        
        List<Id> createdAccountIds = new List<Id>();
        List<Id> updatedAccountIds = new List<Id>();
        for (integer i = 0; i < AccountList.size(); i++) {
            if (i < 5) {
                createdAccountIds.add(AccountList[i].Id);
            } else {
                updatedAccountIds.add(AccountList[i].Id);
            }
        }

        Test.startTest();
            System.enqueueJob(new AU_createAccSubsidiaries_queueable(createdAccountIds, updatedAccountIds));
        Test.stopTest();
        
    }
}