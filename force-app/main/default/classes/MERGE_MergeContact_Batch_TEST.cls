@isTest
public class MERGE_MergeContact_Batch_TEST {
    
    @TestSetup
    static void makeData(){

        List<Account> accounts = MERGE_TestDataFactory.createAccounts(3, true);
        System.debug('=====> Number of inserted Accounts = ' + accounts.size());
        List<Contact> contacts = new List<Contact>();
        contacts.addAll(MERGE_TestDataFactory.createContactsForEmailMatchingOnTeacherSchoolNumber(1, accounts, false));
        contacts.addAll(MERGE_TestDataFactory.createContactsForTeacherNumberMatching(1, accounts, false));
        insert contacts;
        System.debug('=====> Number of inserted Contacts = ' + contacts.size());
        
    }

    @IsTest
    static void TestTeacherNumberMatching(){
        
        Test.startTest();
            MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(false, true, false, false);
            Id batchprocessid = Database.executebatch(MergeCon, 1);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE TeacherNumber__c = '987654321']);

    }
    
    @IsTest
    static void TestEmailMatching(){
        
        Test.startTest();
            MERGE_MergeContacts_Batch  MergeCon = new MERGE_MergeContacts_Batch(false, false, false, true);
            Id batchprocessid = Database.executebatch(MergeCon, 1);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Email = 'email@test.com']);

    }
}