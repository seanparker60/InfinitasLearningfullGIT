@IsTest
public class AU_agodiHelper_TEST {
    
    @TestSetup
    static void makeData(){
        Account[] accounts = AU_TestDataFactory.createAccounts(true);
    }

    @IsTest
    static void test01(){
        
        Test.startTest();
            System.enqueueJob(new AU_agodiHelper(true, false));
        Test.stopTest();
        
    }

    @IsTest
    static void test02(){

        Map<String, Id> accountScholenMap = new Map<String, Id>();
        Id agodiId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Id> createdAccountIds = new List<Id>();
        List<Id> updatedAccountIds = new List<Id>();
        
        Test.startTest();
            System.enqueueJob(new AU_agodiHelper(true, false, accountScholenMap, agodiId, createdAccountIds, updatedAccountIds));
        Test.stopTest();
        
    }

    @IsTest
    static void test02_error(){

        Map<String, Id> accountScholenMap = new Map<String, Id>();
        Id agodiId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Id> createdAccountIds = new List<Id>();
        List<Id> updatedAccountIds = new List<Id>();
        
        Test.startTest();
            System.enqueueJob(new AU_agodiHelper(true, true, accountScholenMap, agodiId, createdAccountIds, updatedAccountIds));
        Test.stopTest();
        
    }

    @IsTest
    static void test03(){

        Id lastAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Account> AccountList = new List<Account>();
        
        Test.startTest();
            System.enqueueJob(new AU_agodiHelper(true, false, AccountList, lastAccountId));
        Test.stopTest();
        
    }

    @IsTest
    static void test03_error(){

        Id lastAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Account> AccountList = new List<Account>();
        
        Test.startTest();
            System.enqueueJob(new AU_agodiHelper(true, true, AccountList, lastAccountId));
        Test.stopTest();
        
    }

    @IsTest
    static void test04(){

        Map<String, Id> accountScholenMap = new Map<String, Id>();
        Id lastAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Account> AccountList = new List<Account>();
        
        Test.startTest();
            System.enqueueJob(new AU_agodiHelper(true, false, AccountList, accountScholenMap, lastAccountId));
        Test.stopTest();
        
    }

    @IsTest
    static void test04_error(){

        Map<String, Id> accountScholenMap = new Map<String, Id>();
        Id lastAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        List<Account> AccountList = new List<Account>();
        
        Test.startTest();
            System.enqueueJob(new AU_agodiHelper(true, true, AccountList, accountScholenMap, lastAccountId));
        Test.stopTest();
        
    }
}