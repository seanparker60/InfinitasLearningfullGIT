@isTest
public class MERGE_unMergeAccounts_Batch_TEST {
    
    @TestSetup
    static void makeData(){

        List<Account> accounts = new List<Account>();

        Account a1 = new Account();
        a1.Name = 'TestAccount1';
        a1.BillingCity = 'Lelystad';
        a1.NumberofStudents__c = 1;
        a1.OperatingCompany__c = 'Plantyn';
        a1.Area__c = 'Dutch';
        accounts.add(a1);
        
        Account a2 = new Account();
        a2.Name = 'TestAccount2';
        a2.BillingCity = 'Almere';
        a2.NumberofStudents__c = 1;
        a2.OperatingCompany__c = 'Plantyn';
        a2.Area__c = 'Dutch';
        accounts.add(a2);

        Account a3 = new Account();
        a3.Name = 'TestParentAccount';
        a3.BillingCity = 'Almere';
        a3.NumberofStudents__c = 1;
        a3.OperatingCompany__c = 'Plantyn';
        a3.Area__c = 'Dutch';
        accounts.add(a3);
        
        insert accounts;

        a1.ParentId = a3.Id;

        update a1;

        AccountHistory ah = new AccountHistory();
        ah.AccountId = a1.Id;
        ah.Field = 'Parent';
        insert ah;

    }

    @IsTest
    static void test(){
        
        Account a1 = [SELECT Id, BillingCity FROM Account WHERE Name = 'TestAccount1' LIMIT 1];
        Account a2 = [SELECT Id, BillingCity FROM Account WHERE Name = 'TestAccount2' LIMIT 1];

        Database.Merge(a1, a2, false);

     //   System.assertEquals(2, [SELECT COUNT() FROM Account]);

        Test.startTest();
            MERGE_unMergeAccounts_Batch  unmergeAcc = new MERGE_unMergeAccounts_Batch();
            Id batchprocessid = Database.executebatch(unmergeAcc, 1);
        Test.stopTest();
        
       // System.assertEquals(3, [SELECT COUNT() FROM Account]);

    }
}