@IsTest
public class LEAD_leadTriggerHelper_TEST {
    
    @TestSetup
    static void makeData(){
        LEAD_TestDataFactory.createLeads(1, true);
        Account acc = LEAD_TestDataFactory.insertAccounts(1, 'Plantyn', true)[0];
        Contact c = LEAD_TestDataFactory.createContacts(1, acc, true)[0];
    }

    @IsTest
    static void testInsert1(){
        
        Lead l = LEAD_TestDataFactory.createLeads(1, false)[0];
        l.Status = 'Discarded';
        l.ReasonClosed__c = '7-Duplicate/test/wrong data';

        Test.startTest();
            insert l;
        Test.stopTest();
        
        System.assertEquals(true, [SELECT IsDeleted FROM Lead WHERE Id = :l.Id LIMIT 1 ALL ROWS].IsDeleted);
    }

    @IsTest
    static void testInsert2(){
        
        Id queueId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Default Lead queue' LIMIT 1].Queue.Id;
        Account a = [SELECT Id FROM Account LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Lead l = LEAD_TestDataFactory.createLeads(1, false)[0];
        l.OwnerId = queueId;
        l.Account__c = a.Id;
        l.Contact__c = c.Id;
        l.Status = 'Discarded';
        l.ReasonClosed__c = '1-Already chosen other method';

        Test.startTest();
            insert l;
        Test.stopTest();
        
        System.assertEquals(true, [SELECT AutoConvert__c FROM Lead WHERE Id = :l.Id LIMIT 1 ALL ROWS].AutoConvert__c);
    }

    @IsTest
    static void testUpdate1(){
        
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        l.Status = 'Discarded';
        l.ReasonClosed__c = '7-Duplicate/test/wrong data';

        Test.startTest();
            update l;
        Test.stopTest();
        
        System.assertEquals(true, [SELECT IsDeleted FROM Lead WHERE Id = :l.Id LIMIT 1 ALL ROWS].IsDeleted);
    }

    @IsTest
    static void testUpdate2(){
        
        Id queueId = [SELECT Queue.Id, Queue.Name FROM QueueSObject WHERE Queue.Name = 'Default Lead queue' LIMIT 1].Queue.Id;
        Account a = [SELECT Id FROM Account LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        l.OwnerId = queueId;
        l.Account__c = a.Id;
        l.Contact__c = c.Id;
        l.Status = 'Discarded';
        l.ReasonClosed__c = '1-Already chosen other method';

        Test.startTest();
            update l;
        Test.stopTest();
        
        System.assertEquals(true, [SELECT AutoConvert__c FROM Lead WHERE Id = :l.Id LIMIT 1 ALL ROWS].AutoConvert__c);
    }

}