@isTest
public class UTIL_ApexJobSummary_TEST {
    @testSetup
    public static void makeData(){
        SystemMonitor__c sysMon = new SystemMonitor__c();
        sysMon.Type__c = 'Integration';
        sysMon.Object__c = 'Order';
        insert sysMon;
    }
    
    public static testMethod void testUTIL_ApexJobSummary1(){
        test.startTest();
        UTIL_ApexJobSummary.Request req = new UTIL_ApexJobSummary.Request();
        List<UTIL_ApexJobSummary.Request> lsReq = new List<UTIL_ApexJobSummary.Request>();
        req.startDate = Date.today().addDays(-1);
        req.endDate = Date.today();
        lsReq.add(req);

        UTIL_ApexJobSummary.createSummaries(lsReq);

        test.stopTest();
    }
    
    public static testMethod void testUTIL_ApexJobSummary2(){
        test.startTest();
        List<UTIL_ApexJobSummary.Request> lsReq = new List<UTIL_ApexJobSummary.Request>();
        
        UTIL_ApexJobSummary.createSummaries(lsReq);
        
        test.stopTest();
    }
}