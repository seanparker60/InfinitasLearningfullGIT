@IsTest
public class AU_AgodiUpdateByAPI_TEST {

    @TestSetup
    static void makeData(){

        Account[] agodiAccounts = AU_TestDataFactory.createAccounts(true);
        
    }

    @IsTest
    static void test01(){

        Account[] agodiAccounts = [SELECT Id,Name,NumberOfStudents__c,LegalName__c,PurchasingGroup__c,ExternalCustomerId__c,ExternalDatabase__c,PhoneCountry__c,CustomerDiscountGroup__c FROM Account];
        Map<String,Account> agodiAccountMap = new Map<String, Account>();
        for (Account acc: agodiAccounts) {
            agodiAccountMap.put(acc.ExternalCustomerId__c, acc);
        }

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AU_TestDataFactory.Mock());
            System.enqueueJob(new AU_AgodiUpdateByAPI(agodiAccountMap));
        Test.stopTest();

    }
}