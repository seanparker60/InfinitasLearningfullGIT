@isTest
public class ImportOrderRetryRESTAPI_TEST {
    
    public static testMethod void testImportOrderRetryRESTAPI(){
        ImportOrder__c io = new ImportOrder__c();
        io.Status__c = 'Error';
        io.ExternalOrderId__c = 'contest';
        io.Error__c = 'This error occurred when the flow tried to create records: UNABLE_TO_LOCK_ROW: unable to obtain exclusive access to this record or 1 records: 0013V00000AIZ7wQAH';
        
        insert io;
        
        ImportOrder__c io2 = new ImportOrder__c();
        io2.Status__c = 'Error';
        io2.ExternalOrderId__c = 'contest';
        io2.Error__c = 'Cant find parent';
        
        insert io2;

        test.startTest();
        ImportOrderRetryRESTAPI.doPost(io.ExternalOrderId__c);
        ImportOrderRetryRESTAPI.retryImportOrder(io.ExternalOrderId__c);
        test.stopTest();
    }
}