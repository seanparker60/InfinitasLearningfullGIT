public class Order_ResyncFailedOrdersBatch implements Database.Batchable<sObject> {
    
    @InvocableMethod (Label='resyncFailedOrders')
    public static void resyncFailedOrders(){
        Order_ResyncFailedOrdersBatch myBatchObject = new Order_ResyncFailedOrdersBatch();
		Id batchId = Database.executeBatch(myBatchObject, 1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([SELECT Id, OrderNumber, Status, SyncedWithNS__c, NSOrderStatus__c, OperatingCompany__c, ErrorReason__c, ValidationErrorsOrder__c, SuccessStatusOfLastAWSUpdate__c, IntegrationFactorySend__c  
                                         FROM Order 
                                         WHERE Status = 'Activated' AND SyncedWithNS__c = true AND NSOrderStatus__c = null AND OperatingCompany__c != null AND ErrorReason__c = 'None' AND ValidationErrorsOrder__c = 0 AND SuccessStatusOfLastAWSUpdate__c != null AND BlockSync__c = false]);
    }
    
    public void execute(Database.BatchableContext bc, List<Order> records){
        // process each batch of records
        for(Order thisOrder : records){
            Map<String, Object> params = new Map<String, Object>();
            params.put('var_Order', thisOrder);
            Flow.Interview.Order_RetriggerIntegrationFactorySync myFlow = new Flow.Interview.Order_RetriggerIntegrationFactorySync(params);
            myFlow.start();
        }
    }
    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    
}