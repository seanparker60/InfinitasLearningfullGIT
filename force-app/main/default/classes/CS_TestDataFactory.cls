@IsTest
public class CS_TestDataFactory {
    
    public static Account createAccount(Boolean doInsert) {

        Id B2BEdicationalRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('B2B Educational').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.NumberofStudents__c = 1;
        acc.OperatingCompany__c = 'Plantyn';
        acc.CustomerCategory__c = 'Educational Institution';
        acc.TypeOfAccount__c = 'Sales and Order';
        acc.RecordTypeId = B2BEdicationalRecordTypeId;
        acc.Area__c = 'Dutch';

        if (doInsert) {
            insert acc;
        }

        return acc;
    }

    public static List<Contact> createContacts(Id accountId, Integer amount, Boolean doInsert) {

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < amount; i++) {
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact ' + (i+1);
            c.Email = (i+1) + 'test@test.com';
            c.OperatingCompany__c = 'Plantyn';
            c.AccountId = accountId;
            contacts.add(c);
        }

        if (doInsert) {
            insert contacts;
        }

        return contacts;
    }

    public static Lead creatLead(Boolean doInsert) {

        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead';
        ld.Email = 'test@test.com';
        ld.OperatingCompany__c = 'Plantyn';
        ld.Status = 'New';
        ld.Company = 'Test Account';
        ld.Segment__c = 'Primary Education';
        ld.MatchType__c = 'Email';

        if (doInsert) {
            insert ld;
        }

        return ld;
    }
}