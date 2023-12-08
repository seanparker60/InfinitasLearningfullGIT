@isTest
public with sharing class MERGE_MergeAccount_TEST {

    @TestSetup
    static void makeData(){
        
        List<Account> accountLst = MERGE_TestDataFactory.createAccounts(2, true);
        MERGE_TestDataFactory.createAccountsForAccountMatchTest1(3, accountLst, true);

    }

   @IsTest
    static void StandardMergeTestShouldMerge(){
        
        List<Account> accountList = [SELECT Id, ManualMergeCheck__c, ExternalCustomerId__c, KGStudents__c, HEStudents__c, PEStudents__c, SEStudents__c, VEStudents__c, OldAccountIdOrigin__c, OperatingCompany__c, OldAccountId__c, InvoicingEmail__c, LastAgodiUpdate__c, ParentId, PurchasingGroup__c, NumberofStudents__c, OwnerId, Categories__c, KlopotekNumber__c FROM Account WHERE ExternalCustomerId__c = '123456789' ORDER BY Name ASC];
        
        Test.startTest();
            MERGE_MergeAccount.MergeAccounts(accountList, false);
        Test.stopTest();

       // System.assertEquals(1, [SELECT Count() FROM Account WHERE ExternalCustomerId__c = '123456789']);
        
    }
    @IsTest
    static void StandardMergeTestShouldError(){

        List<Account> parentAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Parent Test Account%'];
        MERGE_TestDataFactory.createAccountsForAccountMatchTest1(1, parentAccounts, true);
        
        List<Account> accountList = [SELECT Id, ManualMergeCheck__c, ExternalCustomerId__c, KGStudents__c, HEStudents__c, PEStudents__c, SEStudents__c, VEStudents__c, OldAccountIdOrigin__c, OperatingCompany__c, OldAccountId__c, InvoicingEmail__c, LastAgodiUpdate__c, ParentId, PurchasingGroup__c, NumberofStudents__c, OwnerId, Categories__c, KlopotekNumber__c FROM Account WHERE ExternalCustomerId__c = '123456789' ORDER BY Name ASC];
        
        Test.startTest();
            MERGE_MergeAccount.MergeAccounts(accountList, false);
        Test.stopTest();

        List<Account> accountsForAssertion = [SELECT Id, ManualMergeCheck__c FROM Account WHERE ExternalCustomerId__c = '123456789'];
        System.assertEquals(4, accountsForAssertion.size());
        for (Account a : accountsForAssertion) {
            System.assertEquals(true, a.ManualMergeCheck__c);
        }
        
    }
}