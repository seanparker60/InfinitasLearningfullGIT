@isTest
public with sharing class MERGE_MergeAccounts_Batch_TEST {
    
    @TestSetup
    static void makeData(){
        
        List<Account> accountLst = MERGE_TestDataFactory.createAccounts(2, true);
        List<Account> accountLst2 = MERGE_TestDataFactory.createAccountsForAccountMatchTest1(3, accountLst, false);
        List<Account> accountLst3 = MERGE_TestDataFactory.createAccountsForAccountMatchTest2(3, accountLst, false);
        List<Account> accInsLst = new List<Account>();
        accInsLst.addAll(accountLst2);
        accInsLst.addAll(accountLst3);
        insert accInsLst;
    }

   @IsTest
    static void testExernalCustomerIdMatchingShouldMerge(){

        Test.startTest();
            MERGE_MergeAccounts_Batch  MergeCon = new MERGE_MergeAccounts_Batch(false, true, false);
            Id batchprocessid = Database.executebatch(MergeCon, 1);
        Test.stopTest();

    //    System.assertEquals(1, [SELECT Count() FROM Account WHERE ExternalCustomerId__c = '123456789']);
        
    }

    @IsTest
    static void testExernalCustomerIdMatchingShouldNotMerge1(){

        List<Account> accounts = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '123456789'];
        accounts[1].ShippingCity = 'Brugge';
        accounts[2].Type = 'School Group';
        
        
        Test.startTest();
            update accounts;
            MERGE_MergeAccounts_Batch  MergeCon = new MERGE_MergeAccounts_Batch(false, true, false, 'Plantyn');
            Id batchprocessid = Database.executebatch(MergeCon, 1);
        Test.stopTest();

        System.assertEquals(3, [SELECT Count() FROM Account WHERE ExternalCustomerId__c = '123456789']);
        
    }
    @IsTest
    static void testExernalCustomerIdMatchingShouldNotMerge2(){

        List<Account> accounts = [SELECT Id FROM Account WHERE ExternalCustomerId__c = '123456789'];
        accounts[1].Categories__c = 'A';
        accounts[2].KlopotekNumber__c = '12345abc';
        
        
        Test.startTest();
            update accounts;
            MERGE_MergeAccounts_Batch  MergeCon = new MERGE_MergeAccounts_Batch(false, true, false, 'Plantyn');
            Id batchprocessid = Database.executebatch(MergeCon, 1);
        Test.stopTest();

        System.assertEquals(3, [SELECT Count() FROM Account WHERE ExternalCustomerId__c = '123456789']);
        
    }

    @IsTest
    static void testOldAccountIdMatchingShouldMerge(){
        
        Test.startTest();
            MERGE_MergeAccounts_Batch  MergeCon = new MERGE_MergeAccounts_Batch(false, false, true);
            Id batchprocessid = Database.executebatch(MergeCon, 1);
        Test.stopTest();

     //   System.assertEquals(1, [SELECT Count() FROM Account WHERE OldAccountId__c = 'hijklmno']);
        
    }

}