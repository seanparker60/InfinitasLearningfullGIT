@isTest
public class UTIL_MergeContact_TEST {
    @TestSetup
    static void makeData(){

        List<Account> accounts = UTIL_TestDatafactory.createAccounts(3, true);
        List<Contact> contacts = new List<Contact>();
        contacts.addAll(UTIL_TestDatafactory.createContactsForEmailMatchingOnTeacherSchoolNumber(1, accounts, false));
        contacts.addAll(UTIL_TestDatafactory.createContactsForEmailMatchingOnAccount(3, accounts[0], false));
        contacts.addAll(UTIL_TestDatafactory.createContactsDorTeacherNumberMatching(1, accounts, false));
        insert contacts;
        
    }

    @IsTest
    static void TestOnEmailAndAccountMerge(){
        
        String emailForMatching = 'email2@test.com';
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE Email = :emailForMatching ORDER BY LastModifiedDate DESC];
        Test.startTest();
            UTIL_MergeContact.MergeContacts(contacts);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'email2@test.com']);

    }

    @isTest
    static void TestOnEmailAndTeacherSchoolNumberMerge(){
        
        String emailForMatching = 'email@test.com';
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId, TeacherSchoolNumber__c FROM Contact WHERE Email = :emailForMatching ORDER BY LastModifiedDate DESC];
        System.debug('====> Number of Contacts in Query: ' + contacts.size());
        Test.startTest();
            UTIL_MergeContact.MergeContacts(contacts);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'email@test.com']);

    }

    @isTest
    static void TestOnTeacherNumber(){
        
        String TeacherNumber = '987654321';
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, CommunicationLanguage__c, OperatingCompany__c, MailingStreet, MailingCity, MailingCountry, TeacherNumber__c, AccountId FROM Contact WHERE TeacherNumber__c = :TeacherNumber ORDER BY LastModifiedDate DESC];
        System.debug('====> Number of Contacts in Query: ' + contacts.size());
        Test.startTest();
            UTIL_MergeContact.MergeContacts(contacts);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE TeacherNumber__c = '987654321']);

    }
}