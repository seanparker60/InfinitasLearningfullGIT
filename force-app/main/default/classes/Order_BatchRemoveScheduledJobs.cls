Global with sharing class Order_BatchRemoveScheduledJobs implements Database.Batchable<sObject>,Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
           
        
        return Database.getQueryLocator([SELECT Id FROM CronTrigger WHERE CronJobDetail.Name like: '%Started At%' AND StartTime !=: null]  ); 
    }

    global void execute(Database.BatchableContext BC, List<CronTrigger> scope){
        for(CronTrigger cron:scope){
            System.abortJob(cron.Id);    
        }
    }    
    global void finish(Database.BatchableContext BC){

    }    
    global void execute(SchedulableContext sc)
    {
        Order_BatchRemoveScheduledJobs  RemoveScheduledJobs = new Order_BatchRemoveScheduledJobs();
        database.executebatch(RemoveScheduledJobs ,15);
    }

}