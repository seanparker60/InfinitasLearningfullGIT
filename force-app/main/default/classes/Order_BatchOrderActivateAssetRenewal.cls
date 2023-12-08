global with sharing class Order_BatchOrderActivateAssetRenewal implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        //Simpler to start with Orders than Assets renewed today to ensure that there is no split due to batch size
       // Date CurrrentDay = system.today()-1; createddate >: CurrrentDay and

        system.debug('**Order Created: 1');
       return Database.getQueryLocator([SELECT Id,Billto__c  FROM Order where ActivateforBatchProcessing__c =:true AND  Status !=: 'Activated' AND  Status !=: 'Cancelled' and ValidationErrorsOrder__c =:0 and ValidationErrorsOrderProducts__c =:0 and LineCount__c >:0 Order by LineCount__c ASC limit 1]  );
    
       // return Database.getQueryLocator([SELECT Id  FROM Account where RenewalAssetToday__c =: true]  );
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope){  
        system.debug('**Order Created: checknextOrder()');
        String checked = '';
        Set<String> Set_Checked = new Set<String>();
        Order_OrderActivateQueueHandler.checknextOrder(checked,Set_Checked);

    
    }  

    global void finish(Database.BatchableContext BC){
        
        Datetime NextStart =  Datetime.now().addMinutes(1);

        CronTrigger[] cronJob = [SELECT Id,StartTime FROM CronTrigger WHERE CronJobDetail.Name like: '%Started At%'  AND StartTime !=: null];

       
       for(CronTrigger cron:cronJob){
            System.abortJob(cron.Id);    
       }
       
        

    }
    global void execute(SchedulableContext sc)
    {
        Order_BatchOrderActivateAssetRenewal  orderActivate = new Order_BatchOrderActivateAssetRenewal();
        database.executebatch(orderActivate ,1);
    }


}