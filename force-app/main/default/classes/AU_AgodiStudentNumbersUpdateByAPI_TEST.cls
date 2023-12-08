@IsTest
public class AU_AgodiStudentNumbersUpdateByAPI_TEST {

    @TestSetup
    static void makeData(){
        List<Account> agodiAccounts = AU_TestDataFactory.createMultipleAccounts(20, true);
    }

    @IsTest
    static void TestGetStudentNumbers(){
        
        List<Account> agodiAccounts = [SELECT Id,ExternalCustomerId__c, ExternalDatabase__c FROM Account];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AU_TestDataFactory.MockStudentNumbers());
            System.enqueueJob(new AU_AgodiStudentNumbersUpdateByAPI(agodiAccounts));
        Test.stopTest();
        
    }

    @IsTest
    static void testUpdateAccounts(){
        
        List<Account> accountUpdateList = New List<Account>();
        List<Account> accList = [SELECT Id, ExternalCustomerId__c, ExternalDatabase__c FROM Account];

        for (Integer i = 0; i < accList.size(); i++) {
            Account acc = accList[i];
            acc.KGStudents__c = (i + 10);
            acc.PEStudents__c = (i + 20);
            acc.SEStudents__c = (i + 30);
            acc.VEStudents__c = (i + 40);
            accountUpdateList.add(acc);
        }

        Test.startTest();
            System.enqueueJob(new AU_AgodiStudentNumbersUpdateByAPI(accountUpdateList, true));
        Test.stopTest();
        
    }
}