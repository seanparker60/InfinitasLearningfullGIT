@IsTest
public class SWELL_deactivateInactiveUsers_TEST {
    
    @TestSetup
    static void makeData(){
        
    }

    @IsTest
    static void TestCorrectMock(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SWELL_TestDataFactory.correctMock());
            System.enqueueJob(new SWELL_deactivateInactiveUsers());
        Test.stopTest();
        
    }

    @IsTest
    static void TestIncorrectMock01(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SWELL_TestDataFactory.incorrectMock01());
            System.enqueueJob(new SWELL_deactivateInactiveUsers());
        Test.stopTest();
        
    }

    @IsTest
    static void TestIncorrectMock02(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SWELL_TestDataFactory.incorrectMock02());
            System.enqueueJob(new SWELL_deactivateInactiveUsers());
        Test.stopTest();
        
    }
}