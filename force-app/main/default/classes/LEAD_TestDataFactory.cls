@isTest
public class LEAD_TestDataFactory {
    
    public static List<Lead> createLeads(Integer amount, Boolean doInsert) {

        Id systemUserId = [SELECT Id FROM User WHERE Alias = 'suser' LIMIT 1].Id;
        List<Lead> leadList = New List<Lead>();

        for (Integer i = 0; i < amount; i++) {
            Lead l = new Lead();
            l.FirstName = 'test';
            l.LastName = 'Tester ' + (i+1);
            l.Status = 'new';
            l.OperatingCompany__c = 'Plantyn';
            l.Company = 'TestCompany';
            l.Segment__c = 'Primary Education';
            l.OwnerId = systemUserId;
            leadList.add(l);
        }
        if (doInsert) {
            insert leadList;
        }
        return leadList;
    }

    public static List<Account> insertAccounts(Integer Count, String Opco,Boolean doInsert){

        Id educationalRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND Name = 'B2B Educational' LIMIT 1].Id;
        List<Account> lst_Account = new List<Account>();
        for(Integer i=0;i<Count;i++){
            
            Account Acc = new Account();
            acc.RecordTypeId = educationalRecordTypeId;
            Acc.Name = 'School'+i;
            Acc.TypeOfAccount__c = 'Sales';
            Acc.OperatingCompany__c = Opco;
            Acc.CustomerCategory__c = 'Educational Institution';
            Acc.CustomerDiscountGroup__c = 'Educational Institution';
            Acc.NetsuiteInternalId__c = '1234'+i;
            Acc.ShippingCity = 'Amsterdam';
            Acc.ShippingCountry = 'Netherlands';
            Acc.ShippingPostalCode = '1224AM';
            Acc.ShippingStreet = 'DePijp22';
            Acc.Area__c = 'Dutch';  
            lst_Account.Add(Acc);
        }
        if(doInsert) {
            insert lst_Account;
        }
        return lst_Account;

    }

    public static List<Contact> createContacts(Integer amount, Account account, Boolean doInsert) {

        List<Contact> contactList = New List<Contact>();

        for (Integer i = 0; i < amount; i++) {
            Contact c = New Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact ' + (i+1);
            c.OperatingCompany__c = account.OperatingCompany__c;
            c.AccountId = account.Id;
            contactList.add(c);
        }
        if (doInsert) {
            insert contactList;
        }
        return contactList;
    }

}