global with sharing class Order_BatchQueueableMonitor implements Database.Batchable<sObject>,Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        
        return Database.getQueryLocator([SELECT jobtype FROM AsyncApexJob limit 1]  ); 
    }

    global void execute(Database.BatchableContext BC, List<AsyncApexJob> scope){
        
        Integer nonBatchAsyncApexJobs = [SELECT count() FROM AsyncApexJob WHERE JobType != 'BatchApexWorker' AND JobType != 'BatchApex' AND CreatedDate >= :DateTime.now().addDays(-1)];
        AggregateResult[] ar = [SELECT SUM(JobItemsProcessed) FROM AsyncApexJob WHERE JobType = 'BatchApex' AND CreatedDate >= :DateTime.now().addDays(-1)];
        Integer batchJobItemsProcessed = Integer.valueOf(ar[0].get('expr0'));
        Integer total = nonBatchAsyncApexJobs + batchJobItemsProcessed;

        SystemMonitor__c SystemMonitor = new SystemMonitor__c();
        SystemMonitor.Type__c = 'Queueable';
        SystemMonitor.Message__c = 'Last 24 Hours';
        SystemMonitor.SystemMonitorCount__c = total;
        
        Insert SystemMonitor;

        System.debug('total: ' + total);
    }    
    global void finish(Database.BatchableContext BC){

    }    
    global void execute(SchedulableContext sc)
    {
        Order_BatchQueueableMonitor  RemoveScheduledJobs = new Order_BatchQueueableMonitor();
        database.executebatch(RemoveScheduledJobs ,1);
    }

}