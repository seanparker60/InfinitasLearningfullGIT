@isTest
public class UTIL_CleanObjectRecordsScheduleable_TEST {
    @testSetup
    public static void makedata(){
        ErrorLog__c errLog = new ErrorLog__c();
        errLog.ClassName__c = 'Test';
        errLog.MethodName__c = 'Test';
        insert errLog;
        
        ErrorLog__c errLog2 = new ErrorLog__c();
        errLog2.ClassName__c = 'Test';
        errLog2.MethodName__c = 'Test';
        insert errLog2;
        
        List<SystemMonitor__c> sysMonLs = new List<SystemMonitor__c>();
        
        SystemMonitor__c sysMon1 = new SystemMonitor__c();
        sysMon1.Object__c = 'Account';
        sysMon1.Type__c = 'Integration';
        sysMon1.OperatingCompany__c = 'Plantyn';
        sysMonLs.add(sysMon1);
        
        SystemMonitor__c sysMon2 = new SystemMonitor__c();
        sysMon2.Object__c = 'Order';
        sysMon2.Type__c = 'Integration';
        sysMon2.OperatingCompany__c = 'Liber';
        sysMonLs.add(sysMon2);
        
        SystemMonitor__c sysMon3 = new SystemMonitor__c();
        sysMon3.Object__c = 'Account';
        sysMon3.Type__c = 'Integration';
        sysMon3.OperatingCompany__c = 'Plantyn';
        sysMonLs.add(sysMon3);
        
        insert sysMonLs;
    }
    
    @isTest
    public static void testUTIL_CleanObjectRecords(){
        Date overrideDate = Date.today().addMonths(-2);
        Date overrideDate2 = Date.today().addMonths(-3);
        Date overrideDate3 = Date.today().addMonths(-7);
        
        List<SystemMonitor__c> sysMonLs = [SELECT Id from SystemMonitor__c LIMIT 3];
        List<ErrorLog__c> errLogLs = [SELECT Id from ErrorLog__c LIMIT 2];
        
        Test.setCreatedDate(errLogLs[0].Id, overrideDate);
        Test.setCreatedDate(errLogLs[1].Id, overrideDate2);
        
        Test.setCreatedDate(sysMonLs[0].Id, overrideDate);
        Test.setCreatedDate(sysMonLs[1].Id, overrideDate2);
        Test.setCreatedDate(sysMonLs[2].Id, overrideDate3);
        
        test.startTest();
        UTIL_CleanObjectRecordsInvocable.cleanObjects();
        //UTIL_CleanObjectRecordsScheduleable ctrl = new UTIL_CleanObjectRecordsScheduleable();
        //ctrl.execute(null);
        test.stopTest();
    }
}