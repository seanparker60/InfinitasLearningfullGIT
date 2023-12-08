global with sharing class Order_BatchResetAccountAssetRenewal Implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts{
    
   
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        return Database.getQueryLocator([SELECT Id  FROM Account where RenewalAssetToday__c =: true]  );
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

       
        Set<String> Set_BillTo = new Set<String>();
        for (Account acc : scope) {
            acc.RenewalAssetToday__c = false;
        }

        update scope;
   
    }    

    global void finish(Database.BatchableContext BC){

        
    }

    global void execute(SchedulableContext sc)
    {
        Order_BatchResetAccountAssetRenewal  orderActivate = new Order_BatchResetAccountAssetRenewal();
        database.executebatch(orderActivate ,20);
    }

}