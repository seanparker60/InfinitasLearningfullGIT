global class ImportOrder_LockErrorRetryBatch implements Queueable {
    private ImportOrder__c ioRecord;
    private String externalOrderId;
    private Integer numOfRetries;
    private Integer maxNumOfRetries;
    
    global class ImportOrderRetryDTO {
        @InvocableVariable global String externalOrderId;
    }
    
    public ImportOrder_LockErrorRetryBatch(ImportOrder__c io, String extId, Integer countRetries){
        ioRecord = io;
        externalOrderId = extId;
        numOfRetries = countRetries;
        
        List<ImportOrderSetting__mdt> ioSettings = ImportOrderSetting__mdt.getAll().values();
        maxNumOfRetries = Integer.valueOf(ioSettings[0].MaxNoOfRetries__c);
    }
    
    public void execute(QueueableContext context) {
        ioRecord.Status__c = 'Pending';
        ioRecord.NoOfRetries__c = numOfRetries+1;
        ioRecord.DebugMessage__c = 'Processed successfully via apex';
        update ioRecord;
        
        // get rest of lines that must be processed and use recursion to continuously call this queueable until there are no import order records left
        List<ImportOrder__c> ioLs = [SELECT Id,ProductId__c, TriggerBusinessLogic__c, NoOfRetries__c from ImportOrder__c WHERE ExternalOrderId__c =: externalOrderId AND Status__c = 'Error' ORDER BY ProductId__c ASC, TriggerBusinessLogic__c ASC];
        
        if(ioLs.size() > 0){
            Integer numRetries = Integer.valueOf(ioLs[0].NoOfRetries__c) == null ? 0 : Integer.valueOf(ioLs[0].NoOfRetries__c);
            
            if(!Test.isRunningTest()){
                
                if(numRetries < maxNumOfRetries){
                    System.enqueueJob(new ImportOrder_LockErrorRetryBatch(ioLs[0], externalOrderId, numRetries));
                }
            }
        }
    }
    
    @InvocableMethod(Label = 'Rerun Locked Import Orders')
    global static void retryImportOrders(ImportOrderRetryDTO[] ioRun){
        system.debug('===ioRun: ' + ioRun);
        
        List<ImportOrder__c> ioLs = [SELECT Id,ProductId__c, TriggerBusinessLogic__c, NoOfRetries__c from ImportOrder__c WHERE ExternalOrderId__c =: ioRun[0].externalOrderId AND Status__c = 'Error' ORDER BY ProductId__c DESC];
        system.debug('ioLs: ' + ioLs);
        
        Integer numRetries = Integer.valueOf(ioLs[0].NoOfRetries__c) == null ? 0 : Integer.valueOf(ioLs[0].NoOfRetries__c);
        
        System.enqueueJob(new ImportOrder_LockErrorRetryBatch(ioLs[0], ioRun[0].externalOrderId, numRetries));
    }
}