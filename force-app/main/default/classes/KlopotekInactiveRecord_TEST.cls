@isTest
public class KlopotekInactiveRecord_TEST {
    public static testMethod void testClass(){
        //KlopotekInactiveRecordSchedulable
        List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(1, 'Noordhoff',true,true);
        
        List<Contact> conLst = new List<Contact>();
        for (Integer i = 0; i < 1; i++) {
            Contact con = New Contact();
            con.FirstName = 'Test';
            con.LastName = 'Contact ' + (i+1);
            con.AccountId = lstAccount[0].Id;
            con.OperatingCompany__c = 'Noordhoff';
            con.Email = (i+1) + 'testEmail@test.com';
            conLst.add(con);
        }
        insert conLst;
        
        KlopotekAccount__c ka = new KlopotekAccount__c();
        ka.Account__c = lstAccount[0].Id;
        insert ka;
        
        KlopotekContact__c kc = new KlopotekContact__c();
        kc.Contact__c = conLst[0].Id;
        insert kc;
        
        test.startTest();
        KlopotekInactiveRecordSchedulable klopotekTest = new KlopotekInactiveRecordSchedulable();
        klopotekTest.execute(null);
        test.stopTest();
    }
}