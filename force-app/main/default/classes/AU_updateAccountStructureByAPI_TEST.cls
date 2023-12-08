@IsTest
public class AU_updateAccountStructureByAPI_TEST {
    @TestSetup
    static void makeData(){
        List<Account> accounts = AU_TestDataFactory.createMultipleAccounts(10, false);
        accounts.addAll(AU_TestDataFactory.createAccounts(false));
        insert accounts;

        AgodiUpdate__c au = new AgodiUpdate__c();
        insert au;
    }

    @IsTest
    static void Test01(){

        Map<String, Id> schoolNumberAccountIdMap = new Map<String, Id>();
        Map<String, Account> PlantynAccounts = new Map<String, Account>();
        Id agodiId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<Id> createdAccounts = new List<Id>();
        List<Id> updatedAccounts = new List<Id>();
        
        List<Account> accountList = [SELECT Id, ExternalCustomerId__c FROM Account];
        for (Account acc : accountList) {
            if (acc.ExternalCustomerId__c.length() > 5) {
                PlantynAccounts.put(acc.ExternalCustomerId__c, acc);
                updatedAccounts.add(acc.Id);
            } else {
                schoolNumberAccountIdMap.put(acc.ExternalCustomerId__c, acc.Id);
                PlantynAccounts.put(acc.ExternalCustomerId__c, acc);
                createdAccounts.add(acc.Id);
            }
        }

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AU_TestDataFactory.MockInstellingDetails());
            System.enqueueJob(new AU_updateAccountStructureByAPI(schoolNumberAccountIdMap, PlantynAccounts, agodiId, createdAccounts, updatedAccounts));
        Test.stopTest(); 
    }

    @IsTest
    static void Test02(){

        Map<String, Id> schoolNumberAccountIdMap = new Map<String, Id>();
        Map<String, Account> PlantynAccounts = new Map<String, Account>();
        Id agodiId = [SELECT Id FROM AgodiUpdate__c LIMIT 1].Id;
        List<Id> createdAccounts = new List<Id>();
        List<Id> updatedAccounts = new List<Id>();
        List<Account> AccountsToUpdate = new List<Account>();
        List<Database.SaveResult> resultList = new List<Database.SaveResult>();
        
        List<Account> accountList = [SELECT Id, ExternalCustomerId__c FROM Account];
        for (Account acc : accountList) {
            if (acc.ExternalCustomerId__c.length() > 5) {
                PlantynAccounts.put(acc.ExternalCustomerId__c, acc);
                updatedAccounts.add(acc.Id);
            } else {
                schoolNumberAccountIdMap.put(acc.ExternalCustomerId__c, acc.Id);
                createdAccounts.add(acc.Id);
            }
        }

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AU_TestDataFactory.MockInstellingDetails());
            System.enqueueJob(new AU_updateAccountStructureByAPI(schoolNumberAccountIdMap, PlantynAccounts, 0, agodiId, accountsToUpdate, resultList, createdAccounts, updatedAccounts));
        Test.stopTest(); 
    }
}