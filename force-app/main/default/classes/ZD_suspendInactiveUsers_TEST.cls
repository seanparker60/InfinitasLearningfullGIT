@IsTest
public class ZD_suspendInactiveUsers_TEST {
    
    // @TestSetup
    // public static void makeData(){
        
    // }

    @IsTest
    public static void test_01(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ZD_testDataFactory.correctMock());
            System.enqueueJob(new ZD_suspendInactiveUsers());
        Test.stopTest();
        
    }

    @IsTest
    public static void test_ZD_suspendInactiveUsers_Invocable(){
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ZD_testDataFactory.correctMock());
            ZD_suspendInactiveUsers_Invocable.start();
        Test.stopTest();
        
    }
}