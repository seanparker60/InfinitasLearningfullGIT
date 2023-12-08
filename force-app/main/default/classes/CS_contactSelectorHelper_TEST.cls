@IsTest
public class CS_contactSelectorHelper_TEST {
    
    @TestSetup
    static void testSetup(){
        Account a = CS_TestDataFactory.createAccount(true);
        List<Contact> contacts = CS_TestDataFactory.createContacts(a.Id, 4, true);
        Lead ld = CS_TestDataFactory.creatLead(true);
    }

    @IsTest
    public static void testReturnContacts(){
        
        Lead ld = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
            List<Contact> contacts = CS_contactSelectorHelper.returnContacts(ld.Id);
        Test.stopTest();

        System.debug('contacts.size() ==> ' + contacts.size());
      //  System.assertEquals(4, contacts.size());
        
    }

    @IsTest
    static void testMarkForContactSelection(){
        
        Lead ld = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
            CS_contactSelectorHelper.markForContactSelection(ld.Id);
        Test.stopTest();

        Lead ldAfter = [SELECT Id, AutoConvertContactMatchStatus__c FROM Lead LIMIT 1];

        System.assertEquals('Multiple results', ldAfter.AutoConvertContactMatchStatus__c);
        
    }

    @IsTest
    static void testUpdateLead(){
        
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        ld.AutoConvertContactMatchStatus__c = 'Multiple results';
        update ld;

        Lead ldBefore = [SELECT Id, Contact__c, AutoConvertContactMatchStatus__c FROM Lead LIMIT 1];

        System.assertEquals(null, ldBefore.Contact__c);
        System.assertEquals('Multiple results', ldBefore.AutoConvertContactMatchStatus__c);

        Contact c = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
            CS_contactSelectorHelper.updateLead(ld.Id, c.Id);
        Test.stopTest();

        Lead ldAfter = [SELECT Id, AutoConvertContactMatchStatus__c, Contact__c FROM Lead LIMIT 1];
        
        System.assertEquals(c.Id, ldAfter.Contact__c);
        System.assertEquals(null, ldAfter.AutoConvertContactMatchStatus__c);
    
    }
}