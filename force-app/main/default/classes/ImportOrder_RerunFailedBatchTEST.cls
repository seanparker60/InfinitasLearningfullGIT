@isTest
public class ImportOrder_RerunFailedBatchTEST {
    @testSetup
    public static void setupData(){
        ImportOrder__c io = new ImportOrder__c();
        io.OperatingCompany__c = 'Plantyn';
        io.Source__c = 'B2B Salesforce';
        io.customerNo__c = '1234';
        io.ExternalOrderId__c = 'howzit';
        io.ProductId__c = null;
        io.Status__c = 'Error';
        
        insert io;
        
        ImportOrder__c ioLine = new ImportOrder__c();
        ioLine.OperatingCompany__c = 'Plantyn';
        ioLine.Source__c = 'B2B Salesforce';
        ioLine.customerNo__c = '1234';
        ioLine.ExternalOrderId__c = 'howzit';
        ioLine.ProductId__c = 'test';
        ioLine.Status__c = 'Error';
        
        insert ioLine;
    }
    
    public static testMethod void testImportOrder_RerunFailedBatch1(){
        test.startTest();
        ImportOrder_RerunFailedBatch.ImportOrderDTO ioDTO = new ImportOrder_RerunFailedBatch.ImportOrderDTO();
        ioDTO.allOrSpecificRun = 'All';
        ioDTO.externalOrderId = null;
        
        ImportOrder_RerunFailedBatch.rerunImportOrders(new List<ImportOrder_RerunFailedBatch.ImportOrderDTO> {ioDTO});
        
        test.stopTest();
    }
    
    public static testMethod void testImportOrder_RerunFailedBatch2(){
        test.startTest();
        ImportOrder_RerunFailedBatch.ImportOrderDTO ioDTO = new ImportOrder_RerunFailedBatch.ImportOrderDTO();
        ioDTO.allOrSpecificRun = 'Specific';
        ioDTO.externalOrderId = 'howzit';
        
        ImportOrder_RerunFailedBatch.rerunImportOrders(new List<ImportOrder_RerunFailedBatch.ImportOrderDTO> {ioDTO});
        
        test.stopTest();
    }
    
    public static testMethod void testImportOrder_RerunFailedBatch3(){
        test.startTest();
        ImportOrder_LockErrorRetryBatch.ImportOrderRetryDTO ioDTO = new ImportOrder_LockErrorRetryBatch.ImportOrderRetryDTO();
        ioDTO.externalOrderId = 'howzit';
        
        ImportOrder_LockErrorRetryBatch.retryImportOrders(new List<ImportOrder_LockErrorRetryBatch.ImportOrderRetryDTO> {ioDTO});
        
        test.stopTest();
    }
}