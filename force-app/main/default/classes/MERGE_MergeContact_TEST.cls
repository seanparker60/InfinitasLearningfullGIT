@isTest
public class MERGE_MergeContact_TEST {
    
    @TestSetup
    static void makeData(){

        List<Account> accounts = MERGE_TestDataFactory.createAccounts(3, true);
        System.debug('=====> Number of inserted Accounts = ' + accounts.size());
        List<Contact> contacts = new List<Contact>();
        contacts.addAll(MERGE_TestDataFactory.createContactsForEmailMatchingOnTeacherSchoolNumber(1, accounts, false));
        contacts.addAll(MERGE_TestDataFactory.createContactsForManualCheck(1, accounts, false));
        contacts.addAll(MERGE_TestDataFactory.createContactsForEmailMatchingOnAccount(3, accounts[0], false));
        contacts.addAll(MERGE_TestDataFactory.createContactsForTeacherNumberMatching(1, accounts, false));
        insert contacts;
        System.debug('=====> Number of inserted Contacts = ' + contacts.size());
        
    }

    @IsTest
    static void TestOnEmailAndAccountMerge() {
        
        String emailForMatching = 'email2@test.com';
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE Email = :emailForMatching ORDER BY LastModifiedDate DESC];
        Test.startTest();
            MERGE_MergeContact.MergeContacts(contacts);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'email2@test.com']);

    }

    @isTest
    static void TestOnEmailAndTeacherSchoolNumberMerge() {
        
        String emailForMatching = 'email@test.com';
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE Email = :emailForMatching ORDER BY LastModifiedDate DESC];
        System.debug('=====> Number of Contacts in Query: ' + contacts.size());
        System.debug('=====> Contacts:');
        for (Contact c : contacts) {
            System.debug('==========> ' + c);
        }
        Test.startTest();
            MERGE_MergeContact.MergeContacts(contacts);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'email@test.com']);

    }

    @isTest
    static void TestOnTeacherNumber() {
        
        String TeacherNumber = '987654321';
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId FROM Contact WHERE TeacherNumber__c = :TeacherNumber ORDER BY LastModifiedDate DESC];
        System.debug('=====> Number of Contacts in Query: ' + contacts.size());
        Test.startTest();
            MERGE_MergeContact.MergeContacts(contacts);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE TeacherNumber__c = '987654321']);

    }

    @isTest
    static void TestManualCheck() {

        String emailForMatching = 'email4@test.com';
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE Email = :emailForMatching ORDER BY LastModifiedDate DESC];
        System.debug('=====> Number of Contacts in Query: ' + contacts.size());
        Test.startTest();
            MERGE_MergeContact.MergeContacts(contacts);
        Test.stopTest();

        List<Contact> mergeContactCheckList = [SELECT ManualMergeCheck__c FROM Contact WHERE Email = 'email4@test.com'];
        
        System.assertEquals(true, mergeContactCheckList[0].ManualMergeCheck__c);
        System.assertEquals(true, mergeContactCheckList[1].ManualMergeCheck__c);
        System.assertEquals(true, mergeContactCheckList[2].ManualMergeCheck__c);

    }

}