@isTest
public class HandleCustomException_TEST {

    @TestSetup
    static void makeData(){
        CustomExceptionHandlingSettings__c sc = new CustomExceptionHandlingSettings__c(CriticalGovernorLimitPercentage__c = 90);
        insert sc;
    }

    @isTest
    public static void CreateDmlException() {
        
        Test.startTest();
        try {
            Contact c = new Contact();
            insert c;
        } catch (Exception e) {
            HandleCustomException.LogException(e);
        }
        Test.stopTest();
        
        List<ErrorLog__c> errorLogs = [SELECT ExceptionType__c FROM ErrorLog__c];

        System.assertEquals(1, errorLogs.size(), 'Incorrect number of ErrorLog objects inserted.');
        System.assertEquals('System.DmlException', errorLogs[0].ExceptionType__c, 'Incorrect Exception type.');
        System.assertEquals(1, [SELECT COUNT() FROM DMLErrorLog__c], 'Incorrect number of DML Error Logs inserted.');
    }

    @IsTest
    static void CreateQueryException(){
        
        Test.startTest();
            try {
                Contact c = [SELECT Id FROM Contact LIMIT 10];
            } catch (Exception e) {
                HandleCustomException.LogException(e);
            }
        Test.stopTest();

        List<ErrorLog__c> errorLogs = [SELECT ExceptionType__c FROM ErrorLog__c];

        System.assertEquals(1, errorLogs.size(), 'Incorrect number of ErrorLog objects inserted.');
        System.assertEquals('System.QueryException', errorLogs[0].ExceptionType__c, 'Incorrect Exception type.');
        System.assertEquals(0, [SELECT COUNT() FROM DMLErrorLog__c], 'Incorrect number of DML Error Logs inserted.');
    }
    
    @IsTest
    static void CreateCriticalGovernorLimitError(){
        
        Test.startTest();
            for (Integer i = 0; i < 95; i++) {
                List<Contact> clst = [SELECT Id FROM Contact LIMIT 1];
            }

            HandleCustomException.checkCriticalGovernorLimits(new DmlException().getStackTraceString().substringBefore('\n'));
        Test.stopTest();

        List<ErrorLog__c> errorLogs = [SELECT ExceptionType__c FROM ErrorLog__c];

        System.assertEquals(1, errorLogs.size(), 'Incorrect number of ErrorLog objects inserted.');
        System.assertEquals('Critical Governor Limits', errorLogs[0].ExceptionType__c, 'Incorrect Exception type.');
        System.assertEquals(0, [SELECT COUNT() FROM DMLErrorLog__c], 'Incorrect number of DML Error Logs inserted.');
    }

}